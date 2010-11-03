library gssscript;

uses
  ComServ,
  gssscript_TLB in 'gssscript_TLB.pas',
  GlobalMigrateWizard in 'GlobalMigrateWizard.pas' {frmGlobalMigrateWizard},
  DDLExtractor in 'DDLExtractor.pas',
  MetaExtractUnit in 'MetaExtractUnit.pas',
  GSSDDLExtractorServer in 'GSSDDLExtractorServer.pas' {GSSDDLExtractor: CoClass},
  Globals in 'Globals.pas',
  MarathonProjectCacheTypes in '..\Source\MarathonProjectCacheTypes.pas',
  GSSRegistry in '..\Common\GSSRegistry.pas';

exports
  DllGetClassObject,
  DllCanUnloadNow,
  DllRegisterServer,
  DllUnregisterServer;

{$R *.TLB}

{$R *.RES}
{$R GssscriptVersion.RES}

begin
end.
