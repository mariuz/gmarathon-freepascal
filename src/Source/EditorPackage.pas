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

unit EditorPackage;

{$MODE Delphi}

{ Viewer for a Firebird 3 package.

  Read-only on purpose. A package is edited as a whole - header and body are
  separate objects that have to be recreated together, and getting that wrong
  invalidates every routine that depends on the package - so this shows what is
  there and leaves changing it to the SQL editor, which "Script as CREATE" on
  the tree node fills in for you. Header and body are shown separately because
  a package may legitimately have a header and no body. }

interface

uses
  {$IFDEF FPC} LCLIntf, LCLType, LMessages, {$ELSE} Windows, Messages, {$ENDIF}
  SysUtils, Classes, Graphics, Controls, Forms, Dialogs, ComCtrls, StdCtrls,
  Menus, IBDatabase, IBQuery, BaseDocumentDataAwareForm,
  MarathonInternalInterfaces, MarathonProjectCacheTypes, FrameMetadata,
  SyntaxMemoWithStuff2;

type
  TfrmPackageEditor = class(TfrmBaseDocumentDataAwareForm)
    pgObjectEditor: TPageControl;
    tsHeader: TTabSheet;
    tsBody: TTabSheet;
    tsDDL: TTabSheet;
    edHeader: TSyntaxMemoWithStuff2;
    edBody: TSyntaxMemoWithStuff2;
    framDDL: TframDisplayDDL;
    stsEditor: TStatusBar;
    qryPackage: TIBQuery;
    procedure FormCreate(Sender: TObject);
    procedure pgObjectEditorChange(Sender: TObject);
  private
    FBodyPresent: Boolean;
  public
    procedure LoadPackage(PackageName: String);
    { True when the package has a body as well as a header. }
    property BodyPresent: Boolean read FBodyPresent;
  end;

implementation

uses Globals, MarathonIDE;

{$R *.lfm}

procedure TfrmPackageEditor.FormCreate(Sender: TObject);
var
  TmpIntf: IMarathonForm;
begin
  FObjectType := ctPackage;
  LoadFormPosition(Self);
  TmpIntf := Self;
  framDDL.Init(TmpIntf);
end;

procedure TfrmPackageEditor.pgObjectEditorChange(Sender: TObject);
begin
  if pgObjectEditor.ActivePage = tsDDL then
  begin
    framDDL.SetActive;
    framDDL.GetDDL;
  end;
end;

procedure TfrmPackageEditor.LoadPackage(PackageName: String);
var
  Conn: TObject;
begin
  FObjectName := PackageName;
  FNewObject := False;
  Caption := 'Package - [' + PackageName + ']';
  InternalCaption := Caption;

  qryPackage.Database := MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[ConnectionName].Connection;
  qryPackage.Transaction := MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[ConnectionName].Transaction;
  if not qryPackage.Transaction.Active then
    qryPackage.Transaction.StartTransaction;
  try
    qryPackage.SQL.Text :=
      'select rdb$package_header_source, rdb$package_body_source ' +
      'from rdb$packages where rdb$package_name = ' + AnsiQuotedStr(PackageName, '''');
    qryPackage.Open;
    if not qryPackage.EOF then
    begin
      edHeader.Lines.Text := qryPackage.FieldByName('rdb$package_header_source').AsString;
      edBody.Lines.Text := qryPackage.FieldByName('rdb$package_body_source').AsString;
    end
    else
    begin
      edHeader.Lines.Clear;
      edBody.Lines.Clear;
    end;
    qryPackage.Close;
  finally
    if qryPackage.Transaction.Active then
      qryPackage.Transaction.Commit;
  end;

  FBodyPresent := Trim(edBody.Lines.Text) <> '';
  if FBodyPresent then
    stsEditor.Panels[0].Text := 'Header and body'
  else
    { Not an error: a package can be declared and left unimplemented. }
    stsEditor.Panels[0].Text := 'Header only - this package has no body';
  stsEditor.Panels[1].Text := ConnectionName;
end;

end.
