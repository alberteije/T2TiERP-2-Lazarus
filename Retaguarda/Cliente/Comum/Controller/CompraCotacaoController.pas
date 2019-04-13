{*******************************************************************************
Title: T2Ti ERP                                                                 
Description: Controller do lado Cliente relacionado à tabela [COMPRA_COTACAO] 
                                                                                
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
           t2ti.com@gmail.com                                                   
                                                                                
@author Albert Eije (t2ti.com@gmail.com)                    
@version 2.0                                                                    
*******************************************************************************}
unit CompraCotacaoController;

{$MODE Delphi}

interface

uses
  Classes, Dialogs, SysUtils, DB, LCLIntf, LCLType, LMessages, Forms, Controller,
  VO, ZDataset, CompraCotacaoVO, CompraFornecedorCotacaoVO,
  CompraCotacaoDetalheVO, CompraReqCotacaoDetalheVO, CompraRequisicaoDetalheVO;

type
  TCompraCotacaoController = class(TController)
  private
  public
    class function Consulta(pFiltro: String; pPagina: String): TZQuery;
    class function ConsultaLista(pFiltro: String): TListaCompraCotacaoVO;
    class function ConsultaObjeto(pFiltro: String): TCompraCotacaoVO;

    class procedure Insere(pObjeto: TCompraCotacaoVO);
    class function Altera(pObjeto: TCompraCotacaoVO): Boolean;

    class function Exclui(pId: Integer): Boolean;

  end;

implementation

uses UDataModule, T2TiORM;

var
  ObjetoLocal: TCompraCotacaoVO;

class function TCompraCotacaoController.Consulta(pFiltro: String; pPagina: String): TZQuery;
begin
  try
    ObjetoLocal := TCompraCotacaoVO.Create;
    Result := TT2TiORM.Consultar(ObjetoLocal, pFiltro, pPagina);
  finally
    ObjetoLocal.Free;
  end;
end;

class function TCompraCotacaoController.ConsultaLista(pFiltro: String): TListaCompraCotacaoVO;
begin
  try
    ObjetoLocal := TCompraCotacaoVO.Create;
    Result := TListaCompraCotacaoVO(TT2TiORM.Consultar(ObjetoLocal, pFiltro, True));
  finally
    ObjetoLocal.Free;
  end;
end;

class function TCompraCotacaoController.ConsultaObjeto(pFiltro: String): TCompraCotacaoVO;
begin
  try
    Result := TCompraCotacaoVO.Create;
    Result := TCompraCotacaoVO(TT2TiORM.ConsultarUmObjeto(Result, pFiltro, True));
  finally
  end;
end;

class procedure TCompraCotacaoController.Insere(pObjeto: TCompraCotacaoVO);
var
  UltimoID, UltimoIDFornecedorCotacao, UltimoIDCotacaoDetalhe: Integer;
  i, j: Integer;
  CompraFornecedorCotacao: TCompraFornecedorCotacaoVO;
  CompraCotacaoDetalhe: TCompraCotacaoDetalheVO;
  CompraReqCotacaoDetalhe: TCompraReqCotacaoDetalheVO;
  CompraRequisicaoDetalhe: TCompraRequisicaoDetalheVO;
begin
  try
    UltimoID := TT2TiORM.Inserir(pObjeto);

    try
      for i := 0 to pObjeto.ListaCompraFornecedorCotacao.Count - 1 do
      begin
        CompraFornecedorCotacao := pObjeto.ListaCompraFornecedorCotacao[i];
        CompraFornecedorCotacao.IdCompraCotacao := UltimoID;
        UltimoIDFornecedorCotacao := TT2TiORM.Inserir(CompraFornecedorCotacao);

        for j := 0 to CompraFornecedorCotacao.ListaCompraCotacaoDetalhe.Count - 1 do
        begin
          CompraCotacaoDetalhe := CompraFornecedorCotacao.ListaCompraCotacaoDetalhe[j];
          CompraCotacaoDetalhe.IdCompraFornecedorCotacao := UltimoIDFornecedorCotacao;
          UltimoIDCotacaoDetalhe := TT2TiORM.Inserir(CompraCotacaoDetalhe);
        end;
      end;
    finally
    end;

    // Lista de itens da requisição que foram utilizados na cotação
    for i := 0 to pObjeto.ListaCompraReqCotacaoDetalheVO.Count - 1 do
    begin

      CompraRequisicaoDetalhe := TCompraRequisicaoDetalheVO.Create;

      //insere os items em COMPRA_REQ_COTACAO_DETALHE
      CompraReqCotacaoDetalhe := pObjeto.ListaCompraReqCotacaoDetalheVO[i];
      CompraReqCotacaoDetalhe.IdCompraCotacao := UltimoID;
      TT2TiORM.Inserir(CompraReqCotacaoDetalhe);

      //atualiza a quantidade cotada em COMPRA_REQUISICAO_DETALHE
      CompraRequisicaoDetalhe.Id := CompraReqCotacaoDetalhe.IdCompraRequisicaoDetalhe;
      CompraRequisicaoDetalhe.QuantidadeCotada := CompraReqCotacaoDetalhe.QuantidadeCotada;
      TT2TiORM.Alterar(CompraRequisicaoDetalhe);
    end;

    Consulta('ID = ' + IntToStr(UltimoID), '0');
  finally
  end;
end;

class function TCompraCotacaoController.Altera(pObjeto: TCompraCotacaoVO): Boolean;
begin
  try
    Result := TT2TiORM.Alterar(pObjeto);
  finally
  end;
end;

class function TCompraCotacaoController.Exclui(pId: Integer): Boolean;
var
  ObjetoLocal: TCompraCotacaoVO;
begin
  try
    ObjetoLocal := TCompraCotacaoVO.Create;
    ObjetoLocal.Id := pId;
    Result := TT2TiORM.Excluir(ObjetoLocal);
  finally
    FreeAndNil(ObjetoLocal)
  end;
end;

initialization
  Classes.RegisterClass(TCompraCotacaoController);

finalization
  Classes.UnRegisterClass(TCompraCotacaoController);

end.

