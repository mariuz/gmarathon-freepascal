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

interface

uses
	Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
	ExtCtrls, DB, Printers, Registry, Chart,
	PagePrnt,
	DSprint,
	SynEdit,
	SyntaxMemoWithStuff2,
	IBODataset,
	GSSRegistry,
	MarathonProjectCacheTypes,
	MarathonProjectCache,
	GlobalPrintDialog;

type
  TfrmGlobalPrintingRoutines = class(TForm)
    pdsPrinter: TDataSetPrint;
    pnlBase: TPanel;
    ppPrinter: TPagePrinter;
    edPrintProxy: TSyntaxMemoWithStuff2;
    qryUtil: TIBOQuery;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
		{ Private declarations }

    ipPrn: TPagePrinter;
    ipObjectName: string;
    FipObjectsList: boolean;
    ipObjectsListHeader: boolean;
    ipConnectionName: string;

    procedure SetipObjectsList(Value: boolean);

    procedure qryUtilPrepare;
    procedure qryUtilOpen(sql: string); overload;
    procedure qryUtilOpen(opt: TfrmGlobalPrintDialogOption; ObjectName: string; FPO: TfrmGlobalPrintDialogOptions); overload;
    procedure qryUtilClose;

    function  getDataType: string;
    function  getBoolValueText(b: boolean): string;
    function  getFieldStr(FieldName: string; Len: integer): string;
    function  getFillStr(S: string; Len: integer): string;
    function  getNullFlagStr(FieldName: string): string;

    procedure IPProcPageHeader;
//    procedure IPProcPageFooter;
    procedure IPProcHeaderLine(s: string);
    procedure IPProcObjectHeader(ObjectType: string);
    procedure IPProcObjectFooter;
    procedure IPProcLine(s: string);
    procedure IPProcLineValueBool(s: string; b: boolean);
    procedure IPProcLinesFromField(f: TField);
    procedure IPProcHR;
    procedure IPProcStandartFont(stl: TFontStyles = []);
    procedure IPProcNewPage;
    procedure IPProcObjectSeparator(FPO: TfrmGlobalPrintDialogOptions);

    procedure InternalPrintObjectDescription;
    procedure InternalPrintDomain;
    procedure InternalPrintDomainDetail;
    procedure InternalPrintException;
    procedure InternalPrintExceptionException;
    procedure InternalPrintGenerator;
    procedure InternalPrintGeneratorDetail;
    procedure InternalPrintTable;
    procedure InternalPrintTableStructure;
    procedure InternalPrintTableConstraints;
    procedure InternalPrintTableIndexes;
    procedure InternalPrintTableTriggers(Detail: boolean);
    procedure InternalPrintTrigger;
    procedure InternalPrintTriggerCode;
    procedure InternalPrintSP;
    procedure InternalPrintSPCode;
    procedure InternalPrintUDF;
    procedure InternalPrintUDFUDF;
    procedure InternalPrintView;
    procedure InternalPrintViewStruct;
    procedure InternalPrintViewTriggers(Detail: boolean);
    procedure InternalPrintViewSource;
    procedure InternalPrintObjectDependencies;
    procedure InternalPrintObjectDoco(ObjectType: TGSSCacheType);
    procedure InternalPrintObjectDRUIMatrix(ObjectType : TGSSCacheType);
    procedure InternalPrintObjectDDL(ObjectType : TGSSCacheType);
    procedure InternalPrintObjectPerms(ObjectType : TGSSCacheType);

    property ipObjectsList: boolean read FipObjectsList write SetipObjectsList;

	public
		{ Public declarations }
		//general
    procedure PrintDataSetNewPage(Sender: TObject);
		procedure PrintDataSet(DataSet : TDataSet; Preview : Boolean; Title : String);
		procedure PrintSyntaxMemo(TSM : TSyntaxMemoWithStuff2; Preview : Boolean; Title : String);
		procedure PrintLines(Lines : TStrings; Preview : Boolean; Title : String);
		procedure PrintLinesWithTitle(Lines : TStrings; PageTitle : String; Preview : Boolean; Title : String);
		procedure PrintPerformanceAnalysis(Preview : Boolean; Query : TStrings; Dataset : TDataSet; Chart : TChart);
		procedure PrintQueryPlan(Preview : Boolean; Query : TStrings; Plan : String; GPlan : TMetafile);

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

uses
	Globals,
	MarathonIDE,
	PrintPreviewForm,
  GlobalQueriesText,
  Math;

{$R *.DFM}

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

        gpTopMargin := ReadFloat('Top');
        gpLeftMargin := ReadFloat('Left');
        gpBottomMargin := ReadFloat('Bottom');
        gpRightMargin := ReadFloat('Right');

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

procedure TfrmGlobalPrintingRoutines.PrintDataSetNewPage(Sender: TObject);
begin
  ppPrinter.NewPage;
//  pdsPrinter.PrinterCanvas := ppPrinter.Canvas;
end;

procedure TfrmGlobalPrintingRoutines.PrintDataSet(DataSet: TDataSet; Preview: Boolean; Title : String);
var
  PP : TfrmPrintPreview;
  F : TfrmGlobalPrintDialog;

begin
  F := TfrmGlobalPrintDialog.Create(Self);
  try
    F.chkWrap.Enabled := False;

    if Preview then
    begin
      F.edNumCopies.Enabled := False;
      F.ActiveControl := F.btnOK;
    end;

    if F.ShowModal = mrOK then
    begin
      Screen.Cursor := crHourGlass;
      try
        ppPrinter.Title := Title;

        ppPrinter.MarginLeft := gpLeftMargin;
        ppPrinter.MarginTop := gpTopMargin;
        ppPrinter.MarginRight := gpRightMargin;
        ppPrinter.MarginBottom := gpBottomMargin;

        pdsPrinter.PagePrinter := ppPrinter;
        pdsPrinter.PageOrientation := Printer.Orientation;
        pdsPrinter.DataSet := DataSet;
        pdsPrinter.DataFont.Assign(F.pnDataFont.Font);
        pdsPrinter.DataHeaderFont.Assign(F.pnDataHeaderFont.Font);
        pdsPrinter.rpPageHeaderFont.Assign(F.pnPageHeaderFont.Font);
        pdsPrinter.rpPageFooterFont.Assign(F.pnPageFooterFont.Font);
        pdsPrinter.rpTailFont.Assign(F.pnTailFont.Font);
        pdsPrinter.rpTitleFont.Assign(F.pnTitleFont.Font);

        pdsPrinter.OnPrinterNewPage := PrintDataSetNewPage;
        pdsPrinter.Print;

				if Preview then
        begin
          PP := TfrmPrintPreview.Create(nil);
          PP.PrintObject := Self;
					pnlBase.Parent := PP.pnlParent;
          PP.Show;
        end
        else
        begin
          //now print to the printer...
          ppPrinter.Print;
        end;
      finally
        Screen.Cursor := crDefault;
      end;
    end;
  finally
    F.Free;
  end;
end;

procedure TfrmGlobalPrintingRoutines.PrintLines(Lines: TStrings; Preview: Boolean; Title : String);
var
  PP : TfrmPrintPreview;
  F : TfrmGlobalPrintDialog;
  Idx : Integer;

begin
  if Lines.Count > 0 then
  begin
    F := TfrmGlobalPrintDialog.Create(Self);
    try

      if Preview then
      begin
        F.edNumCopies.Enabled := False;
        F.ActiveControl := F.btnOK;
      end;

			if F.ShowModal = mrOK then
      begin
        Screen.Cursor := crHourGlass;
        try
					if gpWrap then
            ppPrinter.WordWrap := True
          else
            ppPrinter.WordWrap := False;

          ppPrinter.Title := Title;

          ppPrinter.Orientation := Printer.Orientation;

          ppPrinter.MarginLeft := gpLeftMargin;
          ppPrinter.MarginTop := gpTopMargin;
          ppPrinter.MarginRight := gpRightMargin;
          ppPrinter.MarginBottom := gpBottomMargin;

          try
            ppPrinter.BeginDoc;

            for Idx := 0 to Lines.Count - 1 do
            begin
              ppPrinter.WriteLine(Lines[Idx]);
            end;

            ppPrinter.EndDoc;

          finally
            Screen.Cursor := crDefault;
          end;

					if Preview then
          begin
            PP := TfrmPrintPreview.Create(nil);
            PP.PrintObject := Self;
            pnlBase.Parent := PP.pnlParent;
            PP.Show;
          end
					else
          begin
            //now print to the printer...
            ppPrinter.Print;
					end;
        finally
          Screen.Cursor := crDefault;
        end;
      end;
    finally
      F.Free;
    end;
  end;
end;

procedure TfrmGlobalPrintingRoutines.PrintSyntaxMemo(TSM: TSyntaxMemoWithStuff2; Preview: Boolean; Title : String);
begin
	PrintLines(TSM.Lines, Preview, Title);
end;

function TfrmGlobalPrintingRoutines.CanFirst: Boolean;
begin
	Result := ppPrinter.PageNumber > 1;
end;

function TfrmGlobalPrintingRoutines.CanLast: Boolean;
begin
	Result := ppPrinter.PageNumber < ppPrinter.PageCount;
end;

function TfrmGlobalPrintingRoutines.CanNext: Boolean;
begin
	Result := ppPrinter.PageNumber < ppPrinter.PageCount;
