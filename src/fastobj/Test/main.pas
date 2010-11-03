unit main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, StdActns, xmldom, msxmldom, XMLDoc, XMLIntf;

type
  TMainForm = class(TForm)
    BtnLoop: TButton;
    LbLoop: TLabel;
    procedure BtnLoopClick(Sender: TObject);
  private
    { Private declarations }
    procedure DoLoop;
  public
    { Public declarations }
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

uses
  fastobj;

type
  TBaseClass = class(TInterfacedObject)
  //TBaseClass = class(TXMLDocument)
  //TBaseClass = class(TObject)
  private
  end;

  TTestClass = class(TBaseClass)
  private
    FExtraField : array[1..50] of dword;
    //FExtraField : array[1..50] of dword;
    FHeaderFld  : integer;
    //FStr       : string;
    //FV         : variant;
    //FStr2       : string;
    //FV2         : variant;
  public
    //class function NewInstance: TObject; override;
    //FStrN       : array[0..0] of string;

  end;

procedure TMainForm.DoLoop;
const
  LoopCount = 100000;
var
  I, J : integer;
  O : array[1..100] of TTestClass;
  T1, T2 : Cardinal;
begin
  T1 := GetTickCount;
  for I := 1 to LoopCount do
  begin
    for J := Low(O) to High(O) do
    begin
      O[J] := TTestClass.Create;
    end;
    for J := Low(O) to High(O) do
    begin
      O[J].Free;
    end;
    if I mod 10 = 0 then
    begin
      T2 := GetTickCount;
      if T2 - T1 > 1000 then
      begin
        LbLoop.Caption := Format('%.1n%%', [I*100/LoopCount]);
        Update;
        T1 := T2;
      end;
    end;
  end;
end;


procedure TMainForm.BtnLoopClick(Sender: TObject);
var
  T : Cardinal;
begin
  LbLoop.Caption := 'Loop...';
  Update;
  T := GetTickCount;

  DoLoop;

  T := GetTickCount - T;

  LbLoop.Caption := LbLoop.Caption + Format('  %d ms', [T]);
end;

{ TTestClass }
//simple way to increase the header size
{
class function TTestClass.NewInstance: TObject;
begin
  Result := inherited NewInstance;
  //TTestClass(Result).FHeaderFld := 1;
end;
}
initialization
  //this is needed when using safe mode, if NewInstance is overridden
  //fastobj.OptimizeClass(TTestClass);
  //simple test for packages
  //UnloadPackage(LoadPackage('webdsnap90.bpl'));
end.
