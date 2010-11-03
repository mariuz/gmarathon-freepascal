program screxec;

uses
  Forms,
  ScriptMain in 'ScriptMain.pas' {frmScript},
  AboutBox in '..\Common\AboutBox.pas' {frmAboutBox},
  ScriptOptions in 'ScriptOptions.pas' {frmScriptOptions},
  ChooseFolder in '..\Common\ChooseFolder.pas' {frmChooseFolder},
  StopDialog in 'StopDialog.pas' {frmStopExecution},
  GSSRegistry in '..\Common\GSSRegistry.pas',
  ScriptExecutive in '..\Common\ScriptExecutive.pas',
  Tools in '..\Common\Tools.pas';

{$R *.RES}
{$R ScrExecVersion.RES}

begin
  Application.Title := 'Marathon Script Executive';
  Application.CreateForm(TfrmScript, frmScript);
  Application.Run;
end.
