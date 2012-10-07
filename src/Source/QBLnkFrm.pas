unit QBLnkFrm;

{$MODE Delphi}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls;

type
  TQBLinkForm = class(TForm)
    txtTable1: TStaticText;
    txtTable2: TStaticText;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    txtCol1: TStaticText;
    Label4: TLabel;
    txtCol2: TStaticText;
    btnOK: TButton;
    btnCancel: TButton;
    btnHelp: TButton;
    cmbJoinOperator: TComboBox;
    cmbJoinType: TComboBox;
    Label5: TLabel;
    Label6: TLabel;
    Bevel1: TBevel;
  end;

implementation

{$R *.lfm}

end.


