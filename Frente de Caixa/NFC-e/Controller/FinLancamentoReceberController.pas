{*******************************************************************************
Title: T2Ti ERP                                                                 
Description: Controller relacionado à tabela [FIN_LANCAMENTO_RECEBER] 
                                                                                
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
unit FinLancamentoReceberController;

interface

uses
  Classes, SysUtils, Windows, Forms, Controller,
  VO, FinLancamentoReceberVO;


type
  TFinLancamentoReceberController = class(TController)
  private
  public
    class procedure Insere(pObjeto: TFinLancamentoReceberVO);
    class function Altera(pObjeto: TFinLancamentoReceberVO): Boolean;
    class function Exclui(pId: Integer): Boolean;
  end;

implementation

uses T2TiORM;

var
  ObjetoLocal: TFinLancamentoReceberVO;

class procedure TFinLancamentoReceberController.Insere(pObjeto: TFinLancamentoReceberVO);
var
  UltimoID, I: Integer;
begin
  try
    UltimoID := TT2TiORM.Inserir(pObjeto);

    // Detalhes
    for I := 0 to pObjeto.ListaParcelaReceberVO.Count - 1 do
    begin
      pObjeto.ListaParcelaReceberVO[I].IdFinLancamentoReceber := UltimoID;
      TT2TiORM.Inserir(pObjeto.ListaParcelaReceberVO[I])
    end;

  finally
  end;
end;

class function TFinLancamentoReceberController.Altera(pObjeto: TFinLancamentoReceberVO): Boolean;
begin
  try
    Result := TT2TiORM.Alterar(pObjeto);
  finally
  end;
end;

class function TFinLancamentoReceberController.Exclui(pId: Integer): Boolean;
begin
  try
    ObjetoLocal := TFinLancamentoReceberVO.Create;
    ObjetoLocal.Id := pId;
    Result := TT2TiORM.Excluir(ObjetoLocal);
  finally
    FreeAndNil(ObjetoLocal);
  end;
end;

end.
