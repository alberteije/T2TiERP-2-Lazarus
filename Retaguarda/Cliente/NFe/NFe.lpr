program NFe;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, rxnew, printer4lazarus, zcore, EmpresaVO, UsuarioVO, VO, ProdutoVO, ContadorVO, NfeAcessoXmlVO, NfeCabecalhoVO, NfeCanaDeducoesSafraVO,
  NfeCanaFornecimentoDiarioVO, NfeCanaVO, NfeConfiguracaoVO, NfeCteReferenciadoVO, NfeCupomFiscalReferenciadoVO, NfeDeclaracaoImportacaoVO,
  NfeDestinatarioVO, NfeDetalheImpostoCofinsVO, NfeDetalheImpostoIcmsVO, NfeDetalheImpostoIiVO, NfeDetalheImpostoIpiVO, NfeDetalheImpostoIssqnVO,
  NfeDetalheImpostoPisVO, NfeDetalheVO, NfeDetEspecificoArmamentoVO, NfeDetEspecificoCombustivelVO, NfeDetEspecificoMedicamentoVO,
  NfeDetEspecificoVeiculoVO, NfeDuplicataVO, NfeEmitenteVO, NfeExportacaoVO, NfeFaturaVO, NfeFormaPagamentoVO, NfeImportacaoDetalheVO,
  NfeLocalEntregaVO, NfeLocalRetiradaVO, NfeNfReferenciadaVO, NfeNumeroVO, NfeProcessoReferenciadoVO, NfeProdRuralReferenciadaVO, NfeReferenciadaVO,
  NfeTransporteReboqueVO, NfeTransporteVO, NfeTransporteVolumeLacreVO, NfeTransporteVolumeVO, ViewTributacaoCofinsVO, ViewTributacaoIcmsCustomVO,
  ViewTributacaoIcmsVO, ViewTributacaoIpiVO, ViewTributacaoIssVO, ViewTributacaoPisVO, ViewPessoaClienteVO, ViewPessoaTransportadoraVO,
  VendaCabecalhoVO, TributOperacaoFiscalVO, EmpresaEnderecoVO, FinLancamentoReceberVO, FinLctoReceberNtFinanceiraVO, FinParcelaReceberVO,
  FinParcelaRecebimentoVO, Biblioteca, Constantes, UDataModule, UDataModuleNFe, Tipos, SessaoUsuario, UBase, UTela, UFiltro, UTelaCadastro, ULookup,
  umenu, UNFe, NFeCalculoController;

{$R *.res}

begin
  RequireDerivedFormResource := True;
  Application.Initialize;
  Application.CreateForm(TFMenu, FMenu);
  Application.CreateForm(TFDataModule, FDataModule);
  Application.CreateForm(TFDataModuleNFe, FDataModuleNFe);
  Application.CreateForm(TFLookup, FLookup);
  Application.Run;
end.

