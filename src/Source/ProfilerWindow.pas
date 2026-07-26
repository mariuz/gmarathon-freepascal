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

unit ProfilerWindow;

{$MODE Delphi}

{ Front end for Firebird's built-in profiler. The database work is all in
  ProfilerQueries.pas; this is buttons and grids over it.

  Recording is per attachment, so what gets profiled is whatever runs on this
  connection while a session is open - typically statements the user runs in a
  SQL editor pointed at the same connection. Nothing is readable until the
  session is finished, because that is when the plugin flushes. }

interface

uses {$IFDEF FPC} LCLIntf, LCLType, LMessages, {$ELSE} Windows, Messages, {$ENDIF}
  SysUtils, Classes, Graphics, Controls, Forms, Dialogs, ComCtrls, StdCtrls,
  ExtCtrls, DB, DBGrids, IBDatabase, IBQuery;

type
  TfrmProfiler = class(TForm)
    pnlTop: TPanel;
    lblConnection: TLabel;
    btnStart: TButton;
    btnPause: TButton;
    btnResume: TButton;
    btnFinish: TButton;
    btnRefresh: TButton;
    btnClear: TButton;
    pgProfiler: TPageControl;
    tsSessions: TTabSheet;
    tsStatements: TTabSheet;
    tsRecordSources: TTabSheet;
    grdSessions: TDBGrid;
    grdStatements: TDBGrid;
    grdRecordSources: TDBGrid;
    dsSessions: TDataSource;
    dsStatements: TDataSource;
    dsRecordSources: TDataSource;
    qrySessions: TIBQuery;
    qryStatements: TIBQuery;
    qryRecordSources: TIBQuery;
    tranProfiler: TIBTransaction;
    stsProfiler: TStatusBar;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnStartClick(Sender: TObject);
    procedure btnPauseClick(Sender: TObject);
    procedure btnResumeClick(Sender: TObject);
    procedure btnFinishClick(Sender: TObject);
    procedure btnRefreshClick(Sender: TObject);
    procedure btnClearClick(Sender: TObject);
  private
    FConnectionName: String;
    FRecording: Boolean;
    FPaused: Boolean;
    procedure SetConnectionName(const Value: String);
    procedure UpdateButtons;
    procedure CloseQueries;
  public
    procedure RefreshData;
    property ConnectionName: String read FConnectionName write SetConnectionName;
    property Recording: Boolean read FRecording;
    property Paused: Boolean read FPaused;
  end;

implementation

uses Globals, MarathonIDE, MarathonProjectCache, ProfilerQueries;

{$R *.lfm}

procedure TfrmProfiler.FormCreate(Sender: TObject);
begin
  LoadFormPosition(Self);
  FRecording := False;
  FPaused := False;
  UpdateButtons;
end;

procedure TfrmProfiler.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  SaveFormPosition(Self);
  { A session left open would go on recording against a window that no longer
    exists, so close it out. }
  if FRecording then
    try
      FinishProfilerSession(qrySessions.Database as TIBDatabase, tranProfiler);
    except
      on E: Exception do
        ; { closing anyway }
    end;
  CloseQueries;
  if tranProfiler.Active then
    tranProfiler.Commit;
  Action := caFree;
end;

procedure TfrmProfiler.CloseQueries;
begin
  qrySessions.Close;
  qryStatements.Close;
  qryRecordSources.Close;
end;

procedure TfrmProfiler.SetConnectionName(const Value: String);
var
  Conn: TMarathonCacheConnection;
begin
  FConnectionName := Value;
  Caption := 'SQL Profiler - ' + Value;
  lblConnection.Caption := 'Connection: ' + Value;

  Conn := MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[Value];
  tranProfiler.DefaultDatabase := Conn.Connection;
  qrySessions.Database := Conn.Connection;
  qrySessions.Transaction := tranProfiler;
  qryStatements.Database := Conn.Connection;
  qryStatements.Transaction := tranProfiler;
  qryRecordSources.Database := Conn.Connection;
  qryRecordSources.Transaction := tranProfiler;

  if not ProfilerAvailable(Conn.Connection, tranProfiler) then
  begin
    { Firebird 5 introduced the profiler; on anything older the whole window is
      inert rather than misleading. }
    stsProfiler.Panels[0].Text := 'This server has no profiler (Firebird 5 or later required)';
    btnStart.Enabled := False;
    btnRefresh.Enabled := False;
    btnClear.Enabled := False;
    Exit;
  end;
  UpdateButtons;
  RefreshData;
