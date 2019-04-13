{ *******************************************************************************
Title: T2Ti ERP
Description: Controller relacionado às tabelas [DAV_CABECALHO e DAV_DETALHE]

The MIT License

Copyright: Copyright (C) 2014 T2Ti.COM

Permission is hereby granted, free of charge, to any person
obtaining a copy of this software and associated documentation
files (the "Software"), to deal in the Software without
restriction, including without limitation the rights to use,
copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following
conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.

The author may be contacted at:
t2ti.com@gmail.com</p>

@author Albert Eije (t2ti.com@gmail.com)
@version 2.0
******************************************************************************* }
unit DAVController;

interface

uses
  Classes, Dialogs, SysUtils, Windows, Forms, Controller,
  VO, DavCabecalhoVO, Biblioteca;

type
  TDAVController = class(TController)
  private
  public
    class function ConsultaObjeto(pFiltro: String): TDavCabecalhoVO;
  end;

implementation

uses T2TiORM, DavDetalheVO;

class function TDAVController.ConsultaObjeto(pFiltro: String): TDavCabecalhoVO;
var
  Filtro: String;
begin
  try
    Result := TDavCabecalhoVO.Create;
    Result := TDavCabecalhoVO(TT2TiORM.ConsultarUmObjeto(Result, pFiltro, True));

    //Exercício: crie o método para popular esses objetos automaticamente no T2TiORM
    if Assigned(Result) then
    begin
      Filtro := 'ID_DAV_CABECALHO = ' + IntToStr(Result.Id);
      Result.ListaDavDetalheVO := TListaDavDetalheVO(TT2TiORM.Consultar(TDavDetalheVO.Create, Filtro, True));
    end;
  finally
  end;
end;

end.
