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
// $Id: Globals.pas,v 1.2 2002/04/25 07:16:24 tmuetze Exp $

unit Globals;

interface

uses
	Classes, SysUtils, Windows, IBHeader, Forms, Registry;

function ConvertFieldType(ftype, flen, fscale, fsubtype, fprecision : Integer; IsInterbase6 : Boolean) : String;
function GetDBCharSetNameByID(ID : Integer) : String;
function GetDBCharSetIndexByID(ID : Integer) : Integer;
function ParseSection (ParseLine : String; ParseNum : Integer; ParseSep : Char) : String;
function MakeQuotedIdent(S : String; IB6 : Boolean; Dialect : Integer) : String;
function StripQuotesFromQuotedIdentifier(S : String) : String;
function IsIdentifierQuoted(S : String) : Boolean;
function ShouldBeQuoted(S : String) : Boolean;
function EscapeQuotes(I : String) : String;
function NoLangFormatDateTime(const Format: string; DateTime: TDateTime): string;

procedure LoadFormPosition(F : TForm);
procedure SaveFormPosition(F : TForm);

implementation

uses
	GSSRegistry;

procedure LoadFormPosition(F : TForm);
var
  R : TRegistry;

begin
  R := TRegistry.Create;
  try
		if R.OpenKey(REG_SETTINGS_FORMS + '\' + F.ClassName, False) then
    begin
      if R.ValueExists('Top') then
        F.Top := R.ReadInteger('Top');
      if R.ValueExists('Left') then
        F.Left := R.ReadInteger('Left');
      if R.ValueExists('Width') then
        F.Width := R.ReadInteger('Width');
      if R.ValueExists('Height') then
        F.Height := R.ReadInteger('Height');
      R.CloseKey;
    end;
  finally
    R.Free;
  end;
end;

procedure SaveFormPosition(F : TForm);
var
  R : TRegistry;

begin
  R := TRegistry.Create;
  try
		if R.OpenKey(REG_SETTINGS_FORMS + '\' + F.ClassName, True) then
		begin
			R.WriteInteger('Top', F.Top);
			R.WriteInteger('Left', F.Left);
			R.WriteInteger('Width', F.Width);
			R.WriteInteger('Height', F.Height);
			R.CloseKey;
		end;
	finally
		R.Free;
	end;
end;

function EscapeQuotes(I : String) : String;
var
  Idx : Integer;

begin
  Result := '';
  for Idx := 1 to Length(I) do
  begin
    if I[Idx] = '"' then
      Result := Result + '"';

    if I[Idx] = '''' then
      Result := Result + '''';

    Result := Result + I[Idx];
  end;
end;

procedure NoLangDateTimeToString(var Result: string; const Format: string; DateTime: TDateTime);
var
  BufPos, AppendLevel: Integer;
  Buffer: array[0..255] of Char;

const
  NoLangShortMonthNames : array[1..12] of Shortstring =
                           ('JAN',
													 'FEB',
                           'MAR',
                           'APR',
                           'MAY',
                           'JUN',
                           'JUL',
                           'AUG',
                           'SEP',
                           'OCT',
                           'NOV',
                           'DEC');

  NoLangLongMonthNames : array[1..12] of Shortstring =
                           ('January',
													 'February',
                           'March',
                           'April',
                           'May',
                           'June',
                           'July',
                           'August',
                           'September',
                           'October',
                           'November',
                           'December');

  procedure AppendChars(P: PChar; Count: Integer);
  var
    N: Integer;
  begin
    N := SizeOf(Buffer) - BufPos;
    if N > Count then N := Count;
    if N <> 0 then Move(P[0], Buffer[BufPos], N);
    Inc(BufPos, N);
  end;

  procedure AppendString(const S: string);
  begin
    AppendChars(Pointer(S), Length(S));
	end;

  procedure AppendNumber(Number, Digits: Integer);
  const
    Format: array[0..3] of Char = '%.*d';
  var
    NumBuf: array[0..15] of Char;
  begin
    AppendChars(NumBuf, FormatBuf(NumBuf, SizeOf(NumBuf), Format,
      SizeOf(Format), [Digits, Number]));
  end;

  procedure AppendFormat(Format: PChar);
  var
		Starter, Token, LastToken: Char;
    DateDecoded, TimeDecoded, Use12HourClock,
    BetweenQuotes: Boolean;
    P: PChar;
    Count: Integer;
    Year, Month, Day, Hour, Min, Sec, MSec, H: Word;

    procedure GetCount;
    var
      P: PChar;
    begin
      P := Format;
      while Format^ = Starter do Inc(Format);
      Count := Format - P + 1;
    end;

    procedure GetDate;
    begin
      if not DateDecoded then
      begin
        DecodeDate(DateTime, Year, Month, Day);
        DateDecoded := True;
      end;
    end;

		procedure GetTime;
    begin
      if not TimeDecoded then
      begin
        DecodeTime(DateTime, Hour, Min, Sec, MSec);
        TimeDecoded := True;
      end;
    end;

    function ConvertEraString(const Count: Integer) : string;
    var
      FormatStr: string;
      SystemTime: TSystemTime;
      Buffer: array[Byte] of Char;
			P: PChar;
    begin
      Result := '';
      with SystemTime do
      begin
        wYear  := Year;
        wMonth := Month;
        wDay   := Day;
      end;

      FormatStr := 'gg';
      if GetDateFormat(GetThreadLocale, DATE_USE_ALT_CALENDAR, @SystemTime,
        PChar(FormatStr), Buffer, SizeOf(Buffer)) <> 0 then
      begin
        Result := Buffer;
        if Count = 1 then
        begin
          case SysLocale.PriLangID of
            LANG_JAPANESE:
              Result := Copy(Result, 1, CharToBytelen(Result, 1));
            LANG_CHINESE:
              if (SysLocale.SubLangID = SUBLANG_CHINESE_TRADITIONAL)
                and (ByteToCharLen(Result, Length(Result)) = 4) then
              begin
                P := Buffer + CharToByteIndex(Result, 3) - 1;
								SetString(Result, P, CharToByteLen(P, 2));
              end;
          end;
        end;
      end;
    end;

    function ConvertYearString(const Count: Integer): string;
    var
      FormatStr: string;
      SystemTime: TSystemTime;
      Buffer: array[Byte] of Char;
    begin
      Result := '';
			with SystemTime do
      begin
        wYear  := Year;
        wMonth := Month;
        wDay   := Day;
      end;

      if Count <= 2 then
        FormatStr := 'yy' // avoid Win95 bug.
      else
        FormatStr := 'yyyy';

      if GetDateFormat(GetThreadLocale, DATE_USE_ALT_CALENDAR, @SystemTime,
        PChar(FormatStr), Buffer, SizeOf(Buffer)) <> 0 then
      begin
        Result := Buffer;
        if (Count = 1) and (Result[1] = '0') then
          Result := Copy(Result, 2, Length(Result)-1);
      end;
    end;

  begin
    if (Format <> nil) and (AppendLevel < 2) then
    begin
      Inc(AppendLevel);
			LastToken := ' ';
      DateDecoded := False;
      TimeDecoded := False;
      Use12HourClock := False;
      while Format^ <> #0 do
      begin
        Starter := Format^;
        Inc(Format);
        if Starter in LeadBytes then
        begin
          if Format^ = #0 then Break;
          Inc(Format);
          LastToken := ' ';
          Continue;
				end;
        Token := Starter;
        if Token in ['a'..'z'] then Dec(Token, 32);
        if Token in ['A'..'Z'] then
        begin
          if (Token = 'M') and (LastToken = 'H') then Token := 'N';
          LastToken := Token;
        end;
        case Token of
          'Y':
            begin
              GetCount;
              GetDate;
              if Count <= 2 then
                AppendNumber(Year mod 100, 2) else
                AppendNumber(Year, 4);
            end;
          'G':
            begin
              GetCount;
              GetDate;
              AppendString(ConvertEraString(Count));
            end;
          'E':
            begin
							GetCount;
              GetDate;
              AppendString(ConvertYearString(Count));
            end;
          'M':
            begin
              GetCount;
              GetDate;
              case Count of
                1, 2: AppendNumber(Month, Count);
                3: AppendString(NoLangShortMonthNames[Month]);
              else
                AppendString(NoLangLongMonthNames[Month]);
              end;
						end;
          'D':
            begin
              GetCount;
              case Count of
                1, 2:
                  begin
                    GetDate;
                    AppendNumber(Day, Count);
                  end;
                3: AppendString(ShortDayNames[DayOfWeek(DateTime)]);
                4: AppendString(LongDayNames[DayOfWeek(DateTime)]);
                5: AppendFormat(Pointer(ShortDateFormat));
              else
                AppendFormat(Pointer(LongDateFormat));
              end;
            end;
          'H':
            begin
              GetCount;
              GetTime;
              BetweenQuotes := False;
              P := Format;
              while P^ <> #0 do
              begin
								if P^ in LeadBytes then
                begin
                  Inc(P);
                  if P^ = #0 then Break;
                  Inc(P);
                  Continue;
                end;
                case P^ of
                  'A', 'a':
                    if not BetweenQuotes then
                    begin
                      if ( (StrLIComp(P, 'AM/PM', 5) = 0)
                        or (StrLIComp(P, 'A/P',   3) = 0)
                        or (StrLIComp(P, 'AMPM',  4) = 0) ) then
												Use12HourClock := True;
                      Break;
                    end;
                  'H', 'h':
                    Break;
                  '''', '"': BetweenQuotes := not BetweenQuotes;
                end;
                Inc(P);
              end;
              H := Hour;
              if Use12HourClock then
                if H = 0 then H := 12 else if H > 12 then Dec(H, 12);
              if Count > 2 then Count := 2;
              AppendNumber(H, Count);
            end;
          'N':
            begin
              GetCount;
              GetTime;
              if Count > 2 then Count := 2;
              AppendNumber(Min, Count);
            end;
          'S':
            begin
              GetCount;
							GetTime;
              if Count > 2 then Count := 2;
              AppendNumber(Sec, Count);
            end;
          'T':
            begin
              GetCount;
              if Count = 1 then
                AppendFormat(Pointer(ShortTimeFormat)) else
                AppendFormat(Pointer(LongTimeFormat));
            end;
          'A':
            begin
              GetTime;
							P := Format - 1;
              if StrLIComp(P, 'AM/PM', 5) = 0 then
              begin
                if Hour >= 12 then Inc(P, 3);
                AppendChars(P, 2);
                Inc(Format, 4);
                Use12HourClock := TRUE;
              end else
              if StrLIComp(P, 'A/P', 3) = 0 then
              begin
                if Hour >= 12 then Inc(P, 2);
                AppendChars(P, 1);
                Inc(Format, 2);
                Use12HourClock := TRUE;
              end else
              if StrLIComp(P, 'AMPM', 4) = 0 then
              begin
                if Hour < 12 then
                  AppendString(TimeAMString) else
                  AppendString(TimePMString);
                Inc(Format, 3);
                Use12HourClock := TRUE;
              end else
              if StrLIComp(P, 'AAAA', 4) = 0 then
              begin
								GetDate;
                AppendString(LongDayNames[DayOfWeek(DateTime)]);
                Inc(Format, 3);
              end else
              if StrLIComp(P, 'AAA', 3) = 0 then
              begin
                GetDate;
                AppendString(ShortDayNames[DayOfWeek(DateTime)]);
                Inc(Format, 2);
              end else
              AppendChars(@Starter, 1);
            end;
          'C':
            begin
							GetCount;
              AppendFormat(Pointer(ShortDateFormat));
              GetTime;
              if (Hour <> 0) or (Min <> 0) or (Sec <> 0) then
              begin
                AppendChars(' ', 1);
                AppendFormat(Pointer(LongTimeFormat));
              end;
            end;
          '/':
            AppendChars(@DateSeparator, 1);
          ':':
            AppendChars(@TimeSeparator, 1);
          '''', '"':
            begin
              P := Format;
              while (Format^ <> #0) and (Format^ <> Starter) do
              begin
                if Format^ in LeadBytes then
                begin
                  Inc(Format);
                  if Format^ = #0 then Break;
                end;
                Inc(Format);
              end;
							AppendChars(P, Format - P);
              if Format^ <> #0 then Inc(Format);
            end;
        else
          AppendChars(@Starter, 1);
        end;
      end;
      Dec(AppendLevel);
    end;
  end;

begin
  BufPos := 0;
  AppendLevel := 0;
	if Format <> '' then AppendFormat(Pointer(Format)) else AppendFormat('C');
  SetString(Result, Buffer, BufPos);
end;


function NoLangFormatDateTime(const Format: string; DateTime: TDateTime): string;
begin
  NoLangDateTimeToString(Result, Format, DateTime);
end;

function StripQuotesFromQuotedIdentifier(S : String) : String;
begin
  if Length(S) > 0 then
  begin
    if S[1] in ['''', '"'] then
    begin
      S := Copy(S, 2, Length(S));
    end;
  end;

  if Length(S) > 0 then
  begin
    if S[Length(S)] in ['''', '"'] then
    begin
      S := Copy(S, 1, Length(S) - 1);
		end;
  end;
  Result := S;
end;

function IsIdentifierQuoted(S : String) : Boolean;
var
  BeginQuote : Boolean;
  EndQuote : Boolean;

begin
  BeginQuote := False;
  EndQuote := False;

	if Length(S) > 0 then
  begin
    if S[1] in ['''', '"'] then
    begin
      BeginQuote := True;
    end;
  end;

  if Length(S) > 0 then
  begin
    if S[Length(S)] in ['''', '"'] then
    begin
      EndQuote := True;
    end;
  end;
  Result := BeginQuote and EndQuote;
end;


function ShouldBeQuoted(S : String) : Boolean;
var
  Idx : Integer;

begin
  Result := False;
	for Idx := 1 to Length(S) do
  begin
    if not (S[Idx] in ['A'..'Z', 'a'..'z', '_', '0'..'9']) then
    begin
      Result := True;
      Break;
    end;
  end;
end;

function MakeQuotedIdent(S : String; IB6 : Boolean; Dialect : Integer) : String;
begin
  if not IB6 then
  begin
		Result := S;
  end
  else
  begin
    if Dialect in [3] then
    begin
      if not IsIdentifierQuoted(S) then
      begin
        if ShouldBeQuoted(S) then
          Result := AnsiQuotedStr(S, '"')
        else
          Result := S;
      end
      else
        Result := S;
    end
    else
      Result := S;
  end;
end;


function GetDBCharSetIndexByID(ID : Integer) : Integer;
begin
  case ID of
		0 : Result := 0;
    1 : Result := 2;
    2 : Result := 3;
    3 : Result := 4;
    5 : Result := 5;
    6 : Result := 6;
    10 : Result := 7;
    11 : Result := 8;
    12 : Result := 9;
    21 : Result := 10;
    45 : Result := 11;
    46 : Result := 12;
    13 : Result := 13;
    47 : Result := 14;
		14 : Result := 15;
    50 : Result := 16;
    51 : Result := 17;
    52 : Result := 18;
    53 : Result := 19;
    54 : Result := 20;
    55 : Result := 21;
    19 : Result := 22;
    44 : Result := 23;
    56 : Result := 24;
    57 : Result := 25;
  else
    Result := 0;
  end;
end;

function GetDBCharSetNameByID(ID : Integer) : String;
begin
  case ID of
    0 : Result := '';
    1 : Result := 'OCTETS';
    2 : Result := 'ASCII';
    3 : Result := 'UNICODE_FSS';
    5 : Result := 'SJIS_0208';
    6 : Result := 'EUCJ_0208';
		10 : Result := 'DOS437';
    11 : Result := 'DOS850';
    12 : Result := 'DOS865';
    21 : Result := 'ISO8859_1';
    45 : Result := 'DOS852';
    46 : Result := 'DOS857';
    13 : Result := 'DOS860';
    47 : Result := 'DOS861';
    14 : Result := 'DOS863';
    50 : Result := 'CYRL';
    51 : Result := 'WIN1250';
    52 : Result := 'WIN1251';
    53 : Result := 'WIN1252';
    54 : Result := 'WIN1253';
		55 : Result := 'WIN1254';
    19 : Result := 'NEXT';
    44 : Result := 'KSC_5601';
    56 : Result := 'BIG_5';
    57 : Result := 'GB_2312';
  else
    Result := '';
  end;
end;

function ConvertFieldType(ftype, flen, fscale, fsubtype, fprecision : Integer; IsInterbase6 : Boolean) : String;
begin
  fscale := Abs(fscale);
  Case ftype of
    blr_short :
      begin
        if IsInterbase6 then
        begin
          case fsubtype of
            0 :
              begin
                Result := 'smallint';
              end;
            1 :
              begin
								Result := 'numeric(' + IntToStr(fprecision) + ', ' + IntToStr(fscale) + ')'
              end;
            2 :
              begin
                Result := 'decimal(' + IntToStr(fprecision) + ', ' + IntToStr(fscale) + ')'
              end;
          end;
        end
        else
        begin
          if fscale <> 0 then
          begin
            Result := 'decimal(4, ' + IntToStr(fscale) + ')'
          end
					else
            Result := 'smallint';
        end;
      end;

    blr_long :
      begin
        if IsInterbase6 then
        begin
          case fsubtype of
            0 :
              begin
                Result := 'integer';
              end;
            1 :
              begin
                Result := 'numeric(' + IntToStr(fprecision) + ', ' + IntToStr(fscale) + ')'
              end;
            2 :
              begin
                Result := 'decimal(' + IntToStr(fprecision) + ', ' + IntToStr(fscale) + ')'
              end;
          end;
        end
        else
				begin
          if fscale <> 0 then
          begin
            Result := 'decimal(9, ' + IntToStr(fscale) + ')'
          end
          else
            Result := 'integer';
        end;
      end;

    blr_int64 :
      begin
        if IsInterbase6 then
        begin
					case fsubtype of
            0 :
              begin
                Result := 'decimal(18, 0)';
              end;
            1 :
              begin
                Result := 'numeric(' + IntToStr(fprecision) + ', ' + IntToStr(fscale) + ')'
              end;
            2 :
              begin
                Result := 'decimal(' + IntToStr(fprecision) + ', ' + IntToStr(fscale) + ')'
              end;
          end;
        end;
      end;

    blr_float :
      begin
        Result := 'float';
      end;


    blr_text :
      begin
				Result := 'char(' + IntToStr(flen) + ')';
      end;

    blr_double :
      begin
        if fscale <> 0 then
        begin
          Result := 'decimal(15, ' + IntToStr(fscale) + ')';
        end
        else
          Result := 'double precision';
      end;

    blr_timestamp :
			begin
        if IsInterbase6 then
          Result := 'timestamp'
        else
          Result := 'date'
      end;

    blr_sql_time :
      begin
        Result := 'time'
      end;

    blr_sql_date :
      begin
        Result := 'date'
      end;

    blr_varying :
      begin
        Result := 'varchar(' + IntToStr(flen) + ')';
      end;

    blr_cstring :
      begin
        Result := 'cstring(' + IntToStr(flen) + ')';
			end;

    blr_blob :
      begin
        Result := 'blob';
      end;
  end;
end;

function ParseSection (ParseLine : String; ParseNum : Integer; ParseSep : Char) : String;
var
  iPos: LongInt;
  i : Integer;
  tmp : String;

begin
  tmp := ParseLine;
  for i := 1 To ParseNum do
  begin
    iPos := Pos(ParseSep, tmp);
    If iPos > 0 Then
    begin
      if i = ParseNum Then
      begin
	Result := Copy(tmp, 1, iPos - 1);
        Exit;
      end
      else
        begin
          Delete(tmp, 1, iPos);
        end;
    end
    else
      If ParseNum > i Then
      begin
        Result := '';
        Exit;
      end
      else
				begin
          Result := tmp;
          Exit;
        end;
  end;
end;

end.

{
$Log: Globals.pas,v $
Revision 1.2  2002/04/25 07:16:24  tmuetze
New CVS powered comment block

}
