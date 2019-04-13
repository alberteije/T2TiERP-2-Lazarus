unit TributIcmsCustomCab;

{$mode objfpc}{$H+}

interface

uses
  HTTPDefs, BrookRESTActions, BrookUtils;

type

  TTributIcmsCustomCabOptions = class(TBrookOptionsAction)
  end;

  TTributIcmsCustomCabRetrieve = class(TBrookRetrieveAction)
    procedure Request({%H-}ARequest: TRequest; AResponse: TResponse); override;
  end;

  TTributIcmsCustomCabShow = class(TBrookShowAction)
  end;

  TTributIcmsCustomCabCreate = class(TBrookCreateAction)
  end;

  TTributIcmsCustomCabUpdate = class(TBrookUpdateAction)
  end;

  TTributIcmsCustomCabDestroy = class(TBrookDestroyAction)
  end;

implementation

procedure TTributIcmsCustomCabRetrieve.Request(ARequest: TRequest; AResponse: TResponse);
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
  TTributIcmsCustomCabOptions.Register('tribut_icms_custom_cab', '/tribut_icms_custom_cab');
  TTributIcmsCustomCabRetrieve.Register('tribut_icms_custom_cab', '/tribut_icms_custom_cab/:campo/:filtro/');
  TTributIcmsCustomCabShow.Register('tribut_icms_custom_cab', '/tribut_icms_custom_cab/:id');
  TTributIcmsCustomCabCreate.Register('tribut_icms_custom_cab', '/tribut_icms_custom_cab');
  TTributIcmsCustomCabUpdate.Register('tribut_icms_custom_cab', '/tribut_icms_custom_cab/:id');
  TTributIcmsCustomCabDestroy.Register('tribut_icms_custom_cab', '/tribut_icms_custom_cab/:id');

end.
