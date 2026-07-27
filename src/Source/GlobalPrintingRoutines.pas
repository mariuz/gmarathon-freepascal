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
// $Id: GlobalPrintingRoutines.pas,v 1.7 2006/10/22 06:04:28 rjmills Exp $

unit GlobalPrintingRoutines;

{$MODE Delphi}

interface

uses {$IFDEF FPC} LCLIntf, LCLType, LMessages, {$ELSE} Windows, Messages, {$ENDIF} SysUtils, Classes, Graphics, Controls, Forms, Dialogs, ExtCtrls, DB, Printers, Registry, TAGraph, SynEdit, SyntaxMemoWithStuff2, IBDatabase, IBQuery, GSSRegistry, MarathonProjectCacheTypes, MarathonProjectCache, GlobalPrintDialog,
  PrintDocument, PrintRenderer, DDLExtractor, SchemaObjects;

type
  { The reports the application can print. Every method builds a TPrintDocument
    and hands it to Emit, which paginates it and either prints it or opens the
    preview - see PrintDocument for where the pages break and PrintRenderer for
    how they are drawn.

    This replaced the original PagePrnt/DSprint report writers, which were
    never ported; the method signatures are unchanged because the editor forms
    all call them. }
  TfrmGlobalPrintingRoutines = class(TForm)
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    procedure ShowPrintingUnavailable;
    { Lays the document out and either prints it or opens the preview on it.
      Every Print method below ends here, so there is one place that decides
      what a page is and one place that decides where it goes. }
    procedure Emit(Doc: TPrintDocument; Preview: Boolean; const JobTitle: String);
    { A document holding one object's DDL, which is what almost every
      object-specific report on this form amounts to. }
    function DDLDocument(const ObjectName, ConnectionName: String;
      ObjectType: TDDLObjectType; const ReportTitle: String): TPrintDocument;
    procedure PrintOneObject(Preview: Boolean; const ObjectName, ConnectionName,
      ReportTitle: String; ObjectType: TDDLObjectType);
    procedure PrintAllObjects(Preview: Boolean; const ConnectionName,
      ReportTitle: String; ObjectType: TDDLObjectType; Kind: TSchemaObjectKind);
    { The tree's idea of what an object is, as the extractor's. }
    function DDLTypeOf(ObjectType: TGSSCacheType): TDDLObjectType;
    { A report built from one query, which is what the dependency and
      permission reports both are. }
    procedure PrintQueryReport(Preview: Boolean; const ConnectionName,
      ReportTitle, SQLText, EmptyText: String);
	public
		{ Public declarations }
		//general
    procedure PrintDataSetNewPage(Sender: TObject);
		procedure PrintDataSet(DataSet : TDataSet; Preview : Boolean; Title : String);
		procedure PrintSyntaxMemo(TSM : TSyntaxMemoWithStuff2; Preview : Boolean; Title : String);
		procedure PrintLines(Lines : TStrings; Preview : Boolean; Title : String);
		procedure PrintLinesWithTitle(Lines : TStrings; PageTitle : String; Preview : Boolean; Title : String);
		procedure PrintPerformanceAnalysis(Preview : Boolean; Query : TStrings; Dataset : TDataSet; Chart : TChart);
		{$IFNDEF FPC}procedure PrintQueryPlan(Preview : Boolean; Query : TStrings; Plan : String; GPlan : TMetafile);{$ENDIF}

		//object
    procedure PrintGeneral(Preview: Boolean;	ReportTitle, ObjectType, ObjectName, ConnectionName: String);
		procedure PrintDatabase(Preview : Boolean; ConnectionName : String);
		procedure PrintDomain(Preview : Boolean; ObjectName : String; ConnectionName : String);
		procedure PrintDomains(Preview : Boolean; ConnectionName : String);
		procedure PrintException(Preview : Boolean; ObjectName : String; ConnectionName : String);
		procedure PrintExceptions(Preview : Boolean; ConnectionName : String);
		procedure PrintGenerator(Preview : Boolean; ObjectName : String; ConnectionName : String);
    procedure PrintGenerators(Preview : Boolean; ConnectionName : String);
    procedure PrintTable(Preview : Boolean; ObjectName : String; ConnectionName : String);
    procedure PrintTables(Preview : Boolean; ConnectionName : String);
    procedure PrintTableStruct(Preview : Boolean; ObjectName : String; ConnectionName : String);
    procedure PrintTableConstraints(Preview : Boolean; ObjectName : String; ConnectionName : String);
    procedure PrintTableIndexes(Preview : Boolean; ObjectName : String; ConnectionName : String);
    procedure PrintTableTriggers(Preview : Boolean; ObjectName : String; ConnectionName : String);
    procedure PrintTrigger(Preview : Boolean; ObjectName : String; ConnectionName : String);
    procedure PrintTriggers(Preview : Boolean; ConnectionName : String);
		procedure PrintSP(Preview : Boolean; ObjectName : String; ConnectionName : String);
		procedure PrintSPs(Preview : Boolean; ConnectionName : String);
		procedure PrintUDF(Preview : Boolean; ObjectName : String; ConnectionName : String);
		procedure PrintUDFs(Preview : Boolean; ConnectionName : String);
		procedure PrintView(Preview : Boolean; ObjectName : String; ConnectionName : String);
		procedure PrintViews(Preview : Boolean; ConnectionName : String);
		procedure PrintViewSource(Preview : Boolean; ObjectName : String; ConnectionName : String);
		procedure PrintViewStruct(Preview : Boolean; ObjectName : String; ConnectionName : String);
		procedure PrintViewTriggers(Preview : Boolean; ObjectName : String; ConnectionName : String);
		procedure PrintObjectDependencies(Preview : Boolean; ObjectName : String; ConnectionName : String);
		procedure PrintObjectDoco(Preview : Boolean; ObjectName : String; ConnectionName : String; ObjectType : TGSSCacheType);
		procedure PrintObjectDRUIMatrix(Preview : Boolean; ObjectName : String; ConnectionName : String; ObjectType : TGSSCacheType);
		procedure PrintObjectDDL(Preview : Boolean; ObjectName : String; ConnectionName : String; ObjectType : TGSSCacheType);
		procedure PrintObjectPerms(Preview : Boolean; ObjectName : String; ConnectionName : String; ObjectType : TGSSCacheType);

		//tree
		procedure PrintTreeList(Preview : Boolean; ObjectList : TList);

		function CanPrint : Boolean;
		function CanFirst : Boolean;
		function CanPrior : Boolean;
		function CanNext : Boolean;
		function CanLast : Boolean;

		procedure DoPrint;
		procedure DoFirst;
    procedure DoPrior;
    procedure DoNext;
    procedure DoLast;
	end;

