{*******************************************************************************
Title: T2Ti ERP                                                                 
Description: Controller do lado Cliente relacionado à tabela [COMPRA_REQUISICAO] 
                                                                                
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
unit CompraRequisicaoController;

{$MODE Delphi}

interface

uses
  Classes, Dialogs, SysUtils, DB, LCLIntf, LCLType, LMessages, Forms, Controller,
  VO, ZDataset, CompraRequisicaoVO, CompraRequisicaoDetalheVO;

type
  TCompraRequisicaoController = class(TController)
  private
  public
    class function Consulta(pFiltro: String; pPagina: String): TZQuery;
    class function ConsultaLista(pFiltro: String): TListaCompraRequisicaoVO;
    class function ConsultaObjeto(pFiltro: String): TCompraRequisicaoVO;

    class procedure Insere(pObjeto: TCompraRequisicaoVO);
    class function Altera(pObjeto: TCompraRequisicaoVO): Boolean;

    class function Exclui(pId: Integer): Boolean;

  end;

implementation

uses UDataModule, T2TiORM;

var
  ObjetoLocal: TCompraRequisicaoVO;

class function TCompraRequisicaoController.Consulta(pFiltro: String; pPagina: String): TZQuery;
begin
  try
    ObjetoLocal := TCompraRequisicaoVO.Create;
    Result := TT2TiORM.Consultar(ObjetoLocal, pFiltro, pPagina);
  finally
    ObjetoLocal.Free;
  end;
end;

class function TCompraRequisicaoController.ConsultaLista(pFiltro: String): TListaCompraRequisicaoVO;
begin
  try
    ObjetoLocal := TCompraRequisicaoVO.Create;
    Result := TListaCompraRequisicaoVO(TT2TiORM.Consultar(ObjetoLocal, pFiltro, True));
  finally
    ObjetoLocal.Free;
  end;
end;

class function TCompraRequisicaoController.ConsultaObjeto(pFiltro: String): TCompraRequisicaoVO;
begin
  try
    Result := TCompraRequisicaoVO.Create;
    Result := TCompraRequisicaoVO(TT2TiORM.ConsultarUmObjeto(Result, pFiltro, True));

    Filtro := 'ID_COMPRA_REQUISICAO = ' + IntToStr(Result.Id);

    // Objetos Vinculados
    Result.ColaboradorPessoaNome := Result.ColaboradorVO.Nome;
    Result.CompraTipoRequisicaoNome := Result.CompraTipoRequisicaoVO.Nome;

    // Listas
    Result.ListaCompraRequisicaoDetalheVO := TListaCompraRequisicaoDetalheVO(TT2TiORM.Consultar(TCompraRequisicaoDetalheVO.Create, Filtro, True));

  finally
  end;
end;

class procedure TCompraRequisicaoController.Insere(pObjeto: TCompraRequisicaoVO);
var
  UltimoID: Integer;
  I: Integer;
  Current: TCompraRequisicaoDetalheVO;
begin
  try
    UltimoID := TT2TiORM.Inserir(pObjeto);

    // Detalhes
    for I := 0 to pObjeto.ListaCompraRequisicaoDetalheVO.Count - 1 do
    begin
      Current := pObjeto.ListaCompraRequisicaoDetalheVO[I];
      Current.IdCompraRequisicao := UltimoID;
      TT2TiORM.Inserir(Current);
    end;

    Consulta('ID = ' + IntToStr(UltimoID), '0');
  finally
  end;
end;

class function TCompraRequisicaoController.Altera(pObjeto: TCompraRequisicaoVO): Boolean;
var
  I: Integer;
  Current: TCompraRequisicaoDetalheVO;
begin
  try
    Result := TT2TiORM.Alterar(pObjeto);

    // Detalhes
    for I := 0 to pObjeto.ListaCompraRequisicaoDetalheVO.Count - 1 do
    begin
      Current := pObjeto.ListaCompraRequisicaoDetalheVO[I];

      if Current.Id > 0 then
        Result := TT2TiORM.Alterar(Current)
      else
      begin
        Current.IdCompraRequisicao := pObjeto.Id;
        Result := TT2TiORM.Inserir(Current) > 0;
      end;
    end;
  finally
  end;
end;

class function TCompraRequisicaoController.Exclui(pId: Integer): Boolean;
var
  ObjetoLocal: TCompraRequisicaoVO;
begin
  try
    ObjetoLocal := TCompraRequisicaoVO.Create;
    ObjetoLocal.Id := pId;

    Result := TT2TiORM.ComandoSQL('DELETE FROM COMPRA_REQUISICAO_DETALHE where ID_COMPRA_REQUISICAO = ' + IntToStr(pId));

    Result := TT2TiORM.Excluir(ObjetoLocal);
  finally
    FreeAndNil(ObjetoLocal)
  end;
end;

initialization
  Classes.RegisterClass(TCompraRequisicaoController);

finalization
  Classes.UnRegisterClass(TCompraRequisicaoController);

end.

