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

unit PlanParser;

{$MODE Delphi}

{ Firebird's query plan, as a tree.

  The SQL editor has drawn plans as a tree for some time, but only ones laid
  out in lines and indented - the "explained" plan Firebird 3 added. IBX asks
  for isc_info_sql_get_plan, which is the older form: one line of nested
  parentheses,

    PLAN SORT (JOIN (CUSTOMERS NATURAL, ORDERS INDEX (FK_ORD_CUST)))

  and the line-and-indent reader makes exactly one node of that. So on every
  server IBX talks to, the plan tab has been a picture of a single box with the
  whole plan written inside it - which is the text, drawn.

  This parses the nested form properly. It is a small recursive descent over a
  small grammar:

    plan     := [PLAN] expr
    expr     := op '(' expr [, expr]* ')' | '(' expr [, expr]* ')' | item
    op       := JOIN | SORT | MERGE | HASH
    item     := name [access]
    access   := NATURAL | INDEX '(' name [, name]* ')' | ORDER name [INDEX ...]

  Tolerance matters more than strictness here. A plan comes from the server, so
  it is not the user's mistake if something in it is unrecognised, and a plan
  tab that says nothing because one token was unexpected is worse than one that
  shows the shape and leaves a leaf reading oddly. Anything that does not parse
  becomes a leaf holding the text. }

interface

uses SysUtils, Classes;

type
  TPlanNodeKind = (pnRoot, pnJoin, pnSort, pnMerge, pnHash, pnTable, pnText);

  TPlanNode = class
  private
    FChildren: TList;
    function GetChild(Index: Integer): TPlanNode;
  public
    Kind: TPlanNodeKind;
    { What the node shows. For a table that is its name; for an operation, the
      operation. }
    Caption: String;
    { How the table is read - 'NATURAL', 'INDEX (PK_X)' - kept apart from the
      name so a caller can show it differently, and so "is this a full scan"
      is a question about a field rather than about a string. }
    Access: String;
    constructor Create(AKind: TPlanNodeKind; const ACaption: String);
    destructor Destroy; override;
    function AddChild(AKind: TPlanNodeKind; const ACaption: String): TPlanNode;
    function ChildCount: Integer;
    property Children[Index: Integer]: TPlanNode read GetChild; default;
    { The whole subtree, counting this node. }
    function TotalNodes: Integer;
  end;

{ Parses a plan. Never returns nil and never raises: an empty plan gives a root
  with no children. The caller owns the result. }
function ParsePlan(const APlanText: String): TPlanNode;

{ True when the text looks like the indented, line-per-step plan Firebird 3
  produces rather than the older parenthesised one. The two need different
  readers, and which one arrives depends on how the caller asked. }
function IsExplainedPlan(const APlanText: String): Boolean;

{ True when this node reads a table without an index - the thing worth
  noticing in a plan. }
function IsNaturalScan(ANode: TPlanNode): Boolean;

implementation

constructor TPlanNode.Create(AKind: TPlanNodeKind; const ACaption: String);
begin
  inherited Create;
  Kind := AKind;
  Caption := ACaption;
  FChildren := TList.Create;
end;

destructor TPlanNode.Destroy;
var
  Idx: Integer;
begin
  for Idx := 0 to FChildren.Count - 1 do
    TPlanNode(FChildren[Idx]).Free;
  FChildren.Free;
  inherited Destroy;
end;

function TPlanNode.GetChild(Index: Integer): TPlanNode;
begin
  Result := TPlanNode(FChildren[Index]);
end;

function TPlanNode.ChildCount: Integer;
begin
  Result := FChildren.Count;
end;

function TPlanNode.AddChild(AKind: TPlanNodeKind;
  const ACaption: String): TPlanNode;
begin
  Result := TPlanNode.Create(AKind, ACaption);
  FChildren.Add(Result);
end;

function TPlanNode.TotalNodes: Integer;
var
  Idx: Integer;
