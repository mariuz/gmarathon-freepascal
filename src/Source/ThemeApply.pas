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

unit ThemeApply;

{$MODE Delphi}

{ Painting the window in the current theme.

  The LCL has no theming. Nothing reads a palette; every control carries its
  own Color and Font.Color, defaulted to the system's, and a form assembled in
  the designer is a hundred controls each holding clBtnFace. So a theme here is
  not a setting the widgetset honours - it is a walk over every control on
  every form, assigning colours by what the control is.

  Which colour goes where is UITheme's business and is decided without a
  widgetset. This unit only knows how to reach the properties, which is the
  part that cannot be tested without one.

  Two rules keep this honest:

  - A control that was deliberately coloured keeps its colour. The environment
    band that marks a production connection, the maroon read-only notice on the
    Data tab, the error line in an editor - those carry meaning, and repainting
    them to match the theme would throw the meaning away. They register with
    KeepColour and are skipped.

  - Applying twice is the same as applying once, and switching back gives the
    original window. Nothing here reads a colour it previously wrote. }

interface

uses SysUtils, Classes, Controls, Graphics, Forms, UITheme;

{ Paints one form and everything on it. Safe to call repeatedly. }
procedure ApplyTheme(AForm: TCustomForm; AKind: TThemeKind);

{ Paints every form currently open - what a switch of the setting needs. }
procedure ApplyThemeToOpenForms(AKind: TThemeKind);

{ Recolours the shared SQL highlighter. Separate because there is one of it for
  the whole application, not one per form, so it is set when the theme changes
  rather than once per window. }
procedure ApplySyntaxTheme(AHighlighter: TObject; AKind: TThemeKind);

{ Marks a control as carrying its own meaning, so the walk leaves it alone.
  Call it after setting the colour that matters. }
procedure KeepColour(AControl: TControl);

{ True when the walk will skip this control. }
function ColourIsKept(AControl: TControl): Boolean;

{ The theme in force. Set by the shell at startup and when the setting
  changes; read by anything that builds a control after that. }
var
  CurrentTheme: TThemeKind = tkLight;

implementation

uses ComCtrls, StdCtrls, ExtCtrls, Grids, DBGrids, SynEdit, SynHighlighterSQL;

type
  { The grid colours are protected on the custom bases and only published by
    the concrete classes, so reaching them through a descendant declared here
    is the way to set them without caring which concrete grid it is. }
  TGridAccess = class(TCustomGrid);
  TDBGridAccess = class(TCustomDBGrid);

var
  { Controls that opted out. A list of references rather than a flag on the
    control, because TControl has nowhere to put one and subclassing every
    control that needs it would be a far larger change than the feature. }
  FKept: TList = nil;

procedure KeepColour(AControl: TControl);
begin
  if not Assigned(AControl) then
    Exit;
  if not Assigned(FKept) then
    FKept := TList.Create;
  if FKept.IndexOf(AControl) < 0 then
    FKept.Add(AControl);
end;

function ColourIsKept(AControl: TControl): Boolean;
begin
  Result := Assigned(FKept) and (FKept.IndexOf(AControl) >= 0);
end;

function Col(AKind: TThemeKind; ARole: TThemeRole): TColor;
begin
  Result := TColor(ThemeColor(AKind, ARole));
end;

{ One control. Split out so the recursion below stays readable, and ordered
  most specific first - a TDBGrid is a TCustomGrid is a TWinControl, and the
  first match wins. }
