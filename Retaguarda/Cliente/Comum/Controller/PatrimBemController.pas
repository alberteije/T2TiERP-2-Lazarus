{*******************************************************************************
Title: T2Ti ERP                                                                 
Description: Controller do lado Cliente relacionado à tabela [PATRIM_BEM] 
                                                                                
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
unit PatrimBemController;

{$MODE Delphi}

interface

uses
  Classes, Dialogs, SysUtils, DB, LCLIntf, LCLType, LMessages, Forms, Controller,
  VO, ZDataset, PatrimBemVO;

type
  TPatrimBemController = class(TController)
  private
  public
    class function Consulta(pFiltro: String; pPagina: String): TZQuery;
    class function ConsultaLista(pFiltro: String): TListaPatrimBemVO;
    class function ConsultaObjeto(pFiltro: String): TPatrimBemVO;

    class procedure Insere(pObjeto: TPatrimBemVO);
    class function Altera(pObjeto: TPatrimBemVO): Boolean;

    class function Exclui(pId: Integer): Boolean;

  end;

implementation

uses UDataModule, T2TiORM, PatrimDocumentoBemVO, PatrimDepreciacaoBemVO, PatrimMovimentacaoBemVO;

var
  ObjetoLocal: TPatrimBemVO;

class function TPatrimBemController.Consulta(pFiltro: String; pPagina: String): TZQuery;
begin
  try
    ObjetoLocal := TPatrimBemVO.Create;
    Result := TT2TiORM.Consultar(ObjetoLocal, pFiltro, pPagina);
  finally
    ObjetoLocal.Free;
  end;
end;

class function TPatrimBemController.ConsultaLista(pFiltro: String): TListaPatrimBemVO;
begin
  try
    ObjetoLocal := TPatrimBemVO.Create;
    Result := TListaPatrimBemVO(TT2TiORM.Consultar(ObjetoLocal, pFiltro, True));
  finally
    ObjetoLocal.Free;
  end;
end;

class function TPatrimBemController.ConsultaObjeto(pFiltro: String): TPatrimBemVO;
begin
  try
    Result := TPatrimBemVO.Create;
    Result := TPatrimBemVO(TT2TiORM.ConsultarUmObjeto(Result, pFiltro, True));

    Filtro := 'ID_PATRIM_BEM = ' + IntToStr(Result.Id);

    // Objetos Vinculados

    // Listas
    Result.ListaPatrimDocumentoBemVO := TListaPatrimDocumentoBemVO(TT2TiORM.Consultar(TPatrimDocumentoBemVO.Create, Filtro, True));
    Result.ListaPatrimDepreciacaoBemVO := TListaPatrimDepreciacaoBemVO(TT2TiORM.Consultar(TPatrimDepreciacaoBemVO.Create, Filtro, True));
    Result.ListaPatrimMovimentacaoBemVO := TListaPatrimMovimentacaoBemVO(TT2TiORM.Consultar(TPatrimMovimentacaoBemVO.Create, Filtro, True));
  finally
  end;
end;

class procedure TPatrimBemController.Insere(pObjeto: TPatrimBemVO);
var
  UltimoID, I: Integer;
  DocumentoBem: TPatrimDocumentoBemVO;
  DepreciacaoBem: TPatrimDepreciacaoBemVO;
  MovimentacaoBem: TPatrimMovimentacaoBemVO;
begin
  try
    UltimoID := TT2TiORM.Inserir(pObjeto);

    // Documento
    for I := 0 to pObjeto.ListaPatrimDocumentoBemVO.Count - 1 do
    begin
      DocumentoBem := pObjeto.ListaPatrimDocumentoBemVO[I];
      DocumentoBem.IdPatrimBem := UltimoID;
      TT2TiORM.Inserir(DocumentoBem);
    end;

    // Depreciação
    for I := 0 to pObjeto.ListaPatrimDepreciacaoBemVO.Count - 1 do
    begin
      DepreciacaoBem := pObjeto.ListaPatrimDepreciacaoBemVO[I];
      DepreciacaoBem.IdPatrimBem := UltimoID;
      TT2TiORM.Inserir(DepreciacaoBem);
    end;

    // Movimentação
    for I := 0 to pObjeto.ListaPatrimMovimentacaoBemVO.Count - 1 do
    begin
      MovimentacaoBem := pObjeto.ListaPatrimMovimentacaoBemVO[I];
      MovimentacaoBem.IdPatrimBem := UltimoID;
      TT2TiORM.Inserir(MovimentacaoBem);
    end;

    Consulta('ID = ' + IntToStr(UltimoID), '0');
  finally
  end;
end;

class function TPatrimBemController.Altera(pObjeto: TPatrimBemVO): Boolean;
var
  UltimoID, I: Integer;
  DocumentoBem: TPatrimDocumentoBemVO;
  DepreciacaoBem: TPatrimDepreciacaoBemVO;
  MovimentacaoBem: TPatrimMovimentacaoBemVO;
begin
  try
    Result := TT2TiORM.Alterar(pObjeto);

    // Documento
    for I := 0 to pObjeto.ListaPatrimDocumentoBemVO.Count - 1 do
    begin
      DocumentoBem := pObjeto.ListaPatrimDocumentoBemVO[I];

      if DocumentoBem.Id > 0 then
        Result := TT2TiORM.Alterar(DocumentoBem)
      else
      begin
        DocumentoBem.IdPatrimBem := pObjeto.Id;
        Result := TT2TiORM.Inserir(DocumentoBem) > 0;
      end;
    end;

    // Depreciação
    for I := 0 to pObjeto.ListaPatrimDepreciacaoBemVO.Count - 1 do
    begin
      DepreciacaoBem := pObjeto.ListaPatrimDepreciacaoBemVO[I];

      if DepreciacaoBem.Id > 0 then
        Result := TT2TiORM.Alterar(DepreciacaoBem)
      else
      begin
        DepreciacaoBem.IdPatrimBem := pObjeto.Id;
        Result := TT2TiORM.Inserir(DepreciacaoBem) > 0;
      end;
    end;

    // Movimentação
    for I := 0 to pObjeto.ListaPatrimMovimentacaoBemVO.Count - 1 do
    begin
      MovimentacaoBem := pObjeto.ListaPatrimMovimentacaoBemVO[I];

      if MovimentacaoBem.Id > 0 then
        Result := TT2TiORM.Alterar(MovimentacaoBem)
      else
      begin
        MovimentacaoBem.IdPatrimBem := pObjeto.Id;
        Result := TT2TiORM.Inserir(MovimentacaoBem) > 0;
      end;
    end;

  finally
  end;
end;

class function TPatrimBemController.Exclui(pId: Integer): Boolean;
var
  ObjetoLocal: TPatrimBemVO;
begin
  try
    ObjetoLocal := TPatrimBemVO.Create;
    ObjetoLocal.Id := pId;
    Result := TT2TiORM.Excluir(ObjetoLocal);
  finally
    FreeAndNil(ObjetoLocal)
  end;
end;

initialization
  Classes.RegisterClass(TPatrimBemController);

finalization
  Classes.UnRegisterClass(TPatrimBemController);

end.

