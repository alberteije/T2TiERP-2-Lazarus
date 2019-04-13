{*******************************************************************************
Title: T2Ti ERP                                                                 
Description:  VO  relacionado à tabela [NFE_CABECALHO] 
                                                                                
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
unit NfeCabecalhoVO;

{$mode objfpc}{$H+}

interface

uses
  VO, Classes, SysUtils, FGL,
  NfeDestinatarioVO, NfeDetalheVO, NfeFormaPagamentoVO;

type
  TNfeCabecalhoVO = class(TVO)
  private
    FID: Integer;
    FID_NFCE_MOVIMENTO: Integer;
    FID_VENDEDOR: Integer;
    FID_TRIBUT_OPERACAO_FISCAL: Integer;
    FID_VENDA_CABECALHO: Integer;
    FID_EMPRESA: Integer;
    FID_FORNECEDOR: Integer;
    FID_CLIENTE: Integer;
    FUF_EMITENTE: Integer;
    FCODIGO_NUMERICO: String;
    FNATUREZA_OPERACAO: String;
    FINDICADOR_FORMA_PAGAMENTO: Integer;
    FCODIGO_MODELO: String;
    FSERIE: String;
    FNUMERO: String;
    FDATA_HORA_EMISSAO: TDateTime;
    FDATA_HORA_ENTRADA_SAIDA: TDateTime;
    FTIPO_OPERACAO: Integer;
    FLOCAL_DESTINO: Integer;
    FCODIGO_MUNICIPIO: Integer;
    FFORMATO_IMPRESSAO_DANFE: Integer;
    FTIPO_EMISSAO: Integer;
    FCHAVE_ACESSO: String;
    FDIGITO_CHAVE_ACESSO: String;
    FAMBIENTE: Integer;
    FFINALIDADE_EMISSAO: Integer;
    FCONSUMIDOR_OPERACAO: Integer;
    FCONSUMIDOR_PRESENCA: Integer;
    FPROCESSO_EMISSAO: Integer;
    FVERSAO_PROCESSO_EMISSAO: String;
    FDATA_ENTRADA_CONTINGENCIA: TDateTime;
    FJUSTIFICATIVA_CONTINGENCIA: String;
    FBASE_CALCULO_ICMS: Extended;
    FVALOR_ICMS: Extended;
    FVALOR_ICMS_DESONERADO: Extended;
    FBASE_CALCULO_ICMS_ST: Extended;
    FVALOR_ICMS_ST: Extended;
    FVALOR_TOTAL_PRODUTOS: Extended;
    FVALOR_FRETE: Extended;
    FVALOR_SEGURO: Extended;
    FVALOR_DESCONTO: Extended;
    FVALOR_IMPOSTO_IMPORTACAO: Extended;
    FVALOR_IPI: Extended;
    FVALOR_PIS: Extended;
    FVALOR_COFINS: Extended;
    FVALOR_DESPESAS_ACESSORIAS: Extended;
    FVALOR_TOTAL: Extended;
    FVALOR_SERVICOS: Extended;
    FBASE_CALCULO_ISSQN: Extended;
    FVALOR_ISSQN: Extended;
    FVALOR_PIS_ISSQN: Extended;
    FVALOR_COFINS_ISSQN: Extended;
    FDATA_PRESTACAO_SERVICO: TDateTime;
    FVALOR_DEDUCAO_ISSQN: Extended;
    FOUTRAS_RETENCOES_ISSQN: Extended;
    FDESCONTO_INCONDICIONADO_ISSQN: Extended;
    FDESCONTO_CONDICIONADO_ISSQN: Extended;
    FTOTAL_RETENCAO_ISSQN: Extended;
    FREGIME_ESPECIAL_TRIBUTACAO: Integer;
    FVALOR_RETIDO_PIS: Extended;
    FVALOR_RETIDO_COFINS: Extended;
    FVALOR_RETIDO_CSLL: Extended;
    FBASE_CALCULO_IRRF: Extended;
    FVALOR_RETIDO_IRRF: Extended;
    FBASE_CALCULO_PREVIDENCIA: Extended;
    FVALOR_RETIDO_PREVIDENCIA: Extended;
    FCOMEX_UF_EMBARQUE: String;
    FCOMEX_LOCAL_EMBARQUE: String;
    FCOMEX_LOCAL_DESPACHO: String;
    FCOMPRA_NOTA_EMPENHO: String;
    FCOMPRA_PEDIDO: String;
    FCOMPRA_CONTRATO: String;
    FINFORMACOES_ADD_FISCO: String;
    FINFORMACOES_ADD_CONTRIBUINTE: String;
    FSTATUS_NOTA: Integer;
    FTROCO: Extended;

    FNfeDestinatarioVO: TNfeDestinatarioVO;
    FListaNfeDetalheVO: TListaNfeDetalheVO;
    FListaNfeFormaPagamentoVO: TListaNfeFormaPagamentoVO;

  published 
    constructor Create; override;
    destructor Destroy; override;

    property Id: Integer  read FID write FID;
    property IdNfceMovimento: Integer  read FID_NFCE_MOVIMENTO write FID_NFCE_MOVIMENTO;
    property IdVendedor: Integer  read FID_VENDEDOR write FID_VENDEDOR;
    property IdTributOperacaoFiscal: Integer  read FID_TRIBUT_OPERACAO_FISCAL write FID_TRIBUT_OPERACAO_FISCAL;
    property IdVendaCabecalho: Integer  read FID_VENDA_CABECALHO write FID_VENDA_CABECALHO;
    property IdEmpresa: Integer  read FID_EMPRESA write FID_EMPRESA;
    property IdFornecedor: Integer  read FID_FORNECEDOR write FID_FORNECEDOR;
    property IdCliente: Integer  read FID_CLIENTE write FID_CLIENTE;
    property UfEmitente: Integer  read FUF_EMITENTE write FUF_EMITENTE;
    property CodigoNumerico: String  read FCODIGO_NUMERICO write FCODIGO_NUMERICO;
    property NaturezaOperacao: String  read FNATUREZA_OPERACAO write FNATUREZA_OPERACAO;
    property IndicadorFormaPagamento: Integer  read FINDICADOR_FORMA_PAGAMENTO write FINDICADOR_FORMA_PAGAMENTO;
    property CodigoModelo: String  read FCODIGO_MODELO write FCODIGO_MODELO;
    property Serie: String  read FSERIE write FSERIE;
    property Numero: String  read FNUMERO write FNUMERO;
    property DataHoraEmissao: TDateTime  read FDATA_HORA_EMISSAO write FDATA_HORA_EMISSAO;
    property DataHoraEntradaSaida: TDateTime  read FDATA_HORA_ENTRADA_SAIDA write FDATA_HORA_ENTRADA_SAIDA;
    property TipoOperacao: Integer  read FTIPO_OPERACAO write FTIPO_OPERACAO;
    property LocalDestino: Integer  read FLOCAL_DESTINO write FLOCAL_DESTINO;
    property CodigoMunicipio: Integer  read FCODIGO_MUNICIPIO write FCODIGO_MUNICIPIO;
    property FormatoImpressaoDanfe: Integer  read FFORMATO_IMPRESSAO_DANFE write FFORMATO_IMPRESSAO_DANFE;
    property TipoEmissao: Integer  read FTIPO_EMISSAO write FTIPO_EMISSAO;
    property ChaveAcesso: String  read FCHAVE_ACESSO write FCHAVE_ACESSO;
    property DigitoChaveAcesso: String  read FDIGITO_CHAVE_ACESSO write FDIGITO_CHAVE_ACESSO;
    property Ambiente: Integer  read FAMBIENTE write FAMBIENTE;
    property FinalidadeEmissao: Integer  read FFINALIDADE_EMISSAO write FFINALIDADE_EMISSAO;
    property ConsumidorOperacao: Integer  read FCONSUMIDOR_OPERACAO write FCONSUMIDOR_OPERACAO;
    property ConsumidorPresenca: Integer  read FCONSUMIDOR_PRESENCA write FCONSUMIDOR_PRESENCA;
    property ProcessoEmissao: Integer  read FPROCESSO_EMISSAO write FPROCESSO_EMISSAO;
    property VersaoProcessoEmissao: String  read FVERSAO_PROCESSO_EMISSAO write FVERSAO_PROCESSO_EMISSAO;
    property DataEntradaContingencia: TDateTime  read FDATA_ENTRADA_CONTINGENCIA write FDATA_ENTRADA_CONTINGENCIA;
    property JustificativaContingencia: String  read FJUSTIFICATIVA_CONTINGENCIA write FJUSTIFICATIVA_CONTINGENCIA;
    property BaseCalculoIcms: Extended  read FBASE_CALCULO_ICMS write FBASE_CALCULO_ICMS;
    property ValorIcms: Extended  read FVALOR_ICMS write FVALOR_ICMS;
    property ValorIcmsDesonerado: Extended  read FVALOR_ICMS_DESONERADO write FVALOR_ICMS_DESONERADO;
    property BaseCalculoIcmsSt: Extended  read FBASE_CALCULO_ICMS_ST write FBASE_CALCULO_ICMS_ST;
    property ValorIcmsSt: Extended  read FVALOR_ICMS_ST write FVALOR_ICMS_ST;
    property ValorTotalProdutos: Extended  read FVALOR_TOTAL_PRODUTOS write FVALOR_TOTAL_PRODUTOS;
    property ValorFrete: Extended  read FVALOR_FRETE write FVALOR_FRETE;
    property ValorSeguro: Extended  read FVALOR_SEGURO write FVALOR_SEGURO;
    property ValorDesconto: Extended  read FVALOR_DESCONTO write FVALOR_DESCONTO;
    property ValorImpostoImportacao: Extended  read FVALOR_IMPOSTO_IMPORTACAO write FVALOR_IMPOSTO_IMPORTACAO;
    property ValorIpi: Extended  read FVALOR_IPI write FVALOR_IPI;
    property ValorPis: Extended  read FVALOR_PIS write FVALOR_PIS;
    property ValorCofins: Extended  read FVALOR_COFINS write FVALOR_COFINS;
    property ValorDespesasAcessorias: Extended  read FVALOR_DESPESAS_ACESSORIAS write FVALOR_DESPESAS_ACESSORIAS;
    property ValorTotal: Extended  read FVALOR_TOTAL write FVALOR_TOTAL;
    property ValorServicos: Extended  read FVALOR_SERVICOS write FVALOR_SERVICOS;
    property BaseCalculoIssqn: Extended  read FBASE_CALCULO_ISSQN write FBASE_CALCULO_ISSQN;
    property ValorIssqn: Extended  read FVALOR_ISSQN write FVALOR_ISSQN;
    property ValorPisIssqn: Extended  read FVALOR_PIS_ISSQN write FVALOR_PIS_ISSQN;
    property ValorCofinsIssqn: Extended  read FVALOR_COFINS_ISSQN write FVALOR_COFINS_ISSQN;
    property DataPrestacaoServico: TDateTime  read FDATA_PRESTACAO_SERVICO write FDATA_PRESTACAO_SERVICO;
    property ValorDeducaoIssqn: Extended  read FVALOR_DEDUCAO_ISSQN write FVALOR_DEDUCAO_ISSQN;
    property OutrasRetencoesIssqn: Extended  read FOUTRAS_RETENCOES_ISSQN write FOUTRAS_RETENCOES_ISSQN;
    property DescontoIncondicionadoIssqn: Extended  read FDESCONTO_INCONDICIONADO_ISSQN write FDESCONTO_INCONDICIONADO_ISSQN;
    property DescontoCondicionadoIssqn: Extended  read FDESCONTO_CONDICIONADO_ISSQN write FDESCONTO_CONDICIONADO_ISSQN;
    property TotalRetencaoIssqn: Extended  read FTOTAL_RETENCAO_ISSQN write FTOTAL_RETENCAO_ISSQN;
    property RegimeEspecialTributacao: Integer  read FREGIME_ESPECIAL_TRIBUTACAO write FREGIME_ESPECIAL_TRIBUTACAO;
    property ValorRetidoPis: Extended  read FVALOR_RETIDO_PIS write FVALOR_RETIDO_PIS;
    property ValorRetidoCofins: Extended  read FVALOR_RETIDO_COFINS write FVALOR_RETIDO_COFINS;
    property ValorRetidoCsll: Extended  read FVALOR_RETIDO_CSLL write FVALOR_RETIDO_CSLL;
    property BaseCalculoIrrf: Extended  read FBASE_CALCULO_IRRF write FBASE_CALCULO_IRRF;
    property ValorRetidoIrrf: Extended  read FVALOR_RETIDO_IRRF write FVALOR_RETIDO_IRRF;
    property BaseCalculoPrevidencia: Extended  read FBASE_CALCULO_PREVIDENCIA write FBASE_CALCULO_PREVIDENCIA;
    property ValorRetidoPrevidencia: Extended  read FVALOR_RETIDO_PREVIDENCIA write FVALOR_RETIDO_PREVIDENCIA;
    property ComexUfEmbarque: String  read FCOMEX_UF_EMBARQUE write FCOMEX_UF_EMBARQUE;
    property ComexLocalEmbarque: String  read FCOMEX_LOCAL_EMBARQUE write FCOMEX_LOCAL_EMBARQUE;
    property ComexLocalDespacho: String  read FCOMEX_LOCAL_DESPACHO write FCOMEX_LOCAL_DESPACHO;
    property CompraNotaEmpenho: String  read FCOMPRA_NOTA_EMPENHO write FCOMPRA_NOTA_EMPENHO;
    property CompraPedido: String  read FCOMPRA_PEDIDO write FCOMPRA_PEDIDO;
    property CompraContrato: String  read FCOMPRA_CONTRATO write FCOMPRA_CONTRATO;
    property InformacoesAddFisco: String  read FINFORMACOES_ADD_FISCO write FINFORMACOES_ADD_FISCO;
    property InformacoesAddContribuinte: String  read FINFORMACOES_ADD_CONTRIBUINTE write FINFORMACOES_ADD_CONTRIBUINTE;
    property StatusNota: Integer  read FSTATUS_NOTA write FSTATUS_NOTA;
    property Troco: Extended  read FTROCO write FTROCO;

    property NfeDestinatarioVO: TNfeDestinatarioVO read FNfeDestinatarioVO write FNfeDestinatarioVO;
    property ListaNfeDetalheVO: TListaNFeDetalheVO read FListaNfeDetalheVO write FListaNfeDetalheVO;
    property ListaNfeFormaPagamentoVO: TListaNfeFormaPagamentoVO read FListaNfeFormaPagamentoVO write FListaNfeFormaPagamentoVO;

  end;

  TListaNfeCabecalhoVO = specialize TFPGObjectList<TNfeCabecalhoVO>;

implementation

constructor TNfeCabecalhoVO.Create;
begin
  inherited;
  FNfeDestinatarioVO := TNfeDestinatarioVO.Create;
  FListaNfeDetalheVO := TListaNfeDetalheVO.Create;
  FListaNfeFormaPagamentoVO := TListaNfeFormaPagamentoVO.Create;
end;

destructor TNfeCabecalhoVO.Destroy;
begin
  FreeAndNil(FNfeDestinatarioVO);
  FreeAndNil(FListaNfeDetalheVO);
  FreeAndNil(FListaNfeFormaPagamentoVO);
  inherited;
end;


initialization
  Classes.RegisterClass(TNfeCabecalhoVO);

finalization
  Classes.UnRegisterClass(TNfeCabecalhoVO);

end.
