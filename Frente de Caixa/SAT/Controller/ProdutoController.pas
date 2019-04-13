{ *******************************************************************************
Title: T2Ti ERP
Description: Controller do lado Cliente relacionado à tabela [PRODUTO]

The MIT License

Copyright: Copyright (C) 2010 T2Ti.COM

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
unit ProdutoController;

interface

uses
  Classes, SysUtils, Windows, Forms, Controller, ZDataset, md5,
  VO, ProdutoVO, Biblioteca;

type
  TProdutoController = class(TController)
  private
  public
    class function Consulta(pFiltro: String; pPagina: String): TZQuery;
    class function ConsultaLista(pFiltro: String): TListaProdutoVO;
    class function ConsultaObjeto(pFiltro: String): TProdutoVO;
    class function ConsultaPorTipo(pCodigo: String; pTipo: Integer): TProdutoVO;
    class function Altera(pObjeto: TProdutoVO): Boolean;
  end;

implementation

uses T2TiORM, UnidadeProdutoVO;

var
  ObjetoLocal: TProdutoVO;

class function TProdutoController.Consulta(pFiltro: String; pPagina: String): TZQuery;
begin
  try
    ObjetoLocal := TProdutoVO.Create;
    Result := TT2TiORM.Consultar(ObjetoLocal, pFiltro, pPagina);
  finally
    ObjetoLocal.Free;
  end;
end;

class function TProdutoController.ConsultaLista(pFiltro: String): TListaProdutoVO;
var
  I: Integer;
begin
  try
    ObjetoLocal := TProdutoVO.Create;
    Result := TListaProdutoVO(TT2TiORM.Consultar(ObjetoLocal, pFiltro, True));

    if Assigned(Result) then
    begin
      //Exercício: crie o método para popular esses objetos automaticamente no T2TiORM
      for I := 0 to Result.Count - 1 do
      begin
        Result[I].UnidadeProdutoVO := TUnidadeProdutoVO.Create;
        Result[I].UnidadeProdutoVO := TUnidadeProdutoVO(TT2TiORM.ConsultarUmObjeto(Result[I].UnidadeProdutoVO, 'ID='+IntToStr(Result[I].IdUnidadeProduto), True));
      end;
    end;
  finally
    ObjetoLocal.Free;
  end;
end;

class function TProdutoController.ConsultaObjeto(pFiltro: String): TProdutoVO;
begin
  try
    Result := TProdutoVO.Create;
    Result := TProdutoVO(TT2TiORM.ConsultarUmObjeto(Result, pFiltro, True));

    if Assigned(Result) then
    begin
      //Exercício: crie o método para popular esses objetos automaticamente no T2TiORM
      Result.UnidadeProdutoVO := TUnidadeProdutoVO(TT2TiORM.ConsultarUmObjeto(Result.UnidadeProdutoVO, 'ID='+IntToStr(Result.IdUnidadeProduto), True));
    end;
  finally
  end;
end;

class function TProdutoController.ConsultaPorTipo(pCodigo: String; pTipo: Integer): TProdutoVO;
var
  Filtro: String;
begin
  try
    case pTipo of
      1:
        begin // pesquisa pelo codigo da balanca
          Filtro := 'CODIGO_BALANCA = ' + QuotedStr(pCodigo);
        end;
      2:
        begin // pesquisa pelo GTIN
          Filtro := 'GTIN = ' + QuotedStr(pCodigo);
        end;
      3:
        begin // pesquisa pelo CODIGO_INTERNO ou GTIN
          Filtro := 'CODIGO_INTERNO = ' + QuotedStr(pCodigo);
        end;
      4:
        begin // pesquisa pelo Id
          Filtro := 'ID = ' + QuotedStr(pCodigo);
        end;
    end;
    Result := TProdutoVO.Create;
    Result := TProdutoVO(TT2TiORM.ConsultarUmObjeto(Result, Filtro, True));

    if Assigned(Result) then
    begin
      //Exercício: crie o método para popular esses objetos automaticamente no T2TiORM
      Result.UnidadeProdutoVO := TUnidadeProdutoVO.Create;
      Result.UnidadeProdutoVO := TUnidadeProdutoVO(TT2TiORM.ConsultarUmObjeto(Result.UnidadeProdutoVO, 'ID='+IntToStr(Result.IdUnidadeProduto), True));
    end;
  finally
  end;
end;

class function TProdutoController.Altera(pObjeto: TProdutoVO): Boolean;
begin
  try
    Result := TT2TiORM.Alterar(pObjeto);
  finally
  end;
end;

end.

