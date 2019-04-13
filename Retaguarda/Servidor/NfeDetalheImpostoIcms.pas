unit NfeDetalheImpostoIcms;

{$mode objfpc}{$H+}

interface

uses
  HTTPDefs, BrookRESTActions, BrookUtils, FPJson, SysUtils, BrookHTTPConsts;

type

  TNfeDetalheImpostoIcmsOptions = class(TBrookOptionsAction)
  end;

  TNfeDetalheImpostoIcmsRetrieve = class(TBrookRetrieveAction)
    procedure Request({%H-}ARequest: TRequest; AResponse: TResponse); override;
  end;

  TNfeDetalheImpostoIcmsShow = class(TBrookShowAction)
  end;

  TNfeDetalheImpostoIcmsCreate = class(TBrookCreateAction)
  end;

  TNfeDetalheImpostoIcmsUpdate = class(TBrookUpdateAction)
  end;

  TNfeDetalheImpostoIcmsDestroy = class(TBrookDestroyAction)
  end;

implementation

procedure TNfeDetalheImpostoIcmsRetrieve.Request(ARequest: TRequest; AResponse: TResponse);
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
  TNfeDetalheImpostoIcmsOptions.Register('nfe_detalhe_imposto_icms', '/nfe_detalhe_imposto_icms');
  TNfeDetalheImpostoIcmsRetrieve.Register('nfe_detalhe_imposto_icms', '/nfe_detalhe_imposto_icms/:campo/:filtro/');
  TNfeDetalheImpostoIcmsShow.Register('nfe_detalhe_imposto_icms', '/nfe_detalhe_imposto_icms/:id');
  TNfeDetalheImpostoIcmsCreate.Register('nfe_detalhe_imposto_icms', '/nfe_detalhe_imposto_icms');
  TNfeDetalheImpostoIcmsUpdate.Register('nfe_detalhe_imposto_icms', '/nfe_detalhe_imposto_icms/:id');
  TNfeDetalheImpostoIcmsDestroy.Register('nfe_detalhe_imposto_icms', '/nfe_detalhe_imposto_icms/:id');

end.
