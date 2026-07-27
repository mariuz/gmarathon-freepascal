{******************************************************************}
{ The contents of this file are used with permission, subject to   }
{ the Mozilla Public License Version 1.1 (the "License"); you may  }
{ not use this file except in compliance with the License. You may }
{ obtain a copy of the License at                                  }
{ http://www.mozilla.org/MPL/MPL-1.1.html                          }
{                                                                  }
{ Software distributed under the License is distributed on an      }
{ "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, either express or   }
{ implied. See the License for the specific language governing     }
{ rights and limitations under the License.                        }
{                                                                  }
{******************************************************************}

unit QueryModel;

{$MODE Delphi}

{ A query as the query builder holds it, and the SELECT it becomes.

  The old builder, QBuilder.pas, was 2819 lines of Delphi that drew its own
  table boxes with raw Polygon calls, handled WM_ messages by hand and called
  ClipCursor to trap the mouse. None of that survives a move to the LCL, so it
  was dropped from the program entirely - the unit is still in the tree but not
  in marathon.lpr, and the four menu items that opened it are commented out.

  What is worth keeping from a query builder is not the drawing. It is the
  answer to "given these tables, these joins and these columns, what is the
  SQL?" - and that question has nothing to do with a canvas. It lives here,
  where it is tested without a widgetset; the form draws boxes and calls in.

  The one genuinely hard part is join order. A join may only name a table that
  is already in the FROM clause, so the tables have to be emitted in an order
  where every join reaches backwards. Get it wrong and the SQL is syntactically
  fine and rejected by the server, which is the worst kind of wrong. }

interface

uses SysUtils, Classes;

type
  TJoinKind = (jkInner, jkLeft, jkRight, jkFull);

  TSortOrder = (soNone, soAscending, soDescending);

  TQueryTable = class
  public
    Schema: String;
    Name: String;
    { Unique within the query, and what every column reference uses. Assigned
      by AddTable rather than by the caller, because uniqueness is the whole
      point of it. }
    Alias: String;
  end;

  TQueryColumn = class
  public
    TableAlias: String;
    Name: String;
    { The AS name, when the user wants one. }
    OutputName: String;
    Sort: TSortOrder;
    { A condition on this column, written as it would appear after the column
      itself: '> 100', 'is null', "like 'A%'". Held as text because that is
      what the user types, and parsing it only to print it again would add a
      way to be wrong without adding anything. }
    Filter: String;
  end;

  TQueryJoin = class
  public
    Kind: TJoinKind;
    LeftAlias: String;
    LeftColumn: String;
    RightAlias: String;
    RightColumn: String;
  end;

  TQueryModel = class
  private
    FTables: TList;
    FColumns: TList;
    FJoins: TList;
    FDistinct: Boolean;
    FQuoteIdentifiers: Boolean;
    function GetTable(Index: Integer): TQueryTable;
    function GetColumn(Index: Integer): TQueryColumn;
    function GetJoin(Index: Integer): TQueryJoin;
    function UniqueAlias(const ATableName: String): String;
  public
    constructor Create;
    destructor Destroy; override;

    { Adds a table and gives it an alias no other table has. }
    function AddTable(const ASchema, AName: String): TQueryTable;
    function AddColumn(const ATableAlias, AName: String): TQueryColumn;
    function AddJoin(Kind: TJoinKind; const ALeftAlias, ALeftColumn,
      ARightAlias, ARightColumn: String): TQueryJoin;

    procedure RemoveTable(const AAlias: String);
    function TableByAlias(const AAlias: String): TQueryTable;

    function TableCount: Integer;
    function ColumnCount: Integer;
    function JoinCount: Integer;
    property Tables[Index: Integer]: TQueryTable read GetTable;
    property Columns[Index: Integer]: TQueryColumn read GetColumn;
    property Joins[Index: Integer]: TQueryJoin read GetJoin;

    property Distinct: Boolean read FDistinct write FDistinct;
    { Whether generated identifiers get double quotes. Off by default: Firebird
      folds unquoted names to upper case, and quoting everything makes every
      generated query case-sensitive in a way the user did not ask for. }
    property QuoteIdentifiers: Boolean read FQuoteIdentifiers
      write FQuoteIdentifiers;
  end;

{ The SELECT the model describes.

  Returns '' when there is nothing to select from. With no columns chosen it
  selects everything, which is what a builder with tables dropped on it but no
  boxes ticked plainly means. }
function BuildSelectSQL(Model: TQueryModel): String;

{ The order the tables must appear in for every join to reach a table already
  named. Returns the aliases. Tables that no join connects come out at the end,
  which makes them a cross join - the SQL says what the picture showed rather
  than quietly inventing a condition. }
function JoinOrder(Model: TQueryModel): TStringList;

{ True when every table is reachable from the first through joins. A builder
  should say so: an unjoined table multiplies the row count by its whole
  length, which looks like a hung query rather than a mistake. }
function IsFullyJoined(Model: TQueryModel): Boolean;

implementation

uses SQLIdentifiers, SchemaNames;

constructor TQueryModel.Create;
begin
  inherited Create;
  FTables := TList.Create;
  FColumns := TList.Create;
  FJoins := TList.Create;
end;

destructor TQueryModel.Destroy;
var
  Idx: Integer;
begin
  for Idx := 0 to FTables.Count - 1 do
    TQueryTable(FTables[Idx]).Free;
  for Idx := 0 to FColumns.Count - 1 do
    TQueryColumn(FColumns[Idx]).Free;
  for Idx := 0 to FJoins.Count - 1 do
    TQueryJoin(FJoins[Idx]).Free;
  FTables.Free;
  FColumns.Free;
  FJoins.Free;
  inherited Destroy;
end;

function TQueryModel.GetTable(Index: Integer): TQueryTable;
begin
  Result := TQueryTable(FTables[Index]);
end;

function TQueryModel.GetColumn(Index: Integer): TQueryColumn;
begin
  Result := TQueryColumn(FColumns[Index]);
end;

function TQueryModel.GetJoin(Index: Integer): TQueryJoin;
begin
  Result := TQueryJoin(FJoins[Index]);
end;

function TQueryModel.TableCount: Integer;
begin
  Result := FTables.Count;
end;

function TQueryModel.ColumnCount: Integer;
begin
  Result := FColumns.Count;
end;

function TQueryModel.JoinCount: Integer;
begin
  Result := FJoins.Count;
end;

function TQueryModel.TableByAlias(const AAlias: String): TQueryTable;
var
  Idx: Integer;
begin
  Result := nil;
  for Idx := 0 to FTables.Count - 1 do
    if SameText(TQueryTable(FTables[Idx]).Alias, AAlias) then
      Exit(TQueryTable(FTables[Idx]));
end;

{ An alias from the table's initials, numbered if that is taken. The same table
  dropped twice is the ordinary case - a self-join - so this has to cope with
  it rather than treat it as an error. }
function TQueryModel.UniqueAlias(const ATableName: String): String;
var
  Base: String;
  Idx, N: Integer;
begin
  Base := '';
  for Idx := 1 to Length(ATableName) do
    if (Idx = 1) or (ATableName[Idx - 1] = '_') then
      if ATableName[Idx] <> '_' then
        Base := Base + UpCase(ATableName[Idx]);
  if Base = '' then
    Base := 'T';

  Result := Base;
  N := 1;
  while Assigned(TableByAlias(Result)) do
  begin
    Inc(N);
    Result := Base + IntToStr(N);
  end;
end;

function TQueryModel.AddTable(const ASchema, AName: String): TQueryTable;
begin
  Result := TQueryTable.Create;
  Result.Schema := Trim(ASchema);
  Result.Name := Trim(AName);
  Result.Alias := UniqueAlias(Trim(AName));
  FTables.Add(Result);
end;

function TQueryModel.AddColumn(const ATableAlias, AName: String): TQueryColumn;
begin
  Result := TQueryColumn.Create;
  Result.TableAlias := Trim(ATableAlias);
  Result.Name := Trim(AName);
  Result.Sort := soNone;
  FColumns.Add(Result);
end;

function TQueryModel.AddJoin(Kind: TJoinKind; const ALeftAlias, ALeftColumn,
  ARightAlias, ARightColumn: String): TQueryJoin;
begin
  Result := TQueryJoin.Create;
  Result.Kind := Kind;
  Result.LeftAlias := Trim(ALeftAlias);
  Result.LeftColumn := Trim(ALeftColumn);
  Result.RightAlias := Trim(ARightAlias);
  Result.RightColumn := Trim(ARightColumn);
  FJoins.Add(Result);
end;

procedure TQueryModel.RemoveTable(const AAlias: String);
var
  Idx: Integer;
begin
  { The columns and joins that named it go too. A column of a table that is no
    longer in the query generates SQL naming an alias the FROM clause never
    declares, which the server rejects. }
  for Idx := FColumns.Count - 1 downto 0 do
    if SameText(TQueryColumn(FColumns[Idx]).TableAlias, AAlias) then
    begin
      TQueryColumn(FColumns[Idx]).Free;
      FColumns.Delete(Idx);
    end;
  for Idx := FJoins.Count - 1 downto 0 do
    if SameText(TQueryJoin(FJoins[Idx]).LeftAlias, AAlias) or
       SameText(TQueryJoin(FJoins[Idx]).RightAlias, AAlias) then
    begin
      TQueryJoin(FJoins[Idx]).Free;
      FJoins.Delete(Idx);
    end;
  for Idx := FTables.Count - 1 downto 0 do
    if SameText(TQueryTable(FTables[Idx]).Alias, AAlias) then
    begin
      TQueryTable(FTables[Idx]).Free;
      FTables.Delete(Idx);
    end;
end;

function JoinKeyword(Kind: TJoinKind): String;
begin
  case Kind of
    jkLeft:  Result := 'left join';
    jkRight: Result := 'right join';
    jkFull:  Result := 'full join';
  else
    Result := 'inner join';
  end;
end;

function JoinOrder(Model: TQueryModel): TStringList;
var
  Idx, N, Before: Integer;
  Placed: TStringList;

  { True when a join connects AAlias to something already placed. }
  function ReachesPlaced(const AAlias: String): Boolean;
  var
    J: Integer;
    Join: TQueryJoin;
  begin
    Result := False;
    for J := 0 to Model.JoinCount - 1 do
    begin
      Join := Model.Joins[J];
      if SameText(Join.LeftAlias, AAlias) and
         (Placed.IndexOf(AnsiUpperCase(Join.RightAlias)) >= 0) then
        Exit(True);
      if SameText(Join.RightAlias, AAlias) and
         (Placed.IndexOf(AnsiUpperCase(Join.LeftAlias)) >= 0) then
        Exit(True);
    end;
  end;

begin
  Result := TStringList.Create;
  Placed := TStringList.Create;
  try
    if Model.TableCount = 0 then
      Exit;

    { The first table is simply the first one added - the one the user dropped
      first, which is the one they think of as the subject of the query. }
    Result.Add(Model.Tables[0].Alias);
    Placed.Add(AnsiUpperCase(Model.Tables[0].Alias));

    { Then repeatedly whichever remaining table a join can reach. Repeating
      until nothing moves rather than walking the joins in order, because the
      user makes joins in whatever order they please and the order they were
      made says nothing about the order they can be emitted in. }
    repeat
      Before := Result.Count;
      for Idx := 1 to Model.TableCount - 1 do
      begin
        if Placed.IndexOf(AnsiUpperCase(Model.Tables[Idx].Alias)) >= 0 then
          Continue;
        if ReachesPlaced(Model.Tables[Idx].Alias) then
        begin
          Result.Add(Model.Tables[Idx].Alias);
          Placed.Add(AnsiUpperCase(Model.Tables[Idx].Alias));
        end;
      end;
    until Result.Count = Before;

    { Whatever is left is joined to nothing. It still belongs in the query -
      the user put it there - so it goes on the end as a cross join. }
    for N := 1 to Model.TableCount - 1 do
      if Placed.IndexOf(AnsiUpperCase(Model.Tables[N].Alias)) < 0 then
        Result.Add(Model.Tables[N].Alias);
  finally
    Placed.Free;
  end;
end;

function IsFullyJoined(Model: TQueryModel): Boolean;
var
  Order: TStringList;
  Idx, J: Integer;
  Reached: Boolean;
  Join: TQueryJoin;
begin
  Result := True;
  if Model.TableCount < 2 then
    Exit;
  Order := JoinOrder(Model);
  try
    { Every table after the first must be connected to one before it - which is
      exactly the condition JoinOrder placed them on, so any table it had to
      fall back on appending is one nothing reaches. }
    for Idx := 1 to Order.Count - 1 do
    begin
      Reached := False;
      for J := 0 to Model.JoinCount - 1 do
      begin
        Join := Model.Joins[J];
        if (SameText(Join.LeftAlias, Order[Idx]) and
            (Order.IndexOf(Join.RightAlias) < Idx) and
            (Order.IndexOf(Join.RightAlias) >= 0)) or
           (SameText(Join.RightAlias, Order[Idx]) and
            (Order.IndexOf(Join.LeftAlias) < Idx) and
            (Order.IndexOf(Join.LeftAlias) >= 0)) then
        begin
          Reached := True;
          Break;
        end;
      end;
      if not Reached then
        Exit(False);
    end;
  finally
    Order.Free;
  end;
end;

function BuildSelectSQL(Model: TQueryModel): String;
var
  Idx, J, Pos_: Integer;
  Order: TStringList;
  SelectList, FromClause, WhereClause, OrderClause: String;
  Table: TQueryTable;
  Col: TQueryColumn;
  Join, Used: TQueryJoin;
  Ident, Ref: String;

  function Ident_(const S: String): String;
  begin
    if Model.QuoteIdentifiers then
      Result := MakeQuotedIdent(S, True, 3)
    else
      Result := S;
  end;

begin
  Result := '';
  if not Assigned(Model) or (Model.TableCount = 0) then
    Exit;

  Order := JoinOrder(Model);
  try
    SelectList := '';
    for Idx := 0 to Model.ColumnCount - 1 do
    begin
      Col := Model.Columns[Idx];
      Ref := Ident_(Col.TableAlias) + '.' + Ident_(Col.Name);
      if Trim(Col.OutputName) <> '' then
        Ref := Ref + ' as ' + Ident_(Trim(Col.OutputName));
      if SelectList <> '' then
        SelectList := SelectList + ',' + #13#10 + '       ';
      SelectList := SelectList + Ref;
    end;
    { Tables on the canvas but no boxes ticked plainly means everything. }
    if SelectList = '' then
      SelectList := '*';

    FromClause := '';
    for Idx := 0 to Order.Count - 1 do
    begin
      Table := Model.TableByAlias(Order[Idx]);
      if not Assigned(Table) then
        Continue;
      Ident := QualifiedIdent(Table.Schema, Table.Name, True, 3);
      if not Model.QuoteIdentifiers then
        Ident := DisplaySchemaName(Table.Schema, Table.Name);

      if Idx = 0 then
      begin
        FromClause := Ident + ' ' + Ident_(Table.Alias);
        Continue;
      end;

      { The join that connects this table to one already emitted. There may be
        more than one - a table joined to two others - in which case the first
        is the join and the rest become extra conditions on it. }
      Used := nil;
      for J := 0 to Model.JoinCount - 1 do
      begin
        Join := Model.Joins[J];
        if SameText(Join.LeftAlias, Table.Alias) then
          Pos_ := Order.IndexOf(Join.RightAlias)
        else if SameText(Join.RightAlias, Table.Alias) then
          Pos_ := Order.IndexOf(Join.LeftAlias)
        else
          Continue;
        if (Pos_ >= 0) and (Pos_ < Idx) then
        begin
          Used := Join;
          Break;
        end;
      end;

      if not Assigned(Used) then
      begin
        { Nothing connects it. A comma rather than a silent invented condition:
          the query then says what the picture said, and returns a row count
          that makes the omission obvious. }
        FromClause := FromClause + ',' + #13#10 + '       ' + Ident + ' ' +
          Ident_(Table.Alias);
        Continue;
      end;

      FromClause := FromClause + #13#10 + '  ' + JoinKeyword(Used.Kind) + ' ' +
        Ident + ' ' + Ident_(Table.Alias) + ' on ' +
        Ident_(Used.LeftAlias) + '.' + Ident_(Used.LeftColumn) + ' = ' +
        Ident_(Used.RightAlias) + '.' + Ident_(Used.RightColumn);

      { Any further join between this table and an already-emitted one is an
        additional condition, not a second join clause. }
      for J := 0 to Model.JoinCount - 1 do
      begin
        Join := Model.Joins[J];
        if Join = Used then
          Continue;
        if SameText(Join.LeftAlias, Table.Alias) then
          Pos_ := Order.IndexOf(Join.RightAlias)
        else if SameText(Join.RightAlias, Table.Alias) then
          Pos_ := Order.IndexOf(Join.LeftAlias)
        else
          Continue;
        if (Pos_ >= 0) and (Pos_ < Idx) then
          FromClause := FromClause + #13#10 + '     and ' +
            Ident_(Join.LeftAlias) + '.' + Ident_(Join.LeftColumn) + ' = ' +
            Ident_(Join.RightAlias) + '.' + Ident_(Join.RightColumn);
      end;
    end;

    WhereClause := '';
    OrderClause := '';
    for Idx := 0 to Model.ColumnCount - 1 do
    begin
      Col := Model.Columns[Idx];
      Ref := Ident_(Col.TableAlias) + '.' + Ident_(Col.Name);
      if Trim(Col.Filter) <> '' then
      begin
        if WhereClause <> '' then
          WhereClause := WhereClause + #13#10 + '   and ';
        WhereClause := WhereClause + Ref + ' ' + Trim(Col.Filter);
      end;
      if Col.Sort <> soNone then
      begin
        if OrderClause <> '' then
          OrderClause := OrderClause + ', ';
        OrderClause := OrderClause + Ref;
        if Col.Sort = soDescending then
          OrderClause := OrderClause + ' desc';
      end;
    end;

    Result := 'select ';
    if Model.Distinct then
      Result := Result + 'distinct ';
    Result := Result + SelectList + #13#10 + '  from ' + FromClause;
    if WhereClause <> '' then
      Result := Result + #13#10 + ' where ' + WhereClause;
    if OrderClause <> '' then
      Result := Result + #13#10 + ' order by ' + OrderClause;
    Result := Result + ';';
  finally
    Order.Free;
  end;
end;

end.
