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
// $Id: QBuilder.pas,v 1.5 2006/10/22 06:04:28 rjmills Exp $

unit QBuilder;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Buttons, ExtCtrls, StdCtrls, ComCtrls, ToolWin, Menus, CheckLst, Grids,
	DB, DBTables, DBGrids, ExtDlgs,
	QBCriteria,
	QBAppendTo,
	SynEdit,
	SyntaxMemoWithStuff2;

type
  TQBForm = class;

  TOnGetTableColumnsEvent = procedure(Sender : TObject; TableName : String; ConnectionName : String; List : TCheckListBox) of object;
  TOnGetTablesEvent = procedure(Sender : TObject; SysTables : Boolean; ConnectionName : String; List : TListBox) of object;

  TQBuilderDialog = class(TComponent)
  private
    FOnGetTableColumns : TOnGetTableColumnsEvent;
    FOnGetTables : TOnGetTablesEvent;
    FSystemTables : boolean;
    FQBForm : TQBForm;
    FSQL : TStrings;
  public
    constructor Create(AOwner : TComponent); override;
    destructor Destroy; override;
    function Execute : Boolean; virtual;
    property SQL : TStrings read FSQL;
  published
    property SystemTables : boolean read FSystemTables write FSystemTables default false;
    property OnGetTableColumns : TOnGetTableColumnsEvent read FOnGetTableColumns write FOnGetTableColumns;
    property OnGetTables : TOnGetTablesEvent read FOnGetTables write FOnGetTables;
  end;

  TArr = array[0..0] of integer;
  PArr = ^TArr;

	TQBLbx = class(TCheckListBox)
	private
		FArrBold : PArr;
		FLoading : boolean;
		procedure CNDrawItem(var Message : TWMDrawItem); message CN_DrawItem;
		procedure WMLButtonDown(var Message : TWMLButtonDblClk); message WM_LButtonDown;
		function GetCheckW : Integer;
		procedure AllocArrBold;
		procedure SelectItemBold(Item : integer);
    procedure UnSelectItemBold(Item : integer);
    function GetItemY(Item : integer) : integer;
  protected
		procedure DrawItem(Index : Integer; Rect : TRect; State : TOwnerDrawState); override;
		procedure ClickCheck; override;
  public
    constructor Create(AOwner : TComponent); override;
    destructor Destroy; override;
  end;

  TQBTable = class(TPanel)
  private
    ScreenDC : HDC;
    OldX,
      OldY,
      OldLeft,
      OldTop : Integer;
    ClipRgn : HRGN;
    ClipRect,
      MoveRect : TRect;
    Moving : Boolean;
    FCloseBtn,
      FUnlinkBtn : TSpeedButton;
    FLbx : TQBLbx;
    FTableName : string;
    FOnGetTableColumns : TOnGetTableColumnsEvent;
    function Activate(OrigName : String; ATableName : string; X, Y : Integer) : boolean;
    function GetRowY(FldN : integer) : integer;
    procedure _CloseBtn(Sender : TObject);
		procedure _UnlinkBtn(Sender : TObject);
		procedure _DragOver(Sender, Source : TObject; X, Y : Integer; State : TDragState; var Accept : Boolean);
		procedure _DragDrop(Sender, Source : TObject; X, Y : Integer);
	protected
    procedure Paint; override;
		procedure SetParent(AParent : TWinControl); override;
		procedure MouseDown(Button : TMouseButton; Shift : TShiftState; X, Y : Integer); override;
		procedure MouseMove(Shift : TShiftState; X, Y : Integer); override;
		procedure MouseUp(Button : TMouseButton; Shift : TShiftState; X, Y : Integer); override;
		property Align;
	public
		constructor Create(AOwner : TComponent); override;
		destructor Destroy; override;
		property OnGetTableColumns : TOnGetTableColumnsEvent read FOnGetTableColumns write FOnGetTableColumns;
	end;

	TQBLink = class(TShape)
	private
		Tbl1,
			Tbl2 : TQBTable;
		FldN1,
			FldN2 : integer;
		FldNam1,
			FldNam2 : string;
		FLinkOpt,
			FLinkType : integer;
		LnkX,
			LnkY : byte;
		Rgn : HRgn;
		PopMenu : TPopupMenu;
		procedure _Click(X, Y : integer);
		procedure CMHitTest(var Message : TCMHitTest); message CM_HitTest;
		function ControlAtPos(const Pos : TPoint) : TControl;
  protected
		procedure Paint; override;
		procedure WndProc(var Message : TMessage); override;
	public
		constructor Create(AOwner : TComponent); override;
		destructor Destroy; override;
	end;

  TQBArea = class(TScrollBox)
  private
    procedure SetOptions(Sender : TObject);
    procedure InsertTable(X, Y : Integer);
    function InsertLink(_tbl1, _tbl2 : TQBTable; _fldN1, _fldN2 : Integer) : TQBLink;
    function FindTable(TableName : string) : TQBTable;
    function FindLink(Link : TQBLink) : boolean;
    function FindOtherLink(Link : TQBLink; Tbl : TQBTable; FldN : integer) : boolean;
    procedure ReboundLink(Link : TQBLink);
    procedure ReboundLinks4Table(ATable : TQBTable);
    procedure Unlink(Sender : TObject);
		procedure UnlinkTable(ATable : TQBTable);
		procedure _DragOver(Sender, Source : TObject; X, Y : Integer;	State : TDragState; var Accept : Boolean);
		procedure _DragDrop(Sender, Source : TObject; X, Y : Integer);
  protected
    procedure CreateParams(var Params : TCreateParams); override;
	end;

	TQBGrid = class(TStringGrid)
	private
		FButton : TSpeedButton;
		CurrCol : integer;
		IsEmpty : boolean;
		FCriteria : TfrmCriteria;
		FAppendTo : TfrmAppendTo;
		function MaxSW(s1, s2 : string) : integer;
		procedure InsertDefault(aCol : integer);
		procedure Insert(aCol : integer; aField, aTable : string);
		function FindColumn(sCol : string) : integer;
		function FindSameColumn(aCol : integer) : boolean;
		procedure RemoveColumn(aCol : integer);
		procedure RemoveColumn4Tbl(Tbl : string);
		procedure ClickCell(X, Y : integer; LeftButton : Boolean);
		procedure _DragOver(Sender, Source : TObject; X, Y : integer; State : TDragState; var Accept : boolean);
		procedure _DragDrop(Sender, Source : TObject; X, Y : integer);
		procedure ButtonClick(Sender : TObject);
  protected
		procedure CreateParams(var Params : TCreateParams); override;
		procedure WndProc(var Message : TMessage); override;
		function SelectCell(ACol, ARow : integer) : boolean; override;
		procedure DoExit; override;
		procedure TopLeftChanged; override;
		procedure ColumnMoved(FromIndex, ToIndex: Longint); override;
		procedure ColWidthsChanged; Override;
		procedure KeyDown(var Key: Word; Shift: TShiftState); override;
		constructor Create(AOwner : TComponent); override;
		destructor Destroy; override;
	end;

	TQBForm = class(TForm)
		ButtonsPanel : TPanel;
		QBPanel : TPanel;
		Pages : TPageControl;
		TabColumns : TTabSheet;
		QBTables : TListBox;
		VSplitter : TSplitter;
		mnuTbl : TPopupMenu;
		Remove1 : TMenuItem;
		mnuFunc : TPopupMenu;
		Nofunction1 : TMenuItem;
		N1 : TMenuItem;
		Average1 : TMenuItem;
		Count1 : TMenuItem;
		Minimum1 : TMenuItem;
		Maximum1 : TMenuItem;
		Sum1 : TMenuItem;
		mnuSort : TPopupMenu;
		Sort1 : TMenuItem;
		N2 : TMenuItem;
		Ascending1 : TMenuItem;
		Descending1 : TMenuItem;
		mnuShow : TPopupMenu;
		Show1 : TMenuItem;
		btnInsert: TButton;
		Button2 : TButton;
		HSplitter : TSplitter;
		TabSQL : TTabSheet;
		btnHelp: TButton;
		pnlToolbar: TPanel;
		btnNew: TSpeedButton;
		btnGenSQL: TSpeedButton;
		mnuCriteria: TPopupMenu;
		Clear1: TMenuItem;
		N3: TMenuItem;
		EditCriteria1: TMenuItem;
		Bevel1: TBevel;
		cmbQueryType: TComboBox;
		Label1: TLabel;
		pnlExtraQueryData: TPanel;
		pnlGridParent: TPanel;
		lblQueryPrompt: TLabel;
		cmbQueryTable: TComboBox;
		mnuUpdateTo: TPopupMenu;
		Clear2: TMenuItem;
		N4: TMenuItem;
		Edit1: TMenuItem;
		mnuAppendTo: TPopupMenu;
		Clear3: TMenuItem;
		N5: TMenuItem;
		Edit2: TMenuItem;
		memoSQL: TSyntaxMemoWithStuff2;
		procedure mnuFunctionClick(Sender : TObject);
		procedure mnuRemoveClick(Sender : TObject);
		procedure mnuShowClick(Sender : TObject);
		procedure mnuSortClick(Sender : TObject);
		procedure btnNewClick(Sender : TObject);
		procedure btnTablesClick(Sender : TObject);
		procedure btnPagesClick(Sender : TObject);
		procedure btnSQLClick(Sender : TObject);
		procedure FormCreate(Sender: TObject);
		procedure cmbQueryTypeChange(Sender: TObject);
		procedure Clear1Click(Sender: TObject);
		procedure Clear2Click(Sender: TObject);
		procedure EditCriteria1Click(Sender: TObject);
		procedure Edit1Click(Sender: TObject);
		procedure Clear3Click(Sender: TObject);
		procedure Edit2Click(Sender: TObject);
		procedure FormKeyDown(Sender: TObject; var Key: Word;	Shift: TShiftState);
		procedure btnHelpClick(Sender: TObject);
	private
		FOnGetTables : TOnGetTablesEvent;
		CurrentQueryType : Integer;
		procedure FillTableNames;
	protected
		QBDialog : TQBuilderDialog;
		QBArea : TQBArea;
		QBGrid : TQBGrid;
		procedure CreateParams(var Params : TCreateParams); override;
		procedure ClearAll;
		procedure OpenDatabase(aSysTables : boolean);
	public
		property OnGetTables : TOnGetTablesEvent read FOnGetTables write FOnGetTables;
	end;

implementation

{$R *.DFM}
{$R QBBUTTON.RES}

uses
	Globals,
	HelpMap,
	//MarathonMain,
	QBLnkFrm;

resourcestring
	sMainCaption = 'QBuilder';
	sDBNameIsEmpty = 'Database name is missing.';
	sNotValidTableParent = 'Parent must be TScrollBox or its descendant.';

const
	cRow1 = 0;
  cRow2 = 1;
  cRow3 = 2;
  cRow4 = 3;
  cRow5 = 4;
  cRow6 = 5;

	sShow = 'Show';
	sSort : array[1..3] of string =
		('',
		'Asc',
		'Desc');
	sAggr : array[1..6] of string =
		('Group By',
		'Avg',
		'Count',
		'Max',
		'Min',
		'Sum');

	sLinkOpt : array[0..5] of string =
		('=',
		'<',
		'>',
		'=<',
		'=>',
		'<>');

	sOuterJoin : array[1..3] of string =
		(' LEFT OUTER JOIN ',
		' RIGHT OUTER JOIN ',
		' FULL OUTER JOIN ');

	Hand = 15;
	Hand2 = 12;

	QBSignature = '# QBuilder';

{ TQueryBuilderDialog}

constructor TQBuilderDialog.Create(AOwner : TComponent);
begin
  inherited Create(AOwner);
  FSystemTables := False;
  FSQL := TStringList.Create;
end;

destructor TQBuilderDialog.Destroy;
begin
  if FSQL <> nil then FSQL.Free;
  inherited Destroy;
end;

