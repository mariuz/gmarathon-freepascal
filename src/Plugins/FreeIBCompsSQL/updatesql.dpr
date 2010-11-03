library updatesql;

uses
  SysUtils,
  Classes,
  Windows,
  Dialogs,
  Forms,
  GimbalToolsAPI in '..\..\Source\GimbalToolsAPI.pas',
  UpdateSQLPlugin in 'UpdateSQLPlugin.pas',
  FreeIBCompsSQL in 'FreeIBCompsSQL.pas' {frmFreeIBComponentsSQL};
    
{$R *.RES}
{$R UpdateSQLVersion.RES}

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
