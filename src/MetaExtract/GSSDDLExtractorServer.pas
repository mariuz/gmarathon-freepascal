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
// $Id: GSSDDLExtractorServer.pas,v 1.3 2002/04/25 07:16:24 tmuetze Exp $

unit GSSDDLExtractorServer;

interface

uses
  ComObj, ActiveX, AxCtrls, gssscript_TLB, DDLExtractor, IBHeader,
  IBDatabase, Forms, StdVcl, Classes, Controls;

type
  TGSSDDLExtractor = class(TAutoObject, IGSSDDLExtractor)
  private
    { Private declarations }
    FDatabase : TIBDatabase;
    FTransaction : TIBTransaction;
    FIsIB6 : Boolean;
    FSQLDialect : Integer;
    FExtractor : TDDLExtractor;
    FAppHandle : Integer;
    FObjectList : TStringList;

    //properties for wizard...
    FMetaCreateDatabase : Boolean;
    FMetaExtractType : Integer;
    FMetaIncludePassword : Boolean;
    FMetaIncludeDependents : Boolean;
    FMetaIncludeDoc : Boolean;
    FMetaDecimalPlaces : Integer;
    FMetaDecimalSeperator : String;
    FMetaWrapOutput : Boolean;
    FMetaWrapOutputAt : Integer;
    FMetaDBPassword : String;
    FMetaDBUserName : String;
    FMetaDBDatabaseName : String;
    FMetaDefaultDirectory : String;
  public
    procedure Initialize; override;
    destructor Destroy; override;
  protected
    { Protected declarations }
    function Extract(ObjectType, ObjectSubType: Integer;
      const ObjectName: WideString): WideString; safecall;
    procedure Set_DatabaseHandle(Value: Integer); safecall;
    function DoWizard(const UserName, Password: WideString): WordBool;
      safecall;
    procedure Set_AppHandle(Value: Integer); safecall;
    function Get_MetaCreateDatabase: WordBool; safecall;
    function Get_MetaExtractType: Integer; safecall;
    function Get_MetaIncludePassword: WordBool; safecall;
    procedure Set_MetaCreateDatabase(Value: WordBool); safecall;
    procedure Set_MetaExtractType(Value: Integer); safecall;
    procedure Set_MetaIncludePassword(Value: WordBool); safecall;
    function Get_MetaIncludeDependents: WordBool; safecall;
    procedure Set_MetaIncludeDependents(Value: WordBool); safecall;
    function Get_MetaDecimalPlaces: Integer; safecall;
    function Get_MetaDecimalSeperator: WideString; safecall;
    function Get_MetaWrapOutput: WordBool; safecall;
    procedure Set_MetaDecimalPlaces(Value: Integer); safecall;
    procedure Set_MetaDecimalSeperator(const Value: WideString); safecall;
    procedure Set_MetaWrapOutput(Value: WordBool); safecall;
    function Get_MetaWrapOutputAt: Integer; safecall;
    procedure Set_MetaWrapOutputAt(Value: Integer); safecall;
    procedure Set_MetaDBPassword(const Value: WideString); safecall;
    procedure Set_MetaDBUserName(const Value: WideString); safecall;
    procedure AddObjectInfo(const ObjectName: WideString; ObjectType: Integer);
      safecall;
    procedure DoWizardList; safecall;
    procedure Set_IB6(Value: WordBool); safecall;
    procedure Set_SQLDialect(Value: Integer); safecall;
    procedure Set_MetaDBDatabaseName(const Value: WideString); safecall;
    procedure Set_MetaDefaultDirectory(const Value: WideString); safecall;
    function Get_MetaIncludeDoc: WordBool; safecall;
    procedure Set_MetaIncludeDoc(Value: WordBool); safecall;
  end;

implementation

uses
  ComServ,
  MarathonProjectCacheTypes,
  GlobalMigrateWizard;


procedure TGSSDDLExtractor.Initialize;
begin
  inherited Initialize;
  FExtractor := TDDLExtractor.Create(nil);
  FDatabase := TIBDatabase.Create(nil);
  FDatabase.LoginPrompt := False;
  FTransaction := TIBTransaction.Create(nil);
  FDatabase.DefaultTransaction := FTransaction;
  FExtractor.Database := FDatabase;
  FExtractor.Transaction := FTransaction;
  FObjectList := TStringList.Create;
end;

function TGSSDDLExtractor.Extract(ObjectType, ObjectSubType: Integer; const ObjectName: WideString): WideString;
begin
  FExtractor.IsInterbase6 := FIsIB6;
  FExtractor.SQLDialect := FSQLDialect;
  FExtractor.IncludeDoc := False;
  if not FTransaction.InTransaction then
    FTransaction.StartTransaction;
  Result := FExtractor.Extract(TDDLObjectType(ObjectType), TDDLSubType(ObjectSubType), ObjectName);
  if FTransaction.InTransaction then
    FTransaction.Commit;
