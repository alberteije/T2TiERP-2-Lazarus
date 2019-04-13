{*******************************************************************************
Title: T2Ti ERP                                                                 
Description: Controller do lado Cliente relacionado à tabela [COMPRA_FORNECEDOR_COTACAO] 
                                                                                
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
unit CompraFornecedorCotacaoController;

{$MODE Delphi}

interface

uses
  Classes, Dialogs, SysUtils, DB, LCLIntf, LCLType, LMessages, Forms, Controller,
  VO, ZDataset, CompraFornecedorCotacaoVO, CompraCotacaoVO,
  CompraCotacaoDetalheVO;

type
  TCompraFornecedorCotacaoController = class(TController)
  private
  public
    class function Consulta(pFiltro: String; pPagina: String): TZQuery;
    class function ConsultaLista(pFiltro: String): TListaCompraFornecedorCotacaoVO;
    class function ConsultaObjeto(pFiltro: String): TCompraFornecedorCotacaoVO;

    class procedure Insere(pObjeto: TCompraFornecedorCotacaoVO);
    class function Altera(pObjeto: TCompraCotacaoVO): Boolean;

    class function Exclui(pId: Integer): Boolean;

  end;

implementation

uses UDataModule, T2TiORM;

var
  ObjetoLocal: TCompraFornecedorCotacaoVO;

class function TCompraFornecedorCotacaoController.Consulta(pFiltro: String; pPagina: String): TZQuery;
begin
  try
    ObjetoLocal := TCompraFornecedorCotacaoVO.Create;
    Result := TT2TiORM.Consultar(ObjetoLocal, pFiltro, pPagina);
  finally
    ObjetoLocal.Free;
  end;
end;

class function TCompraFornecedorCotacaoController.ConsultaLista(pFiltro: String): TListaCompraFornecedorCotacaoVO;
begin
  try
    ObjetoLocal := TCompraFornecedorCotacaoVO.Create;
    Result := TListaCompraFornecedorCotacaoVO(TT2TiORM.Consultar(ObjetoLocal, pFiltro, True));
  finally
    ObjetoLocal.Free;
  end;
end;

class function TCompraFornecedorCotacaoController.ConsultaObjeto(pFiltro: String): TCompraFornecedorCotacaoVO;
begin
  try
    Result := TCompraFornecedorCotacaoVO.Create;
    Result := TCompraFornecedorCotacaoVO(TT2TiORM.ConsultarUmObjeto(Result, pFiltro, True));
  finally
  end;
end;

class procedure TCompraFornecedorCotacaoController.Insere(pObjeto: TCompraFornecedorCotacaoVO);
var
  UltimoID: Integer;
begin
  try
    UltimoID := TT2TiORM.Inserir(pObjeto);
    Consulta('ID = ' + IntToStr(UltimoID), '0');
  finally
  end;
end;

class function TCompraFornecedorCotacaoController.Altera(pObjeto: TCompraCotacaoVO): Boolean;
var
  CompraCotacao: TCompraCotacaoVO;
  CompraConfirmaFornecedorCotacao: TCompraFornecedorCotacaoVO;
  Current: TCompraCotacaoDetalheVO;
  i, j: Integer;
begin
  try
    for i := 0 to pObjeto.ListaCompraFornecedorCotacao.Count - 1 do
    begin
      CompraConfirmaFornecedorCotacao := pObjeto.ListaCompraFornecedorCotacao[i];
      Result := TT2TiORM.Alterar(CompraConfirmaFornecedorCotacao);

      // Itens de cotação do fornecedor
      for j := 0 to CompraConfirmaFornecedorCotacao.ListaCompraCotacaoDetalhe.Count - 1 do
      begin
        Current := CompraConfirmaFornecedorCotacao.ListaCompraCotacaoDetalhe[j];
        Result := TT2TiORM.Alterar(Current);
      end;
    end;

    Result := TT2TiORM.Alterar(pObjeto);
  finally
  end;
end;

class function TCompraFornecedorCotacaoController.Exclui(pId: Integer): Boolean;
var
  ObjetoLocal: TCompraFornecedorCotacaoVO;
begin
  try
    ObjetoLocal := TCompraFornecedorCotacaoVO.Create;
    ObjetoLocal.Id := pId;
    Result := TT2TiORM.Excluir(ObjetoLocal);
  finally
    FreeAndNil(ObjetoLocal)
  end;
end;

initialization
  Classes.RegisterClass(TCompraFornecedorCotacaoController);

finalization
  Classes.UnRegisterClass(TCompraFornecedorCotacaoController);

end.

