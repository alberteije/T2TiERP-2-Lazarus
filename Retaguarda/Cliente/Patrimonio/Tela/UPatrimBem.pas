{ *******************************************************************************
Title: T2Ti ERP
Description: Janela Cadastro de Bem - Patrimônio

The MIT License

Copyright: Copyright (C) 2016 T2Ti.COM

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
t2ti.com@gmail.com</p>

@author Albert Eije (alberteije@gmail.com)
@version 2.0
******************************************************************************* }

unit UPatrimBem;

{$MODE Delphi}

interface

uses
  BrookHTTPClient, BrookFCLHTTPClientBroker, BrookHTTPUtils, BrookUtils, FPJson, ZDataset,
  LCLIntf, LCLType, LMessages, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UTelaCadastro, Menus, StdCtrls, ExtCtrls, Buttons, Grids, DBGrids,
  ComCtrls, LabeledCtrls, rxdbgrid, rxtoolbar, DBCtrls, StrUtils,
  Math, Constantes, CheckLst, ActnList, ToolWin, db, BufDataset, Biblioteca,
  ULookup, VO, md5;

  type

  { TFPatrimBem }

  TFPatrimBem = class(TFTelaCadastro)
    CDSPatrimDocumentoBem: TBufDataset;
    CDSPatrimDepreciacaoBem: TBufDataset;
    CDSPatrimMovimentacaoBem: TBufDataset;
    ScrollBox: TScrollBox;
    EditNome: TLabeledEdit;
    EditNumero: TLabeledEdit;
    BevelEdits: TBevel;
    PageControlDadosPatrimBem: TPageControl;
    tsDadosComplementares: TTabSheet;
    tsDocumentoBem: TTabSheet;
    PanelDocumentacao: TPanel;
    GridDocumentacao: TRxDbGrid;
    tsDepreciacaoBem: TTabSheet;
    PanelDepreciacao: TPanel;
    GridDepreciacao: TRxDbGrid;
    EditIdTipoAquisicao: TLabeledCalcEdit;
    EditTipoAquisicaoNome: TLabeledEdit;
    EditIdSetor: TLabeledCalcEdit;
    EditSetorNome: TLabeledEdit;
    PanelDadosComplementares: TPanel;
    EditDataAquisicao: TLabeledDateEdit;
    MemoDescricao: TLabeledMemo;
    EditDataAceite: TLabeledDateEdit;
    EditDataCadastro: TLabeledDateEdit;
    EditValorOriginal: TLabeledCalcEdit;
    MemoFuncao: TLabeledMemo;
    DSPatrimDocumentoBem: TDataSource;
    DSPatrimDepreciacaoBem: TDataSource;
    tsMovimentacaoBem: TTabSheet;
    PanelMovimentacao: TPanel;
    GridMovimentacao: TRxDbGrid;
    DSPatrimMovimentacaoBem: TDataSource;
    EditGrupoBemNome: TLabeledEdit;
    EditIdGrupoBem: TLabeledCalcEdit;
    EditIdColaborador: TLabeledCalcEdit;
    EditColaboradorNome: TLabeledEdit;
    EditIdFornecedor: TLabeledCalcEdit;
    EditFornecedorNome: TLabeledEdit;
    EditIdEstadoConservacao: TLabeledCalcEdit;
    EditEstadoConservacaoNome: TLabeledEdit;
    EditNumeroSerie: TLabeledEdit;
    EditDataContabilizado: TLabeledDateEdit;
    EditDataVistoria: TLabeledDateEdit;
    EditDataMarcacao: TLabeledDateEdit;
    EditDataBaixa: TLabeledDateEdit;
    EditDataVencimentoGarantia: TLabeledDateEdit;
    EditNumeroNF: TLabeledEdit;
    EditChaveNFe: TLabeledEdit;
    EditValorCompra: TLabeledCalcEdit;
    EditValorAtualizado: TLabeledCalcEdit;
    GroupBoxDepreciacao: TGroupBox;
    EditValorBaixa: TLabeledCalcEdit;
    ComboDeprecia: TLabeledComboBox;
    ComboMetodoDepreciacao: TLabeledComboBox;
    ComboTipoDepreciacao: TLabeledComboBox;
    EditInicioDepreciacao: TLabeledDateEdit;
    EditUltimaDepreciacao: TLabeledDateEdit;
    EditTaxaAnualDepreciacao: TLabeledCalcEdit;
    EditTaxaMensalDepreciacao: TLabeledCalcEdit;
    EditTaxaDepreciacaoAcelerada: TLabeledCalcEdit;
    EditTaxaDepreciacaoIncentivada: TLabeledCalcEdit;
    ActionToolBarDepreciacao: TToolPanel;
    ActionManagerBem: TActionList;
    ActionCalcularDepreciacao: TAction;
    ActionToolBar1: TToolPanel;
    ActionAcionarGed: TAction;
    procedure FormCreate(Sender: TObject);
    procedure GridDocumentacaoKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure GridDepreciacaoKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure ActionCalcularDepreciacaoExecute(Sender: TObject);
    procedure ActionAcionarGedExecute(Sender: TObject);
    procedure EditIdSetorKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure EditIdColaboradorKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure EditIdFornecedorKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure EditIdGrupoBemKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure EditIdTipoAquisicaoKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure EditIdEstadoConservacaoKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure BotaoConsultarClick(Sender: TObject);
    procedure BotaoSalvarClick(Sender: TObject);
  private
    { Private declarations }
    IdTipoPatrimBem: Integer;
  public
    { Public declarations }
    procedure GridParaEdits; override;
    procedure LimparCampos; override;

    // Controles CRUD
    function DoInserir: Boolean; override;
    function DoEditar: Boolean; override;
    function DoExcluir: Boolean; override;
    function DoSalvar: Boolean; override;

    procedure ConfigurarLayoutTela;
  end;

