unit gssscript_TLB;

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
// File generated on 10/22/2006 12:02:49 AM from Type Library described below.

// ************************************************************************  //
// Type Lib: C:\Source\Database Apps\gmarathon\src\MetaExtract\GSSScript.tlb (1)
// LIBID: {8B410880-409B-11D3-AE2C-0040056607F0}
// LCID: 0
// Helpfile: 
// HelpString: Gimbal Software Services IB Scripting Library
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
  gssscriptMajorVersion = 1;
  gssscriptMinorVersion = 0;

  LIBID_gssscript: TGUID = '{8B410880-409B-11D3-AE2C-0040056607F0}';

  IID_IGSSDDLExtractor: TGUID = '{EE5F85F0-40A1-11D3-AE2C-0040056607F0}';
  CLASS_GSSDDLExtractor: TGUID = '{EE5F85F4-40A1-11D3-AE2C-0040056607F0}';
type

// *********************************************************************//
// Forward declaration of types defined in TypeLibrary                    
// *********************************************************************//
  IGSSDDLExtractor = interface;
  IGSSDDLExtractorDisp = dispinterface;

// *********************************************************************//
// Declaration of CoClasses defined in Type Library                       
// (NOTE: Here we map each CoClass to its Default Interface)              
// *********************************************************************//
  GSSDDLExtractor = IGSSDDLExtractor;


// *********************************************************************//
// Interface: IGSSDDLExtractor
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {EE5F85F0-40A1-11D3-AE2C-0040056607F0}
// *********************************************************************//
  IGSSDDLExtractor = interface(IDispatch)
    ['{EE5F85F0-40A1-11D3-AE2C-0040056607F0}']
    procedure Set_DatabaseHandle(Param1: Integer); safecall;
    function Extract(ObjectType: Integer; ObjectSubType: Integer; const ObjectName: WideString): WideString; safecall;
    function DoWizard(const UserName: WideString; const Password: WideString): WordBool; safecall;
    procedure Set_AppHandle(Param1: Integer); safecall;
    function Get_MetaExtractType: Integer; safecall;
    procedure Set_MetaExtractType(Value: Integer); safecall;
    function Get_MetaCreateDatabase: WordBool; safecall;
    procedure Set_MetaCreateDatabase(Value: WordBool); safecall;
    function Get_MetaIncludePassword: WordBool; safecall;
    procedure Set_MetaIncludePassword(Value: WordBool); safecall;
    function Get_MetaIncludeDependents: WordBool; safecall;
    procedure Set_MetaIncludeDependents(Value: WordBool); safecall;
    function Get_MetaWrapOutput: WordBool; safecall;
    procedure Set_MetaWrapOutput(Value: WordBool); safecall;
    function Get_MetaDecimalPlaces: Integer; safecall;
    procedure Set_MetaDecimalPlaces(Value: Integer); safecall;
    function Get_MetaDecimalSeperator: WideString; safecall;
    procedure Set_MetaDecimalSeperator(const Value: WideString); safecall;
    function Get_MetaWrapOutputAt: Integer; safecall;
    procedure Set_MetaWrapOutputAt(Value: Integer); safecall;
    procedure Set_MetaDBUserName(const Param1: WideString); safecall;
    procedure Set_MetaDBPassword(const Param1: WideString); safecall;
    procedure DoWizardList; safecall;
    procedure AddObjectInfo(const ObjectName: WideString; ObjectType: Integer); safecall;
    procedure Set_SQLDialect(Param1: Integer); safecall;
    procedure Set_IB6(Param1: WordBool); safecall;
    procedure Set_MetaDBDatabaseName(const Param1: WideString); safecall;
    procedure Set_MetaDefaultDirectory(const Param1: WideString); safecall;
    function Get_MetaIncludeDoc: WordBool; safecall;
    procedure Set_MetaIncludeDoc(Value: WordBool); safecall;
    property DatabaseHandle: Integer write Set_DatabaseHandle;
    property AppHandle: Integer write Set_AppHandle;
    property MetaExtractType: Integer read Get_MetaExtractType write Set_MetaExtractType;
    property MetaCreateDatabase: WordBool read Get_MetaCreateDatabase write Set_MetaCreateDatabase;
    property MetaIncludePassword: WordBool read Get_MetaIncludePassword write Set_MetaIncludePassword;
    property MetaIncludeDependents: WordBool read Get_MetaIncludeDependents write Set_MetaIncludeDependents;
    property MetaWrapOutput: WordBool read Get_MetaWrapOutput write Set_MetaWrapOutput;
    property MetaDecimalPlaces: Integer read Get_MetaDecimalPlaces write Set_MetaDecimalPlaces;
    property MetaDecimalSeperator: WideString read Get_MetaDecimalSeperator write Set_MetaDecimalSeperator;
    property MetaWrapOutputAt: Integer read Get_MetaWrapOutputAt write Set_MetaWrapOutputAt;
    property MetaDBUserName: WideString write Set_MetaDBUserName;
    property MetaDBPassword: WideString write Set_MetaDBPassword;
    property SQLDialect: Integer write Set_SQLDialect;
    property IB6: WordBool write Set_IB6;
    property MetaDBDatabaseName: WideString write Set_MetaDBDatabaseName;
    property MetaDefaultDirectory: WideString write Set_MetaDefaultDirectory;
    property MetaIncludeDoc: WordBool read Get_MetaIncludeDoc write Set_MetaIncludeDoc;
  end;

