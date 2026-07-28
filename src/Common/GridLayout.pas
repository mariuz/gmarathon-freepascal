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

unit GridLayout;

{$MODE Delphi}

{ Which columns a result grid shows, and how many of them stay put.

  A select over a wide table returns thirty columns and the one being compared
  is off the right-hand edge; hiding what is not being looked at, and freezing
  the key so it stays in view while the rest scrolls, is what makes that
  readable. vscode-mssql shipped both in its new results grid, which is where
  this item came from.

  The rules are small but each has a way of going wrong that leaves an unusable
  grid, so they are here rather than in the dialog:

    - Freezing every column leaves nothing to scroll, so the frozen count is
      always at least one short of what is visible.
    - Hiding a column that was frozen reduces the freeze with it, or the grid
      keeps a column fixed that is no longer there.
    - Hiding everything leaves a grid with no columns at all, which looks
      broken rather than empty; the last visible column will not hide.

  No LCL: this is a list of names and two flags. }

interface

uses SysUtils, Classes;

type
  TGridLayout = class
  private
    FNames: TStringList;
    FHidden: TStringList;
    FFrozen: Integer;
    function GetName(Index: Integer): String;
    function GetCount: Integer;
    function GetVisible(Index: Integer): Boolean;
    procedure SetFrozen(Value: Integer);
    function GetFrozen: Integer;
  public
    constructor Create;
    destructor Destroy; override;

    { The columns the grid has, in order. Any hiding that named a column no
      longer here is forgotten - a new result set is a new set of columns. }
    procedure SetColumns(ANames: TStrings);

    property Count: Integer read GetCount;
    property Names[Index: Integer]: String read GetName;
    property Visible[Index: Integer]: Boolean read GetVisible;

    { True when that column is shown. An unknown name is not shown, since it
      is not there at all. }
    function IsVisible(const AName: String): Boolean;
    { Hides a column. The last visible one refuses to hide: a grid with no
      columns reads as broken rather than as empty. Returns whether it did. }
    function Hide(const AName: String): Boolean;
    procedure Show(const AName: String);
    procedure ShowAll;
    function VisibleCount: Integer;
    { The visible names in order, for a caller building the grid. The caller
      owns the result. }
    function VisibleNames: TStringList;

    { How many of the visible columns stay put while the rest scrolls. Clamped
      to one less than the visible count - freezing all of them leaves nothing
      to scroll - and never below zero. }
    property FrozenCount: Integer read GetFrozen write SetFrozen;
  end;

implementation

constructor TGridLayout.Create;
begin
  inherited Create;
  FNames := TStringList.Create;
  FHidden := TStringList.Create;
  FHidden.CaseSensitive := False;
  FHidden.Sorted := True;
  FHidden.Duplicates := dupIgnore;
  FFrozen := 0;
end;

destructor TGridLayout.Destroy;
begin
  FHidden.Free;
  FNames.Free;
  inherited Destroy;
end;

procedure TGridLayout.SetColumns(ANames: TStrings);
var
  Idx: Integer;
begin
  FNames.Clear;
  if Assigned(ANames) then
    for Idx := 0 to ANames.Count - 1 do
      FNames.Add(ANames[Idx]);
  { A new result set is a new set of columns: keeping a hidden flag for a name
    that is no longer there would hide a column of the same name in an
    unrelated query. }
  FHidden.Clear;
  FFrozen := 0;
end;

function TGridLayout.GetCount: Integer;
begin
  Result := FNames.Count;
end;

function TGridLayout.GetName(Index: Integer): String;
begin
  Result := FNames[Index];
end;

function TGridLayout.IsVisible(const AName: String): Boolean;
begin
  Result := (FNames.IndexOf(AName) >= 0) and (FHidden.IndexOf(AName) < 0);
end;

function TGridLayout.GetVisible(Index: Integer): Boolean;
begin
  Result := FHidden.IndexOf(FNames[Index]) < 0;
end;

function TGridLayout.VisibleCount: Integer;
var
  Idx: Integer;
begin
  Result := 0;
  for Idx := 0 to FNames.Count - 1 do
    if GetVisible(Idx) then
      Inc(Result);
end;

function TGridLayout.Hide(const AName: String): Boolean;
begin
  Result := False;
  if FNames.IndexOf(AName) < 0 then
    Exit;
  if not IsVisible(AName) then
    Exit;
  { The last one stays. A grid showing nothing looks broken. }
  if VisibleCount <= 1 then
    Exit;
  FHidden.Add(AName);
  { A frozen column that has just gone takes its place in the freeze with it,
    or the grid keeps a column fixed that is not there any more. }
  SetFrozen(FFrozen);
  Result := True;
end;

procedure TGridLayout.Show(const AName: String);
var
  At: Integer;
begin
  At := FHidden.IndexOf(AName);
  if At >= 0 then
    FHidden.Delete(At);
end;

procedure TGridLayout.ShowAll;
begin
  FHidden.Clear;
end;

function TGridLayout.VisibleNames: TStringList;
var
  Idx: Integer;
begin
  Result := TStringList.Create;
  for Idx := 0 to FNames.Count - 1 do
    if GetVisible(Idx) then
      Result.Add(FNames[Idx]);
end;

function TGridLayout.GetFrozen: Integer;
begin
  Result := FFrozen;
end;

procedure TGridLayout.SetFrozen(Value: Integer);
var
  Limit: Integer;
begin
  if Value < 0 then
    Value := 0;
  { At least one column has to be left to scroll, or freezing is the same as
    showing nothing new. }
  Limit := VisibleCount - 1;
  if Limit < 0 then
    Limit := 0;
  if Value > Limit then
    Value := Limit;
  FFrozen := Value;
end;

end.