function TQBuilderDialog.Execute : Boolean;
begin
	Result := false;
	if not Assigned(FQBForm) then
	begin
		FQBForm := TQBForm.Create(Application);
		FQBForm.QBDialog := Self;
		FQBForm.OnGetTables := OnGetTables;
		FQBForm.OpenDatabase(FSystemTables);
		if FQBForm.ShowModal = mrOk then
		begin
			FSQL.Assign(FQBForm.MemoSQL.Lines);
			Result := true;
		end;
		FQBForm.Free;
		FQBForm := nil;
	end;
end;

{ TQBLbx }

constructor TQBLbx.Create(AOwner : TComponent);
begin
	inherited Create(AOwner);
	Style := lbOwnerDrawFixed;
  ParentFont := false;
  Font.Style := [];
  Font.Size := 8;
  FArrBold := nil;
  FLoading := false;
end;

destructor TQBLbx.Destroy;
begin
  if FArrBold <> nil then FreeMem(FArrBold);
  inherited;
end;

function TQBLbx.GetCheckW : Integer;
begin
	Result := GetCheckWidth;
end;

procedure TQBLbx.CNDrawItem(var Message : TWMDrawItem);
var
	State : TOwnerDrawState;
begin
	with Message.DrawItemStruct^ do
	begin
		rcItem.Left := rcItem.Left + GetCheckWidth; //*** check
//    State := TOwnerDrawState(WordRec(LongRec(itemState).Lo).Lo);
		Canvas.Font := Font;
		Canvas.Brush := Brush;
		if (Integer(itemID) >= 0) and (Integer(itemID) <= Items.Count - 1) then
		begin
{$R-}
			if (FArrBold <> nil) then
				if FArrBold^[Integer(itemID)] = 1 then
					Canvas.Font.Style := [fsBold];
			DrawItem(itemID, rcItem, State);
			if (FArrBold <> nil) then
        if FArrBold^[Integer(itemID)] = 1 then
          Canvas.Font.Style := [];
{$R+}
    end
    else
      Canvas.FillRect(rcItem);
  end;
end;

procedure TQBLbx.DrawItem(Index : Integer; Rect : TRect; State : TOwnerDrawState);
begin
  inherited;
  if (odFocused in State) then
    Canvas.DrawFocusRect(Rect);
end;

procedure TQBLbx.WMLButtonDown(var Message : TWMLButtonDblClk);
begin
  inherited;
  BeginDrag(false);
end;

procedure TQBLbx.ClickCheck;
var
  iCol : integer;
begin
  inherited;
  if FLoading then
    Exit;
  if Checked[ItemIndex] then
  begin
    TQBForm(GetParentForm(Self)).QBGrid.Insert(
      TQBForm(GetParentForm(Self)).QBGrid.ColCount,
      Items[ItemIndex], TQBTable(Parent).FTableName);
  end
  else
  begin
    iCol := TQBForm(GetParentForm(Self)).QBGrid.FindColumn(Items[ItemIndex]);
		while iCol <> -1 do
    begin
      TQBForm(GetParentForm(Self)).QBGrid.RemoveColumn(iCol);
      iCol := TQBForm(GetParentForm(Self)).QBGrid.FindColumn(Items[ItemIndex]);
    end;
  end;
  TQBForm(GetParentForm(Self)).QBGrid.Refresh; // StringGrid bug
end;

procedure TQBLbx.AllocArrBold;
begin
  FArrBold := AllocMem(Items.Count * SizeOf(integer));
end;

procedure TQBLbx.SelectItemBold(Item : integer);
begin
  if FArrBold <> nil then
  begin
{$R-}
    if FArrBold[Item] = 0 then
      FArrBold^[Item] := 1;
{$R+}
  end;
end;

procedure TQBLbx.UnSelectItemBold(Item : integer);
begin
  if FArrBold <> nil then
  begin
{$R-}
    if FArrBold[Item] = 1 then
      FArrBold^[Item] := 0;
{$R+}
  end;
end;

function TQBLbx.GetItemY(Item : integer) : integer;
begin
  Result := Item * ItemHeight + ItemHeight div 2 + 1;
end;

{ TQBTable }

constructor TQBTable.Create(AOwner : TComponent);
begin
  inherited Create(AOwner);
  Visible := false;
  ShowHint := True;
  BevelInner := bvRaised;
  BevelOuter := bvRaised;
  BorderWidth := 1;
  FCloseBtn := TSpeedButton.Create(Self);
  FCloseBtn.Parent := Self;
  FCloseBtn.Hint := 'Close';
  FUnlinkBtn := TSpeedButton.Create(Self);
  FUnlinkBtn.Parent := Self;
  FUnlinkBtn.Hint := 'Unlink';

  FLbx := TQBLbx.Create(Self);
  FLbx.Parent := Self;
  FLbx.Style := lbOwnerDrawFixed;
  FLbx.Align := alBottom;
  FLbx.TabStop := false;
  FLbx.Visible := false;
end;

destructor TQBTable.Destroy;
begin
  inherited Destroy;
end;

procedure TQBTable.Paint;
begin
  inherited Paint;
  Canvas.TextOut(4, 4, FTableName);
end;

function TQBTable.GetRowY(FldN : integer) : integer;
var
  pnt : TPoint;
begin
  pnt.X := FLbx.Left;
  pnt.Y := FLbx.Top + FLbx.GetItemY(FldN);
  pnt := Parent.ScreenToClient(ClientToScreen(pnt));
  Result := pnt.Y;
end;

function TQBTable.Activate(OrigName : String; ATableName : string; X, Y : Integer) : boolean;
var
  i : integer;
  W, W1 : integer;

begin
  Top := Y;
  Left := X;
  Font.Style := [fsBold];
  Font.Size := 8;
  Canvas.Font := Font;
  Hint := ATableName;
  FTableName := ATableName;

  if Assigned(FOnGetTableColumns) then
    FOnGetTableColumns(Self, OrigName, '', FLbx);

  FLbx.AllocArrBold;
  FLbx.ParentFont := false;
  FLbx.TabStop := false;
  FLbx.Height := FLbx.ItemHeight * FLbx.Items.Count + 4;

  Height := FLbx.Height + 22;
  W := 110;
	for i := 0 to FLbx.Items.Count - 1 do
  begin
    W1 := Canvas.TextWidth(FLbx.Items[i]);
    if W < W1 then
      W := W1;
  end;
	Width := W + 20 + FLbx.GetCheckW; //*** check
  if Canvas.TextWidth(ATableName) > Width - 34 then
    Width := Canvas.TextWidth(ATableName) + 34;

  FLbx.Visible := true;
  FLbx.OnDragOver := _DragOver;
  FLbx.OnDragDrop := _DragDrop;
  FCloseBtn.Top := 4;
  FCloseBtn.Left := Self.ClientWidth - 16;
  FCloseBtn.Width := 12;
  FCloseBtn.Height := 12;
  FCloseBtn.Glyph.LoadFromResourceName(HInstance, 'CLOSEBMP');

	FCloseBtn.Margin := -1;
	FCloseBtn.Spacing := 0;
	FCloseBtn.OnClick := _CloseBtn;
	FCloseBtn.Visible := true;
	FUnlinkBtn.Top := 4;
	FUnlinkBtn.Left := Self.ClientWidth - 16 - FCloseBtn.Width;
	FUnlinkBtn.Width := 12;
	FUnlinkBtn.Height := 12;
	FUnlinkBtn.Glyph.LoadFromResourceName(HInstance, 'UNLINKBMP');

	FUnlinkBtn.Margin := -1;
	FUnlinkBtn.Spacing := 0;
	FUnlinkBtn.OnClick := _UnlinkBtn;
	FUnlinkBtn.Visible := true;
	Visible := true;
	Result := True;
end;

procedure TQBTable._CloseBtn(Sender : TObject);
begin
	TQBArea(Parent).UnlinkTable(Self);
  TQBForm(GetParentForm(Self)).QBGrid.RemoveColumn4Tbl(FTableName);
  Parent.RemoveControl(Self);
  Free;
end;

procedure TQBTable._UnlinkBtn(Sender : TObject);
begin
  TQBArea(Parent).UnlinkTable(Self);
end;

procedure TQBTable._DragOver(Sender, Source : TObject; X, Y : Integer;
  State : TDragState; var Accept : Boolean);
begin
  if (Source is TCustomListBox)
    and
    (TWinControl(Source).Parent is TQBTable)
    then
    Accept := true;
end;

procedure TQBTable._DragDrop(Sender, Source : TObject; X, Y : Integer);
var
  nRow : integer;
  hRow : integer;
begin
  if (Source is TCustomListBox) then
  begin
    if (TWinControl(Source).Parent is TQBTable) then
		begin
      hRow := FLbx.ItemHeight;
      if hRow <> 0 then
        nRow := Y div hRow
      else
        nRow := 0;
      if nRow > FLbx.Items.Count - 1 then
        nRow := FLbx.Items.Count - 1;
      if Source <> FLbx then
        TQBArea(Parent).InsertLink(
          TQBTable(TWinControl(Source).Parent), Self,
          TQBTable(TWinControl(Source).Parent).FLbx.ItemIndex, nRow)
      else
      begin
        if nRow <> FLbx.ItemIndex then
          TQBArea(Parent).InsertLink(Self, Self, FLbx.ItemIndex, nRow);
      end;
    end
    else if Source = TQBForm(GetParentForm(Self)).QBTables then
    begin
      X := X + Left + TWinControl(Sender).Left;
      Y := Y + Top + TWinControl(Sender).Top;
      TQBArea(Parent).InsertTable(X, Y);
    end;
  end
end;

procedure TQBTable.SetParent(AParent : TWinControl);
begin
  if (AParent <> nil) and (not (AParent is TScrollBox)) then
    raise Exception.Create(sNotValidTableParent);
  inherited SetParent(AParent);
end;

procedure TQBTable.MouseDown(Button : TMouseButton; Shift : TShiftState; X, Y : Integer);
begin
  inherited MouseDown(Button, Shift, X, Y);
  BringToFront;
  if (Button = mbLeft) then
	begin
    SetCapture(Self.Handle);
    ScreenDC := GetDC(0);

    ClipRect := Bounds(Parent.Left, Parent.Top, Parent.Width, Parent.Height);
    ClipRect.TopLeft := Parent.Parent.ClientToScreen(ClipRect.TopLeft);
    ClipRect.BottomRight := Parent.Parent.ClientToScreen(ClipRect.BottomRight);
    ClipRgn := CreateRectRgn(ClipRect.Left, ClipRect.Top, ClipRect.Right, ClipRect.Bottom);
    SelectClipRgn(ScreenDC, ClipRgn);
    ClipCursor(@ClipRect);
    OldX := X;
    OldY := Y;
    OldLeft := X;
    OldTop := Y;
    MoveRect := Rect(Self.Left, Self.Top, Self.Left + Self.Width, Self.Top + Self.Height);
    MoveRect.TopLeft := Parent.ClientToScreen(MoveRect.TopLeft);
    MoveRect.BottomRight := Parent.ClientToScreen(MoveRect.BottomRight);
    DrawFocusRect(ScreenDC, MoveRect);
    Moving := True;
  end;
end;

procedure TQBTable.MouseMove(Shift : TShiftState; X, Y : Integer);
begin
  inherited MouseMove(Shift, X, Y);
  if Moving then
  begin
    DrawFocusRect(ScreenDC, MoveRect);
    OldX := X;
    OldY := Y;
    MoveRect := Rect(Self.Left + OldX - OldLeft, Self.Top + OldY - OldTop,
      Self.Left + Self.Width + OldX - OldLeft, Self.Top + Self.Height + OldY - OldTop);
    MoveRect.TopLeft := Parent.ClientToScreen(MoveRect.TopLeft);
    MoveRect.BottomRight := Parent.ClientToScreen(MoveRect.BottomRight);
    DrawFocusRect(ScreenDC, MoveRect);
  end;
end;

