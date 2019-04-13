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
  Classes, SysUtils, EcfVendaCabecalhoVO, EcfVendaDetalheVO, md5,
  VO, Controller, Biblioteca, EcfTotalTipoPagamentoVO;

type
  TVendaController = class(TController)
  private
  public
    class function ConsultaLista(pFiltro: String): TListaEcfVendaCabecalhoVO;
    class function ConsultaObjeto(pFiltro: String): TEcfVendaCabecalhoVO;
    class function VendaDetalhe(pFiltro: String): TEcfVendaDetalheVO;
    class function ExisteVendaAberta: Boolean;
    class function Insere(pObjeto: TEcfVendaCabecalhoVO): TEcfVendaCabecalhoVO;
    class function InsereItem(pObjeto: TEcfVendaDetalheVO): TEcfVendaDetalheVO;
    class function Altera(pObjeto: TEcfVendaCabecalhoVO): Boolean;
    class function CancelaVenda(pObjeto: TEcfVendaCabecalhoVO): Boolean;
    class function CancelaItemVenda(pObjeto: TEcfVendaDetalheVO): Boolean;
  end;

implementation

uses T2TiORM, EcfMovimentoController, LogssController, ClienteVO, EcfFuncionarioVO,
  ProdutoController;

var
  ObjetoLocal: TEcfVendaCabecalhoVO;

class function TVendaController.ConsultaLista(pFiltro: String): TListaEcfVendaCabecalhoVO;
begin
  try
    ObjetoLocal := TEcfVendaCabecalhoVO.Create;
    Result := TListaEcfVendaCabecalhoVO(TT2TiORM.Consultar(ObjetoLocal, pFiltro, True));
  finally
    ObjetoLocal.Free;
  end;
end;

class function TVendaController.ConsultaObjeto(pFiltro: String): TEcfVendaCabecalhoVO;
var
  Filtro: String;
begin
  try
    Result := TEcfVendaCabecalhoVO.Create;
    Result := TEcfVendaCabecalhoVO(TT2TiORM.ConsultarUmObjeto(Result, pFiltro, True));

    if Assigned(Result) then
    begin
      //Exercício: crie o método para popular esses objetos automaticamente no T2TiORM
      Result.EcfFuncionarioVO := TEcfFuncionarioVO(TT2TiORM.ConsultarUmObjeto(Result.EcfFuncionarioVO, 'ID='+IntToStr(Result.IdEcfFuncionario), True));
      Result.EcfMovimentoVO := TEcfMovimentoController.ConsultaObjeto('ID='+IntToStr(Result.IdEcfMovimento));

      Filtro := 'ID_ECF_VENDA_CABECALHO = ' + IntToStr(Result.Id);
      Result.ListaEcfVendaDetalheVO := TListaEcfVendaDetalheVO(TT2TiORM.Consultar(TEcfVendaDetalheVO.Create, Filtro, True));
      Result.ListaEcfTotalTipoPagamentoVO := TListaEcfTotalTipoPagamentoVO(TT2TiORM.Consultar(TEcfTotalTipoPagamentoVO.Create, Filtro, True));
    end;
  finally
  end;
end;

class function TVendaController.VendaDetalhe(pFiltro: String): TEcfVendaDetalheVO;
begin
  try
    Result := TEcfVendaDetalheVO.Create;
    Result := TEcfVendaDetalheVO(TT2TiORM.ConsultarUmObjeto(Result, pFiltro, True));

    //Exercício: crie o método para popular esses objetos automaticamente no T2TiORM
    Result.EcfProdutoVO := TProdutoController.ConsultaObjeto('ID='+IntToStr(Result.IdEcfProduto));
finally
  end;
end;

class function TVendaController.ExisteVendaAberta: Boolean;
var
  Filtro: String;
  Retorno: TListaEcfVendaCabecalhoVO;
begin
  try
    ObjetoLocal := TEcfVendaCabecalhoVO.Create;
    Filtro := 'STATUS_VENDA = ' + QuotedStr('A');
    Retorno := TListaEcfVendaCabecalhoVO(TT2TiORM.Consultar(ObjetoLocal, Filtro, False));
    Result := Assigned(Retorno);
  finally
    ObjetoLocal.Free;
  end;
end;

class function TVendaController.Insere(pObjeto: TEcfVendaCabecalhoVO): TEcfVendaCabecalhoVO;
var
  UltimoID: Integer;
begin
  try
    pObjeto.SerieEcf := Sessao.Configuracao.EcfImpressoraVO.Serie;
    UltimoID := TT2TiORM.Inserir(pObjeto);
    Result := ConsultaObjeto('ID=' + IntToStr(UltimoID));
  finally
  end;
end;

