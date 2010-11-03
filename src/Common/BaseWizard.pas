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
// $Id: BaseWizard.pas,v 1.2 2002/04/25 07:14:47 tmuetze Exp $

unit BaseWizard;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, StdCtrls;

type
  TfrmBaseWizard = class(TForm)
    Panel1: TPanel;
    Bevel2: TBevel;
    Bevel1: TBevel;
    btnPrev: TButton;
    btnNext: TButton;
    btnClose: TButton;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

{$R *.DFM}

end.

{
$Log: BaseWizard.pas,v $
Revision 1.2  2002/04/25 07:14:47  tmuetze
New CVS powered comment block

}