procedure TQBTable.MouseUp(Button : TMouseButton; Shift : TShiftState; X, Y : Integer);
begin
  inherited MouseUp(Button, Shift, X, Y);
  if Button = mbLeft then
  begin
    ReleaseCapture;
    DrawFocusRect(ScreenDC, MoveRect);
    begin
      if (Self.Left <> Self.Left + X + OldLeft)
        or
        (Self.Top <> Self.Top + Y - OldTop)
        then
      begin
        Self.Visible := False;
        Self.Left := Self.Left + X - OldLeft;
        Self.Top := Self.Top + Y - OldTop;
        Self.Visible := True;
      end
    end;
    ClipRect := Rect(0, 0, Screen.Width, Screen.Height);
    ClipCursor(@ClipRect);
    DeleteObject(ClipRgn);
    ReleaseDC(0, ScreenDC);
    Moving := False;
  end;
  TQBArea(Parent).ReboundLinks4Table(Self);
end;

{ TQBLink }

constructor TQBLink.Create(AOwner : TComponent);
var
  mnuArr : array[1..4] of TMenuItem;
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csReplicatable];
  Width := 105;
  Height := 105;
  Rgn := CreateRectRgn(0, 0, Hand, Hand);
  mnuArr[1] := NewItem('', 0, false, false, nil, 0, 'mnuLinkName');
	mnuArr[2] := NewLine;
  mnuArr[3] := NewItem('Link options', 0, false, true, TQBArea(AOwner).SetOptions, 0, 'mnuOptions');
  mnuArr[4] := NewItem('Unlink', 0, false, true, TQBArea(AOwner).Unlink, 0, 'mnuUnlink');
  PopMenu := NewPopupMenu(Self, 'mnu', paLeft, false, mnuArr);
  PopMenu.PopupComponent := Self;
end;

destructor TQBLink.Destroy;
begin
  DeleteObject(Rgn);
  inherited Destroy;
end;

procedure TQBLink.Paint;
var
  X1, X2,
    Y1, Y2 : integer;
  ArrRgn,
    pntArray : array[1..4] of TPoint;
  ArrCnt : integer;
  r : TRect;
begin
  if tbl1 <> tbl2 then
  begin
    if ((LnkX = 1) and (LnkY = 1))
      or
      ((LnkX = 4) and (LnkY = 2))
      then
    begin
      pntArray[1].X := 0;
      pntArray[1].Y := Hand div 2;
      pntArray[2].X := Hand;
      pntArray[2].Y := Hand div 2;
      pntArray[3].X := Width - Hand;
      pntArray[3].Y := Height - Hand div 2;
      pntArray[4].X := Width;
      pntArray[4].Y := Height - Hand div 2;
      ArrRgn[1].X := pntArray[2].X + 5;
      ArrRgn[1].Y := pntArray[2].Y - 5;
			ArrRgn[2].X := pntArray[2].X - 5;
      ArrRgn[2].Y := pntArray[2].Y + 5;
      ArrRgn[3].X := pntArray[3].X - 5;
      ArrRgn[3].Y := pntArray[3].Y + 5;
      ArrRgn[4].X := pntArray[3].X + 5;
      ArrRgn[4].Y := pntArray[3].Y - 5;
    end;
    if Width > Hand + Hand2 then
    begin
      if ((LnkX = 2) and (LnkY = 1))
        or
        ((LnkX = 3) and (LnkY = 2))
        then
      begin
        pntArray[1].X := 0;
        pntArray[1].Y := Hand div 2;
        pntArray[2].X := Hand;
        pntArray[2].Y := Hand div 2;
        pntArray[3].X := Width - 5;
        pntArray[3].Y := Height - Hand div 2;
        pntArray[4].X := Width - Hand;
        pntArray[4].Y := Height - Hand div 2;
        ArrRgn[1].X := pntArray[2].X + 5;
        ArrRgn[1].Y := pntArray[2].Y - 5;
        ArrRgn[2].X := pntArray[2].X - 5;
        ArrRgn[2].Y := pntArray[2].Y + 5;
        ArrRgn[3].X := pntArray[3].X - 5;
        ArrRgn[3].Y := pntArray[3].Y + 5;
        ArrRgn[4].X := pntArray[3].X + 5;
        ArrRgn[4].Y := pntArray[3].Y - 5;
      end;
      if ((LnkX = 3) and (LnkY = 1))
        or
        ((LnkX = 2) and (LnkY = 2))
        then
      begin
        pntArray[1].X := Width - Hand;
        pntArray[1].Y := Hand div 2;
        pntArray[2].X := Width - 5;
				pntArray[2].Y := Hand div 2;
        pntArray[3].X := Hand;
        pntArray[3].Y := Height - Hand div 2;
        pntArray[4].X := 0;
        pntArray[4].Y := Height - Hand div 2;
        ArrRgn[1].X := pntArray[2].X - 5;
        ArrRgn[1].Y := pntArray[2].Y - 5;
        ArrRgn[2].X := pntArray[2].X + 5;
        ArrRgn[2].Y := pntArray[2].Y + 5;
        ArrRgn[3].X := pntArray[3].X + 5;
        ArrRgn[3].Y := pntArray[3].Y + 5;
        ArrRgn[4].X := pntArray[3].X - 5;
        ArrRgn[4].Y := pntArray[3].Y - 5;
      end;
    end
    else
    begin
      if ((LnkX = 2) and (LnkY = 1))
        or
        ((LnkX = 3) and (LnkY = 2))
        or
        ((LnkX = 3) and (LnkY = 1))
        or
        ((LnkX = 2) and (LnkY = 2))
        then
      begin
        pntArray[1].X := 0;
        pntArray[1].Y := Hand div 2;
        pntArray[2].X := Width - Hand2;
        pntArray[2].Y := Hand div 2;
        pntArray[3].X := Width - Hand2;
        pntArray[3].Y := Height - Hand div 2;
        pntArray[4].X := 0;
        pntArray[4].Y := Height - Hand div 2;
        ArrRgn[1].X := pntArray[2].X - 5;
        ArrRgn[1].Y := pntArray[2].Y - 5;
        ArrRgn[2].X := pntArray[2].X + 5;
        ArrRgn[2].Y := pntArray[2].Y + 5;
        ArrRgn[3].X := pntArray[3].X + 5;
				ArrRgn[3].Y := pntArray[3].Y + 5;
        ArrRgn[4].X := pntArray[3].X - 5;
        ArrRgn[4].Y := pntArray[3].Y - 5;
      end;
    end;
    if ((LnkX = 4) and (LnkY = 1))
      or
      ((LnkX = 1) and (LnkY = 2))
      then
    begin
      pntArray[1].X := Width;
      pntArray[1].Y := Hand div 2;
      pntArray[2].X := Width - Hand;
      pntArray[2].Y := Hand div 2;
      pntArray[3].X := Hand;
      pntArray[3].Y := Height - Hand div 2;
      pntArray[4].X := 0;
      pntArray[4].Y := Height - Hand div 2;
      ArrRgn[1].X := pntArray[2].X - 5;
      ArrRgn[1].Y := pntArray[2].Y - 5;
      ArrRgn[2].X := pntArray[2].X + 5;
      ArrRgn[2].Y := pntArray[2].Y + 5;
      ArrRgn[3].X := pntArray[3].X + 5;
      ArrRgn[3].Y := pntArray[3].Y + 5;
      ArrRgn[4].X := pntArray[3].X - 5;
      ArrRgn[4].Y := pntArray[3].Y - 5;
    end;
  end
  else
  begin
    pntArray[1].X := 0;
    pntArray[1].Y := Hand div 2;
    pntArray[2].X := Hand - 5;
    pntArray[2].Y := Hand div 2;
    pntArray[3].X := Hand - 5;
    pntArray[3].Y := Height - Hand div 2;
    pntArray[4].X := 0;
    pntArray[4].Y := Height - Hand div 2;
    ArrRgn[1].X := pntArray[2].X + 5;
		ArrRgn[1].Y := pntArray[2].Y - 5;
    ArrRgn[2].X := pntArray[2].X - 5;
    ArrRgn[2].Y := pntArray[2].Y + 5;
    ArrRgn[3].X := pntArray[3].X - 5;
    ArrRgn[3].Y := pntArray[3].Y + 5;
    ArrRgn[4].X := pntArray[3].X + 5;
    ArrRgn[4].Y := pntArray[3].Y - 5;
  end;
  Canvas.PolyLine(pntArray);
  Canvas.Brush := Parent.Brush;
  DeleteObject(Rgn);
  ArrCnt := 4;
  Rgn := CreatePolygonRgn(ArrRgn, ArrCnt, ALTERNATE);
end;

procedure TQBLink._Click(X, Y : integer);
var
  pnt : TPoint;
begin
  pnt.X := X;
  pnt.Y := Y;
  pnt := ClientToScreen(pnt);
  PopMenu.Popup(pnt.X, pnt.Y);
end;

procedure TQBLink.CMHitTest(var Message : TCMHitTest);
begin
  if PtInRegion(Rgn, Message.XPos, Message.YPos) then
    Message.Result := 1;
end;

function TQBLink.ControlAtPos(const Pos : TPoint) : TControl;
var
  I : integer;
  scrnP,
    P : TPoint;
begin
  scrnP := ClientToScreen(Pos);
  for I := Parent.ControlCount - 1 downto 0 do
	begin
    Result := Parent.Controls[I];
    if (Result is TQBLink) and (Result <> Self) then
      with Result do
      begin
        P := Result.ScreenToClient(scrnP);
        if Perform(CM_HITTEST, 0, integer(PointToSmallPoint(P))) <> 0 then
          Exit;
      end;
  end;
  Result := nil;
end;

procedure TQBLink.WndProc(var Message : TMessage);
begin
  if (Message.Msg = WM_RBUTTONDOWN) or (Message.Msg = WM_LBUTTONDOWN) then
    if not PtInRegion(Rgn, TWMMouse(Message).XPos, TWMMouse(Message).YPos) then
      ControlAtPos(SmallPointToPoint(TWMMouse(Message).Pos))
    else
      _Click(TWMMouse(Message).XPos, TWMMouse(Message).YPos);
  inherited WndProc(Message);
end;

{ TQBArea }

procedure TQBArea.CreateParams(var Params : TCreateParams);
begin
  inherited;
  OnDragOver := _DragOver;
  OnDragDrop := _DragDrop;
end;

procedure TQBArea.SetOptions(Sender : TObject);
var
  AForm : TQBLinkForm;
  ALink : TQBLink;
begin
  if TPopupMenu(Sender).Owner is TQBLink then
  begin
		ALink := TQBLink(TPopupMenu(Sender).Owner);
    AForm := TQBLinkForm.Create(Application);
    AForm.txtTable1.Caption := ALink.tbl1.FTableName;
    AForm.txtCol1.Caption := ALink.fldNam1;
    AForm.txtTable2.Caption := ALink.tbl2.FTableName;
    AForm.txtCol2.Caption := ALink.fldNam2;
    AForm.cmbJoinOperator.ItemIndex := ALink.FLinkOpt;
    AForm.cmbJoinType.ItemIndex := ALink.FLinkType;
    if AForm.ShowModal = mrOk then
    begin
      ALink.FLinkOpt := AForm.cmbJoinOperator.ItemIndex;
      ALink.FLinkType := AForm.cmbJoinType.ItemIndex;
    end;
    AForm.Free;
  end;
end;

procedure TQBArea.InsertTable(X, Y : Integer);
var
  NewTable : TQBTable;
  TableName : String;
  Cntr : Integer;
  OrigTableName : String;

begin
  Cntr := 0;
  OrigTableName := TQBForm(GetParentForm(Self)).QBTables.Items[TQBForm(GetParentForm(Self)).QBTables.ItemIndex];
  TableName := OrigTableName;
  while FindTable(TableName) <> nil do
  begin
    Cntr := Cntr + 1;
    TableName := OrigTableName + '_' + IntToStr(Cntr);
  end;
  NewTable := TQBTable.Create(Self);
  NewTable.OnGetTableColumns := TQBForm(GetParentForm(Self)).QBDialog.OnGetTableColumns;
  NewTable.Parent := Self;
  try
    NewTable.Activate(OrigTableName, TableName, X, Y);
	except
    NewTable.Free;
  end;
  TQBForm(GetParentForm(Self)).FillTableNames;
