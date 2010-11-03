unit GimbalCreateDatabase_TLB;

// ************************************************************************ //
// WARNING                                                                    
// -------                                                                    
// The types declared in this file were generated from data read from a       
// Type Library. If this type library is explicitly or indirectly (via        
// another type library referring to this type library) re-imported, or the   
// 'Refresh' command of the Type Library Editor activated while editing the   
// Type Library, the contents of this file will be regenerated and all        
// manual modifications will be lost.                                         
// ************************************************************************ //

// PASTLWTR : 1.2
// File generated on 10/17/2006 2:23:22 PM from Type Library described below.

// ************************************************************************  //
// Type Lib: C:\Source\Database Apps\gmarathon\src\CreateDBWizard\CDatabse.tlb (1)
// LIBID: {69D66B56-6CD8-412F-86E6-1566D57E61FC}
// LCID: 0
// Helpfile: 
// HelpString: cdatabse Library
// DepndLst: 
//   (1) v2.0 stdole, (C:\WINDOWS\system32\STDOLE2.TLB)
// ************************************************************************ //
{$TYPEDADDRESS OFF} // Unit must be compiled without type-checked pointers. 
{$WARN SYMBOL_PLATFORM OFF}
{$WRITEABLECONST ON}
{$VARPROPSETTER ON}
interface

uses Windows, ActiveX, Classes, Graphics, StdVCL, Variants;
  

// *********************************************************************//
// GUIDS declared in the TypeLibrary. Following prefixes are used:        
//   Type Libraries     : LIBID_xxxx                                      
//   CoClasses          : CLASS_xxxx                                      
//   DISPInterfaces     : DIID_xxxx                                       
//   Non-DISP interfaces: IID_xxxx                                        
// *********************************************************************//
const
  // TypeLibrary Major and minor versions
  GimbalCreateDatabaseMajorVersion = 1;
  GimbalCreateDatabaseMinorVersion = 0;

  LIBID_GimbalCreateDatabase: TGUID = '{69D66B56-6CD8-412F-86E6-1566D57E61FC}';

  IID_IGSSCreateDatabase: TGUID = '{22645070-D79C-49AF-BCB9-AF661F9D3343}';
  CLASS_GSSCreateDatabase: TGUID = '{4CC9F886-D321-4613-BB26-CE66247AEA4C}';
  IID_IGSSCreateDatabaseInfo: TGUID = '{C736CA72-4812-4FE9-9D88-013F2A9E1BA6}';
  CLASS_GSSCreateDatabaseInfo: TGUID = '{7E64F9F2-402A-4D4D-B448-C2873C48F8BC}';
type

// *********************************************************************//
// Forward declaration of types defined in TypeLibrary                    
// *********************************************************************//
  IGSSCreateDatabase = interface;
  IGSSCreateDatabaseDisp = dispinterface;
  IGSSCreateDatabaseInfo = interface;
  IGSSCreateDatabaseInfoDisp = dispinterface;

// *********************************************************************//
// Declaration of CoClasses defined in Type Library                       
// (NOTE: Here we map each CoClass to its Default Interface)              
// *********************************************************************//
  GSSCreateDatabase = IGSSCreateDatabase;
  GSSCreateDatabaseInfo = IGSSCreateDatabaseInfo;


// *********************************************************************//
// Interface: IGSSCreateDatabase
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {22645070-D79C-49AF-BCB9-AF661F9D3343}
// *********************************************************************//
  IGSSCreateDatabase = interface(IDispatch)
    ['{22645070-D79C-49AF-BCB9-AF661F9D3343}']
    function Execute(AppHandle: Integer; CallingApp: Integer; State: Integer): IGSSCreateDatabaseInfo; safecall;
  end;

// *********************************************************************//
// DispIntf:  IGSSCreateDatabaseDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {22645070-D79C-49AF-BCB9-AF661F9D3343}
// *********************************************************************//
  IGSSCreateDatabaseDisp = dispinterface
    ['{22645070-D79C-49AF-BCB9-AF661F9D3343}']
    function Execute(AppHandle: Integer; CallingApp: Integer; State: Integer): IGSSCreateDatabaseInfo; dispid 1;
  end;

