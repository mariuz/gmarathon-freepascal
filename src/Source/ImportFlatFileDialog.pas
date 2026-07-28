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

unit ImportFlatFileDialog;

{$MODE Delphi}

{ Tools > Import Flat File.

  The dialog decides nothing: CsvImport reads the file, works out what each
  column holds and writes the CREATE TABLE and the INSERTs, and all of that is
  checked without a window. What is here is the file name, the separator, the
  preview and the button - and the one judgement a window is the right place
  for, which is showing someone what is about to happen before it happens.

  The preview is the point. An importer that runs and then reports what it did
  is a poor trade when the alternative is showing the columns, the types it
  guessed and the first rows, and letting someone say no. }

interface

uses {$IFDEF FPC} LCLIntf, LCLType, LMessages, {$ELSE} Windows, Messages, {$ENDIF}
  SysUtils, Classes, Graphics, Controls, Forms, Dialogs, StdCtrls, ExtCtrls,
  ComCtrls, Grids, IBDatabase, IBSQL, CsvImport;

type
  TfrmImportFlatFile = class(TForm)
    pnlTop: TPanel;
    lblFile: TLabel;
    edFile: TEdit;
    btnBrowse: TButton;
    lblDelimiter: TLabel;
    cmbDelimiter: TComboBox;
    chkFirstRowNames: TCheckBox;
    lblTable: TLabel;
    edTable: TEdit;
    chkCreateTable: TCheckBox;
    btnPreview: TButton;
    grdPreview: TStringGrid;
    pnlBottom: TPanel;
    btnImport: TButton;
    btnClose: TButton;
    stsImport: TStatusBar;
    dlgOpen: TOpenDialog;
    procedure btnBrowseClick(Sender: TObject);
    procedure btnPreviewClick(Sender: TObject);
    procedure btnImportClick(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    FConnectionName: String;
    FDatabase: TIBDatabase;
    FPlan: TCsvImportPlan;
    procedure SetConnectionName(const Value: String);
    function CurrentOptions: TCsvOptions;
    procedure ShowPlan;
  public
    destructor Destroy; override;
    { Reads the named file and fills the preview. Public so the harness can do
      what the Preview button does without pressing it. }
    function BuildPlan(const AFileName: String): Boolean;
    { Runs what the preview is showing. Returns the number of rows inserted, or
      -1 when it could not start; AError says why. }
    function RunImport(out AError: String): Integer;
    property ConnectionName: String read FConnectionName write SetConnectionName;
    property Plan: TCsvImportPlan read FPlan;
  end;

implementation

{$R *.lfm}

uses MarathonIDE, MarathonProjectCache;

destructor TfrmImportFlatFile.Destroy;
begin
  FPlan.Free;
  inherited Destroy;
end;

procedure TfrmImportFlatFile.SetConnectionName(const Value: String);
var
  Conn: TMarathonCacheConnection;
begin
  FConnectionName := Value;
  Caption := 'Import Flat File - ' + Value;
  Conn := CacheConnectionNamed(Value);
  if Assigned(Conn) then
    FDatabase := Conn.Connection
  else
  begin
    FDatabase := nil;
    stsImport.SimpleText := 'No connection';
  end;
end;

function TfrmImportFlatFile.CurrentOptions: TCsvOptions;
begin
  Result := DefaultCsvOptions;
  Result.FirstRowIsNames := chkFirstRowNames.Checked;
  { The four separators a file in the wild actually uses. Tab is named rather
    than typed, since a tab in an edit box is invisible and unreachable. }
  case cmbDelimiter.ItemIndex of
    1: Result.Delimiter := ';';
    2: Result.Delimiter := #9;
    3: Result.Delimiter := '|';
  else
    Result.Delimiter := ',';
  end;
end;

function TfrmImportFlatFile.BuildPlan(const AFileName: String): Boolean;
var
  Lines: TStringList;
begin
  Result := False;
  FreeAndNil(FPlan);
  if not FileExists(AFileName) then
  begin
    stsImport.SimpleText := 'No such file: ' + AFileName;
    Exit;
  end;
  Lines := TStringList.Create;
  try
    try
      Lines.LoadFromFile(AFileName);
    except
      on E: Exception do
      begin
        stsImport.SimpleText := 'Could not read the file: ' + E.Message;
        Exit;
      end;
    end;
    FPlan := PlanCsvImport(Lines, CurrentOptions);
  finally
    Lines.Free;
  end;
  Result := Assigned(FPlan) and (FPlan.ColumnCount > 0);
  if not Result then
    stsImport.SimpleText := 'There are no columns in that file.'
  else
    ShowPlan;
end;

procedure TfrmImportFlatFile.ShowPlan;
const
  { Enough to see what the file looks like; the import reads all of it. }
  PreviewRows = 50;
var
  Col, Row, Shown: Integer;
begin
  grdPreview.BeginUpdate;
  try
    Shown := FPlan.RowCount;
    if Shown > PreviewRows then
      Shown := PreviewRows;
    grdPreview.ColCount := FPlan.ColumnCount;
    { A row for the name, a row for the type, then the data. }
    grdPreview.RowCount := Shown + 2;
    grdPreview.FixedRows := 2;
    for Col := 0 to FPlan.ColumnCount - 1 do
    begin
      grdPreview.Cells[Col, 0] := FPlan.Columns[Col].Name;
      grdPreview.Cells[Col, 1] := ColumnTypeSQL(FPlan.Columns[Col]);
      for Row := 0 to Shown - 1 do
        if Col < FPlan.Rows[Row].Count then
          grdPreview.Cells[Col, Row + 2] := FPlan.Rows[Row][Col]
        else
          grdPreview.Cells[Col, Row + 2] := '';
    end;
  finally
    grdPreview.EndUpdate;
  end;

  stsImport.SimpleText := IntToStr(FPlan.RowCount) + ' row(s), ' +
    IntToStr(FPlan.ColumnCount) + ' column(s)';
  if FPlan.RowCount > Shown then
    stsImport.SimpleText := stsImport.SimpleText +
      ' - showing the first ' + IntToStr(Shown);
  btnImport.Enabled := FPlan.RowCount > 0;
end;

function TfrmImportFlatFile.RunImport(out AError: String): Integer;
var
  Tr: TIBTransaction;
  S: TIBSQL;
  Idx: Integer;
  Table: String;
begin
  Result := -1;
  AError := '';
  if not Assigned(FPlan) or (FPlan.ColumnCount = 0) then
  begin
    AError := 'Choose a file and preview it first.';
    Exit;
  end;
  if not Assigned(FDatabase) or not FDatabase.Connected then
  begin
    AError := 'That connection is not open.';
    Exit;
  end;
  Table := Trim(edTable.Text);
  if Table = '' then
  begin
    AError := 'Name the table to import into.';
    Exit;
  end;

  Tr := TIBTransaction.Create(nil);
  S := TIBSQL.Create(nil);
  try
    Tr.DefaultDatabase := FDatabase;
    S.Database := FDatabase;
    S.Transaction := Tr;
    Tr.StartTransaction;
    try
      if chkCreateTable.Checked then
      begin
        S.SQL.Text := FPlan.CreateTableSQL(Table);
        S.ExecQuery;
        { DDL and DML in one transaction is more than Firebird likes - the
          table has to exist before anything can be inserted into it. }
        Tr.Commit;
        Tr.StartTransaction;
      end;

      Result := 0;
      for Idx := 0 to FPlan.RowCount - 1 do
      begin
        S.SQL.Text := FPlan.InsertSQL(Table, Idx);
        S.ExecQuery;
        Inc(Result);
      end;
      Tr.Commit;
    except
      on E: Exception do
      begin
        if Tr.Active then
          Tr.Rollback;
        { All or nothing. A half-imported file is worse than none: the rows
          that arrived are indistinguishable from data that was already
          there. }
        AError := E.Message;
        Result := -1;
      end;
    end;
  finally
    S.Free;
    Tr.Free;
  end;
end;

procedure TfrmImportFlatFile.btnBrowseClick(Sender: TObject);
begin
  if dlgOpen.Execute then
  begin
    edFile.Text := dlgOpen.FileName;
    if Trim(edTable.Text) = '' then
      { A sensible first guess at the table name: the file's own. }
      edTable.Text := UpperCase(ChangeFileExt(ExtractFileName(dlgOpen.FileName), ''));
    BuildPlan(edFile.Text);
  end;
end;

procedure TfrmImportFlatFile.btnPreviewClick(Sender: TObject);
begin
  BuildPlan(edFile.Text);
end;

procedure TfrmImportFlatFile.btnImportClick(Sender: TObject);
var
  Err: String;
  Rows: Integer;
begin
  Rows := RunImport(Err);
  if Rows < 0 then
  begin
    stsImport.SimpleText := 'Import failed: ' + Err;
    MessageDlg('The import failed and nothing was written:' + #13#10#13#10 + Err,
      mtError, [mbOK], 0);
    Exit;
  end;
  stsImport.SimpleText := IntToStr(Rows) + ' row(s) imported into ' +
    Trim(edTable.Text);
  MessageDlg(IntToStr(Rows) + ' row(s) imported.', mtInformation, [mbOK], 0);
end;

procedure TfrmImportFlatFile.btnCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmImportFlatFile.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

end.
