unit TributPisCodApuracao;

{$mode objfpc}{$H+}

interface

uses
  HTTPDefs, BrookRESTActions, BrookUtils;

type

  TTributPisCodApuracaoOptions = class(TBrookOptionsAction)
  end;

  TTributPisCodApuracaoRetrieve = class(TBrookRetrieveAction)
    procedure Request({%H-}ARequest: TRequest; AResponse: TResponse); override;
  end;

  TTributPisCodApuracaoShow = class(TBrookShowAction)
  end;

  TTributPisCodApuracaoCreate = class(TBrookCreateAction)
  end;

  TTributPisCodApuracaoUpdate = class(TBrookUpdateAction)
  end;

  TTributPisCodApuracaoDestroy = class(TBrookDestroyAction)
  end;

implementation

procedure TTributPisCodApuracaoRetrieve.Request(ARequest: TRequest; AResponse: TResponse);
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
  TTributPisCodApuracaoOptions.Register('tribut_pis_cod_apuracao', '/tribut_pis_cod_apuracao');
  TTributPisCodApuracaoRetrieve.Register('tribut_pis_cod_apuracao', '/tribut_pis_cod_apuracao/:campo/:filtro/');
  TTributPisCodApuracaoShow.Register('tribut_pis_cod_apuracao', '/tribut_pis_cod_apuracao/:id');
  TTributPisCodApuracaoCreate.Register('tribut_pis_cod_apuracao', '/tribut_pis_cod_apuracao');
  TTributPisCodApuracaoUpdate.Register('tribut_pis_cod_apuracao', '/tribut_pis_cod_apuracao/:id');
  TTributPisCodApuracaoDestroy.Register('tribut_pis_cod_apuracao', '/tribut_pis_cod_apuracao/:id');

end.
