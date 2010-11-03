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
// $Id: GSSRegistry.pas,v 1.4 2005/04/25 13:17:28 rjmills Exp $

unit GSSRegistry;

interface

uses
  Windows, SysUtils, Classes, Registry;

const
	// Marathon
	REG_BASE                     = '\Software\Marathon';
  REG_VERSION_BASE             = REG_BASE+'\3.X';
	REG_SETTINGS_BASE            = REG_VERSION_BASE + '\Settings';
	REG_SETTINGS_HIGHLIGHTING    = REG_SETTINGS_BASE + '\Highlighting';
	REG_SETTINGS_TOOLBARS        = REG_SETTINGS_BASE + '\Toolbars';
	REG_SETTINGS_SQLSMARTS       = REG_SETTINGS_BASE + '\SQLSmarts';
	REG_SETTINGS_EDITOR			     = REG_SETTINGS_BASE + '\Editor';
	REG_SETTINGS_EDITOR_FIND     = REG_SETTINGS_BASE + '\Editor\Find';
	REG_SETTINGS_SQLTRACE        = REG_SETTINGS_BASE + '\SQLTrace';
	REG_SETTINGS_FORMS           = REG_SETTINGS_BASE + '\Forms';
	REG_SETTINGS_SYNHELP         = REG_SETTINGS_BASE + '\SynHelp';
	REG_SETTINGS_RECENTPROJECTS  = REG_SETTINGS_BASE + '\RecentProjects';
	REG_SETTINGS_MARGINS         = REG_SETTINGS_BASE + '\Margins';
	REG_SETTINGS_PRINT           = REG_SETTINGS_BASE + '\Print';
	REG_SETTINGS_PLUGINS         = REG_SETTINGS_BASE + '\Plugins';

	// ScriptExecutive
	REG_SCREXEC									 = REG_SETTINGS_BASE + '\Script';

implementation

end.

{
$Log: GSSRegistry.pas,v $
Revision 1.4  2005/04/25 13:17:28  rjmills
*** empty log message ***

Revision 1.3  2002/09/23 10:34:11  tmuetze
Revised the SQL Trace functionality, e.g. TIB_Monitor options can now be customized via the Option dialog

Revision 1.2  2002/04/25 07:14:47  tmuetze
New CVS powered comment block

}