end;

procedure TGSSDDLExtractor.Set_DatabaseHandle(Value: Integer);
begin
  FDatabase.SQLDialect := FSQLDialect;
  FDatabase.SetHandle(TISC_DB_HANDLE(Value));
end;


function TGSSDDLExtractor.DoWizard(const UserName,
  Password: WideString): WordBool;
var
  F : TfrmGlobalMigrateWizard;

begin
  Application.Handle := FAppHandle;
  F := TfrmGlobalMigrateWizard.Create(nil);
  try
    F.Database := FDatabase;
    F.Transaction := FTransaction;
    //load properties...
    F.chkCreateDatabase.Checked := FMetaCreateDatabase;
    F.rdoMigrate.ItemIndex := FMetaExtractType;
    F.chkInclPassword.Checked := FMetaIncludePassword;
    F.chkInclDependents.Checked := FMetaIncludeDependents;
    F.chkIncludeDoc.Checked := FMetaIncludeDoc;
    F.udDecPlaces.Position := FMetaDecimalPlaces;
    F.cmbDecSep.Text := FMetaDecimalSeperator;
    F.chkWrapat.Checked := FMetaWrapOutput;
    F.upWrap.Position := FMetaWrapOutputAt;
    F.UserName := FMetaDBUserName;
    F.Password := FMetaDBPassword;
    F.DatabaseName := FMetaDBDatabaseName;
    F.SQLDialect := FSQLDialect;
    F.IsIB6 := FIsIB6;
    F.DefaultDirectory := FMetaDefaultDirectory;
    if F.ShowModal = mrOK then
      Result := True
    else
      Result := False;
    //save properties...
    FMetaCreateDatabase := F.chkCreateDatabase.Checked;
    FMetaExtractType := F.rdoMigrate.ItemIndex;
    FMetaIncludePassword := F.chkInclPassword.Checked;
    FMetaIncludeDependents := F.chkInclDependents.Checked;
    FMetaIncludeDoc := F.chkIncludeDoc.Checked;
    FMetaDecimalPlaces := F.udDecPlaces.Position;
    FMetaDecimalSeperator := F.cmbDecSep.Text;
    FMetaWrapOutput := F.chkWrapat.Checked;
    FMetaWrapOutputAt := F.upWrap.Position;
  finally
    F.Free;
  end;
end;

destructor TGSSDDLExtractor.Destroy;
var
  Idx : Integer;
begin
  FExtractor.Free;
  FTransaction.Free;
  FDatabase.Free;
  for Idx := 0 to FObjectList.Count - 1 do
    TDDLObjectAtom(FObjectList.Objects[Idx]).Free;
    
  FObjectList.Free;
end;

procedure TGSSDDLExtractor.Set_AppHandle(Value: Integer);
begin
  FAppHandle := Value;
end;

function TGSSDDLExtractor.Get_MetaCreateDatabase: WordBool;
begin
  Result := FMetaCreateDatabase;
end;

function TGSSDDLExtractor.Get_MetaExtractType: Integer;
begin
  Result := FMetaExtractType;
end;


function TGSSDDLExtractor.Get_MetaIncludePassword: WordBool;
begin
  Result := FMetaIncludePassword;
end;

procedure TGSSDDLExtractor.Set_MetaCreateDatabase(Value: WordBool);
begin
  FMetaCreateDatabase := Value;
end;

procedure TGSSDDLExtractor.Set_MetaExtractType(Value: Integer);
begin
  FMetaExtractType := Value;
end;


procedure TGSSDDLExtractor.Set_MetaIncludePassword(Value: WordBool);
begin
  FMetaIncludePassword := Value;
end;

function TGSSDDLExtractor.Get_MetaIncludeDependents: WordBool;
begin
  Result := FMetaIncludeDependents;
end;

procedure TGSSDDLExtractor.Set_MetaIncludeDependents(Value: WordBool);
begin
  FMetaIncludeDependents := Value;
end;

function TGSSDDLExtractor.Get_MetaDecimalPlaces: Integer;
begin
  Result := FMetaDecimalPlaces;
end;

function TGSSDDLExtractor.Get_MetaDecimalSeperator: WideString;
begin
  Result := FMetaDecimalSeperator;
end;

function TGSSDDLExtractor.Get_MetaWrapOutput: WordBool;
begin
  Result := FMetaWrapOutput;
end;

procedure TGSSDDLExtractor.Set_MetaDecimalPlaces(Value: Integer);
begin
  FMetaDecimalPlaces := Value;
