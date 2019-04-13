unit TributIcmsCustomDet;

{$mode objfpc}{$H+}

interface

uses
  HTTPDefs, BrookRESTActions, BrookUtils;

type

  TTributIcmsCustomDetOptions = class(TBrookOptionsAction)
  end;

  TTributIcmsCustomDetRetrieve = class(TBrookRetrieveAction)
    procedure Request({%H-}ARequest: TRequest; AResponse: TResponse); override;
  end;

  TTributIcmsCustomDetShow = class(TBrookShowAction)
  end;

  TTributIcmsCustomDetCreate = class(TBrookCreateAction)
  end;

  TTributIcmsCustomDetUpdate = class(TBrookUpdateAction)
  end;

  TTributIcmsCustomDetDestroy = class(TBrookDestroyAction)
  end;

implementation

procedure TTributIcmsCustomDetRetrieve.Request(ARequest: TRequest; AResponse: TResponse);
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
  TTributIcmsCustomDetOptions.Register('tribut_icms_custom_det', '/tribut_icms_custom_det');
  TTributIcmsCustomDetRetrieve.Register('tribut_icms_custom_det', '/tribut_icms_custom_det/:campo/:filtro/');
  TTributIcmsCustomDetShow.Register('tribut_icms_custom_det', '/tribut_icms_custom_det/:id');
  TTributIcmsCustomDetCreate.Register('tribut_icms_custom_det', '/tribut_icms_custom_det');
  TTributIcmsCustomDetUpdate.Register('tribut_icms_custom_det', '/tribut_icms_custom_det/:id');
  TTributIcmsCustomDetDestroy.Register('tribut_icms_custom_det', '/tribut_icms_custom_det/:id');

end.
