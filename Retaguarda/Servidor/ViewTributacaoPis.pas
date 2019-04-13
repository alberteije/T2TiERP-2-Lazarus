unit ViewTributacaoPis;

{$mode objfpc}{$H+}

interface

uses
  HTTPDefs, BrookRESTActions, BrookUtils, FPJson, SysUtils, BrookHTTPConsts;

type

  TViewTributacaoPisOptions = class(TBrookOptionsAction)
  end;

  TViewTributacaoPisRetrieve = class(TBrookRetrieveAction)
    procedure Request({%H-}ARequest: TRequest; AResponse: TResponse); override;
  end;

  TViewTributacaoPisShow = class(TBrookShowAction)
  end;

  TViewTributacaoPisCreate = class(TBrookCreateAction)
  end;

  TViewTributacaoPisUpdate = class(TBrookUpdateAction)
  end;

  TViewTributacaoPisDestroy = class(TBrookDestroyAction)
  end;

implementation

procedure TViewTributacaoPisRetrieve.Request(ARequest: TRequest; AResponse: TResponse);
var
  VRow: TJSONObject;
  IdOperacao: String;
  IdGrupo: String;
begin
  IdOperacao := Values['id_operacao'].AsString;
  IdGrupo := Values['id_grupo'].AsString;

  Values.Clear;

  Table.Where('ID_TRIBUT_OPERACAO_FISCAL = "' + IdOperacao + '" and ID_TRIBUT_GRUPO_TRIBUTARIO = "' + IdGrupo + '"');

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

//  inherited Request(ARequest, AResponse);
end;

initialization
  TViewTributacaoPisOptions.Register('view_tributacao_pis', '/view_tributacao_pis');
  TViewTributacaoPisRetrieve.Register('view_tributacao_pis', '/view_tributacao_pis/:id_operacao/:id_grupo/');
  TViewTributacaoPisShow.Register('view_tributacao_pis', '/view_tributacao_pis/:id');
  TViewTributacaoPisCreate.Register('view_tributacao_pis', '/view_tributacao_pis');
  TViewTributacaoPisUpdate.Register('view_tributacao_pis', '/view_tributacao_pis/:id');
  TViewTributacaoPisDestroy.Register('view_tributacao_pis', '/view_tributacao_pis/:id');

end.
