{*******************************************************************************
Title: T2Ti ERP                                                                 
Description:  VO  relacionado à tabela [ECF_MOVIMENTO] 
                                                                                
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
unit EcfMovimentoVO;

{$mode objfpc}{$H+}

interface

uses
  VO, Classes, SysUtils, FGL,
  EcfImpressoraVO, EcfCaixaVO, EcfEmpresaVO, EcfTurnoVO, EcfOperadorVO,
  EcfFechamentoVO, EcfSuprimentoVO, EcfSangriaVO, EcfDocumentosEmitidosVO,
  EcfRecebimentoNaoFiscalVO;

type
  TEcfMovimentoVO = class(TVO)
  private
    FID: Integer;
    FID_ECF_EMPRESA: Integer;
    FID_ECF_TURNO: Integer;
    FID_ECF_IMPRESSORA: Integer;
    FID_ECF_OPERADOR: Integer;
    FID_ECF_CAIXA: Integer;
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

    FNOME_CAIXA: String;
    FID_GERADO_CAIXA: Integer;
    FDATA_SINCRONIZACAO: TDateTime;
    FHORA_SINCRONIZACAO: String;

    FEcfImpressoraVO: TEcfImpressoraVO;
    FEcfCaixaVO: TEcfCaixaVO;
    FEcfEmpresaVO: TEcfEmpresaVO;
    FEcfTurnoVO: TEcfTurnoVO;
    FEcfOperadorVO: TEcfOperadorVO;
    FEcfGerenteVO: TEcfOperadorVO;

    FListaEcfFechamentoVO: TListaEcfFechamentoVO;
    FListaEcfSuprimentoVO: TListaEcfSuprimentoVO;
    FListaEcfSangriaVO: TListaEcfSangriaVO;
    FListaEcfDocumentosEmitidosVO: TListaEcfDocumentosEmitidosVO;
    FListaEcfRecebimentoNaoFiscalVO: TListaEcfRecebimentoNaoFiscalVO;

  published
    constructor Create; override;
    destructor Destroy; override;

    property Id: Integer  read FID write FID;
    property IdEcfEmpresa: Integer  read FID_ECF_EMPRESA write FID_ECF_EMPRESA;
    property IdEcfTurno: Integer  read FID_ECF_TURNO write FID_ECF_TURNO;
    property IdEcfImpressora: Integer  read FID_ECF_IMPRESSORA write FID_ECF_IMPRESSORA;
    property IdEcfOperador: Integer  read FID_ECF_OPERADOR write FID_ECF_OPERADOR;
    property IdEcfCaixa: Integer  read FID_ECF_CAIXA write FID_ECF_CAIXA;
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

    property NomeCaixa: String  read FNOME_CAIXA write FNOME_CAIXA;
    property IdGeradoCaixa: Integer  read FID_GERADO_CAIXA write FID_GERADO_CAIXA;
    property DataSincronizacao: TDateTime  read FDATA_SINCRONIZACAO write FDATA_SINCRONIZACAO;
    property HoraSincronizacao: String  read FHORA_SINCRONIZACAO write FHORA_SINCRONIZACAO;

    property EcfImpressoraVO: TEcfImpressoraVO read FEcfImpressoraVO write FEcfImpressoraVO;
    property EcfCaixaVO: TEcfCaixaVO read FEcfCaixaVO write FEcfCaixaVO;
    property EcfEmpresaVO: TEcfEmpresaVO read FEcfEmpresaVO write FEcfEmpresaVO;
    property EcfTurnoVO: TEcfTurnoVO read FEcfTurnoVO write FEcfTurnoVO;
    property EcfOperadorVO: TEcfOperadorVO read FEcfOperadorVO write FEcfOperadorVO;
    property EcfGerenteVO: TEcfOperadorVO read FEcfGerenteVO write FEcfGerenteVO;

    property ListaEcfFechamentoVO: TListaEcfFechamentoVO read FListaEcfFechamentoVO write FListaEcfFechamentoVO;
    property ListaEcfSuprimentoVO: TListaEcfSuprimentoVO read FListaEcfSuprimentoVO write FListaEcfSuprimentoVO;
    property ListaEcfSangriaVO: TListaEcfSangriaVO read FListaEcfSangriaVO write FListaEcfSangriaVO;
    property ListaEcfDocumentosEmitidosVO: TListaEcfDocumentosEmitidosVO read FListaEcfDocumentosEmitidosVO write FListaEcfDocumentosEmitidosVO;
    property ListaEcfRecebimentoNaoFiscalVO: TListaEcfRecebimentoNaoFiscalVO read FListaEcfRecebimentoNaoFiscalVO write FListaEcfRecebimentoNaoFiscalVO;

  end;

  TListaEcfMovimentoVO = specialize TFPGObjectList<TEcfMovimentoVO>;

implementation

constructor TEcfMovimentoVO.Create;
begin
  inherited;

  FEcfImpressoraVO := TEcfImpressoraVO.Create;
  FEcfCaixaVO := TEcfCaixaVO.Create;
  FEcfEmpresaVO := TEcfEmpresaVO.Create;
  FEcfTurnoVO := TEcfTurnoVO.Create;
  FEcfOperadorVO := TEcfOperadorVO.Create;
  FEcfGerenteVO := TEcfOperadorVO.Create;

  FListaEcfFechamentoVO := TListaEcfFechamentoVO.Create;
  FListaEcfSuprimentoVO := TListaEcfSuprimentoVO.Create;
  FListaEcfSangriaVO := TListaEcfSangriaVO.Create;
  FListaEcfDocumentosEmitidosVO := TListaEcfDocumentosEmitidosVO.Create;
  FListaEcfRecebimentoNaoFiscalVO := TListaEcfRecebimentoNaoFiscalVO.Create;
end;

destructor TEcfMovimentoVO.Destroy;
begin
  FreeAndNil(FEcfImpressoraVO);
  FreeAndNil(FEcfCaixaVO);
  FreeAndNil(FEcfEmpresaVO);
  FreeAndNil(FEcfTurnoVO);
  FreeAndNil(FEcfOperadorVO);
  FreeAndNil(FEcfGerenteVO);

  FreeAndNil(FListaEcfFechamentoVO);
  FreeAndNil(FListaEcfSuprimentoVO);
  FreeAndNil(FListaEcfSangriaVO);
  FreeAndNil(FListaEcfDocumentosEmitidosVO);
  FreeAndNil(FListaEcfRecebimentoNaoFiscalVO);

  inherited;
end;

initialization
  Classes.RegisterClass(TEcfMovimentoVO);

finalization
  Classes.UnRegisterClass(TEcfMovimentoVO);

end.
