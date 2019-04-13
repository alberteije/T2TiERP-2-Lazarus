unit ViewTributacaoIpi;

{$mode objfpc}{$H+}

interface

uses
  HTTPDefs, BrookRESTActions, BrookUtils, FPJson, SysUtils, BrookHTTPConsts;

type

  TViewTributacaoIpiOptions = class(TBrookOptionsAction)
  end;

  TViewTributacaoIpiRetrieve = class(TBrookRetrieveAction)
    procedure Request({%H-}ARequest: TRequest; AResponse: TResponse); override;
  end;

  TViewTributacaoIpiShow = class(TBrookShowAction)
  end;

  TViewTributacaoIpiCreate = class(TBrookCreateAction)
  end;

  TViewTributacaoIpiUpdate = class(TBrookUpdateAction)
  end;

  TViewTributacaoIpiDestroy = class(TBrookDestroyAction)
  end;

implementation

procedure TViewTributacaoIpiRetrieve.Request(ARequest: TRequest; AResponse: TResponse);
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
  TViewTributacaoIpiOptions.Register('view_tributacao_ipi', '/view_tributacao_ipi');
  TViewTributacaoIpiRetrieve.Register('view_tributacao_ipi', '/view_tributacao_ipi/:id_operacao/:id_grupo/');
  TViewTributacaoIpiShow.Register('view_tributacao_ipi', '/view_tributacao_ipi/:id');
  TViewTributacaoIpiCreate.Register('view_tributacao_ipi', '/view_tributacao_ipi');
  TViewTributacaoIpiUpdate.Register('view_tributacao_ipi', '/view_tributacao_ipi/:id');
  TViewTributacaoIpiDestroy.Register('view_tributacao_ipi', '/view_tributacao_ipi/:id');

end.
