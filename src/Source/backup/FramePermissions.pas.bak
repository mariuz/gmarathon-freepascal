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
// $Id: FramePermissions.pas,v 1.5 2005/04/13 16:04:28 rjmills Exp $

//Comment block moved clear up a compiler warning. RJM

{
$Log: FramePermissions.pas,v $
Revision 1.5  2005/04/13 16:04:28  rjmills
*** empty log message ***

Revision 1.4  2002/04/29 11:54:53  tmuetze
Converted from TIBGSSDataset to TIBOQuery

Revision 1.3  2002/04/25 07:21:30  tmuetze
New CVS powered comment block

}

unit FramePermissions;

interface

uses 
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
	ComCtrls, Db,
	IBODataset,
	MarathonInternalInterfaces,
	MarathonProjectCacheTypes;

type
	TframePerms = class(TFrame)
		lvGrants: TListView;
    qryUtil: TIBOQuery;
	private
		{ Private declarations }
		FForm : IMarathonBaseForm;
  public
    { Public declarations }
		procedure SetActive;
		procedure Init(Form : IMarathonBaseForm);
		procedure OpenGrants;

		function CanPrint : Boolean;
		procedure DoPrint;
		procedure DoPrintPreview;
	end;

implementation

uses
	MarathonIDE;

{$R *.DFM}

function TframePerms.CanPrint: Boolean;
begin
	Result := not FFOrm.GetObjectNewStatus;
end;

procedure TframePerms.DoPrint;
begin
	MarathonIDEInstance.PrintObjectPerms(False, FForm.GetObjectName, FForm.GetActiveConnectionName, FForm.GetActiveObjectType);
end;

procedure TframePerms.DoPrintPreview;
begin
	MarathonIDEInstance.PrintObjectPerms(True, FForm.GetObjectName, FForm.GetActiveConnectionName, FForm.GetActiveObjectType);
end;

procedure TframePerms.Init(Form : IMarathonBaseForm);
begin
	FForm := Form;
end;

procedure TframePerms.OpenGrants;
var
	L : TListItem;

begin
	qryUtil.IB_Connection := MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[FForm.GetActiveConnectionName].Connection;
	qryUtil.IB_Transaction := MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[FForm.GetActiveConnectionName].Transaction;


	if qryUtil.IB_Transaction.Started then
		qryUtil.IB_Transaction.Commit;

	lvGrants.Items.BeginUpDate;
	lvGrants.Items.Clear;
	qryUtil.Close;
	qryUtil.SQL.Clear;
	case FForm.GetActiveObjectType of
    ctTable, ctView :
      begin
				qryUtil.SQL.Add('select * from rdb$user_privileges where rdb$relation_name = ' + AnsiQuotedStr(FForm.GetObjectName, '''') + ' and rdb$user <> ''SYSDBA'' order by rdb$user, rdb$privilege;');
      end;
    ctSP :
      begin
        qryUtil.SQL.Add('select * from rdb$user_privileges where rdb$relation_name = ' + AnsiQuotedStr(FForm.GetObjectName, '''') + ' and rdb$user <> ''SYSDBA'' order by rdb$user, rdb$privilege;');
      end;
  end;
  qryUtil.Open;
  While not qryUtil.EOF do
  begin
    L := lvGrants.Items.Add;
    L.Caption := qryUtil.FieldByName('rdb$user').AsString;
    L.SubItems.Add(qryUtil.FieldByName('rdb$grantor').AsString);
    L.SubItems.Add(qryUtil.FieldByName('rdb$privilege').AsString);
    L.SubItems.Add(qryUtil.FieldByName('rdb$grant_option').AsString);
    L.SubItems.Add(qryUtil.FieldByName('rdb$field_name').AsString);
    qryUtil.Next;
  end;
  lvGrants.Items.EndUpDate;
	qryUtil.Close;
	if qryUtil.IB_Transaction.Started then
		qryUtil.IB_Transaction.Commit;
end;

procedure TframePerms.SetActive;
begin
	lvGrants.SetFocus;
end;

end.


