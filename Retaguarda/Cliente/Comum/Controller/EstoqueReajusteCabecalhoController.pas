{*******************************************************************************
Title: T2Ti ERP                                                                 
Description: Controller do lado Cliente relacionado à tabela [ESTOQUE_REAJUSTE_CABECALHO] 
                                                                                
The MIT License                                                                 
                                                                                
Copyright: Copyright (C) 2016 T2Ti.COM                                          
                                                                                
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
unit EstoqueReajusteCabecalhoController;

{$MODE Delphi}

interface

uses
  Classes, Dialogs, SysUtils, DB, LCLIntf, LCLType, LMessages, Forms, Controller,
  VO, ZDataset, EstoqueReajusteCabecalhoVO;

type
  TEstoqueReajusteCabecalhoController = class(TController)
  private
  public
    class function Consulta(pFiltro: String; pPagina: String): TZQuery;
    class function ConsultaLista(pFiltro: String): TListaEstoqueReajusteCabecalhoVO;
    class function ConsultaObjeto(pFiltro: String): TEstoqueReajusteCabecalhoVO;

    class procedure Insere(pObjeto: TEstoqueReajusteCabecalhoVO);
    class function Altera(pObjeto: TEstoqueReajusteCabecalhoVO): Boolean;

    class function Exclui(pId: Integer): Boolean;

  end;

implementation

uses UDataModule, T2TiORM, EstoqueReajusteDetalheVO, ProdutoVO;

var
  ObjetoLocal: TEstoqueReajusteCabecalhoVO;

class function TEstoqueReajusteCabecalhoController.Consulta(pFiltro: String; pPagina: String): TZQuery;
begin
  try
    ObjetoLocal := TEstoqueReajusteCabecalhoVO.Create;
    Result := TT2TiORM.Consultar(ObjetoLocal, pFiltro, pPagina);
  finally
    ObjetoLocal.Free;
  end;
end;

class function TEstoqueReajusteCabecalhoController.ConsultaLista(pFiltro: String): TListaEstoqueReajusteCabecalhoVO;
begin
  try
    ObjetoLocal := TEstoqueReajusteCabecalhoVO.Create;
    Result := TListaEstoqueReajusteCabecalhoVO(TT2TiORM.Consultar(ObjetoLocal, pFiltro, True));
  finally
    ObjetoLocal.Free;
  end;
end;

class function TEstoqueReajusteCabecalhoController.ConsultaObjeto(pFiltro: String): TEstoqueReajusteCabecalhoVO;
begin
  try
    Result := TEstoqueReajusteCabecalhoVO.Create;
    Result := TEstoqueReajusteCabecalhoVO(TT2TiORM.ConsultarUmObjeto(Result, pFiltro, True));

    Filtro := 'ID_ESTOQUE_REAJUSTE_CABECALHO = ' + IntToStr(Result.Id);

    // Objetos Vinculados

    // Listas
    Result.ListaEstoqueReajusteDetalheVO := TListaEstoqueReajusteDetalheVO(TT2TiORM.Consultar(TEstoqueReajusteDetalheVO.Create, Filtro, True));
  finally
  end;
end;

class procedure TEstoqueReajusteCabecalhoController.Insere(pObjeto: TEstoqueReajusteCabecalhoVO);
var
  UltimoID: Integer;
  Produto: TProdutoVO;
  I: Integer;
  Current: TEstoqueReajusteDetalheVO;
begin
  try
    UltimoID := TT2TiORM.Inserir(pObjeto);

    for I := 0 to pObjeto.ListaEstoqueReajusteDetalheVO.Count - 1 do
    begin
      Current := pObjeto.ListaEstoqueReajusteDetalheVO[I];

      Current.IdEstoqueReajusteCabecalho := UltimoID;
      TT2TiORM.Inserir(Current);

      // Atualiza Valor do Produto
      Produto := TProdutoVO.Create;
      Produto.Id := Current.IdProduto;
      Produto.ValorVenda := Current.ValorReajuste;
      TT2TiORM.Alterar(Produto);
    end;

    Consulta('ID = ' + IntToStr(UltimoID), '0');
  finally
  end;
end;

class function TEstoqueReajusteCabecalhoController.Altera(pObjeto: TEstoqueReajusteCabecalhoVO): Boolean;
var
  Produto: TProdutoVO;
  I: Integer;
  Current: TEstoqueReajusteDetalheVO;
begin
  try
    Result := TT2TiORM.Alterar(pObjeto);

    for I := 0 to pObjeto.ListaEstoqueReajusteDetalheVO.Count - 1 do
    begin
      Current := pObjeto.ListaEstoqueReajusteDetalheVO[I];

      if Current.Id > 0 then
        Result := TT2TiORM.Alterar(Current)
      else
      begin
        Current.IdEstoqueReajusteCabecalho := pObjeto.Id;
        Result := TT2TiORM.Inserir(Current) > 0;
      end;

      // Atualiza Valor do Produto
      Produto := TProdutoVO.Create;
      Produto.Id := Current.IdProduto;
      Produto.ValorVenda := Current.ValorReajuste;
      Result := TT2TiORM.Alterar(Produto);
    end;

  finally
  end;
end;

class function TEstoqueReajusteCabecalhoController.Exclui(pId: Integer): Boolean;
var
  ObjetoLocal: TEstoqueReajusteCabecalhoVO;
begin
  try
    ObjetoLocal := TEstoqueReajusteCabecalhoVO.Create;
    ObjetoLocal.Id := pId;
    Result := TT2TiORM.Excluir(ObjetoLocal);
  finally
    FreeAndNil(ObjetoLocal)
  end;
end;

initialization
  Classes.RegisterClass(TEstoqueReajusteCabecalhoController);

finalization
  Classes.UnRegisterClass(TEstoqueReajusteCabecalhoController);

end.

