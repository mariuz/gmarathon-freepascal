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

uses {$IFDEF FPC} LCLIntf, LCLType, LMessages, {$ELSE} Windows, Messages, {$ENDIF} SysUtils, Classes, Graphics, Controls, Forms, Dialogs, ExtCtrls, DB, Printers, Registry, TAGraph, SynEdit, SyntaxMemoWithStuff2, IBDatabase, IBQuery, GSSRegistry, MarathonProjectCacheTypes, MarathonProjectCache, GlobalPrintDialog;

type
  { FPC: This port has no replacement for the original PagePrnt/DSprint report-writer
    units, so the whole print/print-preview subsystem is a no-op stub on this platform.
    Public method signatures are kept as-is because many editor forms call them. }
  TfrmGlobalPrintingRoutines = class(TForm)
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    procedure ShowPrintingUnavailable;
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
  MessageDlg('Printing is not available in this build.', mtInformation, [mbOK], 0);
end;

procedure TfrmGlobalPrintingRoutines.PrintDataSetNewPage(Sender: TObject);
begin
end;

procedure TfrmGlobalPrintingRoutines.PrintDataSet(DataSet: TDataSet; Preview: Boolean; Title : String);
begin
  ShowPrintingUnavailable;
end;

procedure TfrmGlobalPrintingRoutines.PrintSyntaxMemo(TSM : TSyntaxMemoWithStuff2; Preview : Boolean; Title : String);
begin
  ShowPrintingUnavailable;
end;

procedure TfrmGlobalPrintingRoutines.PrintLines(Lines : TStrings; Preview : Boolean; Title : String);
begin
  ShowPrintingUnavailable;
end;

procedure TfrmGlobalPrintingRoutines.PrintLinesWithTitle(Lines : TStrings; PageTitle : String; Preview : Boolean; Title : String);
begin
  ShowPrintingUnavailable;
end;

procedure TfrmGlobalPrintingRoutines.PrintPerformanceAnalysis(Preview : Boolean; Query : TStrings; Dataset : TDataSet; Chart : TChart);
begin
  ShowPrintingUnavailable;
end;

{$IFNDEF FPC}
procedure TfrmGlobalPrintingRoutines.PrintQueryPlan(Preview : Boolean; Query : TStrings; Plan : String; GPlan : TMetafile);
begin
  ShowPrintingUnavailable;
end;
{$ENDIF}

procedure TfrmGlobalPrintingRoutines.PrintGeneral(Preview: Boolean; ReportTitle, ObjectType, ObjectName, ConnectionName: String);
begin
  ShowPrintingUnavailable;
end;

procedure TfrmGlobalPrintingRoutines.PrintDatabase(Preview : Boolean; ConnectionName : String);
begin
  ShowPrintingUnavailable;
end;

procedure TfrmGlobalPrintingRoutines.PrintDomain(Preview : Boolean; ObjectName : String; ConnectionName : String);
begin
  ShowPrintingUnavailable;
end;

procedure TfrmGlobalPrintingRoutines.PrintDomains(Preview : Boolean; ConnectionName : String);
begin
  ShowPrintingUnavailable;
end;

procedure TfrmGlobalPrintingRoutines.PrintException(Preview : Boolean; ObjectName : String; ConnectionName : String);
begin
  ShowPrintingUnavailable;
end;

procedure TfrmGlobalPrintingRoutines.PrintExceptions(Preview : Boolean; ConnectionName : String);
begin
  ShowPrintingUnavailable;
end;

procedure TfrmGlobalPrintingRoutines.PrintGenerator(Preview : Boolean; ObjectName : String; ConnectionName : String);
begin
  ShowPrintingUnavailable;
end;

procedure TfrmGlobalPrintingRoutines.PrintGenerators(Preview : Boolean; ConnectionName : String);
begin
  ShowPrintingUnavailable;
end;

procedure TfrmGlobalPrintingRoutines.PrintTable(Preview : Boolean; ObjectName : String; ConnectionName : String);
begin
  ShowPrintingUnavailable;
end;

procedure TfrmGlobalPrintingRoutines.PrintTables(Preview : Boolean; ConnectionName : String);
begin
  ShowPrintingUnavailable;