procedure ApplyToControl(AControl: TControl; AKind: TThemeKind);
begin
  if ColourIsKept(AControl) then
    Exit;

  { Editors and grids are where text is read, so they get the reading surface
    rather than the window. }
  if AControl is TCustomSynEdit then
  begin
    TCustomSynEdit(AControl).Color := Col(AKind, trSurface);
    TCustomSynEdit(AControl).Font.Color := Col(AKind, trSurfaceText);
    TCustomSynEdit(AControl).Gutter.Color := Col(AKind, trWindow);
    TCustomSynEdit(AControl).SelectedColor.Background := Col(AKind, trSelection);
    TCustomSynEdit(AControl).SelectedColor.Foreground := Col(AKind, trSelectionText);
    Exit;
  end;

  if AControl is TCustomDBGrid then
  begin
    TDBGridAccess(AControl).Color := Col(AKind, trSurface);
    TDBGridAccess(AControl).Font.Color := Col(AKind, trSurfaceText);
    TDBGridAccess(AControl).FixedColor := Col(AKind, trBar);
    TDBGridAccess(AControl).AlternateColor := Col(AKind, trHighlight);
    TDBGridAccess(AControl).GridLineColor := Col(AKind, trBorder);
    TDBGridAccess(AControl).SelectedColor := Col(AKind, trSelection);
    Exit;
  end;

  if AControl is TCustomGrid then
  begin
    TGridAccess(AControl).Color := Col(AKind, trSurface);
    TGridAccess(AControl).Font.Color := Col(AKind, trSurfaceText);
    TGridAccess(AControl).FixedColor := Col(AKind, trBar);
    TGridAccess(AControl).GridLineColor := Col(AKind, trBorder);
    Exit;
  end;

  if (AControl is TCustomTreeView) or (AControl is TCustomListView) or
     (AControl is TCustomListBox) or (AControl is TCustomMemo) or
     (AControl is TCustomEdit) or (AControl is TCustomComboBox) then
  begin
    TWinControl(AControl).Color := Col(AKind, trSurface);
    TWinControl(AControl).Font.Color := Col(AKind, trSurfaceText);
    Exit;
  end;

  { Chrome: bars sit slightly apart from the window behind them. }
  if (AControl is TToolBar) or (AControl is TStatusBar) then
  begin
    TWinControl(AControl).Color := Col(AKind, trBar);
    TWinControl(AControl).Font.Color := Col(AKind, trBarText);
    Exit;
  end;

  if (AControl is TCustomPage) or (AControl is TCustomTabControl) or
     (AControl is TCustomPanel) or (AControl is TCustomGroupBox) then
  begin
    TWinControl(AControl).Color := Col(AKind, trWindow);
    TWinControl(AControl).Font.Color := Col(AKind, trWindowText);
    Exit;
  end;

  { A label or a speed button draws straight onto whatever is behind it, so it
    only needs its text to stay readable. }
  if (AControl is TCustomLabel) or (AControl is TGraphicControl) then
  begin
    AControl.Font.Color := Col(AKind, trWindowText);
    Exit;
  end;

  if AControl is TWinControl then
  begin
    TWinControl(AControl).Color := Col(AKind, trWindow);
    TWinControl(AControl).Font.Color := Col(AKind, trWindowText);
  end;
end;

procedure ApplyToTree(AControl: TControl; AKind: TThemeKind);
var
  Idx: Integer;
begin
  ApplyToControl(AControl, AKind);
  { Children after the parent, so a child that opted out is not overwritten by
    a parent's ParentColor pushing a colour down. }
  if AControl is TWinControl then
    for Idx := 0 to TWinControl(AControl).ControlCount - 1 do
      ApplyToTree(TWinControl(AControl).Controls[Idx], AKind);
end;

procedure ApplyTheme(AForm: TCustomForm; AKind: TThemeKind);
begin
  if not Assigned(AForm) then
    Exit;
  AForm.DisableAlign;
  try
    AForm.Color := Col(AKind, trWindow);
    AForm.Font.Color := Col(AKind, trWindowText);
    ApplyToTree(AForm, AKind);
  finally
    AForm.EnableAlign;
  end;
  AForm.Invalidate;
end;

procedure ApplySyntaxTheme(AHighlighter: TObject; AKind: TThemeKind);
var
  H: TSynSQLSyn;
begin
  if not (AHighlighter is TSynSQLSyn) then
    Exit;
  H := TSynSQLSyn(AHighlighter);
  H.KeyAttri.Foreground := TColor(SyntaxColor(AKind, srKeyword));
  H.CommentAttri.Foreground := TColor(SyntaxColor(AKind, srComment));
  H.StringAttri.Foreground := TColor(SyntaxColor(AKind, srString));
  H.NumberAttri.Foreground := TColor(SyntaxColor(AKind, srNumber));
  H.SymbolAttri.Foreground := TColor(SyntaxColor(AKind, srSymbol));
  H.IdentifierAttri.Foreground := TColor(SyntaxColor(AKind, srIdentifier));
  H.TableNameAttri.Foreground := TColor(SyntaxColor(AKind, srTableName));
end;

procedure ApplyThemeToOpenForms(AKind: TThemeKind);
var
  Idx: Integer;
begin
  CurrentTheme := AKind;
  for Idx := 0 to Screen.FormCount - 1 do
    ApplyTheme(Screen.Forms[Idx], AKind);
end;

initialization

finalization
  FreeAndNil(FKept);

end.
