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

unit BlobText;

{$MODE Delphi}

{ Showing a blob: as a hex dump, and deciding whether it is text at all.

  The blob viewer had a tab labelled Hex that loaded the blob into a second
  memo as text - there was no hex anywhere in it - and it wrote whatever the
  memos held back into the blob when the tab was switched or OK was pressed.
  For a binary blob that is not a viewer, it is a shredder: a memo normalises
  line endings and stops at what it cannot render, so opening a JPEG and
  pressing OK replaced it with a mangled transcription of itself.

  Both halves of the fix are decisions about bytes, so they are here and can be
  checked without a window. }

interface

uses SysUtils, Classes;

const
  { Bytes per line of the dump. Sixteen is what every hex dump does, and it
    makes the offsets read in whole rows. }
  HexDumpWidth = 16;

{ True when these bytes are not text.

  A NUL settles it: no text blob Firebird stores contains one, and every binary
  format does. Beyond that it is a proportion - a stray control byte can appear
  in text that was written by something careless, but a run of them means the
  blob is not text.

  Empty data is text: there is nothing in it to be binary. }
function IsBinaryData(AData: TStream): Boolean; overload;
function IsBinaryData(const AData: TBytes): Boolean; overload;

{ The classic three-column dump: offset, the bytes in hex, and the printable
  ones again on the right. A byte that cannot be shown is a dot there, which is
  what makes the gutter readable rather than a second copy of the noise.

  ALimit caps how much is rendered - a blob can be megabytes, and a memo asked
  to hold all of it stops being a window and becomes a wait. Zero means no
  limit. When the dump is cut short it says so on the last line, because a
  dump that silently stops looks like a blob that ends there. }
function HexDump(AData: TStream; ALimit: Integer = 0): String; overload;
function HexDump(const AData: TBytes; ALimit: Integer = 0): String; overload;

implementation

function StreamBytes(AData: TStream): TBytes;
begin
  SetLength(Result, 0);
  if not Assigned(AData) then
    Exit;
  AData.Position := 0;
  SetLength(Result, AData.Size);
  if Length(Result) > 0 then
    AData.ReadBuffer(Result[0], Length(Result));
  AData.Position := 0;
end;

function IsBinaryData(const AData: TBytes): Boolean;
var
  Idx, Odd_: Integer;
begin
  Result := False;
  if Length(AData) = 0 then
    Exit;
  Odd_ := 0;
  for Idx := 0 to Length(AData) - 1 do
  begin
    { A NUL is the one byte that settles it on its own. }
    if AData[Idx] = 0 then
      Exit(True);
    { Tab, line feed and carriage return are text; the rest of the low range
      is not, and neither is DEL. }
    if ((AData[Idx] < 32) and not (AData[Idx] in [9, 10, 13])) or
       (AData[Idx] = 127) then
      Inc(Odd_);
  end;
  { One in twenty. Text with the odd control byte in it stays text; a run of
    them does not. }
  Result := (Odd_ * 20) > Length(AData);
end;

function IsBinaryData(AData: TStream): Boolean;
begin
  Result := IsBinaryData(StreamBytes(AData));
end;

function HexDump(const AData: TBytes; ALimit: Integer): String;
var
  Lines: TStringList;
  Idx, Shown, LineStart, Col: Integer;
  Hex_, Ascii_: String;
  B: Byte;
begin
  Lines := TStringList.Create;
  try
    Shown := Length(AData);
    if (ALimit > 0) and (Shown > ALimit) then
      Shown := ALimit;

    LineStart := 0;
    while LineStart < Shown do
    begin
      Hex_ := '';
      Ascii_ := '';
      for Col := 0 to HexDumpWidth - 1 do
      begin
        Idx := LineStart + Col;
        if Idx < Shown then
        begin
          B := AData[Idx];
          Hex_ := Hex_ + IntToHex(B, 2) + ' ';
          if (B >= 32) and (B < 127) then
            Ascii_ := Ascii_ + Chr(B)
          else
            Ascii_ := Ascii_ + '.';
        end
        else
          { Padded, so the gutter of a short last line still lines up with the
            ones above it. }
          Hex_ := Hex_ + '   ';
      end;
      Lines.Add(IntToHex(LineStart, 8) + '  ' + Hex_ + ' ' + Ascii_);
      Inc(LineStart, HexDumpWidth);
    end;

    if Shown < Length(AData) then
      Lines.Add('... ' + IntToStr(Length(AData) - Shown) +
        ' more byte(s) not shown');
    Result := Lines.Text;
  finally
    Lines.Free;
  end;
end;

function HexDump(AData: TStream; ALimit: Integer): String;
begin
  Result := HexDump(StreamBytes(AData), ALimit);
end;

end.
