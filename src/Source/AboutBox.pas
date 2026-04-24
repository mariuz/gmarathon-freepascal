unit AboutBox;

{$MODE Delphi}

interface

uses
  SysUtils, Classes, Graphics, Controls, Forms, Dialogs, StdCtrls, ExtCtrls;

type
  TfrmAboutBox = class(TForm)
    btnClose: TButton;
    lblVersion: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
  end;

implementation

{$R *.lfm}

procedure TfrmAboutBox.FormCreate(Sender: TObject);
begin
  lblVersion.Caption := 'Marathon Firebird IDE';
end;

procedure TfrmAboutBox.btnCloseClick(Sender: TObject);
begin
  Close;
end;

end.
