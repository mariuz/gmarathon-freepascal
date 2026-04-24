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

{$MODE Delphi}

interface

uses SysUtils, Classes;

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

  TMarathonTreeNode = class;

  TMarathonTreeNode = class(TObject)
  private
    FData: Pointer;
    FParent: TMarathonTreeNode;
    FChildren: TList;
    FText: String;
    function GetChild(Index: Integer): TMarathonTreeNode;
    function GetCount: Integer;
  public
    constructor Create(AParent: TMarathonTreeNode);
    destructor Destroy; override;
    function AddChild(AData: Pointer; AText: String): TMarathonTreeNode;
    procedure DeleteChildren;
    function GetNextSibling: TMarathonTreeNode;
    function GetFirstChild: TMarathonTreeNode;
    function FindPathNode(Path: String; SepChar: Char = #2): TMarathonTreeNode;
    function AddPathNode(Path: String; SepChar: Char = #2): TMarathonTreeNode;
    function NodePath(SepChar: Char = #2): String;
    property Data: Pointer read FData write FData;
    property Parent: TMarathonTreeNode read FParent;
    property Text: String read FText write FText;
    property Count: Integer read GetCount;
    property Children[Index: Integer]: TMarathonTreeNode read GetChild; default;
    property Item[Index: Integer]: TMarathonTreeNode read GetChild;
  end;

  TMarathonTree = class(TObject)
  private
    FRoot: TMarathonTreeNode;
    FSepChar: Char;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
    function AddChild(AParent: TMarathonTreeNode; AData: Pointer; AText: String): TMarathonTreeNode;
    function FindPathNode(Path: String): TMarathonTreeNode;
    function AddPathNode(AParent: TMarathonTreeNode; Path: String): TMarathonTreeNode;
    property Root: TMarathonTreeNode read FRoot;
    property SepChar: Char read FSepChar write FSepChar;
  end;

implementation

{ TMarathonTreeNode }

constructor TMarathonTreeNode.Create(AParent: TMarathonTreeNode);
begin
  inherited Create;
  FParent := AParent;
  FChildren := TList.Create;
end;

destructor TMarathonTreeNode.Destroy;
begin
  DeleteChildren;
  FChildren.Free;
  inherited Destroy;
end;

function TMarathonTreeNode.AddChild(AData: Pointer; AText: String): TMarathonTreeNode;
begin
  Result := TMarathonTreeNode.Create(Self);
  Result.Data := AData;
  Result.Text := AText;
  FChildren.Add(Result);
end;

procedure TMarathonTreeNode.DeleteChildren;
var
  i: Integer;
begin
  for i := 0 to FChildren.Count - 1 do
    TMarathonTreeNode(FChildren[i]).Free;
  FChildren.Clear;
end;

function TMarathonTreeNode.GetChild(Index: Integer): TMarathonTreeNode;
begin
  Result := TMarathonTreeNode(FChildren[Index]);
end;

function TMarathonTreeNode.GetCount: Integer;
begin
  Result := FChildren.Count;
end;

function TMarathonTreeNode.GetFirstChild: TMarathonTreeNode;
begin
  if FChildren.Count > 0 then
    Result := TMarathonTreeNode(FChildren[0])
  else
    Result := nil;
end;

function TMarathonTreeNode.GetNextSibling: TMarathonTreeNode;
var
  Idx: Integer;
begin
  Result := nil;
  if Assigned(FParent) then
  begin
    Idx := FParent.FChildren.IndexOf(Self);
    if (Idx >= 0) and (Idx < FParent.FChildren.Count - 1) then
      Result := TMarathonTreeNode(FParent.FChildren[Idx + 1]);
  end;
end;

function TMarathonTreeNode.FindPathNode(Path: String; SepChar: Char): TMarathonTreeNode;
var
  S: String;
  Idx: Integer;
  i: Integer;
  Target: String;
begin
  Result := nil;
  if Path = '' then
  begin
    Result := Self;
    Exit;
  end;

  if Path[1] = SepChar then
    Delete(Path, 1, 1);

  Idx := Pos(SepChar, Path);
  if Idx > 0 then
  begin
    Target := Copy(Path, 1, Idx - 1);
    S := Copy(Path, Idx + 1, Length(Path));
  end
  else
  begin
    Target := Path;
    S := '';
  end;

  for i := 0 to FChildren.Count - 1 do
  begin
    if TMarathonTreeNode(FChildren[i]).Text = Target then
    begin
      Result := TMarathonTreeNode(FChildren[i]).FindPathNode(S, SepChar);
      Break;
    end;
  end;
end;

function TMarathonTreeNode.AddPathNode(Path: String; SepChar: Char): TMarathonTreeNode;
var
  S: String;
  Idx: Integer;
  i: Integer;
  Target: String;
  Node: TMarathonTreeNode;
begin
  if Path = '' then
  begin
    Result := Self;
    Exit;
  end;

  if Path[1] = SepChar then
    Delete(Path, 1, 1);

  Idx := Pos(SepChar, Path);
  if Idx > 0 then
  begin
    Target := Copy(Path, 1, Idx - 1);
    S := Copy(Path, Idx + 1, Length(Path));
  end
  else
  begin
    Target := Path;
    S := '';
  end;

  Node := nil;
  for i := 0 to FChildren.Count - 1 do
  begin
    if TMarathonTreeNode(FChildren[i]).Text = Target then
    begin
      Node := TMarathonTreeNode(FChildren[i]);
      Break;
    end;
  end;

  if not Assigned(Node) then
    Node := AddChild(nil, Target);

  Result := Node.AddPathNode(S, SepChar);
end;

function TMarathonTreeNode.NodePath(SepChar: Char): String;
begin
  if Assigned(FParent) then
  begin
    Result := FParent.NodePath(SepChar);
    if Result <> '' then
      Result := Result + SepChar + FText
    else
      Result := FText;
  end
  else
    Result := '';
end;

{ TMarathonTree }

constructor TMarathonTree.Create;
begin
  inherited Create;
  FRoot := TMarathonTreeNode.Create(nil);
  FSepChar := #2;
end;

destructor TMarathonTree.Destroy;
begin
  FRoot.Free;
  inherited Destroy;
end;

procedure TMarathonTree.Clear;
begin
  FRoot.DeleteChildren;
end;

function TMarathonTree.AddChild(AParent: TMarathonTreeNode; AData: Pointer; AText: String): TMarathonTreeNode;
begin
  if Assigned(AParent) then
    Result := AParent.AddChild(AData, AText)
  else
    Result := FRoot.AddChild(AData, AText);
end;

function TMarathonTree.FindPathNode(Path: String): TMarathonTreeNode;
begin
  Result := FRoot.FindPathNode(Path, FSepChar);
end;

function TMarathonTree.AddPathNode(AParent: TMarathonTreeNode; Path: String): TMarathonTreeNode;
begin
  if Assigned(AParent) then
    Result := AParent.AddPathNode(Path, FSepChar)
  else
    Result := FRoot.AddPathNode(Path, FSepChar);
end;

end.


