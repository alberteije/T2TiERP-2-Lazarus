unit NfeConfiguracao;

{$mode objfpc}{$H+}

interface

uses
  HTTPDefs, BrookRESTActions, BrookUtils;

type

  TNfeConfiguracaoOptions = class(TBrookOptionsAction)
  end;

  TNfeConfiguracaoRetrieve = class(TBrookRetrieveAction)
    procedure Request({%H-}ARequest: TRequest; AResponse: TResponse); override;
  end;

  TNfeConfiguracaoShow = class(TBrookShowAction)
  end;

  TNfeConfiguracaoCreate = class(TBrookCreateAction)
  end;

  TNfeConfiguracaoUpdate = class(TBrookUpdateAction)
  end;

  TNfeConfiguracaoDestroy = class(TBrookDestroyAction)
  end;

implementation

procedure TNfeConfiguracaoRetrieve.Request(ARequest: TRequest; AResponse: TResponse);
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
  TNfeConfiguracaoOptions.Register('nfe_configuracao', '/nfe_configuracao');
  TNfeConfiguracaoRetrieve.Register('nfe_configuracao', '/nfe_configuracao/:campo/:filtro/');
  TNfeConfiguracaoShow.Register('nfe_configuracao', '/nfe_configuracao/:id');
  TNfeConfiguracaoCreate.Register('nfe_configuracao', '/nfe_configuracao');
  TNfeConfiguracaoUpdate.Register('nfe_configuracao', '/nfe_configuracao/:id');
  TNfeConfiguracaoDestroy.Register('nfe_configuracao', '/nfe_configuracao/:id');

end.
