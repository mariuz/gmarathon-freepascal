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

unit IconScaling;

{$MODE Delphi}

{ Which size of icon a display wants.

  The tree images were one 16-pixel strip. Forms were made to scale with the
  display earlier in this port, so on a 200% display the text grew and the
  icons did not: they either sat at 16 pixels beside 24-pixel text, or were
  stretched to fit and looked stretched. The artwork is SVG now - see icons/
  and tools/build_icons.sh - and is rendered to a strip per size, so there is
  something crisp to choose from.

  Choosing is all this unit does, and it does it without the LCL so the
  thresholds can be checked without a display. They are the ones Windows and
  the desktops offer rather than a smooth curve: 100%, 125%, 150%, 200%. A
  display at 150% gets the 24-pixel icons, which is nearer than either
  neighbour; one at 175% gets 32, because slightly-too-large is easier to read
  than slightly-too-small. }

interface

uses SysUtils;

const
  { The sizes tools/build_icons.sh renders. Adding one here means adding it
    there and adding the resource; nothing else needs to know. }
  IconSizes: array[0..2] of Integer = (16, 24, 32);
  BaseIconSize = 16;
  BaseDPI = 96;

{ The icon size for a display of that many pixels per inch. }
function IconSizeForDPI(APixelsPerInch: Integer): Integer;

{ The suffix on the resource name holding that size: '' for the base 16, and
  '_24' or '_32' for the rest. The base has no suffix because it is the
  resource this application has always had, and renaming it would break every
  strip loaded by an older build's resource file. }
function IconResourceSuffix(ASize: Integer): String;

implementation

function IconSizeForDPI(APixelsPerInch: Integer): Integer;
begin
  { Nonsense in, base size out. A display that reports nothing useful is
    commoner than it should be, and guessing large from a bad number makes
    every icon wrong. }
  if APixelsPerInch < 1 then
    Exit(BaseIconSize);

  if APixelsPerInch < 120 then
    Result := 16          { up to about 125% }
  else if APixelsPerInch < 168 then
    Result := 24          { 125% and 150% }
  else
    Result := 32;         { 175% and above }
end;

function IconResourceSuffix(ASize: Integer): String;
begin
  if ASize <= BaseIconSize then
    Result := ''
  else
    Result := '_' + IntToStr(ASize);
end;

end.
