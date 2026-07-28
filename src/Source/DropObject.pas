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
// $Id: DropObject.pas,v 1.5 2006/10/22 06:04:28 rjmills Exp $

unit DropObject;

{$MODE Delphi}

interface

uses {$IFDEF FPC} LCLIntf, LCLType, LMessages, Messages, {$ELSE} Windows, Messages, {$ENDIF} SysUtils, Classes, Graphics, Controls, Forms, Dialogs, StdCtrls, ComCtrls, Db, ImgList, IBDatabase, IBQuery, IB, Globals, MarathonProjectCacheTypes, MarathonProjectCache, MarathonIDE, ScriptAs, rmCompatControls;

type
	TfrmDropObject = class(TForm)
		btnOK: TButton;
		btnCancel: TButton;
		lvObjects: TListView;
		lblDropPrompt: TLabel;
		ilResults : TImageList;
		lstErrors: TrmCollectionListBox;
		procedure btnOKClick(Sender: TObject);
		procedure FormShow(Sender: TObject);
	private
		{ Private declarations }
		FSuccess : Boolean;
		FDropList : TStringList;
		FDropItem : String;
		FDropCacheType : TGSSCacheType;
		FDropConnection : String;
		{ The schema the object lives in, so the generated DROP names the object
		  the editor was opened on rather than whatever an unqualified name
		  reaches. Empty on every server before Firebird 6. }
		FDropSchema : String;
		procedure WMBuggerOff(var Message : TMessage); message LM_USER + 101;
		procedure AddStatusItem(Status, StatResult: String; Severity: Integer);
		procedure DoDropObjects;
		procedure DoDrop(Item : TMarathonCacheBaseNode; SQL: String);
	public
		{ Public declarations }
		constructor CreateDrop(AOwner: TComponent; DropObjects : TStringList);
		constructor CreateDropObject(AOwner : TComponent; Connection : String; ObjectType : TGSSCacheType; ObjectName : String; ObjectSchema : String = '');
	end;

{ The statement that drops this object - see the implementation for what it
  used to be and why it is not that any more. Empty when the connection has
  gone, which the caller reports rather than running. }
function DropStatementForItem(Item: TMarathonCacheBaseNode): String;
function DropStatementForNamed(const AConnection, AName, ASchema: String;
  ACacheType: TGSSCacheType): String;

implementation

{ The identifier a DROP should name. Qualified when the node came from a named
  schema: an unqualified DROP outside the search path removes a different
  object, or nothing at all - and this dialog is the one place where getting
  that wrong destroys something. }
{ The statement that drops this object.

  It used to be built here, verb by verb, in a case statement that was a second
  copy of the one in ScriptAs - and the copies had already diverged: this one
  said "drop external function" for every function, so a Firebird 3 PSQL
  function could not be dropped from the tree at all (the engine refuses it,
  verified). ScriptAsDrop branches on the legacy flag, qualifies by schema and
  is checked against a live server, so this asks it rather than knowing.

  Empty when the connection has gone, which the caller reports rather than
  running. }
function DropStatementForItem(Item: TMarathonCacheBaseNode): String;
var
  Conn: TMarathonCacheConnection;
begin
  Result := '';
  if not (Item is TMarathonCacheObject) then
    Exit;
  Conn := CacheConnectionNamed(TMarathonCacheObject(Item).ConnectionName);
  if not Assigned(Conn) then
    Exit;
  Result := ScriptAsDrop(ItemScriptContext(Conn, Item), Item.Caption,
    Item.CacheType);
end;

{ The same for an object named rather than selected - the path the editors take
  when they drop what they are editing. }
function DropStatementForNamed(const AConnection, AName, ASchema: String;
  ACacheType: TGSSCacheType): String;
var
  Conn: TMarathonCacheConnection;
  Ctx: TScriptAsContext;
begin
  Result := '';
  Conn := CacheConnectionNamed(AConnection);
  if not Assigned(Conn) then
    Exit;
  Ctx := ConnScriptContext(Conn);
  Ctx.Schema := ASchema;
  Result := ScriptAsDrop(Ctx, AName, ACacheType);
