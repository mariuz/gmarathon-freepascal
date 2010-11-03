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
// $Id: AboutBox.pas,v 1.13 2003/11/05 05:57:20 figmentsoft Exp $

unit AboutBox;

interface

uses
	Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
	StdCtrls, ExtCtrls, Buttons,
	IB_Components;

type
	TfrmAboutBox = class(TForm)
		Bevel1: TBevel;
		btnClose: TButton;
		Label5: TLabel;
		lblMemoryStatus: TLabel;
    lblIBO: TLabel;
    dbDummy: TIB_Connection;
    scbx3rdParty: TScrollBox;
    lblIBObjects: TLabel;
    Label3: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Label7: TLabel;
    lblQueryBuilder: TLabel;
    Label2: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Bevel2: TBevel;
    Label14: TLabel;
    Label15: TLabel;
    lbl3rdParty: TLabel;
		lblVersion: TLabel;
    cbxCredits: TComboBox;
    lblSupport: TLabel;
    Label13: TLabel;
    scbxContributors: TScrollBox;
    Bevel5: TBevel;
    Label30: TLabel;
    Label31: TLabel;
    Label32: TLabel;
    Label33: TLabel;
    lblContributors: TLabel;
    Label36: TLabel;
    Label37: TLabel;
    imgMarathon: TImage;
    Label4: TLabel;
    Label6: TLabel;
    Label16: TLabel;
    Label17: TLabel;
    Label18: TLabel;
    Label19: TLabel;
    Label20: TLabel;
    Label21: TLabel;
    imgIBO: TImage;
    Bevel3: TBevel;
    Bevel4: TBevel;
    Label1: TLabel;
    Label22: TLabel;
    Label23: TLabel;
    Label24: TLabel;
    Label25: TLabel;
    Label26: TLabel;
    Label27: TLabel;
    Label28: TLabel;
    Label29: TLabel;
    Label34: TLabel;
    Label35: TLabel;
    Label38: TLabel;
    Label39: TLabel;
    Label40: TLabel;
    Label41: TLabel;
		procedure FormCreate(Sender: TObject);
		procedure btnCloseClick(Sender: TObject);
    procedure WebLabelsClick(Sender: TObject);
    procedure cbxCreditsChange(Sender: TObject);
    procedure MailLabelsClick(Sender: TObject);
	private
		{ Private declarations }
	public
		{ Public declarations }
	end;

var
	frmAboutBox: TfrmAboutBox;

implementation

uses
	Tools;

{$R *.DFM}

procedure TfrmAboutBox.FormCreate(Sender: TObject);
var
	MS : TMemoryStatus;
	iExeVer1, iExeVer2, iExeVer3, iExeVer4: Word;
begin
	lblIBO.Caption := lblIBO.Caption + '(' + dbDummy.Version + ')';
	GlobalMemoryStatus(MS);
	lblMemoryStatus.Caption := Format('%.0n KB', [StrToFloat(IntToStr(MS.dwTotalPhys div 1024))]);
	Tools.GetBuildInfo(Application.ExeName, iExeVer1, iExeVer2, iExeVer3, iExeVer4);
	lblVersion.Caption := lblVersion.Caption + IntToStr(iExeVer1) + '.' + IntToStr(iExeVer2) + '.' + IntToStr(iExeVer3) + '.' + IntToStr(iExeVer4);
	cbxCredits.ItemIndex := 0;
	cbxCredits.OnChange(Sender);
	scbxContributors.ScrollInView(lblContributors);
	scbx3rdParty.ScrollInView(lbl3rdParty);
end;

procedure TfrmAboutBox.btnCloseClick(Sender: TObject);
begin
	Close;
end;

procedure TfrmAboutBox.WebLabelsClick(Sender: TObject);
begin
	Tools.ExecuteWin32Program((Sender as TLabel).Caption);
end;

procedure TfrmAboutBox.MailLabelsClick(Sender: TObject);
begin
	Tools.ExecuteWin32Program('mailto:' + (Sender as TLabel).Caption);
end;

procedure TfrmAboutBox.cbxCreditsChange(Sender: TObject);
begin
	if (cbxCredits.ItemIndex = 0) then
		scbxContributors.BringToFront
	else
		scbx3rdParty.BringToFront;
end;

end.

{ Old History
	20.03.2002	tmuetze
		* Removed the BevelInner, BevelOuter from the TScrollBox components, to enhance
			D5 compatibilty
}

{
$Log: AboutBox.pas,v $
Revision 1.13  2003/11/05 05:57:20  figmentsoft
I have learn the hard way that if I don't give myself a little credit, then people will view my work as trash.  So I'm adding my credits into this humble AboutBox.

Revision 1.12  2003/03/12 18:56:44  tmuetze
Added Ignacio, changed the rmControls contact information

Revision 1.11  2002/09/23 10:28:52  tmuetze
Added Paul Gittings

Revision 1.10  2002/05/29 10:59:21  tmuetze
Added Pavel Odstrcil

Revision 1.9  2002/04/30 14:39:21  tmuetze
Added two component credits

Revision 1.8  2002/04/25 07:14:47  tmuetze
New CVS powered comment block

}