class function TVendaController.InsereItem(pObjeto: TEcfVendaDetalheVO): TEcfVendaDetalheVO;
var
  UltimoID: Integer;
begin
  try
    if pObjeto.EcfProdutoVO.EcfIcmsSt = 'NN' then
      pObjeto.EcfIcmsSt := 'N'
    else if pObjeto.EcfProdutoVO.EcfIcmsSt = 'FF' then
      pObjeto.EcfIcmsSt := 'F'
    else if pObjeto.EcfProdutoVO.EcfIcmsSt = 'II' then
      pObjeto.EcfIcmsSt := 'I'
    else
    begin
      if copy(pObjeto.TotalizadorParcial, 3, 1) = 'S' then
        pObjeto.EcfIcmsSt := copy(pObjeto.TotalizadorParcial, 4, 4)
      else if copy(pObjeto.TotalizadorParcial, 3, 1) = 'T' then
        pObjeto.EcfIcmsSt := copy(pObjeto.TotalizadorParcial, 4, 4)
      else if pObjeto.TotalizadorParcial = 'Can-T' then
        pObjeto.EcfIcmsSt := 'CANC'
      else
      begin
        pObjeto.EcfIcmsSt := '1700';
      end;
    end;

    pObjeto.Cancelado := 'N';

    if (pObjeto.EcfProdutoVO.EcfIcmsSt = 'II') or (pObjeto.EcfProdutoVO.EcfIcmsSt = 'NN') then
      pObjeto.TaxaICMS := 0;

    pObjeto.SerieEcf := Sessao.Configuracao.EcfImpressoraVO.Serie;

    FormatSettings.DecimalSeparator := '.';
    pObjeto.HashRegistro := '0';
    pObjeto.HashRegistro := MD5Print(MD5String(pObjeto.ToJSONString));
    UltimoID := TT2TiORM.Inserir(pObjeto);

    Result := VendaDetalhe('ID = ' + IntToStr(UltimoID));
  finally
    FormatSettings.DecimalSeparator := ',';
  end;
end;

class function TVendaController.Altera(pObjeto: TEcfVendaCabecalhoVO): Boolean;
begin
  try
    FormatSettings.DecimalSeparator := '.';
    pObjeto.HashRegistro := '0';
    pObjeto.HashRegistro := MD5Print(MD5String(pObjeto.ToJSONString));
    Result := TT2TiORM.Alterar(pObjeto);
    TLogssController.AtualizarQuantidades;
  finally
    FormatSettings.DecimalSeparator := ',';
  end;
end;

class function TVendaController.CancelaVenda(pObjeto: TEcfVendaCabecalhoVO): Boolean;
var
  I: Integer;
begin
  try
    FormatSettings.DecimalSeparator := '.';
    pObjeto.HashRegistro := '0';
    pObjeto.HashRegistro := MD5Print(MD5String(pObjeto.ToJSONString));
    Result := TT2TiORM.Alterar(pObjeto);

    // Detalhes
    for I := 0 to pObjeto.ListaEcfVendaDetalheVO.Count - 1 do
    begin
      pObjeto.ListaEcfVendaDetalheVO[I].TotalizadorParcial := 'Can-T';
      pObjeto.ListaEcfVendaDetalheVO[I].Cancelado := 'S';
      pObjeto.ListaEcfVendaDetalheVO[I].Ccf := pObjeto.Ccf;
      pObjeto.ListaEcfVendaDetalheVO[I].Coo := pObjeto.Coo;
      pObjeto.ListaEcfVendaDetalheVO[I].HashRegistro := '0';
      pObjeto.ListaEcfVendaDetalheVO[I].HashRegistro := MD5Print(MD5String(pObjeto.ListaEcfVendaDetalheVO[I].ToJSONString));
      Result := TT2TiORM.Alterar(pObjeto.ListaEcfVendaDetalheVO[I])
    end;

    // Pagamentos
    for I := 0 to pObjeto.ListaEcfTotalTipoPagamentoVO.Count - 1 do
    begin
      pObjeto.ListaEcfTotalTipoPagamentoVO[I].Estorno := 'S';
      pObjeto.ListaEcfTotalTipoPagamentoVO[I].HashRegistro := '0';
      pObjeto.ListaEcfTotalTipoPagamentoVO[I].HashRegistro := MD5Print(MD5String(pObjeto.ListaEcfTotalTipoPagamentoVO[I].ToJSONString));
      Result := TT2TiORM.Alterar(pObjeto.ListaEcfTotalTipoPagamentoVO[I])
    end;

  finally
    FormatSettings.DecimalSeparator := ',';
  end;
end;

class function TVendaController.CancelaItemVenda(pObjeto: TEcfVendaDetalheVO): Boolean;
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
