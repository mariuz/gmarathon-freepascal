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

unit TableDesignerForm;

{$MODE Delphi}

{ The table designer: the whole table in one grid, the script it would run
  underneath it, and one Apply.

  This is the other half of what Marathon's table editor does. That editor
  applies as you go - each column dialog runs its own ALTER TABLE when you
  press OK - so there is never anything pending to show and no way to change
  your mind about the third column once you have started the fourth. Both are
  kept: the editor is what you want to alter one column, and this is what you
  want to lay out a table.

  Almost nothing is decided here. What an edit generates is TableDesign's
  business and is tested without a database; reading and running are
  TableDesignIO's. This form holds two designs - what the table is, and what it
  is being made into - and shows the difference. }

interface

uses
  SysUtils, Classes, Graphics, Controls, Forms, Dialogs, StdCtrls, ExtCtrls,
  Grids, ComCtrls, Buttons, Menus, IBDatabase, BaseDocumentForm, TableDesign,
  MarathonProjectCacheTypes;

type

  { TfrmTableDesigner }

  TfrmTableDesigner = class(TfrmBaseDocumentForm)
    pnlTop: TPanel;
    lblTable: TLabel;
    edTableName: TEdit;
    tbActions: TToolBar;
    btnAddColumn: TToolButton;
    btnDeleteColumn: TToolButton;
    btnMoveUp: TToolButton;
    btnMoveDown: TToolButton;
    sep1: TToolButton;
    btnApply: TToolButton;
    btnRevert: TToolButton;
    grdColumns: TStringGrid;
    splScript: TSplitter;
    pnlScript: TPanel;
    lblScript: TLabel;
    memScript: TMemo;
    stbStatus: TStatusBar;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure grdColumnsEditingDone(Sender: TObject);
    procedure grdColumnsCheckboxToggled(Sender: TObject; aCol, aRow: Integer;
      aState: TCheckboxState);
    procedure btnAddColumnClick(Sender: TObject);
    procedure btnDeleteColumnClick(Sender: TObject);
    procedure btnMoveUpClick(Sender: TObject);
    procedure btnMoveDownClick(Sender: TObject);
    procedure btnApplyClick(Sender: TObject);
    procedure btnRevertClick(Sender: TObject);
  private
    FDatabase: TIBDatabase;
    FConnectionName: String;
    FTableName: String;
    { The schema the table lives in, so the designer reads and alters the table
      the tree listed rather than whatever the search path reaches. }
    FSchema: String;
    { What the table is in the database. Never edited: it is the thing the grid
      is compared against, and it is only replaced by re-reading after an
      apply. Nil for a table that does not exist yet, which is what makes this
      a CREATE rather than a set of ALTERs. }
    FOriginal: TTableDesign;
    FTransaction: TIBTransaction;
    { What the grid says. Rebuilt from the grid rather than kept in step with
      it, because a design read out of the grid is always what is on screen and
      one maintained alongside it is only usually. }
    FIsNew: Boolean;
    FLoading: Boolean;
    { True when this server has schemas at all - which is not the same question
      as whether a schema was named. A table opened without one still lives in
      a schema on Firebird 6, and its domain lookup still has to say which. }
    function ServerHasSchemas: Boolean;
    function DesignFromGrid: TTableDesign;
    procedure LoadGridFrom(ADesign: TTableDesign);
    procedure AddGridRow(const AColumn: TColumnDesign);
    procedure RefreshScript;
    function CurrentTransaction: TIBTransaction;
  public
    { Opens the designer on an existing table. }
    procedure LoadTable(ADatabase: TIBDatabase; const AConnectionName,
      ATableName: String; const ASchema: String = '');
    { Opens it on a table that does not exist yet, so Apply creates it. }
    procedure NewTable(ADatabase: TIBDatabase; const AConnectionName: String);
    function GetObjectName: String; override;
    function GetActiveConnectionName: String; override;
    function GetActiveObjectType: TGSSCacheType; override;
    function InternalCloseQuery: Boolean; override;
  end;

