{*******************************************************************************
Title: T2Ti ERP                                                                 
Description: Controller do lado Cliente relacionado à tabela [TRIBUT_ICMS_CUSTOM_CAB] 
                                                                                
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
@version 1.0                                                                    
*******************************************************************************}
unit TributIcmsCustomCabController;

{$MODE Delphi}

interface

uses
  Classes, Dialogs, SysUtils, DB, LCLIntf, LCLType, LMessages, Forms, Controller,
  TributIcmsCustomCabVO, TributIcmsCustomDetVO, ZDataset, VO;

type
  TTributIcmsCustomCabController = class(TController)
  private
  public
    class function Consulta(pFiltro: String; pPagina: String): TZQuery;
    class function ConsultaLista(pFiltro: String): TListaTributIcmsCustomCabVO;
    class function ConsultaObjeto(pFiltro: String): TTributIcmsCustomCabVO;

    class procedure Insere(pObjeto: TTributIcmsCustomCabVO);
    class function Altera(pObjeto: TTributIcmsCustomCabVO): Boolean;

    class function Exclui(pId: Integer): Boolean;
    class function ExcluiDetalhe(pId: Integer): Boolean;

  end;

implementation

uses UDataModule, T2TiORM;

var
  ObjetoLocal: TTributIcmsCustomCabVO;

class function TTributIcmsCustomCabController.Consulta(pFiltro: String; pPagina: String): TZQuery;
begin
  try
    ObjetoLocal := TTributIcmsCustomCabVO.Create;
    Result := TT2TiORM.Consultar(ObjetoLocal, pFiltro, pPagina);
  finally
    ObjetoLocal.Free;
  end;
end;

class function TTributIcmsCustomCabController.ConsultaLista(pFiltro: String): TListaTributIcmsCustomCabVO;
begin
  try
    ObjetoLocal := TTributIcmsCustomCabVO.Create;
    Result := TListaTributIcmsCustomCabVO(TT2TiORM.Consultar(ObjetoLocal, pFiltro, True));
  finally
    ObjetoLocal.Free;
  end;
end;

class function TTributIcmsCustomCabController.ConsultaObjeto(pFiltro: String): TTributIcmsCustomCabVO;
var
  Filtro: String;
begin
  try
    Result := TTributIcmsCustomCabVO.Create;
    Result := TTributIcmsCustomCabVO(TT2TiORM.ConsultarUmObjeto(Result, pFiltro, True));

    Filtro := 'ID_TRIBUT_ICMS_CUSTOM_CAB = ' + IntToStr(Result.Id);
    Result.ListaTributIcmsCustomDetVO := TListaTributIcmsCustomDetVO(TT2TiORM.Consultar(TTributIcmsCustomDetVO.Create, Filtro, True));
  finally
  end;
end;

class procedure TTributIcmsCustomCabController.Insere(pObjeto: TTributIcmsCustomCabVO);
var
  UltimoID, I: Integer;
  Current: TTributIcmsCustomDetVO;
begin
  try
    UltimoID := TT2TiORM.Inserir(pObjeto);

    // Detalhes
    for I := 0 to pObjeto.ListaTributIcmsCustomDetVO.Count - 1 do
    begin
      Current := pObjeto.ListaTributIcmsCustomDetVO[I];
      Current.IdTributIcmsCustomCab := UltimoID;
      TT2TiORM.Inserir(Current);
    end;

    Consulta('ID = ' + IntToStr(UltimoID), '0');
  finally
  end;
end;

class function TTributIcmsCustomCabController.Altera(pObjeto: TTributIcmsCustomCabVO): Boolean;
var
  I: Integer;
  Current: TTributIcmsCustomDetVO;
begin
  try
    Result := TT2TiORM.Alterar(pObjeto);

    // Detalhes
    for I := 0 to pObjeto.ListaTributIcmsCustomDetVO.Count - 1 do
    begin
      Current := pObjeto.ListaTributIcmsCustomDetVO[I];
      if Current.Id > 0 then
        Result := TT2TiORM.Alterar(Current)
      else
      begin
        Current.IdTributIcmsCustomCab := pObjeto.Id;
        Result := TT2TiORM.Inserir(Current) > 0;
      end;
    end;
  finally
  end;
end;

class function TTributIcmsCustomCabController.Exclui(pId: Integer): Boolean;
var
  ObjetoLocal: TTributIcmsCustomCabVO;
begin
  try
    ObjetoLocal := TTributIcmsCustomCabVO.Create;
    ObjetoLocal.Id := pId;
    Result := TT2TiORM.Excluir(ObjetoLocal);
  finally
    FreeAndNil(ObjetoLocal)
  end;
end;

class function TTributIcmsCustomCabController.ExcluiDetalhe(pId: Integer): Boolean;
var
  ObjetoLocal: TTributIcmsCustomDetVO;
begin
  try
    ObjetoLocal := TTributIcmsCustomDetVO.Create;
    ObjetoLocal.Id := pId;
    Result := TT2TiORM.Excluir(ObjetoLocal);
  finally
    FreeAndNil(ObjetoLocal)
  end;
end;

initialization
  Classes.RegisterClass(TTributIcmsCustomCabController);

finalization
  Classes.UnRegisterClass(TTributIcmsCustomCabController);

end.

