unit Pessoa;

{$mode objfpc}{$H+}

interface

uses
  HTTPDefs, BrookRESTActions, BrookUtils;

type

  TPessoaOptions = class(TBrookOptionsAction)
  end;

  TPessoaRetrieve = class(TBrookRetrieveAction)
    procedure Request({%H-}ARequest: TRequest; AResponse: TResponse); override;
  end;

  TPessoaShow = class(TBrookShowAction)
  end;

  TPessoaCreate = class(TBrookCreateAction)
  end;

  TPessoaUpdate = class(TBrookUpdateAction)
  end;

  TPessoaDestroy = class(TBrookDestroyAction)
  end;

implementation

procedure TPessoaRetrieve.Request(ARequest: TRequest; AResponse: TResponse);
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
  TPessoaOptions.Register('pessoa', '/pessoa');
  TPessoaRetrieve.Register('pessoa', '/pessoa/:campo/:filtro/');
  TPessoaShow.Register('pessoa', '/pessoa/:id');
  TPessoaCreate.Register('pessoa', '/pessoa');
  TPessoaUpdate.Register('pessoa', '/pessoa/:id');
  TPessoaDestroy.Register('pessoa', '/pessoa/:id');

end.