end;

procedure TfrmGlobalPrintingRoutines.PrintTableStruct(Preview : Boolean; ObjectName : String; ConnectionName : String);
begin
  ShowPrintingUnavailable;
end;

procedure TfrmGlobalPrintingRoutines.PrintTableConstraints(Preview : Boolean; ObjectName : String; ConnectionName : String);
begin
  ShowPrintingUnavailable;
end;

procedure TfrmGlobalPrintingRoutines.PrintTableIndexes(Preview : Boolean; ObjectName : String; ConnectionName : String);
begin
  ShowPrintingUnavailable;
end;

procedure TfrmGlobalPrintingRoutines.PrintTableTriggers(Preview : Boolean; ObjectName : String; ConnectionName : String);
begin
  ShowPrintingUnavailable;
end;

procedure TfrmGlobalPrintingRoutines.PrintTrigger(Preview : Boolean; ObjectName : String; ConnectionName : String);
begin
  ShowPrintingUnavailable;
end;

procedure TfrmGlobalPrintingRoutines.PrintTriggers(Preview : Boolean; ConnectionName : String);
begin
  ShowPrintingUnavailable;
end;

procedure TfrmGlobalPrintingRoutines.PrintSP(Preview : Boolean; ObjectName : String; ConnectionName : String);
begin
  ShowPrintingUnavailable;
end;

procedure TfrmGlobalPrintingRoutines.PrintSPs(Preview : Boolean; ConnectionName : String);
begin
  ShowPrintingUnavailable;
end;

procedure TfrmGlobalPrintingRoutines.PrintUDF(Preview : Boolean; ObjectName : String; ConnectionName : String);
begin
  ShowPrintingUnavailable;
end;

procedure TfrmGlobalPrintingRoutines.PrintUDFs(Preview : Boolean; ConnectionName : String);
begin
  ShowPrintingUnavailable;
end;

procedure TfrmGlobalPrintingRoutines.PrintView(Preview : Boolean; ObjectName : String; ConnectionName : String);
begin
  ShowPrintingUnavailable;
end;

procedure TfrmGlobalPrintingRoutines.PrintViews(Preview : Boolean; ConnectionName : String);
begin
  ShowPrintingUnavailable;
end;

procedure TfrmGlobalPrintingRoutines.PrintViewSource(Preview : Boolean; ObjectName : String; ConnectionName : String);
begin
  ShowPrintingUnavailable;
end;

procedure TfrmGlobalPrintingRoutines.PrintViewStruct(Preview : Boolean; ObjectName : String; ConnectionName : String);
begin
  ShowPrintingUnavailable;
end;

procedure TfrmGlobalPrintingRoutines.PrintViewTriggers(Preview : Boolean; ObjectName : String; ConnectionName : String);
begin
  ShowPrintingUnavailable;
end;

procedure TfrmGlobalPrintingRoutines.PrintObjectDependencies(Preview : Boolean; ObjectName : String; ConnectionName : String);
begin
  ShowPrintingUnavailable;
end;

procedure TfrmGlobalPrintingRoutines.PrintObjectDoco(Preview : Boolean; ObjectName : String; ConnectionName : String; ObjectType : TGSSCacheType);
begin
  ShowPrintingUnavailable;
end;

procedure TfrmGlobalPrintingRoutines.PrintObjectDRUIMatrix(Preview : Boolean; ObjectName : String; ConnectionName : String; ObjectType : TGSSCacheType);
begin
  ShowPrintingUnavailable;
end;

procedure TfrmGlobalPrintingRoutines.PrintObjectDDL(Preview : Boolean; ObjectName : String; ConnectionName : String; ObjectType : TGSSCacheType);
begin
  ShowPrintingUnavailable;
end;

procedure TfrmGlobalPrintingRoutines.PrintObjectPerms(Preview : Boolean; ObjectName : String; ConnectionName : String; ObjectType : TGSSCacheType);
begin
  ShowPrintingUnavailable;
end;

procedure TfrmGlobalPrintingRoutines.PrintTreeList(Preview : Boolean; ObjectList : TList);
begin
  ShowPrintingUnavailable;
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
