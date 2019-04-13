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

{$MODE Delphi}

interface

uses
  Classes, Dialogs, SysUtils, DB, LCLIntf, LCLType, LMessages, Forms, Controller,
  VO, ProdutoVO, EcfProdutoVO, EcfE3VO, FichaTecnicaVO, Biblioteca, ZDataSet;

type
  TProdutoController = class(TController)
  private
    class function Inserir(pObjeto: TProdutoVO): Integer;
  public
    class function Consulta(pFiltro: String; pPagina: String): TZQuery;
    class function ConsultaObjeto(pFiltro: String): TProdutoVO;
    class procedure Produto(pFiltro: String);
    class function ConsultaLista(pFiltro: String): TListaProdutoVO;
    class procedure Insere(pObjeto: TProdutoVO);
    class procedure InsereObjeto(pObjeto: TProdutoVO);
    class procedure AtualizaEstoquePAF(pEcfE3VO: TEcfE3VO);
    class function Altera(pObjeto: TProdutoVO): Boolean;
    class function Exclui(pId: Integer): Boolean;
    class function ExcluiFichaTecnica(pId: Integer): Boolean;
  end;

implementation

uses
  UDataModule, T2TiORM, UnidadeProdutoVO, AlmoxarifadoVO, TributIcmsCustomCabVO, TributGrupoTributarioVO,
  ProdutoMarcaVO, ProdutoSubGrupoVO;

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

class function TProdutoController.ConsultaObjeto(pFiltro: String): TProdutoVO;
begin
  try
    Result := TProdutoVO.Create;
    Result := TProdutoVO(TT2TiORM.ConsultarUmObjeto(Result, pFiltro, True));

    Filtro := 'ID_PRODUTO = ' + IntToStr(Result.Id);

    // Objetos Vinculados

    // Listas
    Result.ListaFichaTecnicaVO := TListaFichaTecnicaVO(TT2TiORM.Consultar(TFichaTecnicaVO.Create, Filtro, True));

  finally
  end;
end;

class procedure TProdutoController.Produto(pFiltro: String);
var
  ObjetoLocal: TProdutoVO;
begin
  try
    ObjetoLocal := TProdutoVO.Create;
    ObjetoLocal := TProdutoVO(TT2TiORM.ConsultarUmObjeto(ObjetoLocal, pFiltro, True));
  finally
  end;
end;

class function TProdutoController.ConsultaLista(pFiltro: String): TListaProdutoVO;
begin
  try
    ObjetoLocal := TProdutoVO.Create;
    Result := TListaProdutoVO(TT2TiORM.Consultar(ObjetoLocal, pFiltro, True));
  finally
    ObjetoLocal.Free;
  end;
end;

class procedure TProdutoController.Insere(pObjeto: TProdutoVO);
var
  UltimoID: Integer;
begin
  try
    UltimoID := Inserir(pObjeto);
    Consulta('ID = ' + IntToStr(UltimoID), '0');
  finally
  end;
end;

class procedure TProdutoController.InsereObjeto(pObjeto: TProdutoVO);
var
  UltimoID: Integer;
begin
  try
    UltimoID := Inserir(pObjeto);
  finally
  end;
end;

class function TProdutoController.Inserir(pObjeto: TProdutoVO): Integer;
var
  I: Integer;
begin
  try
    Result := TT2TiORM.Inserir(pObjeto);
    // FichaTecnica
    for I := 0 to pObjeto.ListaFichaTecnicaVO.Count -1 do;
    begin
      pObjeto.ListaFichaTecnicaVO[I].IdProduto := Result;
      TT2TiORM.Inserir(pObjeto.ListaFichaTecnicaVO[I]);
    end;
  finally
  end;
end;

class procedure TProdutoController.AtualizaEstoquePAF(pEcfE3VO: TEcfE3VO);
var
  Filtro: String;
  UltimoID: Integer;
  Retorno: TEcfE3VO;
begin
  try
    Filtro := 'DATA_ESTOQUE = ' + QuotedStr(DataParaTexto(pEcfE3VO.DataEstoque));
    ObjetoLocal := TProdutoVO.Create;
    Retorno := TEcfE3VO(TT2TiORM.ConsultarUmObjeto(ObjetoLocal, Filtro, False));
  finally
    ObjetoLocal.Free;
  end;

  if Assigned(Retorno) then
       // Se não, adiciona o objeto e retorna
  else
  begin
    UltimoID := TT2TiORM.Inserir(pEcfE3VO);
    Filtro := 'ID = ' + IntToStr(UltimoID);
    ObjetoLocal := TProdutoVO.Create;
    Retorno := TEcfE3VO(TT2TiORM.ConsultarUmObjeto(ObjetoLocal, Filtro, False));

  end;
end;

class function TProdutoController.Altera(pObjeto: TProdutoVO): Boolean;
var
  I: Integer;
begin
  try
    Result := TT2TiORM.Alterar(pObjeto);
    for I := 0 to pObjeto.ListaFichaTecnicaVO.Count -1 do;
    begin
      if pObjeto.ListaFichaTecnicaVO[I].Id > 0 then
         Result := TT2TiORM.Alterar(pObjeto.ListaFichaTecnicaVO[I])
      else
      begin
         pObjeto.ListaFichaTecnicaVO[I].IdProduto := pObjeto.Id;
         Result := TT2TiORM.Inserir(pObjeto.ListaFichaTecnicaVO[I]) > 0;
      end;
    end;
  finally
  end;
end;

class function TProdutoController.Exclui(pId: Integer): Boolean;
var
  ObjetoLocal: TProdutoVO;
begin
  try
    ObjetoLocal := TProdutoVO.Create;
    ObjetoLocal.Id := pId;
    Result := TT2TiORM.Excluir(ObjetoLocal);
  finally
    FreeAndNil(ObjetoLocal)
  end;
end;

class function TProdutoController.ExcluiFichaTecnica(pId: Integer): Boolean;
var
  ObjetoLocal: TFichaTecnicaVO;
begin
  try
    ObjetoLocal := TFichaTecnicaVO.Create;
    ObjetoLocal.Id := pId;
    Result := TT2TiORM.Excluir(ObjetoLocal);
  finally
    FreeAndNil(ObjetoLocal)
  end;
end;

initialization
  Classes.RegisterClass(TProdutoController);

finalization
  Classes.UnRegisterClass(TProdutoController);

end.

