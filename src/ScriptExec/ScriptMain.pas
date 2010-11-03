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
// $Id: ScriptMain.pas,v 1.7 2005/04/25 13:21:37 rjmills Exp $

unit ScriptMain;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
	StdCtrls, ComCtrls, ExtCtrls, Menus, Buttons, Db, DBCtrls,
	Registry, ImgList,
	rmCollectionListBox,
	rmDataStorage,
	rmPanel,
	IB_Components,
	IB_Session,
	IB_Constants,
	IB_Header,
	SynEdit,
  SynEditTypes,
	SynEditHighlighter,
	SynHighlighterSQL,
	SyntaxMemoWithStuff2,
	GSSRegistry{,
	CloseUpCombo};

type
  TParseInfo = record
    ParseDBName : String;
    ParseUser : String;
    ParsePassword : String;
  end;

	TfrmScript = class(TForm)
		pnlToolbar: TPanel;
		stsMain: TStatusBar;
		btnOpen: TSpeedButton;
		MainMenu1: TMainMenu;
		File1: TMenuItem;
		N1: TMenuItem;
		Exit1: TMenuItem;
		Script1: TMenuItem;
		Execute1: TMenuItem;
		Help1: TMenuItem;
		About1: TMenuItem;
		btnExecute: TSpeedButton;
		Open1: TMenuItem;
		Panel1: TPanel;
		edScript: TSyntaxMemoWithStuff2;
		dlgOpen: TOpenDialog;
		N2: TMenuItem;
		Options1: TMenuItem;
		btnStop: TSpeedButton;
		synHighlighter: TSynSQLSyn;
		pnlResults: TrmPanel;
		lvErrors: TrmCollectionListBox;
		lstKeyWords: TrmTextDataStorage;
		FDatabase: TIB_Connection;
		FTransaction: TIB_Transaction;
		FSQL: TIB_DSQL;
		imgError: TImageList;
    btnMultiOpen: TSpeedButton;
    CBFiles: TComboBox;         // hexplorador
    btnRunAll: TSpeedButton;
    OpenMultipleScripts1: TMenuItem;
    ExecuteAll1: TMenuItem;        // hexplorador
		procedure FormCreate(Sender: TObject);
		procedure Exit1Click(Sender: TObject);
		procedure Execute1Click(Sender: TObject);
		procedure Open1Click(Sender: TObject);
		procedure btnOpenClick(Sender: TObject);
		procedure btnExecuteClick(Sender: TObject);
		procedure File1Click(Sender: TObject);
		procedure Script1Click(Sender: TObject);
		procedure Help1Click(Sender: TObject);
		procedure About1Click(Sender: TObject);
		procedure Options1Click(Sender: TObject);
		procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
		procedure btnStopClick(Sender: TObject);
		procedure lvErrorsClick(Sender: TObject);
		procedure edScriptKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
                procedure btnMultiOpenClick(Sender: TObject);
    procedure CBFilesChange(Sender: TObject);  // hexplorador
    procedure btnRunAllClick(Sender: TObject);
    procedure OpenMultipleScripts1Click(Sender: TObject);
    procedure ExecuteAll1Click(Sender: TObject); // hexplorador
	private
		{ Private declarations }
		FStopFlag : Boolean;
		FStopCommit : Boolean;
	    //	FLastDir : String;

		FBusy : Boolean;
		FFileCount : Integer;
		FFileName : String;
		FErrorItems : Integer;
		FInfoItems : Integer;
		FScriptDir : String;
		FAbortOnError : Boolean;
		FRollbackOnAbort : Boolean;
		procedure AddError(Err : String; Line : LongInt);
		procedure AddInfo(Err : String);
		procedure OpenScript;
		procedure ExecuteScript;
		procedure DoScriptOptions;
		procedure LoadOptions;
		procedure LineUpdateHandler(Sender: TObject; LineNumber: Integer);
		procedure ReportErrorHandler(Sender: TObject; LineNumber: Integer; ErrorText: String);
  procedure MultiOpenScript;
    procedure SetAbortOnError(const Value: Boolean);
    procedure SetRollbackOnAbort(const Value: Boolean);
    procedure SetScriptDir(const Value: String);

	public
            property ScriptDir : String  read FScriptDir write SetScriptDir;
            property AbortOnError : Boolean  read FAbortOnError write SetAbortOnError;
            property RollbackOnAbort : Boolean  read FRollbackOnAbort write SetRollbackOnAbort;
	end;

	TTokenType = (tkNone, tkKeyWord, tkIdent, tkNumber, tkString, tkComment,
								tkTerm, tkComma, tkBracket, tkOperator, tkOther);

	TToken = record
		Offset : Longint;
		Len : LongInt;
		TokenType : TTokenType;
		TokenText : String;
	end;

	TParseState = (psNormal, psIdent, psKeyword, psNumber,
								 psString, psComment, psBracket, psOperator,
								 psTerminator, psComma);

	TTextParser = class(TObject)
	private
		FInput : String;
		FTermChar : Char;
		Ch, Next: Char;
		FState : TParseState;
		FOutPut : String;
		FPrior : Boolean;
		FIndex : Integer;
		StrDelimCount : Integer;
		procedure PushChar(Ch: Char);
		procedure Mark;

		procedure SetInput(Value : String);
		function GetNextToken : TToken;
	public
		property NextToken : TToken read GetNextToken;
		property Input : String read FInput write SetInPut;
		property TerminatorChar : Char read FTermChar write FTermChar;
	end;

