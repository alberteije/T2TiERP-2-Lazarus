{*******************************************************************************
Title: T2Ti ERP                                                                 
Description: Controller do lado Cliente relacionado à tabela [FIN_LANCAMENTO_PAGAR] 
                                                                                
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
unit FinLancamentoPagarController;

{$MODE Delphi}

interface

uses
  Classes, Dialogs, SysUtils, DB, LCLIntf, LCLType, LMessages, Forms, Controller,
  VO, ZDataset, FinLancamentoPagarVO, FinParcelaPagarVO,
  FinLctoPagarNtFinanceiraVO;

type
  TFinLancamentoPagarController = class(TController)
  private
  public
    class function Consulta(pFiltro: String; pPagina: String): TZQuery;
    class function ConsultaLista(pFiltro: String): TListaFinLancamentoPagarVO;
    class function ConsultaObjeto(pFiltro: String): TFinLancamentoPagarVO;

    class procedure Insere(pObjeto: TFinLancamentoPagarVO);
    class function Altera(pObjeto: TFinLancamentoPagarVO): Boolean;

    class function Exclui(pId: Integer): Boolean;

  end;

implementation

uses UDataModule, T2TiORM;

var
  ObjetoLocal: TFinLancamentoPagarVO;

class function TFinLancamentoPagarController.Consulta(pFiltro: String; pPagina: String): TZQuery;
begin
  try
    ObjetoLocal := TFinLancamentoPagarVO.Create;
    Result := TT2TiORM.Consultar(ObjetoLocal, pFiltro, pPagina);
  finally
    ObjetoLocal.Free;
  end;
end;

class function TFinLancamentoPagarController.ConsultaLista(pFiltro: String): TListaFinLancamentoPagarVO;
begin
  try
    ObjetoLocal := TFinLancamentoPagarVO.Create;
    Result := TListaFinLancamentoPagarVO(TT2TiORM.Consultar(ObjetoLocal, pFiltro, True));
  finally
    ObjetoLocal.Free;
  end;
end;

class function TFinLancamentoPagarController.ConsultaObjeto(pFiltro: String): TFinLancamentoPagarVO;
begin
  try
    Result := TFinLancamentoPagarVO.Create;
    Result := TFinLancamentoPagarVO(TT2TiORM.ConsultarUmObjeto(Result, pFiltro, True));

    Filtro := 'ID_FIN_LANCAMENTO_PAGAR = ' + IntToStr(Result.Id);

    // Objetos Vinculados
    Result.FornecedorNome := Result.FornecedorVO.Nome;
    Result.DocumentoOrigemSigla := Result.DocumentoOrigemVO.SiglaDocumento;

    // Listas
    Result.ListaParcelaPagarVO := TListaFinParcelaPagarVO(TT2TiORM.Consultar(TFinParcelaPagarVO.Create, Filtro, True));
    Result.ListaLancPagarNatFinanceiraVO := TListaFinLctoPagarNtFinanceiraVO(TT2TiORM.Consultar(TFinLctoPagarNtFinanceiraVO.Create, Filtro, True));

  finally
  end;
end;

class procedure TFinLancamentoPagarController.Insere(pObjeto: TFinLancamentoPagarVO);
var
  UltimoID:Integer;
  ParcelaPagar: TFinParcelaPagarVO;
  LancamentoNaturezaFinanceira: TFinLctoPagarNtFinanceiraVO;
  i: Integer;
begin
  try
    UltimoID := TT2TiORM.Inserir(pObjeto);

    // Parcela Pagar
    for I := 0 to pObjeto.ListaParcelaPagarVO.Count - 1 do
    begin
      ParcelaPagar := pObjeto.ListaParcelaPagarVO[I];
      ParcelaPagar.IdFinLancamentoPagar := UltimoID;
      TT2TiORM.Inserir(ParcelaPagar);
    end;


    // Natureza Financeira
    for I := 0 to pObjeto.ListaLancPagarNatFinanceiraVO.Count - 1 do
    begin
      LancamentoNaturezaFinanceira := pObjeto.ListaLancPagarNatFinanceiraVO[i];
      LancamentoNaturezaFinanceira.IdFinLancamentoPagar := UltimoID;
      TT2TiORM.Inserir(LancamentoNaturezaFinanceira);
    end;


    Consulta('ID = ' + IntToStr(UltimoID), '0');
  finally
  end;
end;

class function TFinLancamentoPagarController.Altera(pObjeto: TFinLancamentoPagarVO): Boolean;
var
  ParcelaPagar: TFinParcelaPagarVO;
  LancamentoNaturezaFinanceira: TFinLctoPagarNtFinanceiraVO;
  i: Integer;
begin
  try
    Result := TT2TiORM.Alterar(pObjeto);

    // Parcela Pagar
    for I := 0 to pObjeto.ListaParcelaPagarVO.Count - 1 do
    begin
      ParcelaPagar := pObjeto.ListaParcelaPagarVO[I];
      if ParcelaPagar.Id > 0 then
        Result := TT2TiORM.Alterar(ParcelaPagar)
      else
      begin
        ParcelaPagar.IdFinLancamentoPagar := pObjeto.Id;
        Result := TT2TiORM.Inserir(ParcelaPagar) > 0;
      end;
    end;

    // Natureza Financeira
    for I := 0 to pObjeto.ListaLancPagarNatFinanceiraVO.Count - 1 do
    begin
      LancamentoNaturezaFinanceira := pObjeto.ListaLancPagarNatFinanceiraVO[i];
      if LancamentoNaturezaFinanceira.Id > 0 then
        Result := TT2TiORM.Alterar(LancamentoNaturezaFinanceira)
      else
      begin
        LancamentoNaturezaFinanceira.IdFinLancamentoPagar := pObjeto.Id;
        Result := TT2TiORM.Inserir(LancamentoNaturezaFinanceira) > 0;
      end;
    end;

  finally
  end;
end;

class function TFinLancamentoPagarController.Exclui(pId: Integer): Boolean;
var
  ObjetoLocal: TFinLancamentoPagarVO;
begin
  try
    ObjetoLocal := TFinLancamentoPagarVO.Create;
    ObjetoLocal.Id := pId;
    Result := TT2TiORM.Excluir(ObjetoLocal);
  finally
    FreeAndNil(ObjetoLocal)
  end;
end;

initialization
  Classes.RegisterClass(TFinLancamentoPagarController);

finalization
  Classes.UnRegisterClass(TFinLancamentoPagarController);

end.

