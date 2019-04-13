unit NfeDetalheImpostoPis;

{$mode objfpc}{$H+}

interface

uses
  HTTPDefs, BrookRESTActions, BrookUtils, FPJson, SysUtils, BrookHTTPConsts;

type

  TNfeDetalheImpostoPisOptions = class(TBrookOptionsAction)
  end;

  TNfeDetalheImpostoPisRetrieve = class(TBrookRetrieveAction)
    procedure Request({%H-}ARequest: TRequest; AResponse: TResponse); override;
  end;

  TNfeDetalheImpostoPisShow = class(TBrookShowAction)
  end;

  TNfeDetalheImpostoPisCreate = class(TBrookCreateAction)
  end;

  TNfeDetalheImpostoPisUpdate = class(TBrookUpdateAction)
  end;

  TNfeDetalheImpostoPisDestroy = class(TBrookDestroyAction)
  end;

implementation

procedure TNfeDetalheImpostoPisRetrieve.Request(ARequest: TRequest; AResponse: TResponse);
var
  VRow: TJSONObject;
  Campo: String;
  Filtro: String;
begin
  Campo := Values['campo'].AsString;
  Filtro := Values['filtro'].AsString;

  Values.Clear;

  Table.Where(Campo + ' = "' + Filtro + '"');

  if Execute then
  begin
    Table.GetRow(VRow);
    try
      Write(VRow.AsJSON);
    finally
      FreeAndNil(VRow);
    end;
  end
  else
  begin
    AResponse.Code := BROOK_HTTP_STATUS_CODE_NOT_FOUND;
    AResponse.CodeText := BROOK_HTTP_REASON_PHRASE_NOT_FOUND;
  end;

  //inherited Request(ARequest, AResponse);
end;

initialization
  TNfeDetalheImpostoPisOptions.Register('nfe_detalhe_imposto_pis', '/nfe_detalhe_imposto_pis');
  TNfeDetalheImpostoPisRetrieve.Register('nfe_detalhe_imposto_pis', '/nfe_detalhe_imposto_pis/:campo/:filtro/');
  TNfeDetalheImpostoPisShow.Register('nfe_detalhe_imposto_pis', '/nfe_detalhe_imposto_pis/:id');
  TNfeDetalheImpostoPisCreate.Register('nfe_detalhe_imposto_pis', '/nfe_detalhe_imposto_pis');
  TNfeDetalheImpostoPisUpdate.Register('nfe_detalhe_imposto_pis', '/nfe_detalhe_imposto_pis/:id');
  TNfeDetalheImpostoPisDestroy.Register('nfe_detalhe_imposto_pis', '/nfe_detalhe_imposto_pis/:id');

end.
