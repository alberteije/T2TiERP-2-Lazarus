{*******************************************************************************
Title: T2Ti ERP                                                                 
Description: Controller relacionado à tabela [ECF_FUNCIONARIO] 
                                                                                
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
unit EcfFuncionarioController;

interface

uses
  Classes, SysUtils, Windows, Forms, Controller,
  VO, EcfFuncionarioVO, EcfOperadorVO;


type
  TEcfFuncionarioController = class(TController)
  private
  public
    class function ConsultaLista(pFiltro: String): TListaEcfFuncionarioVO;
    class function ConsultaObjeto(pFiltro: String): TEcfFuncionarioVO;
    class function Usuario(pLogin, pSenha: String): TEcfOperadorVO;
  end;

implementation

uses T2TiORM;

var
  ObjetoLocal: TEcfFuncionarioVO;

class function TEcfFuncionarioController.ConsultaLista(pFiltro: String): TListaEcfFuncionarioVO;
begin
  try
    ObjetoLocal := TEcfFuncionarioVO.Create;
    Result := TListaEcfFuncionarioVO(TT2TiORM.Consultar(ObjetoLocal, pFiltro, True));
  finally
    ObjetoLocal.Free;
  end;
end;

class function TEcfFuncionarioController.ConsultaObjeto(pFiltro: String): TEcfFuncionarioVO;
begin
  try
    Result := TEcfFuncionarioVO.Create;
    Result := TEcfFuncionarioVO(TT2TiORM.ConsultarUmObjeto(Result, pFiltro, True));
  finally
  end;
end;

class function TEcfFuncionarioController.Usuario(pLogin, pSenha: String): TEcfOperadorVO;
var
  Filtro: String;
begin
  try
    Filtro := 'LOGIN = '+QuotedStr(pLogin)+' AND SENHA = '+QuotedStr(pSenha);
    Result := TEcfOperadorVO.Create;
    Result := TEcfOperadorVO(TT2TiORM.ConsultarUmObjeto(Result, Filtro, True));

    //Exercício: crie o método para popular esses objetos automaticamente no T2TiORM
    if Assigned(Result) then
      Result.EcfFuncionarioVO := TEcfFuncionarioVO(TT2TiORM.ConsultarUmObjeto(Result.EcfFuncionarioVO, 'ID='+IntToStr(Result.IdEcfFuncionario), True));
  finally
  end;
end;

end.