end;

function DropIdent(Item: TMarathonCacheBaseNode): String;
var
  Conn: TMarathonCacheConnection;
begin
  Conn := MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[
    TMarathonCacheObject(Item).ConnectionName];
  Result := MakeQuotedIdent(Item.Caption, Conn.IsIB6, Conn.SQLDialect);
  if (Item is TMarathonCacheSchemaMember) and
     (TMarathonCacheSchemaMember(Item).Schema <> '') then
    Result := MakeQuotedIdent(TMarathonCacheSchemaMember(Item).Schema,
      Conn.IsIB6, Conn.SQLDialect) + '.' + Result;
end;

{$R *.lfm}

constructor TfrmDropObject.CreateDrop(AOwner : TComponent; DropObjects : TStringList);
begin
	inherited Create(AOwner);
	FDropList := DropObjects;
  btnOK.Enabled := False;
  btnCancel.Enabled := False;
  ShowModal;
end;

constructor TfrmDropObject.CreateDropObject(AOwner: TComponent; Connection: String; ObjectType: TGSSCacheType; ObjectName: String; ObjectSchema: String);
begin
	inherited Create(AOwner);
	FDropItem := ObjectName;
	FDropCacheType := ObjectType;
	FDropConnection := Connection;
	FDropSchema := ObjectSchema;

	FDropList := nil;
	btnOK.Enabled := False;
	btnCancel.Enabled := False;
	ShowModal;
end;

procedure TfrmDropObject.WMBuggerOff(var Message : TMessage);
begin
  btnOKClick(btnOK);
end;

procedure TfrmDropObject.btnOKClick(Sender: TObject);
begin
  if Assigned(FDropList) then
  begin
    case FDropList.Count of
      1 :
        begin
          if FSuccess then
            ModalResult := mrOK
          else
            ModalResult := mrCancel;
        end;
    else
      DoDropObjects;
    end;
  end
  else
  begin
    if FSuccess then
      ModalResult := mrOK
    else
      ModalResult := mrCancel;
  end;
end;

procedure TfrmDropObject.AddStatusItem(Status : String; StatResult : String; Severity : Integer);
begin
  if Severity = 1 then
    lstErrors.Add('[' + Status + '] ' + StatResult, 0, nil)
  else
    lstErrors.Add('[' + Status + '] ' + StatResult, 1, nil);
end;

procedure TfrmDropObject.DoDropObjects;
var
  Idx : Integer;
  SQL : String;
  Q : TIBQuery;
  DoIt : Boolean;
  Msg : String;
  Item : TMarathonCacheBaseNode;

