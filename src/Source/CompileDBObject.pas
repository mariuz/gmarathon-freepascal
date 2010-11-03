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
// $Id: CompileDBObject.pas,v 1.9 2006/10/19 03:35:45 rjmills Exp $

unit CompileDBObject;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
	StdCtrls, ComCtrls,
	IB_Components,
	IB_Session,
	IBODataset,
	MarathonInternalInterfaces,
	MarathonProjectCacheTypes,
	SQLYacc,
	Globals;

type
	TCreateType = (crtCallback, crtInline, crtMultiStatement);

	TfrmCompileDBObject = class(TForm)
		btnOK: TButton;
		aniCompile: TAnimate;
		memStatus: TMemo;
		procedure FormCreate(Sender: TObject);
		procedure FormDestroy(Sender: TObject);
		procedure FormShow(Sender: TObject);
	private
		{ Private declarations }
		FParser : TSQLLexer;
		FCompileText : TStringList;
		FNewFlag : Boolean;
		FForm : IMarathonBaseForm;
		FTransaction : TIB_Transaction;
		FDatabase : TIB_Connection;
		FObjectType : TGSSCacheType;
		FErrors : Boolean;
		FCreateType : TCreateType;
		FStatusText : String;
		procedure BailOut(ErrMessage : String);
		procedure WMBuggerOff(var Message : TMessage); message WM_BUGGER_OFF;
	public
		{ Public declarations }
		property CompileErrors : Boolean read FErrors;
		constructor CreateAlter(AOwner : TComponent; Form : IMarathonBaseForm; Database : TIB_Connection;
			Transaction : TIB_Transaction; ObjectType : TGSSCacheType; CompileText : String;
			FormCaption : String; StatusText : String);
		constructor CreateCompile(AOwner : TComponent; Form : IMarathonBaseForm; Database : TIB_COnnection;
			Transaction : TIB_Transaction; ObjectType : TGSSCacheType; CompileText : String);
		constructor CreateCompileCallBack(AOwner : TComponent; Form : IMarathonBaseForm);
		constructor CreateMultiStatementCompile(const AOwner: TComponent; const Form: IMarathonBaseForm;
			const Database: TIB_Connection; const Transaction: TIB_Transaction; const CompileText: TStringList);
	end;

implementation

uses
	MarathonIDE;

{$R *.DFM}

constructor TfrmCompileDBObject.CreateAlter(AOwner: TComponent;	Form: IMarathonBaseForm;
	Database: TIB_Connection; Transaction: TIB_Transaction; ObjectType: TGSSCacheType;
	CompileText, FormCaption, StatusText: String);
begin
	inherited Create(AOwner);
	FParser := TSQLLexer.Create(Self);
	FCreateType := crtInline;
	FErrors := False;
	FForm := Form;
	FCompileText := TStringList.Create;
	FCompileText.Text := CompileText;
	FObjectType := ObjectType;
	FTransaction := Transaction;
	FDatabase := Database;
	AniCompile.ResName := 'compile';
	Caption := FormCaption;
	FStatusText := StatusText;
	ShowModal;
end;

constructor TfrmCompileDBObject.CreateCompile(AOwner : TComponent; Form : IMarathonBaseFOrm; Database : TIB_COnnection;
	Transaction : TIB_Transaction; ObjectType : TGSSCacheType; CompileText : String);
begin
	inherited Create(AOwner);
	FParser := TSQLLexer.Create(Self);
	FCreateType := crtInline;
	FErrors := False;
	FForm := Form;
	FCompileText := TStringList.Create;
	FCompileText.Text := CompileText;
	FObjectType := ObjectType;
	FTransaction := Transaction;
	FDatabase := Database;
	AniCompile.ResName := 'compile';
	ShowModal;
end;

constructor TfrmCompileDBObject.CreateCompileCallBack(AOwner: TComponent;
	Form: IMarathonBaseForm);
begin
	inherited Create(AOwner);
	FCreateType := crtCallback;
	FErrors := False;
	FForm := Form;
	AniCompile.ResName := 'compile';
	ShowModal;
end;

constructor TfrmCompileDBObject.CreateMultiStatementCompile(const AOwner: TComponent; const Form: IMarathonBaseForm;
	const Database: TIB_Connection; const Transaction: TIB_Transaction; const CompileText: TStringList);
