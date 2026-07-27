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

unit PrintDocument;

{$MODE Delphi}

{ What goes on the printed page, and where the pages break.

  Marathon's printing was written against PagePrnt and DSprint, two Delphi-era
  report writers that were never ported, so every one of the thirty-odd Print
  methods has been a no-op showing "Printing is not available in this build".
  The menu items, the toolbar buttons and the CanPrint/DoPrint plumbing on
  every form are all still there and all still wired - only the engine was
  missing.

  This is the half of that engine worth testing: a document is built from
  blocks - a title, headings, text and tables - and then laid out onto pages of
  a given size. Nothing here draws anything, knows what a printer is, or links
  the LCL, so pagination is checked without either.

  Measuring in characters rather than in pixels is deliberate. Reports of
  metadata are columns of names and types, which line up only in a fixed-pitch
  font; once the font is fixed-pitch a page is a character grid, and where a
  page breaks stops being a question about font metrics. The renderer picks the
  point size that makes the grid fit the paper. }

interface

uses SysUtils, Classes;

type
  TPrintBlockKind = (pbTitle, pbHeading, pbText, pbSpacer, pbTableHeader, pbTableRow);

  TPrintDocument = class
  private
    FTitle: String;
    FBlocks: TStringList;
    procedure Add(Kind: TPrintBlockKind; const Text: String);
    function KindOf(Index: Integer): TPrintBlockKind;
    function TextOf(Index: Integer): String;
  public
    constructor Create(const ATitle: String);
    destructor Destroy; override;

    { A line of its own, larger than the body text when rendered. }
    procedure AddTitle(const S: String);
    { A section within the report - 'Columns', 'Indices'. Kept with what
      follows it: a heading alone at the foot of a page reads as a mistake. }
    procedure AddHeading(const S: String);
    procedure AddText(const S: String);
    procedure AddLines(ALines: TStrings);
    procedure AddSpacer;

    { A table. The header is repeated at the top of every page the table runs
      onto, which is the whole reason tables are a block kind rather than
      pre-formatted text: a reader looking at page four should not have to turn
      back to page one to find out which column is which.

      Cells are laid out into columns wide enough for their contents, so both
      calls take the cells rather than a formatted line. }
    procedure AddTableHeader(const Cells: array of String);
    procedure AddTableRow(const Cells: array of String);

    property Title: String read FTitle write FTitle;
    function BlockCount: Integer;
    property Blocks: TStringList read FBlocks;
  end;

  { One page, as the lines that go on it. The renderer draws these; the header
    and footer are already in them, so drawing is one loop with no cases. }
  TPrintPage = class
  private
    FLines: TStringList;
  public
    constructor Create;
    destructor Destroy; override;
    property Lines: TStringList read FLines;
  end;

  TPrintedDocument = class
  private
    FPages: TList;
    function GetPage(Index: Integer): TPrintPage;
  public
    constructor Create;
    destructor Destroy; override;
    function AddPage: TPrintPage;
    function PageCount: Integer;
    property Pages[Index: Integer]: TPrintPage read GetPage; default;
  end;

{ Lays the document out onto pages of LinesPerPage by CharsPerLine.

  Two lines of every page are spent on a running header carrying the report
  title and a footer carrying 'Page N of M', so a caller asking for 60 gets 57
  lines of content. Both are put in by this rather than by the renderer,
  because the page count they quote is only known once the layout is done. }
function PaginateDocument(Doc: TPrintDocument;
  LinesPerPage, CharsPerLine: Integer): TPrintedDocument;

{ Breaks one long line into as many as it takes to fit within Width, at spaces
  where there is one. A word longer than the whole width is cut rather than
  dropped - that is a path name or a very long identifier, and truncating it
  silently loses the end of it. }
function WrapLine(const Text: String; Width: Integer): TStringList;

{ Cells padded into fixed columns, one space between. Exposed because the
  pagination tests need to check alignment, and because it is what makes a
  table a table. }
function FormatRow(const Cells: array of String;
  const Widths: array of Integer): String;

implementation

const
  { What separates one column from the next. Two spaces rather than one: with
    one, a value that exactly fills its column runs into the next and the table
    stops being readable at precisely the moment the data gets interesting. }
  ColumnGap = '  ';

