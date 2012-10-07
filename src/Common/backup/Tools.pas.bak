{******************************************************************}
{ The contents of this file are used with permission, subject to	 }
{ the Mozilla Public License Version 1.1 (the "License"); you may  }
{ not use this file except in compliance with the License. You may }
{ obtain a copy of the License at 																 }
{ http://www.mozilla.org/MPL/MPL-1.1.html 												 }
{ 																																 }
{ Software distributed under the License is distributed on an 		 }
{ "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, either express or	 }
{ implied. See the License for the specific language governing		 }
{ rights and limitations under the License. 											 }
{ 																																 }
{******************************************************************}
// $Id: Tools.pas,v 1.6 2002/09/25 12:12:49 tmuetze Exp $

unit Tools;

interface

uses
	Controls, Classes,
	IBODataset;

// String Operation
function AddBackslash(sPath: String): String;
// Components
procedure ChangeEnables(const aControls: array of TControl; bValue: Boolean);
// Database
function CreateQuery(sSQL, sDatabaseName: String; bIsReadOnly, bOpenIt: Boolean): TIBOQuery; overload;
function CreateQuery(sSQL, sDatabaseName: String; sKeyLinks: array of String; bIsReadOnly, bOpenIt: Boolean): TIBOQuery; overload;
// System
procedure ExecuteWin32Program(sPath: String);
function GetBuildInfo(const sFilename: String; var wVer1, wVer2, wVer3, wVer4: Word): Boolean;
// Network
procedure EnumNetResources(List: TStrings);

implementation

uses
	ShellAPI, Forms, Windows, Dialogs;

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
function CreateQuery(sSQL, sDatabaseName: String; bIsReadOnly, bOpenIt: Boolean): TIBOQuery;
var
	sSubStr: String;
begin
	Result := TIBOQuery.Create(nil);
	with Result do
		try
			DatabaseName := sDatabaseName;
			FetchWholeRows := False;
			KeyLinksAutoDefine := not bIsReadOnly;
			ReadOnly := bIsReadOnly;
			RequestLive := not bIsReadOnly;
			SQL.Add(sSQL);
			if (bOpenIt = True) then
				Open;
		except
			Free;
			Result := nil;
		end;
end;

function CreateQuery(sSQL, sDatabaseName: String; sKeyLinks: array of String; bIsReadOnly, bOpenIt: Boolean): TIBOQuery;
var
	I: Integer;
begin
	Result := CreateQuery(sSQL, sDatabaseName, bIsReadOnly, False);
	with Result do
	begin
		KeyLinks.Clear;
		for I := Low(sKeyLinks) to High(sKeyLinks) do
			KeyLinks.Add(sKeyLinks[I]);
		if (bOpenIt = True) then
			Open;
	end;
end;

// System
procedure ExecuteWin32Program(sPath: String);
const
	Mail = 'mailto:';
	Http = 'http://';
var
	Zeiger: PChar;
begin
	if (sPath <> '') then
	begin
		sPath := sPath + #0;
		Zeiger := @sPath[1];
		if (ShellExecute(Application.Handle, 'Open', Zeiger, nil, nil, SW_SHOW) <= 32) then
			if (Pos(Http, sPath) <> 0) then
				MessageDlg('Error while opening your Internet browser.', mtError, [mbOK], 0)
			else
				if (Pos(Mail, sPath) <> 0) then
					MessageDlg('Error while opening your E-Mail client.', mtError, [mbOK], 0);
	end;
end;

function GetBuildInfo(const sFilename: String; var wVer1, wVer2, wVer3, wVer4: Word): Boolean;
var
	VerInfo: Pointer;
	VerInfoSize, VerValueSize, Dummy: Cardinal;
	VerValue: PVSFixedFileInfo;
begin
	VerInfoSize := GetFileVersionInfoSize(PChar(sFilename), Dummy);
	Result := False;
	if (VerInfoSize <> 0) then
	begin
		GetMem(VerInfo, VerInfoSize);
		try
			if (GetFileVersionInfo(PChar(sFilename), 0, VerInfoSize, VerInfo)) then
			begin
				if (VerQueryValue(VerInfo, '\', Pointer(VerValue), VerValueSize)) then
					with VerValue^ do
					begin
						wVer1 := dwFileVersionMS shr 16;
						wVer2 := dwFileVersionMS and $FFFF;
						wVer3 := dwFileVersionLS shr 16;
						wVer4 := dwFileVersionLS and $FFFF;
					end;
				Result := True;
			end;
		finally
			FreeMem(VerInfo, VerInfoSize);
		end;
	end;
end;

// Network
procedure EnumNetResources(List: TStrings);

	procedure EnumFunc(NetResource: PNetResource);
	var
		I: Integer;
		iCount, iBufferSize: DWORD;
		sComputerName: String;
		aBuffer: array[0..16384 div SizeOf(TNetResource)] of TNetResource;
		hanEnum: THandle;
	begin
		Screen.Cursor := crHourGlass;
		if (WNetOpenEnum(RESOURCE_GLOBALNET, RESOURCETYPE_ANY, 0, NetResource, hanEnum) = NO_ERROR) then
			try
				iCount := $FFFFFFFF;
				iBufferSize := SizeOf(aBuffer);
				while WNetEnumResource(hanEnum, iCount, @aBuffer, iBufferSize) = NO_ERROR do
					for I := 0 to iCount - 1 do
					begin
						if (aBuffer[I].dwDisplayType = RESOURCEDISPLAYTYPE_SERVER) then
						begin
							sComputerName := aBuffer[I].lpRemoteName;
							while (Pos('\', sComputerName) > 0) do
								Delete(sComputerName, Pos('\', sComputerName), 1);
							List.Add(sComputerName);
						end;
						if ((aBuffer[I].dwUsage and RESOURCEUSAGE_CONTAINER) > 0) then
							EnumFunc(@aBuffer[I])
					end;
			finally
				WNetCloseEnum(hanEnum);
				Screen.Cursor := crDefault;
			end;
	end;

begin
	EnumFunc(nil);
end;

end.

{ Old History
	13.03.2002	tmuetze
		+ Added ChangeEnables function
	19.01.2002	tmuetze
		+ New procedure ExecuteWin32Program for executing programs, calling of the Internet browser and E-Mail client
		+ New function GetBuildInfo to extract the build info from executables and dlls
}

{
$Log: Tools.pas,v $
Revision 1.6  2002/09/25 12:12:49  tmuetze
Remote server support has been added, at the moment it is strict experimental

Revision 1.5  2002/08/28 14:51:22  tmuetze
AddBackslash function added

Revision 1.4  2002/05/06 06:24:23  tmuetze
Added CreateQuery functions

Revision 1.3  2002/04/25 07:14:47  tmuetze
New CVS powered comment block

}