var
	frmScript: TfrmScript;

	gEditorFontName : String;
	gEditorFontSize : Integer;

	gMarkedBlockFontColor : TColor;
	gMarkedBlockBGColor : TColor;

	gDefForeColor : TColor;
	gDefBackColor : TColor;

	gErrorLineFontColor : TColor;
	gErrorLineBGColor : TColor;

	gListDelay : Integer;
	gAutoIndent : Boolean;
  gInsertMode : Boolean;
  gSyntaxHighlight : Boolean;
  gBlockIndent : Integer;
  gRightMargin : Integer;

  gSQLKeyWords : Boolean;
  gCapitalise : Boolean;

  gInExecModeFlag : Boolean;    // hexplorador

implementation

{$R *.DFM}

uses
  AboutBox,
  ScriptOptions,
  StopDialog,
	ScriptExecutive;

const
	STRDELIM1 = '"';
	STRDELIM2 = #39;

const
	DIGIT = ['0'..'9'];
	ALPHA = ['A'..'Z', 'a'..'z'];
	IDENT = ALPHA + DIGIT + ['_', '$'];

	ZERO =  '0';
	NINE =  '9';
	TAB =   #9;
	SPACE = ' ';
	CR =    #13;
	NULL =  #0;
	LF =    #10;

procedure TTextParser.SetInput(Value : String);
begin
	FInput := Value;
	FTermChar := ';';
	Findex := 1;
end;

procedure TTextParser.PushChar(Ch: Char);
begin
  FOutput := FOutPut + Ch;
  Inc(FIndex);
end;

procedure TTextParser.Mark;
begin
  FPrior := False;
end;

