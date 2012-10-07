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
// $Id: DebugBreakPoints.pas,v 1.2 2002/04/25 07:21:29 tmuetze Exp $

unit DebugBreakPoints;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ComCtrls;

type
  TfrmDebugBreakPoints = class(TForm)
    lvBreakPoints: TListView;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

{$R *.DFM}

procedure TfrmDebugBreakPoints.FormClose(Sender: TObject;  var Action: TCloseAction);
begin
  Action := caFree;
end;

end.

{
$Log: DebugBreakPoints.pas,v $
Revision 1.2  2002/04/25 07:21:29  tmuetze
New CVS powered comment block

}
