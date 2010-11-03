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
// $Id: MenuModule.pas,v 1.5 2006/10/22 06:04:28 rjmills Exp $

//Comment block moved to remove compiler warning. RJM

{
$Log: MenuModule.pas,v $
Revision 1.5  2006/10/22 06:04:28  rjmills
Fixes and Updates for Look and Feel in WinXP

Revision 1.4  2005/04/13 16:04:30  rjmills
*** empty log message ***

Revision 1.3  2002/09/23 10:32:51  tmuetze
Added the possibility to load files into the SQL Editor

Revision 1.2  2002/04/25 07:21:30  tmuetze
New CVS powered comment block

}

unit MenuModule;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
	Menus, ImgList,
	rmDataStorage,
	SynEditHighlighter,
	SynHighlighterSQL, SynEditMiscClasses, SynEditSearch;

type
  TdmMenus = class(TDataModule)
    mnuSQLEditor: TPopupMenu;
    Execute2: TMenuItem;
    N13: TMenuItem;
    SetBookmark1: TMenuItem;
    Bookmark01: TMenuItem;
    Bookmark11: TMenuItem;
    Bookmark21: TMenuItem;
    Bookmark31: TMenuItem;
    Bookmark41: TMenuItem;
    Bookmark51: TMenuItem;
    Bookmark61: TMenuItem;
    Bookmark71: TMenuItem;
    Bookmark81: TMenuItem;
    Bookmark91: TMenuItem;
    GotoBookmark1: TMenuItem;
    GB0: TMenuItem;
    GB1: TMenuItem;
    GB2: TMenuItem;
    GB3: TMenuItem;
    GB4: TMenuItem;
    GB5: TMenuItem;
    GB6: TMenuItem;
    GB7: TMenuItem;
    GB8: TMenuItem;
    GB9: TMenuItem;
    MenuItem1: TMenuItem;
    ClearEditBuffer2: TMenuItem;
    N14: TMenuItem;
    Cut2: TMenuItem;
    Copy2: TMenuItem;
    Paste2: TMenuItem;
    SelectAll2: TMenuItem;
    N12: TMenuItem;
    Statement1: TMenuItem;
    NextStatement1: TMenuItem;
		PreviousStatement1: TMenuItem;
    N15: TMenuItem;
    StatementHistory1: TMenuItem;
    N16: TMenuItem;
    mnuiSaveToFile: TMenuItem;
    MenuItem2: TMenuItem;
    Properties1: TMenuItem;
    mnuListResults: TPopupMenu;
    Copy3: TMenuItem;
    mnuDataMenu: TPopupMenu;
    SaveToFile1: TMenuItem;
    N20: TMenuItem;
    Refresh1: TMenuItem;
    N21: TMenuItem;
    Compile1: TMenuItem;
    Rollback1: TMenuItem;
    N1: TMenuItem;
    Compile2: TMenuItem;
    Parameters1: TMenuItem;
    Rollback2: TMenuItem;
    lstKeyWords: TrmTextDataStorage;
    lstCharSets: TrmTextDataStorage;
    ilErrors: TImageList;
    Debugger1: TMenuItem;
    ObjectToggleBreakPoint1: TMenuItem;
    ObjectAddWatchAtCursor1: TMenuItem;
    mnuTree: TPopupMenu;
    ProjectNewItem1: TMenuItem;
    ProjectOpenItem1: TMenuItem;
    ProjectExtractMetadata1: TMenuItem;
    ProjectAddToProject1: TMenuItem;
    ProjectCreateFolder1: TMenuItem;
    ProjectItemDelete1: TMenuItem;
    ProjectItemDrop1: TMenuItem;
    MenuItem3: TMenuItem;
    ProjectItemProperties1: TMenuItem;
    N4: TMenuItem;
    Print1: TMenuItem;
    PrintPreview1: TMenuItem;
		N3: TMenuItem;
    ViewRefresh1: TMenuItem;
    N5: TMenuItem;
    N2: TMenuItem;
    NewConnection1: TMenuItem;
    NewServer1: TMenuItem;
    mnuFields: TPopupMenu;
    New1: TMenuItem;
    N7: TMenuItem;
    N8: TMenuItem;
    N10: TMenuItem;
    N11: TMenuItem;
    Drop1: TMenuItem;
    N18: TMenuItem;
    N22: TMenuItem;
    N23: TMenuItem;
    N24: TMenuItem;
    N9: TMenuItem;
    Properties2: TMenuItem;
    N25: TMenuItem;
    ReorderColumns1: TMenuItem;
    N26: TMenuItem;
    Grant1: TMenuItem;
    Revoke1: TMenuItem;
    mnuUDF: TPopupMenu;
    InputParameter1: TMenuItem;
    InputParameter2: TMenuItem;
    N6: TMenuItem;
    Properties3: TMenuItem;
    Connect1: TMenuItem;
    Disconnect1: TMenuItem;
    N27: TMenuItem;
    Cut1: TMenuItem;
    Copy1: TMenuItem;
    Paste1: TMenuItem;
    synHighlighter: TSynSQLSyn;
    Open1: TMenuItem;
    New2: TMenuItem;
    N28: TMenuItem;
		N17: TMenuItem;
    Tools1: TMenuItem;
    N29: TMenuItem;
    PrintPreview2: TMenuItem;
    Print2: TMenuItem;
    N30: TMenuItem;
    PrintPreview3: TMenuItem;
    Print3: TMenuItem;
    N31: TMenuItem;
    PrintPreview4: TMenuItem;
    Print4: TMenuItem;
    mnuiLoadFromFile: TMenuItem;
    SynEditSearch1: TSynEditSearch;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  dmMenus: TdmMenus;

implementation

{uses
  MarathonMain;}

{$R *.DFM}

end.


