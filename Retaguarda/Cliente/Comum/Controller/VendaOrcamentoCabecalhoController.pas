{*******************************************************************************
Title: T2Ti ERP                                                                 
Description: Controller do lado Cliente relacionado à tabela [VENDA_ORCAMENTO_CABECALHO] 
                                                                                
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
unit VendaOrcamentoCabecalhoController;

{$MODE Delphi}

interface

uses
  Classes, Dialogs, SysUtils, DB, LCLIntf, LCLType, LMessages, Forms, Controller,
  VO, ZDataset, VendaOrcamentoCabecalhoVO;

type
  TVendaOrcamentoCabecalhoController = class(TController)
  private
  public
    class function Consulta(pFiltro: String; pPagina: String): TZQuery;
    class function ConsultaLista(pFiltro: String): TListaVendaOrcamentoCabecalhoVO;
    class function ConsultaObjeto(pFiltro: String): TVendaOrcamentoCabecalhoVO;

    class procedure Insere(pObjeto: TVendaOrcamentoCabecalhoVO);
    class function Altera(pObjeto: TVendaOrcamentoCabecalhoVO): Boolean;

    class function Exclui(pId: Integer): Boolean;

  end;

implementation

uses UDataModule, T2TiORM, VendaOrcamentoDetalheVO;

var
  ObjetoLocal: TVendaOrcamentoCabecalhoVO;

class function TVendaOrcamentoCabecalhoController.Consulta(pFiltro: String; pPagina: String): TZQuery;
begin
  try
    ObjetoLocal := TVendaOrcamentoCabecalhoVO.Create;
    Result := TT2TiORM.Consultar(ObjetoLocal, pFiltro, pPagina);
  finally
    ObjetoLocal.Free;
  end;
end;

class function TVendaOrcamentoCabecalhoController.ConsultaLista(pFiltro: String): TListaVendaOrcamentoCabecalhoVO;
begin
  try
    ObjetoLocal := TVendaOrcamentoCabecalhoVO.Create;
    Result := TListaVendaOrcamentoCabecalhoVO(TT2TiORM.Consultar(ObjetoLocal, pFiltro, True));
  finally
    ObjetoLocal.Free;
  end;
end;

class function TVendaOrcamentoCabecalhoController.ConsultaObjeto(pFiltro: String): TVendaOrcamentoCabecalhoVO;
begin
  try
    Result := TVendaOrcamentoCabecalhoVO.Create;
    Result := TVendaOrcamentoCabecalhoVO(TT2TiORM.ConsultarUmObjeto(Result, pFiltro, True));

    Filtro := 'ID_VENDA_ORCAMENTO_CABECALHO = ' + IntToStr(Result.Id);

    // Objetos Vinculados

    // Listas
    Result.ListaVendaOrcamentoDetalheVO := TListaVendaOrcamentoDetalheVO(TT2TiORM.Consultar(TVendaOrcamentoDetalheVO.Create, Filtro, True));
  finally
  end;
end;

class procedure TVendaOrcamentoCabecalhoController.Insere(pObjeto: TVendaOrcamentoCabecalhoVO);
var
  UltimoID: Integer;
  Current: TVendaOrcamentoDetalheVO;
  I: Integer;
begin
  try
    UltimoID := TT2TiORM.Inserir(pObjeto);

    // Lista Orçamento Pedido Detalhe
    for I := 0 to pObjeto.ListaVendaOrcamentoDetalheVO.Count - 1 do
    begin
      Current := pObjeto.ListaVendaOrcamentoDetalheVO[I];

      Current.IdVendaOrcamentoCabecalho := UltimoID;
      TT2TiORM.Inserir(Current);
    end;

    Consulta('ID = ' + IntToStr(UltimoID), '0');
  finally
  end;
end;

class function TVendaOrcamentoCabecalhoController.Altera(pObjeto: TVendaOrcamentoCabecalhoVO): Boolean;
var
  Current: TVendaOrcamentoDetalheVO;
  I: Integer;
begin
  try
    Result := TT2TiORM.Alterar(pObjeto);

    // Lista Orçamento Pedido Detalhe
    for I := 0 to pObjeto.ListaVendaOrcamentoDetalheVO.Count - 1 do
    begin
      Current := pObjeto.ListaVendaOrcamentoDetalheVO[I];

      if Current.Id > 0 then
        Result := TT2TiORM.Alterar(Current)
      else
      begin
        Current.IdVendaOrcamentoCabecalho := pObjeto.Id;
        Result := TT2TiORM.Inserir(Current) > 0;
      end;
    end;

  finally
  end;
end;

class function TVendaOrcamentoCabecalhoController.Exclui(pId: Integer): Boolean;
var
  ObjetoLocal: TVendaOrcamentoCabecalhoVO;
begin
  try
    ObjetoLocal := TVendaOrcamentoCabecalhoVO.Create;
    ObjetoLocal.Id := pId;
    Result := TT2TiORM.Excluir(ObjetoLocal);
  finally
    FreeAndNil(ObjetoLocal)
  end;
end;

initialization
  Classes.RegisterClass(TVendaOrcamentoCabecalhoController);

finalization
  Classes.UnRegisterClass(TVendaOrcamentoCabecalhoController);

end.

