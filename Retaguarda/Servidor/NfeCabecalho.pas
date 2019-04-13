unit NfeCabecalho;

{$mode objfpc}{$H+}

interface

uses
  HTTPDefs, BrookRESTActions, BrookUtils;

type

  TNfeCabecalhoOptions = class(TBrookOptionsAction)
  end;

  TNfeCabecalhoRetrieve = class(TBrookRetrieveAction)
    procedure Request({%H-}ARequest: TRequest; AResponse: TResponse); override;
  end;

  TNfeCabecalhoShow = class(TBrookShowAction)
  end;

  TNfeCabecalhoCreate = class(TBrookCreateAction)
  end;

  TNfeCabecalhoUpdate = class(TBrookUpdateAction)
  end;

  TNfeCabecalhoDestroy = class(TBrookDestroyAction)
  end;

implementation

procedure TNfeCabecalhoRetrieve.Request(ARequest: TRequest; AResponse: TResponse);
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
  TNfeCabecalhoOptions.Register('nfe_cabecalho', '/nfe_cabecalho');
  TNfeCabecalhoRetrieve.Register('nfe_cabecalho', '/nfe_cabecalho/:campo/:filtro/');
  TNfeCabecalhoShow.Register('nfe_cabecalho', '/nfe_cabecalho/:id');
  TNfeCabecalhoCreate.Register('nfe_cabecalho', '/nfe_cabecalho');
  TNfeCabecalhoUpdate.Register('nfe_cabecalho', '/nfe_cabecalho/:id');
  TNfeCabecalhoDestroy.Register('nfe_cabecalho', '/nfe_cabecalho/:id');

end.