end;

function TQBArea.InsertLink(_tbl1, _tbl2 : TQBTable; _fldN1, _fldN2 : Integer) : TQBLink;
begin
  Result := TQBLink.Create(Self);
  with Result do
  begin
    Parent := Self;
    tbl1 := _tbl1;
    tbl2 := _tbl2;
    fldN1 := _fldN1;
    fldN2 := _fldN2;
    fldNam1 := tbl1.FLbx.Items[fldN1];
    fldNam2 := tbl2.FLbx.Items[fldN2];
  end;
  if FindLink(Result) then
  begin
    ShowMessage('These tables are already linked.');
    Result.Free;
    Result := nil;
    Exit;
  end;
  with Result do
  begin
    tbl1.FLbx.SelectItemBold(fldN1);
    tbl1.FLbx.Refresh;
    tbl2.FLbx.SelectItemBold(fldN2);
    tbl2.FLbx.Refresh;
    OnDragOver := _DragOver;
    OnDragDrop := _DragDrop;
  end;
  ReboundLink(Result);
  Result.Visible := True;
end;

function TQBArea.FindTable(TableName : string) : TQBTable;
var
  i : integer;
  TempTable : TQBTable;
begin
  Result := nil;
  for i := ControlCount - 1 downto 0 do
    if Controls[i] is TQBTable then
    begin
      TempTable := TQBTable(Controls[i]);
      if (TempTable.FTableName = TableName) then
      begin
        Result := TempTable;
        Exit;
      end;
    end;
end;

function TQBArea.FindLink(Link : TQBLink) : boolean;
var
  i : integer;
  TempLink : TQBLink;
begin
  Result := false;
  for i := ControlCount - 1 downto 0 do
    if Controls[i] is TQBLink then
    begin
      TempLink := TQBLink(Controls[i]);
      if (TempLink <> Link) then
        if (((TempLink.tbl1 = Link.tbl1) and (TempLink.fldN1 = Link.fldN1))
          and
          ((TempLink.tbl2 = Link.tbl2) and (TempLink.fldN2 = Link.fldN2)))
          or
          (((TempLink.tbl1 = Link.tbl2) and (TempLink.fldN1 = Link.fldN2))
          and
          ((TempLink.tbl2 = Link.tbl1) and (TempLink.fldN2 = Link.fldN1)))
          then
        begin
          Result := true;
					Exit;
        end;
    end;
end;

function TQBArea.FindOtherLink(Link : TQBLink; Tbl : TQBTable; FldN : integer) : boolean;
var
  i : integer;
  OtherLink : TQBLink;
begin
  Result := false;
  for i := ControlCount - 1 downto 0 do
    if Controls[i] is TQBLink then
    begin
      OtherLink := TQBLink(Controls[i]);
      if (OtherLink <> Link) then
        if ((OtherLink.tbl1 = Tbl) and (OtherLink.fldN1 = FldN))
          or
          ((OtherLink.tbl2 = Tbl) and (OtherLink.fldN2 = FldN))
          then
        begin
          Result := true;
          Exit;
        end;
    end;
end;

procedure TQBArea.ReboundLink(Link : TQBLink);
var
  X1, X2,
    Y1, Y2 : integer;
begin
  Link.PopMenu.Items[0].Caption := Link.tbl1.FTableName + ' :: ' + Link.tbl2.FTableName;
  with Link do
  begin
    if Tbl1 = Tbl2 then
    begin
      X1 := Tbl1.Left + Tbl1.Width;
      X2 := Tbl1.Left + Tbl1.Width + Hand;
		end
    else
    begin
      if Tbl1.Left < Tbl2.Left then
      begin
        if Tbl1.Left + Tbl1.Width + Hand < Tbl2.Left then
        begin //A
          X1 := Tbl1.Left + Tbl1.Width;
          X2 := Tbl2.Left;
          LnkX := 1;
        end
        else
        begin //B
          if Tbl1.Left + Tbl1.Width > Tbl2.Left + Tbl2.Width then
          begin
            X1 := Tbl2.Left + Tbl2.Width;
            X2 := Tbl1.Left + Tbl1.Width + Hand;
            LnkX := 3;
          end
          else
          begin
            X1 := Tbl1.Left + Tbl1.Width;
            X2 := Tbl2.Left + Tbl2.Width + Hand;
            LnkX := 2;
          end;
        end;
      end
      else
      begin
        if Tbl2.Left + Tbl2.Width + Hand > Tbl1.Left then
        begin //C
          if Tbl2.Left + Tbl2.Width > Tbl1.Left + Tbl1.Width then
          begin
            X1 := Tbl1.Left + Tbl1.Width;
            X2 := Tbl2.Left + Tbl2.Width + Hand;
            LnkX := 2;
          end
          else
          begin
						X1 := Tbl2.Left + Tbl2.Width;
            X2 := Tbl1.Left + Tbl1.Width + Hand;
            LnkX := 3;
          end;
        end
        else
        begin //D
          X1 := Tbl2.Left + Tbl2.Width;
          X2 := Tbl1.Left;
          LnkX := 4;
        end;
      end;
    end;

    Y1 := Tbl1.GetRowY(FldN1);
    Y2 := Tbl2.GetRowY(FldN2);
    if Y1 < Y2 then
    begin //M
      Y1 := Tbl1.GetRowY(FldN1) - Hand div 2;
      Y2 := Tbl2.GetRowY(FldN2) + Hand div 2;
      LnkY := 1;
    end
    else
    begin //N
      Y2 := Tbl1.GetRowY(FldN1) + Hand div 2;
      Y1 := Tbl2.GetRowY(FldN2) - Hand div 2;
      LnkY := 2;
    end;
    SetBounds(X1, Y1, X2 - X1, Y2 - Y1);
  end;
end;

procedure TQBArea.ReboundLinks4Table(ATable : TQBTable);
var
  i : integer;
  Link : TQBLink;
begin
  for i := 0 to ControlCount - 1 do
  begin
		if Controls[i] is TQBLink then
    begin
      Link := TQBLink(Controls[i]);
      if (Link.Tbl1 = ATable) or (Link.Tbl2 = ATable) then
        ReboundLink(Link);
    end;
  end;
end;

procedure TQBArea.Unlink(Sender : TObject);
var
  Link : TQBLink;
begin
  if TPopupMenu(Sender).Owner is TQBLink then
  begin
    Link := TQBLink(TPopupMenu(Sender).Owner);
    RemoveControl(Link);
    if not FindOtherLink(Link, Link.tbl1, Link.fldN1) then
    begin
      Link.tbl1.FLbx.UnSelectItemBold(Link.fldN1);
      Link.tbl1.FLbx.Refresh;
    end;
    if not FindOtherLink(Link, Link.tbl2, Link.fldN2) then
    begin
      Link.tbl2.FLbx.UnSelectItemBold(Link.fldN2);
      Link.tbl2.FLbx.Refresh;
    end;
    Link.Free;
  end;
end;

procedure TQBArea.UnlinkTable(ATable : TQBTable);
var
  i : integer;
  TempLink : TQBLink;
begin
  for i := ControlCount - 1 downto 0 do
  begin
    if Controls[i] is TQBLink then
		begin
      TempLink := TQBLink(Controls[i]);
      if (TempLink.Tbl1 = ATable) or (TempLink.Tbl2 = ATable) then
      begin
        RemoveControl(TempLink);
        if not FindOtherLink(TempLink, TempLink.tbl1, TempLink.fldN1) then
        begin
          TempLink.tbl1.FLbx.UnSelectItemBold(TempLink.fldN1);
          TempLink.tbl1.FLbx.Refresh;
        end;
        if not FindOtherLink(TempLink, TempLink.tbl2, TempLink.fldN2) then
        begin
          TempLink.tbl2.FLbx.UnSelectItemBold(TempLink.fldN2);
          TempLink.tbl2.FLbx.Refresh;
        end;
        TempLink.Free;
      end;
    end;
  end;
end;

procedure TQBArea._DragOver(Sender, Source : TObject; X, Y : Integer;
  State : TDragState; var Accept : Boolean);
begin
  if (Source = TQBForm(GetParentForm(Self)).QBTables) then
    Accept := true;
end;

procedure TQBArea._DragDrop(Sender, Source : TObject; X, Y : Integer);
begin
  if not (Sender is TQBArea) then
  begin
    X := X + TControl(Sender).Left;
    Y := Y + TControl(Sender).Top;
  end;
  if Source = TQBForm(GetParentForm(Self)).QBTables then
    InsertTable(X, Y);
end;

{ TQBGrid }

constructor TQBGrid.Create(AOwner : TComponent);
begin
  inherited Create(AOwner);
  FButton := TSpeedButton.Create(Self);
  FButton.GroupIndex := 1;
  FButton.AllowAllUp := True;
  FButton.Visible := False;
  FButton.Parent := Self;
  FButton.Caption := '...';
  FCriteria := TfrmCriteria.Create(Self);
  FAppendTo := TfrmAppendTo.Create(Self);
end;

destructor TQBGrid.Destroy;
begin
  FButton.Free;
  FCriteria.Free;
  FAppendTo.Free;
  inherited Destroy;
end;

procedure TQBGrid.DoExit;
begin
  FButton.Visible := False;
  FButton.OnClick := nil;
  inherited;
end;

procedure TQBGrid.CreateParams(var Params : TCreateParams);
begin
  inherited;
  Options := [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goColSizing, goColMoving];
  ColCount := 2;
  Height := Parent.ClientHeight;
  DefaultRowHeight := 16;
  OnDragOver := _DragOver;
  OnDragDrop := _DragDrop;
	IsEmpty := true;
end;

procedure TQBGrid.WndProc(var Message : TMessage);
begin
  if Message.Msg=WM_RBUTTONDOWN then
    ClickCell(TWMMouse(Message).XPos,TWMMouse(Message).YPos, False);
  inherited WndProc(Message);
end;

function TQBGrid.MaxSW(s1, s2 : string) : integer;
begin
  Result := Canvas.TextWidth(s1);
  if Result < Canvas.TextWidth(s2) then
    Result := Canvas.TextWidth(s2);
end;

procedure TQBGrid.InsertDefault(aCol : integer);
begin
  case TQBForm(GetParentForm(Self)).cmbQueryType.ItemIndex of
    0 :
      begin
        Cells[aCol, cRow3] := sShow;
        Cells[aCol, cRow4] := '';
        Cells[aCol, cRow5] := 'Group By';
        Cells[aCol, cRow6] := '';
      end;
  end;    
end;

procedure TQBGrid.Insert(aCol : integer; aField, aTable : string);
var
  i : integer;
begin
  if IsEmpty then
  begin
    IsEmpty := false;
    aCol := 1;
    Cells[aCol, cRow1] := aField;
		Cells[aCol, cRow2] := aTable;
    InsertDefault(aCol);
  end
  else
  begin
    if aCol = -1 then
    begin
      ColCount := ColCount + 1;
      aCol := ColCount - 1;
      Cells[aCol, cRow1] := aField;
      Cells[aCol, cRow2] := aTable;
      InsertDefault(aCol);
    end
    else
    begin
      ColCount := ColCount + 1;
      for i := ColCount - 1 downto aCol + 1 do
        MoveColumn(i - 1, i);
      Cells[aCol, cRow1] := aField;
      Cells[aCol, cRow2] := aTable;
      InsertDefault(aCol);
    end;
      //* Fix StringGrid Bug *
    if aCol > 1 then
      ColWidths[aCol - 1] := MaxSW(Cells[aCol - 1, cRow1], Cells[aCol - 1, cRow2]) + 8;
    if aCol < ColCount - 1 then
      ColWidths[aCol + 1] := MaxSW(Cells[aCol + 1, cRow1], Cells[aCol + 1, cRow2]) + 8;
    ColWidths[ColCount - 1] := MaxSW(Cells[ColCount - 1, cRow1], Cells[ColCount - 1, cRow2]) + 8;
  end;
  ColWidths[aCol] := MaxSW(aTable, aField) + 8;
end;

function TQBGrid.FindColumn(sCol : string) : integer;
var
  i : integer;
