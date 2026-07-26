program imagelist_convert;

{$MODE Delphi}

{ Rebuilds MarathonMain.lfm's ilMarathonImages in LCL's own format.

  The .lfm inherited a Delphi TImageList blob: an "IL" header giving the count
  and icon size, followed by one 64x80 strip bitmap and a 1-bpp transparency
  mask. LCL reads that blob but keeps only the first 16x16 tile, so the list
  arrived holding a single image while every cache type indexes 0..10 into it.
  gtk2's ItemSetImage writes Widgets^.Images.Items[AImageIndex] with no bound
  check of its own, so the second icon raised "List index (1) out of bounds" -
  which is what a user saw on selecting a connection.

  The artwork was extracted from that blob once, into tools/marathon_icons.png:
  the 32-bpp strip supplied the colours, the 1-bpp mask the alpha, since Delphi
  left the alpha channel at zero throughout. This program slices that PNG back
  into the 14 icons the header declared and prints the component as .lfm text,
  so the result can be pasted into MarathonMain.lfm and read back correctly.

  Run it under Xvfb - TImageList needs a widgetset. }

uses
  Interfaces, SysUtils, Classes, Graphics, Controls, ImgList;

var
  Png: TPortableNetworkGraphic;
  IL: TImageList;
  Stream, Textual, Back, Bin: TMemoryStream;
  Verify: TImageList;
  Text: TStringList;
  Idx: Integer;
  PngName, ListName, OutName: String;
  IconW, IconH, RealImages, Columns, Rows: Integer;

begin
  if ParamCount < 5 then
  begin
    WriteLn('Usage: imagelist_convert <png> <iconWidth> <iconHeight> <count> <name> [outfile]');
    Halt(2);
  end;
  PngName := ParamStr(1);
  IconW := StrToInt(ParamStr(2));
  IconH := StrToInt(ParamStr(3));
  { What the Delphi header declared. A strip usually has room for more tiles
    than the list actually holds, and the spare ones are filler - keeping them
    would show solid blocks at the end of the list. }
  RealImages := StrToInt(ParamStr(4));
  ListName := ParamStr(5);
  if ParamCount >= 6 then
    OutName := ParamStr(6)
  else
    OutName := ChangeFileExt(PngName, '.lfm');
  if not FileExists(PngName) then
  begin
    WriteLn('Cannot find ', PngName);
    Halt(2);
  end;

  Png := TPortableNetworkGraphic.Create;
  IL := TImageList.Create(nil);
  Stream := TMemoryStream.Create;
  Text := TStringList.Create;
  try
    Png.LoadFromFile(PngName);
    Columns := Png.Width div IconW;
    Rows := Png.Height div IconH;
    IL.Width := IconW;
    IL.Height := IconH;
    IL.Name := ListName;
    IL.AddSliced(Png, Columns, Rows);
    WriteLn('sliced ', IL.Count, ' tiles of ', IL.Width, 'x', IL.Height);
    for Idx := IL.Count - 1 downto RealImages do
      IL.Delete(Idx);
    WriteLn('kept ', IL.Count, ' images');

    { Streamed binary first, then converted to the .lfm text form - the
      one-step helper lives in the IDE, not the LCL. }
    Stream.WriteComponent(IL);
    Stream.Position := 0;
    Textual := TMemoryStream.Create;
    try
      ObjectBinaryToText(Stream, Textual);
      Textual.Position := 0;
      Text.LoadFromStream(Textual);
    finally
      Textual.Free;
    end;
    Text.SaveToFile(OutName);
    WriteLn('wrote ', OutName, ' (', Text.Count, ' lines)');

    { Read straight back. Writing a blob proves nothing if the reader does not
      recover the same number of images from it. }
    Verify := TImageList.Create(nil);
    Back := TMemoryStream.Create;
    Bin := TMemoryStream.Create;
    try
      Text.SaveToStream(Back);
      Back.Position := 0;
      ObjectTextToBinary(Back, Bin);
      Bin.Position := 0;
      Bin.ReadComponent(Verify);
      WriteLn('read back: ', Verify.Count, ' images of ',
        Verify.Width, 'x', Verify.Height);
    finally
      Bin.Free;
      Back.Free;
      Verify.Free;
    end;
  finally
    Text.Free;
    Stream.Free;
    IL.Free;
    Png.Free;
  end;
end.
