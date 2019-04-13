unit TributIpiDipi;

{$mode objfpc}{$H+}

interface

uses
  HTTPDefs, BrookRESTActions, BrookUtils;

type

  TTributIpiDipiOptions = class(TBrookOptionsAction)
  end;

  TTributIpiDipiRetrieve = class(TBrookRetrieveAction)
    procedure Request({%H-}ARequest: TRequest; AResponse: TResponse); override;
  end;

  TTributIpiDipiShow = class(TBrookShowAction)
  end;

  TTributIpiDipiCreate = class(TBrookCreateAction)
  end;

  TTributIpiDipiUpdate = class(TBrookUpdateAction)
  end;

  TTributIpiDipiDestroy = class(TBrookDestroyAction)
  end;

implementation

procedure TTributIpiDipiRetrieve.Request(ARequest: TRequest; AResponse: TResponse);
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
  TTributIpiDipiOptions.Register('tribut_ipi_dipi', '/tribut_ipi_dipi');
  TTributIpiDipiRetrieve.Register('tribut_ipi_dipi', '/tribut_ipi_dipi/:campo/:filtro/');
  TTributIpiDipiShow.Register('tribut_ipi_dipi', '/tribut_ipi_dipi/:id');
  TTributIpiDipiCreate.Register('tribut_ipi_dipi', '/tribut_ipi_dipi');
  TTributIpiDipiUpdate.Register('tribut_ipi_dipi', '/tribut_ipi_dipi/:id');
  TTributIpiDipiDestroy.Register('tribut_ipi_dipi', '/tribut_ipi_dipi/:id');

end.
