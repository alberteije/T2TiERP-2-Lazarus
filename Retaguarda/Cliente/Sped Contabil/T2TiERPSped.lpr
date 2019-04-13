program T2TiERPSped;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, rxnew, printer4lazarus, zcore, UMenu, UPreview, USpedContabil, SessaoUsuario, Tipos, EmpresaController, ComissaoObjetivoController,
  ComissaoPerfilController, SpedContabilController, Biblioteca, Constantes, T2TiORM, AdministrativoFormularioVO, AdmParametroVO, AgenciaBancoVO,
  AidfAimdfVO, AlmoxarifadoVO, AtividadeForCliVO, BancoVO, CargoVO, CboVO, CentroResultadoVO, CepVO, CfopVO, ChequeVO, ClienteVO, CnaeVO, CodigoGpsVO,
  ColaboradorVO, CompraCotacaoDetalheVO, CompraCotacaoPedidoDetalheVO, CompraCotacaoVO, CompraFornecedorCotacaoVO, CompraPedidoDetalheVO,
  CompraPedidoVO, CompraReqCotacaoDetalheVO, CompraRequisicaoDetalheVO, CompraRequisicaoVO, CompraTipoPedidoVO, CompraTipoRequisicaoVO,
  ContabilContaVO, ContabilDreCabecalhoVO, ContabilDreDetalheVO, ContabilEncerramentoExeCabVO, ContabilEncerramentoExeDetVO, ContabilFechamentoVO,
  ContabilHistoricoVO, ContabilIndiceValorVO, ContabilIndiceVO, ContabilLancamentoCabecalhoVO, ContabilLancamentoDetalheVO,
  ContabilLancamentoOrcadoVO, ContabilLancamentoPadraoVO, ContabilLivroVO, ContabilLoteVO, ContabilParametroVO, ContabilTermoVO, ContaCaixaVO,
  ContadorVO, ContratoHistFaturamentoVO, ContratoHistoricoReajusteVO, ContratoPrevFaturamentoVO, ContratoSolicitacaoServicoVO, ContratoTemplateVO,
  ContratoTipoServicoVO, ContratoVO, ConvenioVO, CsosnAVO, CsosnBVO, CstCofinsVO, CstIcmsAVO, CstIcmsBVO, CstIpiVO, CstPisVO, DavCabecalhoVO,
  DavDetalheAlteracaoVO, DavDetalheVO, EcfE3VO, EcfImpressoraVO, EcfNotaFiscalCabecalhoVO, EcfProdutoVO, EcfR02VO, EcfR03VO, EcfSintegra60aVO,
  EcfSintegra60mVO, EcfVendaCabecalhoVO, EcfVendaDetalheVO, EfdTabela435VO, EfdTabela436VO, EfdTabela437VO, EfdTabela439VO, EfdTabela4310VO,
  EfdTabela4313VO, EfdTabela4314VO, EfdTabela4315VO, EfdTabela4316VO, EmpresaCnaeVO, EmpresaContatoVO, EmpresaEnderecoVO, EmpresaTelefoneVO,
  EmpresaTransporteItinerarioVO, EmpresaVO, EstadoCivilVO, EstoqueReajusteCabecalhoVO, EstoqueReajusteDetalheVO, FapVO, FeriadosVO,
  FeriasPeriodoAquisitivoVO, FinChequeEmitidoVO, FinChequeRecebidoVO, FinCobrancaParcelaReceberVO, FinCobrancaVO, FinConfiguracaoBoletoVO,
  FinDocumentoOrigemVO, FinExtratoContaBancoVO, FinFechamentoCaixaBancoVO, FinLancamentoPagarVO, FinLancamentoReceberVO, FinLctoPagarNtFinanceiraVO,
  FinLctoReceberNtFinanceiraVO, FinPagamentoFixoVO, FinParcelaPagamentoVO, FinParcelaPagarVO, FinParcelaReceberVO, FinParcelaRecebimentoVO,
  FinStatusParcelaVO, FinTipoPagamentoVO, FinTipoRecebimentoVO, FiscalApuracaoIcmsVO, FiscalLivroVO, FiscalNotaFiscalEntradaVO, FiscalParametroVO,
  FiscalTermoVO, FolhaAfastamentoVO, FolhaEventoVO, FolhaFechamentoVO, FolhaFeriasColetivasVO, FolhaHistoricoSalarialVO, FolhaInssRetencaoVO,
  FolhaInssServicoVO, FolhaInssVO, FolhaLancamentoCabecalhoVO, FolhaLancamentoComissaoVO, FolhaLancamentoDetalheVO, FolhaParametroVO,
  FolhaPlanoSaudeVO, FolhaPppAtividadeVO, FolhaPppCatVO, FolhaPppExameMedicoVO, FolhaPppFatorRiscoVO, FolhaPppVO, FolhaRescisaoVO,
  FolhaTipoAfastamentoVO, FolhaValeTransporteVO, FornecedorVO, FuncaoVO, GedDocumentoCabecalhoVO, GedDocumentoDetalheVO, GedTipoDocumentoVO,
  GedVersaoDocumentoVO, GuiasAcumuladasVO, IndiceEconomicoVO, MunicipioVO, NaturezaFinanceiraVO, NcmVO, NfeAcessoXmlVO, NfeCabecalhoVO,
  NfeCanaDeducoesSafraVO, NfeCanaFornecimentoDiarioVO, NfeCanaVO, NfeConfiguracaoVO, NfeCteReferenciadoVO, NfeCupomFiscalReferenciadoVO,
  NfeDeclaracaoImportacaoVO, NfeDestinatarioVO, NfeDetalheImpostoCofinsVO, NfeDetalheImpostoIcmsVO, NfeDetalheImpostoIiVO, NfeDetalheImpostoIpiVO,
  NfeDetalheImpostoIssqnVO, NfeDetalheImpostoPisVO, NfeDetalheVO, NfeDetEspecificoArmamentoVO, NfeDetEspecificoCombustivelVO,
  NfeDetEspecificoMedicamentoVO, NfeDetEspecificoVeiculoVO, NfeDuplicataVO, NfeEmitenteVO, NfeExportacaoVO, NfeFaturaVO, NfeFormaPagamentoVO,
  NfeImportacaoDetalheVO, NfeLocalEntregaVO, NfeLocalRetiradaVO, NfeNfReferenciadaVO, NfeNumeroVO, NfeProcessoReferenciadoVO,
  NfeProdRuralReferenciadaVO, NfeReferenciadaVO, NfeTransporteReboqueVO, NfeTransporteVO, NfeTransporteVolumeLacreVO, NfeTransporteVolumeVO,
  NivelFormacaoVO, NotaFiscalTipoVO, OperadoraCartaoVO, OperadoraPlanoSaudeVO, OrcamentoDetalheVO, OrcamentoEmpresarialVO,
  OrcamentoFluxoCaixaDetalheVO, OrcamentoFluxoCaixaPeriodoVO, OrcamentoFluxoCaixaVO, OrcamentoPeriodoVO, PaisVO, PapelFuncaoVO, PapelVO,
  PatrimApoliceSeguroVO, PatrimBemVO, PatrimDepreciacaoBemVO, PatrimDocumentoBemVO, PatrimEstadoConservacaoVO, PatrimGrupoBemVO,
  PatrimIndiceAtualizacaoVO, PatrimMovimentacaoBemVO, PatrimTaxaDepreciacaoVO, PatrimTipoAquisicaoBemVO, PatrimTipoMovimentacaoVO, PessoaAlteracaoVO,
  PessoaContatoVO, PessoaEnderecoVO, PessoaFisicaVO, PessoaJuridicaVO, PessoaTelefoneVO, PessoaVO, PlanoCentroResultadoVO, PlanoContaRefSpedVO,
  PlanoContaVO, PlanoNaturezaFinanceiraVO, PontoAbonoUtilizacaoVO, PontoAbonoVO, PontoBancoHorasUtilizacaoVO, PontoBancoHorasVO,
  PontoClassificacaoJornadaVO, PontoEscalaVO, PontoFechamentoJornadaVO, PontoHorarioAutorizadoVO, PontoHorarioVO, PontoMarcacaoVO, PontoParametroVO,
  PontoRelogioVO, PontoTurmaVO, PreVendaCabecalhoVO, PreVendaDetalheVO, ProdutoAlteracaoItemVO, ProdutoGrupoVO, ProdutoLoteVO, ProdutoMarcaVO,
  ProdutoSubGrupoVO, ProdutoVO, QuadroSocietarioVO, RegistroCartorioVO, RequisicaoInternaCabecalhoVO, RequisicaoInternaDetalheVO, SalarioMinimoVO,
  SefipCategoriaTrabalhoVO, SefipCodigoMovimentacaoVO, SefipCodigoRecolhimentoVO, SeguradoraVO, SetorVO, SimplesNacionalCabecalhoVO,
  SimplesNacionalDetalheVO, SindicatoVO, SituacaoColaboradorVO, SituacaoDocumentoVO, SituacaoForCliVO, SocioDependenteVO,
  SocioParticipacaoSocietariaVO, SocioVO, TalonarioChequeVO, TipoAdmissaoVO, TipoColaboradorVO, TipoContratoVO, TipoDesligamentoVO, TipoItemSpedVO,
  TipoReceitaDipiVO, TipoRelacionamentoVO, TributCofinsCodApuracaoVO, TributConfiguraOfGtVO, TributGrupoTributarioVO, TributIcmsCustomCabVO,
  TributIcmsCustomDetVO, TributIcmsUfVO, TributIpiDipiVO, TributIssVO, TributOperacaoFiscalVO, TributPisCodApuracaoVO, UfVO, UnidadeConversaoVO,
  UnidadeProdutoVO, UsuarioVO, VendaCabecalhoVO, VendaComissaoVO, VendaCondicoesPagamentoVO, VendaCondicoesParcelasVO, VendaDetalheVO, VendaFreteVO,
  VendaOrcamentoCabecalhoVO, VendaOrcamentoDetalheVO, VendaRomaneioEntregaVO, VendedorVO, ViewCompraItemCotacaoVO, ViewCompraMapaComparativoVO,
  ViewCompraReqItemCotadoVO, ViewConciliaClienteVO, ViewConciliaFornecedorVO, ViewContratoDadosContratanteVO, ViewFinChequeEmitidoVO,
  ViewFinChequeNaoCompensadoVO, ViewFinChequesEmSerVO, ViewFinFluxoCaixaVO, ViewFinLancamentoPagarVO, ViewFinLancamentoReceberVO,
  ViewFinMovimentoCaixaBancoVO, ViewFinResumoTesourariaVO, ViewFinTotalPagamentosDiaVO, ViewFinTotalRecebimentosDiaVO, ViewPessoaClienteVO,
  ViewPessoaColaboradorVO, ViewPessoaFornecedorVO, ViewPessoaTransportadoraVO, ViewPontoEscalaTurmaVO, ViewPontoMarcacaoVO, ViewSessaoEmpresaVO,
  ViewSintegra60dVO, ViewSintegra60rVO, ViewSintegra61rVO, ViewSpedC190VO, ViewSpedC300VO, ViewSpedC321VO, ViewSpedC370VO, ViewSpedC390VO,
  ViewSpedC425VO, ViewSpedC490VO, ViewSpedNfeDestinatarioVO, ViewSpedNfeDetalheVO, ViewSpedNfeEmitenteVO, ViewSpedNfeItemVO, ViewTributacaoCofinsVO,
  ViewTributacaoIcmsCustomVO, ViewTributacaoIcmsVO, ViewTributacaoIpiVO, ViewTributacaoIssVO, ViewTributacaoPisVO, VO, ComissaoObjetivoVO,
  ComissaoPerfilVO, ViewSpedI155VO, UDataModule, UDataModuleNFe, UBase, UFiltro, ULogin, ULookup, UTela, UTelaCadastro
  { you can add units after this };

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

