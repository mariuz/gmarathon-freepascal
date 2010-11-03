unit FastcodeStrToInt32Unit;

(* ***** BEGIN LICENSE BLOCK *****
 * Version: MPL 1.1
 *
 * The contents of this file are subject to the Mozilla Public License Version
 * 1.1 (the "License"); you may not use this file except in compliance with
 * the License. You may obtain a copy of the License at
 * http://www.mozilla.org/MPL/
 *
 * Software distributed under the License is distributed on an "AS IS" basis,
 * WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
 * for the specific language governing rights and limitations under the
 * License.
 *
 * The Original Code is Fastcode
 *
 * The Initial Developer of the Original Code is Fastcode
 *
 * Portions created by the Initial Developer are Copyright (C) 2002-2005
 * the Initial Developer. All Rights Reserved.
 *
 * Contributor(s):
 * Charalabos Michael <chmichael@creationpower.com>
 * Dennis Kjaer Christensen <marianndkc@home3.gvdnet.dk>
 * John O'Harrow <john@elmcrest.demon.co.uk>
 *
 * BV Version: 1.03
 * ***** END LICENSE BLOCK ***** *)

interface

{$I Fastcode.inc}

uses
  SysUtils;

type
  FastcodeStrToInt32Function = function(const S: string): Integer;

{Functions shared between Targets}
function StrToInt32_DKC_IA32_13(const S: string): Integer;
function StrToInt32_DKC_IA32_8(const S: string): Integer;
function StrToInt32_DKC_IA32_15(const S: string): Integer;

{Functions not shared between Targets}
function StrToInt32_DKC_IA32_14(const S: string): Integer;
function StrToInt32_DKC_IA32_9(const S: string): Integer;

{Functions}

const
  FastcodeStrToInt32P4R: FastcodeStrToInt32Function = StrToInt32_DKC_IA32_14;
  FastcodeStrToInt32P4N: FastcodeStrToInt32Function = StrToInt32_DKC_IA32_13;
  FastcodeStrToInt32PMY: FastcodeStrToInt32Function = StrToInt32_DKC_IA32_8;
  FastcodeStrToInt32PMD: FastcodeStrToInt32Function = StrToInt32_DKC_IA32_8;
  FastcodeStrToInt32AMD64: FastcodeStrToInt32Function = StrToInt32_DKC_IA32_13;
  FastcodeStrToInt32AMD64_SSE3: FastcodeStrToInt32Function = StrToInt32_DKC_IA32_9;
  FastcodeStrToInt32IA32SizePenalty: FastcodeStrToInt32Function = StrToInt;
  FastcodeStrToInt32IA32: FastcodeStrToInt32Function = StrToInt32_DKC_IA32_15;
  FastcodeStrToInt32MMX: FastcodeStrToInt32Function = StrToInt32_DKC_IA32_15;
  FastcodeStrToInt32SSESizePenalty: FastcodeStrToInt32Function = StrToInt;
  FastcodeStrToInt32SSE: FastcodeStrToInt32Function = StrToInt32_DKC_IA32_15;
  FastcodeStrToInt32SSE2: FastcodeStrToInt32Function = StrToInt32_DKC_IA32_15;
  FastcodeStrToInt32PascalSizePenalty: FastcodeStrToInt32Function = StrToInt;
  FastcodeStrToInt32Pascal: FastcodeStrToInt32Function = StrToInt;

function StrToInt32Stub(const S: string): Integer;

implementation

uses
  SysConst;

procedure ConvertErrorFmt(ResString: PResStringRec; const Args: array of const); local;
begin
  raise EConvertError.CreateResFmt(ResString, Args);
end;

procedure RaiseConvertError(S : AnsiString);
begin
  ConvertErrorFmt(@SInvalidInteger, [S]);
end;

