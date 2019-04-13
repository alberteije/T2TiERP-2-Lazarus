unit NfeDetalhe;

{$mode objfpc}{$H+}

interface

uses
  HTTPDefs, BrookRESTActions, BrookUtils, FPJson, SysUtils, BrookHTTPConsts;

type

  TNfeDetalheOptions = class(TBrookOptionsAction)
  end;

  TNfeDetalheRetrieve = class(TBrookRetrieveAction)
    procedure Request({%H-}ARequest: TRequest; AResponse: TResponse); override;
  end;

  TNfeDetalheShow = class(TBrookShowAction)
  end;

  TNfeDetalheCreate = class(TBrookCreateAction)
  end;

  TNfeDetalheUpdate = class(TBrookUpdateAction)
  end;

  TNfeDetalheDestroy = class(TBrookDestroyAction)
  end;

implementation

procedure TNfeDetalheRetrieve.Request(ARequest: TRequest; AResponse: TResponse);
var
  VRow: TJSONObject;
  Campo: String;
  Filtro: String;
  Opcao: String;
begin
  Campo := Values['campo'].AsString;
  Filtro := Values['filtro'].AsString;
  Opcao := Values['opcao'].AsString;

  Values.Clear;

  Table.Where(Campo + ' = "' + Filtro + '"');

  if Opcao = 'registro' then
  begin
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
  end
  else
    inherited Request(ARequest, AResponse);
end;

initialization
  TNfeDetalheOptions.Register('nfe_detalhe', '/nfe_detalhe');
  TNfeDetalheRetrieve.Register('nfe_detalhe', '/nfe_detalhe/:campo/:filtro/:opcao/');
  TNfeDetalheShow.Register('nfe_detalhe', '/nfe_detalhe/:id');
  TNfeDetalheCreate.Register('nfe_detalhe', '/nfe_detalhe');
  TNfeDetalheUpdate.Register('nfe_detalhe', '/nfe_detalhe/:id');
  TNfeDetalheDestroy.Register('nfe_detalhe', '/nfe_detalhe/:id');

end.
