unit Banco;

{$mode objfpc}{$H+}

interface

uses
  HTTPDefs, BrookRESTActions, BrookUtils;

type

  TBancoOptions = class(TBrookOptionsAction)
  end;

  TBancoRetrieve = class(TBrookRetrieveAction)
    procedure Request({%H-}ARequest: TRequest; AResponse: TResponse); override;
  end;

  TBancoShow = class(TBrookShowAction)
  end;

  TBancoCreate = class(TBrookCreateAction)
  end;

  TBancoUpdate = class(TBrookUpdateAction)
  end;

  TBancoDestroy = class(TBrookDestroyAction)
  end;

implementation

procedure TBancoRetrieve.Request(ARequest: TRequest; AResponse: TResponse);
var
  Campo: String;
  Filtro: String;
begin
  Campo := Values['campo'].AsString;
  Filtro := Values['filtro'].AsString;

  Values.Clear;

  Table.Where(Campo + ' LIKE "%' + Filtro + '%"');
  inherited Request(ARequest, AResponse);
end;

initialization
  TBancoOptions.Register('banco', '/banco');
  TBancoRetrieve.Register('banco', '/banco/:campo/:filtro/');
  TBancoShow.Register('banco', '/banco/:id');
  TBancoCreate.Register('banco', '/banco');
  TBancoUpdate.Register('banco', '/banco/:id');
  TBancoDestroy.Register('banco', '/banco/:id');

end.
