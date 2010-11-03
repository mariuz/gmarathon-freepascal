unit ReplDlg;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, SynEdit, SynEditTypes, SyntaxMemoWithStuff2;

type
  TEdReplDlg = class(TForm)
    Panel1 : TPanel;
    OKButton : TButton;
    CancelButton : TButton;
    Panel2 : TPanel;
    Label1 : TLabel;
    FindHistoryBox : TComboBox;
    GroupBox1 : TGroupBox;
    UseCaseBox : TCheckBox;
    WholeWordBox : TCheckBox;
    ReplaceAllButton : TButton;
    Label2 : TLabel;
    ReplHistoryBox : TComboBox;
    PromptOnReplBox : TCheckBox;
    GroupBox2: TGroupBox;
    FwdDirection: TRadioButton;
    BackDirection: TRadioButton;
    procedure FormShow(Sender : TObject);
    procedure FormKeyDown(Sender : TObject; var Key : Word;
      Shift : TShiftState);
    procedure OKButtonClick(Sender : TObject);
    procedure ReplaceAllButtonClick(Sender : TObject);
    procedure CancelButtonClick(Sender : TObject);
    procedure FormClose(Sender : TObject; var Action : TCloseAction);
    procedure FindHistoryBoxChange(Sender : TObject);
  private
    { Private declarations }
    FPersist : TEdPersistent;
    FFindOpt : TSynSearchOptions;
    FFindText : string;
    FEditor : TSyntaxMemoWithStuff2;
    procedure UpdateOptionBoxes;
    procedure ReadOptionsBoxes;
    procedure ReplaceTextHandler(Sender: TObject; const ASearch,
      AReplace: String; Line, Column: Integer;
      var Action: TSynReplaceAction);
  public
    { Public declarations }
    procedure Execute(FindText : string; Options : TSynSearchOptions; anEditor : TSyntaxMemoWithStuff2; HistoryData : TEdPersistent);
  end;

var
  EdReplDlg : TEdReplDlg;

implementation

{$R *.DFM}

{ TEdReplDlg }

procedure TEdReplDlg.ReplaceTextHandler(Sender: TObject;
  const ASearch, AReplace: String; Line, Column: Integer;
  var Action: TSynReplaceAction);
begin
  case MessageDlg('Replace this instance of "' + ASearch + '"?', mtConfirmation, [mbYes, mbNo, mbCancel, mbAll], 0) of
    mrYes :
      begin
        Action := raReplace;
      end;
    mrNo :
      begin
        Action := raSkip;
      end;
    mrCancel :
      begin
        Action := raCancel;
      end;
    mrAll :
      begin
        Action := raReplaceAll;
      end;
  end;
end;

procedure TEdReplDlg.Execute(FindText : string; Options : TSynSearchOptions; anEditor : TSyntaxMemoWithStuff2; HistoryData : TEdPersistent);
begin
  FFindText := FindText;
  FFindOpt := Options;
  FEditor := anEditor;
  FEditor.HideSelection := false;
  FEditor.OnReplaceText := ReplaceTextHandler;
  FPersist := HistoryData;
  ShowModal;
end;

procedure TEdReplDlg.FormShow(Sender : TObject);
begin
  FindHistoryBox.Items.Assign(FPersist.FindList);
  ReplHistoryBox.Items.Assign(FPersist.ReplList);
  if (FFindText <> '') then
  begin
    if FindHistoryBox.Items.IndexOf(FFindText) = -1 then FindHistoryBox.Items.Add(FFindText);
    FindHistoryBox.ItemIndex := FindHistoryBox.Items.IndexOf(FFindText);
  end;
  UpdateOptionBoxes;
  FindHistoryBoxChange(Self);
  FindHistoryBox.Setfocus;
end;

procedure TEdReplDlg.FormKeyDown(Sender : TObject; var Key : Word; Shift : TShiftState);
begin
  if Key = VK_ESCAPE then Close;
end;

procedure TEdReplDlg.OKButtonClick(Sender : TObject);
var
  SOptions : TSynSearchOptions;

begin
  ReadOptionsBoxes;
  SOptions := FFindOpt;
  SOptions := SOptions + [ssoReplace, ssoEntireScope];
  with FEditor do
  begin
    if FindHistoryBox.Items.IndexOf(FindHistoryBox.Text) = -1 then
      FindHistoryBox.Items.Insert(0, FindHistoryBox.Text);
    if ReplHistoryBox.Items.IndexOf(ReplHistoryBox.Text) = -1 then
      ReplHistoryBox.Items.Insert(0, ReplHistoryBox.Text);

    FPersist.LastFindText := FindHistoryBox.Text;
    FPersist.LastReplaceText := ReplHistoryBox.Text;

    if SearchReplace(FindHistoryBox.Text, ReplHistoryBox.Text, SOptions) = 0 then
      MessageDlg(format('Search string "%s" not found.', [FindHistoryBox.Text]), mtInformation, [mbOK], 0)
  end;
  ModalResult := mrOK;
end;

procedure TEdReplDlg.ReadOptionsBoxes;
begin
  FFindOpt := [];
  if UseCaseBox.Checked then FFindOpt := FFindOpt + [ssoMatchCase];
  if WholeWordBox.Checked then FFindOpt := FFindOpt + [ssoWholeWord];
  if BackDirection.Checked then FFindOpt := FFindOpt + [ssoBackwards];
  if PromptOnReplBox.Checked then FFindOpt := FFindOpt + [ssoPrompt];
end;

procedure TEdReplDlg.UpdateOptionBoxes;
begin
  UseCaseBox.Checked := ssoMatchCase in FFindOpt;
  WholeWordBox.Checked := ssoWholeWord in FFindOpt;
  BackDirection.Checked := ssoBackwards in FFindOpt;
  PromptOnReplBox.Checked := ssoPrompt in FFindOpt;
end;

procedure TEdReplDlg.ReplaceAllButtonClick(Sender : TObject);
var
  SOptions : TSynSearchOptions;

begin
  ReadOptionsBoxes;
  SOptions := FFindOpt;
  SOptions := SOptions + [ssoReplace, ssoEntireScope, ssoReplaceAll];
  with FEditor do
  begin
    if FindHistoryBox.Items.IndexOf(FindHistoryBox.Text) = -1 then
      FindHistoryBox.Items.Insert(0, FindHistoryBox.Text);
    if ReplHistoryBox.Items.IndexOf(ReplHistoryBox.Text) = -1 then
      ReplHistoryBox.Items.Insert(0, ReplHistoryBox.Text);

    FPersist.LastFindText := FindHistoryBox.Text;
    FPersist.LastReplaceText := ReplHistoryBox.Text;

    if SearchReplace(FindHistoryBox.Text, ReplHistoryBox.Text, SOptions) = 0 then
      MessageDlg(format('Search string "%s" not found.', [FindHistoryBox.Text]), mtInformation, [mbOK], 0)
  end;
  ModalResult := mrOK;
end;

procedure TEdReplDlg.CancelButtonClick(Sender : TObject);
begin
  Close;
end;

procedure TEdReplDlg.FormClose(Sender : TObject; var Action : TCloseAction);
begin
  FEditor.HideSelection := true;
  FPersist.FindList := FindHistoryBox.Items;
  FPersist.ReplList := ReplHistoryBox.Items;
end;

procedure TEdReplDlg.FindHistoryBoxChange(Sender : TObject);
begin
  OKButton.Enabled := FindHistoryBox.Text <> '';
  ReplaceAllButton.Enabled := OKButton.Enabled;
end;

end.

