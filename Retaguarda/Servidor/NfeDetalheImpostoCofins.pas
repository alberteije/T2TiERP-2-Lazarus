unit NfeDetalheImpostoCofins;

{$mode objfpc}{$H+}

interface

uses
  HTTPDefs, BrookRESTActions, BrookUtils, FPJson, SysUtils, BrookHTTPConsts;

type

  TNfeDetalheImpostoCofinsOptions = class(TBrookOptionsAction)
  end;

  TNfeDetalheImpostoCofinsRetrieve = class(TBrookRetrieveAction)
    procedure Request({%H-}ARequest: TRequest; AResponse: TResponse); override;
  end;

  TNfeDetalheImpostoCofinsShow = class(TBrookShowAction)
  end;

  TNfeDetalheImpostoCofinsCreate = class(TBrookCreateAction)
  end;

  TNfeDetalheImpostoCofinsUpdate = class(TBrookUpdateAction)
  end;

  TNfeDetalheImpostoCofinsDestroy = class(TBrookDestroyAction)
  end;

implementation

procedure TNfeDetalheImpostoCofinsRetrieve.Request(ARequest: TRequest; AResponse: TResponse);
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
  TNfeDetalheImpostoCofinsOptions.Register('nfe_detalhe_imposto_cofins', '/nfe_detalhe_imposto_cofins');
  TNfeDetalheImpostoCofinsRetrieve.Register('nfe_detalhe_imposto_cofins', '/nfe_detalhe_imposto_cofins/:campo/:filtro/');
  TNfeDetalheImpostoCofinsShow.Register('nfe_detalhe_imposto_cofins', '/nfe_detalhe_imposto_cofins/:id');
  TNfeDetalheImpostoCofinsCreate.Register('nfe_detalhe_imposto_cofins', '/nfe_detalhe_imposto_cofins');
  TNfeDetalheImpostoCofinsUpdate.Register('nfe_detalhe_imposto_cofins', '/nfe_detalhe_imposto_cofins/:id');
  TNfeDetalheImpostoCofinsDestroy.Register('nfe_detalhe_imposto_cofins', '/nfe_detalhe_imposto_cofins/:id');

end.