constructor TPrintDocument.Create(const ATitle: String);
begin
  inherited Create;
  FTitle := ATitle;
  FBlocks := TStringList.Create;
end;

destructor TPrintDocument.Destroy;
begin
  FBlocks.Free;
  inherited Destroy;
end;

{ Blocks are held as strings tagged by their kind, so the document is one list
  rather than a class hierarchy for six things that all carry a string. }
procedure TPrintDocument.Add(Kind: TPrintBlockKind; const Text: String);
begin
  FBlocks.AddObject(Text, TObject(PtrInt(Ord(Kind))));
end;

function TPrintDocument.KindOf(Index: Integer): TPrintBlockKind;
begin
  Result := TPrintBlockKind(PtrInt(FBlocks.Objects[Index]));
end;

function TPrintDocument.TextOf(Index: Integer): String;
begin
  Result := FBlocks[Index];
end;

procedure TPrintDocument.AddTitle(const S: String);
begin
  Add(pbTitle, S);
end;

procedure TPrintDocument.AddHeading(const S: String);
begin
  Add(pbHeading, S);
end;

procedure TPrintDocument.AddText(const S: String);
begin
  Add(pbText, S);
end;

procedure TPrintDocument.AddLines(ALines: TStrings);
var
  Idx: Integer;
begin
  if not Assigned(ALines) then
    Exit;
  for Idx := 0 to ALines.Count - 1 do
    Add(pbText, ALines[Idx]);
end;

procedure TPrintDocument.AddSpacer;
begin
  Add(pbSpacer, '');
end;

{ Cells are joined with a tab, which cannot occur in the values themselves -
  everything printed here comes from Firebird metadata or from a dataset
  rendered as text, and a tab in either would already have broken the SQL that
  produced it. }
function JoinCells(const Cells: array of String): String;
var
  Idx: Integer;
