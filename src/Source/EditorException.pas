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
// $Id: EditorException.pas,v 1.5 2005/05/20 19:24:08 rjmills Exp $

unit EditorException;

interface

uses
	Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
	DB, Menus, ComCtrls, DBCtrls, StdCtrls, Printers, ExtCtrls, ClipBrd, ActnList,
	IBODataset,
	BaseDocumentDataAwareForm,
	MarathonInternalInterfaces,
	MarathonProjectCacheTypes,
	FrameDescription,
	FrameMetadata;

type
  TfrmExceptions = class(TfrmBaseDocumentDataAwareForm)
    pgObjectEditor: TPageControl;
    tsObject: TTabSheet;
    tsDocoView: TTabSheet;
    Label1: TLabel;
    edExceptionName: TEdit;
    Label2: TLabel;
    edExceptionText: TEdit;
    qryException: TIBOQuery;
    tsDDL: TTabSheet;
    framDoco: TframeDesc;
    stsEditor: TStatusBar;
    framDDL: TframDisplayDDL;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure edExceptionNameChange(Sender: TObject);
    procedure edExceptionTextChange(Sender: TObject);
		procedure pgObjectEditorChanging(Sender: TObject; var AllowChange: Boolean);
		procedure pgObjectEditorChange(Sender: TObject);
		procedure FormResize(Sender: TObject);
		procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
	private
		{ Private declarations }
		FErrors : Boolean;
		It : TMenuItem;
		procedure WindowListClick(Sender: TObject);
		procedure WMMove(var Message : TMessage); message WM_MOVE;
	public
		{ Public declarations }
		procedure LoadException(ExceptionName : String);
		procedure NewException;
		function InternalCloseQuery : Boolean; override;
		procedure SetObjectName(Value : String); override;
    procedure SetObjectModified(Value : Boolean); override;
    procedure SetDatabaseName(const Value: String); override;
    function GetActiveStatusBar : TStatusBar; override;

    function CanPrint : Boolean; override;
    procedure DoPrint; override;

    function CanPrintPreview : Boolean; override;
    procedure DoPrintPreview; override;

    function CanViewNextPage : Boolean; override;
    procedure DOViewNextPage; override;

    function CanViewPrevPage : Boolean; override;
    procedure DOViewPrevPage; override;

    function CanObjectDrop : Boolean; override;
    procedure DoObjectDrop; override;

    function CanCompile : Boolean; override;
    procedure DoCompile; override;

    function CanSaveDoco : Boolean; override;
    procedure DoSaveDoco; override;

		function CanUndo : Boolean; override;
    procedure DoUndo; override;

    function CanRedo : Boolean; override;
    procedure DoRedo; override;

    function CanCaptureSnippet : Boolean; override;
    procedure DoCaptureSnippet; override;

    function CanCut : Boolean; override;
    procedure DoCut; override;

    function CanCopy : Boolean; override;
    procedure DoCopy; override;

    function CanPaste : Boolean; override;
    procedure DoPaste; override;

    function CanFind : Boolean; override;
    procedure DoFind; override;

    function CanFindNext : Boolean; override;
    procedure DoFindNext; override;

    function CanReplace : Boolean; override;
    procedure DoReplace; override;

    function CanSelectAll : Boolean; override;
    procedure DoSelectAll;  override;

		procedure ProjectOptionsRefresh; override;
		procedure EnvironmentOptionsRefresh; override;
	end;

implementation

uses
	Globals,
	HelpMap,
	MarathonIDE,
	CompileDBObject,
	DropObject;

{$R *.DFM}

const
	PG_EXCEPT      = 0;
	PG_DOCO        = 1;
	PG_DDL         = 2;

procedure TfrmExceptions.WindowListClick(Sender: TObject);
begin
	if WindowState = wsMinimized then
    WindowState := wsNormal
  else
    BringToFront;
end;

procedure TfrmExceptions.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  inherited;
  IT.Free;
  Action := caFree;
end;