function TTextParser.GetNextToken : TToken;
begin
  if not (Length(FInput) > 0) then
    raise Exception.Create('No input');
	if FIndex > Length(FInput) then
	begin
		Result.Offset := 0;
		Result.Len := 0;
		Result.TokenType := tkNone;
		Result.TokenText := '';
	end;

	while FIndex <= Length(FInput) do
	begin
		Ch := FInput[FIndex];
		if FIndex < Length(FInput) then
			Next := FInput[FIndex + 1]
		else
			Next := #0;

		case FState of
			psIdent :
				begin
					if not (Ch in  ALPHA + [ZERO..NINE, '_', '$']) then
					begin
						Result.Offset := FIndex - Length(FOutPut);
            Result.Len := Length(FOutPut);
            Result.TokenType := tkIdent;
            Result.TokenText := FOutPut;
            FState := psNormal;
            Exit;
          end
          else
            FOutPut := FOutPut + Ch;
        end;

      psOperator :
        begin
          if not (Ch in ['>','<','=','+','-']) then
          begin
            Result.Offset := FIndex - Length(FOutPut);
            Result.Len := Length(FOutPut);
            Result.TokenType := tkOperator;
            Result.TokenText := FOutPut;
            FState := psNormal;
            Exit;
          end
          else
            FOutPut := FOutPut + Ch;
        end;

      psBracket :
        begin
          Result.Offset := FIndex - Length(FOutPut);
          Result.Len := Length(FOutPut);
          Result.TokenType := tkBracket;
          Result.TokenText := FOutPut;
          FState := psNormal;
          Exit;
        end;

      psTerminator :
        begin
          Result.Offset := FIndex - Length(FOutPut);
          Result.Len := Length(FOutPut);
          Result.TokenType := tkTerm;
          Result.TokenText := FOutPut;
          FState := psNormal;
          Exit;
        end;

      psComma :
        begin
          Result.Offset := FIndex - Length(FOutPut);
          Result.Len := Length(FOutPut);
          Result.TokenType := tkComma;
          Result.TokenText := FOutPut;
          FState := psNormal;
          Exit;
        end;

      psNumber :
        begin
          if not (Ch in [ZERO..NINE,'.','E','e']) then
          begin
            Result.Offset := FIndex - Length(FOutPut);
            Result.Len := Length(FOutPut);
            Result.TokenType := tkNumber;
            Result.TokenText := FOutPut;
            FState := psNormal;
            Exit;
          end
          else
            FOutPut := FOutPut + Ch;
        end;

      psString :
        begin
          case Ch of
            STRDELIM1, STRDELIM2:
              begin
                FOutPut := FOutPut + Ch;
                StrDelimCount := StrDelimCount + 1;
                if not Odd(StrDelimCount) then
                begin
                  if not (Next in [STRDELIM1, STRDELIM2]) then
                  begin
                    Result.Offset := FIndex - Length(FOutPut);
                    Result.Len := Length(FOutPut);
                    Result.TokenType := tkString;
                    Result.TokenText := FOutPut;
                    FState := psNormal;
                    PushChar(Next);
                    Exit;
                  end
                  else
                  begin
                    PushChar(Next);
                    StrDelimCount := StrDelimCount + 1;
                  end;
                end
                else
                begin
                  StrDelimCount := StrDelimCount + 1;
                end;
              end;
          else
            begin
              FOutPut := FOutPut + Ch;
            end;
          end;
        end;

      psNormal :
        begin
          if Ch = FTermChar then
          begin
            FState := psTerminator;
          end
          else
          begin
            case Ch of
              SPACE, NULL, TAB, CR, LF : ;

              '>','<','=','+','-' :
                begin
                  FState := psOperator;
                end;

              '[',']','(',')' :
                begin
                  FState := psBracket;
                end;

              ',' :
                begin
                  FState := psComma;
                end;

              ZERO..NINE :
                begin
                  FState := psNumber;
                end;

              '#','$' :
                begin
                  if Next in DIGIT then
                  begin
                    FState := psNumber;
                    Mark;
                  end;
                end;

              'A'..'Z','a'..'z', '_' :
                begin
                  begin
                    FState := psIdent;
                    Mark;
                  end;
                end;

              STRDELIM1, STRDELIM2:
                begin
                  begin
                    FState := psString;
                    StrDelimCount := 1;
                    Mark;
                  end;
                end;


              '/' :
                begin
                  if Next = '*' then
                  begin
                    FState := psComment;
                    Mark;
                  end;
                end;
            end;
          end;
          FOutPut := Ch;
        end;

      psComment :
        begin
          if Ch = '*' then
          begin
            FOutput := FOutPut + Ch;
            if Next = '/' then
            begin
              PushChar(Next);
              Result.Offset := FIndex - Length(FOutPut);
              Result.Len := Length(FOutPut);
              Result.TokenType := tkComment;
              Result.TokenText := FOutPut;
              FState := psNormal;
              Exit
            end;
          end
          else
            FOutput := FOutPut + Ch;
        end;
    end;
    Inc(FIndex);
  end;
  if FIndex > Length(FInput) then
  begin
    Result.Offset := 0;
    Result.Len := 0;
    Result.TokenType := tkNone;
    Result.TokenText := '';
  end;
end;



function ConvertTabs(Data : String; Editor : TSyntaxMemoWithStuff2) : String;
var
  Idx : Integer;
  Idy : Integer;
  Tmp : String;

begin
  Tmp := '';
  for Idx := 1 to Length(Data) do
  begin
    if Data[Idx] = #9 then
    begin
      for Idy := 1 to Editor.TabWidth do
        Tmp := Tmp + ' ';
    end
    else
      Tmp := Tmp + Data[Idx];
  end;
  Result := Tmp;
end;


procedure TfrmScript.LoadOptions;
var
  I : TRegistry;
  Idx : Integer;