var
  FPatrimBem: TFPatrimBem;

implementation

uses PatrimBemVO, PatrimBemController, PatrimDocumentoBemVO,
  PatrimDepreciacaoBemVO, PatrimMovimentacaoBemVO,  UDataModule,
  PatrimTipoAquisicaoBemVO, PatrimTipoAquisicaoBemController, ViewPessoaColaboradorVO,
  ViewPessoaColaboradorController, PatrimEstadoConservacaoVO, PatrimEstadoConservacaoController,
  ViewPessoaFornecedorVO, ViewPessoaFornecedorController, PatrimGrupoBemVO, PatrimGrupoBemController,
  SetorVO, SetorController, PatrimTipoMovimentacaoVO, PatrimTipoMovimentacaoController;
{$R *.lfm}

{$REGION 'Infra'}
procedure TFPatrimBem.BotaoConsultarClick(Sender: TObject);
var
  RetornoConsulta: TZQuery;
  ListaCampos: TStringList;
  i: integer;
begin
  inherited;

  if Sessao.Camadas = 2 then
  begin
    Filtro := MontaFiltro;

    CDSGrid.Close;
    CDSGrid.Open;
    ConfiguraGridFromVO(Grid, ClasseObjetoGridVO);

    ListaCampos  := TStringList.Create;
    RetornoConsulta := TPatrimBemController.Consulta(Filtro, IntToStr(Pagina));
    RetornoConsulta.Active := True;

    RetornoConsulta.GetFieldNames(ListaCampos);

    RetornoConsulta.First;
    while not RetornoConsulta.EOF do begin
      CDSGrid.Append;
      for i := 0 to ListaCampos.Count - 1 do
      begin
        CDSGrid.FieldByName(ListaCampos[i]).Value := RetornoConsulta.FieldByName(ListaCampos[i]).Value;
      end;
      CDSGrid.Post;
      RetornoConsulta.Next;
    end;
  end;
end;

procedure TFPatrimBem.BotaoSalvarClick(Sender: TObject);
begin
  inherited;
  BotaoConsultarClick(Sender);
end;

procedure TFPatrimBem.FormCreate(Sender: TObject);
var
  Form: TForm;
begin
  ClasseObjetoGridVO := TPatrimBemVO;
  ObjetoController := TPatrimBemController.Create;

  inherited;

  ConfiguraCDSFromVO(CDSPatrimDocumentoBem, TPatrimDocumentoBemVO);
  ConfiguraGridFromVO(GridDocumentacao, TPatrimDocumentoBemVO);

  ConfiguraCDSFromVO(CDSPatrimDepreciacaoBem, TPatrimDepreciacaoBemVO);
  ConfiguraGridFromVO(GridDepreciacao, TPatrimDepreciacaoBemVO);

  ConfiguraCDSFromVO(CDSPatrimMovimentacaoBem, TPatrimMovimentacaoBemVO);
  ConfiguraGridFromVO(GridMovimentacao, TPatrimMovimentacaoBemVO);
end;

procedure TFPatrimBem.LimparCampos;
var
  i: Integer;
begin
  inherited;

  CDSPatrimDocumentoBem.Close;
  CDSPatrimDepreciacaoBem.Close;
  CDSPatrimMovimentacaoBem.Close;
  CDSPatrimDocumentoBem.Open;
  CDSPatrimDepreciacaoBem.Open;
  CDSPatrimMovimentacaoBem.Open;

  ConfigurarLayoutTela;
end;

procedure TFPatrimBem.ConfigurarLayoutTela;
begin
  PanelEdits.Enabled := True;
  PageControlDadosPatrimBem.ActivePageIndex := 0;

  if StatusTela = stNavegandoEdits then
  begin
    PanelDadosComplementares.Enabled := False;
    GridDocumentacao.ReadOnly := True;
    GridDepreciacao.ReadOnly := True;
    GridMovimentacao.ReadOnly := True;
  end
  else
  begin
    PanelDadosComplementares.Enabled := True;
    GridDocumentacao.ReadOnly := False;
    GridDepreciacao.ReadOnly := False;
    GridMovimentacao.ReadOnly := False;
  end;
end;
{$ENDREGION}

{$REGION 'Controles CRUD'}
function TFPatrimBem.DoInserir: Boolean;
begin
  Result := inherited DoInserir;

  if Result then
  begin
    EditIdSetor.SetFocus;
  end;
end;

