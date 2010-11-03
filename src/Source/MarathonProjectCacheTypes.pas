{******************************************************************}
{ The contents of this file are used with permission, subject to   }
{ the Mozilla Public License Version 1.1 (the "License"); you may  }
{ not use this file except in compliance with the License. You may }
{ obtain a copy of the License at                                  }
{ http://www.mozilla.org/MPL/MPL-1.1.html                          }
{                                                                  }
{ Software distributed under the License is distributed on an      }
{ "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, either express or   }
{ implied. See the License for the specific language governing     }
{ rights and limitations under the License.                        }
{                                                                  }
{******************************************************************}
// $Id: MarathonProjectCacheTypes.pas,v 1.3 2005/04/13 16:04:30 rjmills Exp $

//This comment block was moved to clear up a compiler warning, RJM

{
$Log: MarathonProjectCacheTypes.pas,v $
Revision 1.3  2005/04/13 16:04:30  rjmills
*** empty log message ***

Revision 1.2  2002/04/25 07:21:30  tmuetze
New CVS powered comment block
}

unit MarathonProjectCacheTypes;

interface

uses
  SysUtils, Classes;

type
  TGSSCacheOp = (
    opConnect,
    opDisconnect,
    opDisconnected,
    opPrint,
    opPrintPreview,
    opNew,
    opDelete,
    opOpen,
    opDrop,
    opProperties,
    opRefresh,
    opRefreshNoFocus,
    opExpandNode,
    opRemoveNode,
    opExtractDDL,
    opAddToProject,
    opCreateFolder);

  TGSSCacheType = (
    ctDontCare,
    ctErrorItem,
    ctConnection,
    ctServer,
    ctSQL,
    ctSQLEditor,
    ctFolder,
    ctFolderItem,
    ctRecentHeader,
    ctRecentItem,
    ctCacheHeader,
    ctDomainHeader,
    ctDomain,
    ctTableHeader,
    ctTable,
    ctViewHeader,
    ctView,
    ctSPHeader,
    ctSP,
    ctSPTemplate,
    ctTriggerHeader,
    ctTrigger,
    ctGeneratorHeader,
    ctGenerator,
    ctExceptionHeader,
    ctException,
    ctUDFHeader,
    ctUDF);

  TSortOrder = (srtAsc, srtDesc);

  TSPPrintOption = (prSPCode, prSPDoco);
  TSPPrintOptions = set of TSPPrintOption;

  TTrigPrintOption = (prTrigCode, prTrigDoco);
  TTrigPrintOptions = set of TTrigPrintOption;

  TEXPrintOption = (prEXCode, prEXDoco);
  TEXPrintOptions = set of TEXPrintOption;

  TUDFPrintOption = (prUDFCode, prUDFDoco);
  TUDFPrintOptions = set of TUDFPrintOption;

  TTabPrintOption = (prTabStruct, prTabConstraints, prTabIndexes, prTabDepend, prTabTriggers, prTabDoco);
  TTabPrintOptions = set of TTabPrintOption;

  TViewPrintOption = (prViewCode, prViewStruct, prViewDepend, prViewTriggers, prViewDoco);
  TViewPrintOptions = set of TViewPrintOption;


  TSearchOption = (soCaseSensitive,
                   soNamesOnly,
                   soDomains,
                   soTables,
                   soViews,
                   soTrig,
                   soSP,
                   soGenerators,
                   soExceptions,
                   soUDFs,
                   soDoco);

  TSearchOptions = set of TSearchOption;

{  TNodeType = (dbntRoot,
               dbntConnection,
               dbntDomainHeader,
               dbntDomain,
               dbntTableHeader,
               dbntTable,
               dbntViewHeader,
               dbntView,
               dbntStoredProcHeader,
               dbntStoredProc,
               dbntTriggerHeader,
               dbntTrigger,
               dbntGeneratorHeader,
               dbntGenerator,
               dbntExceptionHeader,
               dbntException,
               dbntUDFHeader,
               dbntUDF,
               dbntDoco,
               dbntError,
               dbntMiscHeader,
               dbntMisc,
               dbntProject,
               dbntFolder,
               dbntRecent);
 }
   TGSSObjectType = (
     objDomain);

implementation

end.


