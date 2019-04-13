unit Contador;

{$mode objfpc}{$H+}

interface

uses
  BrookRESTActions, BrookUtils;

type
  TContadorOptions = class(TBrookOptionsAction)
  end;

  TContadorRetrieve = class(TBrookRetrieveAction)
  end;

  TContadorShow = class(TBrookShowAction)
  end;

  TContadorCreate = class(TBrookCreateAction)
  end;

  TContadorUpdate = class(TBrookUpdateAction)
  end;

  TContadorDestroy = class(TBrookDestroyAction)
  end;

implementation

initialization
  TContadorOptions.Register('contador', '/contador');
  TContadorRetrieve.Register('contador', '/contador');
  TContadorShow.Register('contador', '/contador/:id');
  TContadorCreate.Register('contador', '/contador');
  TContadorUpdate.Register('contador', '/contador/:id');
  TContadorDestroy.Register('contador', '/contador/:id');

end.
