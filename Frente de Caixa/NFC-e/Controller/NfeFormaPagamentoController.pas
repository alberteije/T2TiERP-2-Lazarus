{*******************************************************************************
Title: T2Ti ERP                                                                 
Description: Controller relacionado à tabela [NFE_FORMA_PAGAMENTO] 
                                                                                
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
unit NfeFormaPagamentoController;

interface

uses
  Classes, SysUtils, Windows, Forms, Controller, md5,
  VO, NfeFormaPagamentoVO, Biblioteca;


type
  TNfeFormaPagamentoController = class(TController)
  private
  public
    class function ConsultaLista(pFiltro: String): TListaNfeFormaPagamentoVO;
    class procedure Insere(pObjeto: TNfeFormaPagamentoVO);
    class procedure InsereLista(pListaObjetos: TListaNfeFormaPagamentoVO);
    class function Altera(pObjeto: TNfeFormaPagamentoVO): Boolean;
    class function Exclui(pId: Integer): Boolean;
  end;

implementation

uses T2TiORM;

var
  ObjetoLocal: TNfeFormaPagamentoVO;

class function TNfeFormaPagamentoController.ConsultaLista(pFiltro: String): TListaNfeFormaPagamentoVO;
begin
  try
    ObjetoLocal := TNfeFormaPagamentoVO.Create;
    Result := TListaNfeFormaPagamentoVO(TT2TiORM.Consultar(ObjetoLocal, pFiltro, True));
  finally
    ObjetoLocal.Free;
  end;
end;

class procedure TNfeFormaPagamentoController.Insere(pObjeto: TNfeFormaPagamentoVO);
var
  UltimoID: Integer;
begin
  try
    UltimoID := TT2TiORM.Inserir(pObjeto);
  finally
  end;
end;

class procedure TNfeFormaPagamentoController.InsereLista(pListaObjetos: TListaNfeFormaPagamentoVO);
var
  I: Integer;
  UltimoID: Integer;
begin
  try

    for I := 0 to pListaObjetos.Count - 1 do
    begin
      UltimoID := TT2TiORM.Inserir(pListaObjetos[I]);
    end;

  finally
  end;
end;

class function TNfeFormaPagamentoController.Altera(pObjeto: TNfeFormaPagamentoVO): Boolean;
begin
  try
    Result := TT2TiORM.Alterar(pObjeto);
  finally
  end;
end;

class function TNfeFormaPagamentoController.Exclui(pId: Integer): Boolean;
begin
  try
    ObjetoLocal := TNfeFormaPagamentoVO.Create;
    ObjetoLocal.Id := pId;
    Result := TT2TiORM.Excluir(ObjetoLocal);
  finally
    FreeAndNil(ObjetoLocal);
  end;
end;

end.