function StrToInt32_DKC_IA32_14(const S: string): Integer;
asm
   push  esi
   push  ebx
   push  edi
   mov   edx,eax
   test  eax,eax
   je    @Error
   mov   esi,eax
   xor   eax,eax
   mov   edi,07FFFFFFFH / 10     // limit
 @blankLoop:
   movzx ebx,byte ptr [esi]
   add   esi,1
   cmp   bl,' '
   je    @BlankLoop
   xor   ecx,ecx
   cmp   bl,'-'
   je    @Minus
   cmp   bl,'+'
   je    @Plus
 @CheckDollar:
   cmp   bl,'$'
   je    @Dollar
   cmp   bl,'x'
   je    @Dollar
   cmp   bl,'X'
   je    @Dollar
   cmp   bl,'0'
   jne   @FirstDigit
   movzx ebx,byte ptr [esi]
   add   esi,1
   cmp   bl,'x'
   je    @Dollar
   cmp   bl,'X'
   je    @dollar
   test  ebx,ebx
   je    @EndDigits
   jmp   @DigLoop
 @FirstDigit:
   test  ebx,ebx
   je    @Error
 @PreDigitLoop:
   sub   bl,'0'
   cmp   bl,9
   ja    @Error
   mov   eax,ebx
   movzx ebx, byte ptr [esi]
   add   esi,1
   test  ebx,ebx
   je    @EndDigits
   sub   bl,'0'
   cmp   bl,9
   ja    @Error
   lea   eax,[eax+eax*4]
   add   eax,eax
   add   eax,ebx         // fortunately, we can't have a carry
   movzx ebx, byte ptr [esi]
   add   esi,1
   test  ebx,ebx
   je    @EndDigits
   sub   bl,'0'
   cmp   bl,9
   ja    @Error
   lea   eax,[eax+eax*4]
   add   eax,eax
   add   eax,ebx         // fortunately, we can't have a carry
   movzx ebx, byte ptr [esi]
   add   esi,1
   test  ebx,ebx
   je    @EndDigits
   sub   bl,'0'
   cmp   bl,9
   ja    @Error
   lea   eax,[eax+eax*4]
   add   eax,eax
   add   eax,ebx         // fortunately, we can't have a carry
   movzx ebx, byte ptr [esi]
   add   esi,1
   test  ebx,ebx
   je    @EndDigits
   sub   bl,'0'
   cmp   bl,9
   ja    @Error
   lea   eax,[eax+eax*4]
   add   eax,eax
   add   eax,ebx         // fortunately, we can't have a carry
   movzx ebx, byte ptr [esi]
   add   esi,1
   test  ebx,ebx
   je    @EndDigits
   sub   bl,'0'
   cmp   bl,9
   ja    @Error
   lea   eax,[eax+eax*4]
   add   eax,eax
   add   eax,ebx         // fortunately, we can't have a carry
   movzx ebx, byte ptr [esi]
   add   esi,1
   test  ebx,ebx
   je    @EndDigits
   sub   bl,'0'
   cmp   bl,9
   ja    @Error
   lea   eax,[eax+eax*4]
   add   eax,eax
   add   eax,ebx         // fortunately, we can't have a carry
   movzx ebx, byte ptr [esi]
   add   esi,1
   test  ebx,ebx
   je    @EndDigits
   sub   bl,'0'
   cmp   bl,9
   ja    @Error
   lea   eax,[eax+eax*4]
   add   eax,eax
   add   eax,ebx         // fortunately, we can't have a carry
   movzx ebx, byte ptr [esi]
   add   esi,1
   test  ebx,ebx
   je    @EndDigits
 @digLoop:
   sub   bl,'0'
   cmp   bl,9
   ja    @Error
   cmp   eax,edi         // value > limit ?
   ja    @OverFlow
   lea   eax,[eax+eax*4]
   add   eax,eax
   add   eax,ebx         // fortunately, we can't have a carry
   movzx ebx, byte ptr [esi]
   add   esi,1
   test  ebx,ebx
   jne   @DigLoop
 @EndDigits:
   sub   ch,1
   je    @Negate
   test  eax,eax
   jge   @SuccessExit
   jmp   @OverFlow
 @negate:
   neg   eax
   jle   @SuccessExit
   js    @SuccessExit           // to handle 2**31 correctly, where the negate overflows
 @Error :
 @OverFlow :
   mov   eax,edx
   call  RaiseConvertError
 @minus:
   add   ch,1
 @plus:
   movzx ebx,byte ptr [esi]
   add   esi,1
   jmp   @CheckDollar
 @dollar:
   mov   edi,0FFFFFFFH
   movzx ebx,byte ptr [esi]
   add   esi,1
   test  ebx,ebx
   jz    @Error
 @HexDigLoop:
   cmp   bl,'a'
   jb    @Upper
   sub   bl,'a' - 'A'
 @upper:
   sub   bl,'0'
   cmp   bl,9
   jbe   @DigOk
   sub   bl,'A' - '0'
   cmp   bl,5
   ja    @Error
   add   bl,10
 @digOk:
   cmp   eax,edi
   ja    @OverFlow
   shl   eax,4
   add   eax,ebx
   movzx ebx, byte ptr [esi]
   add   esi,1
   test  ebx,ebx
   jne   @HexDigLoop
   dec   ch
   jne   @SuccessExit
   neg   eax
 @successExit:
   pop   edi
   pop   ebx
   pop   esi
