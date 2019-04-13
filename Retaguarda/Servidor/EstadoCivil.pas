unit EstadoCivil;

{$mode objfpc}{$H+}

interface

uses
  HTTPDefs, BrookRESTActions, BrookUtils;

type

  TEstadoCivilOptions = class(TBrookOptionsAction)
  end;

  TEstadoCivilRetrieve = class(TBrookRetrieveAction)
    procedure Request({%H-}ARequest: TRequest; AResponse: TResponse); override;
  end;

  TEstadoCivilShow = class(TBrookShowAction)
  end;

  TEstadoCivilCreate = class(TBrookCreateAction)
  end;

  TEstadoCivilUpdate = class(TBrookUpdateAction)
  end;

  TEstadoCivilDestroy = class(TBrookDestroyAction)
  end;

implementation

procedure TEstadoCivilRetrieve.Request(ARequest: TRequest; AResponse: TResponse);
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
  TEstadoCivilOptions.Register('estado_civil', '/estado_civil');
  TEstadoCivilRetrieve.Register('estado_civil', '/estado_civil/:campo/:filtro/');
  TEstadoCivilShow.Register('estado_civil', '/estado_civil/:id');
  TEstadoCivilCreate.Register('estado_civil', '/estado_civil');
  TEstadoCivilUpdate.Register('estado_civil', '/estado_civil/:id');
  TEstadoCivilDestroy.Register('estado_civil', '/estado_civil/:id');

end.
