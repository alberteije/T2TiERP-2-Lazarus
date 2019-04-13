unit Empresa;

{$mode objfpc}{$H+}

interface

uses
  HTTPDefs, BrookRESTActions, BrookUtils;

type

  TEmpresaOptions = class(TBrookOptionsAction)
  end;

  TEmpresaRetrieve = class(TBrookRetrieveAction)
    procedure Request({%H-}ARequest: TRequest; AResponse: TResponse); override;
  end;

  TEmpresaShow = class(TBrookShowAction)
  end;

  TEmpresaCreate = class(TBrookCreateAction)
  end;

  TEmpresaUpdate = class(TBrookUpdateAction)
  end;

  TEmpresaDestroy = class(TBrookDestroyAction)
  end;

implementation

procedure TEmpresaRetrieve.Request(ARequest: TRequest; AResponse: TResponse);
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
  TEmpresaOptions.Register('empresa', '/empresa');
  TEmpresaRetrieve.Register('empresa', '/empresa/:campo/:filtro/');
  TEmpresaShow.Register('empresa', '/empresa/:id');
  TEmpresaCreate.Register('empresa', '/empresa');
  TEmpresaUpdate.Register('empresa', '/empresa/:id');
  TEmpresaDestroy.Register('empresa', '/empresa/:id');

end.
