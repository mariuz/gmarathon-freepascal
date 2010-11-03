program Project1;

uses
  FastCode in '..\FastCode.pas',
  Forms,
  Unit1 in 'Unit1.pas' {Form1},
  AnsiStringReplaceJOHIA32Unit12 in '..\AnsiStringReplaceJOHIA32Unit12.pas',
  AnsiStringReplaceJOHIA32Unit13 in '..\AnsiStringReplaceJOHIA32Unit13.pas',
  AnsiStringReplaceJOHPASUnit12 in '..\AnsiStringReplaceJOHPASUnit12.pas',
  FastCodeStrToInt32Unit in '..\FastCodeStrToInt32Unit.pas',
  FastCodeStrCopyUnit in '..\FastCodeStrCopyUnit.pas',
  FastcodeUpperCaseUnit in '..\FastcodeUpperCaseUnit.pas',
  FastCodeCompareTextUnit in '..\FastCodeCompareTextUnit.pas',
  FastcodeCPUID in '..\FastcodeCPUID.pas',
  FastcodeLowerCaseUnit in '..\FastcodeLowerCaseUnit.pas',
  FastCodePatch in '..\FastCodePatch.pas',
  FastCodePosUnit in '..\FastCodePosUnit.pas',
  FastCodeStrCompUnit in '..\FastCodeStrCompUnit.pas',
  FastCodeFillCharUnit in '..\FastCodeFillCharUnit.pas',
  FastCodeCompareStrUnit in '..\FastCodeCompareStrUnit.pas',
  FastCodeCompareMemUnit in '..\FastCodeCompareMemUnit.pas',
  FastCodePosExUnit in '..\FastCodePosExUnit.pas',
  FastCodeStrLenUnit in '..\FastCodeStrLenUnit.pas',
  FastCodeAnsiStringReplaceUnit in '..\FastCodeAnsiStringReplaceUnit.pas',
  FastcodeStrICompUnit in '..\FastcodeStrICompUnit.pas',
  FastCodeCharPos in '..\Non.RTL\FastCodeCharPos.pas',
  FastcodeGCDUnit in '..\Non.RTL\FastcodeGCDUnit.pas',
  FastcodeMaxIntUnit in '..\Non.RTL\FastcodeMaxIntUnit.pas',
  FastcodePosIEXUnit in '..\Non.RTL\FastcodePosIEXUnit.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
