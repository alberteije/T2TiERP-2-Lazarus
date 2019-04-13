{*******************************************************************************
Title: T2Ti ERP                                                                 
Description: Controller relacionado à tabela [ECF_TOTAL_TIPO_PAGAMENTO] 
                                                                                
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
unit EcfTotalTipoPagamentoController;

interface

uses
  Classes, SysUtils, Windows, Forms, Controller, md5,
  VO, EcfTotalTipoPagamentoVO, Biblioteca;


type
  TEcfTotalTipoPagamentoController = class(TController)
  private
  public
    class function ConsultaLista(pFiltro: String): TListaEcfTotalTipoPagamentoVO;
    class procedure Insere(pObjeto: TEcfTotalTipoPagamentoVO);
    class procedure InsereLista(pListaObjetos: TListaEcfTotalTipoPagamentoVO);
    class function Altera(pObjeto: TEcfTotalTipoPagamentoVO): Boolean;
    class function Exclui(pId: Integer): Boolean;
  end;

implementation

uses T2TiORM;

var
  ObjetoLocal: TEcfTotalTipoPagamentoVO;

class function TEcfTotalTipoPagamentoController.ConsultaLista(pFiltro: String): TListaEcfTotalTipoPagamentoVO;
begin
  try
    ObjetoLocal := TEcfTotalTipoPagamentoVO.Create;
    Result := TListaEcfTotalTipoPagamentoVO(TT2TiORM.Consultar(ObjetoLocal, pFiltro, True));
  finally
    ObjetoLocal.Free;
  end;
end;

class procedure TEcfTotalTipoPagamentoController.Insere(pObjeto: TEcfTotalTipoPagamentoVO);
var
  UltimoID: Integer;
begin
  try
    UltimoID := TT2TiORM.Inserir(pObjeto);
  finally
  end;
end;

class procedure TEcfTotalTipoPagamentoController.InsereLista(pListaObjetos: TListaEcfTotalTipoPagamentoVO);
var
  I: Integer;
  UltimoID: Integer;
begin
  try
    DecimalSeparator := '.';

    for I := 0 to pListaObjetos.Count - 1 do
    begin
      pListaObjetos[I].DataVenda := Sessao.VendaAtual.DataVenda;
      pListaObjetos[I].HashRegistro := '0';
      pListaObjetos[I].HashRegistro := MD5Print(MD5String(pListaObjetos[I].ToJSONString));
      UltimoID := TT2TiORM.Inserir(pListaObjetos[I]);
    end;

  finally
    DecimalSeparator := ',';
  end;
end;

class function TEcfTotalTipoPagamentoController.Altera(pObjeto: TEcfTotalTipoPagamentoVO): Boolean;
begin
  try
    Result := TT2TiORM.Alterar(pObjeto);
  finally
  end;
end;

class function TEcfTotalTipoPagamentoController.Exclui(pId: Integer): Boolean;
begin
  try
    ObjetoLocal := TEcfTotalTipoPagamentoVO.Create;
    ObjetoLocal.Id := pId;
    Result := TT2TiORM.Excluir(ObjetoLocal);
  finally
    FreeAndNil(ObjetoLocal);
  end;
end;

end.
