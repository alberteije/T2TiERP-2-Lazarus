{*******************************************************************************
Title: T2Ti ERP                                                                 
Description: Controller do lado Transportadora relacionado à tabela [VIEW_PESSOA_TRANSPORTADORA] 
                                                                                
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
@version 2.0
*******************************************************************************}
unit ViewPessoaTransportadoraController;

{$MODE Delphi}

interface

uses
  Classes, Dialogs, SysUtils, DB, LCLIntf, LCLType, LMessages, Forms, Controller,
  ViewPessoaTransportadoraVO, ZDataSet;


type
  TViewPessoaTransportadoraController = class(TController)
  private
  public
    class function Consulta(pFiltro: String; pPagina: String): TZQuery;
    class function ConsultaLista(pFiltro: String): TListaViewPessoaTransportadoraVO;
    class function ConsultaObjeto(pFiltro: String): TViewPessoaTransportadoraVO;

  end;

implementation

uses UDataModule, T2TiORM;

var
  ObjetoLocal: TViewPessoaTransportadoraVO;

class function TViewPessoaTransportadoraController.Consulta(pFiltro: String; pPagina: String): TZQuery;
begin
  try
    ObjetoLocal := TViewPessoaTransportadoraVO.Create;
    Result := TT2TiORM.Consultar(ObjetoLocal, pFiltro, pPagina);
  finally
    ObjetoLocal.Free;
  end;
end;

class function TViewPessoaTransportadoraController.ConsultaLista(pFiltro: String): TListaViewPessoaTransportadoraVO;
begin
  try
    ObjetoLocal := TViewPessoaTransportadoraVO.Create;
    Result := TListaViewPessoaTransportadoraVO(TT2TiORM.Consultar(ObjetoLocal, pFiltro, True));
  finally
    ObjetoLocal.Free;
  end;
end;

class function TViewPessoaTransportadoraController.ConsultaObjeto(pFiltro: String): TViewPessoaTransportadoraVO;
begin
  try
    Result := TViewPessoaTransportadoraVO.Create;
    Result := TViewPessoaTransportadoraVO(TT2TiORM.ConsultarUmObjeto(Result, pFiltro, True));
  finally
  end;
end;

initialization
  Classes.RegisterClass(TViewPessoaTransportadoraController);

finalization
  Classes.UnRegisterClass(TViewPessoaTransportadoraController);

end.

