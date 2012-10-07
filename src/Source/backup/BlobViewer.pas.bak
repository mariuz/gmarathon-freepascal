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
// $Id: BlobViewer.pas,v 1.4 2005/04/13 16:04:26 rjmills Exp $

//Comment block moved to remove compiler warning. RJM

{
$Log: BlobViewer.pas,v $
Revision 1.4  2005/04/13 16:04:26  rjmills
*** empty log message ***

Revision 1.3  2002/09/23 10:31:16  tmuetze
FormOnKeyDown now works with Shift+Tab to cycle backwards through the pages

Revision 1.2  2002/04/25 07:21:29  tmuetze
New CVS powered comment block

}

unit BlobViewer;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
	StdCtrls, Grids, ComCtrls,
	Hexeditor,
	rmCornerGrip;

type
	TfrmBlobViewer = class(TForm)
		btnOK: TButton;
		btnCancel: TButton;
		pgBlobViewer: TPageControl;
		tsText: TTabSheet;
		tsHex: TTabSheet;
		edBlobHex: THexEditor;
		edBlobText: TMemo;
		rmCornerGrip1: TrmCornerGrip;
		procedure pgBlobViewerChanging(Sender: TObject;	var AllowChange: Boolean);
		procedure btnOKClick(Sender: TObject);
		procedure FormKeyDown(Sender: TObject; var Key: Word;	Shift: TShiftState);
		procedure FormCreate(Sender: TObject);
		procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    FData: TMemoryStream;
    FReadOnly: Boolean;
    procedure SetData(const Value: TMemoryStream);
    procedure SetReadOnly(const Value: Boolean);
    { Private declarations }
  public
		{ Public declarations }
		property Data : TMemoryStream read FData write SetData;
		property ReadOnly : Boolean read FReadOnly write SetReadOnly;
	end;

implementation

{$R *.DFM}

uses
	Globals;

procedure TfrmBlobViewer.SetData(const Value: TMemoryStream);
begin
	FData := Value;
	FData.Position := 0;
	edBlobText.Lines.LoadFromStream(FData);
	FData.Position := 0;
	edBlobHex.LoadFromStream(FData);
end;

procedure TfrmBlobViewer.pgBlobViewerChanging(Sender: TObject; var AllowChange: Boolean);
begin
  case pgBlobViewer.ActivePage.PageIndex of
    0 :
      begin
        //save current...
        fData.Clear;
        edBlobText.Lines.SaveToStream(FData);

        //load others...
        FData.Position := 0;
        edBlobHex.LoadFromStream(FData);
      end;

		1 :
			begin
				//save current...
        fdata.clear;
				edBlobHex.SaveToStream(FData);

				//load others...
				FData.Position := 0;
				edBlobText.Lines.LoadFromStream(FData);
			end;
	end;
end;

procedure TfrmBlobViewer.btnOKClick(Sender: TObject);
begin
	case pgBlobViewer.ActivePage.PageIndex of
		0 :
			begin
				//save current...
        fData.Clear;
				edBlobText.Lines.SaveToStream(FData);
			end;

		1 :
			begin
				//save current...
        fData.Clear;
				edBlobHex.SaveToStream(FData);
			end;
	end;
  fData.Position := 0;
	ModalResult := mrOK;
end;

procedure TfrmBlobViewer.SetReadOnly(const Value: Boolean);
begin
	FReadOnly := Value;
	edBlobText.ReadOnly := FReadOnly;
	edBlobHex.ReadOnlyView := FReadOnly;
end;

procedure TfrmBlobViewer.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
	if (Shift = [ssCtrl, ssShift]) and (Key = VK_TAB) then
		ProcessPriorTab(pgBlobViewer)
	else
		if (Shift = [ssCtrl]) and (Key = VK_TAB) then
			ProcessNextTab(pgBlobViewer);
end;

procedure TfrmBlobViewer.FormCreate(Sender: TObject);
begin
  LoadFormPosition(Self);
end;

procedure TfrmBlobViewer.FormClose(Sender: TObject;	var Action: TCloseAction);
begin
  SaveFormPosition(Self);
end;

end.


