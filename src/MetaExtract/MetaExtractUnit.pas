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
// $Id: MetaExtractUnit.pas,v 1.3 2006/10/19 03:59:40 rjmills Exp $

unit MetaExtractUnit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, IBDatabase, IBCustomDataSet, DB, Globals, DDLExtractor;


type
  TExtractType = (exMetaOnly, exMetaAndData, exDataOnly);

  TNotifyExtractEvent = procedure(Sender : TObject; CurObj : String; PercentDone : Integer; var Stop : Boolean) of Object;

//==============================================================================
  TMetaExtract = class(TComponent)

  private
    FTotalObjects : LongInt;
    FCurrentObject : LongInt;
    FOnExtractNotify : TNotifyExtractEvent;
    FStop : Boolean;
  protected
    procedure ExtractNotify(Obj : String);
  public
    property OnExtractNotify : TNotifyExtractEvent read FOnExtractNotify write FOnExtractNotify;
    constructor Create(AOwner : TComponent); override;
    destructor Destroy; override;
  end;

//==============================================================================
  TIBMetaExtract = class(TMetaExtract)
  private
    FDomains : TStringList;
    FTables : TStringList;
    FViews : TStringList;
    FSPs : TStringList;
    FTriggers : TStringList;
    FGenerators : TStringList;
    FExceptions : TStringList;
    FTableDependencyOrder : TStringList;
    FUDFs : TStringList;
    FExtractType : TExtractType;
    FCreateDatabase : Boolean;
    FIncludePassword : Boolean;
    FFileName : String;
    FFile : TextFile;
    FDatabase : TIBDatabase;
    FTransaction : TIBTransaction;
    FBusy : TIBDataSet;
    FExtractor : TDDLExtractor;
    FIncludeDependents: Boolean;
    FWrap: Boolean;
    FDecimals: Integer;
    FDecSeparator: String;
    FUserName: String;
    FPassword: String;
    FRightMargin: Integer;
    FIsIB6: Boolean;
    FSQLDialect: Integer;
    FGrantSPs: TStringList;
    FGrantViews: TStringList;
    FGrantTables: TStringList;
    FDatabaseName: String;
    FIncludeDoc: Boolean;
    procedure SetDatabase(Value : TIBDatabase);
    procedure SetTransaction(Value : TIBTransaction);
    procedure WriteHeader;
    procedure WriteDatabase;
    procedure WriteDomains;
    procedure WriteTables;
    procedure WriteTableData;
    procedure WriteTableConstraints;
    procedure WriteTableIndexes;
    procedure WriteViews;
    procedure WriteTriggers;
    procedure WriteStoredProcedures;
    procedure WriteGenerators;
    procedure WriteExceptions;
    procedure WriteUDFs;
    procedure OnDataHandler(Sender : TObject; Line : String; NoWrap : Boolean; var Stop : Boolean);
    procedure OnStatusHandler(Sender : TObject; Line : String);
    procedure BuildObjectDependencies;
    procedure SetDecimals(const Value: Integer);
    procedure SetDecSeparator(const Value: String);
    procedure WriteGrants;
    procedure AnalyseSPDependencies(ObjectName : String);
    procedure AnalyseTableDependencies(ObjectName : String);
    procedure AnalyseTriggerDependencies(ObjectName : String);
    procedure AnalyseViewDependencies(ObjectName : String);
  protected

  public
    property Database : TIBDatabase read FDatabase write SetDatabase;
    property DatabaseName : String read FDatabaseName write FDatabaseName;
    property UserName : String read FUserName write FUserName;
    property Password : String read FPassword write FPassword;
    property IsIB6 : Boolean read FIsIB6 write FIsIB6;
    property SQLDialect : Integer read FSQLDialect write FSQLDialect;

    property RightMargin : Integer read FRightMargin write FRightMargin;
    property Transaction : TIBTransaction read FTransaction write SetTransaction;
    property Domains : TStringList read FDomains write FDomains;
    property Tables : TStringList read FTables write FTables;
    property Views : TStringList read FViews write FViews;
    property SPs : TStringList read FSPs write FSPs;
    property GrantTables : TStringList read FGrantTables write FGrantTables;
    property GrantViews : TStringList read FGrantViews write FGrantViews;
    property GrantSPs : TStringList read FGrantSPs write FGrantSPs;
    property Triggers : TStringList read FTriggers write FTriggers;
    property Generators : TStringList read FGenerators write FGenerators;
    property Exceptions : TStringList read FExceptions write FExceptions;
    property UDFs : TStringList read FUDFs write FUDFs;
    property ExtractType : TExtractType read FExtractType write FExtractType;
    property CreateDatabase : Boolean read FCreateDatabase write FCreateDatabase;
    property IncludePassword : Boolean read FIncludePassword write FIncludePassword;
    property IncludeDoc : Boolean read FIncludeDoc write FIncludeDoc;

    property IncludeDependents : Boolean read FIncludeDependents write FIncludeDependents;
    property FileName : String read FFileName write FFileName;
    property Wrap : Boolean read FWrap write FWrap;
    property DecimalPlaces : Integer read FDecimals write SetDecimals;
    property DecimalSeparator : String read FDecSeparator write SetDecSeparator;
    procedure ExtractFullMetaData;
    constructor Create(AOwner : TComponent); override;
    destructor Destroy; override;
  end;

implementation


//==============================================================================
constructor TMetaExtract.Create(AOwner : TComponent);
begin
  inherited Create(AOwner);
end;

destructor TMetaExtract.Destroy;
begin
  inherited Destroy;
end;


procedure TMetaExtract.ExtractNotify(Obj : String);
var
  Temp : Integer;
  TmpStop : Boolean;

begin
  if FTotalObjects <> 0 then
  begin
    Temp := Trunc((FCurrentObject / FTotalObjects) * 100);
  end
  else
    Temp := 1;
  if Assigned(FOnExtractNotify) then
  begin
    TmpStop := False;
    FOnExtractNotify(Self, Obj, Temp, TmpStop);
    FStop := TmpStop;
  end;
