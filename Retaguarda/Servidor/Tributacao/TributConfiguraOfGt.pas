unit TributConfiguraOfGt;

{$mode objfpc}{$H+}

interface

uses
  HTTPDefs, BrookRESTActions, BrookUtils;

type

  TTributConfiguraOfGtOptions = class(TBrookOptionsAction)
  end;

  TTributConfiguraOfGtRetrieve = class(TBrookRetrieveAction)
    procedure Request({%H-}ARequest: TRequest; AResponse: TResponse); override;
  end;

  TTributConfiguraOfGtShow = class(TBrookShowAction)
  end;

  TTributConfiguraOfGtCreate = class(TBrookCreateAction)
  end;

  TTributConfiguraOfGtUpdate = class(TBrookUpdateAction)
  end;

  TTributConfiguraOfGtDestroy = class(TBrookDestroyAction)
  end;

implementation

procedure TTributConfiguraOfGtRetrieve.Request(ARequest: TRequest; AResponse: TResponse);
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
  TTributConfiguraOfGtOptions.Register('tribut_configura_of_gt', '/tribut_configura_of_gt');
  TTributConfiguraOfGtRetrieve.Register('tribut_configura_of_gt', '/tribut_configura_of_gt/:campo/:filtro/');
  TTributConfiguraOfGtShow.Register('tribut_configura_of_gt', '/tribut_configura_of_gt/:id');
  TTributConfiguraOfGtCreate.Register('tribut_configura_of_gt', '/tribut_configura_of_gt');
  TTributConfiguraOfGtUpdate.Register('tribut_configura_of_gt', '/tribut_configura_of_gt/:id');
  TTributConfiguraOfGtDestroy.Register('tribut_configura_of_gt', '/tribut_configura_of_gt/:id');

end.