begin
  Result := -1;
  for i := 1 to ColCount - 1 do
    if Cells[i, cRow1] = sCol then
		begin
      Result := i;
      Exit;
    end;
end;

function TQBGrid.FindSameColumn(aCol : integer) : boolean;
var
  i : integer;
begin
  Result := false;
  for i := 1 to ColCount - 1 do
  begin
    if i = aCol then
      Continue
    else if Cells[i, cRow1] = Cells[aCol, cRow1] then
    begin
      Result := True;
      Exit;
    end;
  end;
end;

procedure TQBGrid.RemoveColumn(aCol : integer);
var
  i : integer;
begin
  if (ColCount > 2) then
  begin
    DeleteColumn(aCol);
  end
  else
  begin
    for i := 0 to RowCount - 1 do
      Cells[1, i] := '';
    IsEmpty := true;
  end;
end;

procedure TQBGrid.RemoveColumn4Tbl(Tbl : string);
var
  i : integer;
begin
  for i := ColCount - 1 downto 1 do
  begin
    if Cells[i, cRow2] = Tbl then
      RemoveColumn(i);
  end;
end;

procedure TQBGrid.ClickCell(X, Y : integer; LeftButton : Boolean);
var
  P : TPoint;
  mCol,
  mRow : integer;

begin
  MouseToCell(X, Y, mCol, mRow);
  CurrCol := mCol;
  if LeftButton then
  begin
    P.X := X;
    P.Y := Y + 16;
  end
  else
  begin
    P.X := X;
    P.Y := Y;
  end;
  P := ClientToScreen(P);
  if (mCol > 0) and (mCol < ColCount) and (not IsEmpty) then
  begin
    case mRow of
      cRow1 :
        begin
          if Not LeftButton then
            TQBForm(GetParentForm(Self)).mnuTbl.Popup(P.X, P.Y);
        end;
			cRow3 :
        begin
          if LeftButton then
          begin
            case TQBForm(GetParentForm(Self)).cmbQueryType.ItemIndex of
              0 :
                begin
                  if Cells[mCol, cRow3] = sShow then
                    TQBForm(GetParentForm(Self)).mnuShow.Items[0].Checked := true
                  else
                    TQBForm(GetParentForm(Self)).mnuShow.Items[0].Checked := false;
                  TQBForm(GetParentForm(Self)).mnuShow.Popup(P.X, P.Y);
                end;
              1 :
                begin
                  //update/Update To
                  if Cells[mCol, cRow3] <> '' then
                    TQBForm(GetParentForm(Self)).mnuUpdateTo.Items[0].Enabled := true
                  else
                    TQBForm(GetParentForm(Self)).mnuUpdateTo.Items[0].Enabled := false;
                  TQBForm(GetParentForm(Self)).mnuUpdateTo.Popup(P.X, P.Y);
                end;
              2 :
                begin
                  //delete/Criteria
                  if Cells[mCol, cRow3] <> '' then
                    TQBForm(GetParentForm(Self)).mnuCriteria.Items[0].Enabled := true
                  else
                    TQBForm(GetParentForm(Self)).mnuCriteria.Items[0].Enabled := false;
                  TQBForm(GetParentForm(Self)).mnuCriteria.Popup(P.X, P.Y);
                end;
              3 :
                begin
                  //insert/Append To
                  if Cells[mCol, cRow3] <> '' then
                    TQBForm(GetParentForm(Self)).mnuAppendTo.Items[0].Enabled := true
                  else
                    TQBForm(GetParentForm(Self)).mnuAppendTo.Items[0].Enabled := false;
                  TQBForm(GetParentForm(Self)).mnuAppendTo.Popup(P.X, P.Y);
                end;

            end;
          end;
        end;
      cRow4 :
        begin
          if LeftButton then
          begin
            case TQBForm(GetParentForm(Self)).cmbQueryType.ItemIndex of
              0 :
                begin
                  if Cells[mCol, cRow4] = sSort[1] then
                    TQBForm(GetParentForm(Self)).mnuSort.Items[0].Checked := true
                  else if Cells[mCol, cRow4] = sSort[2] then
                    TQBForm(GetParentForm(Self)).mnuSort.Items[2].Checked := true
                  else
                    TQBForm(GetParentForm(Self)).mnuSort.Items[3].Checked := true;
                  TQBForm(GetParentForm(Self)).mnuSort.Popup(P.X, P.Y);
                end;
              1 :
                begin
                  //update/Criteria
                  if Cells[mCol, cRow4] <> '' then
                    TQBForm(GetParentForm(Self)).mnuCriteria.Items[0].Enabled := true
                  else
                    TQBForm(GetParentForm(Self)).mnuCriteria.Items[0].Enabled := false;
                  TQBForm(GetParentForm(Self)).mnuCriteria.Popup(P.X, P.Y);
                end;
              3 :
                begin
                  //insert/Criteria
                  if Cells[mCol, cRow4] <> '' then
                    TQBForm(GetParentForm(Self)).mnuCriteria.Items[0].Enabled := true
                  else
                    TQBForm(GetParentForm(Self)).mnuCriteria.Items[0].Enabled := false;
                  TQBForm(GetParentForm(Self)).mnuCriteria.Popup(P.X, P.Y);
                end;
            end;
          end;
        end;
      cRow5 :
        begin
          if LeftButton then
          begin
            case TQBForm(GetParentForm(Self)).cmbQueryType.ItemIndex of
              0 :
                begin
                  if Cells[mCol, cRow5] = sAggr[1] then
                    TQBForm(GetParentForm(Self)).mnuFunc.Items[0].Checked := true
                  else if Cells[mCol, cRow5] = sAggr[2] then
                    TQBForm(GetParentForm(Self)).mnuFunc.Items[2].Checked := true
                  else if Cells[mCol, cRow5] = sAggr[3] then
                    TQBForm(GetParentForm(Self)).mnuFunc.Items[3].Checked := true
                  else if Cells[mCol, cRow5] = sAggr[4] then
                    TQBForm(GetParentForm(Self)).mnuFunc.Items[4].Checked := true
                  else if Cells[mCol, cRow5] = sAggr[5] then
                    TQBForm(GetParentForm(Self)).mnuFunc.Items[5].Checked := true
                  else
                    TQBForm(GetParentForm(Self)).mnuFunc.Items[6].Checked := true;
                  TQBForm(GetParentForm(Self)).mnuFunc.Popup(P.X, P.Y);
                end;
            end;
          end;
        end;
      cRow6 :
        begin
          if LeftButton then
          begin
            case TQBForm(GetParentForm(Self)).cmbQueryType.ItemIndex of
              0 :
                begin
                  if Cells[mCol, cRow6] <> '' then
                    TQBForm(GetParentForm(Self)).mnuCriteria.Items[0].Enabled := true
                  else
                    TQBForm(GetParentForm(Self)).mnuCriteria.Items[0].Enabled := false;
                  TQBForm(GetParentForm(Self)).mnuCriteria.Popup(P.X, P.Y);
                end;
            end;
          end;
        end;
    end;
  end;
end;

procedure TQBGrid.ButtonClick(Sender : TObject);
begin
  FButton.Down := True;
  ClickCell(TSpeedButton(Sender).Left, TSpeedButton(Sender).Top, True);
  FButton.Down := False;
end;

procedure TQBGrid.TopLeftChanged;
begin
  inherited TopLeftChanged;
  if FButton.Visible = True then
  begin
    FButton.Visible := False;
    FButton.OnClick := nil;
    SelectCell(Col, Row);
  end;
end;

procedure TQBGrid.ColumnMoved(FromIndex, ToIndex: Longint);
begin
  inherited ColumnMoved(FromIndex, ToIndex);
  if FButton.Visible = True then
  begin
    FButton.Visible := False;
    FButton.OnClick := nil;
    SelectCell(Col, Row);
  end;
end;

procedure TQBGrid.ColWidthsChanged;
begin
  inherited ColWidthsChanged;
  if FButton.Visible = True then
  begin
    FButton.Visible := False;
    FButton.OnClick := nil;
    SelectCell(Col, Row);
  end;
end;

procedure TQBGrid.KeyDown(var Key: Word; Shift: TShiftState);
begin
  inherited KeyDown(Key, Shift);
  if ((key = VK_RETURN) and (Shift = [ssCtrl])) then
  begin
    ButtonClick(FButton);
  end;
  if Key = VK_SPACE then
    ButtonClick(FButton);
end;


function TQBGrid.SelectCell(ACol, ARow : integer) : boolean;
var
  Rect : TRect;

begin
  inherited SelectCell(ACol, ARow);

  FButton.Visible := False;
  FButton.OnClick := nil;

  if Not IsEmpty then
  begin
    Rect := CellRect(ACol, ARow);
    if ACol <> 0 then
    begin
      case ARow of
        cRow1 :
          begin
            FButton.Visible := False;
            FButton.OnClick := nil;
          end;

        cRow2 :
          begin
            FButton.Visible := False;
            FButton.OnClick := nil;
          end;

        cRow3 :
          begin
            FButton.Top := Rect.Top;
            FButton.Left := Rect.Right - 16;
            FButton.Width := 16;
            FButton.Height := 16;
            FButton.Visible := True;
            FButton.OnClick := ButtonClick;
          end;

        cRow4 :
          begin
            FButton.Top := Rect.Top;
            FButton.Left := Rect.Right - 16;
            FButton.Width := 16;
            FButton.Height := 16;
            FButton.Visible := True;
            FButton.OnClick := ButtonClick;
          end;

        cRow5 :
          begin
            FButton.Top := Rect.Top;
            FButton.Left := Rect.Right - 16;
            FButton.Width := 16;
            FButton.Height := 16;
            FButton.Visible := True;
            FButton.OnClick := ButtonClick;
          end;

        cRow6 :
          begin
            FButton.Top := Rect.Top;
            FButton.Left := Rect.Right - 16;
            FButton.Width := 16;
            FButton.Height := 16;
            FButton.Visible := True;
            FButton.OnClick := ButtonClick;
          end;
      end;
      Result := True;
    end
    else
    begin
      FButton.Visible := False;
      FButton.OnClick := nil;
      Result := True;
    end;
  end
  else
  begin
    FButton.Visible := False;
    FButton.OnClick := nil;
    Result := False;
  end;
end;

procedure TQBGrid._DragOver(Sender, Source : TObject; X, Y : Integer;
  State : TDragState; var Accept : Boolean);
begin
  if (Source <> TQBForm(GetParentForm(Self)).QBTables) then
    Accept := true;
end;

procedure TQBGrid._DragDrop(Sender, Source : TObject; X, Y : Integer);
var
  dCol,
    dRow : integer;
begin
  if ((Source is TQBLbx) and
    (Source <> TQBForm(GetParentForm(Self)).QBTables))
    then
  begin
    TQBTable(TWinControl(Source).Parent).FLbx.Checked[TQBTable(TWinControl(Source).Parent).FLbx.ItemIndex] := True; //*** check
    MouseToCell(X, Y, dCol, dRow);
    if dCol = 0 then
      Exit;
    Insert(dCol,
      TQBTable(TWinControl(Source).Parent).FLbx.Items[TQBTable(TWinControl(Source).Parent).FLbx.ItemIndex],
      TQBTable(TWinControl(Source).Parent).FTableName);
  end;
end;

{ TQBForm }

procedure TQBForm.CreateParams(var Params : TCreateParams);
begin
  inherited CreateParams(Params);
  QBArea := TQBArea.Create(Self);
  QBArea.Parent := QBPanel;
  QBArea.Align := alClient;
  QBArea.Color := clAppWorkSpace;
  QBGrid := TQBGrid.Create(Self);
  QBGrid.Parent := pnlGridParent;
  QBGrid.Align := alClient;
end;

procedure TQBForm.mnuFunctionClick(Sender : TObject);
var
  Item : TMenuItem;
begin
  if Sender is TMenuItem then
  begin
    Item := (Sender as TMenuItem);
    if not Item.Checked then
    begin
      Item.Checked := true;
      QBGrid.Cells[QBGrid.CurrCol, cRow5] := sAggr[Item.Tag];
    end;
  end;
