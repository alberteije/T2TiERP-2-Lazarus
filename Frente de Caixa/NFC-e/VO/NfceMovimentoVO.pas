{*******************************************************************************
Title: T2Ti ERP                                                                 
Description:  VO  relacionado à tabela [NFCE_MOVIMENTO] 
                                                                                
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
unit NfceMovimentoVO;

{$mode objfpc}{$H+}

interface

uses
  VO, Classes, SysUtils, FGL,
  NfceCaixaVO, EmpresaVO, NfceTurnoVO, NfceOperadorVO,
  NfceFechamentoVO, NfceSuprimentoVO, NfceSangriaVO;

type
  TNfceMovimentoVO = class(TVO)
  private
    FID: Integer;
    FID_NFCE_CAIXA: Integer;
    FID_NFCE_OPERADOR: Integer;
    FID_NFCE_TURNO: Integer;
    FID_EMPRESA: Integer;
    FID_GERENTE_SUPERVISOR: Integer;
    FDATA_ABERTURA: TDateTime;
    FHORA_ABERTURA: String;
    FDATA_FECHAMENTO: TDateTime;
    FHORA_FECHAMENTO: String;
    FTOTAL_SUPRIMENTO: Extended;
    FTOTAL_SANGRIA: Extended;
    FTOTAL_NAO_FISCAL: Extended;
    FTOTAL_VENDA: Extended;
    FTOTAL_DESCONTO: Extended;
    FTOTAL_ACRESCIMO: Extended;
    FTOTAL_FINAL: Extended;
    FTOTAL_RECEBIDO: Extended;
    FTOTAL_TROCO: Extended;
    FTOTAL_CANCELADO: Extended;
    FSTATUS_MOVIMENTO: String;

    FNfceCaixaVO: TNfceCaixaVO;
    FEmpresaVO: TEmpresaVO;
    FNfceTurnoVO: TNfceTurnoVO;
    FNfceOperadorVO: TNfceOperadorVO;
    FNfceGerenteVO: TNfceOperadorVO;

    FListaNfceFechamentoVO: TListaNfceFechamentoVO;
    FListaNfceSuprimentoVO: TListaNfceSuprimentoVO;
    FListaNfceSangriaVO: TListaNfceSangriaVO;

  published
    constructor Create; override;
    destructor Destroy; override;

    property Id: Integer  read FID write FID;
    property IdNfceCaixa: Integer  read FID_NFCE_CAIXA write FID_NFCE_CAIXA;
    property IdNfceOperador: Integer  read FID_NFCE_OPERADOR write FID_NFCE_OPERADOR;
    property IdNfceTurno: Integer  read FID_NFCE_TURNO write FID_NFCE_TURNO;
    property IdEmpresa: Integer  read FID_EMPRESA write FID_EMPRESA;
    property IdGerenteSupervisor: Integer  read FID_GERENTE_SUPERVISOR write FID_GERENTE_SUPERVISOR;
    property DataAbertura: TDateTime  read FDATA_ABERTURA write FDATA_ABERTURA;
    property HoraAbertura: String  read FHORA_ABERTURA write FHORA_ABERTURA;
    property DataFechamento: TDateTime  read FDATA_FECHAMENTO write FDATA_FECHAMENTO;
    property HoraFechamento: String  read FHORA_FECHAMENTO write FHORA_FECHAMENTO;
    property TotalSuprimento: Extended  read FTOTAL_SUPRIMENTO write FTOTAL_SUPRIMENTO;
    property TotalSangria: Extended  read FTOTAL_SANGRIA write FTOTAL_SANGRIA;
    property TotalNaoFiscal: Extended  read FTOTAL_NAO_FISCAL write FTOTAL_NAO_FISCAL;
    property TotalVenda: Extended  read FTOTAL_VENDA write FTOTAL_VENDA;
    property TotalDesconto: Extended  read FTOTAL_DESCONTO write FTOTAL_DESCONTO;
    property TotalAcrescimo: Extended  read FTOTAL_ACRESCIMO write FTOTAL_ACRESCIMO;
    property TotalFinal: Extended  read FTOTAL_FINAL write FTOTAL_FINAL;
    property TotalRecebido: Extended  read FTOTAL_RECEBIDO write FTOTAL_RECEBIDO;
    property TotalTroco: Extended  read FTOTAL_TROCO write FTOTAL_TROCO;
    property TotalCancelado: Extended  read FTOTAL_CANCELADO write FTOTAL_CANCELADO;
    property StatusMovimento: String  read FSTATUS_MOVIMENTO write FSTATUS_MOVIMENTO;

    property NfceCaixaVO: TNfceCaixaVO read FNfceCaixaVO write FNfceCaixaVO;
    property EmpresaVO: TEmpresaVO read FEmpresaVO write FEmpresaVO;
    property NfceTurnoVO: TNfceTurnoVO read FNfceTurnoVO write FNfceTurnoVO;
    property NfceOperadorVO: TNfceOperadorVO read FNfceOperadorVO write FNfceOperadorVO;
    property NfceGerenteVO: TNfceOperadorVO read FNfceGerenteVO write FNfceGerenteVO;

    property ListaNfceFechamentoVO: TListaNfceFechamentoVO read FListaNfceFechamentoVO write FListaNfceFechamentoVO;
    property ListaNfceSuprimentoVO: TListaNfceSuprimentoVO read FListaNfceSuprimentoVO write FListaNfceSuprimentoVO;
    property ListaNfceSangriaVO: TListaNfceSangriaVO read FListaNfceSangriaVO write FListaNfceSangriaVO;
  end;

  TListaNfceMovimentoVO = specialize TFPGObjectList<TNfceMovimentoVO>;

implementation

constructor TNfceMovimentoVO.Create;
begin
  inherited;

  FNfceCaixaVO := TNfceCaixaVO.Create;
  FEmpresaVO := TEmpresaVO.Create;
  FNfceTurnoVO := TNfceTurnoVO.Create;
  FNfceOperadorVO := TNfceOperadorVO.Create;
  FNfceGerenteVO := TNfceOperadorVO.Create;

  FListaNfceFechamentoVO := TListaNfceFechamentoVO.Create;
  FListaNfceSuprimentoVO := TListaNfceSuprimentoVO.Create;
  FListaNfceSangriaVO := TListaNfceSangriaVO.Create;
end;

destructor TNfceMovimentoVO.Destroy;
begin
  FreeAndNil(FNfceCaixaVO);
  FreeAndNil(FEmpresaVO);
  FreeAndNil(FNfceTurnoVO);
  FreeAndNil(FNfceOperadorVO);
  FreeAndNil(FNfceGerenteVO);

  FreeAndNil(FListaNfceFechamentoVO);
  FreeAndNil(FListaNfceSuprimentoVO);
  FreeAndNil(FListaNfceSangriaVO);

  inherited;
end;


initialization
  Classes.RegisterClass(TNfceMovimentoVO);

finalization
  Classes.UnRegisterClass(TNfceMovimentoVO);

end.
