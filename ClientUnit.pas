unit ClientUnit;

{$I mormot.defines.inc}

interface

uses
  Classes,
  SysUtils,
  mormot.core.base,
  mormot.core.interfaces,
  mormot.rest.http.client,
  mormot.rest.client,
  mormot.soa.core,
  mormot.core.os,
  mormot.orm.core,
  SharedInterface;

type

  { TChatCallback }

  TChatCallback = class(TInterfacedCallback,IChatCallback)
  protected
    procedure NotifyBlaBla(const pseudo, msg: string);
  end;

  { TClient }

  TClient = class
  public
    procedure Run;
  end;


implementation

{ TClient }

procedure TClient.Run;
var
  Client: TRestHttpClientWebsockets;
  pseudo,msg: string;
  Service: IChatService;
  callback: IChatCallback;
begin
  writeln('Connecting to the local Websockets server...');
  Client := TRestHttpClientWebsockets.Create('127.0.0.1','8888',TOrmModel.Create([]));
  try
    Client.Model.Owner := Client;
    Client.WebSocketsUpgrade(PROJECTEST_TRANSMISSION_KEY);
    if not Client.ServerTimeStampSynchronize then
      raise EServiceException.Create(
        'Error connecting to the server: please run Server.exe');
    Client.ServiceDefine([IChatService],sicShared);
    if not Client.Services.Resolve(IChatService,Service) then
      raise EServiceException.Create('Service IChatService unavailable');
    try
      TextColor(ccWhite);
      writeln('Please enter you name, then press [Enter] to join the chat');
      writeln('Enter a void line to quit');
      write('@');
      TextColor(ccLightGray);
      readln(pseudo);
      if pseudo='' then
        exit;
      callback := TChatCallback.Create(Client,IChatCallback);
      Service.Join(pseudo, callback);
      TextColor(ccWhite);
      writeln('Please type a message, then press [Enter]');
      writeln('Enter a void line to quit');
      repeat
        TextColor(ccLightGray);
        write('>');
        readln(msg);
        if msg='' then
          break;
        Service.BlaBla(pseudo,msg);
      until false;
    finally
      callback := nil; // will unsubscribe from the remote publisher
      Service := nil;  // release the service local instance BEFORE Client.Free
    end;
  finally
    Client.Free;
  end;
end;

{ TChatCallback }

procedure TChatCallback.NotifyBlaBla(const pseudo, msg: string);
begin
  TextColor(ccLightBlue);
  writeln(#13'@',pseudo,' ',msg);
  TextColor(ccLightGray);
  write('>');
end;

end.

