library cdatabse;

uses
  ComServ,
  GimbalCreateDatabase_TLB in 'GimbalCreateDatabase_TLB.pas',
  GSSCreateDatabaseImpl in 'GSSCreateDatabaseImpl.pas' {GSSCreateDatabase: CoClass},
  CreateDatabase in 'CreateDatabase.pas' {frmCreateDatabase},
  GSSDatabaseInfoImpl in 'GSSDatabaseInfoImpl.pas' {GSSCreateDatabaseInfo: CoClass},
  GSSCreateDatabaseConsts in 'GSSCreateDatabaseConsts.pas',
  DBAddSecondaryFile in 'DBAddSecondaryFile.pas' {frmDBSecondaryFile};

exports
  DllGetClassObject,
  DllCanUnloadNow,
  DllRegisterServer,
  DllUnregisterServer;

{$R *.TLB}

{$R *.RES}
{$R CDatabseVersion.RES}

begin
end.
