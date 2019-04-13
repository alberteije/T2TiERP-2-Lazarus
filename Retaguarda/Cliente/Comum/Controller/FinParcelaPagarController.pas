{*******************************************************************************
Title: T2Ti ERP                                                                 
Description: Controller do lado Cliente relacionado à tabela [FIN_PARCELA_PAGAR] 
                                                                                
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
unit FinParcelaPagarController;

{$MODE Delphi}

interface

uses
  Classes, Dialogs, SysUtils, DB, LCLIntf, LCLType, LMessages, Forms, Controller,
  VO, ZDataset, FinParcelaPagarVO, ChequeVO;

type
  TFinParcelaPagarController = class(TController)
  private
  public
    class function Consulta(pFiltro: String; pPagina: String): TZQuery;
    class function ConsultaLista(pFiltro: String): TListaFinParcelaPagarVO;
    class function ConsultaObjeto(pFiltro: String): TFinParcelaPagarVO;

    class procedure Insere(pObjeto: TFinParcelaPagarVO);
    class function Altera(pObjeto: TFinParcelaPagarVO): Boolean;
    class function BaixarParcelaCheque(pObjeto: TFinParcelaPagarVO): Boolean;

    class function Exclui(pId: Integer): Boolean;

  end;

implementation

uses UDataModule, T2TiORM;

var
  ObjetoLocal: TFinParcelaPagarVO;

class function TFinParcelaPagarController.Consulta(pFiltro: String; pPagina: String): TZQuery;
begin
  try
    ObjetoLocal := TFinParcelaPagarVO.Create;
    Result := TT2TiORM.Consultar(ObjetoLocal, pFiltro, pPagina);
  finally
    ObjetoLocal.Free;
  end;
end;

class function TFinParcelaPagarController.ConsultaLista(pFiltro: String): TListaFinParcelaPagarVO;
begin
  try
    ObjetoLocal := TFinParcelaPagarVO.Create;
    Result := TListaFinParcelaPagarVO(TT2TiORM.Consultar(ObjetoLocal, pFiltro, True));
  finally
    ObjetoLocal.Free;
  end;
end;

class function TFinParcelaPagarController.ConsultaObjeto(pFiltro: String): TFinParcelaPagarVO;
begin
  try
    Result := TFinParcelaPagarVO.Create;
    Result := TFinParcelaPagarVO(TT2TiORM.ConsultarUmObjeto(Result, pFiltro, True));
  finally
  end;
end;

class procedure TFinParcelaPagarController.Insere(pObjeto: TFinParcelaPagarVO);
var
  UltimoID: Integer;
begin
  try
    UltimoID := TT2TiORM.Inserir(pObjeto);
    Consulta('ID = ' + IntToStr(UltimoID), '0');
  finally
  end;
end;

class function TFinParcelaPagarController.Altera(pObjeto: TFinParcelaPagarVO): Boolean;
var
  UltimoID: Integer;
  objCheque: TChequeVO;
begin
  try
    //altera a parcela a pagar
    Result := TT2TiORM.Alterar(pObjeto);

    //se foi pago com cheque, realiza as devidas persistências e pega o id do cheque emitido
    if pObjeto.FinChequeEmitidoVO.IdCheque > 0 then
    begin
      UltimoID := TT2TiORM.Inserir(pObjeto.FinChequeEmitidoVO);

      pObjeto.FinParcelaPagamentoVO.IdFinChequeEmitido := UltimoID;

      objCheque := TChequeVO.Create;
      objCheque.Id := pObjeto.FinChequeEmitidoVO.IdCheque;
      objCheque.DataStatus := now;
      objCheque.StatusCheque := 'U';
      Result := TT2TiORM.Alterar(objCheque);
    end;

    //insere ou altera a parcela paga
    if pObjeto.FinParcelaPagamentoVO.Id > 0 then
      Result := TT2TiORM.Alterar(pObjeto.FinParcelaPagamentoVO)
    else
      Result := TT2TiORM.Inserir(pObjeto.FinParcelaPagamentoVO) > 0;

  finally
  end;
end;

class function TFinParcelaPagarController.BaixarParcelaCheque(pObjeto: TFinParcelaPagarVO): Boolean;
var
  UltimoID: Integer;
  objCheque: TChequeVO;
  i: Integer;
begin
  try
    //altera a lista de parcelas a pagar
    {
    for i := 0 to pObjeto.ListaParcelaPagarVO.Count - 1 do
    begin
      Result := TT2TiORM.Alterar(pObjeto.ListaParcelaPagarVO[i]);
    end;
    }

    //realiza as devidas persistências e pega o id do cheque emitido
    UltimoID := TT2TiORM.Inserir(pObjeto.FinChequeEmitidoVO);

    //insere ou altera a lista de parcelas pagas
    for i := 0 to pObjeto.ListaParcelaPagamentoVO.Count - 1 do
    begin
      pObjeto.ListaParcelaPagamentoVO[i].IdFinChequeEmitido := UltimoID;
      if pObjeto.ListaParcelaPagamentoVO[i].Id > 0 then
        Result := TT2TiORM.Alterar(pObjeto.ListaParcelaPagamentoVO[i])
      else
        Result := TT2TiORM.Inserir(pObjeto.ListaParcelaPagamentoVO[i]) > 0;
    end;

    objCheque := TChequeVO.Create;
    objCheque.Id := pObjeto.FinChequeEmitidoVO.IdCheque;
    objCheque.DataStatus := now;
    objCheque.StatusCheque := 'U';
    Result := TT2TiORM.Alterar(objCheque);
  finally
  end;
end;

class function TFinParcelaPagarController.Exclui(pId: Integer): Boolean;
var
  ObjetoLocal: TFinParcelaPagarVO;
begin
  try
    ObjetoLocal := TFinParcelaPagarVO.Create;
    ObjetoLocal.Id := pId;
    Result := TT2TiORM.Excluir(ObjetoLocal);
  finally
    FreeAndNil(ObjetoLocal)
  end;
end;

initialization
  Classes.RegisterClass(TFinParcelaPagarController);

finalization
  Classes.UnRegisterClass(TFinParcelaPagarController);

end.