{ Opens a designer on a table, or brings up the one already open on it. }
function ShowTableDesigner(ADatabase: TIBDatabase; const AConnectionName,
  ATableName: String; const ASchema: String = ''): TfrmTableDesigner;

implementation

{$R *.lfm}

uses TableDesignIO, IB, MarathonIDE, MarathonProjectCache;

const
  { The grid's columns. Named rather than numbered because the order is a
    layout decision and every use of them would otherwise have to be found
    again when it changes. }
  colName     = 0;
  colType     = 1;
  colNotNull  = 2;
  colDefault  = 3;
  colComputed = 4;
  colKey      = 5;
  { Not shown. Carries what the column is called in the database, which is what
    tells a rename from an add, and which the user must not be able to edit
    because it is not a fact about the design - it is a fact about the table. }
  colOriginal = 6;

function ShowTableDesigner(ADatabase: TIBDatabase; const AConnectionName,
  ATableName: String; const ASchema: String = ''): TfrmTableDesigner;
var
  Idx: Integer;
  Existing: TfrmTableDesigner;
begin
  { One designer per table: a second one would hold a design read before the
    first one applied, and applying it would generate changes against a table
    that had already moved. }
  for Idx := 0 to Screen.FormCount - 1 do
    if Screen.Forms[Idx] is TfrmTableDesigner then
    begin
      Existing := TfrmTableDesigner(Screen.Forms[Idx]);
      if SameText(Existing.FTableName, ATableName) and
         SameText(Existing.FConnectionName, AConnectionName) then
      begin
        Existing.ShowDocument;
        Exit(Existing);
      end;
    end;

  Result := TfrmTableDesigner.Create(nil);
  Result.LoadTable(ADatabase, AConnectionName, ATableName, ASchema);
  Result.ShowDocument;
end;

procedure TfrmTableDesigner.FormCreate(Sender: TObject);
begin
  grdColumns.RowCount := 1;
  grdColumns.Cells[colName, 0] := 'Column';
  grdColumns.Cells[colType, 0] := 'Type';
  grdColumns.Cells[colNotNull, 0] := 'Not null';
  grdColumns.Cells[colDefault, 0] := 'Default';
  grdColumns.Cells[colComputed, 0] := 'Computed by';
  grdColumns.Cells[colKey, 0] := 'Key';
end;

procedure TfrmTableDesigner.FormDestroy(Sender: TObject);
begin
  FOriginal.Free;
  { Anything still open is abandoned rather than committed: nothing the form
    holds is applied until Apply says so. }
  if Assigned(FTransaction) and FTransaction.InTransaction then
    FTransaction.Rollback;
end;

function TfrmTableDesigner.ServerHasSchemas: Boolean;
var
  Conn: TMarathonCacheConnection;
begin
  Result := False;
  if not Assigned(MarathonIDEInstance) or
     not Assigned(MarathonIDEInstance.CurrentProject) then
    Exit;
  Conn := MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[FConnectionName];
  Result := Assigned(Conn) and Conn.Connected and
    Conn.IsODSAtLeast(ODS_FB6_MAJOR, 0);
end;

function TfrmTableDesigner.CurrentTransaction: TIBTransaction;
begin
  Result := nil;
  if not Assigned(FDatabase) then
    Exit;

  { The designer's own transaction, not whichever one the connection happens to
    hold. Taking TIBDatabase.Transactions[0] looks equivalent and is not: a
    connection accumulates a transaction per editor that has been opened on it,
    so the first in the list belongs to some other form and using it fails with
    "Transaction is not active" no matter what state this form put it in.

    Its own is also the right unit of work for a form built around applying a
    batch and rolling the whole batch back if any of it fails. }
  if not Assigned(FTransaction) then
  begin
    FTransaction := TIBTransaction.Create(Self);
    FTransaction.DefaultDatabase := FDatabase;
  end;
  if not FTransaction.InTransaction then
    FTransaction.StartTransaction;
  Result := FTransaction;
end;

procedure TfrmTableDesigner.LoadTable(ADatabase: TIBDatabase;
  const AConnectionName, ATableName: String; const ASchema: String);