function TFPatrimBem.DoEditar: Boolean;
begin
  Result := inherited DoEditar;

  if Result then
  begin
    EditIdSetor.SetFocus;
  end;
end;

function TFPatrimBem.DoExcluir: Boolean;
begin
  if inherited DoExcluir then
  begin
    try
      Result := TPatrimBemController.Exclui(IdRegistroSelecionado);
    except
      Result := False;
    end;
  end
  else
  begin
    Result := False;
  end;

  if Result then
    BotaoConsultar.Click;
end;

function TFPatrimBem.DoSalvar: Boolean;
var
  DocumentoBemVO: TPatrimDocumentoBemVO;
  DepreciacaoBemVO: TPatrimDepreciacaoBemVO;
  MovimentacaoBemVO: TPatrimMovimentacaoBemVO;
begin
  Result := inherited DoSalvar;

  if Result then
  begin
    try
      if not Assigned(ObjetoVO) then
        ObjetoVO := TPatrimBemVO.Create;

      TPatrimBemVO(ObjetoVO).IdPatrimTipoAquisicaoBem := EditIdTipoAquisicao.AsInteger;
      TPatrimBemVO(ObjetoVO).PatrimTipoAquisicaoBemNome := EditTipoAquisicaoNome.Text;
      TPatrimBemVO(ObjetoVO).IdPatrimEstadoConservacao := EditIdEstadoConservacao.AsInteger;
      TPatrimBemVO(ObjetoVO).PatrimEstadoConservacaoNome := EditEstadoConservacaoNome.Text;
      TPatrimBemVO(ObjetoVO).IdPatrimGrupoBem := EditIdGrupoBem.AsInteger;
      TPatrimBemVO(ObjetoVO).PatrimGrupoBemNome := EditGrupoBemNome.Text;
      TPatrimBemVO(ObjetoVO).IdSetor := EditIdSetor.AsInteger;
      /// EXERCICIO: permita que o usuário informe o centro de resultado ou preencha de forma dinâmica
      TPatrimBemVO(ObjetoVO).IdCentroResultado := 1;
      TPatrimBemVO(ObjetoVO).SetorNome := EditSetorNome.Text;
      TPatrimBemVO(ObjetoVO).IdFornecedor := EditIdFornecedor.AsInteger;
      TPatrimBemVO(ObjetoVO).FornecedorPessoaNome := EditFornecedorNome.Text;
      TPatrimBemVO(ObjetoVO).IdColaborador := EditIdColaborador.AsInteger;
      TPatrimBemVO(ObjetoVO).ColaboradorPessoaNome := EditColaboradorNome.Text;
      TPatrimBemVO(ObjetoVO).NumeroNb := EditNumero.Text;
      TPatrimBemVO(ObjetoVO).Nome := EditNome.Text;
      TPatrimBemVO(ObjetoVO).Descricao := MemoDescricao.Text;
      TPatrimBemVO(ObjetoVO).NumeroSerie := EditNumeroSerie.Text;
      TPatrimBemVO(ObjetoVO).DataAquisicao := EditDataAquisicao.Date;
      TPatrimBemVO(ObjetoVO).DataAceite := EditDataAceite.Date;
      TPatrimBemVO(ObjetoVO).DataCadastro := EditDataCadastro.Date;
      TPatrimBemVO(ObjetoVO).DataContabilizado := EditDataContabilizado.Date;
      TPatrimBemVO(ObjetoVO).DataVistoria := EditDataVistoria.Date;
      TPatrimBemVO(ObjetoVO).DataMarcacao := EditDataMarcacao.Date;
      TPatrimBemVO(ObjetoVO).DataBaixa := EditDataBaixa.Date;
      TPatrimBemVO(ObjetoVO).VencimentoGarantia := EditDataVencimentoGarantia.Date;
      TPatrimBemVO(ObjetoVO).NumeroNotaFiscal := EditNumeroNF.Text;
      TPatrimBemVO(ObjetoVO).ChaveNfe := EditChaveNFe.Text;
      TPatrimBemVO(ObjetoVO).ValorOriginal := EditValorOriginal.Value;
      TPatrimBemVO(ObjetoVO).ValorCompra := EditValorCompra.Value;
      TPatrimBemVO(ObjetoVO).ValorAtualizado := EditValorAtualizado.Value;
      TPatrimBemVO(ObjetoVO).ValorBaixa := EditValorBaixa.Value;
      TPatrimBemVO(ObjetoVO).Deprecia := Copy(ComboDeprecia.Text, 1, 1);
      TPatrimBemVO(ObjetoVO).MetodoDepreciacao := Copy(ComboMetodoDepreciacao.Text, 1, 1);
      TPatrimBemVO(ObjetoVO).InicioDepreciacao := EditInicioDepreciacao.Date;
      TPatrimBemVO(ObjetoVO).UltimaDepreciacao := EditUltimaDepreciacao.Date;
      TPatrimBemVO(ObjetoVO).TipoDepreciacao := Copy(ComboTipoDepreciacao.Text, 1, 1);
      TPatrimBemVO(ObjetoVO).TaxaAnualDepreciacao := EditTaxaAnualDepreciacao.Value;
      TPatrimBemVO(ObjetoVO).TaxaMensalDepreciacao := EditTaxaMensalDepreciacao.Value;
      TPatrimBemVO(ObjetoVO).TaxaDepreciacaoAcelerada := EditTaxaDepreciacaoAcelerada.Value;
      TPatrimBemVO(ObjetoVO).TaxaDepreciacaoIncentivada := EditTaxaDepreciacaoIncentivada.Value;
      TPatrimBemVO(ObjetoVO).Funcao := MemoFuncao.Text;

      // Documento
      CDSPatrimDocumentoBem.DisableControls;
      CDSPatrimDocumentoBem.First;
      while not CDSPatrimDocumentoBem.Eof do
      begin
        DocumentoBemVO := TPatrimDocumentoBemVO.Create;
        DocumentoBemVO.Id := CDSPatrimDocumentoBem.FieldByName('ID').AsInteger;
        DocumentoBemVO.IdPatrimBem := TPatrimBemVO(ObjetoVO).Id;
        DocumentoBemVO.Nome := CDSPatrimDocumentoBem.FieldByName('NOME').AsString;
        DocumentoBemVO.Descricao := CDSPatrimDocumentoBem.FieldByName('DESCRICAO').AsString;
        DocumentoBemVO.Imagem := CDSPatrimDocumentoBem.FieldByName('IMAGEM').AsString;
        TPatrimBemVO(ObjetoVO).ListaPatrimDocumentoBemVO.Add(DocumentoBemVO);
        CDSPatrimDocumentoBem.Next;
      end;
      CDSPatrimDocumentoBem.First;
      CDSPatrimDocumentoBem.EnableControls;

      // Depreciação
      CDSPatrimDepreciacaoBem.DisableControls;
      CDSPatrimDepreciacaoBem.First;
      while not CDSPatrimDepreciacaoBem.Eof do
      begin
        DepreciacaoBemVO := TPatrimDepreciacaoBemVO.Create;
        DepreciacaoBemVO.Id := CDSPatrimDepreciacaoBem.FieldByName('ID').AsInteger;
        DepreciacaoBemVO.IdPatrimBem := TPatrimBemVO(ObjetoVO).Id;
        DepreciacaoBemVO.DataDepreciacao := CDSPatrimDepreciacaoBem.FieldByName('DATA_DEPRECIACAO').AsDateTime;
        DepreciacaoBemVO.Dias := CDSPatrimDepreciacaoBem.FieldByName('DIAS').AsInteger;
        DepreciacaoBemVO.Taxa := CDSPatrimDepreciacaoBem.FieldByName('TAXA').AsFloat;
        DepreciacaoBemVO.Indice := CDSPatrimDepreciacaoBem.FieldByName('INDICE').AsFloat;
        DepreciacaoBemVO.Valor := CDSPatrimDepreciacaoBem.FieldByName('VALOR').AsFloat;
        DepreciacaoBemVO.DepreciacaoAcumulada := CDSPatrimDepreciacaoBem.FieldByName('DEPRECIACAO_ACUMULADA').AsFloat;
        TPatrimBemVO(ObjetoVO).ListaPatrimDepreciacaoBemVO.Add(DepreciacaoBemVO);
        CDSPatrimDepreciacaoBem.Next;
      end;
      CDSPatrimDepreciacaoBem.First;
      CDSPatrimDepreciacaoBem.EnableControls;

      // Movimentação
      CDSPatrimMovimentacaoBem.DisableControls;
      CDSPatrimMovimentacaoBem.First;
      while not CDSPatrimMovimentacaoBem.Eof do
      begin
        MovimentacaoBemVO := TPatrimMovimentacaoBemVO.Create;
        MovimentacaoBemVO.Id := CDSPatrimMovimentacaoBem.FieldByName('ID').AsInteger;
        MovimentacaoBemVO.IdPatrimBem := TPatrimBemVO(ObjetoVO).Id;
        MovimentacaoBemVO.IdPatrimTipoMovimentacao := CDSPatrimMovimentacaoBem.FieldByName('ID_PATRIM_TIPO_MOVIMENTACAO').AsInteger;
        //MovimentacaoBemVO.PatrimTipoMovimentacaoNome := CDSPatrimMovimentacaoBem.FieldByName('PATRIM_TIPO_MOVIMENTACAONOME').AsString;
        MovimentacaoBemVO.DataMovimentacao := CDSPatrimMovimentacaoBem.FieldByName('DATA_MOVIMENTACAO').AsDateTime;
        MovimentacaoBemVO.Responsavel := CDSPatrimMovimentacaoBem.FieldByName('RESPONSAVEL').AsString;
        TPatrimBemVO(ObjetoVO).ListaPatrimMovimentacaoBemVO.Add(MovimentacaoBemVO);
        CDSPatrimMovimentacaoBem.Next;
      end;
      CDSPatrimMovimentacaoBem.First;
      CDSPatrimMovimentacaoBem.EnableControls;

      if StatusTela = stInserindo then
      begin
        TPatrimBemController.Insere(TPatrimBemVO(ObjetoVO));
      end
      else if StatusTela = stEditando then
      begin
        /// EXERCICIO: Verifique se tem como serializar as listas junto com o objeto para realizar a comparação
        //if TPatrimBemVO(ObjetoVO).ToJSONString <> StringObjetoOld then
        //begin
          TPatrimBemController.Altera(TPatrimBemVO(ObjetoVO));
        //end
        //else
        //Application.MessageBox('Nenhum dado foi alterado.', 'Mensagem do Sistema', MB_OK + MB_ICONINFORMATION);
      end;
    except
      Result := False;
    end;
  end;
