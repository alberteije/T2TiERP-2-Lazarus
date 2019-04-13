{*******************************************************************************
Title: T2Ti ERP                                                                 
Description: Controller do lado Cliente relacionado à tabela [CONTABIL_LANCAMENTO_CABECALHO] 
                                                                                
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
unit ContabilLancamentoCabecalhoController;

{$MODE Delphi}

interface

uses
  Classes, Dialogs, SysUtils, DB, LCLIntf, LCLType, LMessages, Forms, Controller,
  VO, ZDataset, ContabilLancamentoCabecalhoVO,
  ContabilLancamentoDetalheVO;

type
  TContabilLancamentoCabecalhoController = class(TController)
  private
  public
    class function Consulta(pFiltro: String; pPagina: String): TZQuery;
    class function ConsultaLista(pFiltro: String): TListaContabilLancamentoCabecalhoVO;
    class function ConsultaObjeto(pFiltro: String): TContabilLancamentoCabecalhoVO;

    class procedure Insere(pObjeto: TContabilLancamentoCabecalhoVO);
    class function Altera(pObjeto: TContabilLancamentoCabecalhoVO): Boolean;

    class function Exclui(pId: Integer): Boolean;

  end;

implementation

uses UDataModule, T2TiORM;

var
  ObjetoLocal: TContabilLancamentoCabecalhoVO;

class function TContabilLancamentoCabecalhoController.Consulta(pFiltro: String; pPagina: String): TZQuery;
begin
  try
    ObjetoLocal := TContabilLancamentoCabecalhoVO.Create;
    Result := TT2TiORM.Consultar(ObjetoLocal, pFiltro, pPagina);
  finally
    ObjetoLocal.Free;
  end;
end;

class function TContabilLancamentoCabecalhoController.ConsultaLista(pFiltro: String): TListaContabilLancamentoCabecalhoVO;
begin
  try
    ObjetoLocal := TContabilLancamentoCabecalhoVO.Create;
    Result := TListaContabilLancamentoCabecalhoVO(TT2TiORM.Consultar(ObjetoLocal, pFiltro, True));
  finally
    ObjetoLocal.Free;
  end;
end;

class function TContabilLancamentoCabecalhoController.ConsultaObjeto(pFiltro: String): TContabilLancamentoCabecalhoVO;
begin
  try
    Result := TContabilLancamentoCabecalhoVO.Create;
    Result := TContabilLancamentoCabecalhoVO(TT2TiORM.ConsultarUmObjeto(Result, pFiltro, True));

    Filtro := 'ID_CONTABIL_LANCAMENTO_CAB = ' + IntToStr(Result.Id);

    // Objetos Vinculados

    // Listas
    Result.ListaContabilLancamentoDetalheVO := TListaContabilLancamentoDetalheVO(TT2TiORM.Consultar(TContabilLancamentoDetalheVO.Create, Filtro, True));
  finally
  end;
end;

class procedure TContabilLancamentoCabecalhoController.Insere(pObjeto: TContabilLancamentoCabecalhoVO);
var
  UltimoID: Integer;
  I: Integer;
  Current: TContabilLancamentoDetalheVO;
begin
  try
    UltimoID := TT2TiORM.Inserir(pObjeto);

    // Detalhes
    for I := 0 to pObjeto.ListaContabilLancamentoDetalheVO.Count - 1 do
    begin
      Current := pObjeto.ListaContabilLancamentoDetalheVO[I];

      Current.IdContabilLancamentoCab := UltimoID;
      TT2TiORM.Inserir(Current);
    end;

    Consulta('ID = ' + IntToStr(UltimoID), '0');
  finally
  end;
end;

class function TContabilLancamentoCabecalhoController.Altera(pObjeto: TContabilLancamentoCabecalhoVO): Boolean;
var
  I: Integer;
  Current: TContabilLancamentoDetalheVO;
begin
  try
    Result := TT2TiORM.Alterar(pObjeto);

    // Detalhes
    for I := 0 to pObjeto.ListaContabilLancamentoDetalheVO.Count - 1 do
    begin
    Current := pObjeto.ListaContabilLancamentoDetalheVO[I];
    if Current.Id > 0 then
      Result := TT2TiORM.Alterar(Current)
    else
    begin
      Current.IdContabilLancamentoCab := pObjeto.Id;
      Result := TT2TiORM.Inserir(Current) > 0;
    end;
    end;
  finally
  end;
end;

class function TContabilLancamentoCabecalhoController.Exclui(pId: Integer): Boolean;
var
  ObjetoLocal: TContabilLancamentoCabecalhoVO;
begin
  try
    ObjetoLocal := TContabilLancamentoCabecalhoVO.Create;
    ObjetoLocal.Id := pId;
    Result := TT2TiORM.Excluir(ObjetoLocal);
  finally
    FreeAndNil(ObjetoLocal)
  end;
end;

initialization
  Classes.RegisterClass(TContabilLancamentoCabecalhoController);

finalization
  Classes.UnRegisterClass(TContabilLancamentoCabecalhoController);

end.