// *********************************************************************//
// DispIntf:  IGSSDDLExtractorDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {EE5F85F0-40A1-11D3-AE2C-0040056607F0}
// *********************************************************************//
  IGSSDDLExtractorDisp = dispinterface
    ['{EE5F85F0-40A1-11D3-AE2C-0040056607F0}']
    property DatabaseHandle: Integer writeonly dispid 1;
    function Extract(ObjectType: Integer; ObjectSubType: Integer; const ObjectName: WideString): WideString; dispid 5;
    function DoWizard(const UserName: WideString; const Password: WideString): WordBool; dispid 2;
    property AppHandle: Integer writeonly dispid 6;
    property MetaExtractType: Integer dispid 3;
    property MetaCreateDatabase: WordBool dispid 4;
    property MetaIncludePassword: WordBool dispid 8;
    property MetaIncludeDependents: WordBool dispid 10;
    property MetaWrapOutput: WordBool dispid 11;
    property MetaDecimalPlaces: Integer dispid 12;
    property MetaDecimalSeperator: WideString dispid 13;
    property MetaWrapOutputAt: Integer dispid 14;
    property MetaDBUserName: WideString writeonly dispid 15;
    property MetaDBPassword: WideString writeonly dispid 16;
    procedure DoWizardList; dispid 9;
    procedure AddObjectInfo(const ObjectName: WideString; ObjectType: Integer); dispid 17;
    property SQLDialect: Integer writeonly dispid 7;
    property IB6: WordBool writeonly dispid 18;
    property MetaDBDatabaseName: WideString writeonly dispid 19;
    property MetaDefaultDirectory: WideString writeonly dispid 20;
    property MetaIncludeDoc: WordBool dispid 21;
  end;

// *********************************************************************//
// The Class CoGSSDDLExtractor provides a Create and CreateRemote method to          
// create instances of the default interface IGSSDDLExtractor exposed by              
// the CoClass GSSDDLExtractor. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoGSSDDLExtractor = class
    class function Create: IGSSDDLExtractor;
    class function CreateRemote(const MachineName: string): IGSSDDLExtractor;
  end;

implementation

uses ComObj;

class function CoGSSDDLExtractor.Create: IGSSDDLExtractor;
begin
  Result := CreateComObject(CLASS_GSSDDLExtractor) as IGSSDDLExtractor;
end;

class function CoGSSDDLExtractor.CreateRemote(const MachineName: string): IGSSDDLExtractor;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_GSSDDLExtractor) as IGSSDDLExtractor;
end;

end.