var
  gpTopMargin : Double;
  gpLeftMargin : Double;
  gpBottomMargin : Double;
  gpRightMargin : Double;

  gpNumCopies : Integer;
  gpWrap : Boolean;

procedure ReadPrintSettings;
procedure WritePrintSettings;

function DoWeHaveAPrinter : Boolean;

implementation

{ In the implementation, not the interface: PrintPreviewForm names this unit in
  its own interface, so the two would be circular the other way round. }
uses PrintPreviewForm, MarathonIDE;

{$R *.lfm}

procedure ReadPrintSettings;
var
  R : TRegistry;

begin
  //load the margins settings from the registry
  R := TRegistry.Create;
  try
		with R do
    begin
      if OpenKey(REG_SETTINGS_MARGINS, True) then
      begin
				if not ValueExists('Left') then
          WriteFloat('Left', 0.75);

        if not ValueExists('Right') then
          WriteFloat('Right', 0.75);

        if not ValueExists('Top') then
          WriteFloat('Top', 0.5);

        if not ValueExists('Bottom') then
          WriteFloat('Bottom', 0.5);

        gpLeftMargin := ReadFloat('Left');
        gpRightMargin := ReadFloat('Right');
        gpTopMargin := ReadFloat('Top');
        gpBottomMargin := ReadFloat('Bottom');

        CloseKey;
      end;

      if OpenKey(REG_SETTINGS_PRINT, True) then
      begin
        if not ValueExists('NumCopies') then
          WriteInteger('NumCopies', 1);

        if not ValueExists('Wrap') then
          WriteBool('Wrap', True);

        gpNumCopies := ReadInteger('NumCopies');
        gpWrap := ReadBool('Wrap');

        CloseKey;
      end;
    end;
  finally
    R.Free;
  end;
end;

procedure WritePrintSettings;
var
  R : TRegistry;

begin
  //load the margins settings from the registry
  R := TRegistry.Create;
  try
    with R do
    begin
      if OpenKey(REG_SETTINGS_MARGINS, True) then
      begin
        WriteFloat('Left', gpLeftMargin);
        WriteFloat('Right', gpRightMargin);
        WriteFloat('Top', gpTopMargin);
        WriteFloat('Bottom', gpBottomMargin);

        CloseKey;
      end;

      if OpenKey(REG_SETTINGS_PRINT, True) then
      begin
        WriteInteger('NumCopies', gpNumCopies);
        WriteBool('Wrap', gpWrap);

        CloseKey;
      end;
    end;
  finally
    R.Free;
  end;