begin
  I := TRegistry.Create;
  I.RootKey:=HKEY_CURRENT_USER;    // hexplorador
  try
    //set the defaults if the settings don't exist
    if I.OpenKey(REG_SETTINGS_BASE, True) then
    begin
      if not I.ValueExists('Editor Font Name') then
        I.WriteString('Editor Font Name', 'Courier New');

      if not I.ValueExists('Editor Font Size') then
        I.WriteInteger('Editor Font Size', 10);

      if not I.ValueExists('MarkedBlockFontColor') then
        I.WriteInteger('MarkedBlockFontColor', LongInt(clWhite));

      if not I.ValueExists('MarkedBlockBGColor') then
        I.WriteInteger('MarkedBlockBGColor', LongInt(clBlack));

      if not I.ValueExists('ErrorLineFontColor') then
        I.WriteInteger('ErrorLineFontColor', LongInt(clWhite));

      if not I.ValueExists('ErrorLineBGColor') then
        I.WriteInteger('ErrorLineBGColor', LongInt(clRed));

      if not I.ValueExists('ListDelay') then
        I.WriteInteger('ListDelay', 1000);

      if not I.ValueExists('AutoIndent') then
        I.WriteBool('AutoIndent', True);

      if not I.ValueExists('InsertMode') then
        I.WriteBool('InsertMode', True);

      if not I.ValueExists('SyntaxHighlight') then
        I.WriteBool('SyntaxHighlight', True);

      if not I.ValueExists('BlockIndent') then
        I.WriteInteger('BlockIndent', 1);

      if not I.ValueExists('RightMargin') then
        I.WriteInteger('RightMargin', 80);

      I.CloseKey;
    end;

    //more defaults for SQLSmarts
    if I.OpenKey(REG_SETTINGS_SQLSMARTS, True) then
    begin

      if not I.ValueExists('SQL Keywords') then
        I.WriteBool('SQL Keywords', True);

      if not I.ValueExists('Table Names') then
        I.WriteBool('Table Names', False);

      if not I.ValueExists('Field Names') then
        I.WriteBool('Field Names', False);

      if not I.ValueExists('SP Names') then
        I.WriteBool('SP Names', False);

      if not I.ValueExists('Trigger Names') then
        I.WriteBool('Trigger Names', False);

      if not I.ValueExists('Exception Names') then
        I.WriteBool('Exception Names', False);

      if not I.ValueExists('Generator Names') then
        I.WriteBool('Generator Names', False);

      if not I.ValueExists('UDF Names') then
        I.WriteBool('UDF Names', False);

      if not I.ValueExists('Capitalise') then
        I.WriteBool('Capitalise', False);
      I.CloseKey;
    end;

    Sleep(400);

    if I.OpenKey(REG_SETTINGS_BASE, True) then
    begin
      gEditorFontName := I.ReadString('Editor Font Name');
      gEditorFontSize := I.ReadInteger('Editor Font Size');
      gMarkedBlockFontColor := TColor(I.ReadInteger('MarkedBlockFontColor'));
      gMarkedBlockBGColor := TColor(I.ReadInteger('MarkedBlockBGColor'));
      gErrorLineFontColor := TColor(I.ReadInteger('ErrorLineFontColor'));
      gErrorLineBGColor := TColor(I.ReadInteger('ErrorLineBGColor'));
      gListDelay := I.ReadInteger('ListDelay');
      gAutoIndent := I.ReadBool('AutoIndent');
      gInsertMode := I.ReadBool('InsertMode');
      gSyntaxHighlight := I.ReadBool('SyntaxHighlight');
      gBlockIndent := I.ReadInteger('BlockIndent');
      gRightMargin := I.ReadInteger('RightMargin');

      I.CloseKey;
    end;

    if I.OpenKey(REG_SETTINGS_SQLSMARTS, True) then
    begin
      if I.ReadBool('SQL Keywords') then
        gSQLKeyWords := True
      else
        gSQLKeyWords := False;


      if I.ReadBool('Capitalise') then
        gCapitalise := True
      else
        gCapitalise := False;

      I.CloseKey;
    end;


    // Restore the Script Directory
    if I.OpenKey(REG_SCREXEC, True) then
    begin
      FScriptDir := I.ReadString('ScriptDir');
      FAbortOnError := I.ReadBool('AbortOnError');
      FRollbackOnAbort := I.ReadBool('RollbackOnAbort');
      I.CloseKey;
    end;

  finally
    I.Free;
  end;

  synHighlighter.LoadFromRegistry(HKEY_CURRENT_USER, REG_SETTINGS_HIGHLIGHTING);

  if gSyntaxHighlight then
    edScript.Highlighter := synHighlighter
  else
    edScript.Highlighter := nil;

  edScript.FindSettingsRegistryKey := REG_SETTINGS_EDITOR_FIND;
  edScript.FindDialogCaption := 'Find';
  edScript.ReplaceDialogCaption := 'Replace';

  edScript.RightEdge := gRightMargin;
  edScript.Font.Name := gEditorFontName;
  edScript.Font.Size := gEditorFontSize;
  edScript.SelectedColor.Foreground := gMarkedBlockFontColor;
  edScript.SelectedColor.Background := gMarkedBlockBGColor;
  edScript.ErrorBackColor := gErrorLineBGColor;
  edScript.ErrorForeColor := gErrorLineFontColor;
