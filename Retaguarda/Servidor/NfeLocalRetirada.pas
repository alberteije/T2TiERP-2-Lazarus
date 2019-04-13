unit NfeLocalRetirada;

{$mode objfpc}{$H+}

interface

uses
  HTTPDefs, BrookRESTActions, BrookUtils, FPJson, SysUtils, BrookHTTPConsts;

type

  TNfeLocalRetiradaOptions = class(TBrookOptionsAction)
  end;

  TNfeLocalRetiradaRetrieve = class(TBrookRetrieveAction)
    procedure Request({%H-}ARequest: TRequest; AResponse: TResponse); override;
  end;

  TNfeLocalRetiradaShow = class(TBrookShowAction)
  end;

  TNfeLocalRetiradaCreate = class(TBrookCreateAction)
  end;

  TNfeLocalRetiradaUpdate = class(TBrookUpdateAction)
  end;

  TNfeLocalRetiradaDestroy = class(TBrookDestroyAction)
  end;

implementation

procedure TNfeLocalRetiradaRetrieve.Request(ARequest: TRequest; AResponse: TResponse);
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
  TNfeLocalRetiradaOptions.Register('nfe_local_retirada', '/nfe_local_retirada');
  TNfeLocalRetiradaRetrieve.Register('nfe_local_retirada', '/nfe_local_retirada/:campo/:filtro/');
  TNfeLocalRetiradaShow.Register('nfe_local_retirada', '/nfe_local_retirada/:id');
  TNfeLocalRetiradaCreate.Register('nfe_local_retirada', '/nfe_local_retirada');
  TNfeLocalRetiradaUpdate.Register('nfe_local_retirada', '/nfe_local_retirada/:id');
  TNfeLocalRetiradaDestroy.Register('nfe_local_retirada', '/nfe_local_retirada/:id');

end.
