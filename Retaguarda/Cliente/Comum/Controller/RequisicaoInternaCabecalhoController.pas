{*******************************************************************************
Title: T2Ti ERP                                                                 
Description: Controller do lado Cliente relacionado à tabela [REQUISICAO_INTERNA_CABECALHO] 
                                                                                
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
unit RequisicaoInternaCabecalhoController;

{$MODE Delphi}

interface

uses
  Classes, Dialogs, SysUtils, DB, LCLIntf, LCLType, LMessages, Forms, Controller,
  VO, ZDataset, RequisicaoInternaCabecalhoVO, RequisicaoInternaDetalheVO;

type
  TRequisicaoInternaCabecalhoController = class(TController)
  private
  public
    class function Consulta(pFiltro: String; pPagina: String): TZQuery;
    class function ConsultaLista(pFiltro: String): TListaRequisicaoInternaCabecalhoVO;
    class function ConsultaObjeto(pFiltro: String): TRequisicaoInternaCabecalhoVO;

    class procedure Insere(pObjeto: TRequisicaoInternaCabecalhoVO);
    class function Altera(pObjeto: TRequisicaoInternaCabecalhoVO): Boolean;

    class function Exclui(pId: Integer): Boolean;

  end;

implementation

uses UDataModule, T2TiORM, ControleEstoqueController;

var
  ObjetoLocal: TRequisicaoInternaCabecalhoVO;

class function TRequisicaoInternaCabecalhoController.Consulta(pFiltro: String; pPagina: String): TZQuery;
begin
  try
    ObjetoLocal := TRequisicaoInternaCabecalhoVO.Create;
    Result := TT2TiORM.Consultar(ObjetoLocal, pFiltro, pPagina);
  finally
    ObjetoLocal.Free;
  end;
end;

class function TRequisicaoInternaCabecalhoController.ConsultaLista(pFiltro: String): TListaRequisicaoInternaCabecalhoVO;
begin
  try
    ObjetoLocal := TRequisicaoInternaCabecalhoVO.Create;
    Result := TListaRequisicaoInternaCabecalhoVO(TT2TiORM.Consultar(ObjetoLocal, pFiltro, True));
  finally
    ObjetoLocal.Free;
  end;
end;

class function TRequisicaoInternaCabecalhoController.ConsultaObjeto(pFiltro: String): TRequisicaoInternaCabecalhoVO;
begin
  try
    Result := TRequisicaoInternaCabecalhoVO.Create;
    Result := TRequisicaoInternaCabecalhoVO(TT2TiORM.ConsultarUmObjeto(Result, pFiltro, True));

    Filtro := 'ID_REQ_INTERNA_CABECALHO = ' + IntToStr(Result.Id);

    // Objetos Vinculados

    // Listas
    Result.ListaRequisicaoInterna := TListaRequisicaoInternaDetalheVO(TT2TiORM.Consultar(TRequisicaoInternaDetalheVO.Create, Filtro, True));

  finally
  end;
end;

class procedure TRequisicaoInternaCabecalhoController.Insere(pObjeto: TRequisicaoInternaCabecalhoVO);
var
  UltimoID: Integer;
  I: Integer;
  Current: TRequisicaoInternaDetalheVO;
begin
  try
    UltimoID := TT2TiORM.Inserir(pObjeto);

    for I := 0 to pObjeto.ListaRequisicaoInterna.Count - 1 do
    begin
      Current := pObjeto.ListaRequisicaoInterna[I];

      Current.IdReqInternaCabecalho := UltimoID;
      TT2TiORM.Inserir(Current);
    end;

    Consulta('ID = ' + IntToStr(UltimoID), '0');
  finally
  end;
end;

class function TRequisicaoInternaCabecalhoController.Altera(pObjeto: TRequisicaoInternaCabecalhoVO): Boolean;
var
  I: Integer;
  Current: TRequisicaoInternaDetalheVO;
begin
  try
    Result := TT2TiORM.Alterar(pObjeto);

    // Requisição Detalhe
    for I := 0 to pObjeto.ListaRequisicaoInterna.Count - 1 do
    begin
      Current := pObjeto.ListaRequisicaoInterna[I];

      if Current.Id > 0 then
        Result := TT2TiORM.Alterar(Current)
      else
      begin
        Current.IdReqInternaCabecalho := pObjeto.Id;
        Result := TT2TiORM.Inserir(Current) > 0;
      end;

      // Atualiza estoque
      if pObjeto.Situacao = 'D' then
      begin
        TControleEstoqueController.AtualizarEstoque(Current.Quantidade * -1, Current.IdProduto, Sessao.Empresa.Id, Sessao.Empresa.TipoControleEstoque);
      end;
    end;
  finally
  end;
end;

class function TRequisicaoInternaCabecalhoController.Exclui(pId: Integer): Boolean;
var
  ObjetoLocal: TRequisicaoInternaCabecalhoVO;
begin
  try
    ObjetoLocal := TRequisicaoInternaCabecalhoVO.Create;
    ObjetoLocal.Id := pId;
    Result := TT2TiORM.Excluir(ObjetoLocal);
  finally
    FreeAndNil(ObjetoLocal)
  end;
end;

initialization
  Classes.RegisterClass(TRequisicaoInternaCabecalhoController);

finalization
  Classes.UnRegisterClass(TRequisicaoInternaCabecalhoController);

end.

