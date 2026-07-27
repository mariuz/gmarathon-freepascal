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

unit SchemaDiagram;

{$MODE Delphi}

{ A diagram of the tables and the foreign keys between them.

  The VS Code MSSQL extension calls this its Schema Designer, and it is the one
  substantial thing on its list that Marathon had nothing like. Everything it
  needs is already in Firebird's catalogue - RDB$RELATION_CONSTRAINTS for the
  keys, RDB$REF_CONSTRAINTS to pair a foreign key with what it references, and
  RDB$INDEX_SEGMENTS for the columns on each side.

  What is here is the model and the layout. Neither needs a canvas, so where
  every box ends up is decided in something that can be checked without one -
  and layout is the part with judgement in it. A database of sixty tables
  dropped into a grid is unreadable; what makes a diagram legible is putting a
  table near the ones it references.

  The layout is breadth-first from the most-referenced table. That is a rough
  rule and deliberately so: it beats alphabetical order by a long way, it is
  predictable, and it terminates on any graph including the cyclic ones real
  schemas have. Anything cleverer is a force-directed simulation, which moves
  every time it runs and cannot be tested. }

interface

uses SysUtils, Classes;

type
  TDiagramTable = class
  public
    Name: String;
    Schema: String;
    Columns: TStringList;
    { Where the box sits, filled in by LayoutDiagram and moved by dragging. }
    Left, Top, Width, Height: Integer;
    constructor Create;
    destructor Destroy; override;
  end;

  TDiagramLink = class
  public
    { The table holding the foreign key, and the one it points at. }
    FromTable: String;
    ToTable: String;
    FromColumn: String;
    ToColumn: String;
    ConstraintName: String;
  end;

  TSchemaDiagram = class
  private
    FTables: TList;
    FLinks: TList;
    function GetTable(Index: Integer): TDiagramTable;
    function GetLink(Index: Integer): TDiagramLink;
  public
    constructor Create;
    destructor Destroy; override;
    function AddTable(const AName: String; const ASchema: String = ''): TDiagramTable;
    function AddLink(const AFrom, AFromCol, ATo, AToCol,
      AConstraint: String): TDiagramLink;
    function TableCount: Integer;
    function LinkCount: Integer;
    function IndexOfTable(const AName: String): Integer;
    function FindTable(const AName: String): TDiagramTable;
    { How many links touch a table, in either direction. What the layout starts
      from, and what a caller can show as "most connected". }
    function DegreeOf(const AName: String): Integer;
    { Tables nothing links to or from. They have no place in the graph, so the
      layout puts them together rather than scattering them through it. }
    function IsolatedCount: Integer;
    property Tables[Index: Integer]: TDiagramTable read GetTable;
    property Links[Index: Integer]: TDiagramLink read GetLink;
  end;

{ Places every table. Boxes are ABoxWidth wide and as tall as their column
  count needs; AWidth is how much room there is across before wrapping.

  Breadth-first from the most-connected table, so a table sits near what it
  references. Tables in no relationship at all go last, in their own rows -
  mixed into the graph they would push related tables apart for no reason. }
procedure LayoutDiagram(ADiagram: TSchemaDiagram; AWidth, ABoxWidth,
  ARowHeight, AHeaderHeight: Integer);

{ The table whose box contains that point, or nil. Topmost first, so a box
  dragged over another is the one that gets picked up. }
function TableAt(ADiagram: TSchemaDiagram; X, Y: Integer): TDiagramTable;

{ How far right and down the diagram extends, so a caller can size a scroll
  area to it. }
procedure DiagramExtent(ADiagram: TSchemaDiagram; out AWidth, AHeight: Integer);

implementation

constructor TDiagramTable.Create;
begin
  inherited Create;
  Columns := TStringList.Create;
end;

destructor TDiagramTable.Destroy;
begin
  Columns.Free;
  inherited Destroy;
end;

constructor TSchemaDiagram.Create;
begin
  inherited Create;
  FTables := TList.Create;
  FLinks := TList.Create;
end;

destructor TSchemaDiagram.Destroy;
var
  Idx: Integer;
