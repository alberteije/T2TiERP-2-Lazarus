{*******************************************************************************
Title: T2Ti ERP                                                                 
Description: Controller do lado Cliente relacionado à tabela [INVENTARIO_CONTAGEM_CAB] 
                                                                                
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
unit InventarioContagemCabController;

interface

uses
  Classes, Dialogs, SysUtils, DB, LCLIntf, LCLType, LMessages, Forms, Controller,
  VO, ZDataset, InventarioContagemCabVO, InventarioContagemDetVO,
  ProdutoVO;

type
  TInventarioContagemCabController = class(TController)
  private
  public
    class function Consulta(pFiltro: String; pPagina: String): TZQuery;
    class function ConsultaLista(pFiltro: String): TListaInventarioContagemCabVO;
    class function ConsultaObjeto(pFiltro: String): TInventarioContagemCabVO;

    class procedure Insere(pObjeto: TInventarioContagemCabVO);
    class function Altera(pObjeto: TInventarioContagemCabVO): Boolean;

    class function Exclui(pId: Integer): Boolean;

  end;

implementation

uses UDataModule, T2TiORM;

var
  ObjetoLocal: TInventarioContagemCabVO;

class function TInventarioContagemCabController.Consulta(pFiltro: String; pPagina: String): TZQuery;
begin
  try
    ObjetoLocal := TInventarioContagemCabVO.Create;
    Result := TT2TiORM.Consultar(ObjetoLocal, pFiltro, pPagina);
  finally
    ObjetoLocal.Free;
  end;
end;

class function TInventarioContagemCabController.ConsultaLista(pFiltro: String): TListaInventarioContagemCabVO;
begin
  try
    ObjetoLocal := TInventarioContagemCabVO.Create;
    Result := TListaInventarioContagemCabVO(TT2TiORM.Consultar(ObjetoLocal, pFiltro, True));
  finally
    ObjetoLocal.Free;
  end;
end;

class function TInventarioContagemCabController.ConsultaObjeto(pFiltro: String): TInventarioContagemCabVO;
begin
  try
    Result := TInventarioContagemCabVO.Create;
    Result := TInventarioContagemCabVO(TT2TiORM.ConsultarUmObjeto(Result, pFiltro, True));

    Filtro := 'ID_INVENTARIO_CONTAGEM_CAB = ' + IntToStr(Result.Id);

    // Objetos Vinculados

    // Listas
    Result.ListaInventarioContagemDetVO := TListaInventarioContagemDetVO(TT2TiORM.Consultar(TInventarioContagemDetVO.Create, Filtro, True));

  finally
  end;
end;

class procedure TInventarioContagemCabController.Insere(pObjeto: TInventarioContagemCabVO);
var
  UltimoID: Integer;
  Current: TInventarioContagemDetVO;
  i:integer;
begin
  try
    UltimoID := TT2TiORM.Inserir(pObjeto);

    // Detalhes
    for I := 0 to pObjeto.ListaInventarioContagemDetVO.Count - 1 do
    begin
      Current := pObjeto.ListaInventarioContagemDetVO[I];
      Current.IdInventarioContagemCab := UltimoID;
      TT2TiORM.Inserir(Current);
    end;

    Consulta('ID = ' + IntToStr(UltimoID), '0');
  finally
  end;
end;

class function TInventarioContagemCabController.Altera(pObjeto: TInventarioContagemCabVO): Boolean;
var
  Produto: TProdutoVO;
  Current: TInventarioContagemDetVO;
  i:integer;
begin
  try
    Result := TT2TiORM.Alterar(pObjeto);

    // Detalhes
    for I := 0 to pObjeto.ListaInventarioContagemDetVO.Count - 1 do
    begin
      Current := pObjeto.ListaInventarioContagemDetVO[I];

      if Current.Id > 0 then
        Result := TT2TiORM.Alterar(Current)
      else
      begin
        Current.IdInventarioContagemCab := pObjeto.Id;
        Result := TT2TiORM.Inserir(Current) > 0;
      end;

      // Atualiza Estoque
      if pObjeto.EstoqueAtualizado = 'S' then
      begin
        Produto := TProdutoVO.Create;
        Produto.Id := Current.IdProduto;

        /// EXERCICIO
        ///  Atualize de acordo com o campo selecionado em (FECHADO_CONTAGEM)
        Produto.QuantidadeEstoque := Current.Contagem01;
        Result := TT2TiORM.Alterar(Produto);
      end;
    end;
  finally
  end;
end;

class function TInventarioContagemCabController.Exclui(pId: Integer): Boolean;
var
  ObjetoLocal: TInventarioContagemCabVO;
begin
  try
    ObjetoLocal := TInventarioContagemCabVO.Create;
    ObjetoLocal.Id := pId;
    Result := TT2TiORM.Excluir(ObjetoLocal);
  finally
    FreeAndNil(ObjetoLocal)
  end;
end;


initialization
  Classes.RegisterClass(TInventarioContagemCabController);

finalization
  Classes.UnRegisterClass(TInventarioContagemCabController);

end.