procedure TfrmExceptions.FormCreate(Sender: TObject);
var
  TmpIntf : IMarathonForm;

begin
  inherited;
  FObjectType := ctException;

	HelpContext := IDH_Exceptions_Editor;

  pgObjectEditor.ActivePage := tsObject;

	Top := MarathonIDEInstance.MainForm.FormTop + MarathonIDEInstance.MainForm.FormHeight + 2;
  Left := MarathonScreen.Left + (MarathonScreen.Width div 4) + 4;
  Height := (MarathonScreen.Height Div 2) + MarathonIDEInstance.MainForm.FormHeight;
  Width := MarathonScreen.Width - Left + MarathonScreen.Left;

  It := TMenuItem.Create(Self);
  It.Caption := '&1 Exception - [' + FObjectName + ']';
  It.OnClick := WindowListClick;
  MarathonIDEInstance.AddMenuToMainForm(IT);

  TmpIntf := Self;
  framDoco.Init(TmpIntf);
  framDDL.Init(TmpIntf);
end;

procedure TfrmExceptions.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
	if FDropClose or FByPassCLose then
		CanClose := True
	else
		CanClose := InternalCloseQuery;
end;

procedure TfrmExceptions.edExceptionNameChange(Sender: TObject);
begin
	FObjectModified := True;
	CheckNameLength(edExceptionName.Text);
end;

procedure TfrmExceptions.edExceptionTextChange(Sender: TObject);
begin
	FObjectModified := True;
end;

