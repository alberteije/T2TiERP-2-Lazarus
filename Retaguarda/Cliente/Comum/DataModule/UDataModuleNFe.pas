unit UDataModuleNFe;

{$MODE Delphi}

interface

uses
  SysUtils, Classes, DB, BufDataset, FMTBcd, sqldb, Biblioteca;

type
  TFDataModuleNFe = class(TDataModule)
    CDSVolumes: TBufDataSet;
    DSVolumes: TDataSource;
    CDSNfReferenciada: TBufDataSet;
    DSNfReferenciada: TDataSource;
    CDSCteReferenciado: TBufDataSet;
    DSCteReferenciado: TDataSource;
    CDSNfRuralReferenciada: TBufDataSet;
    DSNfRuralReferenciada: TDataSource;
    CDSCupomReferenciado: TBufDataSet;
    DSCupomReferenciado: TDataSource;
    CDSDuplicata: TBufDataSet;
    DSDuplicata: TDataSource;
    CDSNfeReferenciada: TBufDataSet;
    DSNfeReferenciada: TDataSource;
    CDSNfeDetalhe: TBufDataSet;
    DSNfeDetalhe: TDataSource;
    CDSReboque: TBufDataSet;
    DSReboque: TDataSource;
    CDSNfeImpostoCofins: TBufDataSet;
    DSNfeImpostoCofins: TDataSource;
    CDSNfeImpostoIcms: TBufDataSet;
    DSNfeImpostoIcms: TDataSource;
    CDSNfeImpostoImportacao: TBufDataSet;
    DSNfeImpostoImportacao: TDataSource;
    CDSNfeImpostoIpi: TBufDataSet;
    DSNfeImpostoIpi: TDataSource;
    CDSNfeImpostoIssqn: TBufDataSet;
    DSNfeImpostoIssqn: TDataSource;
    CDSNfeImpostoPis: TBufDataSet;
    DSNfeImpostoPis: TDataSource;
    CDSNfeDeclaracaoImportacao: TBufDataSet;
    DSNfeDeclaracaoImportacao: TDataSource;
    CDSNfeImportacaoDetalhe: TBufDataSet;
    DSNfeImportacaoDetalhe: TDataSource;
    CDSNfeDetalheVeiculo: TBufDataSet;
    DSNfeDetalheVeiculo: TDataSource;
    CDSNfeDetalheArmamento: TBufDataSet;
    DSNfeDetalheArmamento: TDataSource;
    CDSNfeDetalheCombustivel: TBufDataSet;
    DSNfeDetalheCombustivel: TDataSource;
    CDSNfeDetalheMedicamento: TBufDataSet;
    DSNfeDetalheMedicamento: TDataSource;
    CDSVolumesLacres: TBufDataSet;
    DSVolumesLacres: TDataSource;
    CDSNfeNumero: TBufDataSet;
    DSNfeNumero: TDataSource;
    procedure DataModuleCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FDataModuleNFe: TFDataModuleNFe;

implementation

uses
  NfeDetalheImpostoCofinsVO, NfeDetalheImpostoIcmsVO, NfeNumeroVO,
  NfeDetalheImpostoPisVO, NfeDetalheImpostoIiVO, NfeDetalheImpostoIssqnVO,
  NfeDetalheImpostoIpiVO;

{$R *.lfm}

{ TFDataModuleNFe }

procedure TFDataModuleNFe.DataModuleCreate(Sender: TObject);
begin
  ConfiguraCDSFromVO(CDSNfeImpostoIcms, TNfeDetalheImpostoIcmsVO);
  ConfiguraCDSFromVO(CDSNfeImpostoPis, TNfeDetalheImpostoPisVO);
  ConfiguraCDSFromVO(CDSNfeImpostoCofins, TNfeDetalheImpostoCofinsVO);
  ConfiguraCDSFromVO(CDSNfeImpostoIpi, TNfeDetalheImpostoIpiVO);
  ConfiguraCDSFromVO(CDSNfeImpostoImportacao, TNfeDetalheImpostoIiVO);
  ConfiguraCDSFromVO(CDSNfeImpostoIssqn, TNfeDetalheImpostoIssqnVO);

  ConfiguraCDSFromVO(CDSNfeNumero, TNfeNumeroVO);
end;

end.
