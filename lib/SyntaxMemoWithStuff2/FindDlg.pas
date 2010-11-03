unit FindDlg;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, SynEdit, SynEditTypes, SyntaxMemoWithStuff2;

type


  TEdFindDlg = class(TForm)
    Panel1 : TPanel;
    Panel2 : TPanel;
    Label1 : TLabel;
    FindHistoryBox : TComboBox;
    GroupBox1 : TGroupBox;
    UseCaseBox : TCheckBox;
    WholeWordBox : TCheckBox;
    OKButton : TButton;
    CancelButton : TButton;
    GroupBox2: TGroupBox;
    FwdDirection: TRadioButton;
    BackDirection: TRadioButton;
    procedure FormShow(Sender : TObject);
    procedure OKButtonClick(Sender : TObject);
    procedure FormKeyDown(Sender : TObject; var Key : Word; Shift : TShiftState);
    procedure CancelButtonClick(Sender : TObject);
    procedure FormClose(Sender : TObject; var Action : TCloseAction);
    procedure FindHistoryBoxChange(Sender : TObject);
  private
    { Private declarations }
    FPersist : TEdPersistent;
    FFindText : string;
    FFindOpt : TsynSearchOptions;
    FEditor : TSyntaxMemoWithStuff2;
    procedure UpdateOptionBoxes;
    procedure ReadOptionsBoxes;
  public
    { Public declarations }
    procedure Execute(FindText : string; Options : TsynSearchOptions; aEditor : TSyntaxMemoWithStuff2; HistoryData : TEdPersistent);
  end;

var
  EdFindDlg : TEdFindDlg;

implementation

{$R *.DFM}

{ TEdFindDlg }

procedure TEdFindDlg.Execute(FindText : string; Options : TsynSearchOptions; aEditor : TSyntaxMemoWithStuff2; HistoryData : TEdPersistent);
begin
  FFindText := FindText;
  FFindOpt := Options;
  FPersist := HistoryData;
  FEditor := aEditor;
  ShowModal;
end;

procedure TEdFindDlg.UpdateOptionBoxes;
begin
  UseCaseBox.Checked := ssoMatchCase in FFindOpt;
  WholeWordBox.Checked := ssoWholeWord in FFindOpt;
  BackDirection.Checked := ssoBackwards in FFindOpt;
end;

procedure TEdFindDlg.ReadOptionsBoxes;
begin
  FFindOpt := [];
  if UseCaseBox.Checked then FFindOpt := FFindOpt + [ssoMatchCase];
  if WholeWordBox.Checked then FFindOpt := FFindOpt + [ssoWholeWord];
  if BackDirection.Checked then FFindOpt := FFindOpt + [ssoBackwards];
end;

procedure TEdFindDlg.FormShow(Sender : TObject);
begin
  FindHistoryBox.Items.Assign(FPersist.FindList);
  if FindHistoryBox.Items.IndexOf(FFindText) = -1 then
    FindHistoryBox.Items.Add(FFindText);
  FindHistoryBox.ItemIndex := FindHistoryBox.Items.IndexOf(FFindText);
  UpdateOptionBoxes;
  FindHistoryBoxChange(Self);
  FindHistoryBox.SetFocus;
end;

procedure TEdFindDlg.OKButtonClick(Sender : TObject);
var
  FoundAt : longint;

begin
  //
  // Initiate the find...
  //
  ReadOptionsBoxes;

  with FEditor do
  begin
    if FindHistoryBox.Items.IndexOf(FindHistoryBox.Text) = -1 then
      FindHistoryBox.Items.Insert(0, FindHistoryBox.Text);
    //
    // Update the last find text data first...
    //
    FPersist.LastFindText := FindHistoryBox.Text;
    FoundAt := SearchReplace(FindHistoryBox.Text, '', FFindOpt);;
    if FoundAt = 0 then
      MessageDlg(format('Search string "%s" not found.', [FindHistoryBox.Text]), mtInformation, [mbOK], 0);
  end;
  ModalResult := mrOK;
end;

procedure TEdFindDlg.FormKeyDown(Sender : TObject; var Key : Word; Shift : TShiftState);
begin
  if Key = VK_ESCAPE then Close;
end;

procedure TEdFindDlg.CancelButtonClick(Sender : TObject);
begin
  Close;
end;

procedure TEdFindDlg.FormClose(Sender : TObject; var Action : TCloseAction);
begin
  FPersist.FindList := FindHistoryBox.Items;
end;

procedure TEdFindDlg.FindHistoryBoxChange(Sender : TObject);
begin
  OKButton.Enabled := FindHistoryBox.Text <> '';
end;

end.

