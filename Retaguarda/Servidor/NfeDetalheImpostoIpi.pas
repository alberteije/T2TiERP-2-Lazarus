unit NfeDetalheImpostoIpi;

{$mode objfpc}{$H+}

interface

uses
  HTTPDefs, BrookRESTActions, BrookUtils, FPJson, SysUtils, BrookHTTPConsts;

type

  TNfeDetalheImpostoIpiOptions = class(TBrookOptionsAction)
  end;

  TNfeDetalheImpostoIpiRetrieve = class(TBrookRetrieveAction)
    procedure Request({%H-}ARequest: TRequest; AResponse: TResponse); override;
  end;

  TNfeDetalheImpostoIpiShow = class(TBrookShowAction)
  end;

  TNfeDetalheImpostoIpiCreate = class(TBrookCreateAction)
  end;

  TNfeDetalheImpostoIpiUpdate = class(TBrookUpdateAction)
  end;

  TNfeDetalheImpostoIpiDestroy = class(TBrookDestroyAction)
  end;

implementation

procedure TNfeDetalheImpostoIpiRetrieve.Request(ARequest: TRequest; AResponse: TResponse);
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
  TNfeDetalheImpostoIpiOptions.Register('nfe_detalhe_imposto_ipi', '/nfe_detalhe_imposto_ipi');
  TNfeDetalheImpostoIpiRetrieve.Register('nfe_detalhe_imposto_ipi', '/nfe_detalhe_imposto_ipi/:campo/:filtro/');
  TNfeDetalheImpostoIpiShow.Register('nfe_detalhe_imposto_ipi', '/nfe_detalhe_imposto_ipi/:id');
  TNfeDetalheImpostoIpiCreate.Register('nfe_detalhe_imposto_ipi', '/nfe_detalhe_imposto_ipi');
  TNfeDetalheImpostoIpiUpdate.Register('nfe_detalhe_imposto_ipi', '/nfe_detalhe_imposto_ipi/:id');
  TNfeDetalheImpostoIpiDestroy.Register('nfe_detalhe_imposto_ipi', '/nfe_detalhe_imposto_ipi/:id');

end.
