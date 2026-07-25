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
// $Id: PlanUnit.pas,v 1.3 2005/04/13 16:04:30 rjmills Exp $

//Comment block moved clear up a compiler warning. RJM

{
$Log: PlanUnit.pas,v $
Revision 1.3  2005/04/13 16:04:30  rjmills
*** empty log message ***

Revision 1.2  2002/04/25 07:21:30  tmuetze
New CVS powered comment block

}

unit PlanUnit;

{$MODE Delphi}

interface

uses Classes, SysUtils, Graphics, ParseCollection, Dialogs, DiagramTree, InterbaseExplainPlan;

type
  TPlanType = (pptNone, pptJoin, pptSortMerge, pptMerge, pptSort);
  TAccessType = (atNatural, atIndex, atOrder);

  TPlanObject = class(TObject)
  private
    FSTatement: TStatement;
  public
    property RootStatement : TStatement read FSTatement write FStatement;
    procedure FillTree(Tree : TDiagramTree);
    constructor Create;
    destructor Destroy; override;
  end;

  TPlanExpressionStatement = class(TStatement)
  private
    FPlanType: TStatement;
    FPlanList: TStatement;
  public
    property PlanType : TStatement read FPlanType write FPlanType;
    property PlanList : TStatement read FPlanList write FPlanList;
  end;

  TPlanNodeTypeStatement = class(TStatement)
  private
    FPlanType: TPlanType;
  public
    property PlanType : TPlanType read FPlanType write FPlanType;
  end;

  TPlanNodeItemListStatement = class(TStatement)
  private
    FItemList: TList;
  public
    property ItemList : TList read FItemList write FItemList;
    constructor Create;
    destructor Destroy; override;
  end;

  TPlanNodeItemStatement = class(TStatement)
  private
    FTableList: TSTatement;
    FAccessType: TStatement;
  public
    property TableList : TSTatement read FTableList write FTableList;
    property AccessType : TStatement read FAccessType write FAccessType;
  end;

  TPlanNodeTableListStatement = class(TStatement)
  private
    FTableList: TList;

  public
    property TableList : TList read FTableList write FTableList;
    constructor Create;
    destructor Destroy; override;
  end;

  TPlanNodeAccessTypeStatement = class(TStatement)
  private
    FAccessType: TAccessType;
    FIndexList: TStatement;
    FArgument: String;

  public
    property AccessType : TAccessType read FAccessType write FAccessType;
    property IndexList : TStatement read FIndexList write FIndexList;
    property Argument : String read FArgument write FArgument;
  end;

	TPlanNodeIndexListStatement = class(TStatement)
	private
		FIndexList: TList;

	public
		property IndexList : TList read FIndexList write FIndexList;
		constructor Create;
		destructor Destroy; override;
	end;

{ Firebird 3+ client libraries only return the newer, indentation-structured
  "explained" plan format (Select Expression / -> Filter / -> Table ... /
  -> Bitmap / -> Index ...) - the classic single-line "PLAN (T INDEX (IX))"
  format that TPlanObject.FillTree/SQLYacc's ptPlan grammar parses is no
  longer produced by TIBQuery.GetPlan against a live server, so it needs its
  own much simpler indentation-based tree builder. }
procedure FillTreeFromExplainedPlan(const PlanText: String; Tree: TDiagramTree);

implementation

constructor TPlanNodeItemListStatement.Create;
begin
	inherited Create;
	FItemList := TList.Create;
end;

destructor TPlanNodeItemListStatement.Destroy;
begin
	FItemList.Free;
	inherited;
end;

{ TPlanNodeTableListStatement }

constructor TPlanNodeTableListStatement.Create;
begin
	inherited Create;
	FTableList := TList.Create;
end;

destructor TPlanNodeTableListStatement.Destroy;
begin
	FTableList.Free;
	inherited;
end;

{ TPlanNodeIndexListStatement }

constructor TPlanNodeIndexListStatement.Create;
begin
	inherited Create;
  FIndexList := TList.Create;
end;

destructor TPlanNodeIndexListStatement.Destroy;
begin
  FIndexList.Free;
  inherited;
end;

{ TPlanObject }

constructor TPlanObject.Create;
begin
  inherited Create;
end;

destructor TPlanObject.Destroy;
begin
  inherited;
end;

