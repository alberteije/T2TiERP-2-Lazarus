{*******************************************************************************
Title: T2Ti ERP                                                                 
Description: Controller do lado Cliente relacionado à tabela [NFE_NUMERO] 
                                                                                
The MIT License                                                                 
                                                                                
Copyright: Copyright (C) 2010 T2Ti.COM                                          
                                                                                
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
unit NfeNumeroController;

{$MODE Delphi}

interface

uses
  Classes, Dialogs, SysUtils, DB, LCLIntf, LCLType, LMessages, Forms, Controller,
  NfeNumeroVO, Generics.Collections;


type
  TNfeNumeroController = class(TController)
  private
  public
    class function Consulta(pFiltro: String; pPagina: String): TZQuery; overload;
    class function ConsultaObjeto(pFiltro: String): TNfeNumeroVO;

  end;

implementation

uses UDataModule, T2TiORM;

var
  ObjetoLocal: TNfeNumeroVO;

class function TNfeNumeroController.Consulta(pFiltro: String; pPagina: String): TZQuery;
begin
  try
    ObjetoLocal := TNfeNumeroVO.Create;
    Result := TT2TiORM.Consultar(ObjetoLocal, pFiltro, pPagina);
  finally
    ObjetoLocal.Free;
  end;
end;

class function TNfeNumeroController.ConsultaObjeto(pFiltro: String): TNfeNumeroVO;
var
  UltimoID: Integer;
begin
  try
    if TT2TiORM.SelectMax('NFE_NUMERO', pFiltro) = -1 then
    begin
      Result := TNfeNumeroVO.Create;
      Result.Serie := '001';
      Result.Numero := 1;
      Result.IdEmpresa := 1;
      UltimoID := TT2TiORM.Inserir(Result);
    Result := TNfeNumeroVO.Create;
    Result := TNfeNumeroVO(TT2TiORM.ConsultarUmObjeto(Result, pFiltro, True));
    end
    else
    begin
      TT2TiORM.ComandoSQL('update NFE_NUMERO set NUMERO = NUMERO + 1');
    Result := TNfeNumeroVO.Create;
    Result := TNfeNumeroVO(TT2TiORM.ConsultarUmObjeto(Result, pFiltro, True));
    end;
  finally
  end;
end;

initialization
  Classes.RegisterClass(TNfeNumeroController);

finalization
  Classes.UnRegisterClass(TNfeNumeroController);

end.