end;

function TfrmGlobalPrintingRoutines.CanPrint: Boolean;
begin
	Result := False;
end;

function TfrmGlobalPrintingRoutines.CanPrior: Boolean;
begin
  Result := ppPrinter.PageNumber > 1;
end;

procedure TfrmGlobalPrintingRoutines.DoFirst;
begin
  ppPrinter.PageNumber := 1
end;

procedure TfrmGlobalPrintingRoutines.DoLast;
begin
	ppPrinter.PageNumber := ppPrinter.PageCount;
end;

procedure TfrmGlobalPrintingRoutines.DoNext;
begin
	if ppPrinter.PageNumber + 1 <= ppPrinter.PageCount then
		ppPrinter.PageNumber := ppPrinter.PageNumber + 1;
end;

procedure TfrmGlobalPrintingRoutines.DoPrint;
begin

end;

procedure TfrmGlobalPrintingRoutines.DoPrior;
begin
	if ppPrinter.PageNumber - 1 > 0 then
		ppPrinter.PageNumber := ppPrinter.PageNumber - 1;
end;

procedure TfrmGlobalPrintingRoutines.PrintPerformanceAnalysis(Preview : Boolean; Query : TStrings; Dataset: TDataSet; Chart: TChart);
var
  PP : TfrmPrintPreview;
	F : TfrmGlobalPrintDialog;
  Idx : Integer;
  OldSize : Integer;

begin
  F := TfrmGlobalPrintDialog.Create(Self);
  try

    if Preview then
    begin
      F.edNumCopies.Enabled := False;
      F.ActiveControl := F.btnOK;
    end;

		if F.ShowModal = mrOK then
    begin
      Screen.Cursor := crHourGlass;
      try
        ppPrinter.WordWrap := True;

        ppPrinter.Title := 'Performance Analysis';

        ppPrinter.Orientation := Printer.Orientation;

        ppPrinter.MarginLeft := gpLeftMargin;
        ppPrinter.MarginTop := gpTopMargin;
        ppPrinter.MarginRight := gpRightMargin;
        ppPrinter.MarginBottom := gpBottomMargin;

        try
          ppPrinter.BeginDoc;

          OldSize := ppPrinter.Font.Size;
          ppPrinter.Font.Size := 16;
          ppPrinter.Font.Style := [fsBold];
					ppPrinter.WriteLineAligned(taCenter, 'Performance Analysis');
					ppPrinter.Font.Size := OldSize;
          ppPrinter.WriteLine('');
          ppPrinter.WriteLine('Query');
          ppPrinter.Font.Style := [];
          ppPrinter.WriteLine('');
          ppPrinter.WriteLine('');
          for Idx := 0 to Query.Count - 1 do
            ppPrinter.WriteLine(Query[Idx]);
          ppPrinter.WriteLine('');
          ppPrinter.WriteLine('');
					ppPrinter.Font.Style := [fsBold];
          ppPrinter.WriteLine('Performance Statistics');
          ppPrinter.WriteLine('');
          ppPrinter.Font.Style := [];
          DataSet.First;
          while not DataSet.EOF do
          begin
						ppPrinter.WriteLine(Format('%20.20s', [DataSet.FieldByName('item').AsString]) + '   ' + Format('%20s', [DataSet.FieldByName('value').AsString]));
            DataSet.Next;
          end;
          ppPrinter.WriteLine('');
          ppPrinter.WriteLine('');

          if (ppPrinter.CurrentY + 2000) > ppPrinter.PixelHeight then
					begin
            ppPrinter.NewPage;
          end;

          Chart.PrintPartialCanvas(ppPrinter.Canvas, Rect(100, ppPrinter.CurrentY, 4500, ppPrinter.CurrentY + 2000));

          ppPrinter.EndDoc;
        finally
          Screen.Cursor := crDefault;
        end;

        if Preview then
        begin
          PP := TfrmPrintPreview.Create(nil);
					PP.PrintObject := Self;
					pnlBase.Parent := PP.pnlParent;
          PP.Show;
        end
        else
        begin
          //now print to the printer...
          ppPrinter.Print;
        end;
      finally
        Screen.Cursor := crDefault;
			end;
    end;
  finally
    F.Free;
  end;
end;

procedure TfrmGlobalPrintingRoutines.PrintQueryPlan(Preview: Boolean;	Query: TStrings; Plan: String; GPlan: TMetafile);
var
	PP : TfrmPrintPreview;
	F : TfrmGlobalPrintDialog;
	Idx : Integer;
	OldSize : Integer;

begin
	F := TfrmGlobalPrintDialog.Create(Self);
	try

		if Preview then
		begin
      F.edNumCopies.Enabled := False;
      F.ActiveControl := F.btnOK;
    end;

    if F.ShowModal = mrOK then
    begin
      Screen.Cursor := crHourGlass;
      try
				ppPrinter.WordWrap := True;

        ppPrinter.Title := 'Query Plan';

        ppPrinter.Orientation := Printer.Orientation;

        ppPrinter.MarginLeft := gpLeftMargin;
        ppPrinter.MarginTop := gpTopMargin;
        ppPrinter.MarginRight := gpRightMargin;
        ppPrinter.MarginBottom := gpBottomMargin;

				try
          ppPrinter.BeginDoc;

          OldSize := ppPrinter.Font.Size;
          ppPrinter.Font.Size := 16;
          ppPrinter.Font.Style := [fsBold];
          ppPrinter.WriteLineAligned(taCenter, 'Query Plan');
          ppPrinter.Font.Size := OldSize;
          ppPrinter.WriteLine('');
          ppPrinter.WriteLine('Query');
          ppPrinter.Font.Style := [];
          ppPrinter.WriteLine('');
          ppPrinter.WriteLine('');
					for Idx := 0 to Query.Count - 1 do
            ppPrinter.WriteLine(Query[Idx]);
          ppPrinter.WriteLine('');
          ppPrinter.WriteLine('');
          ppPrinter.Font.Style := [fsBold];
          ppPrinter.WriteLine('Plan');
					ppPrinter.WriteLine('');
          ppPrinter.Font.Style := [];
          ppPrinter.WriteLine(Plan);
          ppPrinter.WriteLine('');
          ppPrinter.WriteLine('');

          if (ppPrinter.CurrentY + 3200) > ppPrinter.PixelHeight then
          begin
            ppPrinter.NewPage;
					end;

          ppPrinter.Canvas.StretchDraw(Rect(100, ppPrinter.CurrentY, 4500, ppPrinter.CurrentY + 3200), GPlan);

          ppPrinter.EndDoc;
        finally
          Screen.Cursor := crDefault;
        end;

        if Preview then
        begin
					PP := TfrmPrintPreview.Create(nil);
          PP.PrintObject := Self;
          pnlBase.Parent := PP.pnlParent;
          PP.Show;
        end
        else
        begin
          //now print to the printer...
          ppPrinter.Print;
        end;
      finally
        Screen.Cursor := crDefault;
      end;
		end;
  finally
    F.Free;
  end;
end;

procedure TfrmGlobalPrintingRoutines.PrintLinesWithTitle(Lines: TStrings;	PageTitle: String; Preview: Boolean; Title: String);
var
	PP : TfrmPrintPreview;
	F : TfrmGlobalPrintDialog;
  Idx : Integer;
  OldSize : Integer;

begin
  if Lines.Count > 0 then
	begin
		F := TfrmGlobalPrintDialog.Create(Self);
    try

      if Preview then
      begin
        F.edNumCopies.Enabled := False;
        F.ActiveControl := F.btnOK;
      end;

      if F.ShowModal = mrOK then
			begin
        Screen.Cursor := crHourGlass;
        try
          if gpWrap then
            ppPrinter.WordWrap := True
          else
            ppPrinter.WordWrap := False;

          ppPrinter.Title := Title;

          ppPrinter.Orientation := Printer.Orientation;

					ppPrinter.MarginLeft := gpLeftMargin;
          ppPrinter.MarginTop := gpTopMargin;
          ppPrinter.MarginRight := gpRightMargin;
          ppPrinter.MarginBottom := gpBottomMargin;

          try
            ppPrinter.BeginDoc;

            OldSize := ppPrinter.Font.Size;
            ppPrinter.Font.Size := 16;
						ppPrinter.Font.Style := [fsBold];
            ppPrinter.WriteLineAligned(taCenter, PageTitle);
            ppPrinter.Font.Size := OldSize;
            ppPrinter.Font.Style := [];
            ppPrinter.WriteLine('');

						for Idx := 0 to Lines.Count - 1 do
						begin
              ppPrinter.WriteLine(Lines[Idx]);
            end;

            ppPrinter.EndDoc;

          finally
            Screen.Cursor := crDefault;
          end;

					if Preview then
          begin
            PP := TfrmPrintPreview.Create(nil);
            PP.PrintObject := Self;
            pnlBase.Parent := PP.pnlParent;
            PP.Show;
          end
          else
          begin
            //now print to the printer...
            ppPrinter.Print;
          end;
				finally
          Screen.Cursor := crDefault;
        end;
			end;
		finally
			F.Free;
		end;
	end;
end;

procedure TfrmGlobalPrintingRoutines.SetipObjectsList(Value: boolean);
begin
  FipObjectsList := Value;
  ipObjectsListHeader := false;
end;

