{*******************************************************************************
Title: T2Ti ERP                                                                 
Description: Controller do lado Cliente relacionado à tabela [FOLHA_INSS] 
                                                                                
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
unit FolhaInssController;

{$MODE Delphi}

interface

uses
  Classes, Dialogs, SysUtils, DB, LCLIntf, LCLType, LMessages, Forms, Controller,
  VO, ZDataset, FolhaInssVO;

type
  TFolhaInssController = class(TController)
  private
  public
    class function Consulta(pFiltro: String; pPagina: String): TZQuery;
    class function ConsultaLista(pFiltro: String): TListaFolhaInssVO;
    class function ConsultaObjeto(pFiltro: String): TFolhaInssVO;

    class procedure Insere(pObjeto: TFolhaInssVO);
    class function Altera(pObjeto: TFolhaInssVO): Boolean;

    class function Exclui(pId: Integer): Boolean;

  end;

implementation

uses UDataModule, T2TiORM, FolhaInssRetencaoVO;

var
  ObjetoLocal: TFolhaInssVO;

class function TFolhaInssController.Consulta(pFiltro: String; pPagina: String): TZQuery;
begin
  try
    ObjetoLocal := TFolhaInssVO.Create;
    Result := TT2TiORM.Consultar(ObjetoLocal, pFiltro, pPagina);
  finally
    ObjetoLocal.Free;
  end;
end;

class function TFolhaInssController.ConsultaLista(pFiltro: String): TListaFolhaInssVO;
begin
  try
    ObjetoLocal := TFolhaInssVO.Create;
    Result := TListaFolhaInssVO(TT2TiORM.Consultar(ObjetoLocal, pFiltro, True));
  finally
    ObjetoLocal.Free;
  end;
end;

class function TFolhaInssController.ConsultaObjeto(pFiltro: String): TFolhaInssVO;
begin
  try
    Result := TFolhaInssVO.Create;
    Result := TFolhaInssVO(TT2TiORM.ConsultarUmObjeto(Result, pFiltro, True));
  finally
  end;
end;

class procedure TFolhaInssController.Insere(pObjeto: TFolhaInssVO);
var
  UltimoID: Integer;
begin
  try
    UltimoID := TT2TiORM.Inserir(pObjeto);
    {
    // Retenções
    FolhaFolhaInssRetencaoEnumerator := pObjeto.ListaFolhaInssRetencaoVO.GetEnumerator;
    try
      with FolhaFolhaInssRetencaoEnumerator do
      begin
        while MoveNext do
        begin
          Current.IdFolhaInss := UltimoID;
          TT2TiORM.Inserir(Current);
        end;
      end;
    finally
      FreeAndNil(FolhaFolhaInssRetencaoEnumerator);
    end;
    }
    Consulta('ID = ' + IntToStr(UltimoID), '0');
  finally
  end;
end;

class function TFolhaInssController.Altera(pObjeto: TFolhaInssVO): Boolean;
begin
  try
    Result := TT2TiORM.Alterar(pObjeto);
    {
    // Retenções
    try
      FolhaFolhaInssRetencaoEnumerator := pObjeto.ListaFolhaInssRetencaoVO.GetEnumerator;
      with FolhaFolhaInssRetencaoEnumerator do
      begin
        while MoveNext do
        begin
          if Current.Id > 0 then
            Result := TT2TiORM.Alterar(Current)
          else
          begin
            Current.IdFolhaInss := pObjeto.Id;
            Result := TT2TiORM.Inserir(Current) > 0;
          end;
        end;
      end;
    finally
      FreeAndNil(FolhaFolhaInssRetencaoEnumerator);
    end;
    }
  finally
  end;
end;

class function TFolhaInssController.Exclui(pId: Integer): Boolean;
var
  ObjetoLocal: TFolhaInssVO;
begin
  try
    ObjetoLocal := TFolhaInssVO.Create;
    ObjetoLocal.Id := pId;
    Result := TT2TiORM.Excluir(ObjetoLocal);
  finally
    FreeAndNil(ObjetoLocal)
  end;
end;

initialization
  Classes.RegisterClass(TFolhaInssController);

finalization
  Classes.UnRegisterClass(TFolhaInssController);

end.

