{*******************************************************************************
Title: T2Ti ERP                                                                 
Description: Controller do lado Cliente relacionado à tabela [NFSE_CABECALHO] 
                                                                                
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
unit NfseCabecalhoController;

interface

uses
  Classes, Dialogs, SysUtils, DB, LCLIntf, LCLType, LMessages, Forms, Controller,
  VO, ZDataset, NfseCabecalhoVO;

type
  TNfseCabecalhoController = class(TController)
  private
  public
    class function Consulta(pFiltro: String; pPagina: String): TZQuery;
    class function ConsultaLista(pFiltro: String): TListaNfseCabecalhoVO;
    class function ConsultaObjeto(pFiltro: String): TNfseCabecalhoVO;

    class procedure Insere(pObjeto: TNfseCabecalhoVO);
    class function Altera(pObjeto: TNfseCabecalhoVO): Boolean;

    class function Exclui(pId: Integer): Boolean;

  end;

implementation

uses UDataModule, T2TiORM, NFSeDetalheVO, NFSeIntermediarioVO;

var
  ObjetoLocal: TNfseCabecalhoVO;

class function TNfseCabecalhoController.Consulta(pFiltro: String; pPagina: String): TZQuery;
begin
  try
    ObjetoLocal := TNfseCabecalhoVO.Create;
    Result := TT2TiORM.Consultar(ObjetoLocal, pFiltro, pPagina);
  finally
    ObjetoLocal.Free;
  end;
end;

class function TNfseCabecalhoController.ConsultaLista(pFiltro: String): TListaNfseCabecalhoVO;
begin
  try
    ObjetoLocal := TNfseCabecalhoVO.Create;
    Result := TListaNfseCabecalhoVO(TT2TiORM.Consultar(ObjetoLocal, pFiltro, True));
  finally
    ObjetoLocal.Free;
  end;
end;

class function TNfseCabecalhoController.ConsultaObjeto(pFiltro: String): TNfseCabecalhoVO;
begin
  try
    Result := TNfseCabecalhoVO.Create;
    Result := TNfseCabecalhoVO(TT2TiORM.ConsultarUmObjeto(Result, pFiltro, True));
  finally
  end;
end;

class procedure TNfseCabecalhoController.Insere(pObjeto: TNfseCabecalhoVO);
var
  UltimoID: Integer;
  DetalheVO: TNFSeDetalheVO;
  IntermediarioVO: TNFSeIntermediarioVO;
begin
  try
    UltimoID := TT2TiORM.Inserir(pObjeto);

    // Detalhe
    DetalheEnumerator := pObjeto.ListaNFSeDetalheVO.GetEnumerator;
    try
      with DetalheEnumerator do
      begin
        while MoveNext do
        begin
          DetalheVO := Current;
          DetalheVO.IdNfseCabecalho := UltimoID;
          TT2TiORM.Inserir(DetalheVO);
        end;
      end;
    finally
      DetalheEnumerator.Free;
    end;

    // Intermediário
    IntermediarioEnumerator := pObjeto.ListaNFSeIntermediarioVO.GetEnumerator;
    try
      with IntermediarioEnumerator do
      begin
        while MoveNext do
        begin
          IntermediarioVO := Current;
          IntermediarioVO.IdNfseCabecalho := UltimoID;
          TT2TiORM.Inserir(IntermediarioVO);
        end;
      end;
    finally
      IntermediarioEnumerator.Free;
    end;

    Consulta('ID = ' + IntToStr(UltimoID), '0');
  finally
  end;
end;

class function TNfseCabecalhoController.Altera(pObjeto: TNfseCabecalhoVO): Boolean;
var
begin
  try
    Result := TT2TiORM.Alterar(pObjeto);

    // Detalhe
    try
      DetalheEnumerator := pObjeto.ListaNFSeDetalheVO.GetEnumerator;
      with DetalheEnumerator do
      begin
        while MoveNext do
        begin
          if Current.Id > 0 then
            Result := TT2TiORM.Alterar(Current)
          else
          begin
            Current.IdNfseCabecalho := pObjeto.Id;
            Result := TT2TiORM.Inserir(Current) > 0;
          end;
        end;
      end;
    finally
      FreeAndNil(DetalheEnumerator);
    end;

    // Intermediário
    try
      IntermediarioEnumerator := pObjeto.ListaNFSeIntermediarioVO.GetEnumerator;
      with IntermediarioEnumerator do
      begin
        while MoveNext do
        begin
          if Current.Id > 0 then
            Result := TT2TiORM.Alterar(Current)
          else
          begin
            Current.IdNfseCabecalho := pObjeto.Id;
            Result := TT2TiORM.Inserir(Current) > 0;
          end;
        end;
      end;
    finally
      FreeAndNil(IntermediarioEnumerator);
    end;

  finally
  end;
end;

class function TNfseCabecalhoController.Exclui(pId: Integer): Boolean;
var
  ObjetoLocal: TNfseCabecalhoVO;
begin
  try
    ObjetoLocal := TNfseCabecalhoVO.Create;
    ObjetoLocal.Id := pId;
    Result := TT2TiORM.Excluir(ObjetoLocal);
  finally
    FreeAndNil(ObjetoLocal)
  end;
end;

begin
  Result := FDataSet;
end;

begin
  FDataSet := pDataSet;
end;

begin
  try
  finally
    FreeAndNil(pListaObjetos);
  end;
end;

initialization
  Classes.RegisterClass(TNfseCabecalhoController);

finalization
  Classes.UnRegisterClass(TNfseCabecalhoController);

end.