begin
  FDatabase := ADatabase;
  FConnectionName := AConnectionName;
  FTableName := ATableName;
  FSchema := ASchema;
  FIsNew := False;
  Caption := 'Design: ' + ATableName;
  edTableName.Text := ATableName;
  { The name of a table that exists is changed by renaming it, which is not
    what this form does. }
  edTableName.ReadOnly := True;

  FreeAndNil(FOriginal);
  FOriginal := ReadTableDesign(FDatabase, CurrentTransaction, ATableName, FSchema,
    ServerHasSchemas);
  if not Assigned(FOriginal) then
  begin
    { Not a failure worth refusing to open over - the designer is still usable,
      and saying so is better than an empty grid with no explanation. }
    stbStatus.SimpleText := 'Could not read ' + ATableName + ' from the database.';
    Exit;
  end;
  LoadGridFrom(FOriginal);
  RefreshScript;
end;

procedure TfrmTableDesigner.NewTable(ADatabase: TIBDatabase;
  const AConnectionName: String);
begin
  FDatabase := ADatabase;
  FConnectionName := AConnectionName;
  FTableName := '';
  FIsNew := True;
  Caption := 'Design: new table';
  edTableName.ReadOnly := False;
  edTableName.Text := '';
  FreeAndNil(FOriginal);
  { An empty design rather than nil, so everything below has one thing to
    compare against instead of two cases. }
  FOriginal := TTableDesign.Create('');
  LoadGridFrom(FOriginal);
  { A table with no columns cannot be created, so it starts with one. }
  btnAddColumnClick(nil);
end;

procedure TfrmTableDesigner.AddGridRow(const AColumn: TColumnDesign);
var
  Row: Integer;
begin
  Row := grdColumns.RowCount;
  grdColumns.RowCount := Row + 1;
  grdColumns.Cells[colName, Row] := AColumn.Name;
  grdColumns.Cells[colType, Row] := AColumn.DataType;
  if AColumn.NotNull then
    grdColumns.Cells[colNotNull, Row] := '1'
  else
    grdColumns.Cells[colNotNull, Row] := '0';
  grdColumns.Cells[colDefault, Row] := AColumn.DefaultValue;
  grdColumns.Cells[colComputed, Row] := AColumn.ComputedAs;
  grdColumns.Cells[colOriginal, Row] := AColumn.OriginalName;
end;

procedure TfrmTableDesigner.LoadGridFrom(ADesign: TTableDesign);
var
  Idx, Row: Integer;
begin
  FLoading := True;
  try
    grdColumns.RowCount := 1;
    for Idx := 0 to ADesign.ColumnCount - 1 do
      AddGridRow(ADesign.Column(Idx));
    { The key is shown as its position in the key, not as a tick, because a
      compound key is ordered and a tick cannot say which column comes first. }
    for Row := 1 to grdColumns.RowCount - 1 do
      grdColumns.Cells[colKey, Row] := '';
    for Idx := 0 to ADesign.PrimaryKey.Count - 1 do
      for Row := 1 to grdColumns.RowCount - 1 do
        if SameText(Trim(grdColumns.Cells[colName, Row]),
                    Trim(ADesign.PrimaryKey[Idx])) then
          grdColumns.Cells[colKey, Row] := IntToStr(Idx + 1);
    edTableName.Text := ADesign.TableName;
  finally
    FLoading := False;
  end;
end;

function TfrmTableDesigner.DesignFromGrid: TTableDesign;
var
  Row, Position, Slot: Integer;
  C: TColumnDesign;
