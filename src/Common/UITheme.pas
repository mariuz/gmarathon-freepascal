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

unit UITheme;

{$MODE Delphi}

{ The colours, and which part of the window each one is for.

  Only the decisions live here - no LCL, no controls - so a palette can be
  checked without a widgetset. Walking a form and assigning the colours is
  ThemeApply's job.

  A role rather than a colour at each use site. "The background behind text you
  can edit" is a fact about the window that stays true in both themes; #1E1E1E
  is not. Every caller asks for the role, so adding a third palette later means
  adding a column here rather than finding every literal.

  The values are the VS Code Dark+ and Light+ defaults, because that is the
  look this was asked to resemble and because both have had far more attention
  paid to their contrast than anything invented here would get. }

interface

uses SysUtils;

type
  { Which way round the window is. }
  TThemeKind = (tkLight, tkDark);

  { What a colour is for. Named by the job, not the appearance. }
  TThemeRole = (
    { The window itself, and panels that are only chrome. }
    trWindow,
    { Text on trWindow. }
    trWindowText,
    { Anywhere text is read or edited - editors, grids, trees, lists. }
    trSurface,
    { Text on trSurface. }
    trSurfaceText,
    { Lines between things: grid rules, panel edges, splitters. }
    trBorder,
    { The selected row, or selected text. }
    trSelection,
    trSelectionText,
    { A row the mouse is over, and the alternating band in a grid. }
    trHighlight,
    { Toolbars and the status bar, which sit slightly apart from the window. }
    trBar,
    trBarText,
    { The accent - the active tab's underline, focus rings, links. }
    trAccent,
    { Something the user should not miss: a destructive action, an error. }
    trDanger);

{ The colour for a role, as $00BBGGRR - the order a TColor holds. Kept as a
  plain integer so this unit needs no Graphics. }
function ThemeColor(AKind: TThemeKind; ARole: TThemeRole): Integer;

{ True when a theme wants light text on dark, which is the question most
  "should I invert this" decisions actually turn on. }
function IsDarkTheme(AKind: TThemeKind): Boolean;

{ The syntax colours, which are the same kind of decision as the rest and just
  as unreadable if left alone - the stock SQL highlighter writes navy keywords
  and green comments, both of which vanish against #1E1E1E. VS Code's Dark+ and
  Light+ token colours. }
type
  TSyntaxRole = (srKeyword, srComment, srString, srNumber, srSymbol,
    srIdentifier, srTableName);

function SyntaxColor(AKind: TThemeKind; ARole: TSyntaxRole): Integer;

{ The stored form of the setting, and back. Text rather than the ordinal so a
  file written by a build that knew two themes still reads on one that knows
  three. }
function ThemeKindToText(AKind: TThemeKind): String;
function TextToThemeKind(const AText: String; ADefault: TThemeKind): TThemeKind;

implementation

{ Written $00BBGGRR, which is the reverse of the #RRGGBB these are usually
  quoted as - so VS Code's #1E1E1E editor background is $001E1E1E only because
  its three bytes happen to be equal, while #007ACC is $00CC7A00. Getting this
  backwards produces a plausible-looking palette in the wrong hues, so each
  entry carries the hex it came from. }
const
  Palette: array[TThemeKind, TThemeRole] of Integer = (
    { tkLight }
    (
      $00F3F3F3,   // trWindow         #F3F3F3
      $00000000,   // trWindowText     #000000
      $00FFFFFF,   // trSurface        #FFFFFF
      $00000000,   // trSurfaceText    #000000
      $00CECECE,   // trBorder         #CECECE
      $00D7AD00,   // trSelection      #00ADD7 -> VS Code light selection
      $00000000,   // trSelectionText  #000000
      $00F0F0F0,   // trHighlight      #F0F0F0
      $00DDDDDD,   // trBar            #DDDDDD
      $00000000,   // trBarText        #000000
      $00CC7A00,   // trAccent         #007ACC
      $002020C7    // trDanger         #C72020
    ),
    { tkDark }
    (
      $002D2D25,   // trWindow         #252D2D -> VS Code dark chrome
      $00D4D4D4,   // trWindowText     #D4D4D4
      $001E1E1E,   // trSurface        #1E1E1E
      $00D4D4D4,   // trSurfaceText    #D4D4D4
      $003F3F3F,   // trBorder         #3F3F3F
      $007A4926,   // trSelection      #26497A
      $00FFFFFF,   // trSelectionText  #FFFFFF
      $002A2A2A,   // trHighlight      #2A2A2A
      $00333333,   // trBar            #333333
      $00CCCCCC,   // trBarText        #CCCCCC
      $00CC7A00,   // trAccent         #007ACC
      $005555F1    // trDanger         #F15555
    )
  );

function ThemeColor(AKind: TThemeKind; ARole: TThemeRole): Integer;
begin
  Result := Palette[AKind, ARole];
end;

const
  Syntax: array[TThemeKind, TSyntaxRole] of Integer = (
    { tkLight }
    (
      $00FF0000,   // srKeyword     #0000FF
      $00008000,   // srComment     #008000
      $002A2AA5,   // srString      #A52A2A
      $00098709,   // srNumber      #098709
      $00000000,   // srSymbol      #000000
      $00000000,   // srIdentifier  #000000
      $00801F26    // srTableName   #261F80
    ),
    { tkDark }
    (
      $00D69C56,   // srKeyword     #569CD6
      $004A9955,   // srComment     #559A4A
      $007891CE,   // srString      #CE9178
      $00A8CEB5,   // srNumber      #B5CEA8
      $00D4D4D4,   // srSymbol      #D4D4D4
      $00FEDC9C,   // srIdentifier  #9CDCFE
      $00A6DCB5    // srTableName   #B5DCA6
    )
  );

function SyntaxColor(AKind: TThemeKind; ARole: TSyntaxRole): Integer;
begin
  Result := Syntax[AKind, ARole];
end;

function IsDarkTheme(AKind: TThemeKind): Boolean;
begin
  Result := AKind = tkDark;
end;

function ThemeKindToText(AKind: TThemeKind): String;
begin
  case AKind of
    tkDark: Result := 'Dark';
  else
    Result := 'Light';
  end;
end;

function TextToThemeKind(const AText: String; ADefault: TThemeKind): TThemeKind;
var
  S: String;
begin
  S := UpperCase(Trim(AText));
  if S = 'DARK' then
    Result := tkDark
  else
    if S = 'LIGHT' then
      Result := tkLight
    else
      { An empty setting, or one naming a theme this build does not have. }
      Result := ADefault;
end;

end.