end;
{$ENDREGION}

{$REGION 'Campos Transientes'}
/// EXERCICIO: Implemente a busca pela janela de lookup
procedure TFPatrimBem.EditIdTipoAquisicaoKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  Filtro: String;
  PatrimTipoAquisicaoBemVO :TPatrimTipoAquisicaoBemVO;
begin
  if Key = VK_F1 then
  begin
    if EditIdTipoAquisicao.Value <> 0 then
      Filtro := 'ID = ' + EditIdTipoAquisicao.Text
    else
      Filtro := 'ID=0';

    try
      EditIdTipoAquisicao.Clear;
      EditTipoAquisicaoNome.Clear;

      PatrimTipoAquisicaoBemVO := TPatrimTipoAquisicaoBemController.ConsultaObjeto(Filtro);
      if Assigned(PatrimTipoAquisicaoBemVO) then
      begin
        EditTipoAquisicaoNome.Text := PatrimTipoAquisicaoBemVO.Nome;
      end
      else
      begin
        Exit;
      end;
    finally
      EditIdEstadoConservacao.SetFocus;
    end;
  end;
end;

procedure TFPatrimBem.EditIdColaboradorKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  Filtro: String;
  ViewPessoaColaboradorVO :TViewPessoaColaboradorVO ;
begin
  if Key = VK_F1 then
  begin
    if EditIdColaborador.Value <> 0 then
      Filtro := 'ID = ' + EditIdColaborador.Text
    else
      Filtro := 'ID=0';

    try
      EditIdColaborador.Clear;
      EditColaboradorNome.Clear;

      ViewPessoaColaboradorVO := TViewPessoaColaboradorController.ConsultaObjeto(Filtro);
      if Assigned(ViewPessoaColaboradorVO) then
      begin
        EditColaboradorNome.Text := ViewPessoaColaboradorVO.Nome;
      end
      else
      begin
        Exit;
        EditIdFornecedor.SetFocus;
      end;
    finally
    end;
  end;
