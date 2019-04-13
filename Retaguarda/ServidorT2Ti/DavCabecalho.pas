unit DavCabecalho;

{$mode objfpc}{$H+}

interface

uses
  BrookRESTActions, BrookUtils;

type
  TDavCabecalhoOptions = class(TBrookOptionsAction)
  end;

  TDavCabecalhoRetrieve = class(TBrookRetrieveAction)
  end;

  TDavCabecalhoShow = class(TBrookShowAction)
  end;

  TDavCabecalhoCreate = class(TBrookCreateAction)
  end;

  TDavCabecalhoUpdate = class(TBrookUpdateAction)
  end;

  TDavCabecalhoDestroy = class(TBrookDestroyAction)
  end;

implementation

initialization
  TDavCabecalhoOptions.Register('dav_cabecalho', '/dav_cabecalho');
  TDavCabecalhoRetrieve.Register('dav_cabecalho', '/dav_cabecalho');
  TDavCabecalhoShow.Register('dav_cabecalho', '/dav_cabecalho/:id');
  TDavCabecalhoCreate.Register('dav_cabecalho', '/dav_cabecalho');
  TDavCabecalhoUpdate.Register('dav_cabecalho', '/dav_cabecalho/:id');
  TDavCabecalhoDestroy.Register('dav_cabecalho', '/dav_cabecalho/:id');

end.