end;

function StrToInt32_DKC_IA32_13(const S: string): Integer;
asm
   push  esi
   push  ebx
   push  edi
   mov   edx,eax
   test  eax,eax
   je    @Error
   mov   esi,eax
   xor   eax,eax
   mov   edi,07FFFFFFFH / 10     // limit
 @blankLoop:
   movzx ebx,byte ptr [esi]
   add   esi,1
   cmp   bl,' '
   je    @BlankLoop
   xor   ecx,ecx
   cmp   bl,'-'
   je    @Minus
   cmp   bl,'+'
   je    @Plus
 @CheckDollar:
   cmp   bl,'$'
   je    @Dollar
   cmp   bl,'x'
   je    @Dollar
   cmp   bl,'X'
   je    @Dollar
   cmp   bl,'0'
   jne   @FirstDigit
   movzx ebx,byte ptr [esi]
   add   esi,1
   cmp   bl,'x'
   je    @Dollar
   cmp   bl,'X'
   je    @dollar
   test  ebx,ebx
   je    @EndDigits
   jmp   @DigLoop
 @FirstDigit:
   test  ebx,ebx
   je    @Error
 @PreDigitLoop:
   sub   bl,'0'
   cmp   bl,9
   ja    @Error
   mov   eax,ebx
   movzx ebx, byte ptr [esi]
   add   esi,1
   test  ebx,ebx
   je    @EndDigits
   sub   bl,'0'
   cmp   bl,9
   ja    @Error
   lea   eax,[eax+eax*4]
   add   eax,eax
   add   eax,ebx         // fortunately, we can't have a carry
   movzx ebx, byte ptr [esi]
   add   esi,1
   test  ebx,ebx
   je    @EndDigits
   sub   bl,'0'
   cmp   bl,9
   ja    @Error
   lea   eax,[eax+eax*4]
   add   eax,eax
   add   eax,ebx         // fortunately, we can't have a carry
   movzx ebx, byte ptr [esi]
   add   esi,1
   test  ebx,ebx
   je    @EndDigits
   sub   bl,'0'
   cmp   bl,9
   ja    @Error
   lea   eax,[eax+eax*4]
   add   eax,eax
   add   eax,ebx         // fortunately, we can't have a carry
   movzx ebx, byte ptr [esi]
   add   esi,1
   test  ebx,ebx
   je    @EndDigits
   sub   bl,'0'
   cmp   bl,9
   ja    @Error
   lea   eax,[eax+eax*4]
   add   eax,eax
   add   eax,ebx         // fortunately, we can't have a carry
   movzx ebx, byte ptr [esi]
   add   esi,1
   test  ebx,ebx
   je    @EndDigits
   sub   bl,'0'
   cmp   bl,9
   ja    @Error
   lea   eax,[eax+eax*4]
   add   eax,eax
   add   eax,ebx         // fortunately, we can't have a carry
   movzx ebx, byte ptr [esi]
   add   esi,1
   test  ebx,ebx
   je    @EndDigits
   sub   bl,'0'
   cmp   bl,9
   ja    @Error
   lea   eax,[eax+eax*4]
   add   eax,eax
   add   eax,ebx         // fortunately, we can't have a carry
   movzx ebx, byte ptr [esi]
   add   esi,1
   test  ebx,ebx
   je    @EndDigits
 @digLoop:
   sub   bl,'0'
   cmp   bl,9
   ja    @Error
   cmp   eax,edi         // value > limit ?
   ja    @OverFlow
   lea   eax,[eax+eax*4]
   add   eax,eax
   add   eax,ebx         // fortunately, we can't have a carry
   movzx ebx, byte ptr [esi]
   add   esi,1
   test  ebx,ebx
   jne   @DigLoop
 @EndDigits:
   sub   ch,1
   je    @Negate
   test  eax,eax
   jge   @SuccessExit
   jmp   @OverFlow
 @negate:
   neg   eax
   jle   @SuccessExit
   js    @SuccessExit           // to handle 2**31 correctly, where the negate overflows
 @Error :
 @OverFlow :
   mov   eax,edx
   call  RaiseConvertError
 @minus:
   add   ch,1
 @plus:
   movzx ebx,byte ptr [esi]
   add   esi,1
   jmp   @CheckDollar
 @dollar:
   mov   edi,0FFFFFFFH
   movzx ebx,byte ptr [esi]
   add   esi,1
   test  ebx,ebx
   jz    @Error
 @HexDigLoop:
   cmp   bl,'a'
   jb    @Upper
   sub   bl,'a' - 'A'
 @upper:
   sub   bl,'0'
   cmp   bl,9
   jbe   @DigOk
   sub   bl,'A' - '0'
   cmp   bl,5
   ja    @Error
   add   bl,10
 @digOk:
   cmp   eax,edi
   ja    @OverFlow
   shl   eax,4
   add   eax,ebx
   movzx ebx, byte ptr [esi]
   add   esi,1
   test  ebx,ebx
   jne   @HexDigLoop
   dec   ch
   jne   @SuccessExit
   neg   eax
 @successExit:
   pop   edi
   pop   ebx
   pop   esi
