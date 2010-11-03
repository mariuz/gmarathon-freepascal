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
// $Id: ExecutionLibrary.pas,v 1.2 2002/04/25 07:18:10 tmuetze Exp $

unit ExecutionLibrary;

interface

uses
  Classes, Windows, SysUtils, Forms;

type
  EPipeExecError = Exception;

  TLineAvailable = procedure(Sender : TComponent; Line : string) of Object;

  TExecuteProcess = class(TComponent)
  private
    FCommand : string;
    FLineAvailable : TLineAvailable;
    FExecError : TNotifyEvent;
    FExitCode : DWord;
  public
    procedure Execute;
  published
    property OnLineAvailable : TLineAvailable read FLineAvailable write FLineAvailable;
    property OnExecError : TNotifyEvent read FExecError write FExecError;
    property ExitCodeProcess : DWord read FExitCode;
    property Command : string read FCommand write FCommand;
  end;

implementation


procedure TExecuteProcess.Execute;
var
  cmd : string;
  StartupInfo : TStartupInfo;
  SecurityInfo : TSECURITYATTRIBUTES;
  Buffer : array[0..255] of char;
  BytesRead : DWord;
  BytesAvail : DWord;
  BytesUnread : DWord;
  i : integer;
  hp : THandle;
  ProcExitCode : DWord;

  ReadReadHandle : THandle;
  ReadWriteHandle : THandle;
  WriteReadHandle : THandle;
  WriteWriteHandle : THandle;

  ProcessInfo : TProcessInformation;

  Line : String;

begin
  Cmd := Command + #0;

  SecurityInfo.nLength := Sizeof(SecurityInfo);
  SecurityInfo.lpSecurityDescriptor := nil;
  SecurityInfo.bInheritHandle := TRUE;

  CreatePipe(ReadReadHandle, ReadWriteHandle, @SecurityInfo, 0);
  CreatePipe(WriteReadHandle, WriteWriteHandle, @SecurityInfo, 0);

  FillChar(StartupInfo,Sizeof(StartupInfo),#0);
  StartupInfo.cb := Sizeof(StartupInfo);
  StartupInfo.dwFlags := STARTF_USESHOWWINDOW or STARTF_USESTDHANDLES;
  StartupInfo.wShowWindow := SW_HIDE;
  StartupInfo.hStdInput:=ReadReadHandle;
  StartupInfo.hStdOutput:=WriteWriteHandle;
  StartupInfo.hStdError:=WriteWriteHandle;

  if not CreateProcess(nil, @Cmd[1], nil, nil, True, CREATE_NEW_CONSOLE or NORMAL_PRIORITY_CLASS, nil, nil, StartupInfo, ProcessInfo) then
  begin
    if Assigned(OnExecError) then
      OnExecError(Self);
    exit;
  end;

  CloseHandle(readReadHandle);
  CloseHandle(writeWriteHandle);

  Line := '';

  repeat
    sleep(100);
    PeekNamedPipe(writeReadHandle,@buffer[0],255, @bytesRead,@bytesAvail,@bytesUnread);
    hp:=OpenProcess(MUTANT_ALL_ACCESS, True, ProcessInfo.dwProcessId);
  until (bytesRead<>0) or (hp=0);

  repeat
    if PeekNamedPipe(writeReadHandle,@buffer[0],255,
                     @bytesRead,@bytesAvail,@bytesUnread) then
      if bytesRead<>0 then
        repeat
          readFile(writeReadHandle,buffer,255,bytesRead,nil);
          for i:=0 to bytesRead-1 do
            case buffer[i] of
              #10 : begin
                      if Assigned(FLineAvailable) then
                        FLineAvailable(Self, Line);
                      line:='';
                    end;
              #13 : ;
            else
              line:=line+buffer[i];
            end;
        until BytesRead=0;

    sleep(100);

    hp:=OpenProcess(MUTANT_ALL_ACCESS, TRUE, ProcessInfo.dwProcessId);
    GetExitCodeProcess(hp, ProcExitCode);

    FExitCode := exitCode;
  until (hp=0) or (exitCode<>STILL_ACTIVE);

  closeHandle(readWriteHandle);
  closeHandle(writeReadHandle);
end;

end.

{
$Log: ExecutionLibrary.pas,v $
Revision 1.2  2002/04/25 07:18:10  tmuetze
New CVS powered comment block

}
