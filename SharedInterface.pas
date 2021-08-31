unit SharedInterface;

{$I mormot.defines.inc}

interface

uses
  SysUtils,
  mormot.core.base,
  mormot.core.interfaces,
  mormot.soa.server;

type

  { IChatCallback }

  IChatCallback = interface(IInvokable)
    ['{5369B3B3-0C9F-42EE-AC3D-44D514C33CE0}']
    procedure NotifyBlaBla(const pseudo, msg: string);
  end;

  { IChatService }

  IChatService = interface(IServiceWithCallbackReleased)
    ['{C5C4E8C5-B3A2-43CF-888F-AA8D77CFC074}']
    procedure Join(const pseudo: string; const callback: IChatCallback);
    procedure BlaBla(const pseudo, msg: string);
  end;

const
  PROJECTEST_TRANSMISSION_KEY = 'meow_privatekey';


implementation

initialization
  TInterfaceFactory.RegisterInterfaces([
    TypeInfo(IChatService),TypeInfo(IChatCallback)]);
end.
