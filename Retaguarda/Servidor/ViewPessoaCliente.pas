unit ViewPessoaCliente;

{$mode objfpc}{$H+}

interface

uses
  HTTPDefs, BrookRESTActions, BrookUtils;

type

  TViewPessoaClienteOptions = class(TBrookOptionsAction)
  end;

  TViewPessoaClienteRetrieve = class(TBrookRetrieveAction)
    procedure Request({%H-}ARequest: TRequest; AResponse: TResponse); override;
  end;

  TViewPessoaClienteShow = class(TBrookShowAction)
  end;

  TViewPessoaClienteCreate = class(TBrookCreateAction)
  end;

  TViewPessoaClienteUpdate = class(TBrookUpdateAction)
  end;

  TViewPessoaClienteDestroy = class(TBrookDestroyAction)
  end;

implementation

procedure TViewPessoaClienteRetrieve.Request(ARequest: TRequest; AResponse: TResponse);
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
  TViewPessoaClienteOptions.Register('view_pessoa_cliente', '/view_pessoa_cliente');
  TViewPessoaClienteRetrieve.Register('view_pessoa_cliente', '/view_pessoa_cliente/:campo/:filtro/');
  TViewPessoaClienteShow.Register('view_pessoa_cliente', '/view_pessoa_cliente/:id');
  TViewPessoaClienteCreate.Register('view_pessoa_cliente', '/view_pessoa_cliente');
  TViewPessoaClienteUpdate.Register('view_pessoa_cliente', '/view_pessoa_cliente/:id');
  TViewPessoaClienteDestroy.Register('view_pessoa_cliente', '/view_pessoa_cliente/:id');

end.
