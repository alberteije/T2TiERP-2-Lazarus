unit TributIss;

{$mode objfpc}{$H+}

interface

uses
  HTTPDefs, BrookRESTActions, BrookUtils;

type

  TTributIssOptions = class(TBrookOptionsAction)
  end;

  TTributIssRetrieve = class(TBrookRetrieveAction)
    procedure Request({%H-}ARequest: TRequest; AResponse: TResponse); override;
  end;

  TTributIssShow = class(TBrookShowAction)
  end;

  TTributIssCreate = class(TBrookCreateAction)
  end;

  TTributIssUpdate = class(TBrookUpdateAction)
  end;

  TTributIssDestroy = class(TBrookDestroyAction)
  end;

implementation

procedure TTributIssRetrieve.Request(ARequest: TRequest; AResponse: TResponse);
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
  TTributIssOptions.Register('tribut_iss', '/tribut_iss');
  TTributIssRetrieve.Register('tribut_iss', '/tribut_iss/:campo/:filtro/');
  TTributIssShow.Register('tribut_iss', '/tribut_iss/:id');
  TTributIssCreate.Register('tribut_iss', '/tribut_iss');
  TTributIssUpdate.Register('tribut_iss', '/tribut_iss/:id');
  TTributIssDestroy.Register('tribut_iss', '/tribut_iss/:id');

end.