begin
  btnOK.Enabled := False;
  btnCancel.Enabled := False;
  try

    for Idx := 0 to lvObjects.Items.Count - 1 do
    begin
      Item := TMarathonCacheBaseNode(lvObjects.Items.Item[Idx].Data);
      case Item.CacheType of
        ctDomain:
          begin
            Q := TIBQuery.Create(Self);
            try
              Q.Database := MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[TMarathonCacheObject(Item).ConnectionName].Connection;
              Q.Transaction := MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[TMarathonCacheObject(Item).ConnectionName].Transaction;

              Q.SQL.Text := 'select rdb$procedure_name, rdb$parameter_name from ' +
                            'rdb$procedure_parameters where rdb$field_source = ' +
                            AnsiQuotedStr(Item.Caption, '''') + ';';
              Q.Open;
              if Not (Q.BOF and Q.EOF) then
              begin
                DoIt := False;
                Msg := 'unsuccessful metadata update.' + #13#10 +
                       'column "' + AnsiUpperCase(Item.Caption) + '" is in use by the stored procedure "' + Q.FieldByName('rdb$procedure_name').AsString +
                       '" (local name "' + Q.FieldByName('rdb$parameter_name').AsString + '" and cannot be dropped.';
                AddStatusItem('Dropping ' + Item.Caption, Msg, 1);
              end
              else
                DoIt := True;
							Q.Close;
              Q.Transaction.Commit;
            finally
              Q.Free;
            end;
            if DoIt then
            begin
              SQL := DropStatementForItem(Item);
              DoDrop(Item, SQL);
            end;
          end;

        ctTable:
          begin
            SQL := DropStatementForItem(Item);
            DoDrop(Item, SQL);
          end;

        ctView:
          begin
            SQL := DropStatementForItem(Item);
            DoDrop(Item, SQL);
          end;

        ctSP:
          begin
            SQL := DropStatementForItem(Item);
            DoDrop(Item, SQL);
          end;

        ctTrigger:
          begin
            SQL := DropStatementForItem(Item);
            DoDrop(Item, SQL);
					end;

        ctGenerator:
          begin
            { DROP GENERATOR rather than a delete from the catalogue. The raw
              delete matched on name alone, so with schemas it could remove a
              generator of that name in another one - and it was never the
              supported way to drop a generator in any case. The older verb is
              used rather than DROP SEQUENCE because it works on every server
              this codebase still connects to, and matches ScriptAsDrop. }
            SQL := DropStatementForItem(Item);
            DoDrop(Item, SQL);
          end;

        ctException:
          begin
            SQL := DropStatementForItem(Item);
            DoDrop(Item, SQL);
          end;

        ctPackage:
          begin
            { DROP PACKAGE removes the body as well, so one statement covers a
              package with or without one. }
            SQL := DropStatementForItem(Item);
            DoDrop(Item, SQL);
          end;

        ctSchema:
          begin
            { Firebird refuses this while the schema still holds objects, and
              reports so itself - which is what should happen. Dropping the
              contents first is a decision for the user, not a side effect of
              confirming this dialog. }
            SQL := DropStatementForItem(Item);
            DoDrop(Item, SQL);
          end;

        ctUDF:
          begin
            SQL := DropStatementForItem(Item);
            DoDrop(Item, SQL);
          end;

      end;
    end;
  finally
    btnCancel.Caption := '&Close';
    btnCancel.Enabled := True;
  end;
end;

procedure TfrmDropObject.DoDrop(Item : TMarathonCacheBaseNode; SQL : String);
var
  Q : TIBQuery;

begin
  Q := TIBQuery.Create(Self);
  try
    try
      Q.Database := MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[TMarathonCacheObject(Item).ConnectionName].Connection;
			Q.Transaction := MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[TMarathonCacheObject(Item).ConnectionName].Transaction;

      Q.SQL.Text := SQL;
      Q.ExecSQL;
      Q.Transaction.Commit;

      AddStatusItem('Dropping ' + Item.Caption, 'Successful', 0);

      //write to script system
      MarathonIDEInstance.RecordToScript(SQL, TMarathonCacheObject(Item).ConnectionName);

      //update any open linked windows...
      { The schema too, so dropping one schema's object does not close an
                editor open on a same-named object in another. }
              if Item is TMarathonCacheSchemaMember then
                MarathonIDEInstance.CloseDroppedWindow(TMarathonCacheObject(Item).ConnectionName,
                  Item.Caption, TMarathonCacheSchemaMember(Item).Schema)
              else
                MarathonIDEInstance.CloseDroppedWindow(TMarathonCacheObject(Item).ConnectionName, Item.Caption);

      //update the tree view in the database manager...
      MarathonIDEInstance.CurrentProject.Cache.RemoveCacheItem(Item);



    except
      On E : EIBInterBaseError do
      begin
        Q.Transaction.Rollback;
        AddStatusItem('Dropping ' + Item.Caption, E.Message, 1);
      end;
      On E : Exception do
      begin
        Q.Transaction.RollBack;
        AddStatusItem('Dropping ' + Item.Caption, E.Message, 1);
      end;
    end;
  finally
    Q.Free;
  end;
end;

procedure TfrmDropObject.FormShow(Sender: TObject);
var
	SQL : String;
  Q : TIBQuery;
  Msg : String;
  Item : TMarathonCacheBaseNode;
  Idx : Integer;

begin
  if not Assigned(FDropList) then
  begin
		try
      Refresh;
      Repaint;

      FSuccess := False;

      Case FDropCacheType of
        ctSP:
          begin
            with lvObjects.Items.Add do
            begin
              Caption := FDropItem;
              SubItems.Add('Stored Procedure');
              ImageIndex := GetImageIndexForCacheType(FDropCacheType);
            end;
            SQL := DropStatementForNamed(FDropConnection, FDropItem, FDropSchema, FDropCacheType);
          end;

        ctTrigger:
          begin
            with lvObjects.Items.Add do
            begin
              Caption := FDropItem;
              SubItems.Add('Trigger');
              ImageIndex := GetImageIndexForCacheType(FDropCacheType);
            end;
						SQL := DropStatementForNamed(FDropConnection, FDropItem, FDropSchema, FDropCacheType);
          end;

        ctTable:
          begin
            with lvObjects.Items.Add do
            begin
              Caption := FDropItem;
              SubItems.Add('Table');
              ImageIndex := GetImageIndexForCacheType(FDropCacheType);
            end;
						SQL := DropStatementForNamed(FDropConnection, FDropItem, FDropSchema, FDropCacheType);
          end;

        ctException:
          begin
            with lvObjects.Items.Add do
            begin
              Caption := FDropItem;
              SubItems.Add('Exception');
              ImageIndex := GetImageIndexForCacheType(FDropCacheType);
            end;
            SQL := DropStatementForNamed(FDropConnection, FDropItem, FDropSchema, FDropCacheType);
          end;

        ctUDF:
          begin
            with lvObjects.Items.Add do
            begin
              Caption := FDropItem;
              SubItems.Add('UDF');
              ImageIndex := GetImageIndexForCacheType(FDropCacheType);
            end;
            SQL := DropStatementForNamed(FDropConnection, FDropItem, FDropSchema, FDropCacheType);
          end;

				ctView:
					begin
						with lvObjects.Items.Add do
						begin
							Caption := FDropItem;
							SubItems.Add('View');
							ImageIndex := GetImageIndexForCacheType(FDropCacheType);
						end;
						SQL := DropStatementForNamed(FDropConnection, FDropItem, FDropSchema, FDropCacheType);
					end;

        ctGenerator:
          begin
            //add warning here.....
						if MessageDlg('Firebird/InterBase does not store dependencies for Generators! If you drop a generator that is being used you will ' +
                          'receive errors during a restore and the dependent Stored Procedures and Triggers will not run. Are you sure ' +
                          'you wish to drop the Generator "' + FDropItem + '"?', mtWarning, [mbYes, mbNo], 0) = mrYes then
            begin
              with lvObjects.Items.Add do
              begin
                Caption := FDropItem;
                SubItems.Add('Generator');
                ImageIndex := GetImageIndexForCacheType(FDropCacheType);
              end;
              { This path has only the name, from the caller, so it cannot be
                qualified - it is the single-object dialog opened by name
                rather than from a tree node. }
              SQL := 'drop generator ' + MakeQuotedIdent(FDropItem, True, 3) + ';';
            end
            else
            begin
              Exit;
            end;
          end;

{        OBJ_CONSTRAINT:
          begin
            with lvObjects.Items.Add do
						begin
              Caption := FDropItem;
              SubItems.Add('Constraint');
//              ImageIndex := GetImageIndexForNodeType(dbntRoot);
            end;
            SQL := 'alter table ' + FDropTable + ' drop constraint ' + FDropItem + ';';
          end;

        OBJ_FIELD:
          begin
            with lvObjects.Items.Add do
            begin
              Caption := FDropItem;
              SubItems.Add('Column');
//              ImageIndex := GetImageIndexForNodeType(dbntRoot);
            end;
            SQL := 'alter table ' + FDropTable + ' drop ' + FDropItem + ';';
          end;

        OBJ_INDEX:
          begin
            with lvObjects.Items.Add do
            begin
              Caption := FDropItem;
              SubItems.Add('Index');
//              ImageIndex := GetImageIndexForNodeType(dbntRoot);
            end;
            SQL := 'drop index ' + FDropItem + ';';
          end;
 }

        ctDomain:
          begin
            //check whether its in use....
            with lvObjects.Items.Add do
            begin
              Caption := FDropItem;
              SubItems.Add('Domain');
              ImageIndex := GetImageIndexForCacheType(FDropCacheType);
            end;
            Q := TIBQuery.Create(Self);
            try
              Q.Database := MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[FDropConnection].Connection;
              Q.Transaction := MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[FDropConnection].Transaction;

              Q.SQL.Text := 'select rdb$procedure_name, rdb$parameter_name from rdb$procedure_parameters where rdb$field_source = ' + AnsiQuotedStr(FDropItem, '''') + ';';
              Q.Open;
              if Not (Q.BOF and Q.EOF) then
              begin
                Msg := 'unsuccessful metadata update.' + #13#10 +
                       'column "' + AnsiUpperCase(FDropItem) + '" is in use by the stored procedure "' + Q.FieldByName('rdb$procedure_name').AsString +
                       '" (local name "' + Q.FieldByName('rdb$parameter_name').AsString + '" and cannot be dropped.';
              end
							else
                Msg := '';
              Q.Close;
              Q.Transaction.Commit;
            finally
              Q.Free;
            end;
            SQL := DropStatementForNamed(FDropConnection, FDropItem, FDropSchema, FDropCacheType);
          end;
      else
        begin
          MessageDlg('Invalid Drop Type', mtError, [mbOK], 0);
          Exit;
        end;
      end;

      Q := TIBQuery.Create(Self);
      try
        Q.Database := MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[FDropConnection].Connection;
        Q.Transaction := MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[FDropConnection].Transaction;
        try
          if Msg <> '' then
            raise Exception.Create(Msg);


          Q.SQL.Text := SQL;
          Q.ExecSQL;
          Q.Transaction.Commit;

          //write to script system
          MarathonIDEInstance.RecordToScript(SQL, FDropConnection);
          MarathonIDEInstance.CurrentProject.Cache.RemoveCacheItemByName(FDropConnection, FDropItem, FDropCacheType);

          FSuccess := True;

          PostMessage(Self.Handle, WM_BUGGER_OFF, 0, 0);
        except
					On E : EIBInterBaseError do
          begin
            Q.Transaction.Rollback;
            AddStatusItem('Dropping ' + FDropItem, E.Message, 1);
            FSuccess := False;
          end;
          On E : Exception do
          begin
            Q.Transaction.Rollback;
            AddStatusItem('Dropping ' + FDropItem, E.Message, 1);
            FSuccess := False;
          end;
        end;
      finally
        Q.Free;
      end;
    finally
      btnOK.Enabled := True;
      btnOK.Setfocus;
    end;
  end
  else
  begin
    if FDropList.Count = 1 then
    begin
      try
        Refresh;
        Repaint;

        FSuccess := False;

        Item := TMarathonCacheBaseNode(FDropList.Objects[0]);

        if MessageDlg('Are you sure you wish to drop the object "' + Item.Caption + '"?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
        begin
          Case Item.CacheType of
            ctSP:
              begin
                with lvObjects.Items.Add do
								begin
                  Caption := Item.Caption;
                  SubItems.Add('Stored Procedure');
                  ImageIndex := Item.ImageIndex;
                end;
                SQL := DropStatementForItem(Item);
              end;

            ctTrigger:
              begin
                with lvObjects.Items.Add do
                begin
                  Caption := Item.Caption;
                  SubItems.Add('Trigger');
                  ImageIndex := Item.ImageIndex;
                end;
                SQL := DropStatementForItem(Item);
              end;

            ctTable:
              begin
                with lvObjects.Items.Add do
                begin
                  Caption := Item.Caption;
                  SubItems.Add('Table');
                  ImageIndex := Item.ImageIndex;
                end;
                SQL := DropStatementForItem(Item);
              end;

            ctException:
              begin
                with lvObjects.Items.Add do
                begin
                  Caption := Item.Caption;
                  SubItems.Add('Exception');
									ImageIndex := Item.ImageIndex;
                end;
                SQL := DropStatementForItem(Item);
              end;

            ctUDF:
              begin
                with lvObjects.Items.Add do
                begin
                  Caption := Item.Caption;
                  SubItems.Add('UDF');
                  ImageIndex := Item.ImageIndex;
                end;
                SQL := DropStatementForItem(Item);
              end;


            ctView:
              begin
                with lvObjects.Items.Add do
                begin
                  Caption := Item.Caption;
                  SubItems.Add('View');
                  ImageIndex := Item.ImageIndex;
                end;
                SQL := DropStatementForItem(Item);
              end;


            ctGenerator:
              begin
                //add warning here.....
								if MessageDlg('Firebird/InterBase does not store dependencies for Generators! If you drop a generator that is being used you will ' +
                              'receive errors during a restore and the dependent Stored Procedures and Triggers will not run. Are you sure ' +
                              'you wish to drop the Generator "' + Item.Caption + '"?', mtWarning, [mbYes, mbNo], 0) = mrYes then
                begin
									with lvObjects.Items.Add do
                  begin
                    Caption := Item.Caption;
                    SubItems.Add('Generator');
                    ImageIndex := Item.ImageIndex;
                  end;
                  { DROP GENERATOR rather than a delete from the catalogue. The raw
              delete matched on name alone, so with schemas it could remove a
              generator of that name in another one - and it was never the
              supported way to drop a generator in any case. The older verb is
              used rather than DROP SEQUENCE because it works on every server
              this codebase still connects to, and matches ScriptAsDrop. }
            SQL := DropStatementForItem(Item);
                end
                else
                begin
                  Exit;
                end;
              end;

    {        OBJ_CONSTRAINT:
              begin
                with lvObjects.Items.Add do
                begin
                  Caption := FDropItem;
                  SubItems.Add('Constraint');
    //              ImageIndex := GetImageIndexForNodeType(dbntRoot);
                end;
                SQL := 'alter table ' + FDropTable + ' drop constraint ' + FDropItem + ';';
              end;

            OBJ_FIELD:
              begin
                with lvObjects.Items.Add do
                begin
                  Caption := FDropItem;
                  SubItems.Add('Column');
    //              ImageIndex := GetImageIndexForNodeType(dbntRoot);
                end;
                SQL := 'alter table ' + FDropTable + ' drop ' + FDropItem + ';';
              end;

            OBJ_INDEX:
              begin
                with lvObjects.Items.Add do
								begin
                  Caption := FDropItem;
                  SubItems.Add('Index');
    //              ImageIndex := GetImageIndexForNodeType(dbntRoot);
                end;
                SQL := 'drop index ' + FDropItem + ';';
              end;
     }

            ctDomain:
              begin
                //check whether its in use....
                with lvObjects.Items.Add do
                begin
                  Caption := Item.Caption;
                  SubItems.Add('Domain');
                  ImageIndex := Item.ImageIndex;
                end;
                Q := TIBQuery.Create(Self);
                try
                  Q.Database := MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[TMarathonCacheObject(Item).ConnectionName].Connection;
                  Q.Transaction := MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[TMarathonCacheObject(Item).ConnectionName].Transaction;

                  Q.SQL.Text := 'select rdb$procedure_name, rdb$parameter_name from rdb$procedure_parameters where rdb$field_source = ' + AnsiQuotedStr(Item.Caption, '''') + ';';
                  Q.Open;
                  if Not (Q.BOF and Q.EOF) then
                  begin
                    Msg := 'unsuccessful metadata update.' + #13#10 +
                           'column "' + AnsiUpperCase(Item.Caption) + '" is in use by the stored procedure "' + Q.FieldByName('rdb$procedure_name').AsString +
                           '" (local name "' + Q.FieldByName('rdb$parameter_name').AsString + '" and cannot be dropped.';
                  end
                  else
                    Msg := '';
                  Q.Close;
                  Q.Transaction.Commit;
                finally
                  Q.Free;
                end;
                SQL := DropStatementForItem(Item);
              end;

            ctConnection,   //AC:
            ctServer:   //AC:
              begin
                MarathonIDEInstance.CurrentProject.Cache.RemoveCacheItem(Item);
                FSuccess := True;
                PostMessage(Self.Handle, WM_BUGGER_OFF, 0, 0);
                Exit;
              end;
          else
            begin
              MessageDlg('Invalid Drop Type', mtError, [mbOK], 0);
              Exit;
            end;
          end;

          Q := TIBQuery.Create(Self);
          try
            Q.Database := MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[TMarathonCacheObject(Item).ConnectionName].Connection;
            Q.Transaction := MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[TMarathonCacheObject(Item).ConnectionName].Transaction;
            try
              if Msg <> '' then
                raise Exception.Create(Msg);


              Q.SQL.Text := SQL;
              Q.ExecSQL;
              Q.Transaction.Commit;

              //write to script system
              MarathonIDEInstance.RecordToScript(SQL, TMarathonCacheObject(Item).ConnectionName);

              { The schema too, so dropping one schema's object does not close an
                editor open on a same-named object in another. }
              if Item is TMarathonCacheSchemaMember then
                MarathonIDEInstance.CloseDroppedWindow(TMarathonCacheObject(Item).ConnectionName,
                  Item.Caption, TMarathonCacheSchemaMember(Item).Schema)
              else
                MarathonIDEInstance.CloseDroppedWindow(TMarathonCacheObject(Item).ConnectionName, Item.Caption);

              MarathonIDEInstance.CurrentProject.Cache.RemoveCacheItem(Item);

              FSuccess := True;

              PostMessage(Self.Handle, WM_BUGGER_OFF, 0, 0);
            except
              On E : EIBInterBaseError do
              begin
                Q.Transaction.Rollback;
                AddStatusItem('Dropping ' + Item.Caption, E.Message, 1);
                FSuccess := False;
							end;
              On E : Exception do
              begin
                Q.Transaction.Rollback;
                AddStatusItem('Dropping ' + Item.Caption, E.Message, 1);
                FSuccess := False;
              end;
            end;
          finally
            Q.Free;
          end;
        end
        else
          PostMessage(Self.Handle, WM_BUGGER_OFF, 0, 0);
      finally
        btnOK.Enabled := True;
        btnOK.Setfocus;
      end;
    end
    else
    begin
      for Idx := 0 to FDropList.Count - 1 do
      begin
        Item := TMarathonCacheBaseNode(FDropList.Objects[Idx]);
        with lvObjects.Items.Add do
        begin
          Caption := Item.Caption;
					case Item.CacheType of
						ctDomain : SubItems.Add('Domain');
            ctTable : SubItems.Add('Table');
            ctView : SubItems.Add('View');
            ctSP : SubItems.Add('Stored Procedure');
            ctTrigger : SubItems.Add('Trigger');
            ctGenerator : SubItems.Add('Generator');
            ctException : SubItems.Add('Exception');
            ctUDF : SubItems.Add('UDF');
          end;
          ImageIndex := Item.ImageIndex;
          Data := Item;
				end;
      end;
      btnOK.Enabled := True;
      btnCancel.Enabled := True;
      btnOK.Setfocus;
    end;
  end;
end;

end.

{
$Log: DropObject.pas,v $
Revision 1.5  2006/10/22 06:04:28  rjmills
Fixes and Updates for Look and Feel in WinXP

Revision 1.4  2003/11/05 05:32:22  figmentsoft
Added ability to drop connections and server.  This is still considered to be experimental as I don't know if I'm implementing code as the author has intended?!  But it works for me.

Revision 1.3  2002/04/29 10:30:28  tmuetze
Converted from TIBGSSDataset to TIBQuery

Revision 1.2  2002/04/25 07:21:29  tmuetze
New CVS powered comment block

}