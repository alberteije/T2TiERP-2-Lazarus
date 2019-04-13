{*******************************************************************************
Title: T2Ti ERP                                                                 
Description: Controller do lado Cliente relacionado à tabela [VIEW_COMPRA_MAPA_COMPARATIVO] 
                                                                                
The MIT License                                                                 
                                                                                
Copyright: Copyright (C) 2015 T2Ti.COM
                                                                                
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
           t2ti.com@gmail.com                                                   
                                                                                
@author Albert Eije (t2ti.com@gmail.com)                    
@version 2.0                                                                    
*******************************************************************************}
unit ViewCompraMapaComparativoController;

interface

uses
  Classes, Dialogs, SysUtils, DB, LCLIntf, LCLType, LMessages, Forms, Controller,
  VO, ZDataset, ViewCompraMapaComparativoVO,
  CompraCotacaoVO, CompraPedidoVO, CompraPedidoDetalheVO, CompraCotacaoPedidoDetalheVO,
  CompraCotacaoDetalheVO;

type
  TViewCompraMapaComparativoController = class(TController)
  private
  public
    class function Consulta(pFiltro: String; pPagina: String): TZQuery;
    class function ConsultaLista(pFiltro: String): TListaViewCompraMapaComparativoVO;
    class function ConsultaObjeto(pFiltro: String): TViewCompraMapaComparativoVO;

    class procedure Insere(pObjeto: TViewCompraMapaComparativoVO);
    class function Altera(pObjeto: TViewCompraMapaComparativoVO): Boolean;

    class function GerarPedidos(pObjeto: TCompraCotacaoVO): Boolean;
  end;

implementation

uses UDataModule, T2TiORM;

var
  ObjetoLocal: TViewCompraMapaComparativoVO;

class function TViewCompraMapaComparativoController.Consulta(pFiltro: String; pPagina: String): TZQuery;
begin
  try
    ObjetoLocal := TViewCompraMapaComparativoVO.Create;
    Result := TT2TiORM.Consultar(ObjetoLocal, pFiltro, pPagina);
  finally
    ObjetoLocal.Free;
  end;
end;

class function TViewCompraMapaComparativoController.ConsultaLista(pFiltro: String): TListaViewCompraMapaComparativoVO;
begin
  try
    ObjetoLocal := TViewCompraMapaComparativoVO.Create;
    Result := TListaViewCompraMapaComparativoVO(TT2TiORM.Consultar(ObjetoLocal, pFiltro, True));
  finally
    ObjetoLocal.Free;
  end;
end;

class function TViewCompraMapaComparativoController.ConsultaObjeto(pFiltro: String): TViewCompraMapaComparativoVO;
begin
  try
    Result := TViewCompraMapaComparativoVO.Create;
    Result := TViewCompraMapaComparativoVO(TT2TiORM.ConsultarUmObjeto(Result, pFiltro, True));
  finally
  end;
end;

class procedure TViewCompraMapaComparativoController.Insere(pObjeto: TViewCompraMapaComparativoVO);
var
  UltimoID: Integer;
begin
  try
    UltimoID := TT2TiORM.Inserir(pObjeto);
    Consulta('ID = ' + IntToStr(UltimoID), '0');
  finally
  end;
end;

class function TViewCompraMapaComparativoController.Altera(pObjeto: TViewCompraMapaComparativoVO): Boolean;
begin
  try
    Result := TT2TiORM.Alterar(pObjeto);
  finally
  end;
end;

class function TViewCompraMapaComparativoController.GerarPedidos(pObjeto: TCompraCotacaoVO): Boolean;
var
  UltimoID: Integer;
  i, j: Integer;
  FornecedorAtual: Integer;
  //
  objViewCompraMapaComparativo: TViewCompraMapaComparativoVO;
  //
  CompraCotacao: TCompraCotacaoVO;
  CompraPedido: TCompraPedidoVO;
  CompraPedidoDetalhe: TCompraPedidoDetalheVO;
  CompraCotacaoPedidoDetalhe: TCompraCotacaoPedidoDetalheVO;
  CompraCotacaoDetalhe: TCompraCotacaoDetalheVO;