end;

function StrToInt32_DKC_IA32_8(const S: string): Integer;
asm
   push  esi
   push  ebx
   push  edi
   mov   edx,eax
   test  eax,eax
   je    @Error
   mov   esi,eax
   xor   eax,eax
   mov   edi,07FFFFFFFH / 10     // limit
 @blankLoop:
   movzx ebx,byte ptr [esi]
   add   esi,1
   cmp   bl,' '
   je    @BlankLoop
   xor   ecx,ecx
   cmp   bl,'-'
   je    @Minus
   cmp   bl,'+'
   je    @Plus
 @CheckDollar:
   cmp   bl,'$'
   je    @Dollar
   cmp   bl,'x'
   je    @Dollar
   cmp   bl,'X'
   je    @Dollar
   cmp   bl,'0'
   jne   @FirstDigit
   movzx ebx,byte ptr [esi]
   add   esi,1
   cmp   bl,'x'
   je    @Dollar
   cmp   bl,'X'
   je    @dollar
   test  ebx,ebx
   je    @EndDigits
   jmp   @DigLoop
 @FirstDigit:
   test  ebx,ebx
   je    @Error
 @PreDigitLoop:
   sub   bl,'0'
   cmp   bl,9
   ja    @Error
   lea   eax,[eax+eax*4]
   add   eax,eax
   add   eax,ebx         // fortunately, we can't have a carry
   movzx ebx, byte ptr [esi]
   add   esi,1
   test  ebx,ebx
   je    @EndDigits
   sub   bl,'0'
   cmp   bl,9
   ja    @Error
   lea   eax,[eax+eax*4]
   add   eax,eax
   add   eax,ebx         // fortunately, we can't have a carry
   movzx ebx, byte ptr [esi]
   add   esi,1
   test  ebx,ebx
   je    @EndDigits
 @digLoop:
   sub   bl,'0'
   cmp   bl,9
   ja    @Error
   cmp   eax,edi         // value > limit ?
   ja    @OverFlow
   lea   eax,[eax+eax*4]
   add   eax,eax
   add   eax,ebx         // fortunately, we can't have a carry
   movzx ebx, byte ptr [esi]
   add   esi,1
   test  ebx,ebx
   jne   @DigLoop
 @EndDigits:
   sub   ch,1
   je    @Negate
   test  eax,eax
   jge   @SuccessExit
   jmp   @OverFlow
 @negate:
   neg   eax
   jle   @SuccessExit
   js    @SuccessExit           // to handle 2**31 correctly, where the negate overflows
 @Error :
 @OverFlow :
   mov   eax,edx
   call  RaiseConvertError
 @minus:
   add   ch,1
 @plus:
   movzx ebx,byte ptr [esi]
   add   esi,1
   jmp   @CheckDollar
 @dollar:
   mov   edi,0FFFFFFFH
   movzx ebx,byte ptr [esi]
   add   esi,1
   test  ebx,ebx
   jz    @Error
 @HexDigLoop:
   cmp   bl,'a'
   jb    @Upper
   sub   bl,'a' - 'A'
 @upper:
   sub   bl,'0'
   cmp   bl,9
   jbe   @DigOk
   sub   bl,'A' - '0'
   cmp   bl,5
   ja    @Error
   add   bl,10
 @digOk:
   cmp   eax,edi
   ja    @OverFlow
   shl   eax,4
   add   eax,ebx
   movzx ebx, byte ptr [esi]
   add   esi,1
   test  ebx,ebx
   jne   @HexDigLoop
   dec   ch
   jne   @SuccessExit
   neg   eax
 @successExit:
   pop   edi
   pop   ebx
   pop   esi
