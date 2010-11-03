{******************************************************************}
{ The contents of this file are used with permission, subject to	 }
{ the Mozilla Public License Version 1.1 (the "License"); you may  }
{ not use this file except in compliance with the License. You may }
{ obtain a copy of the License at 																 }
{ http://www.mozilla.org/MPL/MPL-1.1.html 												 }
{ 																																 }
{ Software distributed under the License is distributed on an 		 }
{ "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, either express or	 }
{ implied. See the License for the specific language governing		 }
{ rights and limitations under the License. 											 }
{ 																																 }
{******************************************************************} 
// $Id: SplashForm.pas,v 1.6 2002/08/28 14:53:19 tmuetze Exp $

unit SplashForm;

interface

uses
	Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
	ExtCtrls, StdCtrls, jpeg;

type
	TfrmSplash = class(TForm)
		Timer1: TTimer;
    imgSplash: TImage;
    Shape1: TShape;
    lblVersion: TLabel;
		procedure Timer1Timer(Sender: TObject);
		procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
	private
		{ Private declarations }
	public
		{ Public declarations }
	end;

var
	frmSplash: TfrmSplash;

implementation

uses
	Tools;

{$R *.DFM}

procedure TfrmSplash.Timer1Timer(Sender: TObject);
begin
	Close;
end;

procedure TfrmSplash.FormClose(Sender: TObject; var Action: TCloseAction);
begin
	Action := caFree;
end;

procedure TfrmSplash.FormCreate(Sender: TObject);
var
	iExeVer1, iExeVer2, iExeVer3, iExeVer4: Word;
begin
	Tools.GetBuildInfo(Application.ExeName, iExeVer1, iExeVer2, iExeVer3, iExeVer4);
	lblVersion.Caption := IntToStr(iExeVer1) + '.' + IntToStr(iExeVer2) + '.' + IntToStr(iExeVer3) + '.' + IntToStr(iExeVer4);
end;

end.

{
$Log: SplashForm.pas,v $
Revision 1.6  2002/08/28 14:53:19  tmuetze
Added build info

Revision 1.5  2002/04/25 07:21:30  tmuetze
New CVS powered comment block

}
