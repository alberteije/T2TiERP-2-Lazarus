{*******************************************************************************
Title: T2Ti ERP                                                                 
Description: Controller do lado Cliente relacionado à tabela [CONTABIL_INDICE] 
                                                                                
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
unit ContabilIndiceController;

{$MODE Delphi}

interface

uses
  Classes, Dialogs, SysUtils, DB, LCLIntf, LCLType, LMessages, Forms, Controller,
  VO, ZDataset, ContabilIndiceVO, ContabilIndiceValorVO;

type
  TContabilIndiceController = class(TController)
  private
  public
    class function Consulta(pFiltro: String; pPagina: String): TZQuery;
    class function ConsultaLista(pFiltro: String): TListaContabilIndiceVO;
    class function ConsultaObjeto(pFiltro: String): TContabilIndiceVO;

    class procedure Insere(pObjeto: TContabilIndiceVO);
    class function Altera(pObjeto: TContabilIndiceVO): Boolean;

    class function Exclui(pId: Integer): Boolean;

  end;

implementation

uses UDataModule, T2TiORM;

var
  ObjetoLocal: TContabilIndiceVO;

class function TContabilIndiceController.Consulta(pFiltro: String; pPagina: String): TZQuery;
begin
  try
    ObjetoLocal := TContabilIndiceVO.Create;
    Result := TT2TiORM.Consultar(ObjetoLocal, pFiltro, pPagina);
  finally
    ObjetoLocal.Free;
  end;
end;

class function TContabilIndiceController.ConsultaLista(pFiltro: String): TListaContabilIndiceVO;
begin
  try
    ObjetoLocal := TContabilIndiceVO.Create;
    Result := TListaContabilIndiceVO(TT2TiORM.Consultar(ObjetoLocal, pFiltro, True));
  finally
    ObjetoLocal.Free;
  end;
end;

class function TContabilIndiceController.ConsultaObjeto(pFiltro: String): TContabilIndiceVO;
begin
  try
    Result := TContabilIndiceVO.Create;
    Result := TContabilIndiceVO(TT2TiORM.ConsultarUmObjeto(Result, pFiltro, True));

    Filtro := 'ID_CONTABIL_INDICE = ' + IntToStr(Result.Id);

    // Objetos Vinculados

    // Listas
    Result.ListaContabilIndiceValorVO := TListaContabilIndiceValorVO(TT2TiORM.Consultar(TContabilIndiceValorVO.Create, Filtro, True));
  finally
  end;
end;

class procedure TContabilIndiceController.Insere(pObjeto: TContabilIndiceVO);
var
  UltimoID: Integer;
  I: Integer;
  Current: TContabilIndiceValorVO;
begin
  try
    UltimoID := TT2TiORM.Inserir(pObjeto);

    // Detalhes
    for I := 0 to pObjeto.ListaContabilIndiceValorVO.Count - 1 do
    begin
      Current := pObjeto.ListaContabilIndiceValorVO[I];
      Current.IdContabilIndice := UltimoID;
      TT2TiORM.Inserir(Current);
    end;
    Consulta('ID = ' + IntToStr(UltimoID), '0');
  finally
  end;
end;

class function TContabilIndiceController.Altera(pObjeto: TContabilIndiceVO): Boolean;
var
  I: Integer;
  Current: TContabilIndiceValorVO;
begin
  try
    Result := TT2TiORM.Alterar(pObjeto);

    // Detalhes
    for I := 0 to pObjeto.ListaContabilIndiceValorVO.Count - 1 do
    begin
      Current := pObjeto.ListaContabilIndiceValorVO[I];
      if Current.Id > 0 then
        Result := TT2TiORM.Alterar(Current)
      else
      begin
        Current.IdContabilIndice := pObjeto.Id;
        Result := TT2TiORM.Inserir(Current) > 0;
      end;
    end;
  finally
  end;
end;

class function TContabilIndiceController.Exclui(pId: Integer): Boolean;
var
  ObjetoLocal: TContabilIndiceVO;
begin
  try
    ObjetoLocal := TContabilIndiceVO.Create;
    ObjetoLocal.Id := pId;
    Result := TT2TiORM.Excluir(ObjetoLocal);
  finally
    FreeAndNil(ObjetoLocal)
  end;
end;

initialization
  Classes.RegisterClass(TContabilIndiceController);

finalization
  Classes.UnRegisterClass(TContabilIndiceController);

end.