end;

procedure TGSSDDLExtractor.Set_MetaDecimalSeperator(
  const Value: WideString);
begin
  FMetaDecimalSeperator := Value;
end;

procedure TGSSDDLExtractor.Set_MetaWrapOutput(Value: WordBool);
begin
  FMetaWrapOutput := Value;
end;

function TGSSDDLExtractor.Get_MetaWrapOutputAt: Integer;
begin
  Result := FMetaWrapOutputAt;
end;

procedure TGSSDDLExtractor.Set_MetaWrapOutputAt(Value: Integer);
begin
  FMetaWrapOutputAt := Value;
end;

procedure TGSSDDLExtractor.Set_MetaDBPassword(const Value: WideString);
begin
  FMetaDBPassword := Value;
end;

procedure TGSSDDLExtractor.Set_MetaDBUserName(const Value: WideString);
begin
  FMetaDBUserName := Value;
end;

procedure TGSSDDLExtractor.AddObjectInfo(const ObjectName: WideString; ObjectType: Integer);
var
  Item : TDDLObjectAtom;

begin
  Item := TDDLObjectATom.Create;
  Item.ObjectName := ObjectName;
  Item.ObjectType := TGSSCacheType(ObjectType);
  FObjectList.AddObject(ObjectName, Item);
end;

procedure TGSSDDLExtractor.DoWizardList;
var
  F : TfrmGlobalMigrateWizard;

begin
  Application.Handle := FAppHandle;
  F := TfrmGlobalMigrateWizard.Create(nil);
  try
    F.Database := FDatabase;
    F.Transaction := FTransaction;
    //load properties...
    F.chkCreateDatabase.Checked := FMetaCreateDatabase;
    F.rdoMigrate.ItemIndex := FMetaExtractType;
    F.chkInclPassword.Checked := FMetaIncludePassword;
    F.chkInclDependents.Checked := FMetaIncludeDependents;
    F.chkIncludeDoc.Checked := FMetaIncludeDoc;
    F.udDecPlaces.Position := FMetaDecimalPlaces;
    F.cmbDecSep.Text := FMetaDecimalSeperator;
    F.chkWrapat.Checked := FMetaWrapOutput;
    F.upWrap.Position := FMetaWrapOutputAt;
    F.UserName := FMetaDBUserName;
    F.Password := FMetaDBPassword;
    F.DatabaseName := FMetaDBDatabaseName;
    F.SQLDialect := FSQLDialect;
    F.IsIB6 := FIsIB6;
    F.DefaultDirectory := FMetaDefaultDirectory;
    F.ObjectList.Assign(FObjectList);
    F.ShowModal;
    //save properties...
    FMetaCreateDatabase := F.chkCreateDatabase.Checked;
    FMetaExtractType := F.rdoMigrate.ItemIndex;
    FMetaIncludePassword := F.chkInclPassword.Checked;
    FMetaIncludeDependents := F.chkInclDependents.Checked;
    FMetaIncludeDoc := F.chkIncludeDoc.CHecked;
    FMetaDecimalPlaces := F.udDecPlaces.Position;
    FMetaDecimalSeperator := F.cmbDecSep.Text;
    FMetaWrapOutput := F.chkWrapat.Checked;
    FMetaWrapOutputAt := F.upWrap.Position;
  finally
    F.Free;
  end;
end;

procedure TGSSDDLExtractor.Set_IB6(Value: WordBool);
begin
  FIsIB6 := Value;
end;

procedure TGSSDDLExtractor.Set_SQLDialect(Value: Integer);
begin
  FSQLDialect := Value;
end;

procedure TGSSDDLExtractor.Set_MetaDBDatabaseName(const Value: WideString);
begin
  FMetaDBDatabaseName := Value;
end;

procedure TGSSDDLExtractor.Set_MetaDefaultDirectory(
  const Value: WideString);
begin
  FMetaDefaultDirectory := Value;
end;

function TGSSDDLExtractor.Get_MetaIncludeDoc: WordBool;
begin
  Result := FMetaIncludeDoc;
end;

procedure TGSSDDLExtractor.Set_MetaIncludeDoc(Value: WordBool);
begin
  FMetaIncludeDoc := Value;
end;

initialization
  TAutoObjectFactory.Create(ComServer, TGSSDDLExtractor, Class_GSSDDLExtractor,
    ciMultiInstance, tmApartment);
end.

{ Old History

	* Minor change to reflect change of cmdMigrate combobox to rdoMograte RadioGroup (john)
}

{
$Log: GSSDDLExtractorServer.pas,v $
Revision 1.3  2002/04/25 07:16:24  tmuetze
New CVS powered comment block

}