procedure TfrmExceptions.pgObjectEditorChanging(Sender: TObject; var AllowChange: Boolean);
begin
	if FNewObject then
  begin
    MessageDlg('You cannot change to Documentation View until the object has been compiled.', mtWarning, [mbOK], 0);
    AllowChange := False;
  end
  else
  begin
    case pgObjectEditor.ActivePage.PageIndex of
      PG_DOCO:
        begin
          if framDoco.Modified then
          begin
            if MessageDlg('Save changes to documentation?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
              framDoco.SaveDoco;
          end;
        end;
    end;
  end;
end;

procedure TfrmExceptions.pgObjectEditorChange(Sender: TObject);
begin
	case pgObjectEditor.ActivePage.PageIndex of
		PG_EXCEPT:
			begin
				stsEditor.Panels[0].Text := '';
				stsEditor.Panels[1].Text := '';
				stsEditor.Panels[2].Text := '';
				edExceptionName.SetFocus;
			end;
		PG_DOCO:
			begin
				framDoco.SetActive;
			end;
		PG_DDL:
			begin
				framDDL.SetActive;
				if not FNewObject then
					framDDL.GetDDL;
			end;
	end;
end;

procedure TfrmExceptions.FormResize(Sender: TObject);
begin
	MarathonIDEInstance.CurrentProject.Modified := True;
end;

procedure TfrmExceptions.WMMove(var Message: TMessage);
begin
	MarathonIDEInstance.CurrentProject.Modified := True;
	inherited;
end;

procedure TfrmExceptions.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
	if (Shift = [ssCtrl, ssShift]) and (Key = VK_TAB) then
		ProcessPriorTab(pgObjectEditor)
	else
		if (Shift = [ssCtrl]) and (Key = VK_TAB) then
			ProcessNextTab(pgObjectEditor);
end;

function TfrmExceptions.InternalCloseQuery: Boolean;
begin
  if Not FDropClose then
  begin
    Result := True;
    if FObjectModified then
    begin
      case MessageDlg('The exception ' + FObjectName + ' has changed. Do you wish to save changes?', mtConfirmation, [mbYes, mbNo, mbCancel], 0) of
        mrYes:
          begin
            DoCompile;
            if FErrors then
              Result := False
            else
              Result := True;
          end;
        mrCancel :
          Result := False;
        mrNo :
          begin
            Result := True;
            FObjectModified := False;
          end;
      end;
    end;
    if framDoco.Modified then
    begin
      case MessageDlg('The documentation for exception ' + FObjectName + ' has changed. Do you wish to save changes?', mtConfirmation, [mbYes, mbNo, mbCancel], 0) of
        mrYes:
          begin
            framDoco.SaveDoco;
          end;
        mrCancel :
					Result := False;
        mrNo :
          begin
            Result := True;
            framDoco.Modified := False;
          end;  
      end;
    end;
  end
  else
    Result := True;
end;

function TfrmExceptions.GetActiveStatusBar: TStatusBar;
begin
  Result := stsEditor;
end;

procedure TfrmExceptions.SetDatabaseName(const Value: String);
begin
  inherited;
  if Value = '' then
  begin
    qryException.IB_Connection := nil;
    framDoco.qryDoco.IB_Connection := nil;
    framDoco.qryDoco.IB_Transaction := nil;
    IsInterbase6 := False;
    SQLDialect := 0;
    stsEditor.Panels[3].Text := 'No Connection';
  end
  else
  begin
    qryException.IB_Connection := MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[Value].Connection;
    qryException.IB_Transaction := MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[Value].Transaction;

    framDoco.qryDoco.IB_Connection := MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[Value].Connection;
    framDoco.qryDoco.IB_Transaction := MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[Value].Transaction;

    IsInterbase6 := MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[Value].IsIB6;
		SQLDialect := qryException.IB_Connection.SQLDialect;
    stsEditor.Panels[3].Text := Value;
  end;
end;

procedure TfrmExceptions.SetObjectModified(Value: Boolean);
begin
  inherited;
  FObjectModified := True;
end;

procedure TfrmExceptions.SetObjectName(Value: String);
begin
  inherited;
  FObjectName := Value;
  InternalCaption := 'Exception - [' + FObjectName + ']';
  IT.Caption := Caption;
end;

procedure TfrmExceptions.LoadException(ExceptionName: String);
begin
  try
    qryException.BeginBusy(False);
    qryException.SQL.Clear;
    qryException.SQL.Add('select rdb$exception_name, rdb$message from rdb$exceptions where rdb$exception_name = ''' + ExceptionName + ''';');
    qryException.Open;
    edExceptionName.Text := qryException.FieldByName('rdb$exception_name').AsString;
    edExceptionText.Text := qryException.FieldByName('rdb$message').AsString;
    qryException.Close;
    qryException.IB_Transaction.Commit;

    FObjectName := ExceptionName;
    InternalCaption := 'Exception - [' + FObjectName + ']';

    FObjectModified := False;
    FNewObject := False;

    framDoco.LoadDoco;
  finally
		qryException.EndBusy;
  end;
end;

procedure TfrmExceptions.NewException;
begin
  FObjectName := 'new_exception';
  InternalCaption := 'Exception - [' + FObjectName + ']';
  edExceptionName.Text := FObjectName;
  edExceptionText.Text := '';
  ActiveControl := edExceptionText;
  FObjectModified := True;
  FNewObject := True;
end;

function TfrmExceptions.CanObjectDrop: Boolean;
begin
  Result := False;
  if pgObjectEditor.ActivePage = tsObject then
  begin
    Result := not FNewObject;
  end;

  if pgObjectEditor.ActivePage = tsDocoView then
  begin

  end;

  if pgObjectEditor.ActivePage = tsDDL then
  begin

  end;
end;

procedure TfrmExceptions.DoObjectDrop;
var
  frmDropObject : TfrmDropObject;
  DoClose : Boolean;

begin
  If MessageDlg('Are you sure that you wish to drop the exception "' + FObjectName + '"?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
  begin
    frmDropObject := TfrmDropObject.CreateDropObject(Self, FDatabaseName, ctException, FObjectName);
    DoClose := frmDropObject.ModalResult = mrOK;
    frmDropObject.Free;
    if DoClose then
      DropClose;
  end;
end;

function TfrmExceptions.CanCompile: Boolean;
begin
  Result := False;
  if pgObjectEditor.ActivePage = tsObject then
  begin
    Result := edExceptionName.Text <> '';
  end;

  if pgObjectEditor.ActivePage = tsDocoView then
  begin

  end;

  if pgObjectEditor.ActivePage = tsDDL then
  begin

  end;
end;

function TfrmExceptions.CanSaveDoco: Boolean;
begin
  Result := framDoco.Modified;
end;

procedure TfrmExceptions.DoCompile;
var
  FCompile: TfrmCompileDBObject;
	Doco : String;
  CompileText : String;
  TmpIntf : IMarathonForm;

begin
  Doco := framDoco.Doco;

  Refresh;
  if edExceptionName.Text = '' then
  begin
    MessageDlg('Exception must have a name.', mtError, [mbOK], 0);
    Exit;
  end;

	if edExceptionText.Text = '' then
	begin
		MessageDlg('Exception must have a message.', mtError, [mbOK], 0);
		Exit;
	end;

	CompileText := 'create exception ' + edExceptionName.Text + ' ''' + edExceptionText.Text + ''';';

	TmpIntf := Self;
	FCompile := TfrmCompileDBObject.CreateCompile(Self, TmpIntf, qryException.IB_Connection, qryException.IB_Transaction, ctException, CompileText);
	FErrors := FCompile.CompileErrors;
	FCompile.Free;

	if FErrors then
		Exit;

	if FNewObject then
	begin
		//update the tree cache...
		MarathonIDEInstance.CurrentProject.Cache.AddCacheItem(FDatabaseName, FObjectName, ctException);
	end;

	FNewObject := False;
	FObjectModified := False;

  framDoco.Doco := Doco;
  framDoco.SaveDoco;
end;

procedure TfrmExceptions.DoSaveDoco;
begin
  framDoco.SaveDoco;
end;

function TfrmExceptions.CanViewNextPage: Boolean;
begin
  Result := True;
end;

function TfrmExceptions.CanViewPrevPage: Boolean;
begin
  Result := True;
end;

procedure TfrmExceptions.DOViewNextPage;
begin
  pgObjectEditor.SelectNextPage(True);
end;

procedure TfrmExceptions.DOViewPrevPage;
begin
  pgObjectEditor.SelectNextPage(False);
end;

function TfrmExceptions.CanCaptureSnippet: Boolean;
begin
  case pgObjectEditor.ActivePage.PageIndex of
    PG_EXCEPT:
      begin
        Result := False;
			end;
    PG_DOCO:
      begin
        Result := framDoco.CanCaptureSnippet;
      end;
    PG_DDL:
      begin
        Result := framDDL.CanCaptureSnippet;
      end;
  else
    Result := False;
  end;
end;

function TfrmExceptions.CanCopy: Boolean;
begin
  case pgObjectEditor.ActivePage.PageIndex of
    PG_EXCEPT:
      begin
        Result := False;
      end;
    PG_DOCO:
      begin
        Result := framDoco.CanCopy;
      end;
    PG_DDL:
      begin
        Result := framDDL.CanCopy;
      end;
  else
    Result := False;
  end;
end;

function TfrmExceptions.CanCut: Boolean;
begin
  case pgObjectEditor.ActivePage.PageIndex of
    PG_EXCEPT:
      begin
				Result := False;
      end;
    PG_DOCO:
      begin
        Result := framDoco.CanCut;
      end;
    PG_DDL:
      begin
        Result := False;
      end;
  else
    Result := False;
  end;
end;

function TfrmExceptions.CanFind: Boolean;
begin
  case pgObjectEditor.ActivePage.PageIndex of
    PG_EXCEPT:
      begin
        Result := False;
      end;
    PG_DOCO:
      begin
        Result := framDoco.CanFind;
      end;
    PG_DDL:
      begin
        Result := framDDL.CanFind;
      end;
  else
    Result := False;
  end;
end;

function TfrmExceptions.CanFindNext: Boolean;
begin
  case pgObjectEditor.ActivePage.PageIndex of
    PG_EXCEPT:
			begin
        Result := False;
      end;
    PG_DOCO:
      begin
        Result := framDoco.CanFindNext;
      end;
    PG_DDL:
      begin
        Result := framDDL.CanFindNext;
      end;
  else
    Result := False;
  end;
end;

function TfrmExceptions.CanPaste: Boolean;
begin
  case pgObjectEditor.ActivePage.PageIndex of
    PG_EXCEPT:
      begin
        Result := False;
      end;
    PG_DOCO:
      begin
        Result := framDoco.CanPaste;
      end;
    PG_DDL:
      begin
        Result := False;
      end;
  else
    Result := False;
  end;
end;

function TfrmExceptions.CanRedo: Boolean;
begin
  case pgObjectEditor.ActivePage.PageIndex of
		PG_EXCEPT:
      begin
        Result := False;
      end;
    PG_DOCO:
      begin
        Result := framDoco.CanRedo;
      end;
    PG_DDL:
      begin
        Result := False;
      end;
  else
    Result := False;
  end;
end;

function TfrmExceptions.CanReplace: Boolean;
begin
  case pgObjectEditor.ActivePage.PageIndex of
    PG_EXCEPT:
      begin
        Result := False;
      end;
    PG_DOCO:
      begin
        Result := framDoco.CanReplace;
      end;
    PG_DDL:
      begin
        Result := False;
      end;
  else
    Result := False;
  end;
end;

function TfrmExceptions.CanSelectAll: Boolean;
begin
	case pgObjectEditor.ActivePage.PageIndex of
    PG_EXCEPT:
      begin
        Result := False;
      end;
    PG_DOCO:
      begin
        Result := framDoco.CanSelectAll;
      end;
    PG_DDL:
      begin
        Result := framDDL.CanSelectAll;
      end;
  else
    Result := False;
  end;
end;

function TfrmExceptions.CanUndo: Boolean;
begin
  case pgObjectEditor.ActivePage.PageIndex of
    PG_EXCEPT:
      begin
        Result := False;
      end;
    PG_DOCO:
      begin
        Result := framDoco.CanUndo;
      end;
    PG_DDL:
      begin
        Result := False;
      end;
  else
    Result := False;
  end;
end;

procedure TfrmExceptions.DoCaptureSnippet;
begin
  case pgObjectEditor.ActivePage.PageIndex of
    PG_EXCEPT:
      begin
      end;
    PG_DOCO:
      begin
        framDoco.CaptureSnippet;
      end;
    PG_DDL:
      begin
        framDDL.CaptureSnippet;
      end;
  end;
end;

procedure TfrmExceptions.DoCopy;
begin
  case pgObjectEditor.ActivePage.PageIndex of
    PG_EXCEPT:
      begin
      end;
    PG_DOCO:
      begin
        framDoco.CopyToClipboard;
      end;
    PG_DDL:
      begin
        framDDL.CopyToClipboard;
      end;
  end;
end;

procedure TfrmExceptions.DoCut;
begin
  case pgObjectEditor.ActivePage.PageIndex of
    PG_EXCEPT:
      begin
      end;
		PG_DOCO:
      begin
        framDoco.CutToClipBoard;
      end;
    PG_DDL:
      begin
      end;
  end;
end;

procedure TfrmExceptions.DoFind;
begin
  case pgObjectEditor.ActivePage.PageIndex of
    PG_EXCEPT:
      begin
      end;
    PG_DOCO:
      begin
        framDoco.WSFind;
      end;
    PG_DDL:
      begin
        framDDL.WSFind;
      end;
  end;
end;

procedure TfrmExceptions.DoFindNext;
begin
  case pgObjectEditor.ActivePage.PageIndex of
    PG_EXCEPT:
      begin
      end;
    PG_DOCO:
      begin
        framDoco.WSFindNext;
      end;
    PG_DDL:
      begin
				framDDL.WSFindNext;
      end;
  end;
end;

procedure TfrmExceptions.DoPaste;
begin
  case pgObjectEditor.ActivePage.PageIndex of
    PG_EXCEPT:
      begin
      end;
    PG_DOCO:
      begin
        framDoco.PasteFromClipboard;
      end;
    PG_DDL:
      begin
      end;
  end;
end;

procedure TfrmExceptions.DoRedo;
begin
  case pgObjectEditor.ActivePage.PageIndex of
    PG_EXCEPT:
      begin
      end;
    PG_DOCO:
      begin
        framDoco.Redo;
      end;
    PG_DDL:
      begin
      end;
  end;
end;

procedure TfrmExceptions.DoReplace;
begin
	case pgObjectEditor.ActivePage.PageIndex of
    PG_EXCEPT:
      begin
      end;
    PG_DOCO:
      begin
        framDoco.WSReplace;
      end;
    PG_DDL:
      begin
      end;
  end;
end;

procedure TfrmExceptions.DoSelectAll;
begin
  case pgObjectEditor.ActivePage.PageIndex of
    PG_EXCEPT:
      begin
      end;
    PG_DOCO:
      begin
        framDoco.SelectAll;
      end;
    PG_DDL:
      begin
        framDDL.SelectAll;
      end;
  end;
end;

procedure TfrmExceptions.DoUndo;
begin
  case pgObjectEditor.ActivePage.PageIndex of
    PG_EXCEPT:
      begin
      end;
    PG_DOCO:
      begin
				framDoco.Undo;
      end;
    PG_DDL:
      begin
      end;
  end;
end;

procedure TfrmExceptions.EnvironmentOptionsRefresh;
begin
  inherited;

end;

procedure TfrmExceptions.ProjectOptionsRefresh;
begin
  inherited;

end;

function TfrmExceptions.CanPrint: Boolean;
begin
  Result := False;
	case pgObjectEditor.ActivePage.PageIndex of
		0 :
			begin
				Result := (not FNewObject);
			end;
		1 :
			begin
				Result := (not FNewObject) and framDoco.CanPrint;
			end;
		2 :
			begin
				Result := (not FNewObject) and framDDL.CanPrint;
			end;
	end;
end;

function TfrmExceptions.CanPrintPreview: Boolean;
begin
  Result := CanPrint;
end;

procedure TfrmExceptions.DoPrint;
begin
  case pgObjectEditor.ActivePage.PageIndex of
    0 :
      begin
        MarathonIDEInstance.PrintException(False, FObjectName, FDatabaseName);
      end;
    1 :
      begin
        framDoco.DoPrint;
      end;
    2 :
      begin
        framDDL.DoPrint;
      end;
  end;
end;

procedure TfrmExceptions.DoPrintPreview;
begin
  case pgObjectEditor.ActivePage.PageIndex of
    0 :
      begin
        MarathonIDEInstance.PrintException(True, FObjectName, FDatabaseName);
      end;
    1 :
      begin
        framDoco.DoPrintPreview;
      end;
    2 :
      begin
        framDDL.DoPrintPreview;
      end;
  end;
end;

end.

{
$Log: EditorException.pas,v $
Revision 1.5  2005/05/20 19:24:08  rjmills
Fix for Multi-Monitor support.  The GetMinMaxInfo routines have been pulled out of the respective files and placed in to the BaseDocumentDataAwareForm.  It now correctly handles Multi-Monitor support.

There are a couple of files that are descendant from BaseDocumentForm (PrintPreview, SQLForm, SQLTrace) and they now have the corrected routines as well.

UserEditor (Which has been removed for the time being) doesn't descend from BaseDocumentDataAwareForm and it should.  But it also has the corrected MinMax routine.

Revision 1.4  2002/09/23 10:31:16  tmuetze
FormOnKeyDown now works with Shift+Tab to cycle backwards through the pages

Revision 1.3  2002/04/29 11:54:53  tmuetze
Converted from TIBGSSDataset to TIBOQuery

Revision 1.2  2002/04/25 07:21:29  tmuetze
New CVS powered comment block

}