procedure TPlanObject.FillTree(Tree: TDiagramTree);

  procedure RecurseNodes(PlanNode : TStatement; TreeNode : TDiagramNode);
  var
    Data : TInterbasePlanObject;
    TData : TInterbasePlanObject;
    Node : TDiagramNode;
    SubNode : TDiagramNode;
		S : TStatement;
		S1 : TStatement;
		TabList : TStatement;
    IndexList : TStatement;
    AccessType : TStatement;
    Idx : Integer;
    Idy : Integer;
    Idz : Integer;

  begin
    Data := TInterBasePlanObject.Create;

    case TPlanNodeTypeStatement(TPlanExpressionStatement(PlanNode).PlanType).PlanType of
      pptNone :
        begin
          Data.Caption := 'NO MERGE/SORT/JOIN';
          Data.ImageIndex := 0;
        end;
      pptJoin :
        begin
          Data.Caption := 'JOIN';
          Data.ImageIndex := 1;
        end;
      pptSortMerge :
        begin
          Data.Caption := 'SORT MERGE';
          Data.ImageIndex := 2;
        end;
      pptMerge :
        begin
          Data.Caption := 'MERGE';
          Data.ImageIndex := 3;
        end;
      pptSort :
        begin
          Data.Caption := 'SORT';
          Data.ImageIndex := 4;
        end;
    end;
		Data.NodeType := pntOperation;
    Node := Tree.AddNode(Data.Caption, TreeNode);
    Node.Caption := Data.Caption;
    Node.ImageIndex := Data.ImageIndex;
    Node.Data := Data;
    S := TPlanExpressionStatement(PlanNode).PlanList;
    if Assigned(S) then
    begin
      for Idx := 0 to TPlanNodeItemListStatement(S).ItemList.Count - 1 do
      begin
        S1 := TPlanNodeItemListStatement(S).ItemList[Idx];
        if S1 is TPlanNodeItemStatement then
        begin
          TabList := TPlanNodeItemStatement(S1).TableList;
          for Idy := 0 to TPlanNodeTableListStatement(TabList).TableList.Count - 1 do
          begin
            TData := TInterBasePlanObject.Create;
            TData.NodeType := pntRelation;
            TData.Caption := TStatement(TPlanNodeTableListStatement(TabList).TableList[Idy]).Value;
            SubNode := Tree.AddNode(TData.Caption, Node);
            SubNode.Caption := TData.Caption;
            SubNode.Data := TData;

            AccessType := TPlanNodeItemStatement(S1).AccessType;
            case TPlanNodeAccessTypeStatement(AccessType).AccessType of
              atNatural :
								begin
                  TData.AccessType := 'NATURAL';
                  TData.ImageIndex := 5;
                  { Full table scan - flag it, since this is usually the thing
                    a developer is looking for when reading a plan. }
                  SubNode.Color := $00C8C8FF;
                end;

              atIndex :
                begin
                  TData.AccessType := 'INDEX';
                  TData.ImageIndex := 6;
                  SubNode.Color := $00C8FFC8;
                  IndexList := TPlanNodeAccessTypeStatement(AccessType).IndexList;
                  for Idz := 0 to TPlanNodeIndexListStatement(IndexList).IndexList.Count - 1 do
                  begin
                    TData.ItemList.Add(TStatement(TPlanNodeIndexListStatement(IndexList).IndexList[Idz]).Value);
									end;
                end;

              atOrder :
                begin
                  TData.AccessType := 'ORDER';
                  TData.ImageIndex := 7;
                  SubNode.Color := $00C8FFC8;
                end;
            end;
            SubNode.ImageIndex := TData.ImageIndex;
          end;
        end;
        if S1 is TPlanExpressionStatement then
        begin
          RecurseNodes(S1, Node);
        end;
      end;
    end;
  end;

begin
  Tree.Clear;
  RecurseNodes(FStatement, nil);
  Tree.Redraw;
end;

procedure FillTreeFromExplainedPlan(const PlanText: String; Tree: TDiagramTree);
var
  Lines: TStringList;
  Stack: array of TDiagramNode;
  Idx, Depth, Indent: Integer;
  Line, Caption: String;
  ParentNode, Node, RootNode: TDiagramNode;
begin
  Tree.Clear;
  if Trim(PlanText) = '' then
    Exit;

  Lines := TStringList.Create;
  try
    Lines.Text := PlanText;

    { A single synthetic root so multiple top-level "Select Expression"
      blocks (correlated subqueries) become siblings instead of each
      overwriting Tree.Root in turn. }
    RootNode := Tree.AddNode('Plan', nil);
    RootNode.Caption := 'Plan';
    SetLength(Stack, 1);
    Stack[0] := RootNode;

    for Idx := 0 to Lines.Count - 1 do
    begin
      Line := Lines[Idx];
      if Trim(Line) = '' then
        Continue;

      Indent := 0;
      while (Indent < Length(Line)) and (Line[Indent + 1] = ' ') do
        Inc(Indent);
      Depth := (Indent div 4) + 1;

      Caption := Trim(Line);
      if Copy(Caption, 1, 3) = '-> ' then
        Caption := Copy(Caption, 4, MaxInt);

      if Depth > Length(Stack) then
        ParentNode := Stack[High(Stack)]
      else
        ParentNode := Stack[Depth - 1];

      Node := Tree.AddNode(Caption, ParentNode);
      Node.Caption := Caption;

      if Pos('Full Scan', Caption) > 0 then
      begin
        { Full table scan - usually the thing worth flagging in a plan. }
        Node.ImageIndex := 5;
        Node.Color := $00C8C8FF;
      end
      else if (Pos('Index "', Caption) > 0) or (Pos('Access By ID', Caption) > 0) then
      begin
        Node.ImageIndex := 6;
        Node.Color := $00C8FFC8;
      end;

      SetLength(Stack, Depth + 1);
      Stack[Depth] := Node;
    end;
  finally
    Lines.Free;
  end;
  Tree.Redraw;
end;

end.


