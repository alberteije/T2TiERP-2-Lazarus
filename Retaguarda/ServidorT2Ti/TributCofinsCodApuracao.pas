unit TributCofinsCodApuracao;

{$mode objfpc}{$H+}

interface

uses
  HTTPDefs, BrookRESTActions, BrookUtils;

type

  TTributCofinsCodApuracaoOptions = class(TBrookOptionsAction)
  end;

  TTributCofinsCodApuracaoRetrieve = class(TBrookRetrieveAction)
    procedure Request({%H-}ARequest: TRequest; AResponse: TResponse); override;
  end;

  TTributCofinsCodApuracaoShow = class(TBrookShowAction)
  end;

  TTributCofinsCodApuracaoCreate = class(TBrookCreateAction)
  end;

  TTributCofinsCodApuracaoUpdate = class(TBrookUpdateAction)
  end;

  TTributCofinsCodApuracaoDestroy = class(TBrookDestroyAction)
  end;

implementation

procedure TTributCofinsCodApuracaoRetrieve.Request(ARequest: TRequest; AResponse: TResponse);
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
  TTributCofinsCodApuracaoOptions.Register('tribut_cofins_cod_apuracao', '/tribut_cofins_cod_apuracao');
  TTributCofinsCodApuracaoRetrieve.Register('tribut_cofins_cod_apuracao', '/tribut_cofins_cod_apuracao/:campo/:filtro/');
  TTributCofinsCodApuracaoShow.Register('tribut_cofins_cod_apuracao', '/tribut_cofins_cod_apuracao/:id');
  TTributCofinsCodApuracaoCreate.Register('tribut_cofins_cod_apuracao', '/tribut_cofins_cod_apuracao');
  TTributCofinsCodApuracaoUpdate.Register('tribut_cofins_cod_apuracao', '/tribut_cofins_cod_apuracao/:id');
  TTributCofinsCodApuracaoDestroy.Register('tribut_cofins_cod_apuracao', '/tribut_cofins_cod_apuracao/:id');

end.
