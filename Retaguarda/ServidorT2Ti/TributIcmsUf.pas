unit TributIcmsUf;

{$mode objfpc}{$H+}

interface

uses
  HTTPDefs, BrookRESTActions, BrookUtils;

type

  TTributIcmsUfOptions = class(TBrookOptionsAction)
  end;

  TTributIcmsUfRetrieve = class(TBrookRetrieveAction)
    procedure Request({%H-}ARequest: TRequest; AResponse: TResponse); override;
  end;

  TTributIcmsUfShow = class(TBrookShowAction)
  end;

  TTributIcmsUfCreate = class(TBrookCreateAction)
  end;

  TTributIcmsUfUpdate = class(TBrookUpdateAction)
  end;

  TTributIcmsUfDestroy = class(TBrookDestroyAction)
  end;

implementation

procedure TTributIcmsUfRetrieve.Request(ARequest: TRequest; AResponse: TResponse);
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
  TTributIcmsUfOptions.Register('tribut_icms_uf', '/tribut_icms_uf');
  TTributIcmsUfRetrieve.Register('tribut_icms_uf', '/tribut_icms_uf/:campo/:filtro/');
  TTributIcmsUfShow.Register('tribut_icms_uf', '/tribut_icms_uf/:id');
  TTributIcmsUfCreate.Register('tribut_icms_uf', '/tribut_icms_uf');
  TTributIcmsUfUpdate.Register('tribut_icms_uf', '/tribut_icms_uf/:id');
  TTributIcmsUfDestroy.Register('tribut_icms_uf', '/tribut_icms_uf/:id');

end.