//  edScript.ExecutionBackColor := ;
//  edScript.ExecutionForeColor := ;

  edScript.Options := [eoDragDropEditing,
                     eoScrollPastEof,
                     eoShowScrollHint,
                     eoSmartTabs,
                     eoTabsToSpaces,
                     eoTrimTrailingSpaces];

  if gAutoIndent then
    edScript.Options := edScript.Options + [eoAutoIndent]
  else
    edScript.Options := edScript.Options - [eoAutoIndent];


	edScript.InsertMode := gInsertMode;
  edScript.WantTabs := True;

  edScript.KeywordCapitalise := gCapitalise;

  edScript.WordList.Clear;
  if gSQLKeyWords then
  begin
    for Idx := 0 to lstKeyWords.Data.Count - 1 do
    begin
      with edScript.WordList.Add do
      begin
        ItemType := itSQL;
        MatchItem := lstKeyWords.Data[Idx];
        InsertText := lstKeyWords.Data[Idx];
      end;
    end;
  end;


end;

procedure TfrmScript.FormCreate(Sender: TObject);
begin
  LoadOptions;


  if ParamStr(1) <> '' then
  begin
    FFileName := ParamStr(1);
    try
      Screen.Cursor := crHourGlass;
      edScript.Lines.LoadFromFile(FFileName);
      edScript.Lines.Text := ConvertTabs(AdjustLineBreaks(edScript.Lines.Text), edScript);
    finally
      Screen.Cursor := crDefault;
    end;
    Caption := 'Script Executive - [' + ExtractFileName(FFileName) + ']';
  end;

  FFileCount := 0;
  stsMain.Panels[0].Text := 'Ready';
  gInExecModeFlag := false;

end;

procedure TfrmScript.Exit1Click(Sender: TObject);
begin
  Close;
end;

procedure TfrmScript.Execute1Click(Sender: TObject);
begin
  try
    ExecuteScript;
  finally
  end;
end;

procedure TfrmScript.Open1Click(Sender: TObject);
begin
  OpenScript;
end;

procedure TfrmScript.btnOpenClick(Sender: TObject);
begin
  // protect the code vs the reentrance
  if not gInExecModeFlag  then
  begin
    gInExecModeFlag := true;
    dlgOpen.Options := [ofFileMustExist];   // HExplorador
    OpenScript;
    gInExecModeFlag := false;
  end;
end;

procedure TfrmScript.btnExecuteClick(Sender: TObject);
begin
  // protect the code vs the reentrance
  if not gInExecModeFlag  then
  begin
    gInExecModeFlag := true;
    Refresh;
    Application.ProcessMessages;
    ExecuteScript;
    gInExecModeFlag := false;
  end;
end;

procedure TfrmScript.File1Click(Sender: TObject);
begin
  if FBusy then
  begin
		Open1.Enabled := False;
    Exit1.Enabled := False;
  end
  else
  begin
    Open1.Enabled := True;
    Exit1.Enabled := True;
  end;
end;

procedure TfrmScript.Script1Click(Sender: TObject);
begin
  if FBusy then
  begin
    Execute1.Enabled := False;
  end
  else
  begin
    Execute1.Enabled := True;
  end;
end;

