
unit DebugAddBreakPoint;

{$MODE Delphi}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

type
  TfrmDebugAddBreakPoint = class(TForm)
    btnCancel: TButton;
    btnOK: TButton;
    edProcName: TEdit;
    cmbConnection: TComboBox;
    edLine: TEdit;
    edCondition: TEdit;
    edPassCount: TEdit;
    GroupBox1: TGroupBox;
    chkBreak: TCheckBox;
    chkLog: TCheckBox;
    edLogMessage: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

{$R *.lfm}

end.


