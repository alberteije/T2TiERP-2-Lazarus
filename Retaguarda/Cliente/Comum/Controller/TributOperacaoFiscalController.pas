{*******************************************************************************
Title: T2Ti ERP                                                                 
Description: Controller do lado Cliente relacionado à tabela [TRIBUT_OPERACAO_FISCAL] 
                                                                                
The MIT License                                                                 
                                                                                
Copyright: Copyright (C) 2010 T2Ti.COM                                          
                                                                                
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
@version 1.0                                                                    
*******************************************************************************}
unit TributOperacaoFiscalController;

{$MODE Delphi}

interface

uses
  Classes, Dialogs, SysUtils, DB, LCLIntf, LCLType, LMessages, Forms, Controller,
  TributOperacaoFiscalVO, VO, ZDataset;


type
  TTributOperacaoFiscalController = class(TController)
  private
  public
    class function Consulta(pFiltro: String; pPagina: String): TZQuery;
    class function ConsultaLista(pFiltro: String): TListaTributOperacaoFiscalVO;
    class function ConsultaObjeto(pFiltro: String): TTributOperacaoFiscalVO;

    class procedure Insere(pObjeto: TTributOperacaoFiscalVO);
    class function Altera(pObjeto: TTributOperacaoFiscalVO): Boolean;

    class function Exclui(pId: Integer): Boolean;

  end;

implementation

uses UDataModule, T2TiORM, CfopVO;

var
  ObjetoLocal: TTributOperacaoFiscalVO;

class function TTributOperacaoFiscalController.Consulta(pFiltro: String; pPagina: String): TZQuery;
begin
  try
    ObjetoLocal := TTributOperacaoFiscalVO.Create;
    Result := TT2TiORM.Consultar(ObjetoLocal, pFiltro, pPagina);
  finally
    ObjetoLocal.Free;
  end;
end;

class function TTributOperacaoFiscalController.ConsultaLista(pFiltro: String): TListaTributOperacaoFiscalVO;
begin
  try
    ObjetoLocal := TTributOperacaoFiscalVO.Create;
    Result := TListaTributOperacaoFiscalVO(TT2TiORM.Consultar(ObjetoLocal, pFiltro, True));
  finally
    ObjetoLocal.Free;
  end;
end;

class function TTributOperacaoFiscalController.ConsultaObjeto(pFiltro: String): TTributOperacaoFiscalVO;
begin
  try
    Result := TTributOperacaoFiscalVO.Create;
    Result := TTributOperacaoFiscalVO(TT2TiORM.ConsultarUmObjeto(Result, pFiltro, True));

    /// EXERCICIO: crie o método para popular esses objetos automaticamente no T2TiORM
    if Assigned(Result) then
    begin
      Result.CfopVO := TCfopVO(TT2TiORM.ConsultarUmObjeto(Result.CfopVO, 'CFOP='+IntToStr(Result.Cfop), True));
      if Assigned(Result.CfopVO) then
        Result.CfopDescricao := Result.CfopVO.Descricao;
    end;
  finally
  end;
end;

class procedure TTributOperacaoFiscalController.Insere(pObjeto: TTributOperacaoFiscalVO);
var
  UltimoID: Integer;
begin
  try
    UltimoID := TT2TiORM.Inserir(pObjeto);
    Consulta('ID = ' + IntToStr(UltimoID), '0');
  finally
  end;
end;

class function TTributOperacaoFiscalController.Altera(pObjeto: TTributOperacaoFiscalVO): Boolean;
begin
  try
    Result := TT2TiORM.Alterar(pObjeto);
  finally
  end;
end;

class function TTributOperacaoFiscalController.Exclui(pId: Integer): Boolean;
var
  ObjetoLocal: TTributOperacaoFiscalVO;
begin
  try
    ObjetoLocal := TTributOperacaoFiscalVO.Create;
    ObjetoLocal.Id := pId;
    Result := TT2TiORM.Excluir(ObjetoLocal);
  finally
    FreeAndNil(ObjetoLocal)
  end;
end;

initialization
  Classes.RegisterClass(TTributOperacaoFiscalController);

finalization
  Classes.UnRegisterClass(TTributOperacaoFiscalController);

end.