begin
	inherited Create(AOwner);
	FCreateType := crtMultiStatement;
	FErrors := False;
	FForm := Form;
	FDatabase := Database;
	FTransaction := Transaction;
	FCompileText := CompileText;
	AniCompile.ResName := 'compile';
	ShowModal;
end;

procedure TfrmCompileDBObject.WMBuggerOff(var Message: TMessage);
begin
	ModalResult := mrOK;
end;

procedure TfrmCompileDBObject.BailOut(ErrMessage : String);
begin
	if Assigned(FTransaction) then
		if FTransaction.Started then
			FTransaction.Rollback;
	FForm.OpenMessages;
	FForm.AddCompileError(ErrMessage);
	//go to the error
	memStatus.Text := 'Operation Completed - There Were Errors';
	memStatus.Lines.Add(ErrMessage);
	AniCompile.Stop;
	FErrors := True;
end;

procedure TfrmCompileDBObject.FormCreate(Sender: TObject);
begin
// This object is created at constructors procedures
//	FParser := TSQLLexer.Create(nil);
end;

procedure TfrmCompileDBObject.FormDestroy(Sender: TObject);
begin
	FParser.Free;
	FCompileText.Free;
end;

procedure TfrmCompileDBObject.FormShow(Sender: TObject);
var
	I, Idx, Idy: Integer;
	Found, ErrorReported : Boolean;
	DTmp, ThisObject: String;
	Q: TIBOQuery;
	M: TSQLParser;
	Domain : IMarathonDomainEditor;
	TableEditor : IMarathonTableEditor;
	TriggerEditor : IMarathonTriggerEditor;
	UDFEditor : IMarathonUDFEditor;

begin
	try
		if FStatusText = '' then
			memStatus.Text := 'Compiling...'
		else
			memStatus.Text := FStatusText;
		Refresh;
		AniCompile.Open := True;
		AniCompile.Active := True;
		FForm.ClearErrors;
		FForm.ForceRefresh;

		if FCreateType = crtInline then
		begin
			case FObjectType of
				ctSP:
					begin
						FParser.yyinput.Text := FCompileText.Text;
						FParser.yylex;
						try
							if (AnsiUpperCase(FParser.yyText) = 'CREATE') or (AnsiUpperCase(FParser.yyText) = 'ALTER') then
							begin
								FParser.yyLex;
								if AnsiUpperCase(FParser.yyText) = 'PROCEDURE' then
								begin
									FParser.yyLex;
									if FParser.yyText <> FForm.GetObjectName then
									begin
										if MessageDlg('The Stored Procedure Name has changed. Compiling this stored proc will create a new stored proc with the ' +
																	'name "' + FParser.yyText + '". Are you sure you wish to do this?', mtConfirmation, [mbYes, mbNo], 0) = mrNo then
										begin
											AniCompile.Stop;
											memStatus.Text := 'Operation Aborted by User';
											btnOK.Visible := True;
											Exit;
                    end;
										if AnsiUpperCase(FParser.yyText)  = 'NEW_PROCEDURE' then
                    begin
                      if MessageDlg('The Stored Procedure name is still the default. Are you sure you wish to use the default name?', mtConfirmation, [mbYes, mbNo], 0) = mrNo then
                      begin
                        Exit;
                      end;
										end;
									end;
                  ThisObject := StripQuotesFromQuotedIdentifier(FParser.yyText);
                  if not ShouldBeQuoted(ThisObject) then
                  begin
                    ThisObject := AnsiUpperCase(ThisObject);
                  end;
                end
                else
									raise Exception.Create('Syntax Error');
              end
              else
                raise Exception.Create('Syntax Error');

              FNewFlag := True;
              Q := TIBOQuery.Create(Self);
              try
                Q.ParamCheck := false;

                Q.IB_Connection := FDatabase;
                Q.IB_Transaction := FTransaction;

                FParser.Reset;
                FParser.yyInput.Text  := FCompileText.Text;
                FParser.yyLex;