begin
  Result := 1;
  for Idx := 0 to FChildren.Count - 1 do
    Result := Result + TPlanNode(FChildren[Idx]).TotalNodes;
end;

function IsExplainedPlan(const APlanText: String): Boolean;
var
  Lines: TStringList;
  Idx: Integer;
begin
  Result := False;
  { The explained plan is several lines and indents its steps; the old one is
    one line of parentheses. A one-line explained plan would be a plan with a
    single step, which reads the same either way. }
  if Pos('->', APlanText) > 0 then
    Exit(True);
  Lines := TStringList.Create;
  try
    Lines.Text := APlanText;
    for Idx := 0 to Lines.Count - 1 do
      if (Length(Lines[Idx]) > 0) and (Lines[Idx][1] = ' ') and
         (Trim(Lines[Idx]) <> '') then
        Exit(True);
  finally
    Lines.Free;
  end;
end;

function IsNaturalScan(ANode: TPlanNode): Boolean;
begin
  Result := Assigned(ANode) and (ANode.Kind = pnTable) and
    (Pos('NATURAL', AnsiUpperCase(ANode.Access)) > 0);
end;

type
  { A cursor over the plan text. Small enough to keep here rather than make a
    class of its own. }
  TPlanScanner = record
    Text: String;
    Pos_: Integer;
  end;

