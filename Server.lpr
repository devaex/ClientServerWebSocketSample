program Server;

{$I mormot.defines.inc}


uses
  {$I mormot.uses.inc}
  opensslsockets,
  SysUtils,
  mormot.core.log,
  mormot.net.ws.core,
  mormot.core.text,
  Classes,
  SharedInterface,
  ServerUnit;

var
  Server: TServer;
  HeaptraceFile: String;
begin

  {$IF DECLARED(heaptrc)}
  HeaptraceFile := ExtractFileDir(ParamStr(0)) + PathDelim + 'heaptrace.log';
  if FileExists(HeaptraceFile) then DeleteFile(HeaptraceFile);
  SetHeapTraceOutput(HeaptraceFile);
  {$ENDIF}

  with TSynLog.Family do begin // enable logging to file and to console
    Level := LOG_VERBOSE;
    EchoToConsole := LOG_VERBOSE;
    PerThreadLog := ptIdentifiedInOnFile;
  end;

  WebSocketLog := TSynLog; // verbose log of all WebSockets activity
  try
    Server := TServer.Create;
    try
      Server.Run;
    finally
      Server.Free;
    end;
  except
    on E: Exception do
      ConsoleShowFatalException(E);
  end;

end.

