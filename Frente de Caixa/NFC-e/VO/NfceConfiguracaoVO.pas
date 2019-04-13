{*******************************************************************************
Title: T2Ti ERP                                                                 
Description:  VO  relacionado à tabela [NFCE_CONFIGURACAO] 
                                                                                
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
unit NfceConfiguracaoVO;

{$mode objfpc}{$H+}

interface

uses
  VO, Classes, SysUtils, FGL,
  NfceResolucaoVO, NfceCaixaVO, EmpresaVO, NfceConfiguracaoBalancaVO,
  NfceConfiguracaoLeitorSerVO;

type
  TNfceConfiguracaoVO = class(TVO)
  private
    FID: Integer;
    FID_EMPRESA: Integer;
    FID_NFCE_CAIXA: Integer;
    FID_NFCE_RESOLUCAO: Integer;
    FMENSAGEM_CUPOM: String;
    FTITULO_TELA_CAIXA: String;
    FCAMINHO_IMAGENS_PRODUTOS: String;
    FCAMINHO_IMAGENS_MARKETING: String;
    FCAMINHO_IMAGENS_LAYOUT: String;
    FCOR_JANELAS_INTERNAS: String;
    FMARKETING_ATIVO: String;
    FCFOP: Integer;
    FDECIMAIS_QUANTIDADE: Integer;
    FDECIMAIS_VALOR: Integer;
    FQUANTIDADE_MAXIMA_PARCELA: Integer;
    FIMPRIME_PARCELA: String;

    FNfceResolucaoVO: TNfceResolucaoVO;
    FNfceCaixaVO: TNfceCaixaVO;
    FEmpresaVO: TEmpresaVO;
    FNfceConfiguracaoBalancaVO: TNfceConfiguracaoBalancaVO;
    FNfceConfiguracaoLeitorSerVO: TNfceConfiguracaoLeitorSerVO;

  published
    constructor Create; override;
    destructor Destroy; override;

    property Id: Integer  read FID write FID;
    property IdEmpresa: Integer  read FID_EMPRESA write FID_EMPRESA;
    property IdNfceCaixa: Integer  read FID_NFCE_CAIXA write FID_NFCE_CAIXA;
    property IdNfceResolucao: Integer  read FID_NFCE_RESOLUCAO write FID_NFCE_RESOLUCAO;
    property MensagemCupom: String  read FMENSAGEM_CUPOM write FMENSAGEM_CUPOM;
    property TituloTelaCaixa: String  read FTITULO_TELA_CAIXA write FTITULO_TELA_CAIXA;
    property CaminhoImagensProdutos: String  read FCAMINHO_IMAGENS_PRODUTOS write FCAMINHO_IMAGENS_PRODUTOS;
    property CaminhoImagensMarketing: String  read FCAMINHO_IMAGENS_MARKETING write FCAMINHO_IMAGENS_MARKETING;
    property CaminhoImagensLayout: String  read FCAMINHO_IMAGENS_LAYOUT write FCAMINHO_IMAGENS_LAYOUT;
    property CorJanelasInternas: String  read FCOR_JANELAS_INTERNAS write FCOR_JANELAS_INTERNAS;
    property MarketingAtivo: String  read FMARKETING_ATIVO write FMARKETING_ATIVO;
    property Cfop: Integer  read FCFOP write FCFOP;
    property DecimaisQuantidade: Integer  read FDECIMAIS_QUANTIDADE write FDECIMAIS_QUANTIDADE;
    property DecimaisValor: Integer  read FDECIMAIS_VALOR write FDECIMAIS_VALOR;
    property QuantidadeMaximaParcela: Integer  read FQUANTIDADE_MAXIMA_PARCELA write FQUANTIDADE_MAXIMA_PARCELA;
    property ImprimeParcela: String  read FIMPRIME_PARCELA write FIMPRIME_PARCELA;

    property NfceResolucaoVO: TNfceResolucaoVO read FNfceResolucaoVO write FNfceResolucaoVO;
    property NfceCaixaVO: TNfceCaixaVO read FNfceCaixaVO write FNfceCaixaVO;
    property EmpresaVO: TEmpresaVO read FEmpresaVO write FEmpresaVO;
    property NfceConfiguracaoBalancaVO: TNfceConfiguracaoBalancaVO read FNfceConfiguracaoBalancaVO write FNfceConfiguracaoBalancaVO;
    property NfceConfiguracaoLeitorSerVO: TNfceConfiguracaoLeitorSerVO read FNfceConfiguracaoLeitorSerVO write FNfceConfiguracaoLeitorSerVO;

  end;

  TListaNfceConfiguracaoVO = specialize TFPGObjectList<TNfceConfiguracaoVO>;

implementation

constructor TNfceConfiguracaoVO.Create;
begin
  inherited;

  FNfceResolucaoVO := TNfceResolucaoVO.Create;
  FNfceCaixaVO := TNfceCaixaVO.Create;
  FEmpresaVO := TEmpresaVO.Create;
  FNfceConfiguracaoBalancaVO := TNfceConfiguracaoBalancaVO.Create;
  FNfceConfiguracaoLeitorSerVO := TNfceConfiguracaoLeitorSerVO.Create;
end;

destructor TNfceConfiguracaoVO.Destroy;
begin
  FreeAndNil(FNfceResolucaoVO);
  FreeAndNil(FNfceCaixaVO);
  FreeAndNil(FEmpresaVO);
  FreeAndNil(FNfceConfiguracaoBalancaVO);
  FreeAndNil(FNfceConfiguracaoLeitorSerVO);

  inherited;
end;


initialization
  Classes.RegisterClass(TNfceConfiguracaoVO);

finalization
  Classes.UnRegisterClass(TNfceConfiguracaoVO);

end.
