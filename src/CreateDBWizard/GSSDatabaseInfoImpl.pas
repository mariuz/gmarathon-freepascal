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
// $Id: GSSDatabaseInfoImpl.pas,v 1.2 2002/04/25 07:15:55 tmuetze Exp $

unit GSSDatabaseInfoImpl;

interface

uses
	ComObj, ActiveX, StdVcl,
	GimbalCreateDatabase_TLB;

type
  TGSSCreateDatabaseInfo = class(TAutoObject, IGSSCreateDatabaseInfo)
  private
    FCharSet : String;
    FConnectionName : String;
    FCreateConnection : Boolean;
    FCreateProject : Boolean;
    FDialect : Integer;
    FDatabaseName : String;
    FPassword : String;
    FProjectName : String;
    FUserName : String;
  protected
    function Get_CharSet: WideString; safecall;
    function Get_ConnectionName: WideString; safecall;
    function Get_CreateConnection: WordBool; safecall;
    function Get_CreateProject: WordBool; safecall;
    function Get_DatabaseName: WideString; safecall;
    function Get_Dialect: Integer; safecall;
    function Get_Password: WideString; safecall;
    function Get_ProjectName: WideString; safecall;
    function Get_UserName: WideString; safecall;
    procedure Set_CharSet(const Value: WideString); safecall;
    procedure Set_ConnectionName(const Value: WideString); safecall;
    procedure Set_CreateConnection(Value: WordBool); safecall;
    procedure Set_CreateProject(Value: WordBool); safecall;
    procedure Set_DatabaseName(const Value: WideString); safecall;
    procedure Set_Dialect(Value: Integer); safecall;
    procedure Set_Password(const Value: WideString); safecall;
    procedure Set_ProjectName(const Value: WideString); safecall;
    procedure Set_UserName(const Value: WideString); safecall;
    { Protected declarations }
  end;

implementation

uses ComServ;

function TGSSCreateDatabaseInfo.Get_CharSet: WideString;
begin
  Result := FCharSet;
end;

function TGSSCreateDatabaseInfo.Get_ConnectionName: WideString;
begin
  Result := FConnectionName;
end;

function TGSSCreateDatabaseInfo.Get_CreateConnection: WordBool;
begin
  Result := FCreateConnection;
end;

function TGSSCreateDatabaseInfo.Get_CreateProject: WordBool;
begin
  Result := FCreateProject;
end;

function TGSSCreateDatabaseInfo.Get_DatabaseName: WideString;
begin
  Result := FDatabaseName;
end;

function TGSSCreateDatabaseInfo.Get_Dialect: Integer;
begin
  Result := FDialect;
end;

function TGSSCreateDatabaseInfo.Get_Password: WideString;
begin
  Result := FPassword;
end;

function TGSSCreateDatabaseInfo.Get_ProjectName: WideString;
begin
  Result := FProjectName;
end;

function TGSSCreateDatabaseInfo.Get_UserName: WideString;
begin
  Result := FUserName;
end;

procedure TGSSCreateDatabaseInfo.Set_CharSet(const Value: WideString);
begin
  FCharSet := Value;
end;

procedure TGSSCreateDatabaseInfo.Set_ConnectionName(
  const Value: WideString);
begin
  FConnectionName := Value;
end;

procedure TGSSCreateDatabaseInfo.Set_CreateConnection(Value: WordBool);
begin
  FCreateConnection := Value;
end;

procedure TGSSCreateDatabaseInfo.Set_CreateProject(Value: WordBool);
begin
  FCreateProject := Value;
end;

procedure TGSSCreateDatabaseInfo.Set_DatabaseName(const Value: WideString);
begin
  FDatabaseName := Value;
end;

procedure TGSSCreateDatabaseInfo.Set_Dialect(Value: Integer);
begin
  FDialect := Value;
end;

procedure TGSSCreateDatabaseInfo.Set_Password(const Value: WideString);
begin
  FPassword := Value;
end;

procedure TGSSCreateDatabaseInfo.Set_ProjectName(const Value: WideString);
begin
  FProjectName := Value;
end;

procedure TGSSCreateDatabaseInfo.Set_UserName(const Value: WideString);
begin
  FUserName := Value;
end;

initialization
	TAutoObjectFactory.Create(ComServer, TGSSCreateDatabaseInfo, Class_GSSCreateDatabaseInfo,
		ciMultiInstance, tmApartment);
end.

{
$Log: GSSDatabaseInfoImpl.pas,v $
Revision 1.2  2002/04/25 07:15:55  tmuetze
New CVS powered comment block

}
