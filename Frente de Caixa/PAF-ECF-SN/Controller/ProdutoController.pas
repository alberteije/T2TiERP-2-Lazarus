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
  VO, EcfProdutoVO, EcfE3VO, Biblioteca;

type
  TProdutoController = class(TController)
  private
  public
    class function Consulta(pFiltro: String; pPagina: String): TZQuery;
    class function ConsultaLista(pFiltro: String): TListaEcfProdutoVO;
    class function ConsultaObjeto(pFiltro: String): TEcfProdutoVO;
    class function ConsultaPorTipo(pCodigo: String; pTipo: Integer): TEcfProdutoVO;
    class function Altera(pObjeto: TEcfProdutoVO): Boolean;
  end;

implementation

uses T2TiORM, UnidadeProdutoVO;

var
  ObjetoLocal: TEcfProdutoVO;

class function TProdutoController.Consulta(pFiltro: String; pPagina: String): TZQuery;
begin
  try
    ObjetoLocal := TEcfProdutoVO.Create;
    Result := TT2TiORM.Consultar(ObjetoLocal, pFiltro, pPagina);
  finally
    ObjetoLocal.Free;
  end;
end;

class function TProdutoController.ConsultaLista(pFiltro: String): TListaEcfProdutoVO;
var
  I: Integer;
begin
  try
    ObjetoLocal := TEcfProdutoVO.Create;
    Result := TListaEcfProdutoVO(TT2TiORM.Consultar(ObjetoLocal, pFiltro, True));

    if Assigned(Result) then
    begin
      //Exercício: crie o método para popular esses objetos automaticamente no T2TiORM
      for I := 0 to Result.Count - 1 do
      begin
        Result[I].UnidadeEcfProdutoVO := TUnidadeProdutoVO.Create;
        Result[I].UnidadeEcfProdutoVO := TUnidadeProdutoVO(TT2TiORM.ConsultarUmObjeto(Result[I].UnidadeEcfProdutoVO, 'ID='+IntToStr(Result[I].IdUnidadeProduto), True));
      end;
    end;
finally
    ObjetoLocal.Free;
  end;
end;

class function TProdutoController.ConsultaObjeto(pFiltro: String): TEcfProdutoVO;
begin
  try
    Result := TEcfProdutoVO.Create;
    Result := TEcfProdutoVO(TT2TiORM.ConsultarUmObjeto(Result, pFiltro, True));

    if Assigned(Result) then
    begin
      //Exercício: crie o método para popular esses objetos automaticamente no T2TiORM
      Result.UnidadeEcfProdutoVO := TUnidadeProdutoVO(TT2TiORM.ConsultarUmObjeto(Result.UnidadeEcfProdutoVO, 'ID='+IntToStr(Result.IdUnidadeProduto), True));
    end;
  finally
  end;
end;

class function TProdutoController.ConsultaPorTipo(pCodigo: String; pTipo: Integer): TEcfProdutoVO;
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
    Result := TEcfProdutoVO.Create;
    Result := TEcfProdutoVO(TT2TiORM.ConsultarUmObjeto(Result, Filtro, True));

    if Assigned(Result) then
    begin
      //Exercício: crie o método para popular esses objetos automaticamente no T2TiORM
      Result.UnidadeEcfProdutoVO := TUnidadeProdutoVO(TT2TiORM.ConsultarUmObjeto(Result.UnidadeEcfProdutoVO, 'ID='+IntToStr(Result.IdUnidadeProduto), True));
    end;
  finally
  end;
end;

class function TProdutoController.Altera(pObjeto: TEcfProdutoVO): Boolean;
begin
  try
    FormatSettings.DecimalSeparator := '.';
    pObjeto.HashRegistro := '0';
    pObjeto.HashRegistro := MD5Print(MD5String(pObjeto.ToJSONString));
    Result := TT2TiORM.Alterar(pObjeto);
  finally
    FormatSettings.DecimalSeparator := ',';
  end;
end;

end.

