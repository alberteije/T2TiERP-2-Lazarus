{*******************************************************************************
Title: T2Ti ERP                                                                 
Description: Controller do lado Cliente relacionado à tabela [PONTO_ESCALA] 
                                                                                
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
unit PontoEscalaController;

{$MODE Delphi}

interface

uses
  Classes, Dialogs, SysUtils, DB, LCLIntf, LCLType, LMessages, Forms, Controller,
  VO, ZDataset, PontoEscalaVO;

type
  TPontoEscalaController = class(TController)
  private
  public
    class function Consulta(pFiltro: String; pPagina: String): TZQuery;
    class function ConsultaLista(pFiltro: String): TListaPontoEscalaVO;
    class function ConsultaObjeto(pFiltro: String): TPontoEscalaVO;

    class procedure Insere(pObjeto: TPontoEscalaVO);
    class function Altera(pObjeto: TPontoEscalaVO): Boolean;

    class function Exclui(pId: Integer): Boolean;

  end;

implementation

uses UDataModule, T2TiORM, PontoTurmaVO;

var
  ObjetoLocal: TPontoEscalaVO;

class function TPontoEscalaController.Consulta(pFiltro: String; pPagina: String): TZQuery;
begin
  try
    ObjetoLocal := TPontoEscalaVO.Create;
    Result := TT2TiORM.Consultar(ObjetoLocal, pFiltro, pPagina);
  finally
    ObjetoLocal.Free;
  end;
end;

class function TPontoEscalaController.ConsultaLista(pFiltro: String): TListaPontoEscalaVO;
begin
  try
    ObjetoLocal := TPontoEscalaVO.Create;
    Result := TListaPontoEscalaVO(TT2TiORM.Consultar(ObjetoLocal, pFiltro, True));
  finally
    ObjetoLocal.Free;
  end;
end;

class function TPontoEscalaController.ConsultaObjeto(pFiltro: String): TPontoEscalaVO;
begin
  try
    Result := TPontoEscalaVO.Create;
    Result := TPontoEscalaVO(TT2TiORM.ConsultarUmObjeto(Result, pFiltro, True));

    Filtro := 'ID_PONTO_ESCALA = ' + IntToStr(Result.Id);

    // Objetos Vinculados

    // Listas
    Result.ListaPontoTurmaVO := TListaPontoTurmaVO(TT2TiORM.Consultar(TPontoTurmaVO.Create, Filtro, True));

  finally
  end;
end;

class procedure TPontoEscalaController.Insere(pObjeto: TPontoEscalaVO);
var
  UltimoID: Integer;
  Current: TPontoTurmaVO;
  I: Integer;
begin
  try
    UltimoID := TT2TiORM.Inserir(pObjeto);

    // Turmas
    for I := 0 to pObjeto.ListaPontoTurmaVO.Count - 1 do
    begin
      Current := pObjeto.ListaPontoTurmaVO[I];

      Current.IdPontoEscala := UltimoID;
      TT2TiORM.Inserir(Current);
    end;

    Consulta('ID = ' + IntToStr(UltimoID), '0');
  finally
  end;
end;

class function TPontoEscalaController.Altera(pObjeto: TPontoEscalaVO): Boolean;
var
  Current: TPontoTurmaVO;
  I: Integer;
begin
  try
    Result := TT2TiORM.Alterar(pObjeto);

    // Turmas
    for I := 0 to pObjeto.ListaPontoTurmaVO.Count - 1 do
    begin
      Current := pObjeto.ListaPontoTurmaVO[I];

      if Current.Id > 0 then
        Result := TT2TiORM.Alterar(Current)
      else
      begin
        Current.IdPontoEscala := pObjeto.Id;
        Result := TT2TiORM.Inserir(Current) > 0;
      end;
    end;
  finally
  end;
end;

class function TPontoEscalaController.Exclui(pId: Integer): Boolean;
var
  ObjetoLocal: TPontoEscalaVO;
begin
  try
    ObjetoLocal := TPontoEscalaVO.Create;
    ObjetoLocal.Id := pId;

    Result := TT2TiORM.ComandoSQL('DELETE FROM PONTO_TURMA where ID_PONTO_ESCALA = ' + IntToStr(pId));

    Result := TT2TiORM.Excluir(ObjetoLocal);
  finally
    FreeAndNil(ObjetoLocal)
  end;
end;

initialization
  Classes.RegisterClass(TPontoEscalaController);

finalization
  Classes.UnRegisterClass(TPontoEscalaController);

end.

