unit InterbaseExplainPlan;

interface

uses
  Classes;

type
  TPlanNodeType = (pntOperation, pntRelation);

  TInterbasePlanObject = class(TObject)
  private
    FCaption : String;
    FImageIndex : Integer;
    FItemList: TStringList;
    FNodeType: TPlanNodeType;
    FAccessType: String;
  public
    //
    property Caption : String read FCaption write FCaption;
    property ImageIndex : Integer read FImageIndex write FImageIndex;
    property ItemList : TStringList read FItemList write FItemList;
    property NodeType : TPlanNodeType read FNodeType write FNodeType;
    property AccessType : String read FAccessType write FAccessType;
    constructor Create;
    destructor Destroy; override;
  end;

implementation


{ TInterbasePlanObject }

constructor TInterbasePlanObject.Create;
begin
  inherited Create;
  FItemList := TStringList.Create;
end;

destructor TInterbasePlanObject.Destroy;
begin
  FItemList.Free;
  inherited;
end;

end.