begin

  try
    for i := 0 to pObjeto.ListaMapaComparativo.Count - 1 do
    begin
      objViewCompraMapaComparativo := pObjeto.ListaMapaComparativo[i];

      /// EXERCICIO: Um novo pedido é sempre criado. E se já existir um pedido para esse fornecedor referente a essa cotação? Corrija isso!

      CompraPedido := TCompraPedidoVO.Create;
      CompraPedido.ListaCompraPedidoDetalheVO := TListaCompraPedidoDetalheVO.Create;
      CompraPedido.ListaCompraCotacaoPedidoDetalheVO := TListaCompraCotacaoPedidoDetalheVO.Create;
      // Pedido vindo de cotação sempre será marcado como Normal
      CompraPedido.IdCompraTipoPedido := 1;
      CompraPedido.IdFornecedor := objViewCompraMapaComparativo.IdFornecedor;
      CompraPedido.DataPedido := Now;

      // Insere o item no pedido
      CompraPedidoDetalhe := TCompraPedidoDetalheVO.Create;
      CompraPedidoDetalhe.IdProduto := objViewCompraMapaComparativo.IdProduto;
      CompraPedidoDetalhe.Quantidade := objViewCompraMapaComparativo.QuantidadePedida;
      CompraPedidoDetalhe.ValorUnitario := objViewCompraMapaComparativo.ValorUnitario;
      CompraPedidoDetalhe.ValorSubtotal := objViewCompraMapaComparativo.ValorSubtotal;
      CompraPedidoDetalhe.TaxaDesconto := objViewCompraMapaComparativo.TaxaDesconto;
      CompraPedidoDetalhe.ValorDesconto := objViewCompraMapaComparativo.ValorDesconto;
      CompraPedidoDetalhe.ValorTotal := objViewCompraMapaComparativo.ValorTotal;
      CompraPedido.ListaCompraPedidoDetalheVO.Add(CompraPedidoDetalhe);

      // Insere o item da cotação que foi utilizado no pedido
      CompraCotacaoPedidoDetalhe := TCompraCotacaoPedidoDetalheVO.Create;
      CompraCotacaoPedidoDetalhe.IdCompraCotacaoDetalhe := objViewCompraMapaComparativo.IdCompraCotacaoDetalhe;
      CompraCotacaoPedidoDetalhe.QuantidadePedida := objViewCompraMapaComparativo.QuantidadePedida;
      CompraPedido.ListaCompraCotacaoPedidoDetalheVO.Add(CompraCotacaoPedidoDetalhe);

      // Insere o Pedido
      UltimoID := TT2TiORM.Inserir(CompraPedido);

      // Insere os itens do pedido no banco de dados
      for j := 0 to CompraPedido.ListaCompraPedidoDetalheVO.Count - 1 do
      begin
        CompraPedidoDetalhe := CompraPedido.ListaCompraPedidoDetalheVO[j];
        CompraPedidoDetalhe.IdCompraPedido := UltimoID;
        TT2TiORM.Inserir(CompraPedidoDetalhe);
      end;

      // Insere os items em COMPRA_COTACAO_PEDIDO_DETALHE
      for j := 0 to CompraPedido.ListaCompraCotacaoPedidoDetalheVO.Count - 1 do
      begin
        CompraCotacaoPedidoDetalhe := CompraPedido.ListaCompraCotacaoPedidoDetalheVO[j];
        CompraCotacaoPedidoDetalhe.IdCompraPedido := UltimoID;
        TT2TiORM.Inserir(CompraCotacaoPedidoDetalhe);
      end;

      // Atualiza o detalhe da cotação no banco de dados
      CompraCotacaoDetalhe := TCompraCotacaoDetalheVO.Create;
      CompraCotacaoDetalhe.Id := objViewCompraMapaComparativo.IdCompraCotacaoDetalhe;
      CompraCotacaoDetalhe.QuantidadePedida := objViewCompraMapaComparativo.QuantidadePedida;
      TT2TiORM.Alterar(CompraCotacaoDetalhe);
    end;

    // Atualiza o campo SITUACAO da cotação para F - Fechada
    CompraCotacao := TCompraCotacaoVO.Create;
    CompraCotacao.Id := objViewCompraMapaComparativo.IdCompraCotacao;
    CompraCotacao.Situacao := 'F';
    Result := TT2TiORM.Alterar(CompraCotacao);
  finally
  end;
end;

initialization
  Classes.RegisterClass(TViewCompraMapaComparativoController);

finalization
  Classes.UnRegisterClass(TViewCompraMapaComparativoController);

end.

