{*******************************************************************************
Title: T2Ti ERP                                                                 
Description:  VO  relacionado à tabela [ECF_CONFIGURACAO] 
                                                                                
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
unit EcfConfiguracaoVO;

{$mode objfpc}{$H+}

interface

uses
  VO, Classes, SysUtils, FGL, EcfResolucaoVO,
  EcfImpressoraVO, EcfCaixaVO, EcfEmpresaVO, EcfConfiguracaoBalancaVO,
  EcfRelatorioGerencialVO, EcfConfiguracaoLeitorSerVO;

type
  TEcfConfiguracaoVO = class(TVO)
  private
    FID: Integer;
    FID_ECF_IMPRESSORA: Integer;
    FID_ECF_RESOLUCAO: Integer;
    FID_ECF_CAIXA: Integer;
    FID_ECF_EMPRESA: Integer;
    FMENSAGEM_CUPOM: String;
    FPORTA_ECF: String;
    FIP_SERVIDOR: String;
    FIP_SITEF: String;
    FTIPO_TEF: String;
    FTITULO_TELA_CAIXA: String;
    FCAMINHO_IMAGENS_PRODUTOS: String;
    FCAMINHO_IMAGENS_MARKETING: String;
    FCAMINHO_IMAGENS_LAYOUT: String;
    FCOR_JANELAS_INTERNAS: String;
    FMARKETING_ATIVO: String;
    FCFOP_ECF: Integer;
    FCFOP_NF2: Integer;
    FTIMEOUT_ECF: Integer;
    FINTERVALO_ECF: Integer;
    FDESCRICAO_SUPRIMENTO: String;
    FDESCRICAO_SANGRIA: String;
    FTEF_TIPO_GP: Integer;
    FTEF_TEMPO_ESPERA: Integer;
    FTEF_ESPERA_STS: Integer;
    FTEF_NUMERO_VIAS: Integer;
    FDECIMAIS_QUANTIDADE: Integer;
    FDECIMAIS_VALOR: Integer;
    FBITS_POR_SEGUNDO: Integer;
    FQUANTIDADE_MAXIMA_CARTOES: Integer;
    FPESQUISA_PARTE: String;
    FULTIMA_EXCLUSAO: Integer;
    FLAUDO: String;
    FDATA_ATUALIZACAO_ESTOQUE: TDateTime;
    FPEDE_CPF_CUPOM: String;
    FTIPO_INTEGRACAO: Integer;
    FTIMER_INTEGRACAO: Integer;
    FGAVETA_SINAL_INVERTIDO: String;
    FGAVETA_UTILIZACAO: Integer;
    FQUANTIDADE_MAXIMA_PARCELA: Integer;
    FIMPRIME_PARCELA: String;
    FUSA_TECLADO_REDUZIDO: String;
    FPERMITE_LANCAR_NF_MANUAL: String;

    FEcfResolucaoVO: TEcfResolucaoVO;
    FEcfImpressoraVO: TEcfImpressoraVO;
    FEcfCaixaVO: TEcfCaixaVO;
    FEcfEmpresaVO: TEcfEmpresaVO;
    FEcfConfiguracaoBalancaVO: TEcfConfiguracaoBalancaVO;
    FEcfRelatorioGerencialVO: TEcfRelatorioGerencialVO;
    FEcfConfiguracaoLeitorSerVO: TEcfConfiguracaoLeitorSerVO;

  published
    constructor Create; override;
    destructor Destroy; override;

    property Id: Integer  read FID write FID;
    property IdEcfImpressora: Integer  read FID_ECF_IMPRESSORA write FID_ECF_IMPRESSORA;
    property IdEcfResolucao: Integer  read FID_ECF_RESOLUCAO write FID_ECF_RESOLUCAO;
    property IdEcfCaixa: Integer  read FID_ECF_CAIXA write FID_ECF_CAIXA;
    property IdEcfEmpresa: Integer  read FID_ECF_EMPRESA write FID_ECF_EMPRESA;
    property MensagemCupom: String  read FMENSAGEM_CUPOM write FMENSAGEM_CUPOM;
    property PortaEcf: String  read FPORTA_ECF write FPORTA_ECF;
    property IpServidor: String  read FIP_SERVIDOR write FIP_SERVIDOR;
    property IpSitef: String  read FIP_SITEF write FIP_SITEF;
    property TipoTef: String  read FTIPO_TEF write FTIPO_TEF;
    property TituloTelaCaixa: String  read FTITULO_TELA_CAIXA write FTITULO_TELA_CAIXA;
    property CaminhoImagensProdutos: String  read FCAMINHO_IMAGENS_PRODUTOS write FCAMINHO_IMAGENS_PRODUTOS;
    property CaminhoImagensMarketing: String  read FCAMINHO_IMAGENS_MARKETING write FCAMINHO_IMAGENS_MARKETING;
    property CaminhoImagensLayout: String  read FCAMINHO_IMAGENS_LAYOUT write FCAMINHO_IMAGENS_LAYOUT;
    property CorJanelasInternas: String  read FCOR_JANELAS_INTERNAS write FCOR_JANELAS_INTERNAS;
    property MarketingAtivo: String  read FMARKETING_ATIVO write FMARKETING_ATIVO;
    property CfopEcf: Integer  read FCFOP_ECF write FCFOP_ECF;
    property CfopNf2: Integer  read FCFOP_NF2 write FCFOP_NF2;
    property TimeoutEcf: Integer  read FTIMEOUT_ECF write FTIMEOUT_ECF;
    property IntervaloEcf: Integer  read FINTERVALO_ECF write FINTERVALO_ECF;
    property DescricaoSuprimento: String  read FDESCRICAO_SUPRIMENTO write FDESCRICAO_SUPRIMENTO;
    property DescricaoSangria: String  read FDESCRICAO_SANGRIA write FDESCRICAO_SANGRIA;
    property TefTipoGp: Integer  read FTEF_TIPO_GP write FTEF_TIPO_GP;
    property TefTempoEspera: Integer  read FTEF_TEMPO_ESPERA write FTEF_TEMPO_ESPERA;
    property TefEsperaSts: Integer  read FTEF_ESPERA_STS write FTEF_ESPERA_STS;
    property TefNumeroVias: Integer  read FTEF_NUMERO_VIAS write FTEF_NUMERO_VIAS;
    property DecimaisQuantidade: Integer  read FDECIMAIS_QUANTIDADE write FDECIMAIS_QUANTIDADE;
    property DecimaisValor: Integer  read FDECIMAIS_VALOR write FDECIMAIS_VALOR;
    property BitsPorSegundo: Integer  read FBITS_POR_SEGUNDO write FBITS_POR_SEGUNDO;
    property QuantidadeMaximaCartoes: Integer  read FQUANTIDADE_MAXIMA_CARTOES write FQUANTIDADE_MAXIMA_CARTOES;
    property PesquisaParte: String  read FPESQUISA_PARTE write FPESQUISA_PARTE;
    property UltimaExclusao: Integer  read FULTIMA_EXCLUSAO write FULTIMA_EXCLUSAO;
    property Laudo: String  read FLAUDO write FLAUDO;
    property DataAtualizacaoEstoque: TDateTime  read FDATA_ATUALIZACAO_ESTOQUE write FDATA_ATUALIZACAO_ESTOQUE;
    property PedeCpfCupom: String  read FPEDE_CPF_CUPOM write FPEDE_CPF_CUPOM;
    property TipoIntegracao: Integer  read FTIPO_INTEGRACAO write FTIPO_INTEGRACAO;
    property TimerIntegracao: Integer  read FTIMER_INTEGRACAO write FTIMER_INTEGRACAO;
    property GavetaSinalInvertido: String  read FGAVETA_SINAL_INVERTIDO write FGAVETA_SINAL_INVERTIDO;
    property GavetaUtilizacao: Integer  read FGAVETA_UTILIZACAO write FGAVETA_UTILIZACAO;
    property QuantidadeMaximaParcela: Integer  read FQUANTIDADE_MAXIMA_PARCELA write FQUANTIDADE_MAXIMA_PARCELA;
    property ImprimeParcela: String  read FIMPRIME_PARCELA write FIMPRIME_PARCELA;
    property UsaTecladoReduzido: String  read FUSA_TECLADO_REDUZIDO write FUSA_TECLADO_REDUZIDO;
    property PermiteLancarNfManual: String  read FPERMITE_LANCAR_NF_MANUAL write FPERMITE_LANCAR_NF_MANUAL;

    property EcfResolucaoVO: TEcfResolucaoVO read FEcfResolucaoVO write FEcfResolucaoVO;
    property EcfImpressoraVO: TEcfImpressoraVO read FEcfImpressoraVO write FEcfImpressoraVO;
    property EcfCaixaVO: TEcfCaixaVO read FEcfCaixaVO write FEcfCaixaVO;
    property EcfEmpresaVO: TEcfEmpresaVO read FEcfEmpresaVO write FEcfEmpresaVO;
    property EcfConfiguracaoBalancaVO: TEcfConfiguracaoBalancaVO read FEcfConfiguracaoBalancaVO write FEcfConfiguracaoBalancaVO;
    property EcfRelatorioGerencialVO: TEcfRelatorioGerencialVO read FEcfRelatorioGerencialVO write FEcfRelatorioGerencialVO;
    property EcfConfiguracaoLeitorSerVO: TEcfConfiguracaoLeitorSerVO read FEcfConfiguracaoLeitorSerVO write FEcfConfiguracaoLeitorSerVO;

  end;

  TListaEcfConfiguracaoVO = specialize TFPGObjectList<TEcfConfiguracaoVO>;

implementation

constructor TEcfConfiguracaoVO.Create;
begin
  inherited;

  FEcfResolucaoVO := TEcfResolucaoVO.Create;
  FEcfImpressoraVO := TEcfImpressoraVO.Create;
  FEcfCaixaVO := TEcfCaixaVO.Create;
  FEcfEmpresaVO := TEcfEmpresaVO.Create;
  FEcfConfiguracaoBalancaVO := TEcfConfiguracaoBalancaVO.Create;
  FEcfRelatorioGerencialVO := TEcfRelatorioGerencialVO.Create;
  FEcfConfiguracaoLeitorSerVO := TEcfConfiguracaoLeitorSerVO.Create;
end;

destructor TEcfConfiguracaoVO.Destroy;
begin
  FreeAndNil(FEcfResolucaoVO);
  FreeAndNil(FEcfImpressoraVO);
  FreeAndNil(FEcfCaixaVO);
  FreeAndNil(FEcfEmpresaVO);
  FreeAndNil(FEcfConfiguracaoBalancaVO);
  FreeAndNil(FEcfRelatorioGerencialVO);
  FreeAndNil(FEcfConfiguracaoLeitorSerVO);

  inherited;
end;


initialization
  Classes.RegisterClass(TEcfConfiguracaoVO);

finalization
  Classes.UnRegisterClass(TEcfConfiguracaoVO);

end.