// *********************************************************************//
// Interface: IGSSCreateDatabaseInfo
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {C736CA72-4812-4FE9-9D88-013F2A9E1BA6}
// *********************************************************************//
  IGSSCreateDatabaseInfo = interface(IDispatch)
    ['{C736CA72-4812-4FE9-9D88-013F2A9E1BA6}']
    function Get_DatabaseName: WideString; safecall;
    procedure Set_DatabaseName(const Value: WideString); safecall;
    function Get_UserName: WideString; safecall;
    procedure Set_UserName(const Value: WideString); safecall;
    function Get_Password: WideString; safecall;
    procedure Set_Password(const Value: WideString); safecall;
    function Get_CharSet: WideString; safecall;
    procedure Set_CharSet(const Value: WideString); safecall;
    function Get_Dialect: Integer; safecall;
    procedure Set_Dialect(Value: Integer); safecall;
    function Get_CreateProject: WordBool; safecall;
    procedure Set_CreateProject(Value: WordBool); safecall;
    function Get_CreateConnection: WordBool; safecall;
    procedure Set_CreateConnection(Value: WordBool); safecall;
    function Get_ConnectionName: WideString; safecall;
    procedure Set_ConnectionName(const Value: WideString); safecall;
    function Get_ProjectName: WideString; safecall;
    procedure Set_ProjectName(const Value: WideString); safecall;
    property DatabaseName: WideString read Get_DatabaseName write Set_DatabaseName;
    property UserName: WideString read Get_UserName write Set_UserName;
    property Password: WideString read Get_Password write Set_Password;
    property CharSet: WideString read Get_CharSet write Set_CharSet;
    property Dialect: Integer read Get_Dialect write Set_Dialect;
    property CreateProject: WordBool read Get_CreateProject write Set_CreateProject;
    property CreateConnection: WordBool read Get_CreateConnection write Set_CreateConnection;
    property ConnectionName: WideString read Get_ConnectionName write Set_ConnectionName;
    property ProjectName: WideString read Get_ProjectName write Set_ProjectName;
  end;

// *********************************************************************//
// DispIntf:  IGSSCreateDatabaseInfoDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {C736CA72-4812-4FE9-9D88-013F2A9E1BA6}
// *********************************************************************//
  IGSSCreateDatabaseInfoDisp = dispinterface
    ['{C736CA72-4812-4FE9-9D88-013F2A9E1BA6}']
    property DatabaseName: WideString dispid 1;
    property UserName: WideString dispid 2;
    property Password: WideString dispid 3;
    property CharSet: WideString dispid 4;
    property Dialect: Integer dispid 5;
    property CreateProject: WordBool dispid 6;
    property CreateConnection: WordBool dispid 7;
    property ConnectionName: WideString dispid 9;
    property ProjectName: WideString dispid 10;
  end;

// *********************************************************************//
// The Class CoGSSCreateDatabase provides a Create and CreateRemote method to          
// create instances of the default interface IGSSCreateDatabase exposed by              
// the CoClass GSSCreateDatabase. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoGSSCreateDatabase = class
    class function Create: IGSSCreateDatabase;
    class function CreateRemote(const MachineName: string): IGSSCreateDatabase;
  end;

// *********************************************************************//
// The Class CoGSSCreateDatabaseInfo provides a Create and CreateRemote method to          
// create instances of the default interface IGSSCreateDatabaseInfo exposed by              
// the CoClass GSSCreateDatabaseInfo. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoGSSCreateDatabaseInfo = class
    class function Create: IGSSCreateDatabaseInfo;
    class function CreateRemote(const MachineName: string): IGSSCreateDatabaseInfo;
  end;

implementation

uses ComObj;

class function CoGSSCreateDatabase.Create: IGSSCreateDatabase;
begin
  Result := CreateComObject(CLASS_GSSCreateDatabase) as IGSSCreateDatabase;
end;

class function CoGSSCreateDatabase.CreateRemote(const MachineName: string): IGSSCreateDatabase;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_GSSCreateDatabase) as IGSSCreateDatabase;
end;

class function CoGSSCreateDatabaseInfo.Create: IGSSCreateDatabaseInfo;
begin
  Result := CreateComObject(CLASS_GSSCreateDatabaseInfo) as IGSSCreateDatabaseInfo;
end;

class function CoGSSCreateDatabaseInfo.CreateRemote(const MachineName: string): IGSSCreateDatabaseInfo;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_GSSCreateDatabaseInfo) as IGSSCreateDatabaseInfo;
end;

end.