procedure SkipSpace(var S: TPlanScanner);
begin
  while (S.Pos_ <= Length(S.Text)) and (S.Text[S.Pos_] in [' ', #9, #13, #10]) do
    Inc(S.Pos_);
end;

function PeekChar(var S: TPlanScanner): Char;
begin
  SkipSpace(S);
  if S.Pos_ <= Length(S.Text) then
    Result := S.Text[S.Pos_]
  else
    Result := #0;
end;

{ The next bare word, or '' at a punctuation mark or the end. Quoted names come
  back with their quotes, since that is how they must be shown. }
function NextWord(var S: TPlanScanner): String;
var
  Start: Integer;
begin
  Result := '';
  SkipSpace(S);
  if S.Pos_ > Length(S.Text) then
    Exit;
  if S.Text[S.Pos_] = '"' then
  begin
    Start := S.Pos_;
    Inc(S.Pos_);
    while (S.Pos_ <= Length(S.Text)) and (S.Text[S.Pos_] <> '"') do
      Inc(S.Pos_);
    if S.Pos_ <= Length(S.Text) then
      Inc(S.Pos_);
    Exit(Copy(S.Text, Start, S.Pos_ - Start));
  end;
  if S.Text[S.Pos_] in ['(', ')', ','] then
    Exit;
  Start := S.Pos_;
  while (S.Pos_ <= Length(S.Text)) and
        not (S.Text[S.Pos_] in [' ', #9, #13, #10, '(', ')', ',']) do
    Inc(S.Pos_);
  Result := Copy(S.Text, Start, S.Pos_ - Start);
end;

function PeekWord(var S: TPlanScanner): String;
var
  Save: Integer;
begin
  Save := S.Pos_;
  Result := NextWord(S);
  S.Pos_ := Save;
end;

function KindOfWord(const AWord: String): TPlanNodeKind;
var
  W: String;
begin
  W := AnsiUpperCase(AWord);
  if W = 'JOIN' then
    Result := pnJoin
  else if W = 'SORT' then
    Result := pnSort
  else if W = 'MERGE' then
    Result := pnMerge
  else if W = 'HASH' then
    Result := pnHash
  else
    Result := pnTable;
end;

procedure ParseExpr(var S: TPlanScanner; AParent: TPlanNode); forward;

{ One item inside a bracketed list: either a nested expression or a table with
  how it is read. }
procedure ParseItem(var S: TPlanScanner; AParent: TPlanNode);
var
  Word_, Access: String;
  Node: TPlanNode;
  Ch: Char;
  Depth: Integer;
begin
  SkipSpace(S);
  Ch := PeekChar(S);
  if (Ch = '(') or (KindOfWord(PeekWord(S)) <> pnTable) then
  begin
    ParseExpr(S, AParent);
    Exit;
  end;

  Word_ := NextWord(S);
  if Word_ = '' then
    Exit;
  Node := AParent.AddChild(pnTable, Word_);

  { Everything up to the next comma or the closing bracket describes how the
    table is read. Brackets are counted so INDEX (A, B) is not mistaken for the
    end of the item. }
  Access := '';
  Depth := 0;
  while S.Pos_ <= Length(S.Text) do
  begin
    Ch := S.Text[S.Pos_];
    if (Depth = 0) and ((Ch = ',') or (Ch = ')')) then
      Break;
    if Ch = '(' then
      Inc(Depth)
    else if Ch = ')' then
      Dec(Depth);
    Access := Access + Ch;
    Inc(S.Pos_);
  end;
  Node.Access := Trim(Access);
end;

procedure ParseExpr(var S: TPlanScanner; AParent: TPlanNode);
var
  Word_: String;
  Kind: TPlanNodeKind;
  Node: TPlanNode;
  Ch: Char;
begin
  SkipSpace(S);
  Ch := PeekChar(S);

  if Ch = '(' then
  begin
    { A bare bracketed list. It groups without naming an operation, so it adds
      no node of its own - one box saying "(" would be noise. }
    Inc(S.Pos_);
    repeat
      ParseItem(S, AParent);
      SkipSpace(S);
      if PeekChar(S) = ',' then
        Inc(S.Pos_)
      else
        Break;
    until False;
    if PeekChar(S) = ')' then
      Inc(S.Pos_);
    Exit;
  end;

  Word_ := PeekWord(S);
  if Word_ = '' then
    Exit;
  Kind := KindOfWord(Word_);
  if Kind = pnTable then
  begin
    ParseItem(S, AParent);
    Exit;
  end;

  NextWord(S);
  Node := AParent.AddChild(Kind, AnsiUpperCase(Word_));
  SkipSpace(S);
  if PeekChar(S) <> '(' then
    { An operation with nothing bracketed after it. Not something Firebird
      emits, but a node with no children says so better than dropping it. }
    Exit;
  Inc(S.Pos_);
  repeat
    ParseItem(S, Node);
    SkipSpace(S);
    if PeekChar(S) = ',' then
      Inc(S.Pos_)
    else
      Break;
  until False;
  if PeekChar(S) = ')' then
    Inc(S.Pos_);
end;

function ParsePlan(const APlanText: String): TPlanNode;
var
  S: TPlanScanner;
  Text: String;
  Guard: Integer;
begin
  Result := TPlanNode.Create(pnRoot, 'Plan');
  Text := Trim(APlanText);
  if Text = '' then
    Exit;

  S.Text := Text;
  S.Pos_ := 1;

  { A plan may hold several PLAN clauses one after another - one per subquery.
    Each is parsed in turn and hangs off the root as a sibling. }
  Guard := 0;
  while S.Pos_ <= Length(S.Text) do
  begin
    SkipSpace(S);
    if S.Pos_ > Length(S.Text) then
      Break;
    if SameText(PeekWord(S), 'PLAN') then
      NextWord(S);
    ParseExpr(S, Result);
    { Nothing consumed means something unrecognised is in the way. Rather than
      loop forever, take the rest as text: a plan tab showing the shape and one
      odd leaf beats one showing nothing. }
    Inc(Guard);
    if Guard > 512 then
    begin
      Result.AddChild(pnText, Trim(Copy(S.Text, S.Pos_, MaxInt)));
      Break;
    end;
    SkipSpace(S);
    if (S.Pos_ <= Length(S.Text)) and (S.Text[S.Pos_] = ',') then
      Inc(S.Pos_);
  end;
end;

end.
