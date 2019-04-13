{*******************************************************************************
Title: T2Ti ERP                                                                 
Description: Controller do lado Cliente relacionado à tabela [FISCAL_LIVRO] 
                                                                                
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
unit FiscalLivroController;

{$MODE Delphi}

interface

uses
  Classes, Dialogs, SysUtils, DB, LCLIntf, LCLType, LMessages, Forms, Controller,
  VO, ZDataset, FiscalLivroVO, FiscalTermoVO;

type
  TFiscalLivroController = class(TController)
  private
  public
    class function Consulta(pFiltro: String; pPagina: String): TZQuery;
    class function ConsultaLista(pFiltro: String): TListaFiscalLivroVO;
    class function ConsultaObjeto(pFiltro: String): TFiscalLivroVO;

    class procedure Insere(pObjeto: TFiscalLivroVO);
    class function Altera(pObjeto: TFiscalLivroVO): Boolean;

    class function Exclui(pId: Integer): Boolean;

  end;

implementation

uses UDataModule, T2TiORM;

var
  ObjetoLocal: TFiscalLivroVO;

class function TFiscalLivroController.Consulta(pFiltro: String; pPagina: String): TZQuery;
begin
  try
    ObjetoLocal := TFiscalLivroVO.Create;
    Result := TT2TiORM.Consultar(ObjetoLocal, pFiltro, pPagina);
  finally
    ObjetoLocal.Free;
  end;
end;

class function TFiscalLivroController.ConsultaLista(pFiltro: String): TListaFiscalLivroVO;
begin
  try
    ObjetoLocal := TFiscalLivroVO.Create;
    Result := TListaFiscalLivroVO(TT2TiORM.Consultar(ObjetoLocal, pFiltro, True));
  finally
    ObjetoLocal.Free;
  end;
end;

class function TFiscalLivroController.ConsultaObjeto(pFiltro: String): TFiscalLivroVO;
begin
  try
    Result := TFiscalLivroVO.Create;
    Result := TFiscalLivroVO(TT2TiORM.ConsultarUmObjeto(Result, pFiltro, True));

    Filtro := 'ID_FISCAL_LIVRO = ' + IntToStr(Result.Id);

    // Objetos Vinculados

    // Listas
    Result.ListaFiscalTermoVO := TListaFiscalTermoVO(TT2TiORM.Consultar(TFiscalTermoVO.Create, Filtro, True));
  finally
  end;
end;

class procedure TFiscalLivroController.Insere(pObjeto: TFiscalLivroVO);
var
  UltimoID: Integer;
  I: Integer;
  Current: TFiscalTermoVO;
begin
  try
    UltimoID := TT2TiORM.Inserir(pObjeto);

    // Detalhes
    for I := 0 to pObjeto.ListaFiscalTermoVO.Count - 1 do
    begin
      Current := pObjeto.ListaFiscalTermoVO[I];

      Current.IdFiscalLivro := UltimoID;
      TT2TiORM.Inserir(Current);
    end;

    Consulta('ID = ' + IntToStr(UltimoID), '0');
  finally
  end;
end;


class function TFiscalLivroController.Altera(pObjeto: TFiscalLivroVO): Boolean;
begin
  try
    Result := TT2TiORM.Alterar(pObjeto);
  finally
  end;
end;

class function TFiscalLivroController.Exclui(pId: Integer): Boolean;
var
  ObjetoLocal: TFiscalLivroVO;
begin
  try
    ObjetoLocal := TFiscalLivroVO.Create;
    ObjetoLocal.Id := pId;
    Result := TT2TiORM.Excluir(ObjetoLocal);
  finally
    FreeAndNil(ObjetoLocal)
  end;
end;

initialization
  Classes.RegisterClass(TFiscalLivroController);

finalization
  Classes.UnRegisterClass(TFiscalLivroController);

end.

