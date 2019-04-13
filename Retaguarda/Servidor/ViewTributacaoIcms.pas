unit ViewTributacaoIcms;

{$mode objfpc}{$H+}

interface

uses
  HTTPDefs, BrookRESTActions, BrookUtils, FPJson, SysUtils, BrookHTTPConsts;

type

  TViewTributacaoIcmsOptions = class(TBrookOptionsAction)
  end;

  TViewTributacaoIcmsRetrieve = class(TBrookRetrieveAction)
    procedure Request({%H-}ARequest: TRequest; AResponse: TResponse); override;
  end;

  TViewTributacaoIcmsShow = class(TBrookShowAction)
  end;

  TViewTributacaoIcmsCreate = class(TBrookCreateAction)
  end;

  TViewTributacaoIcmsUpdate = class(TBrookUpdateAction)
  end;

  TViewTributacaoIcmsDestroy = class(TBrookDestroyAction)
  end;

implementation

procedure TViewTributacaoIcmsRetrieve.Request(ARequest: TRequest; AResponse: TResponse);
var
  VRow: TJSONObject;
  IdOperacao: String;
  IdGrupo: String;
  UfDestino: String;
begin
  IdOperacao := Values['id_operacao'].AsString;
  IdGrupo := Values['id_grupo'].AsString;
  UfDestino := Values['uf_destino'].AsString;

  Values.Clear;

  Table.Where('ID_TRIBUT_OPERACAO_FISCAL = "' + IdOperacao + '" and ID_TRIBUT_GRUPO_TRIBUTARIO = "' + IdGrupo + '" and UF_DESTINO = "' + UfDestino + '"');

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
  TViewTributacaoIcmsOptions.Register('view_tributacao_icms', '/view_tributacao_icms');
  TViewTributacaoIcmsRetrieve.Register('view_tributacao_icms', '/view_tributacao_icms/:id_operacao/:id_grupo/:uf_destino/');
  TViewTributacaoIcmsShow.Register('view_tributacao_icms', '/view_tributacao_icms/:id');
  TViewTributacaoIcmsCreate.Register('view_tributacao_icms', '/view_tributacao_icms');
  TViewTributacaoIcmsUpdate.Register('view_tributacao_icms', '/view_tributacao_icms/:id');
  TViewTributacaoIcmsDestroy.Register('view_tributacao_icms', '/view_tributacao_icms/:id');

end.
