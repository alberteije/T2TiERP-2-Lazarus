unit Produto;

{$mode objfpc}{$H+}

interface

uses
  HTTPDefs, BrookRESTActions, BrookUtils;

type

  TProdutoOptions = class(TBrookOptionsAction)
  end;

  TProdutoRetrieve = class(TBrookRetrieveAction)
    procedure Request({%H-}ARequest: TRequest; AResponse: TResponse); override;
  end;

  TProdutoShow = class(TBrookShowAction)
  end;

  TProdutoCreate = class(TBrookCreateAction)
  end;

  TProdutoUpdate = class(TBrookUpdateAction)
  end;

  TProdutoDestroy = class(TBrookDestroyAction)
  end;

implementation

procedure TProdutoRetrieve.Request(ARequest: TRequest; AResponse: TResponse);
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
  TProdutoOptions.Register('produto', '/produto');
  TProdutoRetrieve.Register('produto', '/produto/:campo/:filtro/');
  TProdutoShow.Register('produto', '/produto/:id');
  TProdutoCreate.Register('produto', '/produto');
  TProdutoUpdate.Register('produto', '/produto/:id');
  TProdutoDestroy.Register('produto', '/produto/:id');

end.
