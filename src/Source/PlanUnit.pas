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

interface

uses
	Classes, SysUtils, Windows, ParseCollection, Dialogs,
	DiagramTree,
	InterbaseExplainPlan;

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
                end;

              atIndex :
                begin
                  TData.AccessType := 'INDEX';
                  TData.ImageIndex := 6;
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

end.