end;

function DoWeHaveAPrinter : Boolean;
begin
  Result := Printer.Printers.Count > 0;
end;

{ TfrmGlobalPrintingRoutines }

procedure TfrmGlobalPrintingRoutines.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TfrmGlobalPrintingRoutines.ShowPrintingUnavailable;
begin
  MessageDlg('There is no printer configured to print to.', mtInformation,
    [mbOK], 0);
end;

procedure TfrmGlobalPrintingRoutines.Emit(Doc: TPrintDocument; Preview: Boolean;
  const JobTitle: String);
var
  Metrics: TPageMetrics;
  Printed: TPrintedDocument;
  Preview_: TfrmPrintPreview;
begin
  if not Assigned(Doc) then
    Exit;
  try
    Metrics := PrinterPageMetrics;
    Printed := PaginateDocument(Doc, Metrics.LinesPerPage, Metrics.CharsPerLine);
    if Preview then
    begin
      { The preview takes the document over - it is what keeps it alive after
        this returns - so it is not freed here. }
      Preview_ := TfrmPrintPreview.Create(nil);
      Preview_.Caption := JobTitle;
      Preview_.LoadDocument(Printed, Metrics.CharsPerLine);
      Preview_.ShowDocument;
    end
    else
    begin
      try
        if not PrintToPrinter(Printed, JobTitle, Metrics.CharsPerLine) then
          ShowPrintingUnavailable;
      finally
        Printed.Free;
      end;
    end;
  finally
    Doc.Free;
  end;
end;


function TfrmGlobalPrintingRoutines.DDLDocument(const ObjectName,
  ConnectionName: String; ObjectType: TDDLObjectType;
  const ReportTitle: String): TPrintDocument;
var
  Conn: TMarathonCacheConnection;
  Extractor: TDDLExtractor;
  Text: TStringList;
begin
  Result := TPrintDocument.Create(ReportTitle);
  Result.AddTitle(ObjectName);
  Result.AddSpacer;

  Conn := MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[ConnectionName];
  if not Assigned(Conn) or not Conn.Connected then
  begin
    Result.AddText('Not connected to ' + ConnectionName + '.');
    Exit;
  end;

  Extractor := TDDLExtractor.Create(nil);
  Text := TStringList.Create;
  try
    Extractor.Database := Conn.Connection;
    Extractor.Transaction := Conn.Transaction;
    Extractor.SQLDialect := Conn.SQLDialect;
    Extractor.IsInterbase6 := True;
    try
      Text.Text := Extractor.Extract(ObjectType, ddlstNone, ObjectName);
    except
      { A report that says why it is empty is worth more than one that is
        silently blank. }
      on E: Exception do
        Text.Text := 'Could not read ' + ObjectName + ': ' + E.Message;
    end;
    Result.AddLines(Text);
  finally
    Text.Free;
    Extractor.Free;
  end;
end;

procedure TfrmGlobalPrintingRoutines.PrintOneObject(Preview: Boolean;
  const ObjectName, ConnectionName, ReportTitle: String;
  ObjectType: TDDLObjectType);
begin
  Emit(DDLDocument(ObjectName, ConnectionName, ObjectType, ReportTitle),
    Preview, ReportTitle);
end;

{ Every object of one kind, one after another. Listed through the same call the
  object tree uses, so what is printed is what the tree shows. }
procedure TfrmGlobalPrintingRoutines.PrintAllObjects(Preview: Boolean;
  const ConnectionName, ReportTitle: String; ObjectType: TDDLObjectType;
  Kind: TSchemaObjectKind);
var
  Conn: TMarathonCacheConnection;
  Names, Text: TStringList;
  Extractor: TDDLExtractor;
  Doc: TPrintDocument;
  Idx: Integer;
