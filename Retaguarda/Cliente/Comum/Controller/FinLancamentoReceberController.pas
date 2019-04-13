{*******************************************************************************
Title: T2Ti ERP                                                                 
Description: Controller do lado Cliente relacionado à tabela [FIN_LANCAMENTO_RECEBER] 
                                                                                
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
unit FinLancamentoReceberController;

{$MODE Delphi}

interface

uses
  Classes, Dialogs, SysUtils, DB, LCLIntf, LCLType, LMessages, Forms, Controller,
  VO, ZDataset, FinLancamentoReceberVO,
  FinParcelaReceberVO, FinLctoReceberNtFinanceiraVO;

type
  TFinLancamentoReceberController = class(TController)
  private
  public
    class function Consulta(pFiltro: String; pPagina: String): TZQuery;
    class function ConsultaLista(pFiltro: String): TListaFinLancamentoReceberVO;
    class function ConsultaObjeto(pFiltro: String): TFinLancamentoReceberVO;

    class procedure Insere(pObjeto: TFinLancamentoReceberVO);
    class function Altera(pObjeto: TFinLancamentoReceberVO): Boolean;

    class function Exclui(pId: Integer): Boolean;

  end;

implementation

uses UDataModule, T2TiORM;

var
  ObjetoLocal: TFinLancamentoReceberVO;

class function TFinLancamentoReceberController.Consulta(pFiltro: String; pPagina: String): TZQuery;
begin
  try
    ObjetoLocal := TFinLancamentoReceberVO.Create;
    Result := TT2TiORM.Consultar(ObjetoLocal, pFiltro, pPagina);
  finally
    ObjetoLocal.Free;
  end;
end;

class function TFinLancamentoReceberController.ConsultaLista(pFiltro: String): TListaFinLancamentoReceberVO;
begin
  try
    ObjetoLocal := TFinLancamentoReceberVO.Create;
    Result := TListaFinLancamentoReceberVO(TT2TiORM.Consultar(ObjetoLocal, pFiltro, True));
  finally
    ObjetoLocal.Free;
  end;
end;

class function TFinLancamentoReceberController.ConsultaObjeto(pFiltro: String): TFinLancamentoReceberVO;
begin
  try
    Result := TFinLancamentoReceberVO.Create;
    Result := TFinLancamentoReceberVO(TT2TiORM.ConsultarUmObjeto(Result, pFiltro, True));

    Filtro := 'ID_FIN_LANCAMENTO_RECEBER = ' + IntToStr(Result.Id);

    // Objetos Vinculados
    Result.ClienteNome := Result.ClienteVO.Nome;
    Result.DocumentoOrigemSigla := Result.DocumentoOrigemVO.SiglaDocumento;

    // Listas
    Result.ListaParcelaReceberVO := TListaFinParcelaReceberVO(TT2TiORM.Consultar(TFinParcelaReceberVO.Create, Filtro, True));
    Result.ListaLancReceberNatFinanceiraVO := TListaFinLctoReceberNtFinanceiraVO(TT2TiORM.Consultar(TFinLctoReceberNtFinanceiraVO.Create, Filtro, True));

  finally
  end;
end;

class procedure TFinLancamentoReceberController.Insere(pObjeto: TFinLancamentoReceberVO);
var
  UltimoID: Integer;
  ParcelaReceber: TFinParcelaReceberVO;
  LancamentoNaturezaFinanceira: TFinLctoReceberNtFinanceiraVO;
  i: Integer;
begin
  try
    UltimoID := TT2TiORM.Inserir(pObjeto);

    // Parcela Receber
    for I := 0 to pObjeto.ListaParcelaReceberVO.Count - 1 do
    begin
      ParcelaReceber := pObjeto.ListaParcelaReceberVO[I];
      ParcelaReceber.IdFinLancamentoReceber := UltimoID;
      TT2TiORM.Inserir(ParcelaReceber);
    end;

    // Natureza Financeira
    for I := 0 to pObjeto.ListaLancReceberNatFinanceiraVO.Count - 1 do
    begin
      LancamentoNaturezaFinanceira := pObjeto.ListaLancReceberNatFinanceiraVO[i];
      LancamentoNaturezaFinanceira.IdFinLancamentoReceber := UltimoID;
      TT2TiORM.Inserir(LancamentoNaturezaFinanceira);
    end;

    Consulta('ID = ' + IntToStr(UltimoID), '0');
  finally
  end;
end;

class function TFinLancamentoReceberController.Altera(pObjeto: TFinLancamentoReceberVO): Boolean;
var
  ParcelaReceber: TFinParcelaReceberVO;
  LancamentoNaturezaFinanceira: TFinLctoReceberNtFinanceiraVO;
  i: Integer;
begin
  try
    Result := TT2TiORM.Alterar(pObjeto);

    // Parcela Receber
    for I := 0 to pObjeto.ListaParcelaReceberVO.Count - 1 do
    begin
      ParcelaReceber := pObjeto.ListaParcelaReceberVO[I];
      if ParcelaReceber.Id > 0 then
        Result := TT2TiORM.Alterar(ParcelaReceber)
      else
      begin
        ParcelaReceber.IdFinLancamentoReceber := pObjeto.Id;
        Result := TT2TiORM.Inserir(ParcelaReceber) > 0;
      end;
    end;

    // Natureza Financeira
    for I := 0 to pObjeto.ListaLancReceberNatFinanceiraVO.Count - 1 do
    begin
      LancamentoNaturezaFinanceira := pObjeto.ListaLancReceberNatFinanceiraVO[i];
      if LancamentoNaturezaFinanceira.Id > 0 then
        Result := TT2TiORM.Alterar(LancamentoNaturezaFinanceira)
      else
      begin
        LancamentoNaturezaFinanceira.IdFinLancamentoReceber := pObjeto.Id;
        Result := TT2TiORM.Inserir(LancamentoNaturezaFinanceira) > 0;
      end;
    end;

  finally
  end;
end;

class function TFinLancamentoReceberController.Exclui(pId: Integer): Boolean;
var
  ObjetoLocal: TFinLancamentoReceberVO;
begin
  try
    ObjetoLocal := TFinLancamentoReceberVO.Create;
    ObjetoLocal.Id := pId;
    Result := TT2TiORM.Excluir(ObjetoLocal);
  finally
    FreeAndNil(ObjetoLocal)
  end;
end;

initialization
  Classes.RegisterClass(TFinLancamentoReceberController);

finalization
  Classes.UnRegisterClass(TFinLancamentoReceberController);

end.

