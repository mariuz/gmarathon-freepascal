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
// $Id: GSSCreateDatabaseImpl.pas,v 1.2 2002/04/25 07:15:55 tmuetze Exp $

unit GSSCreateDatabaseImpl;

interface

uses
	ComObj, ActiveX, StdVcl,
	GimbalCreateDatabase_TLB;

type
  TGSSCreateDatabase = class(TAutoObject, IGSSCreateDatabase)
  private
  protected
    function Execute(AppHandle, CallingApp,
      State: Integer): IGSSCreateDatabaseInfo; safecall;
    { Protected declarations }
  end;

implementation

uses
  ComServ,
  CreateDatabase,
  GSSCreateDatabaseConsts,
  GSSDatabaseInfoImpl,
  Controls,
  Forms;

function TGSSCreateDatabase.Execute(AppHandle, CallingApp,
  State: Integer): IGSSCreateDatabaseInfo;
var
  F : TfrmCreateDatabase;

begin
  Application.Handle := AppHandle;
	F := TfrmCreateDatabase.Create(nil);
	try
		F.State := State;
		F.CallingApp := CallingApp;
		if F.ShowModal = mrOK then
		begin
			Result := TGSSCreateDatabaseInfo.Create;
			Result.DatabaseName := F.edDBName.Text;
			Result.UserName := F.edUser.Text;
			Result.Password := F.edPassword.Text;
			Result.CharSet := F.cmbCharSet.Text;
			Result.Dialect := F.cmbDialect.ItemIndex + 1;
			if F.chkFurtherAction.Checked then
			begin
				Result.CreateProject := F.rbCreateProject.Checked;
				Result.CreateConnection := F.rbCreateConnection.Checked;
				Result.ConnectionName := F.edConnectionName.Text;
				Result.ProjectName := F.edProjectName.Text;
			end
			else
			begin
				Result.CreateProject := False;
				Result.CreateConnection := False;
				Result.ConnectionName := '';
				Result.ProjectName := '';
			end;
		end
		else
			Result := nil;
	finally
    F.Free;
  end;
end;

initialization
  TAutoObjectFactory.Create(ComServer, TGSSCreateDatabase, Class_GSSCreateDatabase,
    ciMultiInstance, tmApartment);
end.

{
$Log: GSSCreateDatabaseImpl.pas,v $
Revision 1.2  2002/04/25 07:15:55  tmuetze
New CVS powered comment block

}
