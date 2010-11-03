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
// $Id: StoredProcedureParams.pas,v 1.2 2002/04/25 07:21:30 tmuetze Exp $

unit StoredProcedureParams;

interface

uses
	Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
	DB, Grids, DBGrids, StdCtrls;

type TSPParameters = class(TObject)
public
	SPName : String;
	FType : Integer;
	Len : Integer;
	Scale : Integer;
	Value : String;
end;

type
  TfrmStoredProcParameters = class(TForm)
    btnOK: TButton;
    btnCancel: TButton;
    btnHelp: TButton;
    Label1: TLabel;
    dsParameters: TDataSource;
    DBGrid1: TDBGrid;
    procedure btnOKClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnHelpClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;


implementation

uses
	Globals,
	HelpMap,
	EditorStoredProcedure;

{$R *.DFM}

procedure TfrmStoredProcParameters.btnOKClick(Sender: TObject);
var
	OldDecimalSeparator : Char;
begin
	with TfrmStoredProcedure(Owner).txtParameters do
	begin
		First;
		While Not EOF do
		begin
			if AnsiUpperCase(FieldByName('null').AsString) = 'NULL' then
			begin
				//don't do any validation....
			end
			else
      begin
        Case FieldByName('field_type').AsInteger  of
          7 : begin
                if FieldByName('field_scale').AsInteger <> 0 then
                begin
                  OldDecimalSeparator := DecimalSeparator;
                  try
                    DecimalSeparator := '.';
                    try
                      StrToFloat(FieldByName('param_value').AsString);
                    Except
                      MessageDlg(FieldByName('param_value').AsString  + ' is not a valid numeric(4, ' +
                      FieldByName('field_scale').AsString + ') value.', mtError, [mbOK], 0);
                      Exit;
                    end
                  finally
                    DecimalSeparator := OldDecimalSeparator;
                  end;
                end
                else
                begin
                  try
                    StrToInt(FieldByName('param_value').AsString);
                  Except
										MessageDlg(FieldByName('param_value').AsString  + ' is not a valid integer value.', mtError, [mbOK], 0);
                    Exit;
                  end;
                end;
              end;

          8 : begin //integer
                if FieldByName('field_scale').AsInteger <> 0 then
                begin
                  OldDecimalSeparator := DecimalSeparator;
                  try
                    DecimalSeparator := '.';
                    try
                      StrToFloat(FieldByName('param_value').AsString);
                    Except
                      MessageDlg(FieldByName('param_value').AsString  + ' is not a valid numeric(9, ' +
                      FieldByName('field_scale').AsString + ') value.', mtError, [mbOK], 0);
                      Exit;
                    end
                  finally
                    DecimalSeparator := OldDecimalSeparator;
                  end;
                end
                else
                begin
                  try
                    StrToInt(FieldByName('param_value').AsString);
                  Except
                    MessageDlg(FieldByName('param_value').AsString  + ' is not a valid integer point value.', mtError, [mbOK], 0);
                    Exit;
                  end
                end;

              end;

          9 : begin
                //Result := 'REPORT_ME';
              end;

					10 : begin //float
                 OldDecimalSeparator := DecimalSeparator;
                 try
                   DecimalSeparator := '.';
                   try
                     StrToFloat(FieldByName('param_value').AsString);
                   Except
                     MessageDlg(FieldByName('param_value').AsString  + ' is not a valid floating point value.', mtError, [mbOK], 0);
                     Exit;
                   end
                 finally
                   DecimalSeparator := OldDecimalSeparator;
                 end;
               end;

          11 : begin
                //Result := 'REPORT_ME';
               end;

          14 : begin //char
                 if Length(FieldByName('param_value').AsString) > FieldByName('field_length').AsInteger then
                 begin
                   MessageDlg(FieldByName('param_value').AsString  + ' is to long to fit in a parameter of type char(' +
                   FieldByName('param_length').AsString + ').', mtError, [mbOK], 0);
                   Exit;
                 end;
               end;

          27 : begin //double
                if FieldByName('field_scale').AsInteger <> 0 then
                begin
                  OldDecimalSeparator := DecimalSeparator;
                  try
                    DecimalSeparator := '.';
                    try
                      StrToFloat(FieldByName('param_value').AsString);
                    Except
                      MessageDlg(FieldByName('param_value').AsString  + ' is not a valid numeric(15, ' +
                      FieldByName('field_scale').AsString + ') value.', mtError, [mbOK], 0);
											Exit;
                    end
                  finally
                    DecimalSeparator := OldDecimalSeparator;
                  end;
                end
                else
                begin
                  OldDecimalSeparator := DecimalSeparator;
                  try
                    DecimalSeparator := '.';
                    try
                      StrToFloat(FieldByName('param_value').AsString);
                    Except
                      MessageDlg(FieldByName('param_value').AsString  + ' is not a valid double value.', mtError, [mbOK], 0);
                      Exit;
                    end
                  finally
                    DecimalSeparator := OldDecimalSeparator;
                  end;
                 end;
               end;

          35 : begin //date
               end;

          37 : begin //varchar
                 if Length(FieldByName('param_value').AsString) > FieldByName('field_length').AsInteger then
                 begin
                   MessageDlg(FieldByName('param_value').AsString  + ' is to long to fit in a parameter of type varchar(' +
                   FieldByName('field_length').AsString + ').', mtError, [mbOK], 0);
                   Exit;
                 end;
               end;

      //    261 : Result := 'blob';

        end;
      end;
			Next;
    end;
  end;
  ModalResult := mrOK;
end;

procedure TfrmStoredProcParameters.FormCreate(Sender: TObject);
begin
  HelpContext := IDH_Stored_Procedure_Parameters_Dialog;
end;

procedure TfrmStoredProcParameters.btnHelpClick(Sender: TObject);
begin
  Application.HelpCommand(HELP_CONTEXT, IDH_Stored_Procedure_Parameters_Dialog);
end;

end.

{
$Log: StoredProcedureParams.pas,v $
Revision 1.2  2002/04/25 07:21:30  tmuetze
New CVS powered comment block

}
