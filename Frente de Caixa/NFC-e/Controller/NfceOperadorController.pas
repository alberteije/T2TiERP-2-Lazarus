{*******************************************************************************
Title: T2Ti ERP                                                                 
Description: Controller relacionado à tabela [NFCE_OPERADOR] 
                                                                                
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
unit NfceOperadorController;

interface

uses
  Classes, SysUtils, Windows, Forms, Controller,
  VO, NfceOperadorVO;


type
  TNfceOperadorController = class(TController)
  private
  public
    class function ConsultaLista(pFiltro: String): TListaNfceOperadorVO;
    class function ConsultaObjeto(pFiltro: String): TNfceOperadorVO;
    class function Usuario(pLogin, pSenha: String): TNfceOperadorVO;
  end;

implementation

uses T2TiORM;

var
  ObjetoLocal: TNfceOperadorVO;

class function TNfceOperadorController.ConsultaLista(pFiltro: String): TListaNfceOperadorVO;
begin
  try
    ObjetoLocal := TNfceOperadorVO.Create;
    Result := TListaNfceOperadorVO(TT2TiORM.Consultar(ObjetoLocal, pFiltro, True));
  finally
    ObjetoLocal.Free;
  end;
end;

class function TNfceOperadorController.ConsultaObjeto(pFiltro: String): TNfceOperadorVO;
begin
  try
    Result := TNfceOperadorVO.Create;
    Result := TNfceOperadorVO(TT2TiORM.ConsultarUmObjeto(Result, pFiltro, True));
  finally
  end;
end;

class function TNfceOperadorController.Usuario(pLogin, pSenha: String): TNfceOperadorVO;
var
  Filtro: String;
begin
  try
    Filtro := 'LOGIN = '+QuotedStr(pLogin)+' AND SENHA = '+QuotedStr(pSenha);
    Result := TNfceOperadorVO.Create;
    Result := TNfceOperadorVO(TT2TiORM.ConsultarUmObjeto(Result, Filtro, True));
  finally
  end;
end;

end.