end;


//==============================================================================
constructor TIBMetaExtract.Create(AOwner : TComponent);
begin
  inherited Create(AOwner);
  FExtractor := TDDLExtractor.Create(Self);
  FExtractor.OnData := OnDataHandler;
  FExtractor.OnStatus := OnStatusHandler;
  FDomains := TStringList.Create;
  FTables := TStringList.Create;
  FViews := TStringList.Create;
  FSPs := TStringList.Create;
  FTriggers := TStringList.Create;
  FGenerators := TStringList.Create;
  FExceptions := TStringList.Create;
  FUDFs := TStringList.Create;
  FGrantSPs := TStringList.Create;
  FGrantViews := TStringList.Create;
  FGrantTables := TStringList.Create;
  FBusy := TIBDataSet.Create(Self);
  FRightMargin := 80;
end;

destructor TIBMetaExtract.Destroy;
begin
  FDomains.Free;
  FTables.Free;
  FViews.Free;
  FSPs.Free;
  FTriggers.Free;
  FGenerators.Free;
  FExceptions.Free;
  FUDFs.Free;
  FGrantSPs.Free;
  FGrantViews.Free;
  FGrantTables.Free;
  FBusy.Free;
  FExtractor.Free;
  inherited Destroy;
end;


procedure TIBMetaExtract.WriteHeader;
begin
  WriteLn(FFile, '/*===========================================================================*/');
  WriteLn(FFile, '/*Metadata Extract performed ' + FormatDateTime('dd-mmm-yyyy hh:mm', Now) + '                               */');
  WriteLn(FFile, '/*===========================================================================*/');
  if FIsIB6 then
    WriteLn(FFile, 'SET SQL DIALECT ' + IntToStr(FSQLDialect) + ';');
  WriteLn(FFile, '');
end;

procedure TIBMetaExtract.WriteDatabase;
var
  Line : String;