begin
  Result := TTableDesign.Create(Trim(edTableName.Text));
  for Row := 1 to grdColumns.RowCount - 1 do
  begin
    C.Name := Trim(grdColumns.Cells[colName, Row]);
    { A blank row is one the user has started and not filled in, not a column
      called nothing. }
    if C.Name = '' then
      Continue;
    C.OriginalName := Trim(grdColumns.Cells[colOriginal, Row]);
    C.DataType := Trim(grdColumns.Cells[colType, Row]);
    C.NotNull := grdColumns.Cells[colNotNull, Row] = '1';
    C.DefaultValue := Trim(grdColumns.Cells[colDefault, Row]);
    C.ComputedAs := Trim(grdColumns.Cells[colComputed, Row]);
    C.Collation := '';
    Result.AddColumn(C);
  end;

  { Key columns in the order their numbers give, so 2 and 1 mean the key is
    (second, first) - which is a different key from (first, second). }
  for Position := 1 to grdColumns.RowCount - 1 do
    for Row := 1 to grdColumns.RowCount - 1 do
      if TryStrToInt(Trim(grdColumns.Cells[colKey, Row]), Slot) and
         (Slot = Position) and (Trim(grdColumns.Cells[colName, Row]) <> '') then
        Result.PrimaryKey.Add(Trim(grdColumns.Cells[colName, Row]));
end;

procedure TfrmTableDesigner.RefreshScript;
var
  Target: TTableDesign;
  Changes: TTableDesignChangeArray;
  Idx, Destructive: Integer;
  Lines: TStringList;
begin
  if FLoading or not Assigned(FOriginal) then
    Exit;

  Target := DesignFromGrid;
  Lines := TStringList.Create;
  try
    if FIsNew then
    begin
      if (Trim(Target.TableName) = '') or (Target.ColumnCount = 0) then
        stbStatus.SimpleText := 'Give the table a name and at least one column.'
      else
      begin
        Lines.Text := CreateTableScript(Target);
        stbStatus.SimpleText := 'New table: ' + IntToStr(Target.ColumnCount) +
          ' column(s). Apply creates it.';
      end;
      btnApply.Enabled := Lines.Count > 0;
      memScript.Lines.Assign(Lines);
      Exit;
    end;

    Changes := TableDesignChanges(FOriginal, Target);
    Destructive := 0;
    for Idx := 0 to High(Changes) do
    begin
      if Changes[Idx].Destructive then
      begin
        Inc(Destructive);
        Lines.Add('/* this one can lose data */');
      end;
      Lines.Add(Changes[Idx].Statement);
    end;
    memScript.Lines.Assign(Lines);

    if Length(Changes) = 0 then
      stbStatus.SimpleText := 'No changes.'
    else if Destructive > 0 then
      stbStatus.SimpleText := IntToStr(Length(Changes)) + ' change(s), ' +
        IntToStr(Destructive) + ' of which can lose data.'
    else
      stbStatus.SimpleText := IntToStr(Length(Changes)) + ' change(s).';
    btnApply.Enabled := Length(Changes) > 0;
    btnRevert.Enabled := Length(Changes) > 0;
  finally
    Target.Free;
    Lines.Free;
  end;
end;

procedure TfrmTableDesigner.grdColumnsEditingDone(Sender: TObject);
begin
  RefreshScript;
end;

procedure TfrmTableDesigner.grdColumnsCheckboxToggled(Sender: TObject;
  aCol, aRow: Integer; aState: TCheckboxState);
begin
  RefreshScript;
end;

procedure TfrmTableDesigner.btnAddColumnClick(Sender: TObject);
var
  C: TColumnDesign;
begin
  C.OriginalName := '';   { no original name is what makes it an addition }
  C.Name := '';
  C.DataType := 'integer';
  C.NotNull := False;
  C.DefaultValue := '';
  C.ComputedAs := '';
  C.Collation := '';
  AddGridRow(C);
  grdColumns.Row := grdColumns.RowCount - 1;
  grdColumns.Col := colName;
  { Only when the form is actually on screen. Focusing a control on a form that
    is not showing means nothing, and under a bare X server it is worse than
    nothing - it takes the connection down. }
  if Showing and grdColumns.CanFocus then
    grdColumns.SetFocus;
  RefreshScript;
end;

procedure TfrmTableDesigner.btnDeleteColumnClick(Sender: TObject);
begin
  if (grdColumns.Row < 1) or (grdColumns.RowCount <= 1) then
    Exit;
  { Removed from the grid only. Nothing happens to the table until Apply, which
    is the point of the form - so no confirmation here; the script says what
    will happen and the destructive count says it again. }
  grdColumns.DeleteRow(grdColumns.Row);
  RefreshScript;