end;

procedure TfrmProfiler.UpdateButtons;
begin
  btnStart.Enabled := not FRecording;
  btnPause.Enabled := FRecording and not FPaused;
  btnResume.Enabled := FRecording and FPaused;
  btnFinish.Enabled := FRecording;
  if FRecording and FPaused then
    stsProfiler.Panels[0].Text := 'Recording paused'
  else if FRecording then
    stsProfiler.Panels[0].Text := 'Recording - run statements on this connection, then Finish'
  else
    stsProfiler.Panels[0].Text := 'Not recording';
end;

procedure TfrmProfiler.btnStartClick(Sender: TObject);
var
  Id: Int64;
begin
  Id := StartProfilerSession(qrySessions.Database as TIBDatabase, tranProfiler,
    'Marathon ' + FormatDateTime('yyyy-mm-dd hh:nn:ss', Now));
  FRecording := True;
  FPaused := False;
  UpdateButtons;
  stsProfiler.Panels[1].Text := 'Session ' + IntToStr(Id);
end;

procedure TfrmProfiler.btnPauseClick(Sender: TObject);
begin
  PauseProfilerSession(qrySessions.Database as TIBDatabase, tranProfiler);
  FPaused := True;
  UpdateButtons;
end;

procedure TfrmProfiler.btnResumeClick(Sender: TObject);
begin
  ResumeProfilerSession(qrySessions.Database as TIBDatabase, tranProfiler);
  FPaused := False;
  UpdateButtons;
end;

procedure TfrmProfiler.btnFinishClick(Sender: TObject);
begin
  { Finishing is also what flushes; until it has run there is nothing to read. }
  FinishProfilerSession(qrySessions.Database as TIBDatabase, tranProfiler);
  FRecording := False;
  FPaused := False;
  UpdateButtons;
  RefreshData;
end;

procedure TfrmProfiler.btnClearClick(Sender: TObject);
var
  Prefix: String;
begin
  if MessageDlg('Delete every recorded profiler session from this database?',
    mtWarning, [mbYes, mbNo], 0) <> mrYes then
    Exit;
  CloseQueries;
  Prefix := ProfilerSchemaPrefix(qrySessions.Database as TIBDatabase, tranProfiler);
  { Not DISCARD: that drops only what has not been flushed yet, so it would
    leave everything on screen exactly where it was. }
  ClearProfilerData(qrySessions.Database as TIBDatabase, tranProfiler, Prefix);
  if tranProfiler.Active then
    tranProfiler.Commit;
  RefreshData;
end;

procedure TfrmProfiler.btnRefreshClick(Sender: TObject);
begin
  RefreshData;
end;

procedure TfrmProfiler.RefreshData;
var
  Prefix: String;
begin
  CloseQueries;
  if tranProfiler.Active then
    tranProfiler.Commit;
  tranProfiler.StartTransaction;

  Prefix := ProfilerSchemaPrefix(qrySessions.Database as TIBDatabase, tranProfiler);
  if Prefix = '' then
    { The plugin creates its tables on the first flush, so before any session
      has been finished there is genuinely nothing to show. }
    if not tranProfiler.Active then
      tranProfiler.StartTransaction;

  try
    qrySessions.SQL.Text := ProfilerSessionsSQL(Prefix);
    qrySessions.Open;
    qryStatements.SQL.Text := ProfilerStatementStatsSQL(Prefix);
    qryStatements.Open;
    qryRecordSources.SQL.Text := ProfilerRecordSourceStatsSQL(Prefix);
    qryRecordSources.Open;
    stsProfiler.Panels[2].Text := '';
  except
    on E: Exception do
    begin
      CloseQueries;
      stsProfiler.Panels[2].Text := 'No profiler data yet - start a session and finish it';
    end;
  end;
end;

end.
