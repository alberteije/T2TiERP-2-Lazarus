{*******************************************************************************
Title: T2Ti ERP                                                                 
Description: Controller do lado Cliente relacionado à tabela [USUARIO] 
                                                                                
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
t2ti.com@gmail.com</p>

Albert Eije (T2Ti.COM)
@version 2.0
*******************************************************************************}
unit UsuarioController;

{$MODE Delphi}

interface

uses
  Classes, Dialogs, SysUtils, DBClient, DB, Biblioteca,
  LCLIntf, LCLType, LMessages, Forms, Controller, Rtti, Atributos, UsuarioVO, Generics.Collections;

type
  TUsuarioController = class(TController)
  private
  public
    class procedure Usuario(pLogin, pSenha: String);
    class function Consulta(pFiltro: String; pPagina: String): TZQuery;
    class function CriptografarLoginSenha(pLogin, pSenha: string): string;
  end;

implementation

uses UDataModule, Conversor, T2TiORM;

var
  ObjetoLocal: TUsuarioVO;

class function TUsuarioController.Consulta(pFiltro: String; pPagina: String): TZQuery;
begin
  try
    ObjetoLocal := TUsuarioVO.Create;
    Result := TT2TiORM.Consultar(ObjetoLocal, pFiltro, pPagina);
  finally
    ObjetoLocal.Free;
  end;
end;

class procedure TUsuarioController.Usuario(pLogin, pSenha: String);
var
  Filtro: String;
  ObjetoLocal: TUsuarioVO;
begin
  try
    Filtro := 'LOGIN = '+QuotedStr(pLogin)+' AND SENHA = '+QuotedStr(CriptografarLoginSenha(pLogin, pSenha));
    ObjetoLocal := TT2TiORM.ConsultarUmObjeto<TUsuarioVO>(Filtro, True);
    //if Assigned(ObjetoLocal) then
  finally
  end;
end;

initialization
  Classes.RegisterClass(TUsuarioController);

finalization
  Classes.UnRegisterClass(TUsuarioController);

end.