end;

procedure TfrmTableDesigner.btnMoveUpClick(Sender: TObject);
begin
  if grdColumns.Row > 1 then
  begin
    grdColumns.ExchangeColRow(False, grdColumns.Row, grdColumns.Row - 1);
    grdColumns.Row := grdColumns.Row - 1;
    RefreshScript;
  end;
end;

procedure TfrmTableDesigner.btnMoveDownClick(Sender: TObject);
begin
  if (grdColumns.Row >= 1) and (grdColumns.Row < grdColumns.RowCount - 1) then
  begin
    grdColumns.ExchangeColRow(False, grdColumns.Row, grdColumns.Row + 1);
    grdColumns.Row := grdColumns.Row + 1;
    RefreshScript;
  end;
end;

procedure TfrmTableDesigner.btnApplyClick(Sender: TObject);
var
  Target: TTableDesign;
  Statements: TStringList;
  Tr: TIBTransaction;
  Prompt: String;
begin
  if memScript.Lines.Count = 0 then
    Exit;

  Prompt := 'Run these ' + IntToStr(memScript.Lines.Count) +
    ' line(s) against the database?';
  if Pos('can lose data', memScript.Lines.Text) > 0 then
    Prompt := Prompt + #13#10#13#10 +
      'Some of them drop a column or change its type, which can lose data.';
  if MessageDlg('Apply changes', Prompt, mtConfirmation, [mbYes, mbNo], 0) <> mrYes then
    Exit;

  Target := DesignFromGrid;
  Statements := nil;
  try
    if FIsNew then
    begin
      Statements := TStringList.Create;
      Statements.Add(CreateTableScript(Target));
    end
    else
      Statements := TableDesignStatements(FOriginal, Target);

    Tr := CurrentTransaction;
    try
      ApplyTableDesign(FDatabase, Tr, Statements.ToStringArray);
      Tr.Commit;
    except
      on E: EIBError do
      begin
        { Rolled back whole: half a design is worse than none, and the grid
          still holds what was intended so it can be corrected and applied
          again. }
        if Tr.InTransaction then
          Tr.Rollback;
        MessageDlg('The database refused the change',
          E.Message + #13#10#13#10 + 'Nothing was applied.', mtError, [mbOK], 0);
        Exit;
      end;
    end;

    if FIsNew then
    begin
      FTableName := Trim(edTableName.Text);
      FIsNew := False;
      edTableName.ReadOnly := True;
      Caption := 'Design: ' + FTableName;
    end;

    { Re-read rather than assume the design is now what the table is: Firebird
      may have stored something other than what was asked for, and the next
      comparison has to be against what is actually there. }
    FreeAndNil(FOriginal);
    FOriginal := ReadTableDesign(FDatabase, CurrentTransaction, FTableName, FSchema,
      ServerHasSchemas);
    if Assigned(FOriginal) then
      LoadGridFrom(FOriginal);
    RefreshScript;
  finally
    Target.Free;
    Statements.Free;
  end;
end;

procedure TfrmTableDesigner.btnRevertClick(Sender: TObject);
begin
  if Assigned(FOriginal) and not FIsNew then
  begin
    LoadGridFrom(FOriginal);
    RefreshScript;
  end;
end;

function TfrmTableDesigner.InternalCloseQuery: Boolean;
begin
  Result := True;
  { Everything is pending until Apply, so closing throws it away - which is
    exactly what should be asked about, and what the immediate-apply editor
    never could ask. }
  if memScript.Lines.Count > 0 then
    Result := MessageDlg('Discard changes?',
      'The design has changes that have not been applied.'#13#10 +
      'Close the designer and lose them?',
      mtConfirmation, [mbYes, mbNo], 0) = mrYes;
end;

function TfrmTableDesigner.GetObjectName: String;
begin
  Result := FTableName;
end;

function TfrmTableDesigner.GetActiveConnectionName: String;
begin
  Result := FConnectionName;
end;

function TfrmTableDesigner.GetActiveObjectType: TGSSCacheType;
begin
  Result := ctTable;
end;

end.
