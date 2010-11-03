program PoolTest;

uses
//  FastMM4,
//  FastMM4Messages,
  PatchLib in '..\PatchLib.pas',
  FastObj in '..\FastObj.pas',
  FastSys in '..\FastSys.pas',
  Forms,
  main in 'main.pas' {MainForm};

{$R *.res}

begin
  FastObj.InitAutoOptimize;
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
