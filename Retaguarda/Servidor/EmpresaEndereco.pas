unit EmpresaEndereco;

{$mode objfpc}{$H+}

interface

uses
  HTTPDefs, BrookRESTActions, BrookUtils;

type

  TEmpresaEnderecoOptions = class(TBrookOptionsAction)
  end;

  TEmpresaEnderecoRetrieve = class(TBrookRetrieveAction)
    procedure Request({%H-}ARequest: TRequest; AResponse: TResponse); override;
  end;

  TEmpresaEnderecoShow = class(TBrookShowAction)
  end;

  TEmpresaEnderecoCreate = class(TBrookCreateAction)
  end;

  TEmpresaEnderecoUpdate = class(TBrookUpdateAction)
  end;

  TEmpresaEnderecoDestroy = class(TBrookDestroyAction)
  end;

implementation

procedure TEmpresaEnderecoRetrieve.Request(ARequest: TRequest; AResponse: TResponse);
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
  TEmpresaEnderecoOptions.Register('empresa_endereco', '/empresa_endereco');
  TEmpresaEnderecoRetrieve.Register('empresa_endereco', '/empresa_endereco/:campo/:filtro/');
  TEmpresaEnderecoShow.Register('empresa_endereco', '/empresa_endereco/:id');
  TEmpresaEnderecoCreate.Register('empresa_endereco', '/empresa_endereco');
  TEmpresaEnderecoUpdate.Register('empresa_endereco', '/empresa_endereco/:id');
  TEmpresaEnderecoDestroy.Register('empresa_endereco', '/empresa_endereco/:id');

end.
