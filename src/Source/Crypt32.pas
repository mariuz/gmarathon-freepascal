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
// $Id: Crypt32.pas,v 1.2 2002/04/25 07:21:29 tmuetze Exp $

unit Crypt32;

{$MODE Delphi}

{
*************************************************************************
* Name:	Crypt32.Pas                                                     *
* Description:	32 bits encode/decode module                            *
*               2^96 variants it is very high to try hack               *
* Purpose:      Good for encrypting passwors and text                   *
* Security:     avoid use StartKey less than 256                        *
*               if it use only for internal use you may use default     *
*               key, but MODIFY unit before compiling                   *
* Call:         Encrypted := Encrypt(InString,StartKey,MultKey,AddKey)  *
*               Decrypted := Decrypt(InString,StartKey)	                *
* Parameters:   InString = long string (max 2 GB) that need to encrypt  *
*               decrypt                                                 *
*               MultKey  = MultKey key                                  *
*               AddKey   = Second key                                   *
*               StartKey = Third key                                    *
*************************************************************************
}
interface

uses SysUtils;

const
  E_START_KEY   = 967;  	{Start default key}
  E_MULT_KEY	= 12679;	{Mult default key}
  E_ADD_KEY     = 35896;	{Add default key}

function Encrypt(const InString:string; StartKey, MultKey, AddKey:Integer): string;
function Decrypt(const InString:string; StartKey, MultKey, AddKey:Integer): string;

{ As Encrypt/Decrypt, but with the ciphertext carried as hex.

  The cipher's output is arbitrary bytes: Encrypt('masterkey') contains $15 and
  $04, and XML forbids those characters outright, so writing the raw ciphertext
  into an attribute made saving the whole project fail with "Illegal
  character". Hex is the smallest change that keeps the stored form printable -
  it is not extra protection, and this cipher offers very little to begin with. }
function EncryptToHex(const InString:string; StartKey, MultKey, AddKey:Integer): string;

{ Returns an empty string when InString is not valid hex, so a value written by
  an older build - raw ciphertext - is rejected rather than decoded into
  nonsense. Callers fall back to the legacy attribute in that case. }
function DecryptFromHex(const InString:string; StartKey, MultKey, AddKey:Integer): string;

implementation

{$R-}
{$Q-}
{*******************************************************
 * Standard Encryption algorithm - Copied from Borland *
 *******************************************************}
function EncryptToHex(const InString:string; StartKey, MultKey, AddKey:Integer): string;
var
  Raw: String;
  Idx: Integer;
begin
  Raw := Encrypt(InString, StartKey, MultKey, AddKey);
  Result := '';
  for Idx := 1 to Length(Raw) do
    Result := Result + IntToHex(Byte(Raw[Idx]), 2);
end;

function DecryptFromHex(const InString:string; StartKey, MultKey, AddKey:Integer): string;
var
  Raw: String;
  Idx, Value: Integer;
begin
  Result := '';
  if (InString = '') or (Length(InString) mod 2 <> 0) then
    Exit;
  Raw := '';
  Idx := 1;
  while Idx < Length(InString) do
  begin
    if not TryStrToInt('$' + Copy(InString, Idx, 2), Value) then
      Exit;
    Raw := Raw + Chr(Value);
    Inc(Idx, 2);
  end;
  Result := Decrypt(Raw, StartKey, MultKey, AddKey);
end;

function Encrypt(const InString:string; StartKey,MultKey,AddKey:Integer): string;
var
  I : Byte;
begin
  Result := '';
  for I := 1 to Length(InString) do
  begin
    Result := Result + CHAR(Byte(InString[I]) xor (StartKey shr 8));
    StartKey := (Byte(Result[I]) + StartKey) * MultKey + AddKey;
  end;
end;
{*******************************************************
 * Standard Decryption algorithm - Copied from Borland *
 *******************************************************}
function Decrypt(const InString:string; StartKey,MultKey,AddKey:Integer): string;
var
  I : Byte;
begin
  Result := '';
  for I := 1 to Length(InString) do
  begin
    Result := Result + CHAR(Byte(InString[I]) xor (StartKey shr 8));
    StartKey := (Byte(InString[I]) + StartKey) * MultKey + AddKey;
  end;
end;
{$R+}
{$Q+}

end.

{
$Log: Crypt32.pas,v $
Revision 1.2  2002/04/25 07:21:29  tmuetze
New CVS powered comment block

}
