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

unit PrintRenderer;

{$MODE Delphi}

{ Putting a paginated document on a canvas - a printer's or a preview's.

  PrintDocument decided what goes on each page without knowing what a printer
  is; this is the other half, and it is deliberately thin. Everything it does
  is the same for paper and for the preview window, so the preview shows what
  will actually come out rather than an approximation of it: one function draws
  a page into a rectangle, and both callers use it.

  The font is fixed-pitch because the layout measured itself in characters. Its
  size is chosen to make the requested number of characters span the rectangle,
  so the same document fills whatever paper it is given. }

interface

uses SysUtils, Classes, Graphics, Printers, PrintDocument;

type
  TPageMetrics = record
    LinesPerPage: Integer;
    CharsPerLine: Integer;
  end;

{ What will fit on the current printer's page, in characters.

  Falls back to a sensible A4-ish grid when there is no printer configured at
  all, which is the normal state of a machine that has only ever been asked to
  preview - and asking Printer.PageHeight without one raises. }
function PrinterPageMetrics: TPageMetrics;

{ Draws one page into ARect using a fixed-pitch font sized so CharsPerLine
  characters span the rectangle's width. }
procedure RenderPage(ACanvas: TCanvas; APage: TPrintPage;
  const ARect: TRect; CharsPerLine: Integer);

{ Sends the whole document to the default printer. Returns False when there is
  no printer to send it to, so the caller can say so rather than failing
  silently. }
function PrintToPrinter(ADocument: TPrintedDocument; const AJobTitle: String;
  CharsPerLine: Integer): Boolean;

implementation

const
  { A4 at 10 characters per inch and six lines per inch, less a margin all
    round. Only used when there is no printer to ask. }
  DefaultLines = 60;
  DefaultChars = 96;
  { A quarter-inch margin expressed as a fraction of the page. }
  MarginFraction = 0.04;

function PrinterPageMetrics: TPageMetrics;
begin
  Result.LinesPerPage := DefaultLines;
  Result.CharsPerLine := DefaultChars;
  try
    if Printer.Printers.Count = 0 then
      Exit;
    { Both are in device units, so their ratio is the page's shape. Keeping the
      character grid roughly proportional to it stops a landscape page being
      laid out as though it were portrait. }
    if (Printer.PageWidth > 0) and (Printer.PageHeight > 0) then
    begin
      Result.CharsPerLine := DefaultChars;
      Result.LinesPerPage := Round(DefaultChars *
        (Printer.PageHeight / Printer.PageWidth) * 0.55);
      if Result.LinesPerPage < 20 then
        Result.LinesPerPage := 20;
    end;
  except
    { A printer that cannot be interrogated is not a reason to refuse to lay
      the document out - the preview does not need one at all. }
    on E: Exception do
    begin
      Result.LinesPerPage := DefaultLines;
      Result.CharsPerLine := DefaultChars;
    end;
  end;
end;

{ The largest point size at which CharsPerLine characters still fit across
  AWidth. Found by measuring rather than by calculating from the point size:
  what a font actually measures depends on the device, and on a printer at 600
  dpi it is not what it is on screen. }
function FitFontHeight(ACanvas: TCanvas; AWidth, CharsPerLine: Integer): Integer;
var
  Low_, High_, Mid, W: Integer;
  Probe: String;
begin
  Probe := StringOfChar('M', CharsPerLine);
  Low_ := 4;
  High_ := 400;
  Result := Low_;
  while Low_ <= High_ do
  begin
    Mid := (Low_ + High_) div 2;
    ACanvas.Font.Height := Mid;
    W := ACanvas.TextWidth(Probe);
    if (W > 0) and (W <= AWidth) then
    begin
      Result := Mid;
      Low_ := Mid + 1;
    end
    else
      High_ := Mid - 1;
  end;
end;

procedure RenderPage(ACanvas: TCanvas; APage: TPrintPage;
  const ARect: TRect; CharsPerLine: Integer);
var
  Idx, Y, LineHeight, Usable: Integer;
begin
  if not Assigned(APage) then
    Exit;

  ACanvas.Font.Name := 'Courier New';
  ACanvas.Font.Pitch := fpFixed;
  ACanvas.Font.Style := [];
  ACanvas.Font.Color := clBlack;

  Usable := ARect.Right - ARect.Left;
  if Usable < 10 then
    Exit;
  ACanvas.Font.Height := FitFontHeight(ACanvas, Usable, CharsPerLine);

  LineHeight := ACanvas.TextHeight('Mg');
  if LineHeight < 1 then
    Exit;
  { If the chosen size makes the page taller than the rectangle - a very wide,
    short page - shrink until the lines fit too. }
  while (LineHeight * APage.Lines.Count > ARect.Bottom - ARect.Top) and
        (ACanvas.Font.Height > 4) do
  begin
    ACanvas.Font.Height := ACanvas.Font.Height - 1;
    LineHeight := ACanvas.TextHeight('Mg');
    if LineHeight < 1 then
      Exit;
  end;

  Y := ARect.Top;
  for Idx := 0 to APage.Lines.Count - 1 do
  begin
    if Y + LineHeight > ARect.Bottom then
      Break;
    if Trim(APage.Lines[Idx]) <> '' then
      ACanvas.TextOut(ARect.Left, Y, APage.Lines[Idx]);
    Inc(Y, LineHeight);
  end;
end;

function PrintToPrinter(ADocument: TPrintedDocument; const AJobTitle: String;
  CharsPerLine: Integer): Boolean;
var
  Idx: Integer;
  R: TRect;
  MarginX, MarginY: Integer;
begin
  Result := False;
  if not Assigned(ADocument) or (ADocument.PageCount = 0) then
    Exit;
  if Printer.Printers.Count = 0 then
    Exit;

  Printer.Title := AJobTitle;
  Printer.BeginDoc;
  try
    MarginX := Round(Printer.PageWidth * MarginFraction);
    MarginY := Round(Printer.PageHeight * MarginFraction);
    for Idx := 0 to ADocument.PageCount - 1 do
    begin
      { NewPage before each page but the first - calling it after the last
        would eject a blank sheet. }
      if Idx > 0 then
        Printer.NewPage;
      R := Rect(MarginX, MarginY, Printer.PageWidth - MarginX,
        Printer.PageHeight - MarginY);
      RenderPage(Printer.Canvas, ADocument[Idx], R, CharsPerLine);
    end;
    Result := True;
  finally
    Printer.EndDoc;
  end;
end;

end.
