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

{$MODE Delphi}

interface

uses {$IFDEF FPC}
  LCLIntf, LCLType, LMessages, {$ELSE}
  Windows, Messages, {$ENDIF}
  SysUtils, Classes, Graphics, Controls, Forms, Dialogs, StdCtrls, Grids, ComCtrls;

type
	TfrmBlobViewer = class(TForm)
		btnOK: TButton;
		btnCancel: TButton;
		pgBlobViewer: TPageControl;
		tsText: TTabSheet;
		tsHex: TTabSheet;
		edBlobHex: TMemo;		edBlobText: TMemo;
		tsJson: TTabSheet;
		edBlobJson: TMemo;
		procedure pgBlobViewerChanging(Sender: TObject;	var AllowChange: Boolean);
		procedure btnOKClick(Sender: TObject);
		procedure FormKeyDown(Sender: TObject; var Key: Word;	Shift: TShiftState);
		procedure FormCreate(Sender: TObject);
		procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    FData: TMemoryStream;
    FReadOnly: Boolean;
    FBinary: Boolean;
    procedure ShowJsonView(const AText: String);
    procedure SetData(const Value: TMemoryStream);
    procedure SetReadOnly(const Value: Boolean);
    { Private declarations }
  public
		{ Public declarations }
		property Data : TMemoryStream read FData write SetData;
		{ Asked for by the caller - but a binary blob is read-only whatever the
		  caller wants, since a memo cannot hold one without changing it. }
		property ReadOnly : Boolean read FReadOnly write SetReadOnly;
		{ True when the blob is not text. Public so a caller can say why the
		  editing it asked for is not on offer. }
		property IsBinary : Boolean read FBinary;
	end;

implementation

{$R *.lfm}

uses Globals, BlobText;

const
	{ A blob can be megabytes, and a memo asked to hold the dump of all of it
	  stops being a window and becomes a wait. Sixty-four kilobytes is four
	  thousand lines, which is more than anyone reads. }
	HexViewLimit = 64 * 1024;

procedure TfrmBlobViewer.SetData(const Value: TMemoryStream);
begin
	FData := Value;
	if not Assigned(FData) then
	begin
		edBlobText.Lines.Clear;
		edBlobHex.Lines.Clear;
		edBlobJson.Lines.Clear;
		tsJson.TabVisible := False;
		FBinary := False;
		Exit;
	end;

	FData.Position := 0;
	edBlobText.Lines.LoadFromStream(FData);

	{ The tab says Hex, so it is hex. It used to load the same text into the
	  second memo, which showed the same thing twice for a text blob and
	  mojibake twice for a binary one. }
	FData.Position := 0;
	edBlobHex.Lines.Text := HexDump(FData, HexViewLimit);
	{ A view, not an editor: writing hex back would need it parsed, and nothing
	  here does that. }
	edBlobHex.ReadOnly := True;

	ShowJsonView(edBlobText.Lines.Text);

	{ A binary blob cannot survive a memo - line endings are normalised and
	  anything unprintable is lost - so it is shown and not edited, whatever
	  the caller asked for. Before this, opening one and pressing OK wrote the
	  memo's transcription back over it. }
	FData.Position := 0;
	FBinary := IsBinaryData(FData);
	FData.Position := 0;
	if FBinary then
	begin
		edBlobText.ReadOnly := True;
		Caption := Caption + ' - binary, shown read-only';
	end;
end;

{ Firebird has no JSON type - a document lives in a BLOB SUB_TYPE TEXT, and
  the 6.0.0 server has none of the SQL/JSON functions either - so nothing on
  the server side will say that what was stored is malformed. This will.

  The tab is there when the blob *starts* like JSON rather than when it parses:
  a document that begins with a brace and then goes wrong is exactly the case
  where someone wants to see where. }
procedure TfrmBlobViewer.ShowJsonView(const AText: String);
var
	Formatted, Error_: String;
begin
	tsJson.TabVisible := (not FBinary) and LooksLikeJSON(AText);
	if not tsJson.TabVisible then
	begin
		edBlobJson.Lines.Clear;
		Exit;
	end;

	Formatted := FormatJSON(AText, Error_);
	if Error_ = '' then
		edBlobJson.Lines.Text := Formatted
	else
		{ The parser's message carries the line and position, which is the useful
		  half of being told a document is broken. }
		edBlobJson.Lines.Text := 'This is not valid JSON.' + #13#10#13#10 + Error_;
end;

procedure TfrmBlobViewer.pgBlobViewerChanging(Sender: TObject; var AllowChange: Boolean);
begin
	{ Nothing. This used to write whichever memo was being left back into the
	  blob and re-load the other from it, so merely *looking* at the hex tab
	  rewrote the blob - through a memo, which is what made it lossy. The hex
	  side is rendered once, when the data arrives, and the blob is only
	  written when OK is pressed. }
	AllowChange := True;
end;

procedure TfrmBlobViewer.btnOKClick(Sender: TObject);
begin
	{ Only ever from the text side, and only when this blob can be edited at
	  all: the hex tab is a rendering, and writing it back would put the dump
	  itself into the blob - which is what happened when OK was pressed while
	  that tab was in front. }
	if Assigned(FData) and not FReadOnly and not FBinary then
	begin
		FData.Clear;
		edBlobText.Lines.SaveToStream(FData);
		FData.Position := 0;
	end;
	ModalResult := mrOK;
end;

procedure TfrmBlobViewer.SetReadOnly(const Value: Boolean);
begin
	FReadOnly := Value;
	edBlobText.ReadOnly := FReadOnly or FBinary;
	{ The hex side is always a view. }
	edBlobHex.ReadOnly := True;
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


