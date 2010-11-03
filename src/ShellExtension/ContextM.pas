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
// $Id: ContextM.pas,v 1.3 2002/04/25 07:18:10 tmuetze Exp $

unit ContextM;

interface

uses
	Windows, ActiveX, ComObj, ShlObj, SysUtils, ComServ, ShellApi, Registry;

type
	TContextMenu = class(TComObject, IShellExtInit, IContextMenu)
	private
		FFileName: array[0..MAX_PATH] of Char;
	protected
		{ IShellExtInit }
		function IShellExtInit.Initialize = SEIInitialize; // Avoid compiler warning
		function SEIInitialize(pidlFolder: PItemIDList; lpdobj: IDataObject;
			hKeyProgID: HKEY): HResult; stdcall;
		{ IContextMenu }
		function QueryContextMenu(Menu: HMENU; indexMenu, idCmdFirst, idCmdLast,
			uFlags: UINT): HResult; stdcall;
		function InvokeCommand(var lpici: TCMInvokeCommandInfo): HResult; stdcall;
		function GetCommandString(idCmd, uType: UINT; pwReserved: PUINT;
			pszName: LPSTR; cchMax: UINT): HResult; stdcall;
	end;

const
	Class_ContextMenu: TGUID = '{EBDF1F20-C829-11D1-8233-0020AF3E97A9}';

implementation

uses
	GSSRegistry;

function TContextMenu.SEIInitialize(pidlFolder: PItemIDList; lpdobj: IDataObject;
	hKeyProgID: HKEY): HResult;
var
	StgMedium: TStgMedium;
	FormatEtc: TFormatEtc;
begin
	// Fail the call if lpdobj is Nil.
	if (lpdobj = nil) then begin
		Result := E_INVALIDARG;
		Exit;
	end;

	with FormatEtc do begin
		cfFormat := CF_HDROP;
		ptd      := nil;
		dwAspect := DVASPECT_CONTENT;
		lindex   := -1;
		tymed    := TYMED_HGLOBAL;
	end;

	// Render the data referenced by the IDataObject pointer to an HGLOBAL
	// storage medium in CF_HDROP format.
	Result := lpdobj.GetData(FormatEtc, StgMedium);
	if Failed(Result) then
		Exit;
	// If only one file is selected, retrieve the file name and store it in
	// FFileName. Otherwise fail the call.
	if (DragQueryFile(StgMedium.hGlobal, $FFFFFFFF, nil, 0) = 1) then
	begin
		DragQueryFile(StgMedium.hGlobal, 0, FFileName, SizeOf(FFileName));

		Result := NOERROR;
	end
	else
	begin
		FFileName[0] := #0;
		Result := E_FAIL;
	end;
	ReleaseStgMedium(StgMedium);
end;

function TContextMenu.QueryContextMenu(Menu: HMENU; indexMenu, idCmdFirst,
					idCmdLast, uFlags: UINT): HResult;
begin
	Result := 0; // or use MakeResult(SEVERITY_SUCCESS, FACILITY_NULL, 0);

	if ((uFlags and $0000000F) = CMF_NORMAL) or ((uFlags and CMF_EXPLORE) <> 0) then
	begin
		// Add one menu item to context menu
		InsertMenu(Menu, indexMenu, MF_STRING or MF_BYPOSITION, idCmdFirst, 'Marathon project properties...');

		// Return number of menu items added
		Result := 1; // or use MakeResult(SEVERITY_SUCCESS, FACILITY_NULL, 1)
	end;
end;

function TContextMenu.InvokeCommand(var lpici: TCMInvokeCommandInfo): HResult;
var
	R : TRegistry;
	MPath : String;
	si : TStartupInfo;
	pi : TProcessInformation;

begin
	// Make sure we are not being called by an application
	if (HiWord(Integer(lpici.lpVerb)) <> 0) then
	begin
		Result := E_FAIL;
		Exit;
	end;

	// Make sure we aren't being passed an invalid argument number
	if (LoWord(lpici.lpVerb) <> 0) then begin
		Result := E_INVALIDARG;
		Exit;
	end;

	//get the path for Marathon...
	MPath := '';
	R := TRegistry.Create;
	try
		if R.OpenKey(REG_BASE, False) then
		begin
			if R.ValueExists('Home') then
			begin
				MPath := R.ReadString('Home');
				if Length(MPath) > 0 then
				begin
					if MPath[Length(MPath)] <> '\' then
						MPath := MPath + '\';
				end;
			end
			else
				MessageBox(lpici.hWnd, 'Unable to open Marathon home registry key.', 'Error', MB_ICONError or MB_OK);
			R.CloseKey;
		end
		else
			MessageBox(lpici.hWnd, 'Unable to open Marathon home registry key.', 'Error', MB_ICONError or MB_OK);
	finally
		R.Free;
	end;
	if MPath = '' then
		MessageBox(lpici.hWnd, 'Unable to find Marathon home folder.', 'Error', MB_ICONError or MB_OK)
	else
	begin
		FillChar(si, SizeOf(TStartupInfo), 0);
		si.cb := SizeOf(TStartupInfo);
		FillChar(pi, SizeOf(TProcessInformation), 0);
		CreateProcess(nil, PChar(MPath + 'marathon.exe "' + FFileName + '" /p'), nil, nil,
			False, 0, nil, nil, si, pi);
	end;

	Result := NOERROR;
end;

function TContextMenu.GetCommandString(idCmd, uType: UINT; pwReserved: PUINT;
	pszName: LPSTR; cchMax: UINT): HRESULT;
begin
	if (idCmd = 0) then begin
		if (uType = GCS_HELPTEXT) then
			// return help string for menu item
			StrCopy(pszName, 'View\Edit Marathon project properties');
		Result := NOERROR;
  end
  else
    Result := E_INVALIDARG;
end;

type
  TContextMenuFactory = class(TComObjectFactory)
  public
    procedure UpdateRegistry(Register: Boolean); override;
  end;

procedure TContextMenuFactory.UpdateRegistry(Register: Boolean);
var
	ClassID: string;
begin
	if Register then
	begin
		inherited UpdateRegistry(Register);

		ClassID := GUIDToString(Class_ContextMenu);
		CreateRegKey('XMPRFile\shellex', '', '');
		CreateRegKey('XMPRFile\shellex\ContextMenuHandlers', '', '');
		CreateRegKey('XMPRFile\shellex\ContextMenuHandlers\mshellmenu', '', ClassID);

		if (Win32Platform = VER_PLATFORM_WIN32_NT) then
			with TRegistry.Create do
				try
					RootKey := HKEY_LOCAL_MACHINE;
					OpenKey('SOFTWARE\Microsoft\Windows\CurrentVersion\Shell Extensions', True);
					OpenKey('Approved', True);
					WriteString(ClassID, 'Marathon Project Properties Extension');
				finally
					Free;
				end;
	end
	else
	begin
		DeleteRegKey('XMPRFile\shellex\ContextMenuHandlers\ContMenu');
		DeleteRegKey('XMPRFile\shellex\ContextMenuHandlers');
		DeleteRegKey('XMPRFile\shellex');

		inherited UpdateRegistry(Register);
	end;
end;

initialization
	TContextMenuFactory.Create(ComServer, TContextMenu, Class_ContextMenu, '', 'Marathon Project Properties Extension', ciMultiInstance, tmApartment);
end.

{
$Log: ContextM.pas,v $
Revision 1.3  2002/04/25 07:18:10  tmuetze
New CVS powered comment block

}