begin
  if FCreateDatabase then
  begin
    WriteLn(FFile, '/*===========================================================================*/');
    WriteLn(FFile, '/*Create Database                                                            */');
    WriteLn(FFile, '/*===========================================================================*/');
    Line := 'create database ''' + FDatabaseName  + ''' user ''' + FUserName + '''';
    if FIncludePassword then
    begin
      Line := Line + ' password ''' + FPassword + '''';
    end;
  end
  else
  begin
    WriteLn(FFile, '/*===========================================================================*/');
    WriteLn(FFile, '/*Connect to Database                                                        */');
    WriteLn(FFile, '/*===========================================================================*/');
    Line := 'connect ''' + FDatabaseName + ''' user ''' + FUserName + '''';
    if FIncludePassword then
    begin
      Line := Line + ' password ''' + FPassword + '''';
    end;
  end;
  Line := Line + ';';
  if FWrap then
    Line := WrapText(Line, #13#10, [' ', #9], FRightMargin);
  WriteLn(FFile, Line);
  WriteLn(FFile, '');
end;

procedure TIBMetaExtract.WriteDomains;
var
  Line : String;
  Idx : Integer;

begin
  if FDomains.Count > 0 then
  begin
    if FExtractType in [exMetaOnly, exMetaAndData] then
    begin
      WriteLn(FFile, '');
      WriteLn(FFile, '');
      WriteLn(FFile, '/*===========================================================================*/');
      WriteLn(FFile, '/*Domain Definitions                                                         */');
      WriteLn(FFile, '/*===========================================================================*/');
      for Idx := 0 to FDomains.Count - 1 do
      begin
        FCurrentObject := FCurrentObject + 1;
        ExtractNotify('Extracting Domain "' + FDomains[Idx] + '"...');
        if FStop then
          Exit;

        Line := FExtractor.Extract(ddlDomain, ddlstNone, FDomains[Idx]);
        if FWrap then
          Line := WrapText(Line, #13#10, [' ', #9], FRightMargin);
        WriteLn(FFile, Line);
      end;
    end;
  end;
end;

procedure TIBMetaExtract.WriteTables;
var
  Idx : Integer;
  Line : String;
  HasBlobs : Boolean;

begin
  if FTables.Count > 0 then
  begin
    WriteLn(FFile, '');
    WriteLn(FFile, '');
    if FExtractType in [exMetaOnly, exMetaAndData] then
    begin
      WriteLn(FFile, '/*===========================================================================*/');
      WriteLn(FFile, '/*Table Definitions                                                          */');
      WriteLn(FFile, '/*===========================================================================*/');
    end;

    if FExtractType in [exMetaOnly, exMetaAndData] then
    begin
      for Idx := 0 to FTables.Count - 1 do
      begin
        FCurrentObject := FCurrentObject + 1;
        ExtractNotify('Extracting Table "' + FTables[Idx] + '"...');
        if FStop then
          Exit;


        WriteLn(FFile, '');
        WriteLn(FFile, '/*Table: ' + FTables[Idx] + '*/');

        Line := FExtractor.Extract(ddlTable, ddlstNone, FTables[Idx]);
        if FWrap then
          Line := WrapText(Line, #13#10, [' ', #9], FRightMargin);
        WriteLn(FFile, Line);
      end;
    end;
  end;
end;

procedure TIBMetaExtract.WriteTableData;
var
  Idx : Integer;
  Line : String;
  HasBlobs : Boolean;

begin
  if FTables.Count > 0 then
  begin
    WriteLn(FFile, '');
    WriteLn(FFile, '');
    if FExtractType in [exMetaAndData, exDataOnly] then
    begin
      for Idx := 0 to FTables.Count - 1 do
      begin
        FCurrentObject := FCurrentObject + 1;
        ExtractNotify('Extracting Table Data "' + FTables[Idx] + '"...');
        if FStop then
          Exit;
        WriteLn(FFile, '');
        WriteLn(FFile, '/*===========================================================================*/');
        WriteLn(FFile, '/*Table Data for ' + Format('%-32s', [FTables[Idx]]) + '                            */');
        WriteLn(FFile, '/*===========================================================================*/');
        FExtractor.Extract(ddlTableData, ddlstNone, FTables[Idx]);
      end;
    end;
  end;
end;

procedure TIBMetaExtract.WriteTableConstraints;
var
  Idx : Integer;
  Line : String;
  HasBlobs : Boolean;

begin
  HasBlobs := False;
  if FTables.Count > 0 then
  begin
    WriteLn(FFile, '');
    WriteLn(FFile, '');

    if FExtractType in [exMetaOnly, exMetaAndData] then
    begin
      WriteLn(FFile, '/*===========================================================================*/');
      WriteLn(FFile, '/*Table Primary Key Definitions                                              */');
      WriteLn(FFile, '/*===========================================================================*/');

      for Idx := 0 to FTables.Count - 1 do
      begin
        FCurrentObject := FCurrentObject + 1;
        ExtractNotify('Extracting Table Primary Key "' + FTables[Idx] + '"...');
        if FStop then
          Exit;
        Line := FExtractor.Extract(ddlTable, ddlstPrimaryKey, FTables[Idx]);
        if Line <> '' then
        begin
          if FWrap then
            Line := WrapText(Line, #13#10, [' ', #9], FRightMargin);
          WriteLn(FFile, Line);
        end;
      end;
    end;

    if FExtractType in [exMetaOnly, exMetaAndData] then
    begin
      WriteLn(FFile, '/*===========================================================================*/');
      WriteLn(FFile, '/*Table Foreign Key Definitions                                              */');
      WriteLn(FFile, '/*===========================================================================*/');

      for Idx := 0 to FTables.Count - 1 do
      begin
        FCurrentObject := FCurrentObject + 1;
        ExtractNotify('Extracting Table Foreign Key "' + FTables[Idx] + '"...');
        if FStop then
          Exit;
        Line := FExtractor.Extract(ddlTable, ddlstForeignKey, FTables[Idx]);
        if Line <> '' then
        begin
          if FWrap then
            Line := WrapText(Line, #13#10, [' ', #9], FRightMargin);
          WriteLn(FFile, Line);
        end;
      end;
    end;
  end;
end;

procedure TIBMetaExtract.WriteTableIndexes;
var
  Idx : Integer;
  Line : String;
  HasBlobs : Boolean;

begin
  HasBlobs := False;
  if FTables.Count > 0 then
  begin
    WriteLn(FFile, '');
    WriteLn(FFile, '');

    if FExtractType in [exMetaOnly, exMetaAndData] then
    begin
      WriteLn(FFile, '/*===========================================================================*/');
      WriteLn(FFile, '/*Table Index Definitions                                                    */');
      WriteLn(FFile, '/*===========================================================================*/');

      for Idx := 0 to FTables.Count - 1 do
      begin
        FCurrentObject := FCurrentObject + 1;
        ExtractNotify('Extracting Table Index "' + FTables[Idx] + '"...');
        if FStop then
          Exit;
        Line := FExtractor.Extract(ddlTable, ddlstIndex, FTables[Idx]);
        if Line <> '' then
        begin
          if FWrap then
            Line := WrapText(Line, #13#10, [' ', #9], FRightMargin);
          WriteLn(FFile, Line);
        end;
      end;
    end;
  end;
end;

procedure TIBMetaExtract.WriteViews;
var
  Idx : Integer;
  Line : String;

begin
  if FViews.Count > 0 then
  begin
    if FExtractType in [exMetaOnly, exMetaAndData] then
    begin
      WriteLn(FFile, '');
      WriteLn(FFile, '');
      WriteLn(FFile, '/*===========================================================================*/');
      WriteLn(FFile, '/*View Definitions                                                           */');
      WriteLn(FFile, '/*===========================================================================*/');

      for Idx := 0 to FViews.Count - 1 do
      begin
        FCurrentObject := FCurrentObject + 1;
        ExtractNotify('Extracting View "' + FViews[Idx] + '"...');
        if FStop then
          Exit;

        WriteLn(FFile, '');
        WriteLn(FFile, '/* View: ' + FViews[Idx] + ' */');

        Line := FExtractor.Extract(ddlView, ddlstNone, FViews[Idx]);
        if FWrap then
          Line := WrapText(Line, #13#10, [' ', #9], FRightMargin);
        WriteLn(FFile, Line);

      end;

      WriteLn(FFile, '');
      WriteLn(FFile, '');
    end;
  end;
end;

procedure TIBMetaExtract.WriteTriggers;
var
  Line : String;
  Idx : Integer;

begin
  if FTriggers.Count > 0 then
  begin
    if FExtractType in [exMetaOnly, exMetaAndData] then
    begin
      WriteLn(FFile, '');
      WriteLn(FFile, '');
      WriteLn(FFile, '/*===========================================================================*/');
      WriteLn(FFile, '/*Trigger Definitions                                                        */');
      WriteLn(FFile, '/*===========================================================================*/');
      WriteLn(FFile, 'commit work;');
      WriteLn(FFile, 'set autoddl off;');
      WriteLn(FFile, 'set term ^;');
      WriteLn(FFile, '');

      for Idx := 0 to FTriggers.Count - 1 do
      begin
        FCurrentObject := FCurrentObject + 1;
        ExtractNotify('Extracting Trigger "' + FTriggers[Idx] + '"...');
        if FStop then
          Exit;

        Line := FExtractor.Extract(ddlTrigger, ddlstNone, FTriggers[Idx]);
        Line := Line + '^';
        if FWrap then
          Line := WrapText(Line, #13#10, [' ', #9], FRightMargin);
        WriteLn(FFile, Line);
        WriteLn(FFile, '');
        Line := FExtractor.Extract(ddlTrigger, ddlstDoco, FTriggers[Idx]);
        WriteLn(FFile, '');
        WriteLn(FFile, '');
        WriteLn(FFile, '');
      end;
      WriteLn(FFile, '');
      WriteLn(FFile, 'commit work^');
      WriteLn(FFile, 'set autoddl on^');
      WriteLn(FFile, 'set term ;^');
      WriteLn(FFile, '');
    end;
  end;
end;

procedure TIBMetaExtract.WriteStoredProcedures;
var
  Line : String;
  Idx : Integer;

begin
  if FSPs.Count > 0 then
  begin
    if FExtractType in [exMetaOnly, exMetaAndData] then
    begin
      WriteLn(FFile, '');
      WriteLn(FFile, '');
      WriteLn(FFile, '/*===========================================================================*/');
      WriteLn(FFile, '/*Stored Procedure Definitions                                               */');
      WriteLn(FFile, '/*===========================================================================*/');

      WriteLn(FFile, 'commit work;');
      WriteLn(FFile, 'set autoddl off;');
      WriteLn(FFile, 'set term ^;');
      WriteLn(FFile, '');

      for Idx := 0 to FSPs.Count - 1 do
      begin
        FCurrentObject := FCurrentObject + 1;
        ExtractNotify('Extracting Stored Procedure Header"' + FSPs[Idx] + '"...');
        if FStop then
          Exit;

        Line := FExtractor.Extract(ddlStoredProc, ddlstHeader, FSPs[Idx]);
        Line := Line + '^';
        if FWrap then
          Line := WrapText(Line, #13#10, [' ', #9], FRightMargin);
        WriteLn(FFile, Line);
        WriteLn(FFile, '');
        Line := FExtractor.Extract(ddlStoredProc, ddlstDoco, FSPs[Idx]);
        WriteLn(FFile, Line);
        WriteLn(FFile, '');
        WriteLn(FFile, '');
      end;

      WriteLn(FFile, 'commit work^');
      WriteLn(FFile, '');
      WriteLn(FFile, '');

      for Idx := 0 to FSPs.Count - 1 do
      begin
        FCurrentObject := FCurrentObject + 1;
        ExtractNotify('Extracting Stored Procedure "' + FSPs[Idx] + '"...');
        if FStop then
          Exit;

        Line := FExtractor.Extract(ddlStoredProc, ddlstProc, FSPs[Idx]);
        Line := Line + '^';
        if FWrap then
          Line := WrapText(Line, #13#10, [' ', #9], FRightMargin);
        WriteLn(FFile, Line);
        WriteLn(FFile, '');
        WriteLn(FFile, '');
        WriteLn(FFile, '');
        WriteLn(FFile, '');
      end;


      WriteLn(FFile, 'commit work^');
      WriteLn(FFile, 'set autoddl on^');
      WriteLn(FFile, 'set term ;^');
    end;
  end;
end;

procedure TIBMetaExtract.WriteGenerators;
var
  Line : String;
  Idx  : Integer;

begin
  if FGenerators.Count > 0 then
  begin
    WriteLn(FFile, '');
    WriteLn(FFile, '');
    WriteLn(FFile, '/*===========================================================================*/');
    WriteLn(FFile, '/*Generators                                                                 */');
    WriteLn(FFile, '/*===========================================================================*/');
    for Idx := 0 to FGenerators.Count - 1 do
    begin
      FCurrentObject := FCurrentObject + 1;
      ExtractNotify('Extracting Generator "' + FGenerators[Idx] + '"...');
      if FStop then
        Exit;

      case FExtractType of
        exMetaOnly:
          begin
            Line := FExtractor.Extract(ddlGenerator, ddlstGenerator, FGenerators[Idx]);
            if FWrap then
              Line := WrapText(Line, #13#10, [' ', #9], FRightMargin);
            WriteLn(FFile, Line);
          end;
        exMetaAndData:
          begin
            Line := FExtractor.Extract(ddlGenerator, ddlstGenerator, FGenerators[Idx]);
            if FWrap then
              Line := WrapText(Line, #13#10, [' ', #9], FRightMargin);
            WriteLn(FFile, Line);
            Line := FExtractor.Extract(ddlGenerator, ddlstGeneratorVal, FGenerators[Idx]);
            if FWrap then
              Line := WrapText(Line, #13#10, [' ', #9], FRightMargin);
            WriteLn(FFile, Line);
          end;
        exDataOnly:
          begin
            Line := FExtractor.Extract(ddlGenerator, ddlstGeneratorVal, FGenerators[Idx]);
            if FWrap then
              Line := WrapText(Line, #13#10, [' ', #9], FRightMargin);
            WriteLn(FFile, Line);
          end;
      end;
    end;
  end;
end;

procedure TIBMetaExtract.WriteExceptions;
var
  Line : String;
  Idx : Integer;

begin
  if FExceptions.Count > 0 then
  begin
    if FExtractType in [exMetaOnly, exMetaAndData] then
    begin
      WriteLn(FFile, '');
      WriteLn(FFile, '');
      WriteLn(FFile, '/*===========================================================================*/');
      WriteLn(FFile, '/*Exception Definitions                                                      */');
      WriteLn(FFile, '/*===========================================================================*/');
      for Idx := 0 to FExceptions.Count - 1 do
      begin
        FCurrentObject := FCurrentObject + 1;
        ExtractNotify('Extracting Exception "' + FExceptions[Idx] + '"...');
        if FStop then
          Exit;

        Line := FExtractor.Extract(ddlException, ddlstNone, FExceptions[Idx]);
        if FWrap then
          Line := WrapText(Line, #13#10, [' ', #9], FRightMargin);
        WriteLn(FFile, Line);
      end;
    end;
  end;
end;

procedure TIBMetaExtract.WriteUDFs;
var
  Line : String;
  Idx : Integer;

begin
  if FUDFs.Count > 0 then
  begin
    if FExtractType in [exMetaOnly, exMetaAndData] then
    begin
      WriteLn(FFile, '');
      WriteLn(FFile, '');
      WriteLn(FFile, '/*===========================================================================*/');
      WriteLn(FFile, '/*UDF Definitions                                                            */');
      WriteLn(FFile, '/*===========================================================================*/');
    end;

    for Idx := 0 to FUDFs.Count - 1 do
    begin
      FCurrentObject := FCurrentObject + 1;
      ExtractNotify('Extracting UDF "' + FUDFs[Idx] + '"...');
      if FStop then
        Exit;

      WriteLn(FFile, '');

      Line := FExtractor.Extract(ddlUDF, ddlstNone, FUDFs[Idx]);
      if FWrap then
        Line := WrapText(Line, #13#10, [' ', #9], FRightMargin);
      WriteLn(FFile, Line);
      WriteLn(FFile, '');
    end;
  end;
end;

procedure TIBMetaExtract.WriteGrants;
var
  Idx : Integer;
  Line : String;
  
begin

  if FExtractType in [exMetaOnly, exMetaAndData] then
  begin
    WriteLn(FFile, '/*===========================================================================*/');
    WriteLn(FFile, '/*Table Grants                                                               */');
    WriteLn(FFile, '/*===========================================================================*/');

    for Idx := 0 to FGrantTables.Count - 1 do
    begin
      FCurrentObject := FCurrentObject + 1;
      ExtractNotify('Extracting Table Grants "' + FGrantTables[Idx] + '"...');
      if FStop then
        Exit;
      Line := FExtractor.Extract(ddlTable, ddlstGrants, FGrantTables[Idx]);
      if Line <> '' then
      begin
        if FWrap then
          Line := WrapText(Line, #13#10, [' ', #9], FRightMargin);
        WriteLn(FFile, Line);
      end;
    end;
  end;

  if FExtractType in [exMetaOnly, exMetaAndData] then
  begin
    WriteLn(FFile, '/*===========================================================================*/');
    WriteLn(FFile, '/*View Grants                                                                */');
    WriteLn(FFile, '/*===========================================================================*/');

    for Idx := 0 to FGrantViews.Count - 1 do
    begin
      FCurrentObject := FCurrentObject + 1;
      ExtractNotify('Extracting View Grants "' + FGrantViews[Idx] + '"...');
      if FStop then
        Exit;
      Line := FExtractor.Extract(ddlView, ddlstGrants, FGrantViews[Idx]);
      if Line <> '' then
      begin
        if FWrap then
          Line := WrapText(Line, #13#10, [' ', #9], FRightMargin);
        WriteLn(FFile, Line);
      end;
    end;
  end;

  if FExtractType in [exMetaOnly, exMetaAndData] then
  begin
    WriteLn(FFile, '/*===========================================================================*/');
    WriteLn(FFile, '/*Stored Procedure Grants                                                    */');
    WriteLn(FFile, '/*===========================================================================*/');

    for Idx := 0 to FGrantSps.Count - 1 do
    begin
      FCurrentObject := FCurrentObject + 1;
      ExtractNotify('Extracting Procedure Grants "' + FGrantSPs[Idx] + '"...');
      if FStop then
        Exit;
      Line := FExtractor.Extract(ddlStoredProc, ddlstGrants, FGrantSPs[Idx]);
      if Line <> '' then
      begin
        if FWrap then
          Line := WrapText(Line, #13#10, [' ', #9], FRightMargin);
        WriteLn(FFile, Line);
      end;
    end;
  end;
end;

procedure TIBMetaExtract.ExtractFullMetaData;
begin
  if Not Assigned(FTransaction) then
    raise Exception.Create('Transaction not assigned');

  if Not Assigned(FDatabase) then
    raise Exception.Create('Database not assigned');

  if Not FDatabase.Connected then
    raise Exception.Create('Database not connected');

  FExtractor.Database := FDatabase;
  FExtractor.Transaction := FTransaction;
  FExtractor.IsInterbase6 := FIsIB6;
  FExtractor.SQLDialect := FSQLDialect;
  FExtractor.IncludeDoc := FIncludeDoc;

  if not FTransaction.InTransaction then
    FTransaction.StartTransaction;

  FTotalObjects := 0;
  FTotalObjects :=  FTotalObjects + FDomains.Count;
  if FIncludeDependents then
  begin
    ExtractNotify('Walking Object Dependency Tree...');
    BuildObjectDependencies;
  end;

  case FExtractType of
    exMetaOnly :
      begin
        FTotalObjects :=  FTotalObjects + (FTables.Count * 4);
      end;
    exMetaAndData :
      begin
        FTotalObjects :=  FTotalObjects + (FTables.Count * 5);
      end;
    exDataOnly : FTotalObjects :=  FTotalObjects + FTables.Count;
  end;
  FTotalObjects :=  FTotalObjects + FViews.Count;

  FTotalObjects :=  FTotalObjects + FSPs.Count * 2;
  FTotalObjects :=  FTotalObjects + FTriggers.Count;
  FTotalObjects :=  FTotalObjects + FGenerators.Count;
  FTotalObjects :=  FTotalObjects + FExceptions.Count;
  FTotalObjects :=  FTotalObjects + FUDFs.Count;

  if not FStop then
  begin
    try
      Screen.Cursor := crAppStart;
      try
        FCurrentObject := 0;
        AssignFile(FFile, FFileName);
        Rewrite(FFile);
        try
          if Not FStop then
            WriteHeader;

          if Not FStop then
            WriteDatabase;

          if Not FStop then
            WriteDomains;

          if Not FStop then
            WriteUDFs;

          if Not FStop then
            WriteExceptions;

          if Not FStop then
            WriteGenerators;

          if Not FStop then
            WriteTables;

          if Not FStop then
            WriteTableData;

          if Not FStop then
            WriteTableConstraints;

          if Not FStop then
            WriteTableIndexes;
            
          if Not FStop then
            WriteViews;

          if Not FStop then
            WriteStoredProcedures;

          if Not FStop then
            WriteTriggers;

          if Not FStop then
            WriteGrants;

        finally
          CloseFile(FFile);
        end;
        if FTransaction.InTransaction then
          FTransaction.Commit;
        ExtractNotify('Extract to Script Completed Successfully.');
      except
        On E : Exception do
        begin
          FTransaction.Rollback;
          ExtractNotify('Extract to Script encountered an error:' + #13#10#13#10 + E.Message);
          Exit;
        end;
      end;
    finally
      Screen.Cursor := crDefault;
    end;
  end;

  if FStop then
    ExtractNotify('Extract to Script Stopped at User Request.');
end;

procedure TIBMetaExtract.SetDatabase(Value : TIBDatabase);
begin
  FDatabase := Value;
  FBusy.Database := FDatabase;
end;

procedure TIBMetaExtract.SetTransaction(Value : TIBTransaction);
begin
  FTransaction := Value;
  FBusy.Transaction := FTransaction;
end;


procedure TIBMetaExtract.OnDataHandler(Sender: TObject; Line: String; NoWrap : Boolean; var Stop : Boolean);
begin
  if Line <> '' then
  begin
    Application.ProcessMessages;
    if FWrap and (not NoWrap) then
      Line := WrapText(Line, #13#10, [' ', #9], FRightMargin);
    WriteLn(FFile, Line);
    Stop := FStop;
  end;
end;


procedure TIBMetaExtract.SetDecimals(const Value: Integer);
begin
  FDecimals := Value;
  FExtractor.ExDecimalPlaces := FDecimals;
end;

procedure TIBMetaExtract.SetDecSeparator(const Value: String);
begin
  FDecSeparator := Value;
  FExtractor.ExDecimalSeparator := FDecSeparator;
end;

procedure TIBMetaExtract.OnStatusHandler(Sender: TObject; Line: String);
begin
  ExtractNotify(Line);
end;


procedure TIBMetaExtract.AnalyseTriggerDependencies(ObjectName : String);
var
  Idx : Integer;
  Q : TIBDataSet;
  Q1 : TIBDataSet;
  Local : TStringList;

begin
  Q := TIBDataSet.Create(Self);
  Q1 := TIBDataSet.Create(Self);
  Local := TStringList.Create;
  try
    Q.Database := FDatabase;
    Q.Transaction := FTransaction;
    Q1.Database := FDatabase;
    Q1.Transaction := FTransaction;
    ExtractNotify('Walking Trigger Dependency Tree ("' + ObjectName + '")...');
    if FStop then
      Exit;

    //get any objects we use....
    Q1.Close;
    Q1.SelectSQL.Clear;
    Q1.SelectSQL.Add('select rdb$depended_on_name, rdb$depended_on_type, rdb$field_name from rdb$dependencies where rdb$dependent_name = ' + AnsiQuotedStr(ObjectName, '''') + ';');
    Q1.Open;
    if Not (Q1.EOF and Q1.Bof) then
    begin
      while not Q1.EOF do
      begin
        case Q1.FieldByName('rdb$depended_on_type').AsInteger of
          0 :
            begin
              if FTables.IndexOf(Trim(Q1.FieldByName('rdb$depended_on_name').AsString)) = -1 then
              begin
                FTables.Add(Trim(Q1.FieldByName('rdb$depended_on_name').AsString));
                AnalyseTableDependencies(Trim(Q1.FieldByName('rdb$depended_on_name').AsString));
              end;
            end;
          1 :
            begin
              if FViews.IndexOf(Trim(Q1.FieldByName('rdb$depended_on_name').AsString)) = -1 then
              begin
                FViews.Add(Trim(Q1.FieldByName('rdb$depended_on_name').AsString));
                AnalyseViewDependencies(Trim(Q1.FieldByName('rdb$depended_on_name').AsString));
              end;
            end;
          2 :
            begin
              if FTriggers.IndexOf(Trim(Q1.FieldByName('rdb$depended_on_name').AsString)) = -1 then
              begin
                FTriggers.Add(Trim(Q1.FieldByName('rdb$depended_on_name').AsString));
                AnalyseTriggerDependencies(Trim(Q1.FieldByName('rdb$depended_on_name').AsString));
              end;
            end;
          5 :
            begin
              if FSps.IndexOf(Trim(Q1.FieldByName('rdb$depended_on_name').AsString)) = -1 then
              begin
                FSps.Add(Trim(Q1.FieldByName('rdb$depended_on_name').AsString));
                AnalyseSPDependencies(Trim(Q1.FieldByName('rdb$depended_on_name').AsString));
              end;
            end;
          7 :
            begin
              if FExceptions.IndexOf(Trim(Q1.FieldByName('rdb$depended_on_name').AsString)) = -1 then
              begin
                FExceptions.Add(Trim(Q1.FieldByName('rdb$depended_on_name').AsString));
              end;
            end;
        end;
        Q1.Next;
      end;
    end;

  finally
    Local.Free;
    Q1.Free;
    Q.Free;
  end;
