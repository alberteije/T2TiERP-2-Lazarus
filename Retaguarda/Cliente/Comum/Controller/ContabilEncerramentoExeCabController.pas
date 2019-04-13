{*******************************************************************************
Title: T2Ti ERP                                                                 
Description: Controller do lado Cliente relacionado à tabela [CONTABIL_ENCERRAMENTO_EXE_CAB] 
                                                                                
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
unit ContabilEncerramentoExeCabController;

{$MODE Delphi}

interface

uses
  Classes, Dialogs, SysUtils, DB, LCLIntf, LCLType, LMessages, Forms, Controller,
  VO, ZDataset, ContabilEncerramentoExeCabVO,
  ContabilEncerramentoExeDetVO;

type
  TContabilEncerramentoExeCabController = class(TController)
  private
  public
    class function Consulta(pFiltro: String; pPagina: String): TZQuery;
    class function ConsultaLista(pFiltro: String): TListaContabilEncerramentoExeCabVO;
    class function ConsultaObjeto(pFiltro: String): TContabilEncerramentoExeCabVO;

    class procedure Insere(pObjeto: TContabilEncerramentoExeCabVO);
    class function Altera(pObjeto: TContabilEncerramentoExeCabVO): Boolean;

    class function Exclui(pId: Integer): Boolean;

  end;

implementation

uses UDataModule, T2TiORM;

var
  ObjetoLocal: TContabilEncerramentoExeCabVO;

class function TContabilEncerramentoExeCabController.Consulta(pFiltro: String; pPagina: String): TZQuery;
begin
  try
    ObjetoLocal := TContabilEncerramentoExeCabVO.Create;
    Result := TT2TiORM.Consultar(ObjetoLocal, pFiltro, pPagina);
  finally
    ObjetoLocal.Free;
  end;
end;

class function TContabilEncerramentoExeCabController.ConsultaLista(pFiltro: String): TListaContabilEncerramentoExeCabVO;
begin
  try
    ObjetoLocal := TContabilEncerramentoExeCabVO.Create;
    Result := TListaContabilEncerramentoExeCabVO(TT2TiORM.Consultar(ObjetoLocal, pFiltro, True));
  finally
    ObjetoLocal.Free;
  end;
end;

class function TContabilEncerramentoExeCabController.ConsultaObjeto(pFiltro: String): TContabilEncerramentoExeCabVO;
begin
  try
    Result := TContabilEncerramentoExeCabVO.Create;
    Result := TContabilEncerramentoExeCabVO(TT2TiORM.ConsultarUmObjeto(Result, pFiltro, True));

    Filtro := 'ID_CONTABIL_ENCERRAMENTO_EXE = ' + IntToStr(Result.Id);

    // Objetos Vinculados

    // Listas
    Result.ListaContabilEncerramentoExeDetVO := TListaContabilEncerramentoExeDetVO(TT2TiORM.Consultar(TContabilEncerramentoExeDetVO.Create, Filtro, True));
  finally
  end;
end;

class procedure TContabilEncerramentoExeCabController.Insere(pObjeto: TContabilEncerramentoExeCabVO);
var
  UltimoID: Integer;
  Current: TContabilEncerramentoExeDetVO;
  i:integer;
begin
  try
    UltimoID := TT2TiORM.Inserir(pObjeto);

    // Detalhes
    for I := 0 to pObjeto.ListaContabilEncerramentoExeDetVO.Count - 1 do
    begin
      Current := pObjeto.ListaContabilEncerramentoExeDetVO[I];

      Current.IdContabilEncerramentoExe := UltimoID;
      TT2TiORM.Inserir(Current);
    end;

    Consulta('ID = ' + IntToStr(UltimoID), '0');
  finally
  end;
end;

class function TContabilEncerramentoExeCabController.Altera(pObjeto: TContabilEncerramentoExeCabVO): Boolean;
var
  Current: TContabilEncerramentoExeDetVO;
  i:integer;
begin
  try
    Result := TT2TiORM.Alterar(pObjeto);

    // Detalhes
    for I := 0 to pObjeto.ListaContabilEncerramentoExeDetVO.Count - 1 do
    begin
      Current := pObjeto.ListaContabilEncerramentoExeDetVO[I];
      if Current.Id > 0 then
        Result := TT2TiORM.Alterar(Current)
      else
      begin
        Current.IdContabilEncerramentoExe := pObjeto.Id;
        Result := TT2TiORM.Inserir(Current) > 0;
      end;
    end;

  finally
  end;
end;

class function TContabilEncerramentoExeCabController.Exclui(pId: Integer): Boolean;
var
  ObjetoLocal: TContabilEncerramentoExeCabVO;
begin
  try
    ObjetoLocal := TContabilEncerramentoExeCabVO.Create;
    ObjetoLocal.Id := pId;
    Result := TT2TiORM.Excluir(ObjetoLocal);
  finally
    FreeAndNil(ObjetoLocal)
  end;
end;

initialization
  Classes.RegisterClass(TContabilEncerramentoExeCabController);

finalization
  Classes.UnRegisterClass(TContabilEncerramentoExeCabController);

end.

