unit NfeNumero;

{$mode objfpc}{$H+}

interface

uses
  HTTPDefs, BrookRESTActions, BrookUtils;

type

  TNfeNumeroOptions = class(TBrookOptionsAction)
  end;

  TNfeNumeroRetrieve = class(TBrookRetrieveAction)
    procedure Request({%H-}ARequest: TRequest; AResponse: TResponse); override;
  end;

  TNfeNumeroShow = class(TBrookShowAction)
  end;

  TNfeNumeroCreate = class(TBrookCreateAction)
  end;

  TNfeNumeroUpdate = class(TBrookUpdateAction)
  end;

  TNfeNumeroDestroy = class(TBrookDestroyAction)
  end;

implementation

procedure TNfeNumeroRetrieve.Request(ARequest: TRequest; AResponse: TResponse);
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
  TNfeNumeroOptions.Register('nfe_numero', '/nfe_numero');
  TNfeNumeroRetrieve.Register('nfe_numero', '/nfe_numero/:campo/:filtro/');
  TNfeNumeroShow.Register('nfe_numero', '/nfe_numero/:id');
  TNfeNumeroCreate.Register('nfe_numero', '/nfe_numero');
  TNfeNumeroUpdate.Register('nfe_numero', '/nfe_numero/:id');
  TNfeNumeroDestroy.Register('nfe_numero', '/nfe_numero/:id');

end.
