unit FastcodeAnsiStringReplaceUnit;

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
 * John O'Harrow <john@elmcrest.demon.co.uk>
 *
 * BV Version: 1.68
 * ***** END LICENSE BLOCK ***** *)

interface

{$I Fastcode.inc}

uses
  SysUtils, AnsiStringReplaceJOHIA32Unit12, AnsiStringReplaceJOHIA32Unit13,
  AnsiStringReplaceJOHPASUnit12;

type
  FastcodeAnsiStringReplaceFunction = function(
    const S, OldPattern, NewPattern: AnsiString; Flags: TReplaceFlags): AnsiString;

{Functions shared between Targets}

{Functions not shared between Targets}

{Functions}

const
  FastcodeAnsiStringReplaceP4R: FastcodeAnsiStringReplaceFunction = StringReplace_JOH_IA32_13;
  FastcodeAnsiStringReplaceP4N: FastcodeAnsiStringReplaceFunction = StringReplace_JOH_IA32_12;
  FastcodeAnsiStringReplacePMY: FastcodeAnsiStringReplaceFunction = StringReplace_JOH_IA32_13;
  FastcodeAnsiStringReplacePMD: FastcodeAnsiStringReplaceFunction = StringReplace_JOH_IA32_13;
  FastcodeAnsiStringReplaceAMD64: FastcodeAnsiStringReplaceFunction = StringReplace_JOH_IA32_13;
  FastcodeAnsiStringReplaceAMD64_SSE3: FastcodeAnsiStringReplaceFunction = StringReplace_JOH_IA32_13;
  FastCodeAnsiStringReplaceIA32SizePenalty: FastCodeAnsiStringReplaceFunction = StringReplace_JOH_IA32_13;
  FastcodeAnsiStringReplaceIA32: FastcodeAnsiStringReplaceFunction = StringReplace_JOH_IA32_13;
  FastcodeAnsiStringReplaceMMX: FastcodeAnsiStringReplaceFunction = StringReplace_JOH_IA32_13;
  FastCodeAnsiStringReplaceSSESizePenalty: FastCodeAnsiStringReplaceFunction = StringReplace_JOH_IA32_13;
  FastcodeAnsiStringReplaceSSE: FastcodeAnsiStringReplaceFunction = StringReplace_JOH_IA32_13;
  FastcodeAnsiStringReplaceSSE2: FastcodeAnsiStringReplaceFunction = StringReplace_JOH_IA32_13;
  FastCodeAnsiStringReplacePascalSizePenalty: FastCodeAnsiStringReplaceFunction = StringReplace_JOH_PAS_12;
  FastCodeAnsiStringReplacePascal: FastCodeAnsiStringReplaceFunction = StringReplace_JOH_PAS_12;

procedure AnsiStringReplaceStub;

implementation

procedure AnsiStringReplaceStub;
asm
  call SysUtils.StringReplace;
end;

end.
