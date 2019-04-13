{*******************************************************************************
Title: T2Ti ERP                                                                 
Description: Controller do lado Cliente relacionado à tabela [VENDA_CONDICOES_PAGAMENTO] 
                                                                                
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
unit VendaCondicoesPagamentoController;

{$MODE Delphi}

interface

uses
  Classes, Dialogs, SysUtils, DB, LCLIntf, LCLType, LMessages, Forms, Controller,
  VO, ZDataset, VendaCondicoesPagamentoVO;

type
  TVendaCondicoesPagamentoController = class(TController)
  private
  public
    class function Consulta(pFiltro: String; pPagina: String): TZQuery;
    class function ConsultaLista(pFiltro: String): TListaVendaCondicoesPagamentoVO;
    class function ConsultaObjeto(pFiltro: String): TVendaCondicoesPagamentoVO;

    class procedure Insere(pObjeto: TVendaCondicoesPagamentoVO);
    class function Altera(pObjeto: TVendaCondicoesPagamentoVO): Boolean;

    class function Exclui(pId: Integer): Boolean;

  end;

implementation

uses UDataModule, T2TiORM, VendaCondicoesParcelasVO;

var
  ObjetoLocal: TVendaCondicoesPagamentoVO;

class function TVendaCondicoesPagamentoController.Consulta(pFiltro: String; pPagina: String): TZQuery;
begin
  try
    ObjetoLocal := TVendaCondicoesPagamentoVO.Create;
    Result := TT2TiORM.Consultar(ObjetoLocal, pFiltro, pPagina);
  finally
    ObjetoLocal.Free;
  end;
end;

class function TVendaCondicoesPagamentoController.ConsultaLista(pFiltro: String): TListaVendaCondicoesPagamentoVO;
begin
  try
    ObjetoLocal := TVendaCondicoesPagamentoVO.Create;
    Result := TListaVendaCondicoesPagamentoVO(TT2TiORM.Consultar(ObjetoLocal, pFiltro, True));
  finally
    ObjetoLocal.Free;
  end;
end;

class function TVendaCondicoesPagamentoController.ConsultaObjeto(pFiltro: String): TVendaCondicoesPagamentoVO;
begin
  try
    Result := TVendaCondicoesPagamentoVO.Create;
    Result := TVendaCondicoesPagamentoVO(TT2TiORM.ConsultarUmObjeto(Result, pFiltro, True));


    Filtro := 'ID_VENDA_CONDICOES_PAGAMENTO = ' + IntToStr(Result.Id);

    // Objetos Vinculados

    // Listas
    Result.ListaVendaCondicoesParcelasVO := TListaVendaCondicoesParcelasVO(TT2TiORM.Consultar(TVendaCondicoesParcelasVO.Create, Filtro, True));
finally
  end;
end;

class procedure TVendaCondicoesPagamentoController.Insere(pObjeto: TVendaCondicoesPagamentoVO);
var
  UltimoID: Integer;
  Current: TVendaCondicoesParcelasVO;
  I: Integer;
begin
  try
    UltimoID := TT2TiORM.Inserir(pObjeto);

    // Condições Parcela
    for I := 0 to pObjeto.ListaVendaCondicoesParcelasVO.Count - 1 do
    begin
      Current := pObjeto.ListaVendaCondicoesParcelasVO[I];

      Current.IdVendaCondicoesPagamento := UltimoID;
      TT2TiORM.Inserir(Current);
    end;

    Consulta('ID = ' + IntToStr(UltimoID), '0');
  finally
  end;
end;

class function TVendaCondicoesPagamentoController.Altera(pObjeto: TVendaCondicoesPagamentoVO): Boolean;
var
  UltimoID: Integer;
  Current: TVendaCondicoesParcelasVO;
  I: Integer;
begin
  try
    Result := TT2TiORM.Alterar(pObjeto);

    // Condicoes Parcela
    for I := 0 to pObjeto.ListaVendaCondicoesParcelasVO.Count - 1 do
    begin
      Current := pObjeto.ListaVendaCondicoesParcelasVO[I];
      if Current.Id > 0 then
        Result := TT2TiORM.Alterar(Current)
      else
      begin
        Current.IdVendaCondicoesPagamento := pObjeto.Id;
        Result := TT2TiORM.Inserir(Current) > 0;
      end;
    end;

  finally
  end;
end;

class function TVendaCondicoesPagamentoController.Exclui(pId: Integer): Boolean;
var
  ObjetoLocal: TVendaCondicoesPagamentoVO;
begin
  try
    ObjetoLocal := TVendaCondicoesPagamentoVO.Create;
    ObjetoLocal.Id := pId;
    Result := TT2TiORM.Excluir(ObjetoLocal);
  finally
    FreeAndNil(ObjetoLocal)
  end;
end;

initialization
  Classes.RegisterClass(TVendaCondicoesPagamentoController);

finalization
  Classes.UnRegisterClass(TVendaCondicoesPagamentoController);

end.

