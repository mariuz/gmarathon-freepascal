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
// $Id: WindowLists.pas,v 1.4 2005/06/29 22:29:52 hippoman Exp $

//Comment block moved to remove compiler warning. RJM

{
$Log: WindowLists.pas,v $
Revision 1.4  2005/06/29 22:29:52  hippoman
* d6 related things, using D6_OR_HIGHER everywhere

Revision 1.3  2005/04/13 16:04:32  rjmills
*** empty log message ***

Revision 1.2  2002/04/25 07:21:30  tmuetze
New CVS powered comment block

}


{$I compilerdefines.inc}

unit WindowLists;

interface

uses
	Windows, SysUtils, Classes,
	MarathonProjectCacheTypes;

type
	// TWindowListItem
	//
	// Collection item class to hold a window and store its position and size
	//

  TWindowListItem = class(TCollectionItem)
  private
    { Private declarations }
    FIsMaximised: Boolean;
    FPositionTop: Integer;
    FPositionLeft: Integer;
    FSizeWidth: Integer;
    FSizeHeight: Integer;
    FWindowType: TGSSCacheType;
    FObject: String;
    FConnectionName: String;
  protected
    { Protected declarations }
  public
    { Public declarations }
  published
    { Published declarations }
    property PositionLeft : Integer read FPositionLeft write FPositionLeft;
    property PositionTop : Integer read FPositionTop write FPositionTop;
    property SizeWidth : Integer read FSizeWidth write FSizeWidth;
    property SizeHeight : Integer read FSizeHeight write FSizeHeight;
    property IsMaximised : Boolean read FIsMaximised write FIsMaximised;
    property WindowType : TGSSCacheType read FWindowType write FWindowType;
    property ObjectName : String read FObject write FObject;
    property ConnectionName : String read FConnectionName write FConnectionName;
  end;

  // TWindowList
  //
  // Collection class to hold TWindowListItem
  //
  TWindowList = class(TCollection)
  private
    {$ifndef D7_or_higher}
    //Defines added to remove D7 compiler warnings...
    FOwner : TComponent;
    function GetOwner: TComponent; reintroduce;
    {$endif}
    { Private declarations }
    function GetItem(Index : Integer) : TWindowListItem;
    procedure SetItem(Index : Integer; Value : TWindowListItem);
	protected
		{ Protected declarations }
	public
		{ Public declarations }
		constructor Create(AOwner : TComponent);
		function Add : TWindowListItem;
		property Items[Index : Integer] : TWindowListItem read GetItem write SetItem; default;
	published
		{ Published declarations }
	end;

implementation

{ TWindowList }

constructor TWindowList.Create(AOwner : TComponent);
begin
  inherited Create(TWindowListItem);
  {$ifndef d7_or_higher}
  FOwner := AOwner;
  {$endif}
end;

function TWindowList.GetItem(Index : Integer) : TWindowListItem;
begin
  Result := TWindowListItem(inherited GetItem(Index));
end;

procedure TWindowList.SetItem(Index : Integer; Value : TWindowListItem);
begin
  inherited SetItem(Index, Value);
end;

function TWindowList.Add : TWindowListItem;
begin
  Result := TWindowListItem(inherited Add);
end;

{$ifndef d7_or_higher}
function TWindowList.GetOwner: TComponent;
begin
  Result := FOwner;
end;
{$endif}

end.