procedure TfrmScript.Help1Click(Sender: TObject);
begin
  if FBusy then
  begin
    About1.Enabled := False;
  end
  else
  begin
    About1.Enabled := True;
  end;
end;

procedure TfrmScript.Options1Click(Sender: TObject);
begin
  DoScriptOptions;
end;

procedure TfrmScript.LineUpdateHandler(Sender : TObject; LineNumber : Integer);
begin
  edScript.ErrorLine := LineNumber;
  edScript.CaretXY := BufferCoord(1, LineNumber);
  Refresh;
end;

procedure TfrmScript.ReportErrorHandler(Sender : TObject; LineNumber : Integer; ErrorText : String);
begin
  AddError(ErrorText, LineNumber);
end;

//==============================================================================
procedure TfrmScript.ExecuteScript;
var
  ISQLObj: TIBSQLObj;
begin
  FBusy := True;
  try
    edScript.ErrorLine := -1;
    ISQLObj := TIBSqlObj.Create (Self);
    try
      try
        with ISQLObj do
        begin
          AutoDDL := True;
          Query := edScript.Lines;
          Database := FDatabase;
          Transaction := FTransaction;
          SQLQuery := FSQL;
          OnLineUpdate := LineUpdateHandler;
          OnReportError := ReportErrorHandler;
          Cursor := crSQLWait;
          DoIsql;
          Cursor := crDefault;
        end;
        if FTransaction.Started then
          FTransaction.Commit;
        if FDatabase.COnnected then
					FDatabase.Connected := False;
        edScript.ErrorLine := -1;
      except
        on E : Exception do
        begin
          Cursor := crDefault;
          AddError(E.Message, -1);
        end;
      end;
    finally
      ISQLObj.Free;
    end;
  finally
    FBusy := False;
  end;
end;

procedure TfrmScript.OpenScript;
begin
  try
		dlgOpen.InitialDir := ScriptDir;
  except
    //eat it...
  end;
  if dlgOpen.Execute then
  begin
    FFileName := dlgOpen.FileName;
    try
      Screen.Cursor := crHourGlass;
      edScript.Lines.LoadFromFile(FFileName);
      edScript.Lines.Text := ConvertTabs(AdjustLineBreaks(edScript.Lines.Text), edScript);

      ScriptDir := ExtractFilePath(FFileName);
      dlgOpen.FileName := '';
    finally
      Screen.Cursor := crDefault;
    end;
    Caption := 'Script Executive - [' + ExtractFileName(FFileName) + ']';
  end;
end;

procedure TfrmScript.AddError(Err : String; Line : LongInt);
begin
  pnlResults.Height := 125;
  pnlResults.Visible := True;
  FErrorItems := FErrorItems + 1;
  lvErrors.Add('Line ' + IntToStr(Line) + ': ' + Err, 0, nil);
  stsMain.Panels[1].Text := IntToStr(lvErrors.Collection.Count) + ' Error/Info Items';
end;

procedure TfrmScript.AddInfo(Err : String);
begin
  pnlResults.Height := 125;
  pnlResults.Visible := True;
  FInfoItems := FInfoItems + 1;
  lvErrors.Add(Err, 1, nil);
  stsMain.Panels[1].Text := IntToStr(lvErrors.Collection.Count) + ' Error/Info Items';
end;

procedure TfrmScript.About1Click(Sender: TObject);
var
	frmAboutBox: TfrmAboutBox;

begin
	frmAboutBox := TfrmAboutBox.Create(Self);
	try
		frmAboutBox.ShowModal;
	finally
		frmAboutBox.Free;
	end;
end;

procedure TfrmScript.DoScriptOptions;
var
  frmScriptOptions: TfrmScriptOptions;

begin
  frmScriptOptions := TfrmScriptOptions.Create(Self);
	try
    frmScriptOptions.edScriptDir.Text := FScriptDir;
    frmScriptOptions.chkAbortOnError.Checked := FAbortOnError;
    frmScriptOptions.chkRollBack.Checked := FRollbackOnAbort;
    if not frmScriptOptions.chkAbortOnError.Checked then
    begin
      frmScriptOptions.chkRollBack.Enabled := False;
      frmScriptOptions.chkRollBack.Checked := False;
    end;

    if frmScriptOptions.ShowModal = mrOK then
      LoadOptions;
  finally
    frmScriptOptions.Free;
  end;
