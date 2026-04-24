unit Tools;

{$MODE Delphi}

interface

uses {$IFDEF FPC}
  LCLIntf, LCLType, LMessages, {$ELSE}
  Windows, Messages, {$ENDIF}
  Controls, Classes, SQLDB;

// String Operation
function AddBackslash(sPath: String): String;
// Components
procedure ChangeEnables(const aControls: array of TControl; bValue: Boolean);
// Database
function CreateQuery(sSQL, sDatabaseName: String; bIsReadOnly, bOpenIt: Boolean): TSQLQuery; overload;
function CreateQuery(sSQL, sDatabaseName: String; sKeyLinks: array of String; bIsReadOnly, bOpenIt: Boolean): TSQLQuery; overload;
// System
procedure ExecuteWin32Program(sPath: String);
function GetBuildInfo(const sFilename: String; var wVer1, wVer2, wVer3, wVer4: Word): Boolean;
// Network
procedure EnumNetResources(List: TStrings);

implementation

uses {$IFNDEF FPC}
  ShellAPI, Windows, {$ENDIF}
  Forms, Dialogs, SysUtils;

// String Operation
function AddBackslash(sPath: String): String;
begin
	if (Copy(sPath, Length(sPath), 1) <> '\') then
		Result := sPath + '\'
	else
		Result := sPath;
end;

// Components
procedure ChangeEnables(const aControls: array of TControl; bValue: Boolean);
var
	I: Integer;
begin
	for I := 0 to High(aControls) do
		TControl(aControls[I]).Enabled := bValue;
end;

// Database
function CreateQuery(sSQL, sDatabaseName: String; bIsReadOnly, bOpenIt: Boolean): TSQLQuery;
var
	sSubStr: String;
begin
	Result := TSQLQuery.Create(nil);
	with Result do
		try
			// DatabaseName := sDatabaseName; // IBX uses Database property, not DatabaseName string
			// ReadOnly := bIsReadOnly;
			SQL.Add(sSQL);
			if (bOpenIt = True) then
				Open;
		except
			Free;
			raise;
		end;
end;

function CreateQuery(sSQL, sDatabaseName: String; sKeyLinks: array of String; bIsReadOnly, bOpenIt: Boolean): TSQLQuery;
var
	I: Integer;
begin
	Result := CreateQuery(sSQL, sDatabaseName, bIsReadOnly, False);
	with Result do
	begin
    // KeyLinks not in TSQLQuery
		{ KeyLinks.Clear;
		for I := Low(sKeyLinks) to High(sKeyLinks) do
			KeyLinks.Add(sKeyLinks[I]); }
		if (bOpenIt = True) then
			Open;
	end;
end;

// System
procedure ExecuteWin32Program(sPath: String);
var
	Zeiger: PChar;
begin
	Zeiger := StrAlloc(Length(sPath) + 1);
	StrPCopy(Zeiger, sPath);
	try
    {$IFDEF MSWINDOWS}
		if (ShellExecute(0, 'open', Zeiger, nil, nil, SW_SHOWNORMAL) <= 32) then
			MessageDlg('Program "' + sPath + '" not found.', mtError, [mbOK], 0);
    {$ELSE}
    if not OpenDocument(sPath) then
			MessageDlg('Program "' + sPath + '" not found.', mtError, [mbOK], 0);
    {$ENDIF}
	finally
		StrDispose(Zeiger);
	end;
end;

function GetBuildInfo(const sFilename: String; var wVer1, wVer2, wVer3, wVer4: Word): Boolean;
{$IFDEF MSWINDOWS}
var
	Dummy: DWord;
	Len: Integer;
	Buf: PChar;
	FixedInfo: PVSFixedFileInfo;
begin
	Result := False;
	Len := GetFileVersionInfoSize(PChar(sFilename), Dummy);
	if (Len > 0) then
	begin
		Buf := AllocMem(Len);
		try
			if GetFileVersionInfo(PChar(sFilename), 0, Len, Buf) then
			begin
				if VerQueryValue(Buf, '\', Pointer(FixedInfo), Dummy) then
				begin
					wVer1 := HiWord(FixedInfo.dwFileVersionMS);
					wVer2 := LoWord(FixedInfo.dwFileVersionMS);
					wVer3 := HiWord(FixedInfo.dwFileVersionLS);
					wVer4 := LoWord(FixedInfo.dwFileVersionLS);
					Result := True;
				end;
			end;
		finally
			FreeMem(Buf, Len);
		end;
	end;
end;
{$ELSE}
begin
  wVer1 := 0; wVer2 := 0; wVer3 := 0; wVer4 := 0;
  Result := False;
end;
{$ENDIF}

// Network
procedure EnumNetResources(List: TStrings);
{$IFDEF MSWINDOWS}
	procedure EnumFunc(NetResource: PNetResource);
	var
		EnumHandle: THandle;
		Count, BufferSize: DWord;
		Buffer: PNetResource;
		I: Integer;
	begin
		if (WNetOpenEnum(RESOURCE_GLOBALNET, RESOURCETYPE_ANY, 0, NetResource, EnumHandle) = NO_ERROR) then
		try
			Count := $FFFFFFFF;
			BufferSize := 16384;
			Buffer := AllocMem(BufferSize);
			try
				if (WNetEnumResource(EnumHandle, Count, Buffer, BufferSize) = NO_ERROR) then
				begin
					for I := 0 to Count - 1 do
					begin
						if (PNetResource(PChar(Buffer) + (I * SizeOf(TNetResource))).dwDisplayType = RESOURCEDISPLAYTYPE_SERVER) then
							List.Add(PNetResource(PChar(Buffer) + (I * SizeOf(TNetResource))).lpRemoteName)
						else
							if (PNetResource(PChar(Buffer) + (I * SizeOf(TNetResource))).dwUsage and RESOURCEUSAGE_CONTAINER <> 0) then
								EnumFunc(PNetResource(PChar(Buffer) + (I * SizeOf(TNetResource))));
					end;
				end;
			finally
				FreeMem(Buffer);
			end;
		finally
			WNetCloseEnum(EnumHandle);
		end;
	end;
begin
	EnumFunc(nil);
end;
{$ELSE}
begin
  // Not implemented for Linux
end;
{$ENDIF}

end.
