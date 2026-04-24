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

// Marathon Compiler Defines

{$IFDEF FPC}
  // Free Pascal Compiler: always treat as Delphi 6 or higher
  {$DEFINE D6_OR_HIGHER}
{$ELSE}
  {$IFDEF VER140}  // Delphi 6
    {$DEFINE D6_OR_HIGHER}
  {$ENDIF}
  {$IFDEF VER150}  // Delphi 7
    {$DEFINE D6_OR_HIGHER}
  {$ENDIF}
  {$IFDEF VER160}  // Delphi 8
    {$DEFINE D6_OR_HIGHER}
  {$ENDIF}
  {$IFDEF VER170}  // Delphi 9 / 2005
    {$DEFINE D6_OR_HIGHER}
  {$ENDIF}
  {$IFDEF VER180}  // Delphi 10 / 2006
    {$DEFINE D6_OR_HIGHER}
  {$ENDIF}
  {$IFDEF VER185}  // Delphi 2007
    {$DEFINE D6_OR_HIGHER}
  {$ENDIF}
  {$IFDEF VER190}  // Delphi 2007
    {$DEFINE D6_OR_HIGHER}
  {$ENDIF}
  {$IFDEF VER200}  // Delphi 2009
    {$DEFINE D6_OR_HIGHER}
  {$ENDIF}
  {$IFDEF VER210}  // Delphi 2010
    {$DEFINE D6_OR_HIGHER}
  {$ENDIF}
  {$IFDEF VER220}  // Delphi XE
    {$DEFINE D6_OR_HIGHER}
  {$ENDIF}
{$ENDIF}
