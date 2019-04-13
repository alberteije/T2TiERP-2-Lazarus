{ *******************************************************************************
Title: T2Ti ERP
Description: Controller relacionado aos procedimentos de venda

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
unit VendaController;

interface

uses
  Classes, SysUtils, NfeCabecalhoVO, NfeDetalheVO, md5, ZDataset,
  VO, Controller, Biblioteca, NfeFormaPagamentoVO;

type
  TVendaController = class(TController)
  private
  public
    class function Consulta(pFiltro: String; pPagina: String): TZQuery;
    class function ConsultaLista(pFiltro: String): TListaNfeCabecalhoVO;
    class function ConsultaObjeto(pFiltro: String): TNfeCabecalhoVO;
    class function VendaDetalhe(pFiltro: String): TNfeDetalheVO;
    class function Insere(pObjeto: TNfeCabecalhoVO): TNfeCabecalhoVO;
    class function InsereItem(pObjeto: TNfeDetalheVO): TNfeDetalheVO;
    class function Altera(pObjeto: TNfeCabecalhoVO): Boolean;
    class function CancelaVenda(pObjeto: TNfeCabecalhoVO): Boolean;
    class function CancelaItemVenda(pItem: Integer): Boolean;
  end;

implementation

uses T2TiORM, NfceMovimentoController, ProdutoController, ControleEstoqueController,
     NfeDestinatarioVO, NfeDetalheImpostoIcmsVO;

var
  ObjetoLocal: TNfeCabecalhoVO;

class function TVendaController.Consulta(pFiltro: String; pPagina: String): TZQuery;
begin
  try
    ObjetoLocal := TNfeCabecalhoVO.Create;
    Result := TT2TiORM.Consultar(ObjetoLocal, pFiltro, pPagina);
  finally
    ObjetoLocal.Free;
  end;
end;

class function TVendaController.ConsultaLista(pFiltro: String): TListaNfeCabecalhoVO;
begin
  try
    ObjetoLocal := TNfeCabecalhoVO.Create;
    Result := TListaNfeCabecalhoVO(TT2TiORM.Consultar(ObjetoLocal, pFiltro, True));
  finally
    ObjetoLocal.Free;
  end;
end;

class function TVendaController.ConsultaObjeto(pFiltro: String): TNfeCabecalhoVO;
var
  Filtro: String;
  i: Integer;
begin
  try
    Result := TNfeCabecalhoVO.Create;
    Result := TNfeCabecalhoVO(TT2TiORM.ConsultarUmObjeto(Result, pFiltro, True));

    if Assigned(Result) then
    begin
      //Exercício: crie o método para popular esses objetos automaticamente no T2TiORM
      Filtro := 'ID_NFE_CABECALHO = ' + IntToStr(Result.Id);

      Result.NfeDestinatarioVO := TNfeDestinatarioVO(TT2TiORM.ConsultarUmObjeto(Result.NfeDestinatarioVO, Filtro, True));
      if not Assigned(Result.NfeDestinatarioVO) then
        Result.NfeDestinatarioVO := TNfeDestinatarioVO.Create;
      Result.ListaNfeDetalheVO := TListaNfeDetalheVO(TT2TiORM.Consultar(TNfeDetalheVO.Create, Filtro, True));

      for I := 0 to Result.ListaNfeDetalheVO.Count - 1 do
      begin
        Filtro := 'ID_NFE_DETALHE='+IntToStr(Result.ListaNfeDetalheVO[I].Id);
        Result.ListaNfeDetalheVO[I].NfeDetalheImpostoIcmsVO := TNfeDetalheImpostoIcmsVO.Create;
        Result.ListaNfeDetalheVO[I].NfeDetalheImpostoIcmsVO := TNfeDetalheImpostoIcmsVO(TT2TiORM.ConsultarUmObjeto(Result.ListaNfeDetalheVO[I].NfeDetalheImpostoIcmsVO, Filtro, True));
      end;
    end;
  finally
  end;
end;

class function TVendaController.VendaDetalhe(pFiltro: String): TNfeDetalheVO;
var
  Filtro: String;
begin
  try
    Result := TNfeDetalheVO.Create;
    Result := TNfeDetalheVO(TT2TiORM.ConsultarUmObjeto(Result, pFiltro, True));

    //Exercício: crie o método para popular esses objetos automaticamente no T2TiORM
    Result.ProdutoVO := TProdutoController.ConsultaObjeto('ID='+IntToStr(Result.IdProduto));

    Filtro := 'ID_NFE_DETALHE='+IntToStr(Result.Id);
    Result.NfeDetalheImpostoIcmsVO := TNfeDetalheImpostoIcmsVO(TT2TiORM.ConsultarUmObjeto(Result.NfeDetalheImpostoIcmsVO, Filtro, True));
finally
  end;
end;

class function TVendaController.Insere(pObjeto: TNfeCabecalhoVO): TNfeCabecalhoVO;
var
  UltimoID: Integer;
begin
  try
    UltimoID := TT2TiORM.Inserir(pObjeto);

    { Destinatario }
    if pObjeto.NfeDestinatarioVO.CpfCnpj <> '' then
    begin
      pObjeto.NfeDestinatarioVO.IdNfeCabecalho := UltimoID;
      TT2TiORM.Inserir(pObjeto.NfeDestinatarioVO);
    end;

    Result := ConsultaObjeto('ID=' + IntToStr(UltimoID));
  finally
  end;
end;

class function TVendaController.InsereItem(pObjeto: TNfeDetalheVO): TNfeDetalheVO;
var
  UltimoID: Integer;
begin
  try
    UltimoID := TT2TiORM.Inserir(pObjeto);

    TControleEstoqueController.AtualizarEstoque(pObjeto.QuantidadeComercial * -1, pObjeto.IdProduto, Sessao.VendaAtual.IdEmpresa, Sessao.Configuracao.EmpresaVO.TipoControleEstoque);

    { Detalhe - Imposto - ICMS }
    pObjeto.NfeDetalheImpostoIcmsVO.IdNfeDetalhe := UltimoID;
    TT2TiORM.Inserir(pObjeto.NfeDetalheImpostoIcmsVO);

    Result := VendaDetalhe('ID = ' + IntToStr(UltimoID));
  finally
  end;
end;

class function TVendaController.Altera(pObjeto: TNfeCabecalhoVO): Boolean;
begin
  try
    Result := TT2TiORM.Alterar(pObjeto);

    { Destinatario }
    if pObjeto.NfeDestinatarioVO.Id > 0 then
      Result := TT2TiORM.Alterar(pObjeto.NfeDestinatarioVO)
    else
    begin
      pObjeto.NfeDestinatarioVO.IdNfeCabecalho := pObjeto.Id;
      Result := TT2TiORM.Inserir(pObjeto.NfeDestinatarioVO) > 0;
    end;

  finally
  end;
end;

class function TVendaController.CancelaVenda(pObjeto: TNfeCabecalhoVO): Boolean;
var
  I: Integer;
begin
  try
    Result := TT2TiORM.Alterar(pObjeto);

    // Detalhes
    for I := 0 to pObjeto.ListaNfeDetalheVO.Count - 1 do
    begin
      Result := TT2TiORM.Alterar(pObjeto.ListaNfeDetalheVO[I])
    end;

    // Pagamentos
    for I := 0 to pObjeto.ListaNfeFormaPagamentoVO.Count - 1 do
    begin
      pObjeto.ListaNfeFormaPagamentoVO[I].Estorno := 'S';
      Result := TT2TiORM.Alterar(pObjeto.ListaNfeFormaPagamentoVO[I])
    end;

  finally
  end;
end;

class function TVendaController.CancelaItemVenda(pItem: Integer): Boolean;
var
  NfeDetalhe: TNfeDetalheVO;
begin
  try
    NfeDetalhe := TNfeDetalheVO.Create;
    NfeDetalhe :=  TNfeDetalheVO((TT2TiORM.ConsultarUmObjeto(NfeDetalhe, 'NUMERO_ITEM=' + IntToStr(pitem) + ' AND ID_NFE_CABECALHO=' + IntToStr(Sessao.VendaAtual.Id), True)));

    Result := TT2TiORM.ComandoSQL('DELETE FROM NFE_DETALHE_IMPOSTO_COFINS where ID_NFE_DETALHE = ' + IntToStr(NfeDetalhe.Id));
    Result := TT2TiORM.ComandoSQL('DELETE FROM NFE_DETALHE_IMPOSTO_PIS where ID_NFE_DETALHE = ' + IntToStr(NfeDetalhe.Id));
    Result := TT2TiORM.ComandoSQL('DELETE FROM NFE_DETALHE_IMPOSTO_ICMS where ID_NFE_DETALHE = ' + IntToStr(NfeDetalhe.Id));
    Result := TT2TiORM.ComandoSQL('DELETE FROM NFE_DETALHE_IMPOSTO_II where ID_NFE_DETALHE = ' + IntToStr(NfeDetalhe.Id));
    Result := TT2TiORM.ComandoSQL('DELETE FROM NFE_DETALHE_IMPOSTO_IPI where ID_NFE_DETALHE = ' + IntToStr(NfeDetalhe.Id));
    Result := TT2TiORM.ComandoSQL('DELETE FROM NFE_DETALHE_IMPOSTO_ISSQN where ID_NFE_DETALHE = ' + IntToStr(NfeDetalhe.Id));
    Result := TT2TiORM.ComandoSQL('DELETE FROM NFE_DET_ESPECIFICO_COMBUSTIVEL where ID_NFE_DETALHE = ' + IntToStr(NfeDetalhe.Id));
    Result := TT2TiORM.ComandoSQL('DELETE FROM NFE_DET_ESPECIFICO_VEICULO where ID_NFE_DETALHE = ' + IntToStr(NfeDetalhe.Id));
    Result := TT2TiORM.ComandoSQL('DELETE FROM NFE_DET_ESPECIFICO_ARMAMENTO where ID_NFE_DETALHE = ' + IntToStr(NfeDetalhe.Id));
    Result := TT2TiORM.ComandoSQL('DELETE FROM NFE_DET_ESPECIFICO_MEDICAMENTO where ID_NFE_DETALHE = ' + IntToStr(NfeDetalhe.Id));

    // Exercício - atualize o estoque

    Result := TT2TiORM.ComandoSQL('DELETE FROM NFE_DETALHE where ID = ' + IntToStr(NfeDetalhe.Id));
  finally
  end;
end;


end.