procedure TfrmGlobalPrintingRoutines.qryUtilPrepare;
begin
  qryUtil.IB_Connection := MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[ipConnectionName].Connection;
  qryUtil.IB_Transaction := MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[ipConnectionName].Transaction;

  if qryUtil.IB_Transaction.Started then
    qryUtil.IB_Transaction.Commit;
  qryUtil.IB_Transaction.StartTransaction;
end;

procedure TfrmGlobalPrintingRoutines.qryUtilOpen(sql: string);
begin
  qryUtil.SQL.Text := sql;
	qryUtil.Open;
end;

procedure TfrmGlobalPrintingRoutines.qryUtilOpen(opt: TfrmGlobalPrintDialogOption; ObjectName: string; FPO: TfrmGlobalPrintDialogOptions);
begin
  if Length(ObjectName) = 0 then
  begin
    case opt of
      opDomain:     ipObjectsList := (FPO*
          [opDomainDetail]) = [];
      opTable:      ipObjectsList := (FPO*
          [opTableStructure, opTableConstraints, opTableIndexes,
           opTableDependencies, opTableTriggerSummary, opTableTriggerDetail,
           opTableDocumentation]) = [];
      opView:       ipObjectsList := (FPO*
          [opViewDocumentation, opViewStructure, opViewDependencies,
           opViewTriggerSummary, opViewTriggerDetail,
           opViewSource]) = [];
      opSP:         ipObjectsList := (FPO*
          [opSPDocumentation, opSPCode]) = [];
      opTrigger:    ipObjectsList := (FPO*
          [opTriggerDocumentation, opTriggerCode]) = [];
      opGenerator:  ipObjectsList := (FPO*
          [opGeneratorDetail]) = [];
      opException:  ipObjectsList := (FPO*
          [opExceptionDocumentation, opExceptionException]) = [];
      opUDF:        ipObjectsList := (FPO*
          [opUDFDocumentation, opUDFUDF]) = [];
    end;
    case opt of
      opDomain:     qryUtilOpen('select * from rdb$fields where ((rdb$system_flag = 0) or (rdb$system_flag is null)) and rdb$field_name not starting with ''RDB$'' order by rdb$field_name');
      opTable:      qryUtilOpen('select * from rdb$relations where ((rdb$system_flag = 0) or (rdb$system_flag is null)) order by rdb$relation_name asc;');
      opView:       qryUtilOpen('select * from rdb$relations where ((rdb$system_flag = 0) or (rdb$system_flag is null)) and rdb$view_source is not null order by rdb$relation_name asc;');
      opSP:         qryUtilOpen('select * from rdb$procedures where ((rdb$system_flag = 0) or (rdb$system_flag is null)) order by rdb$procedure_name asc;');
      opTrigger:    qryUtilOpen('select * from rdb$triggers where ((rdb$system_flag = 0) or (rdb$system_flag is null)) and rdb$trigger_name not in (select rdb$trigger_name from rdb$check_constraints) order by rdb$trigger_name asc;');
      opGenerator:  qryUtilOpen('select rdb$generator_name from rdb$generators where ((rdb$system_flag = 0) or (rdb$system_flag is null)) order by rdb$generator_name asc;');
      opException:  qryUtilOpen('select * from rdb$exceptions where ((rdb$system_flag = 0) or (rdb$system_flag is null)) order by rdb$exception_name asc;');
      opUDF:        qryUtilOpen('select * from rdb$functions where ((rdb$system_flag = 0) or (rdb$system_flag is null)) order by rdb$function_name asc;');
    end;
  end
  else
  begin
    ipObjectsList := false;
    case opt of
      opDomain:     qryUtilOpen('select * from rdb$fields where rdb$field_name = ' + AnsiQuotedStr(ObjectName, ''''));
      opTable:      qryUtilOpen('select * from rdb$relations where rdb$relation_name = ' + AnsiQuotedStr(ObjectName, ''''));
      opView:       qryUtilOpen('select * from rdb$relations where rdb$relation_name = ' + AnsiQuotedStr(ObjectName, ''''));
      opSP:         qryUtilOpen('select * from rdb$procedures where rdb$procedure_name = ' + AnsiQuotedStr(ObjectName, ''''));
      opTrigger:    qryUtilOpen('select * from rdb$triggers where rdb$trigger_name = ' + AnsiQuotedStr(ObjectName, ''''));
      opGenerator:  qryUtilOpen('select rdb$generator_name, gen_id('+ObjectName+', 0) value from rdb$generators where rdb$generator_name = ' + AnsiQuotedStr(ObjectName, ''''));
      opException:  qryUtilOpen('select * from rdb$exceptions where rdb$exception_name = ' + AnsiQuotedStr(ObjectName, ''''));
      opUDF:        qryUtilOpen('select * from rdb$functions where rdb$function_name = ' + AnsiQuotedStr(ObjectName, ''''));
    end;
  end;
end;

procedure TfrmGlobalPrintingRoutines.qryUtilClose;
begin
  if qryUtil.Active then
  begin
    qryUtil.Close;
    qryUtil.IB_Transaction.Commit;
  end;
end;

procedure TfrmGlobalPrintingRoutines.PrintGeneral(
  Preview: Boolean;
  ReportTitle: string;
  ObjectType: string;
  ObjectName: string;
  ConnectionName: String
);
var
	PP : TfrmPrintPreview;
	F : TfrmGlobalPrintDialog;
  FR : integer;
  FPO : TfrmGlobalPrintDialogOptions;

begin
  // get options for print
	F := TfrmGlobalPrintDialog.Create(Self);
//  FR := mrCancel;
	try
    F.SetDlgType(ObjectType, Preview);
    FR := F.ShowModal;
    FPO := F.GetOptions;
  finally
    F.Free;
  end;
  // create report
  if FR = mrOk then
  begin
    Screen.Cursor := crHourGlass;
    ipPrn := ppPrinter;
    ipObjectName := ObjectName;
    ipConnectionName := ConnectionName;
    try
      ppPrinter.WordWrap := True;

      ppPrinter.Title := ReportTitle;

      ppPrinter.Orientation := Printer.Orientation;

      ppPrinter.MarginLeft := gpLeftMargin;
      ppPrinter.MarginTop := gpTopMargin;
      ppPrinter.MarginRight := gpRightMargin;
      ppPrinter.MarginBottom := gpBottomMargin;

      ppPrinter.FooterFormat := '>'+FloatToStr(ppPrinter.PrintableWidth);
      ppPrinter.FooterFont.Name := 'MS Sans Serif';
      ppPrinter.FooterFont.Size := 8;
      ppPrinter.BeginDoc;

      qryUtilPrepare;

      if opDomain in FPO then
      begin
        qryUtilOpen(opDomain, ObjectName, FPO);
        while not qryUtil.Eof do
        begin
          ipObjectName := qryUtil.FieldByName('rdb$field_name').AsString;
          InternalPrintDomain;
          if opDomainDetail        in FPO then InternalPrintDomainDetail;
          IPProcObjectFooter;
          qryUtil.Next;
        end;
      end;
      IPProcObjectSeparator(FPO);

      if opTable in FPO then
      begin
        qryUtilOpen(opTable, ObjectName, FPO);
        while not qryUtil.Eof do
        begin
          ipObjectName := qryUtil.FieldByName('rdb$relation_name').AsString;
          InternalPrintTable;
          if opTableDocumentation  in FPO then InternalPrintObjectDescription;
          if opTableStructure      in FPO then InternalPrintTableStructure;
          if opTableConstraints    in FPO then InternalPrintTableConstraints;
          if opTableIndexes        in FPO then InternalPrintTableIndexes;
          if opTableTriggerSummary in FPO then InternalPrintTableTriggers(opTableTriggerDetail in FPO);
          if opTableDependencies   in FPO then InternalPrintObjectDependencies;
          IPProcObjectFooter;
          qryUtil.Next;
        end;
      end;
      IPProcObjectSeparator(FPO);

      if opView in FPO then
      begin
        qryUtilOpen(opView, ObjectName, FPO);
        while not qryUtil.Eof do
        begin
          ipObjectName := qryUtil.FieldByName('rdb$relation_name').AsString;
          InternalPrintView;
          if opViewDocumentation  in FPO then InternalPrintObjectDescription;
          if opViewStructure      in FPO then InternalPrintViewStruct;
          if opViewDependencies   in FPO then InternalPrintObjectDependencies;
          if opViewTriggerSummary in FPO then InternalPrintViewTriggers(opViewTriggerDetail in FPO);
          if opViewSource         in FPO then InternalPrintViewSource;
          IPProcObjectFooter;
          qryUtil.Next;
        end;
      end;
      IPProcObjectSeparator(FPO);

      if opSP in FPO then
      begin
        qryUtilOpen(opSP, ObjectName, FPO);
        while not qryUtil.Eof do
        begin
          ipObjectName := qryUtil.FieldByName('rdb$procedure_name').AsString;
          InternalPrintSP;
          if opSPDocumentation    in FPO then InternalPrintObjectDescription;
          if opSPCode             in FPO then InternalPrintSPCode;
          IPProcObjectFooter;
          qryUtil.Next;
        end;
      end;
      IPProcObjectSeparator(FPO);

      if opTrigger in FPO then
      begin
        qryUtilOpen(opTrigger, ObjectName, FPO);
        while not qryUtil.Eof do
        begin
          ipObjectName := qryUtil.FieldByName('rdb$trigger_name').AsString;
          InternalPrintTrigger;
          if opTriggerDocumentation in FPO then InternalPrintObjectDescription;
          if opTriggerCode          in FPO then InternalPrintTriggerCode;
          IPProcObjectFooter;
          qryUtil.Next;
        end;
      end;
      IPProcObjectSeparator(FPO);

      if opGenerator in FPO then
      begin
        qryUtilOpen(opGenerator, ObjectName, FPO);
        while not qryUtil.Eof do
        begin
          ipObjectName := qryUtil.FieldByName('rdb$generator_name').AsString;
          InternalPrintGenerator;
          if opGeneratorDetail        in FPO then InternalPrintGeneratorDetail;
          IPProcObjectFooter;
          qryUtil.Next;
        end;
      end;
      IPProcObjectSeparator(FPO);

      if opException in FPO then
      begin
        qryUtilOpen(opException, ObjectName, FPO);
        while not qryUtil.Eof do
        begin
          ipObjectName := qryUtil.FieldByName('rdb$exception_name').AsString;
          InternalPrintException;
          if opExceptionDocumentation in FPO then InternalPrintObjectDescription;
          if opExceptionException     in FPO then InternalPrintExceptionException;
          IPProcObjectFooter;
          qryUtil.Next;
        end;
      end;
      IPProcObjectSeparator(FPO);

      if opUDF in FPO then
      begin
        qryUtilOpen(opUDF, ObjectName, FPO);
        while not qryUtil.Eof do
        begin
          ipObjectName := qryUtil.FieldByName('rdb$function_name').AsString;
          InternalPrintUDF;
          if opUDFDocumentation   in FPO then InternalPrintObjectDescription;
          if opUDFUDF             in FPO then InternalPrintUDFUDF;
          IPProcObjectFooter;
          qryUtil.Next;
        end;
      end;
      IPProcObjectSeparator(FPO);

      if opDependencies in FPO then
      begin
        InternalPrintObjectDependencies;
      end;
      qryUtilClose;

      ppPrinter.EndDoc;
      Screen.Cursor := crDefault;

  		if Preview then
      begin
        PP := TfrmPrintPreview.Create(nil);
        PP.PrintObject := Self;
        pnlBase.Parent := PP.pnlParent;
        PP.Show;
      end
      else
      begin
        //now print to the printer...
        ppPrinter.Print;
      end;
    finally
      Screen.Cursor := crDefault;
    end;
  end;
end;

procedure TfrmGlobalPrintingRoutines.PrintDomain(Preview: Boolean; ObjectName, ConnectionName: String);
begin
  PrintGeneral(Preview, 'Domain : ' + ObjectName, 'DOMAIN', ObjectName, ConnectionName);
end;

procedure TfrmGlobalPrintingRoutines.PrintException(Preview: Boolean; ObjectName, ConnectionName: String);
begin
  PrintGeneral(Preview, 'Exception : ' + ObjectName, 'EXCEPTION', ObjectName, ConnectionName);
end;

procedure TfrmGlobalPrintingRoutines.PrintGenerator(Preview: Boolean;	ObjectName, ConnectionName: String);
begin
  PrintGeneral(Preview, 'Generator : ' + ObjectName, 'GENERATOR', ObjectName, ConnectionName);
end;

procedure TfrmGlobalPrintingRoutines.PrintSP(Preview: Boolean; ObjectName, ConnectionName: String);
begin
  PrintGeneral(Preview, 'Stored Procedure : ' + ObjectName, 'SP', ObjectName, ConnectionName);
end;

procedure TfrmGlobalPrintingRoutines.PrintTable(Preview: Boolean;	ObjectName, ConnectionName: String);
begin
  PrintGeneral(Preview, 'Table: '+ObjectName, 'TABLE', ObjectName, ConnectionName);
end;

procedure TfrmGlobalPrintingRoutines.PrintTableConstraints(Preview: Boolean; ObjectName, ConnectionName: String);
begin
  PrintGeneral(Preview, 'Table: '+ObjectName, 'TABLE_CONSTRAINTS', ObjectName, ConnectionName);
end;

procedure TfrmGlobalPrintingRoutines.PrintTableIndexes(Preview: Boolean; ObjectName, ConnectionName: String);
begin
  PrintGeneral(Preview, 'Table: '+ObjectName, 'TABLE_INDEXES', ObjectName, ConnectionName);
end;

procedure TfrmGlobalPrintingRoutines.PrintTableTriggers(Preview: Boolean; ObjectName, ConnectionName: String);
begin
  PrintGeneral(Preview, 'Table: '+ObjectName, 'TABLE_TRIGGERS', ObjectName, ConnectionName);
end;

procedure TfrmGlobalPrintingRoutines.PrintTrigger(Preview: Boolean; ObjectName, ConnectionName: String);
begin
  PrintGeneral(Preview, 'Trigger: '+ObjectName, 'TRIGGER', ObjectName, ConnectionName);
end;

procedure TfrmGlobalPrintingRoutines.PrintUDF(Preview: Boolean; ObjectName,	ConnectionName: String);
begin
  PrintGeneral(Preview, 'User Defined Function: '+ObjectName, 'UDF', ObjectName, ConnectionName);
end;

procedure TfrmGlobalPrintingRoutines.PrintView(Preview: Boolean; ObjectName, ConnectionName: String);
begin
  PrintGeneral(Preview, 'View: '+ObjectName, 'VIEW', ObjectName, ConnectionName);
end;

procedure TfrmGlobalPrintingRoutines.PrintViewStruct(Preview: Boolean; ObjectName, ConnectionName: String);
begin
  PrintGeneral(Preview, 'View: '+ObjectName, 'VIEW_STRUCT', ObjectName, ConnectionName);
end;

procedure TfrmGlobalPrintingRoutines.PrintViewTriggers(Preview: Boolean; ObjectName, ConnectionName: String);
begin
  PrintGeneral(Preview, 'View: '+ObjectName, 'VIEW_TRIGGERS', ObjectName, ConnectionName);
end;

procedure TfrmGlobalPrintingRoutines.PrintViewSource(Preview: Boolean; ObjectName, ConnectionName: String);
begin
  PrintGeneral(Preview, 'View: '+ObjectName, 'VIEW_SOURCE', ObjectName, ConnectionName);
end;

procedure TfrmGlobalPrintingRoutines.PrintObjectDependencies(Preview: Boolean; ObjectName, ConnectionName: String);
begin
  PrintGeneral(Preview, 'Dependencies for: '+ObjectName, 'DEPENDENCIES', ObjectName, ConnectionName);
end;

procedure TfrmGlobalPrintingRoutines.PrintTreeList(Preview: Boolean; ObjectList: TList);
var
  PP : TfrmPrintPreview;
  F : TfrmGlobalPrintDialog;

begin
	if ObjectList.Count > 0 then
  begin
    F := TfrmGlobalPrintDialog.Create(Self);
    try
      if Preview then
      begin
        F.edNumCopies.Enabled := False;
        F.ActiveControl := F.btnOK;
      end;
      if F.ShowModal = mrOK then
      begin
        Screen.Cursor := crHourGlass;
        try
					ppPrinter.WordWrap := True;

          ppPrinter.Title := 'Selected Database Objects';

          ppPrinter.Orientation := Printer.Orientation;

          ppPrinter.MarginLeft := gpLeftMargin;
          ppPrinter.MarginTop := gpTopMargin;
          ppPrinter.MarginRight := gpRightMargin;
          ppPrinter.MarginBottom := gpBottomMargin;

          try
            ppPrinter.BeginDoc;

//            InternalPrintObjectDependencies(ppPrinter, ObjectName, ConnectionName);

            ppPrinter.EndDoc;
          finally
            Screen.Cursor := crDefault;
          end;

          if Preview then
          begin
            PP := TfrmPrintPreview.Create(nil);
            PP.PrintObject := Self;
            pnlBase.Parent := PP.pnlParent;
						PP.Show;
					end
					else
					begin
						//now print to the printer...
						ppPrinter.Print;
					end;
				finally
					Screen.Cursor := crDefault;
				end;
			end;
		finally
			F.Free;
		end;
	end;
end;

procedure TfrmGlobalPrintingRoutines.PrintObjectDoco(Preview: Boolean; ObjectName, ConnectionName: String; ObjectType: TGSSCacheType);
var
	PP : TfrmPrintPreview;
	F : TfrmGlobalPrintDialog;

begin
	F := TfrmGlobalPrintDialog.Create(Self);
	try
		if Preview then
		begin
			F.edNumCopies.Enabled := False;
			F.ActiveControl := F.btnOK;
		end;
		if F.ShowModal = mrOK then
		begin
			Screen.Cursor := crHourGlass;
			try
				ppPrinter.WordWrap := True;

        ppPrinter.Title := 'Documentation : ' + ObjectName;

        ppPrinter.Orientation := Printer.Orientation;

        ppPrinter.MarginLeft := gpLeftMargin;
        ppPrinter.MarginTop := gpTopMargin;
        ppPrinter.MarginRight := gpRightMargin;
        ppPrinter.MarginBottom := gpBottomMargin;

        try
          ppPrinter.BeginDoc;

          InternalPrintObjectDoco(ObjectType);

          ppPrinter.EndDoc;
        finally
          Screen.Cursor := crDefault;
        end;

        if Preview then
				begin
					PP := TfrmPrintPreview.Create(nil);
					PP.PrintObject := Self;
					pnlBase.Parent := PP.pnlParent;
					PP.Show;
				end
				else
				begin
					//now print to the printer...
					ppPrinter.Print;
				end;
			finally
				Screen.Cursor := crDefault;
			end;
		end;
	finally
		F.Free;
	end;
end;

procedure TfrmGlobalPrintingRoutines.PrintObjectDRUIMatrix(Preview: Boolean; ObjectName, ConnectionName: String; ObjectType : TGSSCacheType);
var
  PP : TfrmPrintPreview;
  F : TfrmGlobalPrintDialog;

begin
  F := TfrmGlobalPrintDialog.Create(Self);
  try
    if Preview then
    begin
      F.edNumCopies.Enabled := False;
      F.ActiveControl := F.btnOK;
    end;
    if F.ShowModal = mrOK then
    begin
      Screen.Cursor := crHourGlass;
      try
        ppPrinter.WordWrap := True;

        ppPrinter.Title := 'DRUI Matrix : ' + ObjectName;

        ppPrinter.Orientation := Printer.Orientation;

        ppPrinter.MarginLeft := gpLeftMargin;
        ppPrinter.MarginTop := gpTopMargin;
        ppPrinter.MarginRight := gpRightMargin;
        ppPrinter.MarginBottom := gpBottomMargin;

        try
          ppPrinter.BeginDoc;

          InternalPrintObjectDRUIMatrix(ObjectType);

          ppPrinter.EndDoc;
				finally
          Screen.Cursor := crDefault;
        end;

        if Preview then
				begin
          PP := TfrmPrintPreview.Create(nil);
          PP.PrintObject := Self;
          pnlBase.Parent := PP.pnlParent;
          PP.Show;
        end
        else
        begin
          //now print to the printer...
          ppPrinter.Print;
        end;
      finally
        Screen.Cursor := crDefault;
      end;
    end;
  finally
    F.Free;
  end;
end;

procedure TfrmGlobalPrintingRoutines.PrintObjectDDL(Preview: Boolean;	ObjectName, ConnectionName: String; ObjectType: TGSSCacheType);
var
	PP : TfrmPrintPreview;
	F : TfrmGlobalPrintDialog;

begin
	F := TfrmGlobalPrintDialog.Create(Self);
	try
		if Preview then
		begin
			F.edNumCopies.Enabled := False;
			F.ActiveControl := F.btnOK;
		end;
		if F.ShowModal = mrOK then
		begin
			Screen.Cursor := crHourGlass;
			try
				ppPrinter.WordWrap := True;

        ppPrinter.Title := 'Metadata : ' + ObjectName;

        ppPrinter.Orientation := Printer.Orientation;

        ppPrinter.MarginLeft := gpLeftMargin;
        ppPrinter.MarginTop := gpTopMargin;
        ppPrinter.MarginRight := gpRightMargin;
        ppPrinter.MarginBottom := gpBottomMargin;

        try
          ppPrinter.BeginDoc;

          InternalPrintObjectDDL(ObjectType);

          ppPrinter.EndDoc;
        finally
          Screen.Cursor := crDefault;
        end;

        if Preview then
				begin
					PP := TfrmPrintPreview.Create(nil);
					PP.PrintObject := Self;
					pnlBase.Parent := PP.pnlParent;
					PP.Show;
				end
				else
				begin
					//now print to the printer...
					ppPrinter.Print;
				end;
			finally
				Screen.Cursor := crDefault;
			end;
		end;
	finally
		F.Free;
	end;
end;

procedure TfrmGlobalPrintingRoutines.PrintObjectPerms(Preview: Boolean; ObjectName, ConnectionName: String; ObjectType: TGSSCacheType);
var
  PP : TfrmPrintPreview;
  F : TfrmGlobalPrintDialog;

begin
  F := TfrmGlobalPrintDialog.Create(Self);
  try
    if Preview then
    begin
      F.edNumCopies.Enabled := False;
      F.ActiveControl := F.btnOK;
    end;
    if F.ShowModal = mrOK then
    begin
      Screen.Cursor := crHourGlass;
      try
        ppPrinter.WordWrap := True;

        ppPrinter.Title := 'Permissions : ' + ObjectName;

        ppPrinter.Orientation := Printer.Orientation;

        ppPrinter.MarginLeft := gpLeftMargin;
        ppPrinter.MarginTop := gpTopMargin;
        ppPrinter.MarginRight := gpRightMargin;
        ppPrinter.MarginBottom := gpBottomMargin;

        try
          ppPrinter.BeginDoc;

          InternalPrintObjectPerms(ObjectType);

					ppPrinter.EndDoc;
        finally
          Screen.Cursor := crDefault;
        end;

        if Preview then
				begin
          PP := TfrmPrintPreview.Create(nil);
          PP.PrintObject := Self;
          pnlBase.Parent := PP.pnlParent;
          PP.Show;
        end
        else
        begin
          //now print to the printer...
          ppPrinter.Print;
        end;
      finally
        Screen.Cursor := crDefault;
      end;
    end;
  finally
    F.Free;
  end;
end;

//-----------------------------------------------------------------
// private
function TfrmGlobalPrintingRoutines.getBoolValueText(b: boolean): string;
begin
  if b then Result := 'True'
  else Result := 'False';
end;

function TfrmGlobalPrintingRoutines.getDataType: string;
begin
  if MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[ipConnectionName].IsIB6 and (MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[ipConnectionName].SQLDialect = 3) then
  begin
    Result := ConvertFieldType(
      qryUtil.FieldByName('rdb$field_type').AsInteger,
      qryUtil.FieldByName('rdb$field_length').AsInteger,
      qryUtil.FieldByName('rdb$field_scale').AsInteger,
      qryUtil.FieldByName('rdb$field_sub_type').AsInteger,
      qryUtil.FieldByName('rdb$field_precision').AsInteger,
      True,
      3);
  end
  else
  begin
    Result := ConvertFieldType(
      qryUtil.FieldByName('rdb$field_type').AsInteger,
      qryUtil.FieldByName('rdb$field_length').AsInteger,
      qryUtil.FieldByName('rdb$field_scale').AsInteger,
      -1,
      -1,
      False,
      1);
  end;
end;

function TfrmGlobalPrintingRoutines.getFieldStr(FieldName: string; Len: integer): string;
var
  f: TField;
begin
  f := qryUtil.FindField(FieldName);
  if f = nil then
  begin
    Result := getFillStr('', Len);
  end
  else
  begin
    Result := getFillStr(f.AsString, Len);
  end;
end;

function TfrmGlobalPrintingRoutines.getFillStr(S: string; Len: integer): string;
var
  i: integer;
begin
  i := Length(S);
  if i > Len then
  begin
    Result := Copy(S, 1, Len);
  end
  else
  begin
    while i < Len do
    begin
      S := S+' ';
      Inc(i);
    end;
    Result := S;
  end;
end;

function TfrmGlobalPrintingRoutines.getNullFlagStr(FieldName: string): string;
begin
  if (qryUtil.FieldByName(FieldName).IsNull) or (qryUtil.FieldByName(FieldName).AsInteger = 0) then
  begin
    Result := '    Null';
  end
  else
  begin
    Result := 'Not Null';
  end;
end;

procedure TfrmGlobalPrintingRoutines.InternalPrintDomain;
begin
  IPProcPageHeader;
  IPProcObjectHeader('Domain');
end;

procedure TfrmGlobalPrintingRoutines.InternalPrintDomainDetail;
begin

  InternalPrintObjectDescription;

  IPProcHeaderLine('Datatype');
  IPProcStandartFont;
  IPProcLine(GetDataType);

  IPProcHeaderLine('Default');
  IPProcStandartFont;
  IPProcLine(qryUtil.FieldByName('rdb$default_source').AsString);

  IPProcHeaderLine('Constraints');
  IPProcStandartFont;
  IPProcLineValueBool('Nullable : ', qryUtil.FieldByName('rdb$null_flag').IsNull);
  IPProcLine(qryUtil.FieldByName('rdb$validation_source').AsString);

end;

procedure TfrmGlobalPrintingRoutines.InternalPrintException;
begin
	IPProcPageHeader;
  IPProcObjectHeader('Exception');
end;

procedure TfrmGlobalPrintingRoutines.InternalPrintExceptionException;
begin
  IPProcHeaderLine('Message');
	ipPrn.WriteLine(qryUtil.FieldByName('rdb$message').AsString);
end;

procedure TfrmGlobalPrintingRoutines.InternalPrintGenerator;
begin
  IPProcPageHeader;
  IPProcObjectHeader('Generator');
end;

procedure TfrmGlobalPrintingRoutines.InternalPrintGeneratorDetail;
begin
  if qryUtil.FindField('value') <> nil then
  begin
    IPProcLine('Value : '+qryUtil.FieldByName('value').AsString);
  end;
end;

procedure TfrmGlobalPrintingRoutines.InternalPrintObjectDDL(ObjectType: TGSSCacheType);
begin

end;

procedure TfrmGlobalPrintingRoutines.InternalPrintObjectDependencies;
begin

end;

procedure TfrmGlobalPrintingRoutines.InternalPrintObjectDoco(ObjectType: TGSSCacheType);
begin

end;

procedure TfrmGlobalPrintingRoutines.InternalPrintObjectDRUIMatrix(ObjectType: TGSSCacheType);
begin

end;

procedure TfrmGlobalPrintingRoutines.InternalPrintObjectPerms(ObjectType: TGSSCacheType);
begin

end;

procedure TfrmGlobalPrintingRoutines.InternalPrintSP;
begin
  IPProcPageHeader;
  IPProcObjectHeader('Stored Procedure');
end;

procedure TfrmGlobalPrintingRoutines.InternalPrintTable;
begin
  IPProcPageHeader;
  IPProcObjectHeader('Table');
end;

procedure TfrmGlobalPrintingRoutines.InternalPrintTableStructure;
var
  q: TIBOQuery;
  s: string;
begin
  IPProcHeaderLine('Table Structure');
  q := qryUtil;
  try
    qryUtil := TIBOQuery.Create(nil);
    qryUtilPrepare;
    qryUtilOpen(GetQueryText('TABLE', ipObjectName));

    IPProcStandartFont([fsBold]);
    if not qryUtil.Eof then
    begin
      s := s+getFillStr('Field Name', 30);
      s := s+getFillStr('Data Type', 20);
      s := s+getFillStr('Null?', 9);
      IPProcLine(s);
    end;
    ipPrn.Font.Style := [];
    while not qryUtil.Eof do begin
      s := '';
      s := s+getFieldStr('rdb$field_name', 30);
      s := s+getFillStr(getDataType, 20);
      s := s+getNullFlagStr('tnull_flag');
      IPProcLine(s);
      qryUtil.Next;
    end;

    qryUtilClose;
  finally
    qryUtil.Free;
    qryUtil := q;
  end;
end;

procedure TfrmGlobalPrintingRoutines.InternalPrintTableConstraints;
var
  q: TIBOQuery;
  qq: TIBOQuery;
  s: string;
  s1: string;
  s2: string;
  s3: string;
  l0: TStringList;
  l1: TStringList;
  l1max: integer;
  l2: TStringList;
  l2max: integer;
  l3: TStringList;
  l3max: integer;
  l4: TStringList;
  l4max: integer;
  i: integer;
begin
  IPProcHeaderLine('Table Constraints');
  q := qryUtil;
  try

    qq := TIBOQuery.Create(nil);
		qq.IB_Connection := qryUtil.IB_Connection;

    qryUtil := TIBOQuery.Create(nil);
    qryUtilPrepare;

    l0 := TStringList.Create;
    l1 := TStringList.Create;
    l2 := TStringList.Create;
    l3 := TStringList.Create;
    l4 := TStringList.Create;

    qryUtilOpen(GetQueryText('CONSTRAINTS_REF', ipObjectName));

    l1max := 0;
    l2max := 0;
    l3max := 0;
    l4max := 0;

    if not qryUtil.Eof then
    begin
      s := getFillStr('Name', 30)+getFillStr('Type', 12);
      l0.Add(s);
      s2 := 'On Field';
      l1.Add(s2);
      l1max := Max(l1max, Length(s2));
      s2 := 'FK Table';
      l2.Add(s2);
      l2max := Max(l2max, Length(s2));
      s2 := 'FK Field';
      l3.Add(s2);
      l3max := Max(l3max, Length(s2));
      s2 := getFillStr('On Update', 10)+getFillStr('On Delete', 10);
      l4.Add(s2);
      l4max := Max(l4max, Length(s2));
    end;

    while not qryUtil.Eof do begin
      s := '';
      s := s+getFieldStr('rdb$constraint_name', 30);
      s := s+getFieldStr('rdb$constraint_type', 12);
      l0.Add(s);
      s1 := qryUtil.FieldByName('rdb$constraint_name').AsString;
      s3 := qryUtil.FieldByName('rdb$index_name').AsString;

      qq.SQL.Add(
        'select * from rdb$index_segments ' +
        ' where rdb$index_name = ''' + s3 + ''' ' +
        ' order by rdb$field_position asc;');
      qq.Open;
      s2 := '';
  		while not qq.EOF do
			begin
				s2 := s2 + qq.FieldByName('rdb$field_name').AsString;
        qq.Next;
				if not qq.EOF then s2 := s2+', ';
			end;
      l1.Add(s2);
      l1max := Max(l1max, Length(s2));

      qq.Close;
      qq.SQL.Clear;

      qq.SQL.Add(
        'select rdb$relation_name ' +
        ' from rdb$indices ' +
        ' where rdb$index_name in ' +
  			'  (select rdb$foreign_key from rdb$indices ' +
        '    where rdb$index_name	= ''' +	s3 + ''');');
      qq.Open;
      s2 := qq.FieldByName('rdb$relation_name').AsString;
      l2.Add(s2);
      l2max := Max(l2max, Length(s2));

      qq.Close;
      qq.SQL.Clear;

  	 	qq.SQL.Add(
        'select * from rdb$index_segments ' +
        ' where rdb$index_name in ' +
  			'  (select rdb$index_name from rdb$indices ' +
        '    where rdb$index_name in ' +
  			'     (select rdb$foreign_key from rdb$indices ' +
        '       where rdb$index_name	= ''' + s3 + ''')) ' +
        ' order by rdb$field_position asc;');
      qq.Open;
      s2 := '';
			while not qq.EOF do
			begin
				s2 := s2 + qq.FieldByName('rdb$field_name').AsString;
        qq.Next;
				if not qq.EOF then s2 := s2+', ';
			end;
      l3.Add(s2);
      l3max := Max(l3max, Length(s2));

      qq.Close;
      qq.SQL.Clear;

			//IB 5.0 Only...
			try
 			 	qq.SQL.Add(
					'select rdb$update_rule, rdb$delete_rule ' +
          ' from rdb$ref_constraints ' +
          ' where rdb$constraint_name = ''' +	s1 + ''';');
        s2 := '';
        qq.Open;
				if not qq.EOF then
 				begin
          s2 := getFieldStr('rdb$update_rule', 10);
          s2 := s2 + getFieldStr('rdb$delete_rule', 10);
					qq.Next;
				end;
        qq.Close;
        qq.SQL.Clear;
			except
			end;
      l4.Add(s2);
      l4max := Max(l4max, Length(s2));

      qryUtil.Next;
    end;

    qryUtilClose;

    for i := 0 to l0.Count-1 do
    begin
      if i = 0 then
      begin
        IPProcStandartFont([fsBold]);
      end
      else
      begin
        IPProcStandartFont;
      end;
      s := '';
      s := s+l0.Strings[i];
      s := s+getFillStr(l1.Strings[i], l1max+1);
      s := s+getFillStr(l2.Strings[i], l2max+1);
      s := s+getFillStr(l3.Strings[i], l3max+1);
      s := s+getFillStr(l4.Strings[i], l4max+1);
      IPProcLine(s);
    end;

    qryUtilOpen(GetQueryText('CONSTRAINTS_CHECK', ipObjectName));

    l0.Clear;
    l1.Clear;
    l2.Clear;
    l3.Clear;
    l4.Clear;

    if not qryUtil.Eof then
    begin
      l0.Add(getFillStr('Name', 30));
      l1.Add('Check Condition');
    end;
    while not qryUtil.Eof do begin
      s := '';
      s := s+getFieldStr('rdb$constraint_name', 30);
      l0.Add(s);
      s1 := qryUtil.FieldByName('rdb$constraint_name').AsString;
      s2 := qryUtil.FieldByName('rdb$constraint_type').AsString;
      s3 := qryUtil.FieldByName('rdb$index_name').AsString;
			qq.SQL.Add(
        'select a.rdb$trigger_source ' +
        ' from ' +
        '  rdb$check_constraints b, ' +
        '  rdb$triggers a ' +
        ' where ' +
        '  a.rdb$trigger_name = b.rdb$trigger_name ' +
        '  and b.rdb$constraint_name = ''' + s1 + ''';');
      qq.Open;
      s2 := qq.FieldByName('rdb$trigger_source').AsString;
      l1.Add(s2);
      l2.Add('');
      l3.Add('');
      l4.Add('');
      qq.Close;
      qq.SQL.Clear;

      qryUtil.Next;
    end;

    qryUtilClose;

    IPProcLine('');
    for i := 0 to l0.Count-1 do
    begin
      if i = 0 then
      begin
        IPProcStandartFont([fsBold]);
      end
      else
      begin
        IPProcStandartFont();
      end;
      s := '';
      s := s+l0.Strings[i];
      s := s+l1.Strings[i];
      IPProcLine(s);
    end;

  finally
    l0.Free;
    l1.Free;
    l2.Free;
    l3.Free;
    l4.Free;
    qq.Free;
    qryUtil.Free;
    qryUtil := q;
  end;
end;

procedure TfrmGlobalPrintingRoutines.InternalPrintTableIndexes;
var
  q: TIBOQuery;
  qq: TIBOQuery;
  s: string;
  s1: string;
  s2: string;
  l0: TStringList;
  l1: TStringList;
  l1max: integer;
  i: integer;
begin
  IPProcHeaderLine('Table Indices');
  q := qryUtil;
  try

    qq := TIBOQuery.Create(nil);
		qq.IB_Connection := qryUtil.IB_Connection;

    qryUtil := TIBOQuery.Create(nil);
    qryUtilPrepare;

    l0 := TStringList.Create;
    l1 := TStringList.Create;

    qryUtilOpen(GetQueryText('INDEX', ipObjectName));

    l1max := 0;

    if not qryUtil.Eof then
    begin
      s := getFillStr('Name', 30) +
           getFillStr('Unique', 7) +
           getFillStr('Ascending', 10) +
           getFillStr('Active', 7);
      l0.Add(s);
      s2 := 'On Field';
      l1.Add(s2);
      l1max := Max(l1max, Length(s2));
    end;

    while not qryUtil.Eof do begin
      s := '';
      s := s+getFieldStr('rdb$index_name', 30);
      s := s+GetFillStr(getBoolValueText(qryUtil.FieldByName('rdb$unique_flag').AsInteger = 1), 7);
      s := s+GetFillStr(getBoolValueText(qryUtil.FieldByName('rdb$index_type').AsInteger = 0), 10);
      s := s+GetFillStr(getBoolValueText(qryUtil.FieldByName('rdb$index_inactive').AsInteger = 1), 7);
      l0.Add(s);
      s1 := qryUtil.FieldByName('rdb$index_name').AsString;

      qq.SQL.Add(
        'select * from rdb$index_segments ' +
        ' where rdb$index_name = ''' + s1 + ''' ' +
        ' order by rdb$field_position asc;');
      qq.Open;
      s2 := '';
  		while not qq.EOF do
			begin
				s2 := s2 + qq.FieldByName('rdb$field_name').AsString;
        qq.Next;
				if not qq.EOF then s2 := s2+', ';
			end;
      l1.Add(s2);
      l1max := Max(l1max, Length(s2));
      qq.Close;
      qq.SQL.Clear;

      qryUtil.Next;
    end;

    qryUtilClose;

    for i := 0 to l0.Count-1 do
    begin
      if i = 0 then
      begin
        IPProcStandartFont([fsBold]);
      end
      else
      begin
        IPProcStandartFont();
      end;
      s := '';
      s := s+l0.Strings[i];
      s := s+getFillStr(l1.Strings[i], l1max+1);
      IPProcLine(s);
    end;

  finally
    l0.Free;
    l1.Free;
    qq.Free;
    qryUtil.Free;
    qryUtil := q;
  end;
end;

procedure TfrmGlobalPrintingRoutines.InternalPrintTableTriggers(Detail: boolean);
var
  q: TIBOQuery;
  s: string;
begin
  IPProcHeaderLine('Table Triggers');
  q := qryUtil;
  try

    qryUtil := TIBOQuery.Create(nil);
    qryUtilPrepare;

    qryUtilOpen(GetQueryText('TRIGGER', ipObjectName));

    if not qryUtil.Eof and not Detail then
    begin
      s := getFillStr('Type', 15) +
           getFillStr('Name', 30) +
           getFillStr('Sequence', 10);
      IPProcStandartFont([fsBold]);
      IPProcLine(s);
      IPProcStandartFont();
    end;

    while not qryUtil.Eof do begin
      s := '';
      case qryUtil.FieldByName('rdb$trigger_type').AsInteger of
        1: s := 'Before Insert';
        2: s := 'After Insert';
        3: s := 'Before Update';
        4: s := 'After Update';
        5: s := 'Before Delete';
        6: s := 'After Delete';
      end;
      s := GetFillStr(s, 15);
      s := s+GetFieldStr('rdb$trigger_name', 30);
      s := s+GetFieldStr('rdb$trigger_sequence', 10);
      if Detail then
      begin
        ipPrn.Font.Style := [fsBold];
        IPProcLine(s);
        IPProcHR;
        ipPrn.Font.Style := [];
        IPProcLinesFromField(qryUtil.FieldByName('rdb$trigger_source'));
      end
      else
      begin
        IPProcLine(s);
      end;

      qryUtil.Next;
    end;

    qryUtilClose;

  finally
    qryUtil.Free;
    qryUtil := q;
  end;
end;

procedure TfrmGlobalPrintingRoutines.InternalPrintTrigger;
begin
  IPProcPageHeader;
  IPProcObjectHeader('Trigger');
end;

procedure TfrmGlobalPrintingRoutines.InternalPrintUDF;
begin
  IPProcPageHeader;
  IPProcObjectHeader('User Defined Function');
end;

procedure TfrmGlobalPrintingRoutines.InternalPrintView;
begin
  IPProcPageHeader;
  IPProcObjectHeader('View');
end;

procedure TfrmGlobalPrintingRoutines.InternalPrintViewStruct;
var
  q: TIBOQuery;
  s: string;
begin
  IPProcHeaderLine('View Structure');
  q := qryUtil;
  try
    qryUtil := TIBOQuery.Create(nil);
    qryUtilPrepare;
    qryUtilOpen(GetQueryText('TABLE', ipObjectName));

    IPProcStandartFont([fsBold]);
    if not qryUtil.Eof then
    begin
      s := s+getFillStr('Field Name', 30);
      s := s+getFillStr('Data Type', 20);
      s := s+getFillStr('Null?', 9);
      IPProcLine(s);
    end;
    ipPrn.Font.Style := [];
    while not qryUtil.Eof do begin
      s := '';
      s := s+getFieldStr('rdb$field_name', 30);
      s := s+getFillStr(getDataType, 20);
      s := s+getNullFlagStr('tnull_flag');
      IPProcLine(s);
      qryUtil.Next;
    end;

    qryUtilClose;
  finally
    qryUtil.Free;
    qryUtil := q;
  end;
end;

procedure TfrmGlobalPrintingRoutines.InternalPrintViewTriggers;
var
  q: TIBOQuery;
  s: string;
begin
  IPProcHeaderLine('View Triggers');
  q := qryUtil;
  try

    qryUtil := TIBOQuery.Create(nil);
    qryUtilPrepare;

    qryUtilOpen(GetQueryText('TRIGGER', ipObjectName));

    if not qryUtil.Eof and not Detail then
    begin
      s := getFillStr('Type', 15) +
           getFillStr('Name', 30) +
           getFillStr('Sequence', 10);
      IPProcStandartFont([fsBold]);
      IPProcLine(s);
      IPProcStandartFont();
    end;

    while not qryUtil.Eof do begin
      s := '';
      case qryUtil.FieldByName('rdb$trigger_type').AsInteger of
        1: s := 'Before Insert';
        2: s := 'After Insert';
        3: s := 'Before Update';
        4: s := 'After Update';
        5: s := 'Before Delete';
        6: s := 'After Delete';
      end;
      s := GetFillStr(s, 15);
      s := s+GetFieldStr('rdb$trigger_name', 30);
      s := s+GetFieldStr('rdb$trigger_sequence', 10);
      if Detail then
      begin
        ipPrn.Font.Style := [fsBold];
        IPProcLine(s);
        IPProcHR;
        ipPrn.Font.Style := [];
        IPProcLinesFromField(qryUtil.FieldByName('rdb$trigger_source'));
      end
      else
      begin
        IPProcLine(s);
      end;

      qryUtil.Next;
    end;

    qryUtilClose;

  finally
    qryUtil.Free;
    qryUtil := q;
  end;
end;

procedure TfrmGlobalPrintingRoutines.InternalPrintTriggerCode;
begin
  IPProcHeaderLine('Source Code');
  IPProcLinesFromField(qryUtil.FieldByName('rdb$trigger_source'));
end;

procedure TfrmGlobalPrintingRoutines.InternalPrintSPCode;
begin
  IPProcHeaderLine('Source Code');
  IPProcLinesFromField(qryUtil.FieldByName('rdb$procedure_source'));
end;

procedure TfrmGlobalPrintingRoutines.InternalPrintViewSource;
begin
  IPProcHeaderLine('View Source');
  IPProcLinesFromField(qryUtil.FieldByName('rdb$view_source'));
end;

procedure TfrmGlobalPrintingRoutines.InternalPrintUDFUDF;
var
  i: integer;
  q: TIBOQuery;
  s: string;
  s1: string;
  l0: TStringList;
begin

  IPProcHeaderLine('Module Name');
  IPProcStandartFont();
  IPProcLine(qryUtil.FieldByName('rdb$module_name').AsString);

  IPProcHeaderLine('Entry Point');
  IPProcStandartFont();
  IPProcLine(qryUtil.FieldByName('rdb$entrypoint').AsString);

  i := qryUtil.FieldByName('rdb$return_argument').AsInteger;

  q := qryUtil;
  try

    qryUtil := TIBOQuery.Create(nil);
    qryUtilPrepare;
    qryUtilOpen(GetQueryText('FUNCTION_ARGUMENTS', ipObjectName));

    l0 := TStringList.Create;

    if not qryUtil.Eof then
    begin
      s := s+getFillStr('Parameter', 30);
      s := s+getFillStr('Calling Mechanism', 20);
      l0.Add(s);
    end;
    ipPrn.Font.Style := [];
    while not qryUtil.Eof do begin
      s := '';
      s := s+getFillStr(getDataType, 30);
      case qryUtil.FieldByName('rdb$mechanism').AsInteger of
        0 : s1 := 'By Value';
        1 : s1 := 'By Reference';
      end;
      s := s+s1;

      if i = qryUtil.FieldByName('rdb$argument_position').AsInteger then
      begin
        IPProcHeaderLine('Returns');
        IPProcStandartFont();
        IPProcLine(s);
      end
      else
      begin
        l0.Add(s);
      end;

      qryUtil.Next;
    end;

    qryUtilClose;

    IPProcHeaderLine('Parameters');

    for i := 0 to l0.Count-1 do
    begin
      if i = 0 then
      begin
        IPProcStandartFont([fsBold]);
      end
      else
      begin
        IPProcStandartFont();
      end;
      IPProcLine(l0.Strings[i]);
    end;

  finally
    l0.Free;
    qryUtil.Free;
    qryUtil := q;
  end;
end;

procedure TfrmGlobalPrintingRoutines.PrintDatabase(Preview: Boolean; ConnectionName: String);
begin
  PrintGeneral(Preview, 'Database : ' + ConnectionName, 'DATABASE', '', ConnectionName);
end;

procedure TfrmGlobalPrintingRoutines.PrintDomains(Preview: Boolean;	ConnectionName: String);
begin
  PrintGeneral(Preview, 'Domains', 'DOMAIN', '', ConnectionName);
end;

procedure TfrmGlobalPrintingRoutines.PrintSPs(Preview: Boolean;	ConnectionName: String);
begin
  PrintGeneral(Preview, 'Stored Procedures', 'SP', '', ConnectionName);
end;

procedure TfrmGlobalPrintingRoutines.PrintExceptions(Preview: Boolean; ConnectionName: String);
begin
  PrintGeneral(Preview, 'Domains', 'EXCEPTION', '', ConnectionName);
end;

procedure TfrmGlobalPrintingRoutines.PrintGenerators(Preview: Boolean; ConnectionName: String);
begin
  PrintGeneral(Preview, 'Generators', 'GENERATOR', '', ConnectionName);
end;

procedure TfrmGlobalPrintingRoutines.PrintTables(Preview: Boolean; ConnectionName: String);
begin
  PrintGeneral(Preview, 'Tables', 'TABLE', '', ConnectionName);
end;

procedure TfrmGlobalPrintingRoutines.PrintTableStruct(Preview: Boolean; ObjectName, ConnectionName: String);
var
  PP : TfrmPrintPreview;
  F : TfrmGlobalPrintDialog;

begin
  F := TfrmGlobalPrintDialog.Create(Self);
  try
    if Preview then
    begin
      F.edNumCopies.Enabled := False;
      F.ActiveControl := F.btnOK;
    end;
    if F.ShowModal = mrOK then
    begin
      ipConnectionName := ConnectionName;
      ipObjectName := ObjectName;
      ipPrn := ppPrinter;
      Screen.Cursor := crHourGlass;
      try
        ppPrinter.WordWrap := True;

        ppPrinter.Title := 'Table : ' + ObjectName;

        ppPrinter.Orientation := Printer.Orientation;

        ppPrinter.MarginLeft := gpLeftMargin;
				ppPrinter.MarginTop := gpTopMargin;
        ppPrinter.MarginRight := gpRightMargin;
        ppPrinter.MarginBottom := gpBottomMargin;

        try
          ppPrinter.BeginDoc;

          qryUtilPrepare;

          qryUtil.SQL.Text := 'select * from rdb$relations where rdb$relation_name = ' + AnsiQuotedStr(ipObjectName, '''');
					qryUtil.Open;
          if not qryUtil.Eof then
            InternalPrintTableStructure;
          qryUtil.Close;
          qryUtil.IB_Transaction.Commit;

          ppPrinter.EndDoc;
        finally
          Screen.Cursor := crDefault;
        end;

        if Preview then
        begin
          PP := TfrmPrintPreview.Create(nil);
          PP.PrintObject := Self;
          pnlBase.Parent := PP.pnlParent;
          PP.Show;
        end
        else
        begin
          //now print to the printer...
          ppPrinter.Print;
        end;
      finally
        Screen.Cursor := crDefault;
			end;
    end;
  finally
    F.Free;
  end;
end;

procedure TfrmGlobalPrintingRoutines.PrintTriggers(Preview: Boolean; ConnectionName: String);
begin
  PrintGeneral(Preview, 'Triggers', 'TRIGGER', '', ConnectionName);
end;

procedure TfrmGlobalPrintingRoutines.PrintUDFs(Preview: Boolean; ConnectionName: String);
begin
  PrintGeneral(Preview, 'User Defined Functions', 'UDF', '', ConnectionName);
end;

procedure TfrmGlobalPrintingRoutines.PrintViews(Preview: Boolean; ConnectionName: String);
begin
  PrintGeneral(Preview, 'Views', 'VIEW', '', ConnectionName);
end;

{procedure TfrmGlobalPrintingRoutines.IPProcPageFooter;
begin

end;}

procedure TfrmGlobalPrintingRoutines.IPProcPageHeader;
begin

end;

procedure TfrmGlobalPrintingRoutines.IPProcHR;
begin
	ipPrn.Line(Point(0, ipPrn.CurrentY), Point(ipPrn.MeasureUnitsToPixelsH(ipPrn.PrintableWidth), ipPrn.CurrentY));
	IPProcLine('');
end;

procedure TfrmGlobalPrintingRoutines.IPProcObjectHeader(ObjectType: string);
begin
  ipPrn.Canvas.Pen.Width := 1;
  ipPrn.Canvas.Pen.Color := clBlack;
  ipPrn.Canvas.Pen.Style := psSolid;
  if ipObjectsList then
  begin
    if not ipObjectsListHeader then
    begin
      ipPrn.Font.Name := 'Arial';
      ipPrn.Font.Size := 14;
      ipPrn.Font.Style := [fsBold];
      IPProcLine(ObjectType);
      ipPrn.Canvas.Pen.Width := 4;
      IPProcHR;
      ipPrn.Canvas.Pen.Width := 1;
      ipObjectsListHeader := true;
    end;
    IPProcStandartFont;
    IPProcLine(ipObjectName);
  end
  else
  begin
    ipPrn.Font.Name := 'Arial';
    ipPrn.Font.Size := 14;
    ipPrn.Font.Style := [fsBold];
    IPProcLine(ObjectType + ' : ' + ipObjectName);
    ipPrn.Font.Size := 10;
    IPProcLine('');
  end;
end;

procedure TfrmGlobalPrintingRoutines.IPProcObjectFooter;
begin
  if ipObjectsList then
  begin
  end
  else
  begin
    ipPrn.Font.Name := 'Arial';
    ipPrn.Font.Size := 14;
    ipPrn.Font.Style := [fsBold];
    IPProcLine('');
  end;
end;

procedure TfrmGlobalPrintingRoutines.IPProcHeaderLine(s: string);
begin
	ipPrn.Font.Style := [fsBold];
	ipPrn.Font.Name := 'Arial';
	ipPrn.Font.Size := 10;
  IPProcLine('');
	IPProcLine(s);
  IPProcHR;
end;

procedure TfrmGlobalPrintingRoutines.InternalPrintObjectDescription;
begin
  IPProcHeaderLine('Description');
  IPProcLinesFromField(qryUtil.FieldByName('rdb$description'));
end;

procedure TfrmGlobalPrintingRoutines.IPProcLinesFromField(f: TField);
var
  L : TStringList;
  I : Integer;
begin
  IPProcStandartFont([fsBold]);
  L := TStringList.Create;
  try
    L.Text := AdjustLineBreaks(f.AsString);
    for I := 0 to L.Count - 1 do
    begin
      IPProcLine(L[I]);
    end;
  except
    on E: Exception do
    begin
    end;
  end;
  IPProcLine('');
  L.Free;
end;

procedure TfrmGlobalPrintingRoutines.IPProcLine(s: string);
begin
  ipPrn.WriteLine(s);
end;

procedure TfrmGlobalPrintingRoutines.IPProcLineValueBool(s: string; b: boolean);
begin
  s := s + getBoolValueText(b);
  IPProcLine(s);
end;

procedure TfrmGlobalPrintingRoutines.IPProcStandartFont(stl: TFontStyles = []);
begin
  ipPrn.Font.Name := 'Courier New';
  ipPrn.Font.Size := 8;
  ipPrn.Font.Style := stl;
end;

procedure TfrmGlobalPrintingRoutines.IPProcNewPage;
begin
  ipPrn.NewPage;
end;

procedure TfrmGlobalPrintingRoutines.IPProcObjectSeparator(FPO: TfrmGlobalPrintDialogOptions);
begin
  if opDatabase in FPO then
  begin
    ipObjectsList := false;
    IPProcObjectFooter;
    if opDatabaseNewPage in FPO then IPProcNewPage;
  end;
end;

procedure TfrmGlobalPrintingRoutines.FormClose(Sender: TObject;	var Action: TCloseAction);
begin
	Action := caFree;
end;

end.

{
$Log: GlobalPrintingRoutines.pas,v $
Revision 1.7  2006/10/22 06:04:28  rjmills
Fixes and Updates for Look and Feel in WinXP

Revision 1.6  2005/05/17 16:52:01  rjmills
Fixes to the general and specific printing routines.
Tables/Table structures.  Havn't tested other objects yet.

Revision 1.5  2005/04/13 16:04:28  rjmills
*** empty log message ***

Revision 1.4  2002/06/06 07:36:43  tmuetze
Added a patch from Pavel Odstrcil: Now most basic print functions (right click in db navigator, print) work.

Revision 1.3  2002/04/29 14:46:11  tmuetze
Converted from TIBGSSDataset to TIBOQuery

Revision 1.2  2002/04/25 07:21:30  tmuetze
New CVS powered comment block

}
