unit DavDetalhe;

{$mode objfpc}{$H+}

interface

uses
  BrookRESTActions, BrookUtils;

type
  TDavDetalheOptions = class(TBrookOptionsAction)
  end;

  TDavDetalheRetrieve = class(TBrookRetrieveAction)
  end;

  TDavDetalheShow = class(TBrookShowAction)
  end;

  TDavDetalheCreate = class(TBrookCreateAction)
  end;

  TDavDetalheUpdate = class(TBrookUpdateAction)
  end;

  TDavDetalheDestroy = class(TBrookDestroyAction)
  end;

implementation

initialization
  TDavDetalheOptions.Register('dav_detalhe', '/dav_cabecalho/dav_detalhe');
  TDavDetalheRetrieve.Register('dav_detalhe', '/dav_cabecalho/:id_dav_cabecalho/dav_detalhe');
  TDavDetalheShow.Register('dav_detalhe', '/dav_cabecalho/:id_dav_cabecalho/dav_detalhe/:id');
  TDavDetalheCreate.Register('dav_detalhe', '/dav_cabecalho/:id_dav_cabecalho/dav_detalhe');
  TDavDetalheUpdate.Register('dav_detalhe', '/dav_cabecalho/:id_dav_cabecalho/dav_detalhe/:id');
  TDavDetalheDestroy.Register('dav_detalhe', '/dav_cabecalho/:id_dav_cabecalho/dav_detalhe/:id');

end.