end;


procedure TfrmScript.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
	if FBusy then
		CanClose := False;
end;

procedure TfrmScript.btnStopClick(Sender: TObject);
var
	frmStopExecution: TfrmStopExecution;

begin
	frmStopExecution := TfrmStopExecution.Create(Self);
	try
		if frmStopExecution.ShowModal = mrOK then
		begin
			if frmStopExecution.rbCommit.Checked then
				FStopCommit := True
			else
				FStopCommit := False;
			FStopFlag := True;
		end;
	finally
		frmStopExecution.Free;
	end;
end;

procedure TfrmScript.lvErrorsClick(Sender: TObject);
var
	Line : String;
	CharPos : Integer;
	Parser : TTextParser;
	Tok : TToken;
	FoundLine, FoundChar : Boolean;
	LinePos : Integer;

begin
	if not FBusy then
	begin
		if lvErrors.ItemIndex <> -1 then
		begin
			edScript.ErrorLine := -1;

			Line := lvErrors.Collection[lvErrors.ItemIndex].TextData.Text;

			FoundLine := False;
			FoundChar := False;

			Parser := TTextParser.Create;
			Parser.Input := Line;
			Tok := Parser.NextToken;
			while Tok.TokenType <> tkNone do
			begin
				if AnsiUpperCase(Tok.TokenText)  = 'LINE' then
				begin
					Tok := Parser.NextToken;
					While (Tok.TokenType <> tkNumber) do
					begin
						Tok := Parser.NextToken;
						if Tok.TokenType = tkNone then
							Break;
					end;
					if Tok.TokenType = tkNumber then
					begin
						try
							LinePos := StrToInt(Tok.TokenText);
							FoundLine := True;
						except

						end;
					end;
				end;
				if AnsiUpperCase(Tok.TokenText)  = 'CHAR' then
				begin
					Tok := Parser.NextToken;
					While (Tok.TokenType <> tkNumber) do
					begin
						Tok := Parser.NextToken;
						if Tok.TokenType = tkNone then
							Break;
					end;
					if Tok.TokenType = tkNumber then
					begin
						try
							CharPos := StrToInt(Tok.TokenText);
							FoundChar := True;
						except

						end;
					end;
				end;
				Tok := Parser.NextToken;
			end;
			if FoundChar then
				CharPos := Abs(CharPos)
			else
				CharPos := 1;
			if FoundLine then
				LinePos := Abs(LinePos)
			else
				LinePos := 1;

			if not ((LinePos = 0) and (CharPos = 0)) then
			begin
				edScript.ErrorLine := LinePos;
				edScript.CaretXY := BufferCoord(CharPos, LinePos);
			end;
		end;
	end;
end;

procedure TfrmScript.edScriptKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
	edScript.ErrorLine := -1;
end;




//************************** HExplorador begin *********************************
procedure TfrmScript.MultiOpenScript;
var
  i : integer;
begin

  try
		dlgOpen.InitialDir := ScriptDir;
  except
    //eat it...
  end;
  if dlgOpen.Execute then
  begin
    cbFiles.Visible := true;
    cbFiles.Items.Clear;
    cbFiles.Sorted := true;
    for I := 0 to dlgOpen.Files.Count - 1 do
        cbFiles.Items.AddObject(ExtractFileName(dlgOpen.Files.Strings[I]),
                                Pointer(I));

    // Open the first file in the list
    FFileName := dlgOpen.Files.Strings[0];
    try
      edScript.Lines.LoadFromFile(FFileName);
      edScript.Lines.Text := ConvertTabs(AdjustLineBreaks(edScript.Lines.Text), edScript);
      ScriptDir := ExtractFilePath(FFileName);
    except
     //eat it...
    end;
  end;
end;

procedure TfrmScript.btnMultiOpenClick(Sender: TObject);
begin
   // protect the code vs the reentrance
   if not gInExecModeFlag  then
   begin
     gInExecModeFlag := true;
     Screen.Cursor := crHourGlass;
     // Clear errors
     lvErrors.Collection.Clear;
     dlgOpen.Options := [ofAllowMultiSelect, ofFileMustExist];
     MultiOpenScript;
     cbFiles.ItemIndex := 0;
     CBFilesChange(Sender);
     Caption := 'Script Executive - Multi File [' + cbFiles.Text + ']';
     Screen.Cursor := crDefault;
     gInExecModeFlag := false;
   end;
