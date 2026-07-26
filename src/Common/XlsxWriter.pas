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

unit XlsxWriter;

{$MODE Delphi}

{ Writes a result set as a single-sheet .xlsx workbook.

  Hand-rolled rather than pulled in from fpspreadsheet: an .xlsx is a zip of a
  handful of XML parts, FPC ships the zip writer in paszlib, and a result-set
  dump needs none of what a spreadsheet library exists for (formulas, styles,
  multiple sheets, reading). That keeps the build dependencies unchanged.

  Numbers are written as numbers rather than text, so they sort and total in
  the spreadsheet. The type decisions follow the JSON exporter's, and for the
  same reason: Firebird's DECFLOAT, INT128 and NUMERIC all arrive as BCD
  fields, and routing those through AsFloat would silently lose exactly the
  precision they exist to provide, so their text form is written verbatim into
  the numeric cell.

  Strings are written as inline strings. The shared-strings table would be
  smaller for repetitive data, but inline strings keep the writer to one pass
  with no dictionary to hold in memory for a large export.

  LCL-free so that test/ibx_smoke_test.lpr can write a workbook and check it. }

interface

uses SysUtils, Classes, DB;

{ Writes the listed fields of every remaining row of Q to FileName. Q is
  traversed from its current position, which the caller is expected to have set
  to the first row. SheetName is what the tab is called. }
procedure WriteXlsx(Q: TDataSet; FieldList: TStrings; const SheetName, FileName: String);

{ Exposed for testing: the A1-style reference for a zero-based column and
  row. }
function XlsxCellRef(Col, Row: Integer): String;

{ Exposed for testing: XML text escaping. }
function XlsxEscape(const S: String): String;

implementation

uses zipper;

function XlsxEscape(const S: String): String;
begin
  Result := StringReplace(S, '&', '&amp;', [rfReplaceAll]);
  Result := StringReplace(Result, '<', '&lt;', [rfReplaceAll]);
  Result := StringReplace(Result, '>', '&gt;', [rfReplaceAll]);
  Result := StringReplace(Result, '"', '&quot;', [rfReplaceAll]);
  { Excel rejects most control characters outright; a tab or newline inside a
    cell is legal but has to be a character reference. }
  Result := StringReplace(Result, #9, '&#9;', [rfReplaceAll]);
  Result := StringReplace(Result, #13#10, '&#10;', [rfReplaceAll]);
  Result := StringReplace(Result, #13, '&#10;', [rfReplaceAll]);
  Result := StringReplace(Result, #10, '&#10;', [rfReplaceAll]);
end;

function XlsxCellRef(Col, Row: Integer): String;
var
  N: Integer;
begin
  { Columns are base-26 with no zero digit: A..Z, then AA. }
  Result := '';
  N := Col;
  repeat
    Result := Chr(Ord('A') + (N mod 26)) + Result;
    N := (N div 26) - 1;
  until N < 0;
  Result := Result + IntToStr(Row + 1);
end;

{ True when the field should occupy a numeric cell. Dates deliberately are not:
  a date in a numeric cell needs a serial number and a number format to read
  back as a date, and getting that subtly wrong is worse than a text cell that
  says exactly what the database said. }
function IsNumericField(AFld: TField): Boolean;
begin
  Result := AFld.DataType in [ftSmallint, ftInteger, ftLargeint, ftWord,
    ftFloat, ftCurrency, ftBCD, ftFMTBcd];
end;

{ The text to place in a numeric cell. Written from AsString, with only the
  decimal separator normalised - the separator is locale-dependent whereas the
  file format is not. }
function NumericCellText(AFld: TField): String;
begin
  Result := StringReplace(Trim(AFld.AsString), ',', '.', [rfReplaceAll]);
end;

procedure AddPart(Zip: TZipper; const PartName, Content: String;
  Streams: TList);
var
  S: TStringStream;
begin
  S := TStringStream.Create(Content);
  Streams.Add(S);
  S.Position := 0;
  Zip.Entries.AddFileEntry(S, PartName);
end;

procedure WriteXlsx(Q: TDataSet; FieldList: TStrings; const SheetName, FileName: String);
var
  Zip: TZipper;
  Streams: TList;
  Sheet: TStringList;
  Row, Idx: Integer;
  Fld: TField;
  Cell: String;
begin
  Sheet := TStringList.Create;
  Streams := TList.Create;
  Zip := TZipper.Create;
  try
    Sheet.Add('<?xml version="1.0" encoding="UTF-8" standalone="yes"?>');
    Sheet.Add('<worksheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main">');
    Sheet.Add('<sheetData>');

    { Header row, always written: a column dump without names is hard to use. }
    Sheet.Add('<row r="1">');
    for Idx := 0 to FieldList.Count - 1 do
      Sheet.Add('<c r="' + XlsxCellRef(Idx, 0) + '" t="inlineStr"><is><t>' +
        XlsxEscape(FieldList[Idx]) + '</t></is></c>');
    Sheet.Add('</row>');

    Row := 1;
    Q.DisableControls;
    try
      while not Q.EOF do
      begin
        Sheet.Add('<row r="' + IntToStr(Row + 1) + '">');
        for Idx := 0 to FieldList.Count - 1 do
        begin
          Fld := Q.FindField(FieldList[Idx]);
          Cell := '<c r="' + XlsxCellRef(Idx, Row) + '"';
          if (Fld = nil) or Fld.IsNull then
            { An empty cell, which is how a spreadsheet spells "no value" -
              distinct from the empty string a text cell would hold. }
            Sheet.Add(Cell + '/>')
          else if IsNumericField(Fld) then
            Sheet.Add(Cell + '><v>' + NumericCellText(Fld) + '</v></c>')
          else
            Sheet.Add(Cell + ' t="inlineStr"><is><t>' +
              XlsxEscape(Fld.AsString) + '</t></is></c>');
        end;
        Sheet.Add('</row>');
        Inc(Row);
        Q.Next;
      end;
    finally
      Q.EnableControls;
    end;

    Sheet.Add('</sheetData>');
    Sheet.Add('</worksheet>');

    AddPart(Zip, '[Content_Types].xml',
      '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>' +
      '<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">' +
      '<Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>' +
      '<Default Extension="xml" ContentType="application/xml"/>' +
      '<Override PartName="/xl/workbook.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet.main+xml"/>' +
      '<Override PartName="/xl/worksheets/sheet1.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml"/>' +
      '</Types>', Streams);

    AddPart(Zip, '_rels/.rels',
      '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>' +
      '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">' +
      '<Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="xl/workbook.xml"/>' +
      '</Relationships>', Streams);

    AddPart(Zip, 'xl/workbook.xml',
      '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>' +
      '<workbook xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" ' +
      'xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships">' +
      '<sheets><sheet name="' + XlsxEscape(SheetName) + '" sheetId="1" r:id="rId1"/></sheets>' +
      '</workbook>', Streams);

    AddPart(Zip, 'xl/_rels/workbook.xml.rels',
      '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>' +
      '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">' +
      '<Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet" Target="worksheets/sheet1.xml"/>' +
      '</Relationships>', Streams);

    AddPart(Zip, 'xl/worksheets/sheet1.xml', Sheet.Text, Streams);

    Zip.FileName := FileName;
    Zip.ZipAllFiles;
  finally
    Zip.Free;
    for Idx := 0 to Streams.Count - 1 do
      TObject(Streams[Idx]).Free;
    Streams.Free;
    Sheet.Free;
  end;
end;

end.
