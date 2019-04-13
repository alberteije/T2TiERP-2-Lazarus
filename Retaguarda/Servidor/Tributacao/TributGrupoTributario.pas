unit TributGrupoTributario;

{$mode objfpc}{$H+}

interface

uses
  HTTPDefs, BrookRESTActions, BrookUtils;

type

  TTributGrupoTributarioOptions = class(TBrookOptionsAction)
  end;

  TTributGrupoTributarioRetrieve = class(TBrookRetrieveAction)
    procedure Request({%H-}ARequest: TRequest; AResponse: TResponse); override;
  end;

  TTributGrupoTributarioShow = class(TBrookShowAction)
  end;

  TTributGrupoTributarioCreate = class(TBrookCreateAction)
  end;

  TTributGrupoTributarioUpdate = class(TBrookUpdateAction)
  end;

  TTributGrupoTributarioDestroy = class(TBrookDestroyAction)
  end;

implementation

procedure TTributGrupoTributarioRetrieve.Request(ARequest: TRequest; AResponse: TResponse);
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
  TTributGrupoTributarioOptions.Register('tribut_grupo_tributario', '/tribut_grupo_tributario');
  TTributGrupoTributarioRetrieve.Register('tribut_grupo_tributario', '/tribut_grupo_tributario/:campo/:filtro/');
  TTributGrupoTributarioShow.Register('tribut_grupo_tributario', '/tribut_grupo_tributario/:id');
  TTributGrupoTributarioCreate.Register('tribut_grupo_tributario', '/tribut_grupo_tributario');
  TTributGrupoTributarioUpdate.Register('tribut_grupo_tributario', '/tribut_grupo_tributario/:id');
  TTributGrupoTributarioDestroy.Register('tribut_grupo_tributario', '/tribut_grupo_tributario/:id');

end.
