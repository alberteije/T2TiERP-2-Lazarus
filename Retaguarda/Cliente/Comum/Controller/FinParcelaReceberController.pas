{*******************************************************************************
Title: T2Ti ERP                                                                 
Description: Controller do lado Cliente relacionado à tabela [FIN_PARCELA_RECEBER] 
                                                                                
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
unit FinParcelaReceberController;

{$MODE Delphi}

interface

uses
  Classes, Dialogs, SysUtils, DB, LCLIntf, LCLType, LMessages, Forms, Controller,
  VO, ZDataset, FinParcelaReceberVO;

type
  TFinParcelaReceberController = class(TController)
  private
  public
    class function Consulta(pFiltro: String; pPagina: String): TZQuery;
    class function ConsultaLista(pFiltro: String): TListaFinParcelaReceberVO;
    class function ConsultaObjeto(pFiltro: String): TFinParcelaReceberVO;

    class procedure Insere(pObjeto: TFinParcelaReceberVO);
    class function Altera(pObjeto: TFinParcelaReceberVO): Boolean;
    class function BaixarParcelaCheque(pObjeto: TFinParcelaReceberVO): Boolean;

    class function Exclui(pId: Integer): Boolean;

  end;

implementation

uses UDataModule, T2TiORM;

var
  ObjetoLocal: TFinParcelaReceberVO;

class function TFinParcelaReceberController.Consulta(pFiltro: String; pPagina: String): TZQuery;
begin
  try
    ObjetoLocal := TFinParcelaReceberVO.Create;
    Result := TT2TiORM.Consultar(ObjetoLocal, pFiltro, pPagina);
  finally
    ObjetoLocal.Free;
  end;
end;

class function TFinParcelaReceberController.ConsultaLista(pFiltro: String): TListaFinParcelaReceberVO;
begin
  try
    ObjetoLocal := TFinParcelaReceberVO.Create;
    Result := TListaFinParcelaReceberVO(TT2TiORM.Consultar(ObjetoLocal, pFiltro, True));
  finally
    ObjetoLocal.Free;
  end;
end;

class function TFinParcelaReceberController.ConsultaObjeto(pFiltro: String): TFinParcelaReceberVO;
begin
  try
    Result := TFinParcelaReceberVO.Create;
    Result := TFinParcelaReceberVO(TT2TiORM.ConsultarUmObjeto(Result, pFiltro, True));
  finally
  end;
end;

class procedure TFinParcelaReceberController.Insere(pObjeto: TFinParcelaReceberVO);
var
  UltimoID: Integer;
begin
  try
    UltimoID := TT2TiORM.Inserir(pObjeto);
    Consulta('ID = ' + IntToStr(UltimoID), '0');
  finally
  end;
end;

class function TFinParcelaReceberController.Altera(pObjeto: TFinParcelaReceberVO): Boolean;
var
  UltimoID: Integer;
begin
  try
    //altera a parcela a Receber
    Result := TT2TiORM.Alterar(pObjeto);

    //se foi recebido com cheque, realiza as devidas persistências
    if pObjeto.FinChequeRecebidoVO.Numero > 0 then
    begin
      UltimoID := TT2TiORM.Inserir(pObjeto.FinChequeRecebidoVO);
      pObjeto.FinParcelaRecebimentoVO.IdFinChequeRecebido := UltimoID;
    end;

    //insere ou altera a parcela paga
    if pObjeto.FinParcelaRecebimentoVO.Id > 0 then
      Result := TT2TiORM.Alterar(pObjeto.FinParcelaRecebimentoVO)
    else
      Result := TT2TiORM.Inserir(pObjeto.FinParcelaRecebimentoVO) > 0;

  finally
  end;
end;

class function TFinParcelaReceberController.BaixarParcelaCheque(pObjeto: TFinParcelaReceberVO): Boolean;
var
  UltimoID: Integer;
  i: Integer;
begin
  try
    //altera a lista de parcelas a pagar
    {
    for i := 0 to pObjeto.ListaParcelaReceberVO.Count - 1 do
    begin
      Result := TT2TiORM.Alterar(pObjeto.ListaParcelaReceberVO[i]);
    end;
    }

    //realiza as devidas persistências e pega o id do cheque Recebido
    UltimoID := TT2TiORM.Inserir(pObjeto.FinChequeRecebidoVO);

    //insere ou altera a lista de parcelas recebidas
    for i := 0 to pObjeto.ListaParcelaRecebimentoVO.Count - 1 do
    begin
      pObjeto.ListaParcelaRecebimentoVO[i].IdFinChequeRecebido := UltimoID;
      if pObjeto.ListaParcelaRecebimentoVO[i].Id > 0 then
        Result := TT2TiORM.Alterar(pObjeto.ListaParcelaRecebimentoVO[i])
      else
        Result := TT2TiORM.Inserir(pObjeto.ListaParcelaRecebimentoVO[i]) > 0;
    end;
  finally
  end;
end;

class function TFinParcelaReceberController.Exclui(pId: Integer): Boolean;
var
  ObjetoLocal: TFinParcelaReceberVO;
begin
  try
    ObjetoLocal := TFinParcelaReceberVO.Create;
    ObjetoLocal.Id := pId;
    Result := TT2TiORM.Excluir(ObjetoLocal);
  finally
    FreeAndNil(ObjetoLocal)
  end;
end;

initialization
  Classes.RegisterClass(TFinParcelaReceberController);

finalization
  Classes.UnRegisterClass(TFinParcelaReceberController);

end.

