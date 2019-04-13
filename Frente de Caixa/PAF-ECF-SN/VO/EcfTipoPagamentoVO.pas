{*******************************************************************************
Title: T2Ti ERP                                                                 
Description:  VO  relacionado à tabela [ECF_TIPO_PAGAMENTO] 
                                                                                
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
unit EcfTipoPagamentoVO;

{$mode objfpc}{$H+}

interface

uses
  VO, Classes, SysUtils, FGL;

type

  { TEcfTipoPagamentoVO }

  TEcfTipoPagamentoVO = class(TVO)
  private
    FID: Integer;
    FCODIGO: String;
    FDESCRICAO: String;
    FTEF: String;
    FIMPRIME_VINCULADO: String;
    FPERMITE_TROCO: String;
    FTEF_TIPO_GP: String;
    FGERA_PARCELAS: String;

  public
    function Clone: TEcfTipoPagamentoVO;
  published 
    property Id: Integer  read FID write FID;
    property Codigo: String  read FCODIGO write FCODIGO;
    property Descricao: String  read FDESCRICAO write FDESCRICAO;
    property Tef: String  read FTEF write FTEF;
    property ImprimeVinculado: String  read FIMPRIME_VINCULADO write FIMPRIME_VINCULADO;
    property PermiteTroco: String  read FPERMITE_TROCO write FPERMITE_TROCO;
    property TefTipoGp: String  read FTEF_TIPO_GP write FTEF_TIPO_GP;
    property GeraParcelas: String  read FGERA_PARCELAS write FGERA_PARCELAS;

  end;

  TListaEcfTipoPagamentoVO = specialize TFPGObjectList<TEcfTipoPagamentoVO>;

implementation


{ TEcfTipoPagamentoVO }

function TEcfTipoPagamentoVO.Clone: TEcfTipoPagamentoVO;
begin
  Result := TEcfTipoPagamentoVO.Create;
  with Result do begin
    Id := Self.FID;
    Codigo := Self.FCODIGO;
    Descricao := Self.FDESCRICAO;
    Tef := Self.FTEF;
    ImprimeVinculado := Self.FIMPRIME_VINCULADO;
    PermiteTroco := Self.FPERMITE_TROCO;
    TefTipoGp := Self.FTEF_TIPO_GP;
    GeraParcelas := Self.FGERA_PARCELAS;
  end;
end;

initialization
  Classes.RegisterClass(TEcfTipoPagamentoVO);

finalization
  Classes.UnRegisterClass(TEcfTipoPagamentoVO);

end.
