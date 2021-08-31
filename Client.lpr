program Client;

{$I mormot.defines.inc}


uses
  {$I mormot.uses.inc}
  opensslsockets,
  SysUtils,
  Classes,
  SharedInterface,
  ClientUnit;

var
  Client: TClient;
  HeaptraceFile : String;
begin
  {$IF DECLARED(heaptrc)}
  HeaptraceFile := ExtractFileDir(ParamStr(0)) + PathDelim + 'heaptrace-client.log';
  if FileExists(HeaptraceFile) then DeleteFile(HeaptraceFile);
  SetHeapTraceOutput(HeaptraceFile);
  {$ENDIF}

  Client := TClient.Create;
  try
    Client.Run;
  finally
    Client.Free;
  end;
end.