end;

procedure TQBForm.mnuRemoveClick(Sender : TObject);
var
  TempTable : TQBTable;
begin
  TempTable := QBArea.FindTable(QBGrid.Cells[QBGrid.CurrCol, cRow2]);
  if not QBGrid.FindSameColumn(QBGrid.CurrCol) then
    TempTable.FLbx.Checked[TempTable.FLbx.Items.IndexOf(QBGrid.Cells[QBGrid.CurrCol, cRow1])] := false;
  QBGrid.RemoveColumn(QBGrid.CurrCol);
  QBGrid.Refresh; // fix for StringGrid bug
end;

procedure TQBForm.mnuShowClick(Sender : TObject);
begin
  if mnuShow.Items[0].Checked then
  begin
    QBGrid.Cells[QBGrid.CurrCol, cRow3] := '';
    mnuShow.Items[0].Checked := false;
  end
  else
  begin
    QBGrid.Cells[QBGrid.CurrCol, cRow3] := sShow;
    mnuShow.Items[0].Checked := true;
  end;
end;

procedure TQBForm.mnuSortClick(Sender : TObject);
var
  Item : TMenuItem;
begin
  if Sender is TMenuItem then
  begin
    Item := (Sender as TMenuItem);
    if not Item.Checked then
    begin
      Item.Checked := true;
      QBGrid.Cells[QBGrid.CurrCol, cRow4] := sSort[Item.Tag];
    end;
  end;
end;

procedure TQBForm.ClearAll;
var
  i : integer;
  TempTable : TQBTable;
begin
  for i := QBArea.ControlCount - 1 downto 0 do
    if QBArea.Controls[i] is TQBTable then
    begin
      TempTable := TQBTable(QBArea.Controls[i]);
      QBGrid.RemoveColumn4Tbl(TempTable.FTableName);
      TempTable.Free;
    end
    else
      QBArea.Controls[i].Free; // QBLink
  MemoSQL.Lines.Clear;
  Pages.ActivePage := TabColumns;
  cmbQueryType.ItemIndex := 0;
  CurrentQueryType := 0;
  cmbQueryTypeChange(cmbQueryType);
end;

procedure TQBForm.btnNewClick(Sender : TObject);
begin
  ClearAll;
end;

procedure TQBForm.btnTablesClick(Sender : TObject);
begin
  VSplitter.Visible := TToolButton(Sender).Down;
  QBTables.Visible := TToolButton(Sender).Down;
end;

procedure TQBForm.btnPagesClick(Sender : TObject);
begin
  HSplitter.Visible := TToolButton(Sender).Down;
  Pages.Visible := TToolButton(Sender).Down;
end;

procedure TQBForm.OpenDatabase(aSysTables : boolean);
begin
  QBDialog.FSystemTables := aSysTables;

  //get the relation names...
  if Assigned(FOnGetTables) then
    FOnGetTables(Self, aSysTables, '', QBTables);
end;

procedure TQBForm.btnSQLClick(Sender : TObject);
var
  Lst, Lst1, Lst2, // temporary string lists
  SQL : TStringList;
  i : integer;
  s : string;
  tbl1, tbl2 : string;
  Link : TQBLink;
  Aggregates : Boolean;

  function ExtractName(s : string) : string;
{  var
    p : integer;}
  begin
    Result := s;
{    p := Pos('.', s);
    if p = 0 then
      Exit;
    Result := System.Copy(s, 1, p - 1);}
  end;

begin
  Lst := TSTringList.Create;
  SQL := TStringList.Create;
	try
    case cmbQueryType.ItemIndex of
      0 :
        begin
          if QBGrid.IsEmpty then
          begin
            ShowMessage('There are no columns to generate the query.');
            Exit;
          end;
          // SELECT clause
          Aggregates := False;
          with QBGrid do
          begin
            for i := 1 to ColCount - 1 do
            begin
              if Cells[i, cRow3] = sShow then
              begin
                s := ExtractName(Cells[i, cRow2]) + '.' + Cells[i, cRow1];
                if Cells[i, cRow5] <> 'Group By' then
                begin
                  s := UpperCase(Cells[i, cRow5]) + '(' + s + ')';
                  Aggregates := True;
                end;
                Lst.Add(s);
              end;
            end;
            if Lst.Count = 0 then
            begin
              ShowMessage('There are no Columns in the select list.');
              SQL.Free;
              Lst.Free;
              Exit;
            end;
            s := 'SELECT' + #13#10;
            for i := 0 to Lst.Count - 1 do
            begin
              s := s + '  ' + Lst[i];
              if (i < Lst.Count - 1) then
                s := s + ', ';
							s := s + #13#10;
            end;
            SQL.Text := s;
            Lst.Clear;
          end;

          // FROM clause
          with QBArea do
          begin
            Lst1 := TSTringList.Create; // tables in joins
            Lst2 := TSTringList.Create; // outer joins
            for i := 0 to ControlCount - 1 do // search tables for joins
            begin
              if Controls[i] is TQBLink then
              begin
                Link := TQBLink(Controls[i]);
                if Link.FLinkType > 0 then
                begin
                  tbl1 := ExtractName(Link.Tbl1.FTableName);
                  tbl2 := ExtractName(Link.Tbl2.FTableName);
                  if Lst1.IndexOf(tbl1) = -1 then
                    Lst1.Add(tbl1);
                  if Lst1.IndexOf(tbl2) = -1 then
                    Lst1.Add(tbl2);
                  Lst2.Add(tbl1 + sOuterJoin[Link.FLinkType] + tbl2 + ' ON '
                    + tbl1 + '.' + Link.FldNam1
                    + sLinkOpt[Link.FLinkOpt]
                    + tbl2 + '.' + Link.FldNam2
                    );
                end;
              end;
            end;
            for i := 0 to ControlCount - 1 do
            begin
              if Controls[i] is TQBTable then
              begin
                if (Lst.IndexOf(ExtractName(TQBTable(Controls[i]).FTableName)) = -1)
                  and
                  (Lst1.IndexOf(ExtractName(TQBTable(Controls[i]).FTableName)) = -1)
									then
                  Lst.Add(ExtractName(TQBTable(Controls[i]).FTableName));
              end;
            end;
            Lst1.Free;

            s := 'FROM' + #13#10;
            for i := 0 to Lst2.Count - 1 do
            begin
              s := s + '  ' + Lst2[i];
              if (i < Lst2.Count - 1) then
                s := s + ', ';
              s := s + #13#10;
            end;
            SQL.Text := SQL.Text + s;
            s := '';

            if (Lst.Count > 0) and (Lst2.Count > 0) then
              SQL[SQL.Count - 1] := SQL[SQL.Count - 1] + ', ';

            for i := 0 to Lst.Count - 1 do
            begin
              s := s + '  ' + Lst[i];
              if (i < Lst.Count - 1) then
                s := s + ', ';
              s := s + #13#10;
            end;
            SQL.Text := SQL.Text + s;
            s := '';
            Lst2.Free;
            Lst.Clear;
          end;

          // GROUP BY clause
          if Aggregates then
          begin
            with QBGrid do
            begin
              for i := 1 to ColCount - 1 do
							begin
                if Cells[i, cRow5] = 'Group By' then
                begin
                  s := ExtractName(Cells[i, cRow2]) + '.' + Cells[i, cRow1];
                  Lst.Add(s);
                end;
              end;
              s := '';
              for i := 0 to Lst.Count - 1 do
              begin
                if (i < Lst.Count - 1) then
                  s := s + '  ' + Lst[i] + ', '
                else
                  s := s + '  ' + Lst[i];
                s := s + #13#10;
              end;
              if s <> '' then
                s := 'GROUP BY' + #13#10 + s;
              SQL.Text := SQL.Text + s;
              Lst.Clear;
            end;
          end;

          // WHERE clause
          with QBArea do
          begin
            for i := 0 to ControlCount - 1 do
            begin
              if Controls[i] is TQBLink then
              begin
                Link := TQBLink(Controls[i]);
                if Link.FLinkType = 0 then
                begin
                  s := ExtractName(Link.tbl1.FTableName) + '.' + Link.fldNam1
                    + sLinkOpt[Link.FLinkOpt]
                    + ExtractName(Link.tbl2.FTableName) + '.' + Link.fldNam2;
                  Lst.Add(s);
                end;
              end;
						end;

            with QBGrid do
            begin
              for i := 1 to ColCount - 1 do
              begin
                if Cells[i, cRow6] <> '' then
                begin
                  s := ExtractName(Cells[i, cRow2]) + '.' + Cells[i, cRow1];
                  s := '(' + s + Cells[i, cRow6] + ')';
                  Lst.Add(s);
                end;
              end;
            end;

            s := '';
            for i := 0 to Lst.Count - 1 do
            begin
              if (i < Lst.Count - 1) then
                s := s + '  ' + Lst[i] + ' AND '
              else
                s := s + '  ' + Lst[i];
              s := s + #13#10;
            end;
            if s <> '' then
            begin
              if Not Aggregates then
                s := 'WHERE' + #13#10 + s
              else
                s := 'HAVING' + #13#10 + s;
            end;
            SQL.Text := SQL.Text + s;
            Lst.Clear;
          end;

          // ORDER BY clause
          with QBGrid do
          begin
            for i := 1 to ColCount - 1 do
						begin
              if Cells[i, cRow4] <> '' then
              begin
                s := ExtractName(Cells[i, cRow2]) + '.' + Cells[i, cRow1];
                if Cells[i, cRow4] = sSort[3] then
                  s := s + ' DESC';
                Lst.Add(s);
              end;
            end;
            s := '';
            for i := 0 to Lst.Count - 1 do
            begin
              if (i < Lst.Count - 1) then
                s := s + '  ' + Lst[i] + ', '
              else
                s := s + '  ' + Lst[i];
              s := s + #13#10;
            end;
            if s <> '' then
              s := 'ORDER BY' + #13#10 + s;

            SQL.Text := SQL.Text + s;
            s := '';
            Lst.Clear;
          end;
        end;
      1 :
        begin
          if QBGrid.IsEmpty then
          begin
            ShowMessage('There are no columns to generate the query.');
            Exit;
          end;
          with QBGrid do
          begin
            for i := 1 to ColCount - 1 do
            begin
              if Cells[i, cRow3] <> '' then
              begin
								s := ExtractName(Cells[i, cRow2]) + '.' + Cells[i, cRow1] + Cells[i, cRow3];
              end;
              Lst.Add(s);
            end;
            if Lst.Count = 0 then
            begin
              ShowMessage('There are no Columns in the select list.');
              SQL.Free;
              Lst.Free;
              Exit;
            end;
            s := 'UPDATE' + #13#10 + '  ' + cmbQueryTable.Text + #13#10 + 'SET' + #13#10;
            for i := 0 to Lst.Count - 1 do
            begin
              s := s + '  ' + Lst[i];
              if (i < Lst.Count - 1) then
                s := s + ', ';
              s := s + #13#10;
            end;
            SQL.Text := s;
            Lst.Clear;
          end;

          with QBGrid do
          begin
            for i := 1 to ColCount - 1 do
            begin
              if Cells[i, cRow4] <> '' then
              begin
                s := ExtractName(Cells[i, cRow2]) + '.' + Cells[i, cRow1];
                s := '(' + s + Cells[i, cRow4] + ')';
                Lst.Add(s);
              end;
            end;
          end;

          s := '';
          for i := 0 to Lst.Count - 1 do
          begin
						if (i < Lst.Count - 1) then
              s := s + '  ' + Lst[i] + ' AND '
            else
              s := s + '  ' + Lst[i];
            s := s + #13#10;
          end;
          if s <> '' then
          begin
            s := 'WHERE' + #13#10 + s
          end;
          SQL.Text := SQL.Text + s;
          Lst.Clear;
        end;

      2 :
        begin
          SQL.Text := 'DELETE FROM' + #13#10 + '  ' + cmbQueryTable.Text + #13#10;

          // FROM clause
          with QBArea do
          begin
            Lst1 := TSTringList.Create; // tables in joins
            Lst2 := TSTringList.Create; // outer joins
            for i := 0 to ControlCount - 1 do // search tables for joins
            begin
              if Controls[i] is TQBLink then
              begin
                Link := TQBLink(Controls[i]);
                if Link.FLinkType > 0 then
                begin
                  tbl1 := ExtractName(Link.Tbl1.FTableName);
                  tbl2 := ExtractName(Link.Tbl2.FTableName);
                  if Lst1.IndexOf(tbl1) = -1 then
                    Lst1.Add(tbl1);
                  if Lst1.IndexOf(tbl2) = -1 then
                    Lst1.Add(tbl2);
                  Lst2.Add(tbl1 + sOuterJoin[Link.FLinkType] + tbl2 + ' ON '
                    + tbl1 + '.' + Link.FldNam1
                    + sLinkOpt[Link.FLinkOpt]
										+ tbl2 + '.' + Link.FldNam2
										);
                end;
              end;
            end;
            Lst1.Free;

            s := '';
            for i := 0 to Lst2.Count - 1 do
            begin
              s := s + Lst2[i];
              if (i < Lst2.Count - 1) then
                s := s + ', ';
            end;
            Lst.Add(s);
            s := '';
            Lst2.Free;
          end;

          // WHERE clause
          with QBArea do
          begin
            for i := 0 to ControlCount - 1 do
            begin
              if Controls[i] is TQBLink then
              begin
                Link := TQBLink(Controls[i]);
                if Link.FLinkType = 0 then
                begin
                  s := ExtractName(Link.tbl1.FTableName) + '.' + Link.fldNam1
                    + sLinkOpt[Link.FLinkOpt]
                    + ExtractName(Link.tbl2.FTableName) + '.' + Link.fldNam2;
                  Lst.Add(s);
                end;
              end;
            end;

            with QBGrid do
            begin
							for i := 1 to ColCount - 1 do
							begin
                if Cells[i, cRow3] <> '' then
                begin
                  s := ExtractName(Cells[i, cRow2]) + '.' + Cells[i, cRow1];
                  s := '(' + s + Cells[i, cRow3] + ')';
                  Lst.Add(s);
                end;
              end;
            end;

            s := '';
            for i := 0 to Lst.Count - 1 do
            begin
              if (i < Lst.Count - 1) then
                s := s + '  ' + Lst[i] + ' AND '
              else
                s := s + '  ' + Lst[i];
              s := s + #13#10;
            end;
            if s <> '' then
              s := 'WHERE' + #13#10 + s;
            SQL.Text := SQL.Text + s;
            Lst.Clear;
          end;
        end;

      3 :
        begin

        end;
    end;

