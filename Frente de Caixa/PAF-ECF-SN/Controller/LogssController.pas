{*******************************************************************************
Title: T2Ti ERP                                                                 
Description: Controller relacionado à tabela [LOGSS] 
                                                                                
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
unit LogssController;

interface

uses
  Classes, SysUtils, Windows, Forms, Controller,
  VO, LogssVO;


type
  TLogssController = class(TController)
  private
  public
    class function VerificarQuantidades: Boolean;
    class procedure AtualizarQuantidades;
    class function Altera(pObjeto: TLogssVO): Boolean;
  end;

implementation

uses T2TiORM;

class function TLogssController.VerificarQuantidades: Boolean;
var
  ObjetoLocal: TLogssVO;
  Retorno: Boolean;
  TotalProduto, TotalTTP, TotalR01, TotalR02, TotalR03, TotalR04, TotalR05, TotalR06, TotalR07: Integer;
begin
  try
    ObjetoLocal := TLogssVO.Create;
    ObjetoLocal := TLogssVO(TT2TiORM.ConsultarUmObjeto(ObjetoLocal, 'ID=1', True));

    TotalProduto := TT2TiORM.SelectCount('PRODUTO');
    TotalTTP := TT2TiORM.SelectCount('ECF_TOTAL_TIPO_PAGAMENTO');
    TotalR01 := TT2TiORM.SelectCount('R01');
    TotalR02 := TT2TiORM.SelectCount('R02');
    TotalR03 := TT2TiORM.SelectCount('R03');
    TotalR04 := TT2TiORM.SelectCount('ECF_VENDA_CABECALHO');
    TotalR05 := TT2TiORM.SelectCount('ECF_VENDA_DETALHE');
    TotalR06 := TT2TiORM.SelectCount('R06');
    TotalR07 := TT2TiORM.SelectCount('R07');

    if (TotalProduto = ObjetoLocal.Produto) and
       (TotalTTP = ObjetoLocal.Ttp) and
       (TotalR01 = ObjetoLocal.R01) and
       (TotalR02 = ObjetoLocal.R02) and
       (TotalR03 = ObjetoLocal.R03) and
       (TotalR04 = ObjetoLocal.R04) and
       (TotalR05 = ObjetoLocal.R05) and
       (TotalR06 = ObjetoLocal.R06) and
       (TotalR07 = ObjetoLocal.R07) then
       Result := True
     else
       Result := False;

  finally
    FreeAndNil(ObjetoLocal);
  end;
end;

class procedure TLogssController.AtualizarQuantidades;
var
  ObjetoLocal: TLogssVO;
  TotalProduto, TotalTTP, TotalR01, TotalR02, TotalR03, TotalR04, TotalR05, TotalR06, TotalR07: Integer;
begin
  try
    ObjetoLocal := TLogssVO.Create;
    ObjetoLocal := TLogssVO(TT2TiORM.ConsultarUmObjeto(ObjetoLocal, 'ID=1', True));

    TotalProduto := TT2TiORM.SelectCount('PRODUTO');
    TotalTTP := TT2TiORM.SelectCount('ECF_TOTAL_TIPO_PAGAMENTO');
    TotalR01 := TT2TiORM.SelectCount('R01');
    TotalR02 := TT2TiORM.SelectCount('R02');
    TotalR03 := TT2TiORM.SelectCount('R03');
    TotalR04 := TT2TiORM.SelectCount('ECF_VENDA_CABECALHO');
    TotalR05 := TT2TiORM.SelectCount('ECF_VENDA_DETALHE');
    TotalR06 := TT2TiORM.SelectCount('R06');
    TotalR07 := TT2TiORM.SelectCount('R07');

    if not Assigned(ObjetoLocal) then
      ObjetoLocal := TLogssVO.Create;

    ObjetoLocal.Produto := TotalProduto;
    ObjetoLocal.Ttp := TotalTTP;
    ObjetoLocal.R01 := TotalR01;
    ObjetoLocal.R02 := TotalR02;
    ObjetoLocal.R03 := TotalR03;
    ObjetoLocal.R04 := TotalR04;
    ObjetoLocal.R05 := TotalR05;
    ObjetoLocal.R06 := TotalR06;
    ObjetoLocal.R07 := TotalR07;

    if ObjetoLocal.Id > 0 then
      TT2TiORM.Alterar(ObjetoLocal)
    else
      TT2TiORM.Inserir(ObjetoLocal);
  finally
    FreeAndNil(ObjetoLocal);
  end;
end;

class function TLogssController.Altera(pObjeto: TLogssVO): Boolean;
begin
  try
    Result := TT2TiORM.Alterar(pObjeto);
  finally
  end;
end;

end.