end;

procedure TFPatrimBem.EditIdEstadoConservacaoKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  Filtro: String;
  PatrimEstadoConservacaoVO :TPatrimEstadoConservacaoVO ;
begin
  if Key = VK_F1 then
  begin
    if EditIdEstadoConservacao.Value <> 0 then
      Filtro := 'ID = ' + EditIdEstadoConservacao.Text
    else
      Filtro := 'ID=0';

    try
      EditIdEstadoConservacao.Clear;
      EditEstadoConservacaoNome.Clear;

      PatrimEstadoConservacaoVO := TPatrimEstadoConservacaoController.ConsultaObjeto(Filtro);
      if Assigned(PatrimEstadoConservacaoVO) then
      begin
        EditEstadoConservacaoNome.Text := PatrimEstadoConservacaoVO.Nome;
      end
      else
      begin
        Exit;
      end;
    finally
      EditNumero.SetFocus;
    end;
  end;
end;

procedure TFPatrimBem.EditIdFornecedorKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  Filtro: String;
  ViewPessoaFornecedorVO :TViewPessoaFornecedorVO ;
begin
  if Key = VK_F1 then
  begin
    if EditIdFornecedor.Value <> 0 then
      Filtro := 'ID = ' + EditIdFornecedor.Text
    else
      Filtro := 'ID=0';

    try
      EditIdFornecedor.Clear;
      EditFornecedorNome.Clear;

      ViewPessoaFornecedorVO := TViewPessoaFornecedorController.ConsultaObjeto(Filtro);
      if Assigned(ViewPessoaFornecedorVO) then
      begin
        EditFornecedorNome.Text := ViewPessoaFornecedorVO.Nome;
      end
      else
      begin
        Exit;
      end;
    finally
      EditIdGrupoBem.SetFocus;
    end;
  end;
end;

procedure TFPatrimBem.EditIdGrupoBemKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  Filtro: String;
  PatrimGrupoBemVO :TPatrimGrupoBemVO ;
begin
  if Key = VK_F1 then
  begin
    if EditIdGrupoBem.Value <> 0 then
      Filtro := 'ID = ' + EditIdGrupoBem.Text
    else
      Filtro := 'ID=0';

    try
      EditIdGrupoBem.Clear;
      EditGrupoBemNome.Clear;

      PatrimGrupoBemVO := TPatrimGrupoBemController.ConsultaObjeto(Filtro);
      if Assigned(PatrimGrupoBemVO) then
      begin
        EditGrupoBemNome.Text := PatrimGrupoBemVO.Nome;
      end
      else
      begin
        Exit;
      end;
    finally
      EditIdTipoAquisicao.SetFocus;
    end;
  end;
end;

procedure TFPatrimBem.EditIdSetorKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  Filtro: String;
  SetorVO :TSetorVO ;
