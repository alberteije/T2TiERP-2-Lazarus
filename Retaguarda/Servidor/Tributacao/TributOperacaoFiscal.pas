unit TributOperacaoFiscal;

{$mode objfpc}{$H+}

interface

uses
  HTTPDefs, BrookRESTActions, BrookUtils;

type

  TTributOperacaoFiscalOptions = class(TBrookOptionsAction)
  end;

  TTributOperacaoFiscalRetrieve = class(TBrookRetrieveAction)
    procedure Request({%H-}ARequest: TRequest; AResponse: TResponse); override;
  end;

  TTributOperacaoFiscalShow = class(TBrookShowAction)
  end;

  TTributOperacaoFiscalCreate = class(TBrookCreateAction)
  end;

  TTributOperacaoFiscalUpdate = class(TBrookUpdateAction)
  end;

  TTributOperacaoFiscalDestroy = class(TBrookDestroyAction)
  end;

implementation

procedure TTributOperacaoFiscalRetrieve.Request(ARequest: TRequest; AResponse: TResponse);
var
  Campo: String;
  Filtro: String;
begin
  Campo := Values['campo'].AsString;
  Filtro := Values['filtro'].AsString;

  Values.Clear;

  Table.Where(Campo + ' LIKE "%' + Filtro + '%"');
  inherited Request(ARequest, AResponse);
end;

initialization
  TTributOperacaoFiscalOptions.Register('tribut_operacao_fiscal', '/tribut_operacao_fiscal');
  TTributOperacaoFiscalRetrieve.Register('tribut_operacao_fiscal', '/tribut_operacao_fiscal/:campo/:filtro/');
  TTributOperacaoFiscalShow.Register('tribut_operacao_fiscal', '/tribut_operacao_fiscal/:id');
  TTributOperacaoFiscalCreate.Register('tribut_operacao_fiscal', '/tribut_operacao_fiscal');
  TTributOperacaoFiscalUpdate.Register('tribut_operacao_fiscal', '/tribut_operacao_fiscal/:id');
  TTributOperacaoFiscalDestroy.Register('tribut_operacao_fiscal', '/tribut_operacao_fiscal/:id');

end.
