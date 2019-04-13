unit NfeLocalEntrega;

{$mode objfpc}{$H+}

interface

uses
  HTTPDefs, BrookRESTActions, BrookUtils, FPJson, SysUtils, BrookHTTPConsts;

type

  TNfeLocalEntregaOptions = class(TBrookOptionsAction)
  end;

  TNfeLocalEntregaRetrieve = class(TBrookRetrieveAction)
    procedure Request({%H-}ARequest: TRequest; AResponse: TResponse); override;
  end;

  TNfeLocalEntregaShow = class(TBrookShowAction)
  end;

  TNfeLocalEntregaCreate = class(TBrookCreateAction)
  end;

  TNfeLocalEntregaUpdate = class(TBrookUpdateAction)
  end;

  TNfeLocalEntregaDestroy = class(TBrookDestroyAction)
  end;

implementation

procedure TNfeLocalEntregaRetrieve.Request(ARequest: TRequest; AResponse: TResponse);
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
  TNfeLocalEntregaOptions.Register('nfe_local_entrega', '/nfe_local_entrega');
  TNfeLocalEntregaRetrieve.Register('nfe_local_entrega', '/nfe_local_entrega/:campo/:filtro/');
  TNfeLocalEntregaShow.Register('nfe_local_entrega', '/nfe_local_entrega/:id');
  TNfeLocalEntregaCreate.Register('nfe_local_entrega', '/nfe_local_entrega');
  TNfeLocalEntregaUpdate.Register('nfe_local_entrega', '/nfe_local_entrega/:id');
  TNfeLocalEntregaDestroy.Register('nfe_local_entrega', '/nfe_local_entrega/:id');

end.
