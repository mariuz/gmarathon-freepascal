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

unit DocumentHost;

{$MODE Delphi}

{ Hosting document windows as tabs.

  Marathon opens every table, view, procedure and SQL editor as its own
  floating window. This puts them in one tab control instead, which is the
  arrangement the VS Code MSSQL extension uses and the point of Phase 9.

  A form is not rebuilt to be a tab: it is reparented into a tab sheet, its
  border removed and its alignment set to fill. That matters for a port of this
  size - fourteen document forms keep working exactly as they are, and the
  change is to where they are shown rather than to what they contain.

  The host owns nothing. Closing a document frees the form as it always did,
  and the tab goes with it; dropping the host puts nothing at risk. }

interface

uses SysUtils, Classes, Controls, Forms, ComCtrls;

type
  TDocumentHost = class(TComponent)
  private
    FPages: TPageControl;
    procedure FormClosed(Sender: TObject; var Action: TCloseAction);
    function SheetOf(AForm: TForm): TTabSheet;
  public
    constructor Create(AOwner: TComponent; APages: TPageControl); reintroduce;
    { Puts AForm in a tab and shows it. Returns the sheet, or nil when there is
      nowhere to put it - a caller that gets nil should fall back to showing the
      form as a window, so a shell that failed to build cannot lose a document. }
    function Host(AForm: TForm): TTabSheet;
    { True when the form is already in a tab, so a second open activates the
      existing one rather than adding a duplicate. }
    function IsHosted(AForm: TForm): Boolean;
    { Brings an already-hosted form's tab to the front. }
    function Activate(AForm: TForm): Boolean;
    { The form in the active tab, or nil. }
    function ActiveDocument: TForm;
    function DocumentCount: Integer;
    property Pages: TPageControl read FPages;
  end;

var
  { The shell's host, set by the main form once its layout exists. Nil until
    then, and nil in anything that does not build a shell - a test harness, or
    the application before its main window is up - so callers check it. }
  Documents: TDocumentHost = nil;

implementation

constructor TDocumentHost.Create(AOwner: TComponent; APages: TPageControl);
begin
  inherited Create(AOwner);
  FPages := APages;
end;

function TDocumentHost.SheetOf(AForm: TForm): TTabSheet;
var
  Idx: Integer;
begin
  Result := nil;
  if not Assigned(FPages) or not Assigned(AForm) then
    Exit;
  for Idx := 0 to FPages.PageCount - 1 do
    if FPages.Pages[Idx].Tag = PtrInt(AForm) then
    begin
      Result := FPages.Pages[Idx];
      Exit;
    end;
end;

function TDocumentHost.IsHosted(AForm: TForm): Boolean;
begin
  Result := Assigned(SheetOf(AForm));
end;

function TDocumentHost.Activate(AForm: TForm): Boolean;
var
  Sheet: TTabSheet;
begin
  Sheet := SheetOf(AForm);
  Result := Assigned(Sheet);
  if Result then
    FPages.ActivePage := Sheet;
end;

function TDocumentHost.Host(AForm: TForm): TTabSheet;
begin
  Result := nil;
  if not Assigned(FPages) or not Assigned(AForm) then
    Exit;

  { Already open: raise it rather than add a second tab for the same window. }
  Result := SheetOf(AForm);
  if Assigned(Result) then
  begin
    FPages.ActivePage := Result;
    Exit;
  end;

  Result := FPages.AddTabSheet;
  { The sheet remembers which form it holds. A tag rather than a field because
    the sheet outlives nothing and is found by scanning - there is no list to
    keep in step, so there is no list to get wrong. }
  Result.Tag := PtrInt(AForm);
  Result.Caption := AForm.Caption;

  AForm.BorderStyle := bsNone;
  AForm.Parent := Result;
  AForm.Align := alClient;
  { The form's own close handling still runs; this only removes the tab
    afterwards, so a document that refuses to close keeps its tab. }
  AForm.AddHandlerClose(FormClosed);
  AForm.Show;
  FPages.ActivePage := Result;
end;

procedure TDocumentHost.FormClosed(Sender: TObject; var Action: TCloseAction);
var
  Sheet: TTabSheet;
begin
  if not (Sender is TForm) then
    Exit;
  Sheet := SheetOf(TForm(Sender));
  if not Assigned(Sheet) then
    Exit;

  { Detach first: the sheet is the form's parent, and freeing a parent from
    inside the child's close handler leaves the form to be released later - by
    the application's async queue, when Action is caFree - with a parent that
    has gone. That is an access violation in the form's own destructor, and it
    happens after the close looks to have succeeded. }
  TForm(Sender).Parent := nil;
  { Forget it now, so a second close or a lookup in between cannot find a sheet
    that is on its way out. }
  Sheet.Tag := 0;
  { And release the sheet the same way the form is released, rather than in the
    middle of the form's own teardown. }
  Application.ReleaseComponent(Sheet);
end;

function TDocumentHost.ActiveDocument: TForm;
begin
  Result := nil;
  if Assigned(FPages) and Assigned(FPages.ActivePage) and
     (FPages.ActivePage.Tag <> 0) then
    Result := TForm(Pointer(FPages.ActivePage.Tag));
end;

function TDocumentHost.DocumentCount: Integer;
begin
  if Assigned(FPages) then
    Result := FPages.PageCount
  else
    Result := 0;
end;

end.
