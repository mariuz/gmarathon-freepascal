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
// $Id: BaseDocumentDataAwareForm.pas,v 1.4 2005/05/20 19:24:08 rjmills Exp $

//Comment block moved clear up a compiler warning. RJM

{
$Log: BaseDocumentDataAwareForm.pas,v $
Revision 1.4  2005/05/20 19:24:08  rjmills
Fix for Multi-Monitor support.  The GetMinMaxInfo routines have been pulled out of the respective files and placed in to the BaseDocumentDataAwareForm.  It now correctly handles Multi-Monitor support.

There are a couple of files that are descendant from BaseDocumentForm (PrintPreview, SQLForm, SQLTrace) and they now have the corrected routines as well.

UserEditor (Which has been removed for the time being) doesn't descend from BaseDocumentDataAwareForm and it should.  But it also has the corrected MinMax routine.

Revision 1.3  2005/04/13 16:04:25  rjmills
*** empty log message ***

Revision 1.2  2002/04/25 07:21:29  tmuetze
New CVS powered comment block

}

unit BaseDocumentDataAwareForm;

{$MODE Delphi}

interface

uses {$IFDEF FPC} LCLIntf, LCLType, LMessages, Messages, {$ELSE} Windows, Messages, {$ENDIF} SysUtils, Classes, Graphics, Controls, Forms, Dialogs, BaseDocumentForm, Globals, MarathonInternalInterfaces, MarathonIDE, MarathonProjectCacheTypes, Menus, MarathonProjectCache, SchemaNames;

type
	TfrmBaseDocumentDataAwareForm = class(TfrmBaseDocumentForm)
	private
    const
      WM_GETMINMAXINFO = $0024;
      WM_SYSCOMMAND = $0112;
    procedure MinMaxInfo(var Message: TLMessage); message WM_GETMINMAXINFO;
    procedure wmSysCommand(var Message: TLMessage); message WM_SYSCOMMAND;
		{ Private declarations }
	protected
		FCharSet : Byte;
		FDatabaseName: String;
		FObjectName: String;
		FNewObject: Boolean;
		FObjectModified: Boolean;
		FDropClose : Boolean;
		FIsInterbase6: Boolean;
		FSQLDialect: Integer;
		FObjectType: TGSSCacheType;
		{ The schema the object lives in, or '' for whatever an unqualified name
		  reaches through the search path. Empty on every server before Firebird 6,
		  which had no schemas. }
		FSchema: String;
    fIsMaximized : boolean;
		procedure SetDatabaseName(const Value: String); virtual;
		function GetObjectName : String; override;
		function GetObjectSchema : String; override;
 	public
		{ Public declarations }

		function GetActiveConnectionName : String; override;
		function GetActiveObjectType : TGSSCacheType; override;
		function GetObjectNewStatus : Boolean; override;
		procedure DropClose;
		property ConnectionName : String read FDatabaseName write SetDatabaseName;
		property IsInterbase6 : Boolean read FIsInterbase6 write FIsInterbase6;
		property SQLDialect : Integer read FSQLDialect write FSQLDialect;
		property ObjectName : String read FObjectName write FObjectName;
		property NewObject : Boolean read FNewObject write FNewObject;
		property ObjectModified : Boolean read FObjectModified write FObjectModified;
		property ObjectType : TGSSCacheType read FObjectType write FObjectType;

		{ Where the object lives. Set before loading it - the editors read their
		  metadata in the load, so setting this afterwards is too late. }
		property Schema : String read FSchema write FSchema;

		{ The connection of that name, or nil when there is none.

		  Every editor's SetDatabaseName read
		  MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[Value] and
		  dereferenced the result on the spot - up to eleven times in one setter -
		  so a name that is not in the project, which is what a connection removed
		  or renamed while its editor is open leaves behind, took the editor down
		  with an access violation rather than leaving it disconnected. This
		  answers nil for that, and for a form built before there is a project at
		  all, which the harnesses do. }
		function CacheConnection(const AName: String): TMarathonCacheConnection;

		{ True when this connection's server has schemas at all. Firebird 5 and
		  earlier have no RDB$SCHEMA_NAME and naming it is a hard error, so every
		  schema predicate has to disappear rather than evaluate to true. }
		function SupportsSchemas : Boolean;

		{ The fragment that narrows a catalogue query to this object's schema,
		  ready to append to a WHERE that already has a condition in it.

		  Every metadata query in every editor needs this. Without it a query that
		  filters on name alone matches the same name in every schema at once: on
		  a database holding S_ALPHA.DUPTAB(A1, A2) and S_BETA.DUPTAB(B1, B2, B3),
		  the column query for either returns all five columns and the editor shows
		  a table that does not exist.

		  Column is the schema column on the table being filtered, which is not
		  RDB$SCHEMA_NAME everywhere - see SchemaNames for the ones that differ. }
		function SchemaClause(const Alias : String = '';
			const Column : String = 'rdb$schema_name') : String;

		{ The object's name as generated DDL should spell it, qualified when it is
		  in a named schema so the statement acts on the object the queries found
		  rather than on whatever the search path reaches. }
		function QualifiedObjectName : String;

		{ Ties a column or parameter to the domain behind it, in the schema that
		  domain actually lives in.

		  RDB$RELATION_FIELDS, RDB$PROCEDURE_PARAMETERS and RDB$FUNCTION_ARGUMENTS
		  each record the domain's name in RDB$FIELD_SOURCE and, separately, where
		  it is in RDB$FIELD_SOURCE_SCHEMA_NAME. Joining RDB$FIELDS on the name
		  alone finds that name in every schema: with the same name in two, the
		  join returns a row per schema and the editor shows whichever came first,
		  which is how the table designer came to offer an ALTER widening a column
		  to a domain belonging somewhere else.

		  Empty before Firebird 6, which has no such column. }
		function FieldSourceJoin(const ARelAlias, AFieldAlias : String) : String;
	end;

