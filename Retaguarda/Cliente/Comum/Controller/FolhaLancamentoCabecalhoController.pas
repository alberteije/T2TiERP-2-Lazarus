{*******************************************************************************
Title: T2Ti ERP                                                                 
Description: Controller do lado Cliente relacionado à tabela [FOLHA_LANCAMENTO_CABECALHO] 
                                                                                
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
unit FolhaLancamentoCabecalhoController;

{$MODE Delphi}

interface

uses
  Classes, Dialogs, SysUtils, DB, LCLIntf, LCLType, LMessages, Forms, Controller,
  VO, ZDataset, FolhaLancamentoCabecalhoVO, FolhaLancamentoDetalheVO;

type
  TFolhaLancamentoCabecalhoController = class(TController)
  private
  public
    class function Consulta(pFiltro: String; pPagina: String): TZQuery;
    class function ConsultaLista(pFiltro: String): TListaFolhaLancamentoCabecalhoVO;
    class function ConsultaObjeto(pFiltro: String): TFolhaLancamentoCabecalhoVO;

    class procedure Insere(pObjeto: TFolhaLancamentoCabecalhoVO);
    class function Altera(pObjeto: TFolhaLancamentoCabecalhoVO): Boolean;

    class function Exclui(pId: Integer): Boolean;

  end;

implementation

uses UDataModule, T2TiORM;

var
  ObjetoLocal: TFolhaLancamentoCabecalhoVO;

class function TFolhaLancamentoCabecalhoController.Consulta(pFiltro: String; pPagina: String): TZQuery;
begin
  try
    ObjetoLocal := TFolhaLancamentoCabecalhoVO.Create;
    Result := TT2TiORM.Consultar(ObjetoLocal, pFiltro, pPagina);
  finally
    ObjetoLocal.Free;
  end;
end;

class function TFolhaLancamentoCabecalhoController.ConsultaLista(pFiltro: String): TListaFolhaLancamentoCabecalhoVO;
begin
  try
    ObjetoLocal := TFolhaLancamentoCabecalhoVO.Create;
    Result := TListaFolhaLancamentoCabecalhoVO(TT2TiORM.Consultar(ObjetoLocal, pFiltro, True));
  finally
    ObjetoLocal.Free;
  end;
end;

class function TFolhaLancamentoCabecalhoController.ConsultaObjeto(pFiltro: String): TFolhaLancamentoCabecalhoVO;
begin
  try
    Result := TFolhaLancamentoCabecalhoVO.Create;
    Result := TFolhaLancamentoCabecalhoVO(TT2TiORM.ConsultarUmObjeto(Result, pFiltro, True));

    Filtro := 'ID_FOLHA_LANCAMENTO_CABECALHO = ' + IntToStr(Result.Id);

    // Objetos Vinculados

    // Listas
    Result.ListaFolhaLancamentoDetalheVO := TListaFolhaLancamentoDetalheVO(TT2TiORM.Consultar(TFolhaLancamentoDetalheVO.Create, Filtro, True));
  finally
  end;
end;

class procedure TFolhaLancamentoCabecalhoController.Insere(pObjeto: TFolhaLancamentoCabecalhoVO);
var
  UltimoID: Integer;
  I: Integer;
  Current: TFolhaLancamentoDetalheVO;
begin
  try
    UltimoID := TT2TiORM.Inserir(pObjeto);

    // Detalhes
    for I := 0 to pObjeto.ListaFolhaLancamentoDetalheVO.Count - 1 do
    begin
      Current := pObjeto.ListaFolhaLancamentoDetalheVO[I];

      Current.IdFolhaLancamentoCabecalho := UltimoID;
      TT2TiORM.Inserir(Current);
    end;

    Consulta('ID = ' + IntToStr(UltimoID), '0');
  finally
  end;
end;

class function TFolhaLancamentoCabecalhoController.Altera(pObjeto: TFolhaLancamentoCabecalhoVO): Boolean;
var
  I: Integer;
  Current: TFolhaLancamentoDetalheVO;
begin
  try
    Result := TT2TiORM.Alterar(pObjeto);

    // Detalhes
    for I := 0 to pObjeto.ListaFolhaLancamentoDetalheVO.Count - 1 do
    begin
      Current := pObjeto.ListaFolhaLancamentoDetalheVO[I];

      if Current.Id > 0 then
        Result := TT2TiORM.Alterar(Current)
      else
      begin
        Current.IdFolhaLancamentoCabecalho := pObjeto.Id;
        Result := TT2TiORM.Inserir(Current) > 0;
      end;
    end;

  finally
  end;
end;

class function TFolhaLancamentoCabecalhoController.Exclui(pId: Integer): Boolean;
var
  ObjetoLocal: TFolhaLancamentoCabecalhoVO;
begin
  try
    ObjetoLocal := TFolhaLancamentoCabecalhoVO.Create;
    ObjetoLocal.Id := pId;
    Result := TT2TiORM.Excluir(ObjetoLocal);
  finally
    FreeAndNil(ObjetoLocal)
  end;
end;

initialization
  Classes.RegisterClass(TFolhaLancamentoCabecalhoController);

finalization
  Classes.UnRegisterClass(TFolhaLancamentoCabecalhoController);

end.