begin
  Doc := TPrintDocument.Create(ReportTitle);
  Doc.AddTitle(ReportTitle);
  Doc.AddSpacer;

  Conn := MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[ConnectionName];
  if not Assigned(Conn) or not Conn.Connected then
  begin
    Doc.AddText('Not connected to ' + ConnectionName + '.');
    Emit(Doc, Preview, ReportTitle);
    Exit;
  end;

  Names := ListSchemaObjects(Conn.Connection, Conn.Transaction, Kind, '',
    Conn.IsODSAtLeast(ODS_FB6_MAJOR, 0));
  Extractor := TDDLExtractor.Create(nil);
  Text := TStringList.Create;
  try
    Extractor.Database := Conn.Connection;
    Extractor.Transaction := Conn.Transaction;
    Extractor.SQLDialect := Conn.SQLDialect;
    Extractor.IsInterbase6 := True;
    if Names.Count = 0 then
      Doc.AddText('There are none.');
    for Idx := 0 to Names.Count - 1 do
    begin
      Doc.AddHeading(Trim(Names[Idx]));
      try
        Text.Text := Extractor.Extract(ObjectType, ddlstNone, Trim(Names[Idx]));
      except
        { One object that cannot be read must not lose the rest of the
          report. }
        on E: Exception do
          Text.Text := '  could not be read: ' + E.Message;
      end;
      Doc.AddLines(Text);
      Doc.AddSpacer;
    end;
  finally
    Text.Free;
    Extractor.Free;
    Names.Free;
  end;
  Emit(Doc, Preview, ReportTitle);
end;

function TfrmGlobalPrintingRoutines.DDLTypeOf(ObjectType: TGSSCacheType): TDDLObjectType;
begin
  case ObjectType of
    ctView:      Result := ddlView;
    ctSP:        Result := ddlStoredProc;
    ctTrigger:   Result := ddlTrigger;
    ctDomain:    Result := ddlDomain;
    ctGenerator: Result := ddlGenerator;
    ctException: Result := ddlException;
    ctUDF:       Result := ddlUDF;
    ctPackage:   Result := ddlPackage;
  else
    Result := ddlTable;
  end;
end;

procedure TfrmGlobalPrintingRoutines.PrintQueryReport(Preview: Boolean;
  const ConnectionName, ReportTitle, SQLText, EmptyText: String);
var
  Conn: TMarathonCacheConnection;
  Q: TIBQuery;
  Doc: TPrintDocument;
  Cells: array of String;
  Idx, Rows: Integer;
begin
  Doc := TPrintDocument.Create(ReportTitle);
  Doc.AddTitle(ReportTitle);
  Doc.AddSpacer;

  Conn := MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[ConnectionName];
  if not Assigned(Conn) or not Conn.Connected then
  begin
    Doc.AddText('Not connected to ' + ConnectionName + '.');
    Emit(Doc, Preview, ReportTitle);
    Exit;
  end;

  Q := TIBQuery.Create(nil);
  try
    Q.Database := Conn.Connection;
    Q.Transaction := Conn.Transaction;
    { The shared metadata transaction is committed constantly by the object
      tree, so this may well arrive on a closed one. }
    Q.AllowAutoActivateTransaction := True;
    Q.SQL.Text := SQLText;
    Rows := 0;
    try
      Q.Open;
      SetLength(Cells, Q.FieldCount);
      for Idx := 0 to Q.FieldCount - 1 do
        Cells[Idx] := Q.Fields[Idx].DisplayName;
      Doc.AddTableHeader(Cells);
      while not Q.EOF do
      begin
        for Idx := 0 to Q.FieldCount - 1 do
          Cells[Idx] := Trim(Q.Fields[Idx].DisplayText);
        Doc.AddTableRow(Cells);
        Inc(Rows);
        Q.Next;
      end;
    except
      on E: Exception do
        Doc.AddText('Could not read the data: ' + E.Message);
    end;
    if Rows = 0 then
      Doc.AddText(EmptyText);
  finally
    Q.Free;
  end;
  Emit(Doc, Preview, ReportTitle);
end;

procedure TfrmGlobalPrintingRoutines.PrintDataSetNewPage(Sender: TObject);
begin
end;

procedure TfrmGlobalPrintingRoutines.PrintDataSet(DataSet: TDataSet; Preview: Boolean; Title : String);
var
  Doc: TPrintDocument;
  Cells: array of String;
  Idx: Integer;
  Bookmark: TBookmark;