begin
  if Key = VK_F1 then
  begin
    if EditIdSetor.Value <> 0 then
      Filtro := 'ID = ' + EditIdSetor.Text
    else
      Filtro := 'ID=0';

    try
      EditIdSetor.Clear;
      EditSetorNome.Clear;

      SetorVO := TSetorController.ConsultaObjeto(Filtro);
      if Assigned(SetorVO) then
      begin
        EditSetorNome.Text := SetorVO.Nome;
      end
      else
      begin
        Exit;
      end;
    finally
      EditIdColaborador.SetFocus;
    end;
  end;
end;
{$ENDREGION}

{$REGION 'Controle de Grid'}
procedure TFPatrimBem.GridParaEdits;
var
  IdCabecalho: String;
  i: Integer;
  DocumentoBem: TPatrimDocumentoBemVO;
  DepreciacaoBem: TPatrimDepreciacaoBemVO;
  MovimentacaoBem: TPatrimMovimentacaoBemVO;
begin
  inherited;

  if not CDSGrid.IsEmpty then
  begin
    IdCabecalho := IntToStr(IdRegistroSelecionado);
    ObjetoVO := TPatrimBemController.ConsultaObjeto('ID=' + IdCabecalho);
  end;

  if Assigned(ObjetoVO) then
  begin

    EditIdTipoAquisicao.AsInteger := TPatrimBemVO(ObjetoVO).IdPatrimTipoAquisicaoBem;
    EditIdEstadoConservacao.AsInteger := TPatrimBemVO(ObjetoVO).IdPatrimEstadoConservacao;
    EditIdGrupoBem.AsInteger := TPatrimBemVO(ObjetoVO).IdPatrimGrupoBem;
    EditIdSetor.AsInteger := TPatrimBemVO(ObjetoVO).IdSetor;
    EditIdFornecedor.AsInteger := TPatrimBemVO(ObjetoVO).IdFornecedor;
    EditIdColaborador.AsInteger := TPatrimBemVO(ObjetoVO).IdColaborador;
    EditTipoAquisicaoNome.Text := TPatrimBemVO(ObjetoVO).PatrimTipoAquisicaoBemNome;
    EditEstadoConservacaoNome.Text := TPatrimBemVO(ObjetoVO).PatrimEstadoConservacaoNome;
    EditGrupoBemNome.Text := TPatrimBemVO(ObjetoVO).PatrimGrupoBemNome;
    EditSetorNome.Text := TPatrimBemVO(ObjetoVO).SetorNome;
    EditFornecedorNome.Text := TPatrimBemVO(ObjetoVO).FornecedorPessoaNome;
    EditColaboradorNome.Text := TPatrimBemVO(ObjetoVO).ColaboradorPessoaNome;
    EditNumero.Text := TPatrimBemVO(ObjetoVO).NumeroNb;
    EditNome.Text := TPatrimBemVO(ObjetoVO).Nome;
    MemoDescricao.Text := TPatrimBemVO(ObjetoVO).Descricao;
    EditNumeroSerie.Text := TPatrimBemVO(ObjetoVO).NumeroSerie;
    EditDataAquisicao.Date := TPatrimBemVO(ObjetoVO).DataAquisicao;
    EditDataAceite.Date := TPatrimBemVO(ObjetoVO).DataAceite;
    EditDataCadastro.Date := TPatrimBemVO(ObjetoVO).DataCadastro;
    EditDataContabilizado.Date := TPatrimBemVO(ObjetoVO).DataContabilizado;
    EditDataVistoria.Date := TPatrimBemVO(ObjetoVO).DataVistoria;
    EditDataMarcacao.Date := TPatrimBemVO(ObjetoVO).DataMarcacao;
    EditDataBaixa.Date := TPatrimBemVO(ObjetoVO).DataBaixa;
    EditDataVencimentoGarantia.Date := TPatrimBemVO(ObjetoVO).VencimentoGarantia;
    EditNumeroNF.Text := TPatrimBemVO(ObjetoVO).NumeroNotaFiscal;
    EditChaveNFe.Text := TPatrimBemVO(ObjetoVO).ChaveNfe;
    EditValorOriginal.Value := TPatrimBemVO(ObjetoVO).ValorOriginal;
    EditValorCompra.Value := TPatrimBemVO(ObjetoVO).ValorCompra;
    EditValorAtualizado.Value := TPatrimBemVO(ObjetoVO).ValorAtualizado;
    EditValorBaixa.Value := TPatrimBemVO(ObjetoVO).ValorBaixa;

    case AnsiIndexStr(TPatrimBemVO(ObjetoVO).Deprecia, ['S', 'N']) of
      0:
        ComboDeprecia.ItemIndex := 0;
      1:
        ComboDeprecia.ItemIndex := 1;
    else
      ComboDeprecia.ItemIndex := -1;
    end;

    case AnsiIndexStr(TPatrimBemVO(ObjetoVO).MetodoDepreciacao, ['1', '2', '3', '4']) of
      0:
        ComboMetodoDepreciacao.ItemIndex := 0;
      1:
        ComboMetodoDepreciacao.ItemIndex := 1;
      2:
        ComboMetodoDepreciacao.ItemIndex := 2;
      3:
        ComboMetodoDepreciacao.ItemIndex := 3;
    else
      ComboMetodoDepreciacao.ItemIndex := -1;
    end;

    EditInicioDepreciacao.Date := TPatrimBemVO(ObjetoVO).InicioDepreciacao;
    EditUltimaDepreciacao.Date := TPatrimBemVO(ObjetoVO).UltimaDepreciacao;

    case AnsiIndexStr(TPatrimBemVO(ObjetoVO).TipoDepreciacao, ['N', 'A', 'I']) of
      0:
        ComboTipoDepreciacao.ItemIndex := 0;
      1:
        ComboTipoDepreciacao.ItemIndex := 1;
      2:
        ComboTipoDepreciacao.ItemIndex := 2;
    else
      ComboTipoDepreciacao.ItemIndex := -1;
    end;

    EditTaxaAnualDepreciacao.Value := TPatrimBemVO(ObjetoVO).TaxaAnualDepreciacao;
    EditTaxaMensalDepreciacao.Value := TPatrimBemVO(ObjetoVO).TaxaMensalDepreciacao;
    EditTaxaDepreciacaoAcelerada.Value := TPatrimBemVO(ObjetoVO).TaxaDepreciacaoAcelerada;
    EditTaxaDepreciacaoIncentivada.Value := TPatrimBemVO(ObjetoVO).TaxaDepreciacaoIncentivada;
    MemoFuncao.Text := TPatrimBemVO(ObjetoVO).Funcao;

    // Documento
    for I := 0 to TPatrimBemVO(ObjetoVO).ListaPatrimDocumentoBemVO.Count - 1 do
    begin
      DocumentoBem := TPatrimBemVO(ObjetoVO).ListaPatrimDocumentoBemVO[I];

      CDSPatrimDocumentoBem.Append;

      CDSPatrimDocumentoBem.FieldByName('ID').AsInteger := DocumentoBem.Id;
      CDSPatrimDocumentoBem.FieldByName('ID_PATRIM_BEM').AsInteger := DocumentoBem.IdPatrimBem;
      CDSPatrimDocumentoBem.FieldByName('NOME').AsString := DocumentoBem.Nome;
      CDSPatrimDocumentoBem.FieldByName('DESCRICAO').AsString := DocumentoBem.Descricao;
      CDSPatrimDocumentoBem.FieldByName('IMAGEM').AsString := DocumentoBem.Imagem;

      CDSPatrimDocumentoBem.Post;
    end;

    // Depreciação
    for I := 0 to TPatrimBemVO(ObjetoVO).ListaPatrimDepreciacaoBemVO.Count - 1 do
    begin
      DepreciacaoBem := TPatrimBemVO(ObjetoVO).ListaPatrimDepreciacaoBemVO[I];

      CDSPatrimDepreciacaoBem.Append;

      CDSPatrimDepreciacaoBem.FieldByName('ID').AsInteger := DepreciacaoBem.Id;
      CDSPatrimDepreciacaoBem.FieldByName('ID_PATRIM_BEM').AsInteger := DepreciacaoBem.IdPatrimBem;
      CDSPatrimDepreciacaoBem.FieldByName('DATA_DEPRECIACAO').AsDateTime := DepreciacaoBem.DataDepreciacao;
      CDSPatrimDepreciacaoBem.FieldByName('DIAS').AsInteger := DepreciacaoBem.Dias;
      CDSPatrimDepreciacaoBem.FieldByName('TAXA').AsFloat := DepreciacaoBem.Taxa;
      CDSPatrimDepreciacaoBem.FieldByName('INDICE').AsFloat := DepreciacaoBem.Indice;
      CDSPatrimDepreciacaoBem.FieldByName('VALOR').AsFloat := DepreciacaoBem.Valor;
      CDSPatrimDepreciacaoBem.FieldByName('DEPRECIACAO_ACUMULADA').AsFloat := DepreciacaoBem.DepreciacaoAcumulada;

      CDSPatrimDepreciacaoBem.Post;
    end;

    // Movimentação
    for I := 0 to TPatrimBemVO(ObjetoVO).ListaPatrimMovimentacaoBemVO.Count - 1 do
    begin
      MovimentacaoBem := TPatrimBemVO(ObjetoVO).ListaPatrimMovimentacaoBemVO[I];

      CDSPatrimMovimentacaoBem.Append;

      CDSPatrimMovimentacaoBem.FieldByName('ID').AsInteger := MovimentacaoBem.Id;
      CDSPatrimMovimentacaoBem.FieldByName('ID_PATRIM_BEM').AsInteger := MovimentacaoBem.IdPatrimBem;
      CDSPatrimMovimentacaoBem.FieldByName('ID_PATRIM_TIPO_MOVIMENTACAO').AsInteger := MovimentacaoBem.IdPatrimTipoMovimentacao;
      //CDSPatrimMovimentacaoBem.FieldByName('PATRIM_TIPO_MOVIMENTACAONOME').AsString := MovimentacaoBem.PatrimTipoMovimentacaoVO.Nome;
      CDSPatrimMovimentacaoBem.FieldByName('DATA_MOVIMENTACAO').AsDateTime := MovimentacaoBem.DataMovimentacao;
      CDSPatrimMovimentacaoBem.FieldByName('RESPONSAVEL').AsString := MovimentacaoBem.Responsavel;

      CDSPatrimMovimentacaoBem.Post;
    end;

    // Serializa o objeto para consultar posteriormente se houve alterações
    FormatSettings.DecimalSeparator := '.';
    StringObjetoOld := ObjetoVO.ToJSONString;
    FormatSettings.DecimalSeparator := ',';
  end;