begin
  for Idx := 0 to FTables.Count - 1 do
    TDiagramTable(FTables[Idx]).Free;
  for Idx := 0 to FLinks.Count - 1 do
    TDiagramLink(FLinks[Idx]).Free;
  FTables.Free;
  FLinks.Free;
  inherited Destroy;
end;

function TSchemaDiagram.GetTable(Index: Integer): TDiagramTable;
begin
  Result := TDiagramTable(FTables[Index]);
end;

function TSchemaDiagram.GetLink(Index: Integer): TDiagramLink;
begin
  Result := TDiagramLink(FLinks[Index]);
end;

function TSchemaDiagram.TableCount: Integer;
begin
  Result := FTables.Count;
end;

function TSchemaDiagram.LinkCount: Integer;
begin
  Result := FLinks.Count;
end;

function TSchemaDiagram.AddTable(const AName, ASchema: String): TDiagramTable;
begin
  Result := FindTable(AName);
  { The same table twice is a caller reading it twice, not two tables. }
  if Assigned(Result) then
    Exit;
  Result := TDiagramTable.Create;
  Result.Name := Trim(AName);
  Result.Schema := Trim(ASchema);
  FTables.Add(Result);
end;

function TSchemaDiagram.AddLink(const AFrom, AFromCol, ATo, AToCol,
  AConstraint: String): TDiagramLink;
begin
  Result := TDiagramLink.Create;
  Result.FromTable := Trim(AFrom);
  Result.FromColumn := Trim(AFromCol);
  Result.ToTable := Trim(ATo);
  Result.ToColumn := Trim(AToCol);
  Result.ConstraintName := Trim(AConstraint);
  FLinks.Add(Result);
end;

function TSchemaDiagram.IndexOfTable(const AName: String): Integer;
var
  Idx: Integer;
begin
  Result := -1;
  for Idx := 0 to FTables.Count - 1 do
    if SameText(TDiagramTable(FTables[Idx]).Name, Trim(AName)) then
      Exit(Idx);
end;

function TSchemaDiagram.FindTable(const AName: String): TDiagramTable;
var
  At: Integer;
begin
  Result := nil;
  At := IndexOfTable(AName);
  if At >= 0 then
    Result := GetTable(At);
end;

function TSchemaDiagram.DegreeOf(const AName: String): Integer;
var
  Idx: Integer;
  L: TDiagramLink;
begin
  Result := 0;
  for Idx := 0 to FLinks.Count - 1 do
  begin
    L := GetLink(Idx);
    if SameText(L.FromTable, Trim(AName)) then
      Inc(Result);
    { A self-reference counts twice, which is right: it is two ends on the
      same table and makes it no less connected. }
    if SameText(L.ToTable, Trim(AName)) then
      Inc(Result);
  end;
end;

function TSchemaDiagram.IsolatedCount: Integer;
var
  Idx: Integer;
begin
  Result := 0;
  for Idx := 0 to FTables.Count - 1 do
    if DegreeOf(GetTable(Idx).Name) = 0 then
      Inc(Result);
end;

procedure LayoutDiagram(ADiagram: TSchemaDiagram; AWidth, ABoxWidth,
  ARowHeight, AHeaderHeight: Integer);
const
  GapX = 28;
  GapY = 28;
  MarginX = 16;
  MarginY = 16;
var
  Order: TList;
  Queued: TStringList;
  Idx, N, Best, BestDegree, X, Y, RowTop, Columns_: Integer;
  T, Other: TDiagramTable;
  L: TDiagramLink;

  procedure Enqueue(ATable: TDiagramTable);
  begin
    if not Assigned(ATable) then
      Exit;
    if Queued.IndexOf(AnsiUpperCase(ATable.Name)) >= 0 then
      Exit;
    Queued.Add(AnsiUpperCase(ATable.Name));
    Order.Add(ATable);
  end;

