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
// $Id: BaseDocumentDataAwareForm.pas,v 1.4 2005/05/20 19:24:08 rjmills Exp $

//Comment block moved clear up a compiler warning. RJM

{
$Log: BaseDocumentDataAwareForm.pas,v $
Revision 1.4  2005/05/20 19:24:08  rjmills
Fix for Multi-Monitor support.  The GetMinMaxInfo routines have been pulled out of the respective files and placed in to the BaseDocumentDataAwareForm.  It now correctly handles Multi-Monitor support.

There are a couple of files that are descendant from BaseDocumentForm (PrintPreview, SQLForm, SQLTrace) and they now have the corrected routines as well.

UserEditor (Which has been removed for the time being) doesn't descend from BaseDocumentDataAwareForm and it should.  But it also has the corrected MinMax routine.

Revision 1.3  2005/04/13 16:04:25  rjmills
*** empty log message ***

Revision 1.2  2002/04/25 07:21:29  tmuetze
New CVS powered comment block

}

unit BaseDocumentDataAwareForm;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
	BaseDocumentForm, Globals, MarathonInternalInterfaces, MarathonIDE,
  MarathonProjectCacheTypes, Menus;

type
	TfrmBaseDocumentDataAwareForm = class(TfrmBaseDocumentForm)
	private
    procedure MinMaxInfo(var Message: TWMGetMinMaxInfo); message wm_getminmaxinfo;
    procedure wmSysCommand(var message:twmsyscommand); message wm_syscommand;
		{ Private declarations }
	protected
		FCharSet : Byte;
		FDatabaseName: String;
		FObjectName: String;
		FNewObject: Boolean;
		FObjectModified: Boolean;
		FDropClose : Boolean;
		FIsInterbase6: Boolean;
		FSQLDialect: Integer;
		FObjectType: TGSSCacheType;
    fIsMaximized : boolean;
		procedure SetDatabaseName(const Value: String); virtual;
		function GetObjectName : String; override;
 	public
		{ Public declarations }

		function GetActiveConnectionName : String; override;
		function GetActiveObjectType : TGSSCacheType; override;
		function GetObjectNewStatus : Boolean; override;
		procedure DropClose;
		property ConnectionName : String read FDatabaseName write SetDatabaseName;
		property IsInterbase6 : Boolean read FIsInterbase6 write FIsInterbase6;
		property SQLDialect : Integer read FSQLDialect write FSQLDialect;
		property ObjectName : String read FObjectName write FObjectName;
		property NewObject : Boolean read FNewObject write FNewObject;
		property ObjectModified : Boolean read FObjectModified write FObjectModified;
		property ObjectType : TGSSCacheType read FObjectType write FObjectType;
	end;

implementation

{$R *.DFM}

procedure TfrmBaseDocumentDataAwareForm.DropClose;
begin
	FDropClose := True;
	Close;
end;

function TfrmBaseDocumentDataAwareForm.GetActiveConnectionName: String;
begin
	Result := FDatabaseName;
end;

function TfrmBaseDocumentDataAwareForm.GetActiveObjectType: TGSSCacheType;
begin
  Result := FObjectType;
end;

function TfrmBaseDocumentDataAwareForm.GetObjectName: String;
begin
  Result := FObjectName;
end;

function TfrmBaseDocumentDataAwareForm.GetObjectNewStatus: Boolean;
begin
	Result := FNewObject;
end;

procedure TfrmBaseDocumentDataAwareForm.SetDatabaseName(const Value: String);
begin
	FDatabaseName := Value;
end;

procedure TfrmBaseDocumentDataAwareForm.MinMaxInfo(var Message: TWMGetMinMaxInfo);
var
  wRect : TRect;
  wMonitor : TMonitor;
  wMarathonMonitor : TMonitor;
begin
  inherited;
  wMarathonMonitor := MarathonScreen.GetMonitor;
  if self.Monitor.MonitorNum = wMarathonMonitor.MonitorNum then //same screen as the IDE main window
  begin
     wMonitor := screen.monitors[self.Monitor.MonitorNum];
     Message.MinMaxInfo.ptMaxSize.X := wMonitor.Width + (GetSystemMetrics(SM_CXSIZEFRAME) * 2);
     Message.MinMaxInfo.ptMaxSize.y := wMonitor.Height - (MarathonIDEInstance.MainForm.FormHeight + abs(wMonitor.Top - MarathonIDEInstance.MainForm.FormTop));
     Message.MinMaxInfo.ptMaxPosition.Y := abs(wMonitor.Top - MarathonIDEInstance.MainForm.FormTop) + MarathonIDEInstance.MainForm.FormHeight;
  end;
end;

procedure TfrmBaseDocumentDataAwareForm.wmSysCommand(
  var message: twmsyscommand);
begin
   fIsMaximized := (message.CmdType = SC_MAXIMIZE);
   inherited;
end;

end.