end;

procedure TFPatrimBem.GridDocumentacaoKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  If Key = VK_RETURN then
    GridDocumentacao.SelectedIndex := GridDocumentacao.SelectedIndex + 1;
end;

procedure TFPatrimBem.GridDepreciacaoKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  If Key = VK_RETURN then
    GridDepreciacao.SelectedIndex := GridDepreciacao.SelectedIndex + 1;
end;
{$ENDREGION}

{$REGION 'Actions'}
procedure TFPatrimBem.ActionAcionarGedExecute(Sender: TObject);
var
  Parametros: String;
begin
  if not CDSPatrimDocumentoBem.IsEmpty then
  begin
    {
      Parametros
      1 - Login
      2 - Senha
      3 - Aplicação que chamou
      4 - Nome do arquivo (Aplicacao que chamou + Tela que chamou + Numero Apólice
      }

    try
      CDSPatrimDocumentoBem.Edit;
      CDSPatrimDocumentoBem.FieldByName('IMAGEM').AsString := 'PATRIMONIO_BEM_' + EditNumero.Text + '_' + MD5Print(MD5String(CDSPatrimDocumentoBem.FieldByName('NOME').AsString));
      CDSPatrimDocumentoBem.Post;

      Parametros := Sessao.Usuario.Login + ' ' +
                    Sessao.Usuario.Senha + ' ' +
                    'PATRIMONIO' + ' ' +
                    'PATRIMONIO_BEM_' + EditNumero.Text + '_' + MD5Print(MD5String(CDSPatrimDocumentoBem.FieldByName('NOME').AsString));
       OpenDocument('T2TiERPGed.exe'); /// EXERCICIO: Chame o GED e passe os parâmetros acima para que ele armazene o documento
    except
      Application.MessageBox('Erro ao tentar executar o módulo.', 'Erro do Sistema', MB_OK + MB_ICONERROR);
    end;
  end
  else
  begin
    Application.MessageBox('É preciso adicionar os dados de um documento ao bem.', 'Mensagem do Sistema', MB_OK + MB_ICONINFORMATION);
    GridDocumentacao.SetFocus;
    GridDocumentacao.SelectedIndex := 1;
  end;
end;

procedure TFPatrimBem.ActionCalcularDepreciacaoExecute(Sender: TObject);
begin
  CDSPatrimDepreciacaoBem.Append;
  CDSPatrimDepreciacaoBem.FieldByName('DATA_DEPRECIACAO').AsDateTime := Date;
  CDSPatrimDepreciacaoBem.FieldByName('DIAS').AsInteger := StrToInt(FormatDateTime('dd', Date));

  //Normal
  if ComboTipoDepreciacao.ItemIndex = 0 then
  begin
    CDSPatrimDepreciacaoBem.FieldByName('TAXA').AsFloat := EditTaxaMensalDepreciacao.Value;
    CDSPatrimDepreciacaoBem.FieldByName('INDICE').AsFloat := (CDSPatrimDepreciacaoBem.FieldByName('DIAS').AsInteger / 30) * EditTaxaMensalDepreciacao.Value;
  end;

  //Acelerada
  if ComboTipoDepreciacao.ItemIndex = 1 then
  begin
    CDSPatrimDepreciacaoBem.FieldByName('TAXA').AsFloat := EditTaxaDepreciacaoAcelerada.Value;
    CDSPatrimDepreciacaoBem.FieldByName('INDICE').AsFloat := (CDSPatrimDepreciacaoBem.FieldByName('DIAS').AsInteger / 30) * EditTaxaDepreciacaoAcelerada.Value;
  end;

  //Incentivada
  if ComboTipoDepreciacao.ItemIndex = 2 then
  begin
    CDSPatrimDepreciacaoBem.FieldByName('TAXA').AsFloat := EditTaxaDepreciacaoIncentivada.Value;
    CDSPatrimDepreciacaoBem.FieldByName('INDICE').AsFloat := (CDSPatrimDepreciacaoBem.FieldByName('DIAS').AsInteger / 30) * EditTaxaDepreciacaoIncentivada.Value;
  end;

  CDSPatrimDepreciacaoBem.FieldByName('VALOR').AsFloat := EditValorOriginal.Value * CDSPatrimDepreciacaoBem.FieldByName('INDICE').AsFloat;
  CDSPatrimDepreciacaoBem.FieldByName('DEPRECIACAO_ACUMULADA').AsFloat := EditValorOriginal.Value - CDSPatrimDepreciacaoBem.FieldByName('VALOR').AsFloat;
  CDSPatrimDepreciacaoBem.Post;
end;
{$ENDREGION}

end.

