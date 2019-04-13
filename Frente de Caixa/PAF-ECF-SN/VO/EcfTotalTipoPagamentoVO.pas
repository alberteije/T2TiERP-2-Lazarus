{*******************************************************************************
Title: T2Ti ERP                                                                 
Description:  VO  relacionado à tabela [ECF_TOTAL_TIPO_PAGAMENTO] 
                                                                                
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
unit EcfTotalTipoPagamentoVO;

{$mode objfpc}{$H+}

interface

uses
  VO, Classes, SysUtils, FGL, EcfTipoPagamentoVO;

type

  { TEcfTotalTipoPagamentoVO }

  TEcfTotalTipoPagamentoVO = class(TVO)
  private
    FID: Integer;
    FID_ECF_VENDA_CABECALHO: Integer;
    FID_ECF_TIPO_PAGAMENTO: Integer;
    FSERIE_ECF: String;
    FCOO: Integer;
    FCCF: Integer;
    FGNF: Integer;
    FVALOR: Extended;
    FNSU: String;
    FESTORNO: String;
    FREDE: String;
    FCARTAO_DC: String;
    FLOGSS: String;
    FDATA_VENDA: TDateTime;

    FEcfTipoPagamentoVO: TEcfTipoPagamentoVO;

  public
    function Clone: TEcfTotalTipoPagamentoVO;
  published
    constructor Create; override;
    destructor Destroy; override;

    property Id: Integer  read FID write FID;
    property IdEcfVendaCabecalho: Integer  read FID_ECF_VENDA_CABECALHO write FID_ECF_VENDA_CABECALHO;
    property IdEcfTipoPagamento: Integer  read FID_ECF_TIPO_PAGAMENTO write FID_ECF_TIPO_PAGAMENTO;
    property SerieEcf: String  read FSERIE_ECF write FSERIE_ECF;
    property Coo: Integer  read FCOO write FCOO;
    property Ccf: Integer  read FCCF write FCCF;
    property Gnf: Integer  read FGNF write FGNF;
    property Valor: Extended  read FVALOR write FVALOR;
    property Nsu: String  read FNSU write FNSU;
    property Estorno: String  read FESTORNO write FESTORNO;
    property Rede: String  read FREDE write FREDE;
    property CartaoDc: String  read FCARTAO_DC write FCARTAO_DC;
    property HashRegistro: String  read FLOGSS write FLOGSS;
    property DataVenda: TDateTime  read FDATA_VENDA write FDATA_VENDA;

    property EcfTipoPagamentoVO: TEcfTipoPagamentoVO read FEcfTipoPagamentoVO write FEcfTipoPagamentoVO;

  end;

  TListaEcfTotalTipoPagamentoVO = specialize TFPGObjectList<TEcfTotalTipoPagamentoVO>;

implementation

function TEcfTotalTipoPagamentoVO.Clone: TEcfTotalTipoPagamentoVO;
begin
  Result := TEcfTotalTipoPagamentoVO.Create;
  with Result do begin
    Id := Self.FID;
    IdEcfVendaCabecalho := Self.FID_ECF_VENDA_CABECALHO;
    IdEcfTipoPagamento := Self.FID_ECF_TIPO_PAGAMENTO;
    SerieEcf := Self.FSERIE_ECF;
    Coo := Self.FCOO;
    Ccf := Self.FCCF;
    Gnf := Self.FGNF;
    Valor := Self.FVALOR;
    Nsu := Self.FNSU;
    Estorno := Self.FESTORNO;
    Rede := Self.FREDE;
    CartaoDc := Self.FCARTAO_DC;
    HashRegistro := Self.FLOGSS;
    DataVenda := Self.FDATA_VENDA;
  end;
end;

constructor TEcfTotalTipoPagamentoVO.Create;
begin
  inherited;
  FEcfTipoPagamentoVO := TEcfTipoPagamentoVO.Create;
end;

destructor TEcfTotalTipoPagamentoVO.Destroy;
begin
  FreeAndNil(FEcfTipoPagamentoVO);
  inherited;
end;


initialization
  Classes.RegisterClass(TEcfTotalTipoPagamentoVO);

finalization
  Classes.UnRegisterClass(TEcfTotalTipoPagamentoVO);

end.