begin
  if not Assigned(DataSet) or not DataSet.Active then
    Exit;
  Doc := TPrintDocument.Create(Title);
  SetLength(Cells, DataSet.FieldCount);
  for Idx := 0 to DataSet.FieldCount - 1 do
    Cells[Idx] := DataSet.Fields[Idx].DisplayName;
  Doc.AddTableHeader(Cells);

  { The grid the user is looking at must be where it was afterwards, so the
    position is put back however the walk ends. }
  Bookmark := DataSet.GetBookmark;
  DataSet.DisableControls;
  try
    DataSet.First;
    while not DataSet.EOF do
    begin
      for Idx := 0 to DataSet.FieldCount - 1 do
        if DataSet.Fields[Idx].IsNull then
          { Distinguishable from an empty string, which on a printout it
            otherwise would not be. }
          Cells[Idx] := '<null>'
        else
          Cells[Idx] := DataSet.Fields[Idx].DisplayText;
      Doc.AddTableRow(Cells);
      DataSet.Next;
    end;
  finally
    if Assigned(Bookmark) then
    begin
      try
        DataSet.GotoBookmark(Bookmark);
      except
        on E: Exception do
          DataSet.First;
      end;
      DataSet.FreeBookmark(Bookmark);
    end;
    DataSet.EnableControls;
  end;
  Emit(Doc, Preview, Title);
end;

procedure TfrmGlobalPrintingRoutines.PrintSyntaxMemo(TSM : TSyntaxMemoWithStuff2; Preview : Boolean; Title : String);
begin
  if not Assigned(TSM) then
    Exit;
  PrintLines(TSM.Lines, Preview, Title);
end;

procedure TfrmGlobalPrintingRoutines.PrintLines(Lines : TStrings; Preview : Boolean; Title : String);
var
  Doc: TPrintDocument;
begin
  Doc := TPrintDocument.Create(Title);
  Doc.AddLines(Lines);
  Emit(Doc, Preview, Title);
end;

procedure TfrmGlobalPrintingRoutines.PrintLinesWithTitle(Lines : TStrings; PageTitle : String; Preview : Boolean; Title : String);
var
  Doc: TPrintDocument;
begin
  Doc := TPrintDocument.Create(Title);
  Doc.AddTitle(PageTitle);
  Doc.AddSpacer;
  Doc.AddLines(Lines);
  Emit(Doc, Preview, Title);
end;

procedure TfrmGlobalPrintingRoutines.PrintPerformanceAnalysis(Preview : Boolean; Query : TStrings; Dataset : TDataSet; Chart : TChart);
var
  Doc: TPrintDocument;
  Cells: array of String;
  Idx: Integer;
begin
  Doc := TPrintDocument.Create('Performance Analysis');
  Doc.AddTitle('Performance Analysis');
  Doc.AddSpacer;
  if Assigned(Query) and (Query.Count > 0) then
  begin
    Doc.AddHeading('Statement');
    Doc.AddLines(Query);
    Doc.AddSpacer;
  end;
  { The chart is not printed. It is a picture of these same numbers, and
    rendering a TChart onto the page is a different job from laying out text;
    the figures it draws are all here. }
  if Assigned(Dataset) and Dataset.Active then
  begin
    Doc.AddHeading('Statistics');
    SetLength(Cells, Dataset.FieldCount);
    for Idx := 0 to Dataset.FieldCount - 1 do
      Cells[Idx] := Dataset.Fields[Idx].DisplayName;
    Doc.AddTableHeader(Cells);
    Dataset.First;
    while not Dataset.EOF do
    begin
      for Idx := 0 to Dataset.FieldCount - 1 do
        Cells[Idx] := Dataset.Fields[Idx].DisplayText;
      Doc.AddTableRow(Cells);
      Dataset.Next;
    end;
  end;
  Emit(Doc, Preview, 'Performance Analysis');
end;

{$IFNDEF FPC}
procedure TfrmGlobalPrintingRoutines.PrintQueryPlan(Preview : Boolean; Query : TStrings; Plan : String; GPlan : TMetafile);
begin
  ShowPrintingUnavailable;
end;
{$ENDIF}

procedure TfrmGlobalPrintingRoutines.PrintGeneral(Preview: Boolean; ReportTitle, ObjectType, ObjectName, ConnectionName: String);
var
  Doc: TPrintDocument;