end;

function StrToInt32_DKC_IA32_9(const S: string): Integer;
asm
   push  esi
   push  ebx
   push  edi
   mov   edx,eax
   test  eax,eax
   je    @Error
   mov   esi,eax
   xor   eax,eax
   mov   edi,07FFFFFFFH / 10     // limit
 @blankLoop:
   movzx ebx,byte ptr [esi]
   add   esi,1
   cmp   bl,' '
   je    @BlankLoop
   xor   ecx,ecx
   cmp   bl,'-'
   je    @Minus
   cmp   bl,'+'
   je    @Plus
 @CheckDollar:
   cmp   bl,'$'
   je    @Dollar
   cmp   bl,'x'
   je    @Dollar
   cmp   bl,'X'
   je    @Dollar
   cmp   bl,'0'
   jne   @FirstDigit
   movzx ebx,byte ptr [esi]
   add   esi,1
   cmp   bl,'x'
   je    @Dollar
   cmp   bl,'X'
   je    @dollar
   test  ebx,ebx
   je    @EndDigits
   jmp   @DigLoop
 @FirstDigit:
   test  ebx,ebx
   je    @Error
 @PreDigitLoop:
   sub   bl,'0'
   cmp   bl,9
   ja    @Error
   lea   eax,[eax+eax*4]
   add   eax,eax
   add   eax,ebx         // fortunately, we can't have a carry
   movzx ebx, byte ptr [esi]
   add   esi,1
   test  ebx,ebx
   je    @EndDigits
   sub   bl,'0'
   cmp   bl,9
   ja    @Error
   lea   eax,[eax+eax*4]
   add   eax,eax
   add   eax,ebx         // fortunately, we can't have a carry
   movzx ebx, byte ptr [esi]
   add   esi,1
   test  ebx,ebx
   je    @EndDigits
   sub   bl,'0'
   cmp   bl,9
   ja    @Error
   lea   eax,[eax+eax*4]
   add   eax,eax
   add   eax,ebx         // fortunately, we can't have a carry
   movzx ebx, byte ptr [esi]
   add   esi,1
   test  ebx,ebx
   je    @EndDigits
 @digLoop:
   sub   bl,'0'
   cmp   bl,9
   ja    @Error
   cmp   eax,edi         // value > limit ?
   ja    @OverFlow
   lea   eax,[eax+eax*4]
   add   eax,eax
   add   eax,ebx         // fortunately, we can't have a carry
   movzx ebx, byte ptr [esi]
   add   esi,1
   test  ebx,ebx
   jne   @DigLoop
 @EndDigits:
   sub   ch,1
   je    @Negate
   test  eax,eax
   jge   @SuccessExit
   jmp   @OverFlow
 @negate:
   neg   eax
   jle   @SuccessExit
   js    @SuccessExit           // to handle 2**31 correctly, where the negate overflows
 @Error :
 @OverFlow :
   mov   eax,edx
   call  RaiseConvertError
 @minus:
   add   ch,1
 @plus:
   movzx ebx,byte ptr [esi]
   add   esi,1
   jmp   @CheckDollar
 @dollar:
   mov   edi,0FFFFFFFH
   movzx ebx,byte ptr [esi]
   add   esi,1
   test  ebx,ebx
   jz    @Error
 @HexDigLoop:
   cmp   bl,'a'
   jb    @Upper
   sub   bl,'a' - 'A'
 @upper:
   sub   bl,'0'
   cmp   bl,9
   jbe   @DigOk
   sub   bl,'A' - '0'
   cmp   bl,5
   ja    @Error
   add   bl,10
 @digOk:
   cmp   eax,edi
   ja    @OverFlow
   shl   eax,4
   add   eax,ebx
   movzx ebx, byte ptr [esi]
   add   esi,1
   test  ebx,ebx
   jne   @HexDigLoop
   dec   ch
   jne   @SuccessExit
   neg   eax
 @successExit:
   pop   edi
   pop   ebx
   pop   esi
