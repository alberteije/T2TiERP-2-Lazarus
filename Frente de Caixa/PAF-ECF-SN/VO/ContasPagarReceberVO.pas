{*******************************************************************************
Title: T2Ti ERP                                                                 
Description:  VO  relacionado à tabela [CONTAS_PAGAR_RECEBER] 
                                                                                
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
unit ContasPagarReceberVO;

{$mode objfpc}{$H+}

interface

uses
  VO, Classes, SysUtils, FGL;

type
  TContasPagarReceberVO = class(TVO)
  private
    FID: Integer;
    FID_ECF_VENDA_CABECALHO: Integer;
    FID_PLANO_CONTAS: Integer;
    FID_TIPO_DOCUMENTO: Integer;
    FID_PESSOA: Integer;
    FTIPO: String;
    FNUMERO_DOCUMENTO: String;
    FVALOR: Extended;
    FDATA_LANCAMENTO: TDateTime;
    FPRIMEIRO_VENCIMENTO: TDateTime;
    FNATUREZA_LANCAMENTO: String;
    FQUANTIDADE_PARCELA: Integer;
    FCODIGO_TIPO_PAGAMENTO: String;

  published 
    property Id: Integer  read FID write FID;
    property IdEcfVendaCabecalho: Integer  read FID_ECF_VENDA_CABECALHO write FID_ECF_VENDA_CABECALHO;
    property IdPlanoContas: Integer  read FID_PLANO_CONTAS write FID_PLANO_CONTAS;
    property IdTipoDocumento: Integer  read FID_TIPO_DOCUMENTO write FID_TIPO_DOCUMENTO;
    property IdPessoa: Integer  read FID_PESSOA write FID_PESSOA;
    property Tipo: String  read FTIPO write FTIPO;
    property NumeroDocumento: String  read FNUMERO_DOCUMENTO write FNUMERO_DOCUMENTO;
    property Valor: Extended  read FVALOR write FVALOR;
    property DataLancamento: TDateTime  read FDATA_LANCAMENTO write FDATA_LANCAMENTO;
    property PrimeiroVencimento: TDateTime  read FPRIMEIRO_VENCIMENTO write FPRIMEIRO_VENCIMENTO;
    property NaturezaLancamento: String  read FNATUREZA_LANCAMENTO write FNATUREZA_LANCAMENTO;
    property QuantidadeParcela: Integer  read FQUANTIDADE_PARCELA write FQUANTIDADE_PARCELA;
    property CodigoTipoPagamento: String  read FCODIGO_TIPO_PAGAMENTO write FCODIGO_TIPO_PAGAMENTO;

  end;

  TListaContasPagarReceberVO = specialize TFPGObjectList<TContasPagarReceberVO>;

implementation


initialization
  Classes.RegisterClass(TContasPagarReceberVO);

finalization
  Classes.UnRegisterClass(TContasPagarReceberVO);

end.