begin
  { ObjectType arrives as the caption the tree shows rather than as the enum,
    so this cannot dispatch on it; what it can do is head the report properly
    and print the object's DDL underneath. }
  Doc := DDLDocument(ObjectName, ConnectionName, ddlTable, ReportTitle);
  Doc.AddSpacer;
  Doc.AddText(ObjectType + ' in ' + ConnectionName);
  Emit(Doc, Preview, ReportTitle);
end;

procedure TfrmGlobalPrintingRoutines.PrintDatabase(Preview : Boolean; ConnectionName : String);
const
  Kinds: array[0..7] of TSchemaObjectKind = (sokTable, sokView, sokProcedure,
    sokFunction, sokTrigger, sokDomain, sokGenerator, sokException);
  Captions: array[0..7] of String = ('Tables', 'Views', 'Stored Procedures',
    'Functions', 'Triggers', 'Domains', 'Generators', 'Exceptions');
var
  Conn: TMarathonCacheConnection;
  Doc: TPrintDocument;
  Names: TStringList;
  Idx, N: Integer;
begin
  Doc := TPrintDocument.Create('Database Summary');
  Doc.AddTitle(ConnectionName);
  Doc.AddSpacer;

  Conn := MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[ConnectionName];
  if not Assigned(Conn) or not Conn.Connected then
  begin
    Doc.AddText('Not connected to ' + ConnectionName + '.');
    Emit(Doc, Preview, 'Database Summary');
    Exit;
  end;

  Doc.AddHeading('Connection');
  Doc.AddText('Database:  ' + Conn.DBFileName);
  Doc.AddText('Server:    ' + Conn.ServerName);
  Doc.AddText('User:      ' + Conn.UserName);
  Doc.AddText('Dialect:   ' + IntToStr(Conn.SQLDialect));
  Doc.AddText('Version:   ' + Conn.ServerVersion);
  Doc.AddText('ODS:       ' + IntToStr(Conn.ODSMajor) + '.' +
    IntToStr(Conn.ODSMinor));
  Doc.AddSpacer;

  Doc.AddHeading('Contents');
  Doc.AddTableHeader(['Object', 'Count']);
  for Idx := Low(Kinds) to High(Kinds) do
  begin
    N := 0;
    try
      Names := ListSchemaObjects(Conn.Connection, Conn.Transaction, Kinds[Idx],
        '', Conn.IsODSAtLeast(ODS_FB6_MAJOR, 0));
      try
        N := Names.Count;
      finally
        Names.Free;
      end;
    except
      { A kind the server does not have is a count of none, not a failed
        report. }
      on E: Exception do
        N := 0;
    end;
    Doc.AddTableRow([Captions[Idx], IntToStr(N)]);
  end;
  Emit(Doc, Preview, 'Database Summary');
end;

procedure TfrmGlobalPrintingRoutines.PrintDomain(Preview : Boolean; ObjectName : String; ConnectionName : String);
begin
  PrintOneObject(Preview, ObjectName, ConnectionName, 'Domain', ddlDomain);
end;

procedure TfrmGlobalPrintingRoutines.PrintDomains(Preview : Boolean; ConnectionName : String);
begin
  PrintAllObjects(Preview, ConnectionName, 'All Domains', ddlDomain, sokDomain);
end;

procedure TfrmGlobalPrintingRoutines.PrintException(Preview : Boolean; ObjectName : String; ConnectionName : String);
begin
  PrintOneObject(Preview, ObjectName, ConnectionName, 'Exception', ddlException);
end;

procedure TfrmGlobalPrintingRoutines.PrintExceptions(Preview : Boolean; ConnectionName : String);
begin
  PrintAllObjects(Preview, ConnectionName, 'All Exceptions', ddlException, sokException);
end;

procedure TfrmGlobalPrintingRoutines.PrintGenerator(Preview : Boolean; ObjectName : String; ConnectionName : String);
begin
  PrintOneObject(Preview, ObjectName, ConnectionName, 'Generator', ddlGenerator);
end;

procedure TfrmGlobalPrintingRoutines.PrintGenerators(Preview : Boolean; ConnectionName : String);
begin
  PrintAllObjects(Preview, ConnectionName, 'All Generators', ddlGenerator, sokGenerator);
end;

procedure TfrmGlobalPrintingRoutines.PrintTable(Preview : Boolean; ObjectName : String; ConnectionName : String);
begin
  PrintOneObject(Preview, ObjectName, ConnectionName, 'Table', ddlTable);
end;

procedure TfrmGlobalPrintingRoutines.PrintTables(Preview : Boolean; ConnectionName : String);
begin
  PrintAllObjects(Preview, ConnectionName, 'All Tables', ddlTable, sokTable);
end;

procedure TfrmGlobalPrintingRoutines.PrintTableStruct(Preview : Boolean; ObjectName : String; ConnectionName : String);
begin
  PrintOneObject(Preview, ObjectName, ConnectionName, 'Table Structure', ddlTable);
end;

procedure TfrmGlobalPrintingRoutines.PrintTableConstraints(Preview : Boolean; ObjectName : String; ConnectionName : String);
begin
  PrintOneObject(Preview, ObjectName, ConnectionName, 'Table Constraints', ddlTable);
end;

procedure TfrmGlobalPrintingRoutines.PrintTableIndexes(Preview : Boolean; ObjectName : String; ConnectionName : String);
begin
  PrintOneObject(Preview, ObjectName, ConnectionName, 'Table Indices', ddlTable);
end;

procedure TfrmGlobalPrintingRoutines.PrintTableTriggers(Preview : Boolean; ObjectName : String; ConnectionName : String);
begin
  PrintOneObject(Preview, ObjectName, ConnectionName, 'Table Triggers', ddlTable);
end;

procedure TfrmGlobalPrintingRoutines.PrintTrigger(Preview : Boolean; ObjectName : String; ConnectionName : String);
begin
  PrintOneObject(Preview, ObjectName, ConnectionName, 'Trigger', ddlTrigger);
end;

procedure TfrmGlobalPrintingRoutines.PrintTriggers(Preview : Boolean; ConnectionName : String);
begin
  PrintAllObjects(Preview, ConnectionName, 'All Triggers', ddlTrigger, sokTrigger);
end;

procedure TfrmGlobalPrintingRoutines.PrintSP(Preview : Boolean; ObjectName : String; ConnectionName : String);
begin
  PrintOneObject(Preview, ObjectName, ConnectionName, 'Stored Procedure', ddlStoredProc);
end;

procedure TfrmGlobalPrintingRoutines.PrintSPs(Preview : Boolean; ConnectionName : String);
begin
  PrintAllObjects(Preview, ConnectionName, 'All Stored Procedures', ddlStoredProc, sokProcedure);
end;

procedure TfrmGlobalPrintingRoutines.PrintUDF(Preview : Boolean; ObjectName : String; ConnectionName : String);
begin
  PrintOneObject(Preview, ObjectName, ConnectionName, 'User Defined Function', ddlUDF);
end;

procedure TfrmGlobalPrintingRoutines.PrintUDFs(Preview : Boolean; ConnectionName : String);
begin
  PrintAllObjects(Preview, ConnectionName, 'All User Defined Functions', ddlUDF, sokFunction);
end;

procedure TfrmGlobalPrintingRoutines.PrintView(Preview : Boolean; ObjectName : String; ConnectionName : String);
begin
  PrintOneObject(Preview, ObjectName, ConnectionName, 'View', ddlView);
end;

procedure TfrmGlobalPrintingRoutines.PrintViews(Preview : Boolean; ConnectionName : String);
begin
  PrintAllObjects(Preview, ConnectionName, 'All Views', ddlView, sokView);
end;

procedure TfrmGlobalPrintingRoutines.PrintViewSource(Preview : Boolean; ObjectName : String; ConnectionName : String);
begin
  PrintOneObject(Preview, ObjectName, ConnectionName, 'View Source', ddlView);
end;

procedure TfrmGlobalPrintingRoutines.PrintViewStruct(Preview : Boolean; ObjectName : String; ConnectionName : String);
begin
  PrintOneObject(Preview, ObjectName, ConnectionName, 'View Structure', ddlView);
end;

procedure TfrmGlobalPrintingRoutines.PrintViewTriggers(Preview : Boolean; ObjectName : String; ConnectionName : String);
begin
  PrintOneObject(Preview, ObjectName, ConnectionName, 'View Triggers', ddlView);
end;

procedure TfrmGlobalPrintingRoutines.PrintObjectDependencies(Preview : Boolean; ObjectName : String; ConnectionName : String);
begin
  PrintQueryReport(Preview, ConnectionName,
    'Dependencies of ' + ObjectName,
    'select rdb$dependent_name as "Depends On This", ' +
    '       rdb$dependent_type as "Type", ' +
    '       rdb$field_name as "Field" ' +
    'from rdb$dependencies where rdb$depended_on_name = ' +
    AnsiQuotedStr(ObjectName, '''') +
    ' order by rdb$dependent_name, rdb$field_name',
    'Nothing depends on ' + ObjectName + '.');
end;

procedure TfrmGlobalPrintingRoutines.PrintObjectDoco(Preview : Boolean; ObjectName : String; ConnectionName : String; ObjectType : TGSSCacheType);
begin
  { The descriptions attached to the object and to its columns - which is what
    documentation means in a Firebird database. }
  PrintQueryReport(Preview, ConnectionName,
    'Documentation for ' + ObjectName,
    'select rf.rdb$field_name as "Column", ' +
    '       rf.rdb$description as "Description" ' +
    'from rdb$relation_fields rf where rf.rdb$relation_name = ' +
    AnsiQuotedStr(ObjectName, '''') +
    ' order by rf.rdb$field_position',
    'Nothing is documented on ' + ObjectName + '.');
end;

procedure TfrmGlobalPrintingRoutines.PrintObjectDRUIMatrix(Preview : Boolean; ObjectName : String; ConnectionName : String; ObjectType : TGSSCacheType);
begin
  { Who may Delete, Read, Update and Insert - one row per grantee rather than
    one per privilege, which is the point of a matrix. }
  PrintQueryReport(Preview, ConnectionName,
    'Access to ' + ObjectName,
    'select rdb$user as "User", ' +
    '  max(case rdb$privilege when ''D'' then ''yes'' else '''' end) as "Delete", ' +
    '  max(case rdb$privilege when ''S'' then ''yes'' else '''' end) as "Select", ' +
    '  max(case rdb$privilege when ''U'' then ''yes'' else '''' end) as "Update", ' +
    '  max(case rdb$privilege when ''I'' then ''yes'' else '''' end) as "Insert" ' +
    'from rdb$user_privileges where rdb$relation_name = ' +
    AnsiQuotedStr(ObjectName, '''') +
    ' group by rdb$user order by rdb$user',
    'Nobody has been granted access to ' + ObjectName + '.');
end;

procedure TfrmGlobalPrintingRoutines.PrintObjectDDL(Preview : Boolean; ObjectName : String; ConnectionName : String; ObjectType : TGSSCacheType);
begin
  PrintOneObject(Preview, ObjectName, ConnectionName, 'DDL for ' + ObjectName,
    DDLTypeOf(ObjectType));
end;

procedure TfrmGlobalPrintingRoutines.PrintObjectPerms(Preview : Boolean; ObjectName : String; ConnectionName : String; ObjectType : TGSSCacheType);
begin
  PrintQueryReport(Preview, ConnectionName,
    'Permissions on ' + ObjectName,
    'select rdb$user as "User", rdb$privilege as "Privilege", ' +
    '       rdb$grant_option as "Grantable", rdb$field_name as "Column" ' +
    'from rdb$user_privileges where rdb$relation_name = ' +
    AnsiQuotedStr(ObjectName, '''') +
    ' order by rdb$user, rdb$privilege',
    'No permissions have been granted on ' + ObjectName + '.');
end;

procedure TfrmGlobalPrintingRoutines.PrintTreeList(Preview : Boolean; ObjectList : TList);
var
  Doc: TPrintDocument;
  Idx: Integer;
  Item: TMarathonCacheBaseNode;
begin
  Doc := TPrintDocument.Create('Selected Objects');
  Doc.AddTitle('Selected Objects');
  Doc.AddSpacer;
  if not Assigned(ObjectList) or (ObjectList.Count = 0) then
    Doc.AddText('Nothing is selected.')
  else
  begin
    Doc.AddTableHeader(['Object', 'Connection']);
    for Idx := 0 to ObjectList.Count - 1 do
    begin
      Item := TMarathonCacheBaseNode(ObjectList[Idx]);
      if not Assigned(Item) then
        Continue;
      { Only an object node knows which connection it came from; a header or a
        folder in the selection has none to report. }
      if Item is TMarathonCacheObject then
        Doc.AddTableRow([Item.Caption, TMarathonCacheObject(Item).ConnectionName])
      else
        Doc.AddTableRow([Item.Caption, '']);
    end;
  end;
  Emit(Doc, Preview, 'Selected Objects');
end;

function TfrmGlobalPrintingRoutines.CanPrint : Boolean;
begin
  Result := False;
end;

function TfrmGlobalPrintingRoutines.CanFirst : Boolean;
begin
  Result := False;
end;

function TfrmGlobalPrintingRoutines.CanPrior : Boolean;
begin
  Result := False;
end;

function TfrmGlobalPrintingRoutines.CanNext : Boolean;
begin
  Result := False;
end;

function TfrmGlobalPrintingRoutines.CanLast : Boolean;
begin
  Result := False;
end;

procedure TfrmGlobalPrintingRoutines.DoPrint;
begin
end;

procedure TfrmGlobalPrintingRoutines.DoFirst;
begin
end;

procedure TfrmGlobalPrintingRoutines.DoPrior;
begin
end;

procedure TfrmGlobalPrintingRoutines.DoNext;
begin
end;

procedure TfrmGlobalPrintingRoutines.DoLast;
begin
end;

end.