end;

function StrToInt32_DKC_IA32_15(const S: string): Integer;
asm
   push  esi
   push  ebx
   push  edi
   mov   edx,eax
   test  eax,eax
   je    @Error
   mov   esi,eax
   xor   eax,eax
   mov   edi,07FFFFFFFH / 10     // limit
 @blankLoop:
   movzx ebx,byte ptr [esi]
   add   esi,1
   cmp   bl,' '
   je    @BlankLoop
   xor   ecx,ecx
   cmp   bl,'-'
   je    @Minus
   cmp   bl,'+'
   je    @Plus
 @CheckDollar:
   cmp   bl,'$'
   je    @Dollar
   cmp   bl,'x'
   je    @Dollar
   cmp   bl,'X'
   je    @Dollar
   cmp   bl,'0'
   jne   @FirstDigit
   movzx ebx,byte ptr [esi]
   add   esi,1
   cmp   bl,'x'
   je    @Dollar
   cmp   bl,'X'
   je    @dollar
   test  ebx,ebx
   je    @EndDigits
   jmp   @DigLoop
 @FirstDigit:
   test  ebx,ebx
   je    @Error
 @PreDigitLoop:
   sub   bl,'0'
   cmp   bl,9
   ja    @Error
   mov   eax,ebx
   movzx ebx, byte ptr [esi]
   add   esi,1
   test  ebx,ebx
   je    @EndDigits
   sub   bl,'0'
   cmp   bl,9
   ja    @Error
   lea   eax,[eax+eax*4]
   add   eax,eax
   add   eax,ebx         // fortunately, we can't have a carry
   movzx ebx, byte ptr [esi]
   add   esi,1
   test  ebx,ebx
   je    @EndDigits
   sub   bl,'0'
   cmp   bl,9
   ja    @Error
   lea   eax,[eax+eax*4]
   add   eax,eax
   add   eax,ebx         // fortunately, we can't have a carry
   movzx ebx, byte ptr [esi]
   add   esi,1
   test  ebx,ebx
   je    @EndDigits
   sub   bl,'0'
   cmp   bl,9
   ja    @Error
   lea   eax,[eax+eax*4]
   add   eax,eax
   add   eax,ebx         // fortunately, we can't have a carry
   movzx ebx, byte ptr [esi]
   add   esi,1
   test  ebx,ebx
   je    @EndDigits
   sub   bl,'0'
   cmp   bl,9
   ja    @Error
   lea   eax,[eax+eax*4]
   add   eax,eax
   add   eax,ebx         // fortunately, we can't have a carry
   movzx ebx, byte ptr [esi]
   add   esi,1
   test  ebx,ebx
   je    @EndDigits
   sub   bl,'0'
   cmp   bl,9
   ja    @Error
   lea   eax,[eax+eax*4]
   add   eax,eax
   add   eax,ebx         // fortunately, we can't have a carry
   movzx ebx, byte ptr [esi]
   add   esi,1
   test  ebx,ebx
   je    @EndDigits
   sub   bl,'0'
   cmp   bl,9
   ja    @Error
   lea   eax,[eax+eax*4]
   add   eax,eax
   add   eax,ebx         // fortunately, we can't have a carry
   movzx ebx, byte ptr [esi]
   add   esi,1
   test  ebx,ebx
   je    @EndDigits
   sub   bl,'0'
   cmp   bl,9
   ja    @Error
   lea   eax,[eax+eax*4]
   add   eax,eax
   add   eax,ebx         // fortunately, we can't have a carry
   movzx ebx, byte ptr [esi]
   add   esi,1
   test  ebx,ebx
   je    @EndDigits
   sub   bl,'0'
   cmp   bl,9
   ja    @Error
   lea   eax,[eax+eax*4]
   add   eax,eax
   add   eax,ebx         // fortunately, we can't have a carry
   movzx ebx, byte ptr [esi]
   add   esi,1
   test  ebx,ebx
   je    @EndDigits
 @digLoop:
   sub   bl,'0'
   cmp   bl,9
   ja    @Error
   cmp   eax,edi         // value > limit ?
   ja    @OverFlow
   lea   eax,[eax+eax*4]
   add   eax,eax
   add   eax,ebx         // fortunately, we can't have a carry
   movzx ebx, byte ptr [esi]
   add   esi,1
   test  ebx,ebx
   jne   @DigLoop
 @EndDigits:
   sub   ch,1
   je    @Negate
   test  eax,eax
   jge   @SuccessExit
   jmp   @OverFlow
 @negate:
   neg   eax
   jle   @SuccessExit
   js    @SuccessExit           // to handle 2**31 correctly, where the negate overflows
 @Error :
 @OverFlow :
   mov   eax,edx
   call  RaiseConvertError
 @minus:
   add   ch,1
 @plus:
   movzx ebx,byte ptr [esi]
   add   esi,1
   jmp   @CheckDollar
 @dollar:
   mov   edi,0FFFFFFFH
   movzx ebx,byte ptr [esi]
   add   esi,1
   test  ebx,ebx
   jz    @Error
 @HexDigLoop:
   cmp   bl,'a'
   jb    @Upper
   sub   bl,'a' - 'A'
 @upper:
   sub   bl,'0'
   cmp   bl,9
   jbe   @DigOk
   sub   bl,'A' - '0'
   cmp   bl,5
   ja    @Error
   add   bl,10
 @digOk:
   cmp   eax,edi
   ja    @OverFlow
   shl   eax,4
   add   eax,ebx
   movzx ebx, byte ptr [esi]
   add   esi,1
   test  ebx,ebx
   jne   @HexDigLoop
   dec   ch
   jne   @SuccessExit
   neg   eax
 @successExit:
   pop   edi
   pop   ebx
   pop   esi
end;

function StrToInt32Stub(const S: string): Integer;
asm
  call SysUtils.StrToInt;
end;

end.
