library autoinc;

uses
  SysUtils,
  Classes,
  Windows,
  Dialogs,
  Forms,
  GimbalToolsAPI in '..\..\Source\GimbalToolsAPI.pas',
  AutoIncrementFieldWizardPlugin in 'AutoIncrementFieldWizardPlugin.pas',
	AutoIncrementFieldWizard in 'AutoIncrementFieldWizard.pas' {frmAutoInc};

{$R *.RES}
{$R AutoincVersion.RES}

procedure PluginDLLProc(Reason : DWord);
begin
	case Reason of
		 DLL_PROCESS_DETACH:
			 begin
				 Application.Handle := OldApplicationHandle;
				 LocalToolServices := nil;
			 end;
	end;
end;

exports
  GimbalPluginInit,
  GimbalPluginExecute;

begin
  DLLProc := @PluginDLLProc;
end.