//							  if (AnsiUpperCase(FParser.yyText) = 'CREATE') or (AnsiUpperCase(FParser.yyText) = 'ALTER') then //Removed by RJM
//								begin  //Removed by RJM
                  Q.SQL.Text := 'select rdb$procedure_name from rdb$procedures where rdb$procedure_name = ' + AnsiQuotedStr(ThisObject, '''');
                  Q.Open;
                  if (Q.BOF and Q.EOF) then
                  begin
                    Q.Close;
										Q.SQL.Text := 'select rdb$procedure_name from rdb$procedures where rdb$procedure_name = ' + AnsiQuotedStr(AnsiUpperCase(ThisObject), '''');
                    Q.Open;
										if Not (Q.BOF and Q.EOF) then
                    begin
                      DTmp := FCompileText[FParser.yyLineNo - 1];
                      Delete(DTmp, FParser.yycolno - Length(FParser.yyText), Length(FParser.yyText));
                      Insert('alter', DTmp, FParser.yycolno - Length(FParser.yyText));
                      FCompileText[FParser.yyLineNo - 1] := DTmp;
											FNewFlag := False;
										end;
                  end
                  else
                  begin
                    DTmp := FCompileText[FParser.yyLineNo - 1];
                    Delete(DTmp, FParser.yycolno - Length(FParser.yyText), Length(FParser.yyText));
                    Insert('alter', DTmp, FParser.yycolno - Length(FParser.yyText));
                    FCompileText[FParser.yyLineNo - 1] := DTmp;
										FNewFlag := False;
                  end;
                  Q.Close;
                  FTransaction.Commit;
                  Q.ParamCheck := false;
                  Q.SQL.Text := FCompileText.Text;
                  Q.ExecSQL;
                  FTransaction.Commit;
//                end;  //Removed by RJM
              finally
                Q.Free;
              end;
              MarathonIDEInstance.RecordToScript('set term ^;' + #13#10#13#10 + FCompileText.Text + '^' + #13#10#13#10 + 'set term ;^' + #13#10#13#10 + 'commit work;' + #13#10, FForm.GetActiveConnectionName);
              FForm.SetObjectName(ThisObject);
              FForm.SetObjectModified(False);
							memStatus.Text := 'Operation Completed - No Errors';
              AniCompile.Stop;
						except
              On E : EIB_ISCError do
              begin
                if ((E.ERRCODE = 335544569) or (E.ERRCODE = 335544436)) and (E.SQLCODE = -206) then
                begin
                  M := TSQLParser.Create(Self);
									try
                    M.ParserType := ptColUnknown;
										M.Lexer.IsInterbase6 := MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[FForm.GetActiveConnectionName].IsIB6;
                    M.Lexer.SQLDialect := MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[FForm.GetActiveConnectionName].SQLDialect;

                    M.Lexer.yyinput.Text := FCompileText.Text;
                    if M.yyparse = 0 then
                    begin
											if FTransaction.Started then
												FTransaction.Rollback;
                      FForm.OpenMessages;

                      ErrorReported := False;
                      if M.CodeVariables.Count > 0 then
                      begin
                        for Idy := 0 to M.CodeVariables.Count - 1 do
                        begin
													Found := False;
                          for Idx := 0 to M.DeclaredVariables.Count - 1 do
                          begin
                            if AnsiUpperCase(M.DeclaredVariables.Items[Idx].VarName) =
                              AnsiUpperCase(M.CodeVariables.Items[Idy].VarName) then
                            begin
                              Found := True;
                              Break;
                            end;
                          end;
                          if Not Found then
                          begin
                            FForm.AddCompileError('(Column Unknown) : Variable "' + M.CodeVariables.Items[Idy].VarName + '" has not been declared at line ' +
                                                   IntToStr(M.CodeVariables.Items[Idy].Line) + ' column ' +
																									 IntToStr(M.CodeVariables.Items[Idy].Col));
                            ErrorReported := True;
													end;
                        end;
                        if not ErrorReported then
                          FForm.AddCompileError(E.Message);
                      end
                      else
												FForm.AddCompileError(E.Message);

											memStatus.Text := 'Operation Completed - There Were Errors';
                      FErrors := True;
                      AniCompile.Stop;
                    end
                    else
                    begin
											BailOut(E.Message);
										end;
                  finally
                    M.Free;
                  end;
                end
                else
                begin
                  BailOut(E.Message);
								end;
              end;

              On E : Exception do
              begin
                BailOut(E.Message);
              end;
            end;
          end;

        ctTrigger:
          begin
            FParser.yyinput.Text := FCompileText.Text;
            FParser.yylex;
						try
              if (AnsiUpperCase(FParser.yyText) = 'CREATE') or (AnsiUpperCase(FParser.yyText) = 'ALTER') then
							begin
                FParser.yyLex;
                if AnsiUpperCase(FParser.yyText) = 'TRIGGER' then
                begin
                  FParser.yyLex;
                  ThisObject := StripQuotesFromQuotedIdentifier(FParser.yyText);
									if not ShouldBeQuoted(ThisObject) then
                  begin
										ThisObject := AnsiUpperCase(ThisObject);
                  end;
                end
                else
                  raise Exception.Create('Syntax Error');
              end
							else
								raise Exception.Create('Syntax Error');

              Q := TIBOQuery.Create(Self);
              try
                Q.ParamCheck := false;
                Q.IB_Connection := FDatabase;
                Q.IB_Transaction := FTransaction;

                Q.SQL.Text := FCompileText.Text;
								Q.ExecSQL;
                FTransaction.Commit;
              finally
                Q.Free;
              end;
              MarathonIDEInstance.RecordToScript('set term ^;' + #13#10#13#10 + FCompileText.Text + '^' + #13#10#13#10 + 'set term ;^' + #13#10#13#10 + 'commit work;' + #13#10, FForm.GetActiveConnectionName);
              FForm.SetObjectModified(False);
              FForm.SetObjectName(ThisObject);

              if FForm.QueryInterface(IMarathonTriggerEditor, TriggerEditor) = S_OK then
              begin
                TableEditor := MarathonIDEInstance.GetMatchingTableEditor(TriggerEditor.GetTableName);
                if Assigned(TableEditor) then
                begin
									TableEditor.UpdateTriggers;
                end;
							end;

              memStatus.Text := 'Operation Completed - No Errors';
              AniCompile.Stop;
            except
              On E : EIB_ISCError do
							begin
                if ((E.ERRCODE = 335544569) or (E.ERRCODE = 335544436)) and (E.SQLCODE = -206) then
								begin
                  M := TSQLParser.Create(Self);
                  try
                    M.ParserType := ptColUnknown;
                    M.Lexer.IsInterbase6 := MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[FForm.GetActiveConnectionName].IsIB6;
                    M.Lexer.SQLDialect := MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[FForm.GetActiveConnectionName].SQLDialect;

										M.Lexer.yyinput.Text := FCompileText.Text;
                    if M.yyparse = 0 then
                    begin
                      if FTransaction.Started then
                        FTransaction.Rollback;
                      FForm.OpenMessages;

                      ErrorReported := False;
											if M.CodeVariables.Count > 0 then
                      begin
                        for Idy := 0 to M.CodeVariables.Count - 1 do
                        begin
                          Found := False;
                          for Idx := 0 to M.DeclaredVariables.Count - 1 do
                          begin
                            if AnsiUpperCase(M.DeclaredVariables.Items[Idx].VarName) =
                              AnsiUpperCase(M.CodeVariables.Items[Idy].VarName) then
                            begin
                              Found := True;
                              Break;
                            end;
                          end;
													if Not Found then
                          begin
														FForm.AddCompileError('(Column Unknown) : Variable "' + M.CodeVariables.Items[Idy].VarName + '" has not been declared at line ' +
                                                   IntToStr(M.CodeVariables.Items[Idy].Line) + ' column ' +
                                                   IntToStr(M.CodeVariables.Items[Idy].Col));
                            ErrorReported := True;
                          end;
                        end;
												if not ErrorReported then
                          FForm.AddCompileError(E.Message);
											end
                      else
                        FForm.AddCompileError(E.Message);

                      memStatus.Text := 'Operation Completed - There Were Errors';
                      AniCompile.Stop;
											FErrors := True;
										end
                    else
                    begin
                      BailOut(E.Message);
                    end;
                  finally
                    M.Free;
                  end;
								end
                else
                begin
                  BailOut(E.Message);
                end;
              end;

              On E : Exception do
              begin
                BailOut(E.Message);
              end;
            end;
          end;

				ctView:
          begin
						FParser.yyinput.Text := FCompileText.Text;
            FParser.yylex;
            try
              if (AnsiUpperCase(FParser.yyText) = 'CREATE') or (AnsiUpperCase(FParser.yyText) = 'ALTER') then
              begin
                FParser.yyLex;
								if AnsiUpperCase(FParser.yyText) = 'VIEW' then
                begin
									FParser.yyLex;
                  if FParser.yyText <> FForm.GetObjectName then
                  begin
                    if MessageDlg('The View Name has changed. Compiling this view will create a new view with the ' +
                                  'name "' + FParser.yyText + '". Are you sure you wish to do this?', mtConfirmation, [mbYes, mbNo], 0) = mrNo then
                    begin
                      AniCompile.Stop;
											memStatus.Text := 'Operation Aborted by User';
                      btnOK.Visible := True;
                      Exit;
                    end;
                    if AnsiUpperCase(FParser.yyText)  = 'NEW_VIEW' then
                    begin
                      if MessageDlg('The View name is still the default. Are you sure you wish to use the default name?', mtConfirmation, [mbYes, mbNo], 0) = mrNo then
                      begin
												Exit;
                      end;
                    end;
                  end;
                  ThisObject := StripQuotesFromQuotedIdentifier(FParser.yyText);
                  if not ShouldBeQuoted(ThisObject) then
                  begin
                    ThisObject := AnsiUpperCase(ThisObject);
                  end;
                end
                else
                  raise Exception.Create('Syntax Error');
              end
              else
								raise Exception.Create('Syntax Error');

							FNewFlag := True;
              Q := TIBOQuery.Create(Self);
              try
                Q.IB_Connection := FDatabase;
                Q.IB_Transaction := FTransaction;
                FTransaction.Commit;
								Q.SQL.Text := FCompileText.Text;
                Q.ExecSQL;
								FTransaction.Commit;
              finally
                Q.Free;
              end;
              MarathonIDEInstance.RecordToScript(FCompileText.Text, FForm.GetActiveConnectionName);
              FForm.SetObjectName(ThisObject);
              FForm.SetObjectModified(False);
							memStatus.Text := 'Operation Completed - No Errors';
              AniCompile.Stop;
            except
              On E : Exception do
              begin
                BailOut(E.Message);
              end;
            end;
					end;

        ctException :
          begin
            FParser.yyinput.Text := FCompileText.Text;
            FParser.yylex;
            try
              if (AnsiUpperCase(FParser.yyText) = 'CREATE') or (AnsiUpperCase(FParser.yyText) = 'ALTER') then
              begin
                FParser.yyLex;
                if AnsiUpperCase(FParser.yyText) = 'EXCEPTION' then
                begin
                  FParser.yyLex;
                  ThisObject := StripQuotesFromQuotedIdentifier(FParser.yyText);
									if ThisObject <> FForm.GetObjectName then
                  begin
										if MessageDlg('The Exception Name has changed. Compiling this exception will create a new exception with the ' +
                                  'name "' + ThisObject + '". Are you sure you wish to do this?', mtConfirmation, [mbYes, mbNo], 0) = mrNo then
                    begin
                      AniCompile.Stop;
                      memStatus.Text := 'Operation Aborted by User';
                      btnOK.Visible := True;
											Exit;
                    end;

                    if AnsiUpperCase(ThisObject)  = 'NEW_EXCEPTION' then
                    begin
                      if MessageDlg('The Exception name is still the default. Are you sure you wish to use the default name?', mtConfirmation, [mbYes, mbNo], 0) = mrNo then
                      begin
                        Exit;
                      end;
										end;
                  end;
                  if not ShouldBeQuoted(ThisObject) then
                  begin
                    ThisObject := AnsiUpperCase(ThisObject);
                  end;
                end
                else
									raise Exception.Create('Syntax Error');
              end
              else
                raise Exception.Create('Syntax Error');

              Q := TIBOQuery.Create(Self);
              try
                Q.IB_Connection := FDatabase;
                Q.IB_Transaction := FTransaction;

                Q.SQL.Text := FCompileText.Text;
                Q.ExecSQL;
                FTransaction.Commit;
              finally
								Q.Free;
              end;
							MarathonIDEInstance.RecordToScript(FCompileText.Text, FForm.GetActiveConnectionName);
              FForm.SetObjectModified(False);
              FForm.SetObjectName(ThisObject);
              memStatus.Text := 'Operation Completed - No Errors';
              AniCompile.Stop;
            except
							On E : EIB_ISCError do
              begin
								BailOut(E.Message);
              end;
              On E : Exception do
              begin
                BailOut(E.Message);
              end;
            end;
					end;
        ctGenerator :
          begin
            try
              ThisObject := Trim(FCompileText.Text);
              FCompileText.Text := 'create generator ' + FCOmpileText.Text;
              if not ShouldBeQuoted(ThisObject) then
              begin
								ThisObject := AnsiUpperCase(ThisObject);
              end;
              Q := TIBOQuery.Create(Self);
              try
                Q.IB_Connection := FDatabase;
                Q.IB_Transaction := FTransaction;

                Q.SQL.Text := FCompileText.Text;
                Q.ExecSQL;
                FTransaction.Commit;
              finally
                Q.Free;
              end;
              MarathonIDEInstance.RecordToScript(FCompileText.Text, FForm.GetActiveConnectionName);
							FForm.SetObjectModified(False);
              FForm.SetObjectName(ThisObject);
							memStatus.Text := 'Operation Completed - No Errors';
              AniCompile.Stop;
            except
              On E : EIB_ISCError do
              begin
                BailOut(E.Message);
							end;
              On E : Exception do
							begin
                BailOut(E.Message);
              end;
            end;
          end;
        ctUDF :
          begin
						try
              if FForm.QueryInterface(IMarathonUDFEditor, UDFEditor) = S_OK then
              begin
                ThisObject := StripQuotesFromQuotedIdentifier(AnsiQuotedStr(UDFEditor.GetCurrentName, ''''));
                Q := TIBOQuery.Create(Self);
                try
                  Q.IB_Connection := FDatabase;
                  Q.IB_Transaction := FTransaction;
									Q.SQL.Add('select rdb$function_name from rdb$functions where rdb$function_name = ' + AnsiQuotedStr(ThisObject, '''') + ';');
                  Q.Open;
                  If not (Q.BOF and Q.EOF) then
                    FNewFlag := False
                  else
                    FNewFlag := True;
                  Q.Close;
                  Q.IB_Transaction.Commit;
                  Q.SQL.Clear;


                  if Not FNewFlag then
                  begin
                    DTmp := 'drop external function ' + MakeQuotedIdent(ThisObject, UDFEditor.IsInterbaseSix, FDatabase.SQLDialect)  + ';';
										Q.SQL.Text := DTmp;
                    Q.ExecSQL;
									end;

                  FTransaction.Commit;

                  //build the statement from the owner form......
                  DTmp := 'declare external function ' + MakeQuotedIdent(ThisObject, UDFEditor.IsInterbaseSix, FDatabase.SQLDialect) + ' ';

                  //add input params
									for Idx := 0 to UDFEditor.UDFParamCount - 1 do
                  begin
                    DTmp := DTmp + UDFEditor.ParamText(Idx);

                    DTmp := DTmp + ', ';
                  end;

									//get rid of the last comma....
                  DTmp := Trim(DTmp);
                  Idx := Length(DTmp);
                  if DTmp[Idx] = ',' then
                    DTmp := Copy(DTmp, 1, Idx - 1);

                  DTmp := DTmp + ' ';

									//add out put params
                  DTmp := DTmp + 'returns ' + UDFEditor.ReturnType;

                  //add entry point and module name....

                  DTmp := DTmp + ' entry_point ''' + UDFEditor.EntryPoint + ''' module_name ''' + UDFEditor.LibraryName + ''';';

                  FCompileText.Text := DTmp;
                  Q.SQL.Text := FCompileText.Text;
                  Q.ExecSQL;
                  FTransaction.Commit;

                finally
                  Q.Free;
								end;
								if not ShouldBeQuoted(ThisObject) then
								begin
                  ThisObject := AnsiUpperCase(ThisObject);
                end;

                MarathonIDEInstance.RecordToScript(FCompileText.Text, FForm.GetActiveConnectionName);
                FForm.SetObjectModified(False);
								FForm.SetObjectName(ThisObject);
                memStatus.Text := 'Operation Completed - No Errors';
								AniCompile.Stop;
              end
              else
                raise Exception.Create('Internal Error');

            except
              On E : EIB_ISCError do
							begin
                BailOut(E.Message);
              end;
              On E : Exception do
              begin
								BailOut(E.Message);
              end;
            end;
					end;
        ctDomain :
          begin
            FParser.yyinput.Text := FCompileText.Text;
            FParser.yylex;
            try
              if (AnsiUpperCase(FParser.yyText) = 'CREATE') or (AnsiUpperCase(FParser.yyText) = 'ALTER') then
              begin
                FParser.yyLex;
                if AnsiUpperCase(FParser.yyText) = 'DOMAIN' then
                begin
                  FParser.yyLex;
                  ThisObject := StripQuotesFromQuotedIdentifier(FParser.yyText);

									if ThisObject <> FForm.GetObjectName then
									begin
										if AnsiUpperCase(ThisObject)  = 'NEW_DOMAIN' then
                    begin
                      if MessageDlg('The Domain name is still the default. Are you sure you wish to use the default name?', mtConfirmation, [mbYes, mbNo], 0) = mrNo then
                      begin
                        Exit;
                      end;
										end;
                  end;
								end
                else
                  raise Exception.Create('Syntax Error');
              end
              else
                raise Exception.Create('Syntax Error');

							Q := TIBOQuery.Create(Self);
              try
                Q.IB_Connection := FDatabase;
                Q.IB_Transaction := FTransaction;

								Q.SQL.Text := FCompileText.Text;
                Q.ExecSQL;
                FTransaction.Commit;
							finally
                Q.Free;
              end;
              if not ShouldBeQuoted(ThisObject) then
              begin
                ThisObject := AnsiUpperCase(ThisObject);
              end;
              MarathonIDEInstance.RecordToScript(FCompileText.Text, FForm.GetActiveConnectionName);
              FForm.SetObjectModified(False);
              FForm.SetObjectName(ThisObject);
              memStatus.Text := 'Operation Completed - No Errors';
              AniCompile.Stop;
            except
              On E : EIB_ISCError do
							begin
								BailOut(E.Message);
							end;
							On E : Exception do
							begin
								BailOut(E.Message);
							end;
						end;
					end;
				ctSQL :
					begin
						try
							Q := TIBOQuery.Create(Self);
							try
								Q.IB_Connection := FDatabase;
								Q.IB_Transaction := FTransaction;

								Q.SQL.Text := FCompileText.Text;
								Q.ExecSQL;
								FTransaction.Commit;
							finally
								Q.Free;
							end;
							MarathonIDEInstance.RecordToScript(FCompileText.Text, FForm.GetActiveConnectionName);
							memStatus.Text := 'Operation Completed - No Errors';
							AniCompile.Stop;
							PostMessage(Self.Handle, WM_BUGGER_OFF, 0, 0);
						except
							on E: EIB_ISCError do
								BailOut(E.Message);
							on E: Exception do
								BailOut(E.Message);
						end;
					end;
			end;
		end
		else
			if FCreateType = crtMultiStatement then
			begin
				try
					Q := TIBOQuery.Create(Self);
					try
            Q.ParamCheck := false;
						Q.IB_Connection := FDatabase;
						Q.IB_Transaction := FTransaction;

						for I := 0 to FCompileText.Count - 1 do
						begin
							Q.SQL.Text := FCompileText[I];
							Q.ExecSQL;
							MarathonIDEInstance.RecordToScript(FCompileText[I], FForm.GetActiveConnectionName);
						end;

						FTransaction.Commit;
					finally
						Q.Free;
					end;
					memStatus.Text := 'Operation Completed - No Errors';
					AniCompile.Stop;
					PostMessage(Self.Handle, WM_BUGGER_OFF, 0, 0);
				except
					on E: EIB_ISCError do
						BailOut(E.Message);
					on E: Exception do
						BailOut(E.Message);
				end;
			end
			else
			begin
				if FForm.QueryInterface(IMarathonDomainEditor, Domain) = S_OK then
				begin
					try
						Domain.SaveDomain;
						FForm.SetObjectModified(False);
						memStatus.Text := 'Operation Completed - No Errors';
						AniCompile.Stop;
					except
						On E : Exception do
						begin
							Bailout(E.Message);
						end;
					end;
				end;
			end;
	finally
		btnOK.Visible := True;
	end;
end;

end.

{ Old History
	17.03.2002	tmuetze
		* New constructor CreateMultiStatementCompile created, which should be work better
			with executing multiline statements
	03.02.2002	davith
		* FParser is created in constructor procedures, instead of TfrmCompileDBObject.FormCreate
}

{
$Log: CompileDBObject.pas,v $
Revision 1.9  2006/10/19 03:35:45  rjmills
Numerous bug fixes

Revision 1.8  2005/04/13 16:04:26  rjmills
*** empty log message ***

Revision 1.7  2002/05/29 11:02:24  tmuetze
Added a patch from Pavel Odstrcil:  If a stored procedure contains select into variable, query was checking parameters and exception was raised

Revision 1.6  2002/04/29 14:46:11  tmuetze
Converted from TIBGSSDataset to TIBOQuery

Revision 1.5  2002/04/25 07:21:29  tmuetze
New CVS powered comment block

}