end;

procedure TIBMetaExtract.AnalyseSPDependencies(ObjectName : String);
var
  Idx : Integer;
  Q : TIBDataSet;
  Q1 : TIBDataSet;
  Local : TStringList;

begin
  Q := TIBDataSet.Create(Self);
  Q1 := TIBDataSet.Create(Self);
  Local := TStringList.Create;
  try
    Q.Database := FDatabase;
    Q.Transaction := FTransaction;
    Q1.Database := FDatabase;
    Q1.Transaction := FTransaction;
    ExtractNotify('Walking Stored Procedure Dependency Tree ("' + ObjectName + '")...');
    if FStop then
      Exit;

    //get any objects we use....
    Q1.Close;
    Q1.SelectSQL.Clear;
    Q1.SelectSQL.Add('select rdb$depended_on_name, rdb$depended_on_type, rdb$field_name from rdb$dependencies where rdb$dependent_name = ' + AnsiQuotedStr(ObjectName, '''') + ';');
    Q1.Open;
    if Not (Q1.EOF and Q1.Bof) then
    begin
      while not Q1.EOF do
      begin
        case Q1.FieldByName('rdb$depended_on_type').AsInteger of
          0 :
            begin
              if FTables.IndexOf(Trim(Q1.FieldByName('rdb$depended_on_name').AsString)) = -1 then
              begin
                FTables.Add(Trim(Q1.FieldByName('rdb$depended_on_name').AsString));
                AnalyseTableDependencies(Trim(Q1.FieldByName('rdb$depended_on_name').AsString));
              end;
            end;
          1 :
            begin
              if FViews.IndexOf(Trim(Q1.FieldByName('rdb$depended_on_name').AsString)) = -1 then
              begin
                FViews.Add(Trim(Q1.FieldByName('rdb$depended_on_name').AsString));
                AnalyseViewDependencies(Trim(Q1.FieldByName('rdb$depended_on_name').AsString));
              end;
            end;
          2 :
            begin
              if FTriggers.IndexOf(Trim(Q1.FieldByName('rdb$depended_on_name').AsString)) = -1 then
              begin
                FTriggers.Add(Trim(Q1.FieldByName('rdb$depended_on_name').AsString));
                AnalyseTriggerDependencies(Trim(Q1.FieldByName('rdb$depended_on_name').AsString));
              end;
            end;
          5 :
            begin
              if FSps.IndexOf(Trim(Q1.FieldByName('rdb$depended_on_name').AsString)) = -1 then
              begin
                FSps.Add(Trim(Q1.FieldByName('rdb$depended_on_name').AsString));
                AnalyseSPDependencies(Trim(Q1.FieldByName('rdb$depended_on_name').AsString));
              end;
            end;
          7 :
            begin
              if FExceptions.IndexOf(Trim(Q1.FieldByName('rdb$depended_on_name').AsString)) = -1 then
                FExceptions.Add(Trim(Q1.FieldByName('rdb$depended_on_name').AsString));
            end;
        end;
        Q1.Next;
      end;
    end;

  finally
    Local.Free;
    Q1.Free;
    Q.Free;
  end;
end;

procedure TIBMetaExtract.AnalyseTableDependencies(ObjectName : String);
var
  Idx : Integer;
  Q : TIBDataSet;
  Q1 : TIBDataSet;
  Local : TStringList;

begin
  Q := TIBDataSet.Create(Self);
  Q1 := TIBDataSet.Create(Self);
  Local := TStringList.Create;
  try
    Q.Database := FDatabase;
    Q.Transaction := FTransaction;
    Q1.Database := FDatabase;
    Q1.Transaction := FTransaction;
    ExtractNotify('Walking Table Dependency Tree ("' + ObjectName + '")...');
    if FStop then
      Exit;

    //Analyse foreign Key relationships....

    Q1.SelectSQL.Clear;
    Q1.SelectSQL.Add('select rdb$index_name from rdb$relation_constraints where (rdb$constraint_type = ''FOREIGN KEY'') and rdb$relation_name = ' + AnsiQuotedStr(ObjectName, '''') + ';');
    Q1.Open;
    if Not (Q1.EOF and Q1.Bof) then
    begin
      while not Q1.EOF do
      begin
        Q.SelectSQL.Clear;
        //filter on table name to fix self referencing FK's
        Q.SelectSQL.Add('select rdb$relation_name from rdb$indices where rdb$index_name in ' +
                  '(select rdb$foreign_key from rdb$indices where rdb$index_name  = ''' +
                  Trim(Q1.FieldByName('rdb$index_name').AsString) + ''') and rdb$relation_name <> ' + AnsiQuotedStr(ObjectName, '''') + ';');
        Q.Open;
        while not Q.EOF do
        begin
          if FTables.IndexOf(Trim(Q.FieldByName('rdb$relation_name').AsString)) = -1 then
          begin
            FTables.Add(Trim(Q.FieldByName('rdb$relation_name').AsString));
            AnalyseTableDependencies(Trim(Q.FieldByName('rdb$relation_name').AsString));
          end;
          Q.Next;
        end;
        Q.Close;
        Q1.Next;
      end;
    end;

    //Analyse domain usage....
    Q1.Close;
    Q1.SelectSQL.Clear;
    Q1.SelectSQL.Add('select * from rdb$relation_fields where rdb$relation_name = ' + AnsiQuotedStr(ObjectName, '''') + ';');
    Q1.Open;
    if Not (Q1.EOF and Q1.Bof) then
    begin
      while not Q1.EOF do
      begin
        if AnsiUpperCase(Copy(Trim(Q1.FieldByName('rdb$field_source').AsString), 1, 4)) <> 'RDB$' then
        begin
          if FDomains.IndexOf(Trim(Q1.FieldByName('rdb$field_source').AsString)) = -1 then
            FDomains.Add(Trim(Q1.FieldByName('rdb$field_source').AsString));
        end;
        Q1.Next;
      end;
    end;

    //get any triggers...
    Q1.Close;
    Q1.SelectSQL.Clear;
    Q1.SelectSQL.Add('select * from rdb$triggers where rdb$relation_name = ' + AnsiQuotedStr(ObjectName, '''') + ' and rdb$system_flag is null;'); //added is null condition to remove system defined triggers. rjm
    Q1.Open;
    if Not (Q1.EOF and Q1.Bof) then
    begin
      while not Q1.EOF do
      begin
        if FTriggers.IndexOf(Trim(Q1.FieldByName('rdb$trigger_name').AsString)) = -1 then
        begin
          FTriggers.Add(Trim(Q1.FieldByName('rdb$trigger_name').AsString));
          AnalyseTriggerDependencies(Trim(Q1.FieldByName('rdb$trigger_name').AsString));
        end;
        Q1.Next;
      end;
    end;


  finally
    Local.Free;
    Q1.Free;
    Q.Free;
  end;
end;

procedure TIBMetaExtract.AnalyseViewDependencies(ObjectName : String);
var
  Idx : Integer;
  Q : TIBDataSet;
  Q1 : TIBDataSet;
  Local : TStringList;

begin
  Q := TIBDataSet.Create(Self);
  Q1 := TIBDataSet.Create(Self);
  Local := TStringList.Create;
  try
    Q.Database := FDatabase;
    Q.Transaction := FTransaction;
    Q1.Database := FDatabase;
    Q1.Transaction := FTransaction;
    ExtractNotify('Walking View Dependency Tree ("' + ObjectName + '")...');
    if FStop then
      Exit;

    //get any tables we use....
    Q1.Close;
    Q1.SelectSQL.Clear;
    Q1.SelectSQL.Add('select rdb$depended_on_name, rdb$depended_on_type, rdb$field_name from rdb$dependencies where rdb$dependent_name = ' + AnsiQuotedStr(ObjectName, '''') + ';');
    Q1.Open;
    if Not (Q1.EOF and Q1.Bof) then
    begin
      while not Q1.EOF do
      begin
        case Q1.FieldByName('rdb$depended_on_type').AsInteger of
          0 :
            begin
              if FTables.IndexOf(Trim(Q1.FieldByName('rdb$depended_on_name').AsString)) = -1 then
              begin
                FTables.Add(Trim(Q1.FieldByName('rdb$depended_on_name').AsString));
                AnalyseTableDependencies(Trim(Q1.FieldByName('rdb$depended_on_name').AsString));
              end;
            end;
          1 :
            begin
              if FViews.IndexOf(Trim(Q1.FieldByName('rdb$depended_on_name').AsString)) = -1 then
              begin
                FViews.Add(Trim(Q1.FieldByName('rdb$depended_on_name').AsString));
                AnalyseViewDependencies(Trim(Q1.FieldByName('rdb$depended_on_name').AsString));
              end;
            end;
          2 :
            begin
              if FTriggers.IndexOf(Trim(Q1.FieldByName('rdb$depended_on_name').AsString)) = -1 then
              begin
                FTriggers.Add(Trim(Q1.FieldByName('rdb$depended_on_name').AsString));
                AnalyseTriggerDependencies(Trim(Q1.FieldByName('rdb$depended_on_name').AsString));
              end;
            end;
          5 :
            begin
              if FSps.IndexOf(Trim(Q1.FieldByName('rdb$depended_on_name').AsString)) = -1 then
              begin
                FSps.Add(Trim(Q1.FieldByName('rdb$depended_on_name').AsString));
                AnalyseSPDependencies(Trim(Q1.FieldByName('rdb$depended_on_name').AsString));
              end;
            end;
          7 :
            begin
              if FExceptions.IndexOf(Trim(Q1.FieldByName('rdb$depended_on_name').AsString)) = -1 then
                FExceptions.Add(Trim(Q1.FieldByName('rdb$depended_on_name').AsString));
            end;
        end;
        Q1.Next;
      end;
    end;

    //get any triggers...
    Q1.Close;
    Q1.SelectSQL.Clear;
    Q1.SelectSQL.Add('select * from rdb$triggers where rdb$relation_name = ' + AnsiQuotedStr(ObjectName, '''') + ' and rdb$system_flag is null;'); //added is null condition to remove system defined triggers. rjm
    Q1.Open;
    if Not (Q1.EOF and Q1.Bof) then
    begin
      while not Q1.EOF do
      begin
        if FTriggers.IndexOf(Trim(Q1.FieldByName('rdb$trigger_name').AsString)) = -1 then
        begin
          FTriggers.Add(Trim(Q1.FieldByName('rdb$trigger_name').AsString));
          AnalyseTriggerDependencies(Trim(Q1.FieldByName('rdb$trigger_name').AsString));
        end;
        Q1.Next;
      end;
    end;


  finally
    Local.Free;
    Q1.Free;
    Q.Free;
  end;
end;


procedure TIBMetaExtract.BuildObjectDependencies;
var
  Idx : Integer;
  Local : TStringList;

begin
  //Triggers cos they affect SPs and Tables
  if FTriggers.Count > 0 then
  begin
    Local := TStringList.Create;
    try
      Local.Assign(FTriggers);
      for Idx := 0 to Local.Count - 1 do
        AnalyseTriggerDependencies(Local[Idx]);
    finally
      Local.Free;
    end;
  end;

  //SPs cos they affect tables, views, UDFs, Exceptions
  if FSPs.Count > 0 then
  begin
    Local := TStringList.Create;
    try
      Local.Assign(FSPs);
      for Idx := 0 to Local.Count - 1 do
        AnalyseSPDependencies(Local[Idx]);
    finally
      Local.Free;
    end;
  end;


  //do views cos they affect tables
  if FViews.Count > 0 then
  begin
    Local := TStringList.Create;
    try
      Local.Assign(FViews);
      for Idx := 0 to Local.Count - 1 do
        AnalyseViewDependencies(Local[Idx]);
    finally
      Local.Free;
    end;
  end;

  if FTables.Count > 0 then
  begin
    Local := TStringList.Create;
    try
      Local.Assign(FTables);
      for Idx := 0 to Local.Count - 1 do
        AnalyseTableDependencies(Local[Idx]);
    finally
      Local.Free;
    end;
  end;
end;

end.

{
$Log: MetaExtractUnit.pas,v $
Revision 1.3  2006/10/19 03:59:40  rjmills
Numerous bug fixes and current work in progress

Revision 1.2  2002/04/25 07:16:24  tmuetze
New CVS powered comment block

}
