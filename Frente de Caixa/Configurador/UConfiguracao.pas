{*******************************************************************************
Title: T2TiPDV
Description: Configurações do PAF-ECF

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
           alberteije@gmail.com

@author T2Ti.COM
@version 2.0
*******************************************************************************}
unit UConfiguracao;

{$mode objfpc}{$H+}

interface

uses
  LCLIntf, LCLType, LMessages, Messages, SysUtils, Variants, Classes, Graphics,
  Controls, Forms, Dialogs, Grids, DBGrids, RxDBGrid, curredit, FMTBcd, DB,
  BufDataset, StdCtrls, DBCtrls, Buttons, ExtCtrls, ComCtrls, ACBrECF,
  EcfConfiguracaoVO, TypInfo, IniFiles, FileCtrl, ColorBox, ZDataset, Biblioteca;

type

  { TFConfiguracao }

  TFConfiguracao = class(TForm)
    BotaoPosicionarComponentes: TSpeedButton;
    QCaixaDATA_CADASTRO: TDateField;
    QCaixaID: TLargeintField;
    QCaixaNOME: TStringField;
    QCFOPAPLICACAO: TMemoField;
    QCFOPCFOP: TLargeintField;
    QCFOPDESCRICAO: TMemoField;
    QCFOPID: TLargeintField;
    QConfiguracao: TZQuery;
    DSConfiguracao: TDataSource;
    QConfiguracaoBITS_POR_SEGUNDO: TLargeintField;
    QConfiguracaoCAMINHO_IMAGENS_LAYOUT: TStringField;
    QConfiguracaoCAMINHO_IMAGENS_MARKETING: TStringField;
    QConfiguracaoCAMINHO_IMAGENS_PRODUTOS: TStringField;
    QConfiguracaoCFOP_ECF: TLargeintField;
    QConfiguracaoCFOP_NF2: TLargeintField;
    QConfiguracaoCONFIGURACAO_BALANCA: TStringField;
    QConfiguracaoCOR_JANELAS_INTERNAS: TStringField;
    QConfiguracaoDATA_ATUALIZACAO_ESTOQUE: TDateField;
    QConfiguracaoDECIMAIS_QUANTIDADE: TLargeintField;
    QConfiguracaoDECIMAIS_VALOR: TLargeintField;
    QConfiguracaoDESCRICAO_SANGRIA: TStringField;
    QConfiguracaoDESCRICAO_SUPRIMENTO: TStringField;
    QConfiguracaoID: TLargeintField;
    QConfiguracaoID_ECF_CAIXA: TLargeintField;
    QConfiguracaoID_ECF_EMPRESA: TLargeintField;
    QConfiguracaoID_ECF_IMPRESSORA: TLargeintField;
    QConfiguracaoID_ECF_RESOLUCAO: TLargeintField;
    QConfiguracaoINDICE_GERENCIAL: TStringField;
    QConfiguracaoINTERVALO_ECF: TLargeintField;
    QConfiguracaoIP_SERVIDOR: TStringField;
    QConfiguracaoIP_SITEF: TStringField;
    QConfiguracaoLAUDO: TStringField;
    QConfiguracaoMARKETING_ATIVO: TStringField;
    QConfiguracaoMENSAGEM_CUPOM: TStringField;
    QConfiguracaoPARAMETROS_DIVERSOS: TStringField;
    QConfiguracaoPESQUISA_PARTE: TStringField;
    QConfiguracaoPORTA_ECF: TStringField;
    QConfiguracaoQTDE_MAXIMA_CARTOES: TLargeintField;
    QConfiguracaoSINCRONIZADO: TStringField;
    QConfiguracaoTEF_ESPERA_STS: TLargeintField;
    QConfiguracaoTEF_NUMERO_VIAS: TLargeintField;
    QConfiguracaoTEF_TEMPO_ESPERA: TLargeintField;
    QConfiguracaoTEF_TIPO_GP: TLargeintField;
    QConfiguracaoTIMEOUT_ECF: TLargeintField;
    QConfiguracaoTIPO_TEF: TStringField;
    QConfiguracaoTITULO_TELA_CAIXA: TStringField;
    QConfiguracaoULTIMA_EXCLUSAO: TLargeintField;
    QEmpresaALIQUOTA_COFINS: TFloatField;
    QEmpresaALIQUOTA_PIS: TFloatField;
    QEmpresaBAIRRO: TStringField;
    QEmpresaCEP: TStringField;
    QEmpresaCIDADE: TStringField;
    QEmpresaCNPJ: TStringField;
    QEmpresaCODIGO_IBGE_CIDADE: TLargeintField;
    QEmpresaCODIGO_IBGE_UF: TLargeintField;
    QEmpresaCOMPLEMENTO: TStringField;
    QEmpresaCONTATO: TStringField;
    QEmpresaCRT: TStringField;
    QEmpresaDATA_CADASTRO: TDateField;
    QEmpresaDATA_INICIO_ATIVIDADES: TDateField;
    QEmpresaDATA_INSC_JUNTA_COMERCIAL: TDateField;
    QEmpresaEMAIL: TStringField;
    QEmpresaFAX: TStringField;
    QEmpresaFONE: TStringField;
    QEmpresaID: TLargeintField;
    QEmpresaID_EMPRESA: TLargeintField;
    QEmpresaIMAGEM_LOGOTIPO: TMemoField;
    QEmpresaINSCRICAO_ESTADUAL: TStringField;
    QEmpresaINSCRICAO_ESTADUAL_ST: TStringField;
    QEmpresaINSCRICAO_JUNTA_COMERCIAL: TStringField;
    QEmpresaINSCRICAO_MUNICIPAL: TStringField;
    QEmpresaLOGRADOURO: TStringField;
    QEmpresaMATRIZ_FILIAL: TStringField;
    QEmpresaNOME_FANTASIA: TStringField;
    QEmpresaNUMERO: TStringField;
    QEmpresaRAZAO_SOCIAL: TStringField;
    QEmpresaSUFRAMA: TStringField;
    QEmpresaTIPO_REGIME: TStringField;
    QEmpresaUF: TStringField;
    QImpressoraCODIGO: TStringField;
    QImpressoraDATA_INSTALACAO_SB: TDateField;
    QImpressoraDOCTO: TStringField;
    QImpressoraECF_IMPRESSORA: TStringField;
    QImpressoraHORA_INSTALACAO_SB: TStringField;
    QImpressoraID: TLargeintField;
    QImpressoraIDENTIFICACAO: TStringField;
    QImpressoraLACRE_NA_MFD: TStringField;
    QImpressoraLE: TStringField;
    QImpressoraLEF: TStringField;
    QImpressoraMARCA: TStringField;
    QImpressoraMC: TStringField;
    QImpressoraMD: TStringField;
    QImpressoraMFD: TStringField;
    QImpressoraMODELO: TStringField;
    QImpressoraMODELO_ACBR: TStringField;
    QImpressoraMODELO_DOCUMENTO_FISCAL: TStringField;
    QImpressoraNUMERO: TLargeintField;
    QImpressoraSERIE: TStringField;
    QImpressoraTIPO: TStringField;
    QImpressoraVERSAO: TStringField;
    QImpressoraVR: TStringField;
    QPosicaoComponentes: TZQuery;
    DSPosicaoComponentes: TDataSource;
    QImpressora: TZQuery;
    DSImpressora: TDataSource;
    botaoConfirma: TBitBtn;
    botaoSair: TBitBtn;
    Image1: TImage;
    PageControl1: TPageControl;
    QPosicaoComponentesALTURA: TLargeintField;
    QPosicaoComponentesESQUERDA: TLargeintField;
    QPosicaoComponentesID: TLargeintField;
    QPosicaoComponentesID_ECF_RESOLUCAO: TLargeintField;
    QPosicaoComponentesLARGURA: TLargeintField;
    QPosicaoComponentesNOME: TStringField;
    QPosicaoComponentesTAMANHO_FONTE: TLargeintField;
    QPosicaoComponentesTEXTO: TStringField;
    QPosicaoComponentesTOPO: TLargeintField;
    QResolucaoALTURA: TLargeintField;
    QResolucaoEDITS_COLOR: TStringField;
    QResolucaoEDITS_DISABLED_COLOR: TStringField;
    QResolucaoEDITS_FONT_COLOR: TStringField;
    QResolucaoEDITS_FONT_NAME: TStringField;
    QResolucaoEDITS_FONT_STYLE: TStringField;
    QResolucaoHOTTRACK_COLOR: TStringField;
    QResolucaoID: TLargeintField;
    QResolucaoIMAGEM_MENU: TStringField;
    QResolucaoIMAGEM_SUBMENU: TStringField;
    QResolucaoIMAGEM_TELA: TStringField;
    QResolucaoITEM_SEL_STYLE_COLOR: TStringField;
    QResolucaoITEM_STYLE_FONT_COLOR: TStringField;
    QResolucaoITEM_STYLE_FONT_NAME: TStringField;
    QResolucaoITEM_STYLE_FONT_STYLE: TStringField;
    QResolucaoLABEL_TOTAL_GERAL_FONT_COLOR: TStringField;
    QResolucaoLARGURA: TLargeintField;
    QResolucaoRESOLUCAO_TELA: TStringField;
    TabSheet1: TTabSheet;
    ScrollBox1: TScrollBox;
    DBLookupComboBox1: TDBLookupComboBox;
    Label1: TLabel;
    Label2: TLabel;
    DBLookupComboBox2: TDBLookupComboBox;
    QCaixa: TZQuery;
    DSCaixa: TDataSource;
    DBLookupComboBox4: TDBLookupComboBox;
    Label4: TLabel;
    QEmpresa: TZQuery;
    DSEmpresa: TDataSource;
    QResolucao: TZQuery;
    DSResolucao: TDataSource;
    TabSheet2: TTabSheet;
    GridPrincipal: TRxDBGrid;
    Label3: TLabel;
    DBLookupComboBox3: TDBLookupComboBox;
    Label5: TLabel;
    DBEdit1: TDBEdit;
    Label6: TLabel;
    DBEdit2: TDBEdit;
    Label7: TLabel;
    DBEdit3: TDBEdit;
    Label8: TLabel;
    DBEdit4: TDBEdit;
    Label9: TLabel;
    DBEdit5: TDBEdit;
    Label10: TLabel;
    PaletaCores: TColorListBox;
    Label11: TLabel;
    DBEdit6: TDBEdit;
    Label12: TLabel;
    DBEdit7: TDBEdit;
    Label13: TLabel;
    DBEdit8: TDBEdit;
    Folder: TSelectDirectoryDialog;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    SpeedButton3: TSpeedButton;
    Label14: TLabel;
    DBEdit9: TDBEdit;
    Label15: TLabel;
    DBEdit10: TDBEdit;
    DBCheckBox1: TDBCheckBox;
    QCFOP: TZQuery;
    DSCFOP: TDataSource;
    DBLookupComboBox5: TDBLookupComboBox;
    Label17: TLabel;
    DBLookupComboBox6: TDBLookupComboBox;
    Label18: TLabel;
    Label19: TLabel;
    DBEdit11: TDBEdit;
    Label21: TLabel;
    DBEdit13: TDBEdit;
    Label22: TLabel;
    DBEdit14: TDBEdit;
    Label27: TLabel;
    DBEdit19: TDBEdit;
    PanelScroll: TPanel;
    GroupBox1: TGroupBox;
    Label24: TLabel;
    DBEdit16: TDBEdit;
    Label25: TLabel;
    DBEdit17: TDBEdit;
    Label26: TLabel;
    DBEdit18: TDBEdit;
    Label23: TLabel;
    DBEdit15: TDBEdit;
    DBComboBox1: TDBComboBox;
    Label16: TLabel;
    Label20: TLabel;
    DBEdit12: TDBEdit;
    botaoConexoes: TBitBtn;
    botaoReconectaImpressora: TBitBtn;
    Label61: TLabel;
    SinalVerde: TImage;
    SinalVermelho: TImage;
    DBEdit21: TDBEdit;
    Label62: TLabel;
    TabSheet6: TTabSheet;
    botaoDesconectaImpressora: TBitBtn;
    oArquivos: TOpenDialog;
    Bevel1: TBevel;
    PageControl2: TPageControl;
    TabSheet8: TTabSheet;
    TabSheet9: TTabSheet;
    TabSheet10: TTabSheet;
    GroupBox6: TGroupBox;
    Label65: TLabel;
    Label66: TLabel;
    SerieECF: TEdit;
    GTECF: TEdit;
    GroupBox21: TGroupBox;
    Label101: TLabel;
    cmbXXXVI1: TComboBox;
    GroupBox18: TGroupBox;
    Label86: TLabel;
    Label89: TLabel;
    Label90: TLabel;
    Label91: TLabel;
    Label92: TLabel;
    Label93: TLabel;
    Label94: TLabel;
    cmbApl1: TComboBox;
    cmbApl2: TComboBox;
    cmbApl3: TComboBox;
    cmbApl4: TComboBox;
    cmbApl5: TComboBox;
    cmbApl6: TComboBox;
    cmbApl7: TComboBox;
    GroupBox17: TGroupBox;
    Label78: TLabel;
    Label80: TLabel;
    Label82: TLabel;
    Label84: TLabel;
    cmbPar1: TComboBox;
    cmbPar2: TComboBox;
    cmbPar3: TComboBox;
    cmbPar4: TComboBox;
    GroupBox20: TGroupBox;
    Label99: TLabel;
    Label100: TLabel;
    cmbXXII1: TComboBox;
    cmbXXII2: TComboBox;
    GroupBox19: TGroupBox;
    Label95: TLabel;
    Label96: TLabel;
    Label97: TLabel;
    Label98: TLabel;
    cmbCri1: TComboBox;
    cmbCri2: TComboBox;
    cmbCri3: TComboBox;
    cmbCri4: TComboBox;
    GroupBox16: TGroupBox;
    Label72: TLabel;
    Label74: TLabel;
    Label76: TLabel;
    cmbFun1: TComboBox;
    cmbFun2: TComboBox;
    cmbFun3: TComboBox;
    Panel1: TPanel;
    botaoRecarregarAuxiliar: TBitBtn;
    botaoSalvarAuxiliar: TBitBtn;
    GroupBox11: TGroupBox;
    Label77: TLabel;
    editBD: TEdit;
    GroupBox12: TGroupBox;
    Label81: TLabel;
    editImporta: TEdit;
    GroupBox9: TGroupBox;
    Label69: TLabel;
    Label63: TLabel;
    Label68: TLabel;
    editCNPJEstabelecimento: TEdit;
    editRegistraPreVenda: TEdit;
    editImprimeDAV: TEdit;
    GroupBox8: TGroupBox;
    Label67: TLabel;
    editArquivos: TEdit;
    GroupBox10: TGroupBox;
    Label71: TLabel;
    Label73: TLabel;
    Label75: TLabel;
    editCNPJ: TEdit;
    editNome_PAF: TEdit;
    editMD5PrincipalEXE: TEdit;
    GroupBox7: TGroupBox;
    Label64: TLabel;
    editGT: TEdit;
    GroupBox14: TGroupBox;
    MemoSerieEcf: TMemo;
    Bevel2: TBevel;
    GroupBox13: TGroupBox;
    Label83: TLabel;
    Label85: TLabel;
    EditServidorAppServidor: TEdit;
    EditServidorAppPorta: TEdit;
    procedure BotaoPosicionarComponentesClick(Sender: TObject);
    procedure confirma;
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure botaoConfirmaClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure PaletaCoresColorChange(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
    procedure SpeedButton3Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure editTimeOutKeyPress(Sender: TObject; var Key: Char);
    procedure botaoConexoesClick(Sender: TObject);
    procedure CarregaArquivoAuxiliar;
    procedure ConfiguraACBr;
    procedure botaoReconectaImpressoraClick(Sender: TObject);
    procedure EditClick(Sender: TObject);
    procedure botaoRecarregarAuxiliarClick(Sender: TObject);
    procedure botaoSalvarAuxiliarClick(Sender: TObject);
    procedure botaoDesconectaImpressoraClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FConfiguracao: TFConfiguracao;
  ConfiguracaoVO: TEcfConfiguracaoVO;


implementation

uses
  UDataModule, UConfigConexao, USplash, UCaixa,
  ConfiguracaoController, UDataModuleConexao;

{$R *.lfm}

{$REGION 'Infra'}
procedure TFConfiguracao.FormCreate(Sender: TObject);
begin
  Application.CreateForm(TFSplash,FSplash);
  Application.CreateForm(TFDataModule, FDataModule);
  Application.CreateForm(TFDataModuleConexao, FDataModuleConexao);

  try
    FSplash.Show;
    FSplash.BringToFront;

    QCaixa.Active := True;
    QCFOP.Active := True;
    QConfiguracao.Active := True;
    QEmpresa.Active := True;
    QImpressora.Active := True;
    QResolucao.Active := True;
    QPosicaoComponentes.Active := True;
    //
    QPosicaoComponentes.MasterSource := DSResolucao;
    QPosicaoComponentes.MasterFields := 'ID';

    ConfiguracaoVO := TEcfConfiguracaoController.ConsultaObjeto('ID=1');

    try
      ConfiguraACBr;
    except
    end;
    CarregaArquivoAuxiliar;
  finally
    FreeAndNil(FSplash);
    FConfiguracao.Show;
    PageControl1.ActivePageIndex := 0;
  end;
end;

procedure TFConfiguracao.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  CloseAction := caFree;
end;

procedure TFConfiguracao.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = VK_F12 then
    Confirma;
end;

procedure TFConfiguracao.botaoDesconectaImpressoraClick(Sender: TObject);
begin
  try
    FDataModule.ACBrECF.Desativar;
    SinalVerde.Visible := false;
    SinalVermelho.Visible := true;
  except
  end;
end;

procedure TFConfiguracao.botaoReconectaImpressoraClick(Sender: TObject);
begin
  Confirma;
  Application.CreateForm(TFSplash,FSplash);
  FSplash.Show;
  FSplash.BringToFront;
  FDataModule.ACBrECF.Desativar;
  try
    ConfiguraACBr;
  except
  end;
  FreeAndNil(FSplash);
end;

procedure TFConfiguracao.botaoConexoesClick(Sender: TObject);
begin
  Application.CreateForm(TFConfigConexao,FConfigConexao);
  FConfigConexao.ShowModal;
end;

procedure TFConfiguracao.BotaoPosicionarComponentesClick(Sender: TObject);
begin
 Application.CreateForm(TFCaixa, FCaixa);
 FCaixa.ShowModal;
 QPosicaoComponentes.Refresh;
end;
{$ENDREGION 'Infra'}

{$REGION 'Edição, Confirmação e Gravação dos Dados'}
procedure TFConfiguracao.botaoConfirmaClick(Sender: TObject);
begin
  Confirma;
end;

procedure TFConfiguracao.Confirma;
begin
  try
    Application.ProcessMessages;
    if QConfiguracao.State in [dsEdit] then
    begin
      QConfiguracao.Post;
    end;
    if QPosicaoComponentes.State in [dsEdit] then
    begin
      QPosicaoComponentes.Post;
    end;
    Application.MessageBox('Dados salvos com sucesso.', 'Informação do Sistema', MB_OK + MB_ICONINFORMATION);
  except
    Application.MessageBox('Erro ao salvar modificações.', 'Informação do Sistema', MB_OK + MB_ICONERROR);
    Abort;
  end;
end;

procedure TFConfiguracao.PaletaCoresColorChange(Sender: TObject);
begin
  QConfiguracao.Edit;
  QConfiguracao.FieldByName('COR_JANELAS_INTERNAS').AsString := ColorToString(PaletaCores.Color);
end;

procedure TFConfiguracao.EditClick(Sender: TObject);
begin
  (Sender as TEdit).SelectAll;
end;

procedure TFConfiguracao.editTimeOutKeyPress(Sender: TObject; var Key: Char);
begin
  if not (Key in ['0'..'9',#8,#13]) then
    key:=#0;
end;

procedure TFConfiguracao.SpeedButton1Click(Sender: TObject);
begin
  Folder.Execute;
  DBEdit6.Text := Folder.GetNamePath + '\';
  QConfiguracao.Edit;
end;

procedure TFConfiguracao.SpeedButton2Click(Sender: TObject);
begin
  Folder.Execute;
  DBEdit7.Text := Folder.GetNamePath + '\';
  QConfiguracao.Edit;
end;

procedure TFConfiguracao.SpeedButton3Click(Sender: TObject);
begin
  Folder.Execute;
  DBEdit8.Text := Folder.GetNamePath + '\';
  QConfiguracao.Edit;
end;
{$ENDREGION 'Edição, Confirmação e Gravação dos Dados'}

{$REGION 'Arquivo Auxiliar'}
procedure TFConfiguracao.botaoRecarregarAuxiliarClick(Sender: TObject);
begin
  CarregaArquivoAuxiliar;
end;

procedure TFConfiguracao.CarregaArquivoAuxiliar;
var
  ArquivoAuxiliarIni: TIniFile;
  ConexaoIni: TIniFile;
  I, Qtde: integer;
begin
  try
    try
      // dados arquivo auxiliar
      ArquivoAuxiliarIni := TIniFile.Create(ExtractFilePath(Application.ExeName) + 'ArquivoAuxiliar.ini');

      // ***********************************************************************
      // Aba Principal
      // ***********************************************************************

      MemoSerieEcf.Text := '';
      ArquivoAuxiliarIni.ReadSectionValues('SERIES', MemoSerieEcf.Lines);

      Qtde := (MemoSerieEcf.Lines.Count - 1);
      MemoSerieEcf.Text := '';
      for I := 1 to Qtde do
      begin
        if trim(ArquivoAuxiliarIni.ReadString('SERIES', 'SERIE' + IntToStr(I), '')) <> '' then
          MemoSerieEcf.Lines.Add(Codifica('D', trim(ArquivoAuxiliarIni.ReadString('SERIES', 'SERIE' + IntToStr(I), ''))));
      end;

      editGT.Text := Codifica('D', trim(ArquivoAuxiliarIni.ReadString('ECF', 'GT', '')));
      editArquivos.Text := Codifica('D', trim(ArquivoAuxiliarIni.ReadString('MD5', 'ARQUIVOS', '')));

      editCNPJEstabelecimento.Text := Codifica('D', trim(ArquivoAuxiliarIni.ReadString('ESTABELECIMENTO', 'CNPJ', '')));
      editRegistraPreVenda.Text := Codifica('D', trim(ArquivoAuxiliarIni.ReadString('ESTABELECIMENTO', 'REGISTRAPREVENDA', '')));
      editImprimeDAV.Text := Codifica('D', trim(ArquivoAuxiliarIni.ReadString('ESTABELECIMENTO', 'IMPRIMEDAV', '')));

      editCNPJ.Text := Codifica('D', trim(ArquivoAuxiliarIni.ReadString('SHOUSE', 'CNPJ', '')));
      editNome_PAF.Text := Codifica('D', trim(ArquivoAuxiliarIni.ReadString('SHOUSE', 'NOME_PAF', '')));
      editMD5PrincipalEXE.Text := Codifica('D', trim(ArquivoAuxiliarIni.ReadString('SHOUSE', 'MD5PrincipalEXE', '')));

      // ***********************************************************************
      // Aba Parâmetros
      // ***********************************************************************

      cmbFun1.Text := (Codifica('D', trim(ArquivoAuxiliarIni.ReadString('FUNCIONALIDADES', 'FUN1', ''))));
      cmbFun2.Text := (Codifica('D', trim(ArquivoAuxiliarIni.ReadString('FUNCIONALIDADES', 'FUN2', ''))));
      cmbFun3.Text := (Codifica('D', trim(ArquivoAuxiliarIni.ReadString('FUNCIONALIDADES', 'FUN3', ''))));

      cmbPar1.Text := (Codifica('D', trim(ArquivoAuxiliarIni.ReadString('PARAMETROSPARANAOCONCOMITANCIA', 'PAR1', ''))));
      cmbPar2.Text := (Codifica('D', trim(ArquivoAuxiliarIni.ReadString('PARAMETROSPARANAOCONCOMITANCIA', 'PAR2', ''))));
      cmbPar3.Text := (Codifica('D', trim(ArquivoAuxiliarIni.ReadString('PARAMETROSPARANAOCONCOMITANCIA', 'PAR3', ''))));
      cmbPar4.Text := (Codifica('D', trim(ArquivoAuxiliarIni.ReadString('PARAMETROSPARANAOCONCOMITANCIA', 'PAR4', ''))));

      cmbCri1.Text := (Codifica('D', trim(ArquivoAuxiliarIni.ReadString('CRITERIOSPORUNIDADEFEDERADA', 'CRI1', ''))));
      cmbCri2.Text := (Codifica('D', trim(ArquivoAuxiliarIni.ReadString('CRITERIOSPORUNIDADEFEDERADA', 'CRI2', ''))));
      cmbCri3.Text := (Codifica('D', trim(ArquivoAuxiliarIni.ReadString('CRITERIOSPORUNIDADEFEDERADA', 'CRI3', ''))));
      cmbCri4.Text := (Codifica('D', trim(ArquivoAuxiliarIni.ReadString('CRITERIOSPORUNIDADEFEDERADA', 'CRI4', ''))));

      cmbApl1.Text := (Codifica('D', trim(ArquivoAuxiliarIni.ReadString('APLICATIVOSESPECIAIS', 'APL1', ''))));
      cmbApl2.Text := (Codifica('D', trim(ArquivoAuxiliarIni.ReadString('APLICATIVOSESPECIAIS', 'APL2', ''))));
      cmbApl3.Text := (Codifica('D', trim(ArquivoAuxiliarIni.ReadString('APLICATIVOSESPECIAIS', 'APL3', ''))));
      cmbApl4.Text := (Codifica('D', trim(ArquivoAuxiliarIni.ReadString('APLICATIVOSESPECIAIS', 'APL4', ''))));
      cmbApl5.Text := (Codifica('D', trim(ArquivoAuxiliarIni.ReadString('APLICATIVOSESPECIAIS', 'APL5', ''))));
      cmbApl6.Text := (Codifica('D', trim(ArquivoAuxiliarIni.ReadString('APLICATIVOSESPECIAIS', 'APL6', ''))));
      cmbApl7.Text := (Codifica('D', trim(ArquivoAuxiliarIni.ReadString('APLICATIVOSESPECIAIS', 'APL7', ''))));

      cmbXXII1.Text := (Codifica('D', trim(ArquivoAuxiliarIni.ReadString('XXIIREQUISITO', 'XXII1', ''))));
      cmbXXII2.Text := (Codifica('D', trim(ArquivoAuxiliarIni.ReadString('XXIIREQUISITO', 'XXII2', ''))));

      cmbXXXVI1.Text := (Codifica('D', trim(ArquivoAuxiliarIni.ReadString('XXXVIREQUISITO', 'XXXVI1', ''))));

      // ***********************************************************************
      // Aba Conexão
      // ***********************************************************************

      ConexaoIni := TIniFile.Create(ExtractFilePath(Application.ExeName) + 'Conexao.ini');

      editBD.Text := ConexaoIni.ReadString('SGBD', 'BD', '');

      editImporta.Text := ConexaoIni.ReadString('INTEGRACAO', 'REMOTEAPP', '');

      EditServidorAppServidor.Text := ConexaoIni.ReadString('ServidorApp', 'Servidor', '');
      EditServidorAppPorta.Text := ConexaoIni.ReadString('ServidorApp', 'Porta', '');

      // Dados ECF
      if FDataModule.ACBrECF.Ativo then
      begin
        SerieECF.Text := FDataModule.ACBrECF.NumSerie;
        GTECF.Text := FloatToStr(FDataModule.ACBrECF.GrandeTotal);
      end;
    except
      Application.MessageBox('Problemas ao carregar um dos arquivos: ArquivoAuxiliar.ini / Conexao.ini', 'Informação do Sistema', MB_OK + MB_ICONERROR);
    end;
  finally
    ArquivoAuxiliarIni.Free;
    ConexaoIni.Free;
  end;
end;

procedure TFConfiguracao.botaoSalvarAuxiliarClick(Sender: TObject);
var
  ArquivoAuxiliarIni: TIniFile;
  ConexaoIni: TIniFile;
  I: integer;
  Serie: Boolean;
  Serial: string;
begin
  try
    try
      if Application.MessageBox('Tem certeza que deseja salvar estes dados no ArquivoAuxiliar.ini?' + #13 + 'Os dados antigos do arquivo serão perdidos.', 'Informação do Sistema', MB_YESNO + MB_ICONQUESTION) = mryes then
      begin
        // dados arquivo auxiliar
        ArquivoAuxiliarIni := TIniFile.Create(ExtractFilePath(Application.ExeName) + 'ArquivoAuxiliar.ini');

        // *********************************************************************
        // Aba Principal
        // *********************************************************************
        ArquivoAuxiliarIni.WriteString('ECF', 'GT', Codifica('C', trim(GTECF.Text)));
        Serie := false;

        for I := 0 to MemoSerieEcf.Lines.Count - 1 do
        begin
          if (trim(MemoSerieEcf.Lines.Strings[I])) = (trim(SerieECF.Text)) then
            Serie := True;
        end;

        if not Serie then
        begin
          MemoSerieEcf.Lines.Add(trim(SerieECF.Text));
        end;

        for I := 0 to MemoSerieEcf.Lines.Count - 1 do
        begin
          if trim(MemoSerieEcf.Lines.Strings[I]) <> '' then
          begin
            Serial := 'SERIE' + IntToStr(I + 1);
            ArquivoAuxiliarIni.WriteString('SERIES', pchar(Serial), Codifica('C', trim(MemoSerieEcf.Lines.Strings[I])));
          end;
          Application.ProcessMessages;
        end;

        ArquivoAuxiliarIni.WriteString('MD5', 'ARQUIVOS', Codifica('C', trim(editArquivos.Text)));

        ArquivoAuxiliarIni.WriteString('ESTABELECIMENTO', 'CNPJ', Codifica('C', trim(editCNPJEstabelecimento.Text)));
        ArquivoAuxiliarIni.WriteString('ESTABELECIMENTO', 'REGISTRAPREVENDA', Codifica('C', trim(editRegistraPreVenda.Text)));
        ArquivoAuxiliarIni.WriteString('ESTABELECIMENTO', 'IMPRIMEDAV', Codifica('C', trim(editImprimeDAV.Text)));

        ArquivoAuxiliarIni.WriteString('SHOUSE', 'CNPJ', Codifica('C', trim(editCNPJ.Text)));
        ArquivoAuxiliarIni.WriteString('SHOUSE', 'NOME_PAF', Codifica('C', trim(editNome_PAF.Text)));
        ArquivoAuxiliarIni.WriteString('SHOUSE', 'MD5PrincipalEXE', Codifica('C', trim(editMD5PrincipalEXE.Text)));

        // *********************************************************************
        // Aba Parâmetros
        // *********************************************************************

        ArquivoAuxiliarIni.WriteString('FUNCIONALIDADES', 'FUN1', Codifica('C', trim(cmbFun1.Text)));
        ArquivoAuxiliarIni.WriteString('FUNCIONALIDADES', 'FUN2', Codifica('C', trim(cmbFun2.Text)));
        ArquivoAuxiliarIni.WriteString('FUNCIONALIDADES', 'FUN3', Codifica('C', trim(cmbFun3.Text)));

        ArquivoAuxiliarIni.WriteString('PARAMETROSPARANAOCONCOMITANCIA', 'PAR1', Codifica('C', trim(cmbPar1.Text)));
        ArquivoAuxiliarIni.WriteString('PARAMETROSPARANAOCONCOMITANCIA', 'PAR2', Codifica('C', trim(cmbPar2.Text)));
        ArquivoAuxiliarIni.WriteString('PARAMETROSPARANAOCONCOMITANCIA', 'PAR3', Codifica('C', trim(cmbPar3.Text)));
        ArquivoAuxiliarIni.WriteString('PARAMETROSPARANAOCONCOMITANCIA', 'PAR4', Codifica('C', trim(cmbPar4.Text)));

        ArquivoAuxiliarIni.WriteString('CRITERIOSPORUNIDADEFEDERADA', 'CRI1', Codifica('C', trim(cmbCri1.Text)));
        ArquivoAuxiliarIni.WriteString('CRITERIOSPORUNIDADEFEDERADA', 'CRI2', Codifica('C', trim(cmbCri2.Text)));
        ArquivoAuxiliarIni.WriteString('CRITERIOSPORUNIDADEFEDERADA', 'CRI3', Codifica('C', trim(cmbCri3.Text)));
        ArquivoAuxiliarIni.WriteString('CRITERIOSPORUNIDADEFEDERADA', 'CRI4', Codifica('C', trim(cmbCri4.Text)));

        ArquivoAuxiliarIni.WriteString('APLICATIVOSESPECIAIS', 'APL1', Codifica('C', trim(cmbApl1.Text)));
        ArquivoAuxiliarIni.WriteString('APLICATIVOSESPECIAIS', 'APL2', Codifica('C', trim(cmbApl2.Text)));
        ArquivoAuxiliarIni.WriteString('APLICATIVOSESPECIAIS', 'APL3', Codifica('C', trim(cmbApl3.Text)));
        ArquivoAuxiliarIni.WriteString('APLICATIVOSESPECIAIS', 'APL4', Codifica('C', trim(cmbApl4.Text)));
        ArquivoAuxiliarIni.WriteString('APLICATIVOSESPECIAIS', 'APL5', Codifica('C', trim(cmbApl5.Text)));
        ArquivoAuxiliarIni.WriteString('APLICATIVOSESPECIAIS', 'APL6', Codifica('C', trim(cmbApl6.Text)));
        ArquivoAuxiliarIni.WriteString('APLICATIVOSESPECIAIS', 'APL7', Codifica('C', trim(cmbApl7.Text)));

        ArquivoAuxiliarIni.WriteString('XXIIREQUISITO', 'XXII1', Codifica('C', trim(cmbXXII1.Text)));
        ArquivoAuxiliarIni.WriteString('XXIIREQUISITO', 'XXII2', Codifica('C', trim(cmbXXII2.Text)));

        ArquivoAuxiliarIni.WriteString('XXXVIREQUISITO', 'XXXVI1', Codifica('C', trim(cmbXXXVI1.Text)));

        // *********************************************************************
        // Aba Conexão
        // *********************************************************************
        ConexaoIni := TIniFile.Create(ExtractFilePath(Application.ExeName) + 'Conexao.ini');

        ConexaoIni.WriteString('SGBD', 'BD', editBD.Text);

        ConexaoIni.WriteString('INTEGRACAO', 'REMOTEAPP', editImporta.Text);

        ConexaoIni.WriteString('ServidorApp', 'Servidor', EditServidorAppServidor.Text);
        ConexaoIni.WriteString('ServidorApp', 'Porta', EditServidorAppPorta.Text);
      end;
    except
      Application.MessageBox('Problemas ao salvar um dos arquivos: ArquivoAuxiliar.ini / Conexao.ini', 'Informação do Sistema', MB_OK + MB_ICONERROR);
    end;
  finally
    ArquivoAuxiliarIni.Free;
    ConexaoIni.Free;
  end;
end;
{$ENDREGION 'Arquivo Auxiliar'}

{$REGION 'ACBr'}
procedure TFConfiguracao.ConfiguraACBr;
begin
  FDataModule.ACBrECF.Modelo := TACBrECFModelo(GetEnumValue(TypeInfo(TACBrECFModelo), ConfiguracaoVO.EcfImpressoraVO.ModeloAcbr));
  FDataModule.ACBrECF.Porta := ConfiguracaoVO.PortaEcf;
  FDataModule.ACBrECF.TimeOut := ConfiguracaoVO.TimeoutEcf;
  FDataModule.ACBrECF.IntervaloAposComando := ConfiguracaoVO.IntervaloEcf;
  FDataModule.ACBrECF.Device.Baud := ConfiguracaoVO.BitsPorSegundo;
  try
    FSplash.lbMensagem.caption := 'Conectando ao ECF...';
    FSplash.lbMensagem.Refresh;
    FDataModule.ACBrECF.Ativar;
    FSplash.lbMensagem.caption := 'ECF conectado!';
    FSplash.lbMensagem.Refresh;
    FSplash.imgECF.Visible := True;
    FSplash.imgTEF.Visible := True;
    SinalVerde.Visible := True;
    SinalVermelho.Visible := false;
  except
    FSplash.lbMensagem.caption := 'Falha ao tentar conectar ECF!';
    FSplash.lbMensagem.Refresh;
    Application.MessageBox('ECF com problemas ou desligado. Configurações diretas com o ECF não funcionarão.', 'Informação do Sistema', MB_OK + MB_ICONINFORMATION);
    SinalVerde.Visible := false;
    SinalVermelho.Visible := True;
  end;
  FDataModule.ACBrECF.CarregaAliquotas;
  if FDataModule.ACBrECF.Aliquotas.Count <= 0 then
  begin
    Application.MessageBox('ECF sem alíquotas cadastradas. Aplicação será aberta para somente consulta.', 'Informação do Sistema', MB_OK + MB_ICONINFORMATION);
  end;
  FDataModule.ACBrECF.CarregaFormasPagamento;

  if FDataModule.ACBrECF.FormasPagamento.Count <= 0 then
  begin
    Application.MessageBox('ECF sem formas de pagamento cadastradas. Aplicação será aberta para somente consulta.', 'Informação do Sistema', MB_OK + MB_ICONINFORMATION);
  end;
end;
{$ENDREGION 'ACBr'}


end.
