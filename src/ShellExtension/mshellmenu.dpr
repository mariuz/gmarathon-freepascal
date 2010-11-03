// This COM server defines a Context Menu shell extension.  This allows the user
// to right click on Delphi Project files (.DPR) from the Explorer and compile
// them using the DCC32.exe command line compiler.

library mshellmenu;

uses
  ComServ,
  ContextM in 'ContextM.pas',
  mshellmenu_TLB in 'mshellmenu_TLB.pas',
  GSSRegistry in '..\Common\GSSRegistry.pas';

exports
  DllGetClassObject,
  DllCanUnloadNow,
  DllRegisterServer,
  DllUnregisterServer;

{$R *.TLB}

{$R *.RES}
{$R MShellmenuVersion.RES}

begin
end.
