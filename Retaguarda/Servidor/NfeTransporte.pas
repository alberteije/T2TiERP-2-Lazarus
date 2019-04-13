unit NfeTransporte;

{$mode objfpc}{$H+}

interface

uses
  HTTPDefs, BrookRESTActions, BrookUtils, FPJson, SysUtils, BrookHTTPConsts;

type

  TNfeTransporteOptions = class(TBrookOptionsAction)
  end;

  TNfeTransporteRetrieve = class(TBrookRetrieveAction)
    procedure Request({%H-}ARequest: TRequest; AResponse: TResponse); override;
  end;

  TNfeTransporteShow = class(TBrookShowAction)
  end;

  TNfeTransporteCreate = class(TBrookCreateAction)
  end;

  TNfeTransporteUpdate = class(TBrookUpdateAction)
  end;

  TNfeTransporteDestroy = class(TBrookDestroyAction)
  end;

implementation

procedure TNfeTransporteRetrieve.Request(ARequest: TRequest; AResponse: TResponse);
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
  TNfeTransporteOptions.Register('nfe_transporte', '/nfe_transporte');
  TNfeTransporteRetrieve.Register('nfe_transporte', '/nfe_transporte/:campo/:filtro/');
  TNfeTransporteShow.Register('nfe_transporte', '/nfe_transporte/:id');
  TNfeTransporteCreate.Register('nfe_transporte', '/nfe_transporte');
  TNfeTransporteUpdate.Register('nfe_transporte', '/nfe_transporte/:id');
  TNfeTransporteDestroy.Register('nfe_transporte', '/nfe_transporte/:id');

end.