implementation

{$R *.lfm}

procedure TfrmBaseDocumentDataAwareForm.DropClose;
begin
	FDropClose := True;
	Close;
end;

function TfrmBaseDocumentDataAwareForm.GetActiveConnectionName: String;
begin
	Result := FDatabaseName;
end;

function TfrmBaseDocumentDataAwareForm.GetActiveObjectType: TGSSCacheType;
begin
  Result := FObjectType;
end;

function TfrmBaseDocumentDataAwareForm.GetObjectName: String;
begin
  Result := FObjectName;
end;

function TfrmBaseDocumentDataAwareForm.GetObjectSchema: String;
begin
	Result := FSchema;
end;

function TfrmBaseDocumentDataAwareForm.GetObjectNewStatus: Boolean;
begin
	Result := FNewObject;
end;

function TfrmBaseDocumentDataAwareForm.CacheConnection(
	const AName: String): TMarathonCacheConnection;
begin
	{ MarathonIDE owns the one implementation - the sub-dialogs that are plain
	  forms need the same lookup and cannot reach a method here. }
	Result := CacheConnectionNamed(AName);
end;

function TfrmBaseDocumentDataAwareForm.SupportsSchemas: Boolean;
var
	Conn: TMarathonCacheConnection;
begin
	Result := False;
	if not Assigned(MarathonIDEInstance) or
	   not Assigned(MarathonIDEInstance.CurrentProject) then
		Exit;
	Conn := MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[FDatabaseName];
	Result := Assigned(Conn) and Conn.Connected and
		Conn.IsODSAtLeast(ODS_FB6_MAJOR, 0);
end;

function TfrmBaseDocumentDataAwareForm.SchemaClause(const Alias: String;
	const Column: String): String;
begin
	Result := SchemaPredicate(Alias, Column, FSchema, SupportsSchemas);
end;

function TfrmBaseDocumentDataAwareForm.FieldSourceJoin(
	const ARelAlias, AFieldAlias : String) : String;
begin
	Result := SchemaNames.FieldSourceJoin(ARelAlias, AFieldAlias,
		SupportsSchemas);
end;

function TfrmBaseDocumentDataAwareForm.QualifiedObjectName: String;
begin
	Result := SchemaNames.QualifiedIdent(FSchema, FObjectName, FIsInterbase6,
		FSQLDialect);
end;

procedure TfrmBaseDocumentDataAwareForm.SetDatabaseName(const Value: String);
begin
	FDatabaseName := Value;
	{ This is where an editor finds out which database it is about, including
	  when it is repointed at another one, so it is where the strip is decided. }
	UpdateEnvironmentBand;
end;

procedure TfrmBaseDocumentDataAwareForm.MinMaxInfo(var Message: TLMessage);
var
  // wRect : TRect;
  wMonitor : TMonitor;
  wMarathonMonitor : TMonitor;
begin
  inherited;
  { wMarathonMonitor := MarathonScreen.GetMonitor;
  if self.Monitor.MonitorNum = wMarathonMonitor.MonitorNum then //same screen as the IDE main window
  begin
     wMonitor := screen.monitors[self.Monitor.MonitorNum];
     // Message.MinMaxInfo.ptMaxSize.X := wMonitor.Width + (GetSystemMetrics(SM_CXSIZEFRAME) * 2);
     // Message.MinMaxInfo.ptMaxSize.y := wMonitor.Height - (MarathonIDEInstance.MainForm.FormHeight + abs(wMonitor.Top - MarathonIDEInstance.MainForm.FormTop));
     // Message.MinMaxInfo.ptMaxPosition.Y := abs(wMonitor.Top - MarathonIDEInstance.MainForm.FormTop) + MarathonIDEInstance.MainForm.FormHeight;
  end; }
end;

procedure TfrmBaseDocumentDataAwareForm.wmSysCommand(
  var message: TLMessage);
begin
   fIsMaximized := (message.wParam = SC_MAXIMIZE);
   inherited;
end;

end.