//    SQL[SQL.Count - 1] := SQL[SQL.Count - 1] + ';';
    MemoSQL.Lines.Assign(SQL);
    Pages.ActivePage := TabSQL;
  finally
    SQL.Free;
    Lst.Free;
	end;
	btnInsert.Enabled := True;
end;

procedure TQBForm.FormCreate(Sender: TObject);
begin
  HelpContext := IDH_Query_Builder;
  cmbQueryType.ItemIndex := 0;
  CurrentQueryType := 0;
  cmbQueryTypeChange(cmbQueryType);
end;

procedure TQBForm.cmbQueryTypeChange(Sender: TObject);
var
  Row1,
  Row2,
  Row3,
  Row4,
  Row5,
  Row6,
  Row7,
  Row8 : TStringList;
  Idx : Integer;

begin
  Row1 := TStringList.Create;
  Row2 := TStringList.Create;
  Row3 := TStringList.Create;
  Row4 := TStringList.Create;
  Row5 := TStringList.Create;
  Row6 := TStringList.Create;
  Row7 := TStringList.Create;
  Row8 := TStringList.Create;
  try
    case cmbQueryType.ItemIndex of
      0 : //select
        begin
          pnlExtraQueryData.Visible := False;
          case CurrentQueryType of
            0 : //from select
							begin
                //save the old data
                Row1.Text := QBGrid.Rows[cRow1].Text;
                Row2.Text := QBGrid.Rows[cRow2].Text;
                Row3.Text := QBGrid.Rows[cRow3].Text;
                Row4.Text := QBGrid.Rows[cRow4].Text;
                Row5.Text := QBGrid.Rows[cRow5].Text;
                Row6.Text := QBGrid.Rows[cRow6].Text;

                //put the old data back
                QBGrid.Rows[cRow1] := Row1;
                QBGrid.Rows[cRow2] := Row2;
                QBGrid.Rows[cRow3] := Row3;
                QBGrid.Rows[cRow4] := Row4;
                QBGrid.Rows[cRow5] := Row5;
                QBGrid.Rows[cRow6] := Row6;

                //mod the grid
                QBGrid.RowCount := 6;
                QBGrid.Cells[0, cRow1] := 'Field';
                QBGrid.Cells[0, cRow2] := 'Table';
                QBGrid.Cells[0, cRow3] := 'Show';
                QBGrid.Cells[0, cRow4] := 'Sort';
                QBGrid.Cells[0, cRow5] := 'Aggregate';
                QBGrid.Cells[0, cRow6] := 'Criteria';
              end;
            1 : //from update
              begin
                //save the old data
                Row1.Text := QBGrid.Rows[cRow1].Text;
                Row2.Text := QBGrid.Rows[cRow2].Text;
                Row3.Text := QBGrid.Rows[cRow3].Text;
                Row4.Text := QBGrid.Rows[cRow4].Text;

                //put the old data back
                QBGrid.Rows[cRow1] := Row1;
                QBGrid.Rows[cRow2] := Row2;
                QBGrid.Rows[cRow3].Text := '';
                QBGrid.Rows[cRow4].Text := '';
								QBGrid.Rows[cRow5].Text := '';
                QBGrid.Rows[cRow6] := Row4;

                //mod the grid
                QBGrid.RowCount := 6;
                QBGrid.Cells[0, cRow1] := 'Field';
                QBGrid.Cells[0, cRow2] := 'Table';
                QBGrid.Cells[0, cRow3] := 'Show';
                QBGrid.Cells[0, cRow4] := 'Sort';
                QBGrid.Cells[0, cRow5] := 'Aggregate';
                QBGrid.Cells[0, cRow6] := 'Criteria';

                //put shows and aggregates back in
                for Idx := 1 to QBGrid.Rows[cRow3].Count - 1 do
                begin
                  QBGrid.Cells[Idx, cRow3] := 'Show';
                end;
                for Idx := 1 to QBGrid.Rows[cRow5].Count - 1 do
                begin
                  QBGrid.Cells[Idx, cRow5] := 'Group By';
                end;
              end;
            2 : //from delete
              begin
                //save the old data
                Row1.Text := QBGrid.Rows[cRow1].Text;
                Row2.Text := QBGrid.Rows[cRow2].Text;
                Row3.Text := QBGrid.Rows[cRow3].Text;

                //put the old data back
                QBGrid.Rows[cRow1] := Row1;
                QBGrid.Rows[cRow2] := Row2;
                QBGrid.Rows[cRow3].Text := '';
                QBGrid.Rows[cRow4].Text := '';
                QBGrid.Rows[cRow5].Text := '';
                QBGrid.Rows[cRow6] := Row3;

                //mod the grid
                QBGrid.RowCount := 6;
								QBGrid.Cells[0, cRow1] := 'Field';
                QBGrid.Cells[0, cRow2] := 'Table';
                QBGrid.Cells[0, cRow3] := 'Show';
                QBGrid.Cells[0, cRow4] := 'Sort';
                QBGrid.Cells[0, cRow5] := 'Aggregate';
                QBGrid.Cells[0, cRow6] := 'Criteria';

                //put shows and aggregates back in
                for Idx := 1 to QBGrid.Rows[cRow3].Count - 1 do
                begin
                  QBGrid.Cells[Idx, cRow3] := 'Show';
                end;
                for Idx := 1 to QBGrid.Rows[cRow5].Count - 1 do
                begin
                  QBGrid.Cells[Idx, cRow5] := 'Group By';
                end;
              end;
            3 : //from insert
              begin
                //save the old data
                Row1.Text := QBGrid.Rows[cRow1].Text;
                Row2.Text := QBGrid.Rows[cRow2].Text;
                Row3.Text := QBGrid.Rows[cRow3].Text;
                Row4.Text := QBGrid.Rows[cRow4].Text;

                //put the old data back
                QBGrid.Rows[cRow1] := Row1;
                QBGrid.Rows[cRow2] := Row2;
                QBGrid.Rows[cRow3].Text := '';
                QBGrid.Rows[cRow4].Text := '';
                QBGrid.Rows[cRow5].Text := '';
                QBGrid.Rows[cRow6] := Row4;

                //mod the grid
                QBGrid.RowCount := 6;
                QBGrid.Cells[0, cRow1] := 'Field';
                QBGrid.Cells[0, cRow2] := 'Table';
                QBGrid.Cells[0, cRow3] := 'Show';
                QBGrid.Cells[0, cRow4] := 'Sort';
								QBGrid.Cells[0, cRow5] := 'Aggregate';
                QBGrid.Cells[0, cRow6] := 'Criteria';

                //put shows and aggregates back in
                for Idx := 1 to QBGrid.Rows[cRow3].Count - 1 do
                begin
                  QBGrid.Cells[Idx, cRow3] := 'Show';
                end;
                for Idx := 1 to QBGrid.Rows[cRow5].Count - 1 do
                begin
                  QBGrid.Cells[Idx, cRow5] := 'Group By';
                end;
              end;
          end;
          CurrentQueryType := 0;
        end;
      1 : //update
        begin
          pnlExtraQueryData.Visible := True;
          FillTableNames;
          lblQueryPrompt.Caption := 'Update Table:';
          case CurrentQueryType of
            0 : //from select
              begin
                //save the old data
                Row1.Text := QBGrid.Rows[cRow1].Text;
                Row2.Text := QBGrid.Rows[cRow2].Text;
                Row3.Text := QBGrid.Rows[cRow3].Text;
                Row4.Text := QBGrid.Rows[cRow4].Text;
                Row5.Text := QBGrid.Rows[cRow5].Text;
                Row6.Text := QBGrid.Rows[cRow6].Text;

                //put the old data back
                QBGrid.Rows[cRow1] := Row1;
                QBGrid.Rows[cRow2] := Row2;
                QBGrid.Rows[cRow3].Text := '';
                QBGrid.Rows[cRow4] := Row6;

                //mod the grid
								QBGrid.RowCount := 4;
                QBGrid.Cells[0, cRow1] := 'Field';
                QBGrid.Cells[0, cRow2] := 'Table';
                QBGrid.Cells[0, cRow3] := 'Update To';
                QBGrid.Cells[0, cRow4] := 'Criteria';
              end;
            1 : //from update
              begin
                //save the old data
                Row1.Text := QBGrid.Rows[cRow1].Text;
                Row2.Text := QBGrid.Rows[cRow2].Text;
                Row3.Text := QBGrid.Rows[cRow3].Text;
                Row4.Text := QBGrid.Rows[cRow4].Text;

                //put the old data back
                QBGrid.Rows[cRow1] := Row1;
                QBGrid.Rows[cRow2] := Row2;
                QBGrid.Rows[cRow3] := Row3;
                QBGrid.Rows[cRow4] := Row4;

                //mod the grid
                QBGrid.RowCount := 4;
                QBGrid.Cells[0, cRow1] := 'Field';
                QBGrid.Cells[0, cRow2] := 'Table';
                QBGrid.Cells[0, cRow3] := 'Update To';
                QBGrid.Cells[0, cRow4] := 'Criteria';
              end;
            2 : //from delete
              begin
                //save the old data
                Row1.Text := QBGrid.Rows[cRow1].Text;
                Row2.Text := QBGrid.Rows[cRow2].Text;
                Row3.Text := QBGrid.Rows[cRow3].Text;

                //put the old data back
                QBGrid.Rows[cRow1] := Row1;
                QBGrid.Rows[cRow2] := Row2;
                QBGrid.Rows[cRow3].Text := '';
                QBGrid.Rows[cRow4] := Row3;

                //mod the grid
                QBGrid.RowCount := 4;
                QBGrid.Cells[0, cRow1] := 'Field';
                QBGrid.Cells[0, cRow2] := 'Table';
                QBGrid.Cells[0, cRow3] := 'Update To';
                QBGrid.Cells[0, cRow4] := 'Criteria';
              end;
            3 : //from insert
              begin
                //save the old data
                Row1.Text := QBGrid.Rows[cRow1].Text;
                Row2.Text := QBGrid.Rows[cRow2].Text;
                Row3.Text := QBGrid.Rows[cRow3].Text;
                Row4.Text := QBGrid.Rows[cRow4].Text;

                //put the old data back
                QBGrid.Rows[cRow1] := Row1;
                QBGrid.Rows[cRow2] := Row2;
                QBGrid.Rows[cRow3].Text := '';
                QBGrid.Rows[cRow4] := Row4;

                //mod the grid
                QBGrid.RowCount := 4;
                QBGrid.Cells[0, cRow1] := 'Field';
                QBGrid.Cells[0, cRow2] := 'Table';
                QBGrid.Cells[0, cRow3] := 'Update To';
                QBGrid.Cells[0, cRow4] := 'Criteria';
              end;
          end;
          CurrentQueryType := 1;
        end;
      2 : //delete
        begin
          pnlExtraQueryData.Visible := True;
          FillTableNames;
          lblQueryPrompt.Caption := 'Delete From Table:';
          case CurrentQueryType of
            0 : //from select
							begin
                //save the old data
                Row1.Text := QBGrid.Rows[cRow1].Text;
                Row2.Text := QBGrid.Rows[cRow2].Text;
                Row3.Text := QBGrid.Rows[cRow3].Text;
                Row4.Text := QBGrid.Rows[cRow4].Text;
                Row5.Text := QBGrid.Rows[cRow5].Text;
                Row6.Text := QBGrid.Rows[cRow6].Text;

                //put the old data back
                QBGrid.Rows[cRow1] := Row1;
                QBGrid.Rows[cRow2] := Row2;
                QBGrid.Rows[cRow3] := Row6;

                //mod the grid
                QBGrid.RowCount := 3;
                QBGrid.Cells[0, cRow1] := 'Field';
                QBGrid.Cells[0, cRow2] := 'Table';
                QBGrid.Cells[0, cRow3] := 'Criteria';
              end;
            1 : //from update
              begin
                //save the old data
                Row1.Text := QBGrid.Rows[cRow1].Text;
                Row2.Text := QBGrid.Rows[cRow2].Text;
                Row3.Text := QBGrid.Rows[cRow3].Text;
                Row4.Text := QBGrid.Rows[cRow4].Text;

                //put the old data back
                QBGrid.Rows[cRow1] := Row1;
                QBGrid.Rows[cRow2] := Row2;
                QBGrid.Rows[cRow3] := Row4;

                //mod the grid
                QBGrid.RowCount := 3;
                QBGrid.Cells[0, cRow1] := 'Field';
                QBGrid.Cells[0, cRow2] := 'Table';
                QBGrid.Cells[0, cRow3] := 'Criteria';
              end;
						2 : //from delete
              begin
                //save the old data
                Row1.Text := QBGrid.Rows[cRow1].Text;
                Row2.Text := QBGrid.Rows[cRow2].Text;
                Row3.Text := QBGrid.Rows[cRow3].Text;

                //put the old data back
                QBGrid.Rows[cRow1] := Row1;
                QBGrid.Rows[cRow2] := Row2;
                QBGrid.Rows[cRow3] := Row3;

                //mod the grid
                QBGrid.RowCount := 3;
                QBGrid.Cells[0, cRow1] := 'Field';
                QBGrid.Cells[0, cRow2] := 'Table';
                QBGrid.Cells[0, cRow3] := 'Criteria';
              end;
            3 : //from insert
              begin
                //save the old data
                Row1.Text := QBGrid.Rows[cRow1].Text;
                Row2.Text := QBGrid.Rows[cRow2].Text;
                Row3.Text := QBGrid.Rows[cRow3].Text;
                Row4.Text := QBGrid.Rows[cRow4].Text;

                //put the old data back
                QBGrid.Rows[cRow1] := Row1;
                QBGrid.Rows[cRow2] := Row2;
                QBGrid.Rows[cRow3] := Row4;

                //mod the grid
                QBGrid.RowCount := 3;
                QBGrid.Cells[0, cRow1] := 'Field';
                QBGrid.Cells[0, cRow2] := 'Table';
                QBGrid.Cells[0, cRow3] := 'Criteria';
              end;
          end;
          CurrentQueryType := 2;
				end;
      3 :  //insert
        begin
          pnlExtraQueryData.Visible := True;
          FillTableNames;
          lblQueryPrompt.Caption := 'Insert Into Table:';
          case CurrentQueryType of
            0 : //from select
              begin
                //save the old data
                Row1.Text := QBGrid.Rows[cRow1].Text;
                Row2.Text := QBGrid.Rows[cRow2].Text;
                Row3.Text := QBGrid.Rows[cRow3].Text;
                Row4.Text := QBGrid.Rows[cRow4].Text;
                Row5.Text := QBGrid.Rows[cRow5].Text;
                Row6.Text := QBGrid.Rows[cRow6].Text;

                //put the old data back
                QBGrid.Rows[cRow1] := Row1;
                QBGrid.Rows[cRow2] := Row2;
                QBGrid.Rows[cRow3].Text := '';
                QBGrid.Rows[cRow4] := Row6;

                //mod the grid
                QBGrid.RowCount := 4;
                QBGrid.Cells[0, cRow1] := 'Field';
                QBGrid.Cells[0, cRow2] := 'Table';
                QBGrid.Cells[0, cRow3] := 'Append To';
                QBGrid.Cells[0, cRow4] := 'Criteria';
              end;
            1 : //from update
              begin
                //save the old data
                Row1.Text := QBGrid.Rows[cRow1].Text;
                Row2.Text := QBGrid.Rows[cRow2].Text;
                Row3.Text := QBGrid.Rows[cRow3].Text;
                Row4.Text := QBGrid.Rows[cRow4].Text;

                //put the old data back
								QBGrid.Rows[cRow1] := Row1;
                QBGrid.Rows[cRow2] := Row2;
                QBGrid.Rows[cRow3].Text := '';
                QBGrid.Rows[cRow4] := Row4;

                //mod the grid
                QBGrid.RowCount := 4;
                QBGrid.Cells[0, cRow1] := 'Field';
                QBGrid.Cells[0, cRow2] := 'Table';
                QBGrid.Cells[0, cRow3] := 'Append To';
                QBGrid.Cells[0, cRow4] := 'Criteria';
              end;
            2 : //from delete
              begin
                //save the old data
                Row1.Text := QBGrid.Rows[cRow1].Text;
                Row2.Text := QBGrid.Rows[cRow2].Text;
                Row3.Text := QBGrid.Rows[cRow3].Text;

                //put the old data back
                QBGrid.Rows[cRow1] := Row1;
                QBGrid.Rows[cRow2] := Row2;
                QBGrid.Rows[cRow3].Text := '';
                QBGrid.Rows[cRow4] := Row3;

                //mod the grid
                QBGrid.RowCount := 4;
                QBGrid.Cells[0, cRow1] := 'Field';
                QBGrid.Cells[0, cRow2] := 'Table';
                QBGrid.Cells[0, cRow3] := 'Append To';
                QBGrid.Cells[0, cRow4] := 'Criteria';
              end;
            3 : //from insert
              begin
                //save the old data
                Row1.Text := QBGrid.Rows[cRow1].Text;
                Row2.Text := QBGrid.Rows[cRow2].Text;
                Row3.Text := QBGrid.Rows[cRow3].Text;
                Row4.Text := QBGrid.Rows[cRow4].Text;

                //put the old data back
                QBGrid.Rows[cRow1] := Row1;
                QBGrid.Rows[cRow2] := Row2;
                QBGrid.Rows[cRow3].Text := '';
                QBGrid.Rows[cRow4] := Row4;

                //mod the grid
                QBGrid.RowCount := 4;
                QBGrid.Cells[0, cRow1] := 'Field';
                QBGrid.Cells[0, cRow2] := 'Table';
                QBGrid.Cells[0, cRow3] := 'Append To';
                QBGrid.Cells[0, cRow4] := 'Criteria';
              end;
          end;
          CurrentQueryType := 3;
        end;
    end;
  finally
    Row1.Free;
    Row2.Free;
    Row3.Free;
    Row4.Free;
    Row5.Free;
    Row6.Free;
    Row7.Free;
    Row8.Free;
  end;
