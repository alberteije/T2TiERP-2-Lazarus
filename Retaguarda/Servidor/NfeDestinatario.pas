unit NfeDestinatario;

{$mode objfpc}{$H+}

interface

uses
  HTTPDefs, BrookRESTActions, BrookUtils, FPJson, SysUtils, BrookHTTPConsts;

type

  TNfeDestinatarioOptions = class(TBrookOptionsAction)
  end;

  TNfeDestinatarioRetrieve = class(TBrookRetrieveAction)
    procedure Request({%H-}ARequest: TRequest; AResponse: TResponse); override;
  end;

  TNfeDestinatarioShow = class(TBrookShowAction)
  end;

  TNfeDestinatarioCreate = class(TBrookCreateAction)
  end;

  TNfeDestinatarioUpdate = class(TBrookUpdateAction)
  end;

  TNfeDestinatarioDestroy = class(TBrookDestroyAction)
  end;

implementation

procedure TNfeDestinatarioRetrieve.Request(ARequest: TRequest; AResponse: TResponse);
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
  TNfeDestinatarioOptions.Register('nfe_destinatario', '/nfe_destinatario');
  TNfeDestinatarioRetrieve.Register('nfe_destinatario', '/nfe_destinatario/:campo/:filtro/');
  TNfeDestinatarioShow.Register('nfe_destinatario', '/nfe_destinatario/:id');
  TNfeDestinatarioCreate.Register('nfe_destinatario', '/nfe_destinatario');
  TNfeDestinatarioUpdate.Register('nfe_destinatario', '/nfe_destinatario/:id');
  TNfeDestinatarioDestroy.Register('nfe_destinatario', '/nfe_destinatario/:id');

end.
