unit UNfeDetalheAnexo;

{$MODE Delphi}

interface

uses
  BrookHTTPClient, BrookFCLHTTPClientBroker, BrookHTTPUtils, BrookUtils, FPJson, ZDataset,
  LCLIntf, LCLType, LMessages, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UTelaCadastro, Menus, StdCtrls, ExtCtrls, Buttons, Grids, DBGrids,
  ComCtrls, LabeledCtrls, rxdbgrid, rxtoolbar, DBCtrls, StrUtils,
  Math, Constantes, CheckLst, ActnList, ToolWin, db, BufDataset, Biblioteca,
  ULookup, VO;

  type
  TFNfeDetalheAnexo = class(TForm)
    PageControlDadosTributacao: TPageControl;
    tsIcms: TTabSheet;
    PanelDetalheIcms: TPanel;
    tsPis: TTabSheet;
    PanelDetalhePis: TPanel;
    tsCofins: TTabSheet;
    PanelDetalheCofins: TPanel;
    tsIpi: TTabSheet;
    PanelDetalheIpi: TPanel;
    tsImpostoImportacao: TTabSheet;
    tsIssqn: TTabSheet;
    PanelDetalheIssqn: TPanel;
    PanelDetalheImpostoImportacao: TPanel;
    DBEditBcIcms: TLabeledDBEdit;
    Bevel1: TBevel;
    DBEditOrigemMercadoria: TLabeledDBEdit;
    DBEditCst: TLabeledDBEdit;
    DBEditCsosn: TLabeledDBEdit;
    DBEditModalidadeBcIcms: TLabeledDBEdit;
    DBEditTaxaReducaoBcIcmsSt: TLabeledDBEdit;
    DBEditAliquotaIcms: TLabeledDBEdit;
    DBEditValorIcms: TLabeledDBEdit;
    DBEditMotivoDesoneracaoIcms: TLabeledDBEdit;
    DBEditModalidadeBcIcmsSt: TLabeledDBEdit;
    DBEditPercentualMvaIcmsSt: TLabeledDBEdit;
    DBEditTaxaReducaoBcIcms: TLabeledDBEdit;
    DBEditValorBcIcmsSt: TLabeledDBEdit;
    DBEditAliquotaIcmsSt: TLabeledDBEdit;
    DBEditValorIcmsSt: TLabeledDBEdit;
    DBEditValorBcIcmsStRetido: TLabeledDBEdit;
    DBEditValorIcmsStRetido: TLabeledDBEdit;
    DBEditValorBcIcmsStDestino: TLabeledDBEdit;
    DBEditValorIcmsStDestino: TLabeledDBEdit;
    DBEditAliquotaCreditoIcmsSn: TLabeledDBEdit;
    DBEditValorCreditoIcmsSn: TLabeledDBEdit;
    DBEditPercentualBcOperacaoPropria: TLabeledDBEdit;
    DBEditUfSt: TLabeledDBEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Bevel2: TBevel;
    DBEditCstPis: TLabeledDBEdit;
    DBEditQuantidadeVendidaPis: TLabeledDBEdit;
    DBEditValorBcPis: TLabeledDBEdit;
    DBEditAliquotaPisPercentual: TLabeledDBEdit;
    DBEditValorPis: TLabeledDBEdit;
    DBEditAliquotaPisReais: TLabeledDBEdit;
    Bevel3: TBevel;
    DBEditCstCofins: TLabeledDBEdit;
    DBEditQuantidadeVendidaCofins: TLabeledDBEdit;
    DBEditBcCofins: TLabeledDBEdit;
    DBEditAliquotaPercentualCofins: TLabeledDBEdit;
    DBEditValorCofins: TLabeledDBEdit;
    DBEditAliquotaReaisCofins: TLabeledDBEdit;
    Bevel4: TBevel;
    DBEditCstIpi: TLabeledDBEdit;
    DBEditQuantidadeUnidadeTributavelIpi: TLabeledDBEdit;
    DBEditValorBcIpi: TLabeledDBEdit;
    DBEditAliquotaIpi: TLabeledDBEdit;
    DBEditValorIpi: TLabeledDBEdit;
    DBEditValorUnidadeTributavelIpi: TLabeledDBEdit;
    DBEditEnquadramentoIpi: TLabeledDBEdit;
    DBEditEnquadramentoLegalIpi: TLabeledDBEdit;
    DBEditCnpjProdutor: TLabeledDBEdit;
    DBEditQuantidadeSeloIpi: TLabeledDBEdit;
    DBEditCodigoSeloIpi: TLabeledDBEdit;
    Bevel5: TBevel;
    DBEditValorBcIi: TLabeledDBEdit;
    DBEditValorDespesasAduaneirasIi: TLabeledDBEdit;
    DBEditValorIofIi: TLabeledDBEdit;
    DBEditValorIi: TLabeledDBEdit;
    Bevel6: TBevel;
    DBEditValorBcIssqn: TLabeledDBEdit;
    DBEditAliquotaIssqn: TLabeledDBEdit;
    DBEditValorIssqn: TLabeledDBEdit;
    DBEditMunicipioIssqn: TLabeledDBEdit;
    DBEditItemListaServicos: TLabeledDBEdit;
    LabeledDBEdit1: TLabeledDBEdit;
    Label5: TLabel;
    tsDetalheEspecificoCombustivel: TTabSheet;
    PanelDetalheCombustivel: TPanel;
    DBEditCodigoAnpCombustivel: TLabeledDBEdit;
    DBEditCodifCombustivel: TLabeledDBEdit;
    DBEditQuantidadeTemperaturaAmbienteCombustivel: TLabeledDBEdit;
    DBEditUfConsumoCombustivel: TLabeledDBEdit;
    DBEditBcCideCombustivel: TLabeledDBEdit;
    DBEditAliquotaCideCombustivel: TLabeledDBEdit;
    DBEditValorCideCombustivel: TLabeledDBEdit;
    tsDetalheEspecificoVeiculo: TTabSheet;
    PanelDetalheVeiculo: TPanel;
    Bevel8: TBevel;
    DBEditTipoOperacaoVeiculo: TLabeledDBEdit;
    DBEditChassiVeiculo: TLabeledDBEdit;
    DBEditTipoCorVeiculo: TLabeledDBEdit;
    DBEditPotenciaMotorVeiculo: TLabeledDBEdit;
    Label6: TLabel;
    DBEditDescricaoCorVeiculo: TLabeledDBEdit;
    DBEditCilindradasVeiculo: TLabeledDBEdit;
    DBEditPesoLiquidoVeiculo: TLabeledDBEdit;
    DBEditPesoBrutoVeiculo: TLabeledDBEdit;
    DBEditNumeroSerieVeiculo: TLabeledDBEdit;
    DBEditTipoCombustivelVeiculo: TLabeledDBEdit;
    DBEditNumeroMotorVeiculo: TLabeledDBEdit;
    DBEditCapacidadeMaximaTracaoVeiculo: TLabeledDBEdit;
    DBEditDistanciaEixosVeiculo: TLabeledDBEdit;
    DBEditAnoModeloVeiculo: TLabeledDBEdit;
    DBEditAnoFabricacaoVeiculo: TLabeledDBEdit;
    DBEditTipoPinturaVeiculo: TLabeledDBEdit;
    DBEditTipoVeiculo: TLabeledDBEdit;
    DBEditEspecieVeiculo: TLabeledDBEdit;
    Label7: TLabel;
    DBEditCondicaoVinVeiculo: TLabeledDBEdit;
    Label8: TLabel;
    DBEditCondicaoVeiculo: TLabeledDBEdit;
    Label9: TLabel;
    DBEditCodigoMarcaModeloVeiculo: TLabeledDBEdit;
    DBEditCodigoCorDenatranVeiculo: TLabeledDBEdit;
    DBEditLotacaoVeiculo: TLabeledDBEdit;
    DBEditRestricaoVeiculo: TLabeledDBEdit;
    Label10: TLabel;
    tsDetalheEspecificoMedicamento: TTabSheet;
    PanelDetalheMedicamento: TPanel;
    GridDetalheMedicamento: TRxDbGrid;
    tsDetalheEspecificoArmamento: TTabSheet;
    PanelDetalheArmamento: TPanel;
    GridDetalheArmamento: TRxDbGrid;
    tsDeclaracaoImportacao: TTabSheet;
    PanelDeclaracaoImportacao: TPanel;
    GridDeclaracaoImportacao: TRxDbGrid;
    PageControlAdicoes: TPageControl;
    tsDetalheAdicoes: TTabSheet;
    Panel1: TPanel;
    GridDeclaracaoImportacaoDetalhe: TRxDbGrid;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FNfeDetalheAnexo: TFNfeDetalheAnexo;

implementation

uses UDataModule, UDataModuleNFe;

{$R *.lfm}

end.