end;

procedure TQBForm.Clear1Click(Sender: TObject);
begin
  QBGrid.Cells[QBGrid.Col, QBGrid.Row] := '';
end;

procedure TQBForm.Clear2Click(Sender: TObject);
begin
  QBGrid.Cells[QBGrid.Col, QBGrid.Row] := '';
end;

procedure TQBForm.EditCriteria1Click(Sender: TObject);
begin
  QBGrid.FCriteria.edExpression.Text := QBGrid.Cells[QBGrid.Col, QBGrid.Row];
  if QBGrid.FCriteria.ShowModal = mrOK then
  begin
    QBGrid.Cells[QBGrid.Col, QBGrid.Row] := QBGrid.FCriteria.edExpression.Text;
  end;
end;

procedure TQBForm.Edit1Click(Sender: TObject);
begin
  QBGrid.FCriteria.edExpression.Text := QBGrid.Cells[QBGrid.Col, QBGrid.Row];
  if QBGrid.FCriteria.ShowModal = mrOK then
  begin
    QBGrid.Cells[QBGrid.Col, QBGrid.Row] := QBGrid.FCriteria.edExpression.Text;
  end;
end;

procedure TQBForm.Clear3Click(Sender: TObject);
begin
  QBGrid.Cells[QBGrid.Col, QBGrid.Row] := '';
end;

procedure TQBForm.Edit2Click(Sender: TObject);
begin
  if QBGrid.FAppendTo.ShowModal = mrOK then
  begin
    QBGrid.Cells[QBGrid.Col, QBGrid.Row] := 'Append To';
  end;
end;

procedure TQBForm.FillTableNames;
var
  i : Integer;

  function ExtractName(s : string) : string;
  var
    p : integer;
	begin
    Result := s;
    p := Pos('.', s);
    if p = 0 then
      Exit;
    Result := System.Copy(s, 1, p - 1);
  end;

begin
  cmbQueryTable.Items.Clear;

  with QBArea do
  begin
    for i := 0 to ControlCount - 1 do
    begin
      if Controls[i] is TQBTable then
      begin
        if (cmbQueryTable.Items.IndexOf(ExtractName(TQBTable(Controls[i]).FTableName)) = -1) then
          cmbQueryTable.Items.Add(ExtractName(TQBTable(Controls[i]).FTableName));
      end;  
    end;
  end;

  if cmbQueryTable.Items.Count > 0 then
    cmbQueryTable.ItemIndex := 0;
end;

procedure TQBForm.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
	if (Shift = [ssCtrl, ssShift]) and (Key = VK_TAB) then
		ProcessPriorTab(Pages)
	else
		if (Shift = [ssCtrl]) and (Key = VK_TAB) then
			ProcessNextTab(Pages);
end;

procedure TQBForm.btnHelpClick(Sender: TObject);
begin
  Application.HelpCommand(HELP_CONTEXT, IDH_Query_Builder);
end;

end.

{
$Log: QBuilder.pas,v $
Revision 1.5  2006/10/22 06:04:28  rjmills
Fixes and Updates for Look and Feel in WinXP

Revision 1.4  2005/04/13 16:04:30  rjmills
*** empty log message ***

Revision 1.3  2002/09/23 10:31:16  tmuetze
FormOnKeyDown now works with Shift+Tab to cycle backwards through the pages

Revision 1.2  2002/04/25 07:21:30  tmuetze
New CVS powered comment block

}
