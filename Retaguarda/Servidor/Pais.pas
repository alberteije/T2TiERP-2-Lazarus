unit Pais;

{$mode objfpc}{$H+}

interface

uses
  HTTPDefs, BrookRESTActions, BrookUtils;

type

  TPaisOptions = class(TBrookOptionsAction)
  end;

  TPaisRetrieve = class(TBrookRetrieveAction)
    procedure Request({%H-}ARequest: TRequest; AResponse: TResponse); override;
  end;

  TPaisShow = class(TBrookShowAction)
  end;

  TPaisCreate = class(TBrookCreateAction)
  end;

  TPaisUpdate = class(TBrookUpdateAction)
  end;

  TPaisDestroy = class(TBrookDestroyAction)
  end;

implementation

procedure TPaisRetrieve.Request(ARequest: TRequest; AResponse: TResponse);
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
  TPaisOptions.Register('pais', '/pais');
  TPaisRetrieve.Register('pais', '/pais/:campo/:filtro/');
  TPaisShow.Register('pais', '/pais/:id');
  TPaisCreate.Register('pais', '/pais');
  TPaisUpdate.Register('pais', '/pais/:id');
  TPaisDestroy.Register('pais', '/pais/:id');

end.
