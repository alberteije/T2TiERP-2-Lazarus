{*******************************************************************************
Title: T2Ti ERP                                                                 
Description: Controller do lado Cliente relacionado à tabela [FIN_CHEQUE_RECEBIDO] 
                                                                                
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
unit FinChequeRecebidoController;

{$MODE Delphi}

interface

uses
  Classes, Dialogs, SysUtils, DB, LCLIntf, LCLType, LMessages, Forms, Controller,
  VO, ZDataset, FinChequeRecebidoVO;

type
  TFinChequeRecebidoController = class(TController)
  private
  public
    class function Consulta(pFiltro: String; pPagina: String): TZQuery;
    class function ConsultaLista(pFiltro: String): TListaFinChequeRecebidoVO;
    class function ConsultaObjeto(pFiltro: String): TFinChequeRecebidoVO;

    class procedure Insere(pObjeto: TFinChequeRecebidoVO);
    class function Altera(pObjeto: TFinChequeRecebidoVO): Boolean;

    class function Exclui(pId: Integer): Boolean;

  end;

implementation

uses UDataModule, T2TiORM;

var
  ObjetoLocal: TFinChequeRecebidoVO;

class function TFinChequeRecebidoController.Consulta(pFiltro: String; pPagina: String): TZQuery;
begin
  try
    ObjetoLocal := TFinChequeRecebidoVO.Create;
    Result := TT2TiORM.Consultar(ObjetoLocal, pFiltro, pPagina);
  finally
    ObjetoLocal.Free;
  end;
end;

class function TFinChequeRecebidoController.ConsultaLista(pFiltro: String): TListaFinChequeRecebidoVO;
begin
  try
    ObjetoLocal := TFinChequeRecebidoVO.Create;
    Result := TListaFinChequeRecebidoVO(TT2TiORM.Consultar(ObjetoLocal, pFiltro, True));
  finally
    ObjetoLocal.Free;
  end;
end;

class function TFinChequeRecebidoController.ConsultaObjeto(pFiltro: String): TFinChequeRecebidoVO;
begin
  try
    Result := TFinChequeRecebidoVO.Create;
    Result := TFinChequeRecebidoVO(TT2TiORM.ConsultarUmObjeto(Result, pFiltro, True));
    //Result.ContaCaixaNome := Result.ContaCaixaVO.Nome;
  finally
  end;
end;

class procedure TFinChequeRecebidoController.Insere(pObjeto: TFinChequeRecebidoVO);
var
  UltimoID: Integer;
begin
  try
    UltimoID := TT2TiORM.Inserir(pObjeto);
    Consulta('ID = ' + IntToStr(UltimoID), '0');
  finally
  end;
end;

class function TFinChequeRecebidoController.Altera(pObjeto: TFinChequeRecebidoVO): Boolean;
begin
  try
    Result := TT2TiORM.Alterar(pObjeto);
  finally
  end;
end;

class function TFinChequeRecebidoController.Exclui(pId: Integer): Boolean;
var
  ObjetoLocal: TFinChequeRecebidoVO;
begin
  try
    ObjetoLocal := TFinChequeRecebidoVO.Create;
    ObjetoLocal.Id := pId;
    Result := TT2TiORM.Excluir(ObjetoLocal);
  finally
    FreeAndNil(ObjetoLocal)
  end;
end;

initialization
  Classes.RegisterClass(TFinChequeRecebidoController);

finalization
  Classes.UnRegisterClass(TFinChequeRecebidoController);

end.

