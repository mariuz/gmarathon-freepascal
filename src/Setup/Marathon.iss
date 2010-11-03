;{******************************************************************}
;{ The contents of this file are used with permission, subject to   }
;{ the Mozilla Public License Version 1.1 (the "License"); you may  }
;{ not use this file except in compliance with the License. You may }
;{ obtain a copy of the License at                                  }
;{ http://www.mozilla.org/MPL/MPL-1.1.html                          }
;{                                                                  }
;{ Software distributed under the License is distributed on an      }
;{ "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, either express or   }
;{ implied. See the License for the specific language governing     }
;{ rights and limitations under the License.                        }
;{                                                                  }
;{******************************************************************}
; $Id: Marathon.iss,v 1.22 2004/01/14 17:04:05 tmuetze Exp $

#define AppVersion ReadIni(AddBackslash(SourcePath) + "..\..\release.ini","releases","current") + ' ' + ReadIni(AddBackslash(SourcePath) + "..\..\release.ini","releases","programstate")

[Setup]
AppName=Marathon
AppId=Marathon
AppVersion={#AppVersion}
AppVerName=Marathon {#AppVersion}
AppCopyright=Copyright © 2001-2004 Marathon Open Source Project
AppPublisher=Marathon Open Source Project
AppPublisherURL=http://gmarathon.sourceforge.net
AppSupportURL=http://gmarathon.sourceforge.net
AppUpdatesURL=http://gmarathon.sourceforge.net
AppMutex=Marathon
AllowNoIcons=true
AlwaysShowComponentsList=true
AlwaysShowDirOnReadyPage=true
AlwaysShowGroupOnReadyPage=true

ChangesAssociations=true
Compression=bzip
CreateAppDir=true
CreateUninstallRegKey=true

DefaultDirName={pf}\Marathon
DefaultGroupName=Marathon
DirExistsWarning=auto
DisableDirPage=false
DisableStartupPrompt=false
DisableProgramGroupPage=false

FlatComponentsList=true

LicenseFile=Setup\MPL-1.1.txt

MinVersion=4.00.950,4.00.1381

OutputDir=Setup
OutputBaseFilename=Setup

ShowComponentSizes=true
SourceDir=..\

UninstallDisplayIcon={app}\Marathon.exe
UninstallLogMode=append
UninstallFilesDir={app}
Uninstallable=true
UsePreviousAppDir=true
UsePreviousGroup=true
UsePreviousSetupType=true

WindowShowCaption=true
WindowStartMaximized=false
WindowVisible=false
WindowResizable=true
WizardImageFile=Setup\Images\WizMarathonImage.bmp
WizardImageBackColor=$808000
WizardSmallImageFile=Setup\Images\WizMarathonSmallImage.bmp

[Components]
Name: ApplicationFiles; Description: {ini:{code:GetFile|{tmp}\Lang.ini},{language},ApplicationFiles|Application files needed to run Marathon}; Types: full compact custom; Flags: fixed
Name: HelpFiles; Description: {ini:{code:GetFile|{tmp}\Lang.ini},{language},HelpFiles|The online help}; Types: full compact custom; Flags: fixed
Name: CodeSnippetLibrary; Description: {ini:{code:GetFile|{tmp}\Lang.ini},{language},CodeSnippetLibrary|Code Snippets, samples and Stored Procedure library}; Types: full custom
Name: Plugins; Description: {ini:{code:GetFile|{tmp}\Lang.ini},{language},Plugins|Plugins that enhance the functionality of Marathon}; Types: full custom
Name: ToolsAPI; Description: {ini:{code:GetFile|{tmp}\Lang.ini},{language},ToolsAPI|Tools API related files and examples on how-to write your own plugins}; Types: full custom

[Tasks]
Name: desktopicon; Description: {ini:{code:GetFile|{tmp}\Lang.ini},{language},DesktopIcon|Create a Marathon &Desktop icon}; GroupDescription: {ini:{code:GetFile|{tmp}\Lang.ini},{language},GroupDescription|Additional icons:}
Name: quicklaunchicon; Description: {ini:{code:GetFile|{tmp}\Lang.ini},{language},QuickLaunchIcon|Create a Marathon &Quick Launch icon}; GroupDescription: {ini:{code:GetFile|{tmp}\Lang.ini},{language},GroupDescription|Additional icons:}; Flags: unchecked

[Dirs]
Name: {app}\Projects
Name: {app}\Scripts

[Files]
Source: Source\Marathon.exe; DestDir: {app}; DestName: Marathon.exe; Components: ApplicationFiles; Flags: ignoreversion
Source: ScriptExec\ScrExec.exe; DestDir: {app}; DestName: ScrExec.exe; Components: ApplicationFiles; Flags: ignoreversion
Source: CreateDBWizard\CDatabse.dll; DestDir: {app}; DestName: CDatabse.dll; Components: ApplicationFiles; Flags: regserver ignoreversion
Source: MetaExtract\GSSScript.dll; DestDir: {app}; DestName: GSSScript.dll; Components: ApplicationFiles; Flags: regserver ignoreversion
Source: ShellExtension\MShellmenu.dll; DestDir: {app}; DestName: MShellmenu.dll; Components: ApplicationFiles; Flags: regserver ignoreversion
Source: Source\Keybind.dat; DestDir: {app}; DestName: Keybind.dat; Components: ApplicationFiles; Flags: ignoreversion
Source: Source\SQLInsight.dat; DestDir: {app}; DestName: SQLInsight.dat; Components: ApplicationFiles; Flags: ignoreversion
Source: Setup\MPL-1.1.txt; DestDir: {app}; DestName: MPL-1.1.txt; Components: ApplicationFiles; Flags: ignoreversion
Source: Setup\IB60SQLReference.htm; DestDir: {app}; DestName: IB60SQLReference.htm; Components: ApplicationFiles; Flags: ignoreversion
;Source: Setup\ReleaseNotes.htm; DestDir: {app}; DestName: ReleaseNotes.htm; Components: ApplicationFiles; CopyMode: alwaysoverwrite

Source: Help\Marathon.hlp; DestDir: {app}\Help; DestName: Marathon.hlp; Components: HelpFiles; Flags: ignoreversion
Source: Help\Marathon.cnt; DestDir: {app}\Help; DestName: Marathon.cnt; Components: HelpFiles; Flags: ignoreversion
Source: Help\Marathon.fts; DestDir: {app}\Help; DestName: Marathon.fts; Components: HelpFiles; Flags: ignoreversion
Source: Setup\SQLRef.hlp; DestDir: {app}\Help; DestName: SQLRef.hlp; Components: HelpFiles; Flags: ignoreversion
Source: Setup\SQLRef.cnt; DestDir: {app}\Help; DestName: SQLRef.cnt; Components: HelpFiles; Flags: ignoreversion

Source: Plugins\AutoIncFieldWizard\autoinc.dll; DestDir: {app}\Plugins; DestName: Autoinc.dll; Components: Plugins; Flags: ignoreversion
Source: Plugins\FreeIBCompsSQL\updatesql.dll; DestDir: {app}\Plugins; DestName: UpdateSQL.dll; Components: Plugins; Flags: ignoreversion

Source: Setup\Snippets\Queries\*.*; DestDir: {app}\Snippets\Queries; Components: CodeSnippetLibrary; Flags: ignoreversion
Source: Setup\Snippets\Standard Headers\*.*; DestDir: {app}\Snippets\Standard Headers; Components: CodeSnippetLibrary; Flags: ignoreversion
Source: Setup\Snippets\Stored Proc Library\*.*; DestDir: {app}\Snippets\Stored Proc Library; Components: CodeSnippetLibrary; Flags: ignoreversion

Source: Source\GimbalToolsAPI.pas; DestDir: {app}\ToolsAPI\lib; DestName: GimbalToolsAPI.pas; Components: ToolsAPI; Flags: ignoreversion
Source: Plugins\AutoIncFieldWizard\Autoinc.dpr; DestDir: {app}\ToolsAPI\Autoinc; DestName: autoinc.dpr; Components: ToolsAPI; Flags: ignoreversion
Source: Plugins\AutoIncFieldWizard\Autoinc.res; DestDir: {app}\ToolsAPI\Autoinc; DestName: autoinc.res; Components: ToolsAPI; Flags: ignoreversion
Source: Plugins\AutoIncFieldWizard\AutoIncrementFieldWizard.dfm; DestDir: {app}\ToolsAPI\Autoinc; DestName: AutoIncrementFieldWizard.dfm; Components: ToolsAPI; Flags: ignoreversion
Source: Plugins\AutoIncFieldWizard\AutoIncrementFieldWizard.pas; DestDir: {app}\ToolsAPI\Autoinc; DestName: AutoIncrementFieldWizard.pas; Components: ToolsAPI; Flags: ignoreversion
Source: Plugins\AutoIncFieldWizard\AutoIncrementFieldWizardPlugin.pas; DestDir: {app}\ToolsAPI\Autoinc; DestName: AutoIncrementFieldWizardPlugin.pas; Components: ToolsAPI; Flags: ignoreversion
Source: Plugins\FreeIBCompsSQL\FreeIBCompsSQL.dfm; DestDir: {app}\ToolsAPI\UpdateSQL; DestName: FreeIBCompsSQL.dfm; Components: ToolsAPI; Flags: ignoreversion
Source: Plugins\FreeIBCompsSQL\FreeIBCompsSQL.pas; DestDir: {app}\ToolsAPI\UpdateSQL; DestName: FreeIBCompsSQL.pas; Components: ToolsAPI; Flags: ignoreversion
Source: Plugins\FreeIBCompsSQL\UpdateSQL.dpr; DestDir: {app}\ToolsAPI\UpdateSQL; DestName: updatesql.dpr; Components: ToolsAPI; Flags: ignoreversion
Source: Plugins\FreeIBCompsSQL\UpdateSQL.res; DestDir: {app}\ToolsAPI\UpdateSQL; DestName: updatesql.res; Components: ToolsAPI; Flags: ignoreversion
Source: Plugins\FreeIBCompsSQL\UpdateSQLPlugin.pas; DestDir: {app}\ToolsAPI\UpdateSQL; DestName: UpdateSQLPlugin.pas; Components: ToolsAPI; Flags: ignoreversion

Source: Setup\Localization\Lang.ini; DestDir: {tmp}; Flags: dontcopy

[Icons]
Name: {group}\Marathon; Filename: {app}\Marathon.exe; WorkingDir: {app}; IconFilename: {app}\Marathon.exe; IconIndex: 0; Comment: {ini:{code:GetFile|{tmp}\Lang.ini},{language},MarathonIcon|Opens Marathon}
Name: {group}\Marathon Script Executive; Filename: {app}\ScrExec.exe; WorkingDir: {app}; IconFilename: {app}\ScrExec.exe; IconIndex: 0; Comment: {ini:{code:GetFile|{tmp}\Lang.ini},{language},ScriptExecutiveIcon|Opens Marathon Script Executive}
Name: {group}\Marathon Help; Filename: {app}\Help\Marathon.hlp; WorkingDir: {app}\Help; IconFilename: {app}\ScrExec.exe; IconIndex: 0; Comment: {ini:{code:GetFile|{tmp}\Lang.ini},{language},HelpIcon|Opens Marathon Help}
Name: {group}\Mozilla Public License (MPL); Filename: {app}\MPL-1.1.txt; WorkingDir: {app}; Comment: {ini:{code:GetFile|{tmp}\Lang.ini},{language},MPLIcon|Shows the Mozilla Public License (MPL) which Marathon uses}
Name: {group}\InterBase & SQL Reference; Filename: {app}\IB60SQLReference.htm; WorkingDir: {app}; Comment: {ini:{code:GetFile|{tmp}\Lang.ini},{language},InterBaseSQLIcon|Shows the InterBase & SQL reference}
;Name: {group}\ReleaseNotes.htm; Filename: {app}\ReleaseNotes.htm; WorkingDir: {app}; Comment: {ini:{code:GetFile|{tmp}\Lang.ini},{language},ReleaseNotesIcon|Shows the Release Notes of the current release}

Name: {userdesktop}\Marathon; Filename: {app}\Marathon.exe; WorkingDir: {app}; Tasks: desktopicon
Name: {userappdata}\Microsoft\Internet Explorer\Quick Launch\Marathon; WorkingDir: {app}; Filename: {app}\Marathon.exe; Tasks: quicklaunchicon

[Registry]
Root: HKCU; SubKey: Software\Marathon\Settings\Plugins; ValueType: string; Flags: uninsdeletekey; ValueName: AutoIncrement Field Wizard; ValueData: {app}\Plugins\autoinc.dll; Components: Plugins
Root: HKCU; SubKey: Software\Marathon\Settings\Plugins; ValueType: string; Flags: uninsdeletekey; ValueName: Generate SQL for FreeIB/IBExpress; ValueData: {app}\Plugins\updatesql.dll; Components: Plugins
Root: HKCU; SubKey: Software\Marathon; Flags: uninsdeletekey
Root: HKCU; SubKey: Software\Marathon; ValueType: string; Flags: uninsdeletekey; ValueName: Home; ValueData: {app}

[Run]
Filename: {app}\Marathon.exe; Description: {ini:{code:GetFile|{tmp}\Lang.ini},{language},LaunchMarathon|Launch Marathon}; Flags: nowait postinstall skipifsilent

[Languages]
Name: en; MessagesFile: Setup\Localization\English.isl
Name: de; MessagesFile: Setup\Localization\German.isl
Name: es; MessagesFile: Setup\Localization\Spanish.isl
Name: fr; MessagesFile: Setup\Localization\French.isl
Name: it; MessagesFile: Setup\Localization\Italian.isl
Name: pt; MessagesFile: Setup\Localization\PortugueseStd.isl

[Messages]
BeveledLabel=The SQL Tool for Firebird && InterBase
de.BeveledLabel=Das SQL Tool für Firebird && InterBase
pt.BeveledLabel=A Ferramenta SQL para o Firebird && InterBase

[_ISTool]
UseAbsolutePaths=false
Use7zip=false

[Code]
function InitializeSetup(): Boolean;
begin
  Result := ExtractTemporaryFile('Lang.ini');
end;

function GetFile(Default: String): String;
begin
  Result := ExpandConstant('{tmp}\Lang.ini');
end;

begin
end.

; $Log: Marathon.iss,v $
; Revision 1.22  2004/01/14 17:04:05  tmuetze
; Tweaked the version string a bit, some minor localization issues
;
; Revision 1.21  2003/12/01 01:20:48  carlosmacao
; Get ride of [Types] section
;
; Revision 1.20  2003/11/25 10:02:07  carlosmacao
; Compatibility with InnoSetup 4.0.9, localization and show the version before install
;
; Revision 1.19  2003/03/12 18:58:57  tmuetze
; compatibility with InnoSetup 3.0.6.2
;
; Revision 1.18  2002/12/19 19:35:46  tmuetze
; ISX references removed
;
; Revision 1.17  2002/06/14 10:24:47  tmuetze
; Corrected the source path of the SQLRef.* files
;
; Revision 1.16  2002/06/14 10:02:31  tmuetze
; Added SQLRef help files for the context sensitive keyword help
;
; Revision 1.15  2002/05/25 12:43:32  tmuetze
; Done some slight enhancements and added the InterBase 6 SQL reference file
;
; Revision 1.14  2002/04/25 08:16:54  tmuetze
; Fixed some wording
;
; Revision 1.13  2002/04/25 07:14:47  tmuetze
; New CVS powered comment block
;
; Revision 1.12  2002/04/24 13:41:41  tmuetze
; New cvs powered comment block