begin
  if not Assigned(ADiagram) or (ADiagram.TableCount = 0) then
    Exit;
  if ABoxWidth < 40 then
    ABoxWidth := 40;
  if AWidth < ABoxWidth + MarginX * 2 then
    AWidth := ABoxWidth + MarginX * 2;

  { Every box first, so its height is known before anything is placed. }
  for Idx := 0 to ADiagram.TableCount - 1 do
  begin
    T := ADiagram.Tables[Idx];
    T.Width := ABoxWidth;
    T.Height := AHeaderHeight + T.Columns.Count * ARowHeight + 4;
  end;

  Order := TList.Create;
  Queued := TStringList.Create;
  try
    Queued.Sorted := False;

    { Breadth-first from whichever table the most keys touch: it is the one a
      reader looks for first, and starting there keeps its neighbours around
      it. Repeated because a schema is rarely one connected piece. }
    repeat
      Best := -1;
      BestDegree := -1;
      for Idx := 0 to ADiagram.TableCount - 1 do
      begin
        T := ADiagram.Tables[Idx];
        if Queued.IndexOf(AnsiUpperCase(T.Name)) >= 0 then
          Continue;
        if ADiagram.DegreeOf(T.Name) = 0 then
          { Isolated tables are placed last, together. }
          Continue;
        if ADiagram.DegreeOf(T.Name) > BestDegree then
        begin
          BestDegree := ADiagram.DegreeOf(T.Name);
          Best := Idx;
        end;
      end;
      if Best < 0 then
        Break;

      Enqueue(ADiagram.Tables[Best]);
      { Walk what is queued, adding each one's neighbours behind it. The list
        grows as it is walked, which is what makes this breadth-first. }
      N := Order.Count - 1;
      while N < Order.Count do
      begin
        T := TDiagramTable(Order[N]);
        for Idx := 0 to ADiagram.LinkCount - 1 do
        begin
          L := ADiagram.Links[Idx];
          if SameText(L.FromTable, T.Name) then
          begin
            Other := ADiagram.FindTable(L.ToTable);
            Enqueue(Other);
          end
          else if SameText(L.ToTable, T.Name) then
          begin
            Other := ADiagram.FindTable(L.FromTable);
            Enqueue(Other);
          end;
        end;
        Inc(N);
      end;
    until False;

    { Then anything nothing references. }
    for Idx := 0 to ADiagram.TableCount - 1 do
      if ADiagram.DegreeOf(ADiagram.Tables[Idx].Name) = 0 then
        Enqueue(ADiagram.Tables[Idx]);

    { Placed in that order, wrapping when the row is full. Each row is as tall
      as its tallest box, so a wide table does not overlap the row beneath. }
    Columns_ := (AWidth - MarginX) div (ABoxWidth + GapX);
    if Columns_ < 1 then
      Columns_ := 1;
    X := MarginX;
    Y := MarginY;
    RowTop := 0;
    for N := 0 to Order.Count - 1 do
    begin
      T := TDiagramTable(Order[N]);
      if (N > 0) and (N mod Columns_ = 0) then
      begin
        X := MarginX;
        Inc(Y, RowTop + GapY);
        RowTop := 0;
      end;
      T.Left := X;
      T.Top := Y;
      if T.Height > RowTop then
        RowTop := T.Height;
      Inc(X, ABoxWidth + GapX);
    end;
  finally
    Order.Free;
    Queued.Free;
  end;
end;

function TableAt(ADiagram: TSchemaDiagram; X, Y: Integer): TDiagramTable;
var
  Idx: Integer;
  T: TDiagramTable;
begin
  Result := nil;
  if not Assigned(ADiagram) then
    Exit;
  { Backwards: the last drawn is the one on top. }
  for Idx := ADiagram.TableCount - 1 downto 0 do
  begin
    T := ADiagram.Tables[Idx];
    if (X >= T.Left) and (X < T.Left + T.Width) and
       (Y >= T.Top) and (Y < T.Top + T.Height) then
      Exit(T);
  end;
end;

procedure DiagramExtent(ADiagram: TSchemaDiagram; out AWidth, AHeight: Integer);
var
  Idx: Integer;
  T: TDiagramTable;
begin
  AWidth := 0;
  AHeight := 0;
  if not Assigned(ADiagram) then
    Exit;
  for Idx := 0 to ADiagram.TableCount - 1 do
  begin
    T := ADiagram.Tables[Idx];
    if T.Left + T.Width > AWidth then
      AWidth := T.Left + T.Width;
    if T.Top + T.Height > AHeight then
      AHeight := T.Top + T.Height;
  end;
end;

end.
