unit ServerUnit;

{$I mormot.defines.inc}

interface

uses
  Classes,
  SysUtils,
  mormot.core.base,
  mormot.core.interfaces,
  mormot.rest.http.server,
  mormot.rest.memserver,
  mormot.soa.core,
  mormot.core.os,
  SharedInterface;

type

  { TChatService }

  TChatService = class(TInterfacedObject,IChatService)
  protected
    fConnected: array of IChatCallback;
  public
    procedure Join(const pseudo: string; const callback: IChatCallback);
    procedure BlaBla(const pseudo,msg: string);
    procedure CallbackReleased(const callback: IInvokable; const interfaceName: RawUTF8);
  end;

  { TServer }

  TServer = class
  public
    procedure Run;
  end;

implementation

{ TServer }

procedure TServer.Run;
var
  HttpServer: TRestHttpServer;
  Server: TRestServerFullMemory;
  AChatService: IChatService;
begin
  Server := TRestServerFullMemory.CreateWithOwnModel([]);
  try
    Server.ServiceDefine(TChatService,[IChatService],sicShared).
      SetOptions([],[optExecLockedPerInterface]). // thread-safe fConnected[]
      ByPassAuthentication := true;
    HttpServer := TRestHttpServer.Create('8888',[Server],'+',useBidirSocket);
    try
      HttpServer.WebSocketsEnable(Server,PROJECTEST_TRANSMISSION_KEY).
        Settings.SetFullLog; // full verbose logs for this demo
      TextColor(ccLightGreen);
      writeln('WebSockets Chat Server running on localhost:8888'#13#10);
      TextColor(ccWhite);
      writeln('Please compile and run Client.exe'#13#10);
      TextColor(ccLightGray);
      writeln('Press [Enter] to quit'#13#10);
      TextColor(ccCyan);
      readln;
    finally
      HttpServer.Free;
    end;
  finally
    Server.Free;
  end;
end;

{ TChatService }

procedure TChatService.Join(const pseudo: string; const callback: IChatCallback);
begin
  InterfaceArrayAdd(fConnected,callback);
end;

procedure TChatService.BlaBla(const pseudo, msg: string);
var i: integer;
begin
  for i := high(fConnected) downto 0 do // downwards for InterfaceArrayDelete()
    try
      fConnected[i].NotifyBlaBla(pseudo, msg);
    except
      InterfaceArrayDelete(fConnected,i); // unsubscribe the callback on failure
    end;
end;

procedure TChatService.CallbackReleased(const callback: IInvokable; const interfaceName: RawUTF8);
begin
  if interfaceName='IChatCallback' then
    InterfaceArrayDelete(fConnected,callback);
end;

end.

