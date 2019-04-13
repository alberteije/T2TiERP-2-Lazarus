unit ViewTributacaoCofins;

{$mode objfpc}{$H+}

interface

uses
  HTTPDefs, BrookRESTActions, BrookUtils, FPJson, SysUtils, BrookHTTPConsts;

type

  TViewTributacaoCofinsOptions = class(TBrookOptionsAction)
  end;

  TViewTributacaoCofinsRetrieve = class(TBrookRetrieveAction)
    procedure Request({%H-}ARequest: TRequest; AResponse: TResponse); override;
  end;

  TViewTributacaoCofinsShow = class(TBrookShowAction)
  end;

  TViewTributacaoCofinsCreate = class(TBrookCreateAction)
  end;

  TViewTributacaoCofinsUpdate = class(TBrookUpdateAction)
  end;

  TViewTributacaoCofinsDestroy = class(TBrookDestroyAction)
  end;

implementation

procedure TViewTributacaoCofinsRetrieve.Request(ARequest: TRequest; AResponse: TResponse);
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
  TViewTributacaoCofinsOptions.Register('view_tributacao_cofins', '/view_tributacao_cofins');
  TViewTributacaoCofinsRetrieve.Register('view_tributacao_cofins', '/view_tributacao_cofins/:id_operacao/:id_grupo/');
  TViewTributacaoCofinsShow.Register('view_tributacao_cofins', '/view_tributacao_cofins/:id');
  TViewTributacaoCofinsCreate.Register('view_tributacao_cofins', '/view_tributacao_cofins');
  TViewTributacaoCofinsUpdate.Register('view_tributacao_cofins', '/view_tributacao_cofins/:id');
  TViewTributacaoCofinsDestroy.Register('view_tributacao_cofins', '/view_tributacao_cofins/:id');

end.