begin
  Result := '';
  for Idx := Low(Cells) to High(Cells) do
  begin
    if Idx > Low(Cells) then
      Result := Result + #9;
    Result := Result + StringReplace(Cells[Idx], #9, ' ', [rfReplaceAll]);
  end;
end;

procedure TPrintDocument.AddTableHeader(const Cells: array of String);
begin
  Add(pbTableHeader, JoinCells(Cells));
end;

procedure TPrintDocument.AddTableRow(const Cells: array of String);
begin
  Add(pbTableRow, JoinCells(Cells));
end;

function TPrintDocument.BlockCount: Integer;
begin
  Result := FBlocks.Count;
end;

constructor TPrintPage.Create;
begin
  inherited Create;
  FLines := TStringList.Create;
end;

destructor TPrintPage.Destroy;
begin
  FLines.Free;
  inherited Destroy;
end;

constructor TPrintedDocument.Create;
begin
  inherited Create;
  FPages := TList.Create;
end;

destructor TPrintedDocument.Destroy;
var
  Idx: Integer;
begin
  for Idx := 0 to FPages.Count - 1 do
    TPrintPage(FPages[Idx]).Free;
  FPages.Free;
  inherited Destroy;
end;

function TPrintedDocument.AddPage: TPrintPage;
begin
  Result := TPrintPage.Create;
  FPages.Add(Result);
end;

function TPrintedDocument.PageCount: Integer;
begin
  Result := FPages.Count;
end;

function TPrintedDocument.GetPage(Index: Integer): TPrintPage;
begin
  Result := TPrintPage(FPages[Index]);
end;

function WrapLine(const Text: String; Width: Integer): TStringList;
var
  Rest, Piece: String;
  BreakAt, Idx: Integer;
begin
  Result := TStringList.Create;
  if Width < 1 then
    Width := 1;
  Rest := Text;
  { An empty line is a line: a blank between paragraphs must survive. }
  if Rest = '' then
  begin
    Result.Add('');
    Exit;
  end;

  while Length(Rest) > Width do
  begin
    { The last space that still fits, so the break lands between words. }
    BreakAt := 0;
    for Idx := Width + 1 downto 1 do
      if (Idx <= Length(Rest)) and (Rest[Idx] = ' ') then
      begin
        BreakAt := Idx;
        Break;
      end;
    if BreakAt <= 1 then
      { No space to break at - one word longer than the line. Cut it, rather
        than emit an over-long line the renderer would run off the paper. }
      BreakAt := Width + 1;
    Piece := TrimRight(Copy(Rest, 1, BreakAt - 1));
    Result.Add(Piece);
    Rest := TrimLeft(Copy(Rest, BreakAt, MaxInt));
  end;
  Result.Add(Rest);
end;

function FormatRow(const Cells: array of String;
  const Widths: array of Integer): String;
var
  Idx, W: Integer;
  Cell: String;
begin
  Result := '';
  for Idx := Low(Cells) to High(Cells) do
  begin
    if Idx > Low(Cells) then
      Result := Result + ColumnGap;
    if Idx <= High(Widths) then
      W := Widths[Idx]
    else
      W := Length(Cells[Idx]);
    Cell := Cells[Idx];
    if Length(Cell) > W then
      Cell := Copy(Cell, 1, W);
    { The last column is not padded - trailing spaces at the end of a line are
      invisible on paper and only make the output harder to compare. }
    if Idx < High(Cells) then
      Cell := Cell + StringOfChar(' ', W - Length(Cell));
    Result := Result + Cell;
  end;
end;

{ Splits a stored table row back into its cells. }
procedure SplitCells(const Text: String; Cells: TStringList);
begin
  Cells.Clear;
  Cells.StrictDelimiter := True;
  Cells.Delimiter := #9;
  Cells.DelimitedText := Text;
end;

{ How wide each column of the table starting at StartAt has to be. Measured
  over the whole table before any of it is laid out, so the columns do not
  change width halfway down a report; then scaled down if the total overruns
  the page. }
procedure MeasureTable(Doc: TPrintDocument; StartAt, CharsPerLine: Integer;
  Widths: TList; out EndsAt: Integer);
var
  Idx, Col, Total, Over, Take: Integer;
  Cells: TStringList;
  Kind: TPrintBlockKind;
begin
  Widths.Clear;
  Cells := TStringList.Create;
  try
    Idx := StartAt;
    while Idx < Doc.BlockCount do
    begin
      Kind := TPrintBlockKind(PtrInt(Doc.Blocks.Objects[Idx]));
      if not (Kind in [pbTableHeader, pbTableRow]) then
        Break;
      SplitCells(Doc.Blocks[Idx], Cells);
      for Col := 0 to Cells.Count - 1 do
      begin
        while Widths.Count <= Col do
          Widths.Add(nil);
        if Length(Cells[Col]) > PtrInt(Widths[Col]) then
          Widths[Col] := TObject(PtrInt(Length(Cells[Col])));
      end;
      Inc(Idx);
    end;
    EndsAt := Idx;

    { Too wide for the paper: take the overflow off the widest columns first,
      so a table of one long description and six short codes loses it from the
      description rather than mangling every column equally. }
    Total := 0;
    for Col := 0 to Widths.Count - 1 do
      Total := Total + PtrInt(Widths[Col]);
    Total := Total + (Widths.Count - 1) * Length(ColumnGap);
    Over := Total - CharsPerLine;
    while (Over > 0) and (Widths.Count > 0) do
    begin
      Col := 0;
      for Idx := 1 to Widths.Count - 1 do
        if PtrInt(Widths[Idx]) > PtrInt(Widths[Col]) then
          Col := Idx;
      if PtrInt(Widths[Col]) <= 4 then
        { Everything is already as narrow as it is worth making it; the row
          will be clipped by FormatRow rather than shrunk to nothing. }
        Break;
      Take := PtrInt(Widths[Col]) - 4;
      if Take > Over then
        Take := Over;
      Widths[Col] := TObject(PtrInt(PtrInt(Widths[Col]) - Take));
      Dec(Over, Take);
    end;
  finally
    Cells.Free;
  end;
end;

function PaginateDocument(Doc: TPrintDocument;
  LinesPerPage, CharsPerLine: Integer): TPrintedDocument;
var
  Page: TPrintPage;
  Body: Integer;
  Idx, Col, EndsAt: Integer;
  Kind: TPrintBlockKind;
  Wrapped, Cells: TStringList;
  Widths: TList;
  WidthArr: array of Integer;
  CellArr: array of String;
  HeaderLine: String;
  N: Integer;

  procedure NewPage;
  begin
    Page := Result.AddPage;
    Page.Lines.Add(Doc.Title);
    Page.Lines.Add(StringOfChar('-', CharsPerLine));
  end;

  { True when the page has room for that many more content lines. }
  function Fits(HowMany: Integer): Boolean;
  begin
    Result := (Page.Lines.Count - 2) + HowMany <= Body;
  end;

  procedure Emit(const S: String);
  begin
    if not Fits(1) then
      NewPage;
    Page.Lines.Add(S);
  end;

begin
  Result := TPrintedDocument.Create;
  if CharsPerLine < 20 then
    CharsPerLine := 20;
  { Two lines of running header, one of footer. }
  Body := LinesPerPage - 3;
  if Body < 1 then
    Body := 1;

  Widths := TList.Create;
  Cells := TStringList.Create;
  try
    NewPage;
    Idx := 0;
    while Idx < Doc.BlockCount do
    begin
      Kind := TPrintBlockKind(PtrInt(Doc.Blocks.Objects[Idx]));

      if Kind in [pbTableHeader, pbTableRow] then
      begin
        MeasureTable(Doc, Idx, CharsPerLine, Widths, EndsAt);
        SetLength(WidthArr, Widths.Count);
        for Col := 0 to Widths.Count - 1 do
          WidthArr[Col] := PtrInt(Widths[Col]);

        HeaderLine := '';
        while Idx < EndsAt do
        begin
          Kind := TPrintBlockKind(PtrInt(Doc.Blocks.Objects[Idx]));
          SplitCells(Doc.Blocks[Idx], Cells);
          SetLength(CellArr, Cells.Count);
          for Col := 0 to Cells.Count - 1 do
            CellArr[Col] := Cells[Col];

          if Kind = pbTableHeader then
          begin
            { Remembered so it can be repeated wherever the table crosses onto
              a new page. }
            HeaderLine := FormatRow(CellArr, WidthArr);
            { A header with no room for a row under it belongs on the next
              page, not stranded at the foot of this one. }
            if not Fits(3) then
              NewPage;
            Page.Lines.Add(HeaderLine);
            Page.Lines.Add(StringOfChar('-', Length(HeaderLine)));
          end
          else
          begin
            if not Fits(1) then
            begin
              NewPage;
              if HeaderLine <> '' then
              begin
                Page.Lines.Add(HeaderLine);
                Page.Lines.Add(StringOfChar('-', Length(HeaderLine)));
              end;
            end;
            Page.Lines.Add(FormatRow(CellArr, WidthArr));
          end;
          Inc(Idx);
        end;
        Continue;
      end;

      case Kind of
        pbSpacer:
          { A blank line at the top of a page is a blank line wasted, so one
            that falls there is dropped. }
          if Page.Lines.Count > 2 then
            Emit('');

        pbTitle:
          begin
            if not Fits(3) then
              NewPage;
            Page.Lines.Add(Doc.Blocks[Idx]);
            Page.Lines.Add(StringOfChar('=', Length(Doc.Blocks[Idx])));
          end;

        pbHeading:
          begin
            { Kept with what follows: a heading is not worth a page of its
              own, and one alone at the foot reads as content having gone
              missing. }
            if not Fits(2) then
              NewPage;
            Page.Lines.Add(Doc.Blocks[Idx]);
          end;
      else
        begin
          Wrapped := WrapLine(Doc.Blocks[Idx], CharsPerLine);
          try
            for N := 0 to Wrapped.Count - 1 do
              Emit(Wrapped[N]);
          finally
            Wrapped.Free;
          end;
        end;
      end;
      Inc(Idx);
    end;

    { The footers last, because until the layout is finished nothing knows how
      many pages there are to count up to. }
    for N := 0 to Result.PageCount - 1 do
    begin
      while Result[N].Lines.Count < LinesPerPage - 1 do
        Result[N].Lines.Add('');
      Result[N].Lines.Add('Page ' + IntToStr(N + 1) + ' of ' +
        IntToStr(Result.PageCount));
    end;
  finally
    Widths.Free;
    Cells.Free;
  end;
end;

end.
