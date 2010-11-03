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
// $Id: DebugEvalModify.pas,v 1.5 2005/06/29 22:29:43 hippoman Exp $

unit DebugEvalModify;

interface

{$I compilerdefines.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls,
  {$IFDEF D6_OR_HIGHER}
  Variants,
  {$ENDIF}
  IBDebuggerVM;

type
  TfrmGetSetVariable = class(TForm)
    btnClose: TButton;
    GroupBox1: TGroupBox;
    cmbVariableName: TComboBox;
    Label1: TLabel;
    memResult: TMemo;
    memNewValue: TMemo;
    Label2: TLabel;
    Label3: TLabel;
    btnGetValue: TButton;
    btnModify: TButton;
    procedure btnCloseClick(Sender: TObject);
    procedure btnGetValueClick(Sender: TObject);
    procedure btnModifyClick(Sender: TObject);
  private
    FDebuggerVM: TIBDebuggerVM;
    { Private declarations }
    procedure DoGetValue;
    procedure DoModValue;
  public
    { Public declarations }
    property DebuggerVM : TIBDebuggerVM read FDebuggerVM write FDebuggerVM;
  end;

implementation

{$R *.DFM}

procedure TfrmGetSetVariable.DoGetValue;
var
	V : Variant;

begin
	V := FDebuggerVM.EvalExpression(cmbVariableName.Text);
	if VarIsNull(V) then
		memResult.Text := 'NULL'
	else
		memResult.Text := V;
end;

procedure TfrmGetSetVariable.DoModValue;
{var
	Tmp : String;}

begin

//  memResult.Text := Tmp;
//  memNewValue.Text := Tmp;
end;

procedure TfrmGetSetVariable.btnCloseClick(Sender: TObject);
begin
	Close;
end;

procedure TfrmGetSetVariable.btnGetValueClick(Sender: TObject);
begin
	DoGetValue;
end;

procedure TfrmGetSetVariable.btnModifyClick(Sender: TObject);
begin
	DoModValue;
end;

end.

{
$Log: DebugEvalModify.pas,v $
Revision 1.5  2005/06/29 22:29:43  hippoman
* d6 related things, using D6_OR_HIGHER everywhere

Revision 1.4  2005/04/13 16:04:26  rjmills
*** empty log message ***

Revision 1.2  2002/04/25 07:21:29  tmuetze
New CVS powered comment block

}
