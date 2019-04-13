{*******************************************************************************
Title: T2Ti ERP                                                                 
Description:  VO  relacionado à tabela [NOTA_FISCAL_DETALHE] 
                                                                                
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
unit NotaFiscalDetalheVO;

{$mode objfpc}{$H+}

interface

uses
  VO, Classes, SysUtils, FGL;

type
  TNotaFiscalDetalheVO = class(TVO)
  private
    FID: Integer;
    FID_NF_CABECALHO: Integer;
    FID_PRODUTO: Integer;
    FCFOP: Integer;
    FITEM: Integer;
    FQUANTIDADE: Extended;
    FVALOR_UNITARIO: Extended;
    FVALOR_TOTAL: Extended;
    FBASE_ICMS: Extended;
    FTAXA_ICMS: Extended;
    FICMS: Extended;
    FICMS_OUTRAS: Extended;
    FICMS_ISENTO: Extended;
    FTAXA_DESCONTO: Extended;
    FDESCONTO: Extended;
    FTAXA_ISSQN: Extended;
    FISSQN: Extended;
    FTAXA_PIS: Extended;
    FPIS: Extended;
    FTAXA_COFINS: Extended;
    FCOFINS: Extended;
    FTAXA_ACRESCIMO: Extended;
    FACRESCIMO: Extended;
    FTAXA_IPI: Extended;
    FIPI: Extended;
    FCANCELADO: String;
    FCST: String;
    FMOVIMENTA_ESTOQUE: String;
    FECF_ICMS_ST: String;

  published 
    property Id: Integer  read FID write FID;
    property IdNfCabecalho: Integer  read FID_NF_CABECALHO write FID_NF_CABECALHO;
    property IdProduto: Integer  read FID_PRODUTO write FID_PRODUTO;
    property Cfop: Integer  read FCFOP write FCFOP;
    property Item: Integer  read FITEM write FITEM;
    property Quantidade: Extended  read FQUANTIDADE write FQUANTIDADE;
    property ValorUnitario: Extended  read FVALOR_UNITARIO write FVALOR_UNITARIO;
    property ValorTotal: Extended  read FVALOR_TOTAL write FVALOR_TOTAL;
    property BaseIcms: Extended  read FBASE_ICMS write FBASE_ICMS;
    property TaxaIcms: Extended  read FTAXA_ICMS write FTAXA_ICMS;
    property Icms: Extended  read FICMS write FICMS;
    property IcmsOutras: Extended  read FICMS_OUTRAS write FICMS_OUTRAS;
    property IcmsIsento: Extended  read FICMS_ISENTO write FICMS_ISENTO;
    property TaxaDesconto: Extended  read FTAXA_DESCONTO write FTAXA_DESCONTO;
    property Desconto: Extended  read FDESCONTO write FDESCONTO;
    property TaxaIssqn: Extended  read FTAXA_ISSQN write FTAXA_ISSQN;
    property Issqn: Extended  read FISSQN write FISSQN;
    property TaxaPis: Extended  read FTAXA_PIS write FTAXA_PIS;
    property Pis: Extended  read FPIS write FPIS;
    property TaxaCofins: Extended  read FTAXA_COFINS write FTAXA_COFINS;
    property Cofins: Extended  read FCOFINS write FCOFINS;
    property TaxaAcrescimo: Extended  read FTAXA_ACRESCIMO write FTAXA_ACRESCIMO;
    property Acrescimo: Extended  read FACRESCIMO write FACRESCIMO;
    property TaxaIpi: Extended  read FTAXA_IPI write FTAXA_IPI;
    property Ipi: Extended  read FIPI write FIPI;
    property Cancelado: String  read FCANCELADO write FCANCELADO;
    property Cst: String  read FCST write FCST;
    property MovimentaEstoque: String  read FMOVIMENTA_ESTOQUE write FMOVIMENTA_ESTOQUE;
    property EcfIcmsSt: String  read FECF_ICMS_ST write FECF_ICMS_ST;

  end;

  TListaNotaFiscalDetalheVO = specialize TFPGObjectList<TNotaFiscalDetalheVO>;

implementation


initialization
  Classes.RegisterClass(TNotaFiscalDetalheVO);

finalization
  Classes.UnRegisterClass(TNotaFiscalDetalheVO);

end.