end;

procedure TfrmScript.CBFilesChange(Sender: TObject);
var
   FileIndex : Integer;
begin
    if CBFiles.ItemIndex >= 0 then
    begin
      FileIndex := Integer(cbFiles.Items.Objects[CBFiles.ItemIndex]);
      FFileName := dlgOpen.Files.Strings[FileIndex];
      try
        edScript.Lines.LoadFromFile(FFileName);
        edScript.Lines.Text := ConvertTabs(AdjustLineBreaks(edScript.Lines.Text), edScript);
        ScriptDir := ExtractFilePath(FFileName);
        Caption := 'Script Executive - Multi File [' + cbFiles.Text + ']';
      except
         //eat it...
      end;
    end;
end;

procedure TfrmScript.btnRunAllClick(Sender: TObject);
var
  Index, I : Integer;
begin
    // protect the code vs the reentrance
   if not gInExecModeFlag  then
   begin
     gInExecModeFlag := true;
     Screen.Cursor := crHourGlass;
     cbFiles.ItemIndex := 0;
     CBFilesChange(Sender);
     for I := 0 to (cbFiles.Items.Count - 1) do
     begin

        // update panel text
        stsmain.Panels[0].Text := 'Executing ' + cbFiles.Text + '...';

        Refresh;
        Application.ProcessMessages;
        ExecuteScript;

        // break on error
        if lvErrors.Collection.Count > 0 then
        begin
          cbFiles.Hide;
          break;
        end;

        // select the next script
        if I < (cbFiles.Items.Count - 1)
        then
        begin
           cbFiles.ItemIndex := I + 1;
           CBFilesChange(Sender);
        end;
     end;
     stsmain.Panels[0].Text := 'Ready ';
     gInExecModeFlag := false;
     Screen.Cursor := crDefault;
   end;
end;

procedure TfrmScript.OpenMultipleScripts1Click(Sender: TObject);
begin
  btnMultiOpenClick(Sender);
end;

procedure TfrmScript.ExecuteAll1Click(Sender: TObject);
begin
  btnRunAllClick(Sender);
end;

procedure TfrmScript.SetAbortOnError(const Value: Boolean);
var
  I : TRegistry;
begin
  FAbortOnError := Value;
  I := TRegistry.Create;
  I.RootKey:= HKEY_CURRENT_USER;
  try
    if I.OpenKey(REG_SCREXEC, True) then
    begin
      I.WriteBool('AbortOnError', FAbortOnError);
      I.CloseKey;
    end;
  finally
    I.Free;
  end;
end;

procedure TfrmScript.SetRollbackOnAbort(const Value: Boolean);
var
  I : TRegistry;
begin
  FRollbackOnAbort := Value;
  I := TRegistry.Create;
  I.RootKey:= HKEY_CURRENT_USER;
  try
    if I.OpenKey(REG_SCREXEC, True) then
    begin
      I.WriteBool('RollbackOnAbort', FRollbackOnAbort);
      I.CloseKey;
    end;
  finally
    I.Free;
  end;
end;

procedure TfrmScript.SetScriptDir(const Value: String);
var
  I : TRegistry;
begin
  FScriptDir := Value;
  I := TRegistry.Create;
  I.RootKey:= HKEY_CURRENT_USER;
  try
    if I.OpenKey(REG_SCREXEC, True) then
    begin
      I.WriteString('ScriptDir', FScriptDir);
      I.CloseKey;
    end;
  finally
    I.Free;
  end;
end;

end.

{ Old History
				08.04.2002      hexplorador
								+  Multiopen button   (btnMultiOpen)
								+  Execute all button (btnRunAll)
								+  Combo with scripts to compile (cbFiles)
				09.04.2000
								+  protect the button click code vs the reentrance with flag (gInExecModeFlag)
}

{
$Log: ScriptMain.pas,v $
Revision 1.7  2005/04/25 13:21:37  rjmills
*** empty log message ***

Revision 1.6  2002/06/12 11:43:34  tmuetze
Patch from Arturo Castillo: Modifications to ScriptExec

Revision 1.5  2002/05/15 09:09:19  tmuetze
Removed a reference to TIBGSSDataset

Revision 1.4  2002/04/25 07:17:35  tmuetze
New CVS powered comment block

}
