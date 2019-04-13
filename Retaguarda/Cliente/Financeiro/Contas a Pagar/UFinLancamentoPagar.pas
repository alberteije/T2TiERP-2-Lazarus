{ *******************************************************************************
Title: T2Ti ERP
Description: Janela Lançamento a Pagar

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

@author Albert Eije (t2ti.com@gmail.com)
@version 2.0
******************************************************************************* }
unit UFinLancamentoPagar;

{$MODE Delphi}

interface

uses
  BrookHTTPClient, BrookFCLHTTPClientBroker, BrookHTTPUtils, BrookUtils, FPJson, ZDataset,
  LCLIntf, LCLType, LMessages, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UTelaCadastro, Menus, StdCtrls, ExtCtrls, Buttons, Grids, DBGrids,
  ComCtrls, LabeledCtrls, rxdbgrid, rxtoolbar, DBCtrls, StrUtils,
  Math, Constantes, CheckLst, ActnList, ToolWin, db, BufDataset, Biblioteca,
  ULookup, VO, AdmParametroVO, FinLancamentoPagarVO,
  FinLancamentoPagarController;

  
  type

  { TFFinLancamentoPagar }

  TFFinLancamentoPagar = class(TFTelaCadastro)
    ActionManager: TActionList;
    ActionGerarParcelas: TAction;
    CDSParcelaPagar: TBufDataset;
    CDSLancamentoNaturezaFinanceira: TBufDataset;
    PanelParcelas: TPanel;
    PanelMestre: TPanel;
    EditIdFornecedor: TLabeledCalcEdit;
    EditFornecedor: TLabeledEdit;
    EditIdDocumentoOrigem: TLabeledCalcEdit;
    EditDocumentoOrigem: TLabeledEdit;
    ComboBoxPagamentoCompartilhado: TLabeledComboBox;
    EditImagemDocumento: TLabeledEdit;
    EditPrimeiroVencimento: TLabeledDateEdit;
    EditQuantidadeParcelas: TLabeledCalcEdit;
    EditValorAPagar: TLabeledCalcEdit;
    EditValorTotal: TLabeledCalcEdit;
    EditDataLancamento: TLabeledDateEdit;
    DSParcelaPagar: TDataSource;
    PageControlItensLancamento: TPageControl;
    tsItens: TTabSheet;
    PanelItensLancamento: TPanel;
    GridParcelas: TRxDbGrid;
    ActionToolBarEdits: TToolPanel;
    EditNumeroDocumento: TLabeledEdit;
    EditIntervalorEntreParcelas: TLabeledCalcEdit;
    PanelContaCaixa: TPanel;
    EditIdContaCaixa: TLabeledCalcEdit;
    EditContaCaixa: TLabeledEdit;
    CDSParcelaPagarCONTA_CAIXANOME: TStringField;
    ActionAcionarGed: TAction;
    tsNaturezaFinanceira: TTabSheet;
    PanelNaturezaFinanceira: TPanel;
    JvDBUltimGrid1: TRxDbGrid;
    DSLancamentoNaturezaFinanceira: TDataSource;
    ActionGerarPagamentoFixo: TAction;
    procedure FormCreate(Sender: TObject);
    procedure ActionGerarParcelasExecute(Sender: TObject);
    procedure GridDblClick(Sender: TObject);
    procedure GridParcelasKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure CDSParcelaPagarBeforeDelete(DataSet: TDataSet);
    procedure CDSParcelaPagarAfterPost(DataSet: TDataSet);
    procedure GerarParcelas;
    procedure ActionAcionarGedExecute(Sender: TObject);
    procedure JvDBUltimGrid1KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure CDSLancamentoNaturezaFinanceiraAfterPost(DataSet: TDataSet);
    procedure EditIdFornecedorKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure EditIdDocumentoOrigemKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure EditIdContaCaixaKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure CDSLancamentoNaturezaFinanceiraBeforePost(DataSet: TDataSet);
    procedure ActionGerarPagamentoFixoExecute(Sender: TObject);
    procedure BotaoConsultarClick(Sender: TObject);
    procedure BotaoSalvarClick(Sender: TObject);
  private
    { Private declarations }
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
    function VerificarTotalNaturezaFinanceira: Boolean;
  end;

var
  FFinLancamentoPagar: TFFinLancamentoPagar;
  AdmParametroVO: TAdmParametroVO;

implementation

uses UDataModule, PessoaVO, PessoaController,
  FinDocumentoOrigemVO, FinDocumentoOrigemController, FinParcelaPagarVO,
  FinParcelaPagarController, ContaCaixaVO, ContaCaixaController, ViewPessoaFornecedorVO,
  ViewPessoaFornecedorController, NaturezaFinanceiraVO, NaturezaFinanceiraController,
  FinLctoPagarNtFinanceiraVO, AdmParametroController, FinPagamentoFixoVO, FinPagamentoFixoController;
{$R *.lfm}

{$REGION 'Infra'}
procedure TFFinLancamentoPagar.BotaoConsultarClick(Sender: TObject);
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
    RetornoConsulta := TFinLancamentoPagarController.Consulta(Filtro, IntToStr(Pagina));
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

procedure TFFinLancamentoPagar.BotaoSalvarClick(Sender: TObject);
begin
  inherited;
  BotaoConsultarClick(Sender);
end;

procedure TFFinLancamentoPagar.FormCreate(Sender: TObject);
var
  Filtro: String;
begin
  ClasseObjetoGridVO := TFinLancamentoPagarVO;
  ObjetoController := TFinLancamentoPagarController.Create;

  inherited;

  Filtro := 'ID_EMPRESA = ' + IntToStr(Sessao.Empresa.Id);
  AdmParametroVO := TAdmParametroController.ConsultaObjeto(Filtro);

  /// EXERCICIO: Pense numa maneira de esconder a coluna "mesclar pagamento" que será utilizada na janela de mesclagem
  // Grid.Columns.Items[0].Visible := False;

  ConfiguraCDSFromVO(CDSParcelaPagar, TFinParcelaPagarVO);
  ConfiguraCDSFromVO(CDSLancamentoNaturezaFinanceira, TFinLctoPagarNtFinanceiraVO);
end;

procedure TFFinLancamentoPagar.LimparCampos;
begin
  inherited;
  CDSParcelaPagar.Close;
  CDSLancamentoNaturezaFinanceira.Close;
  CDSParcelaPagar.Open;
  CDSLancamentoNaturezaFinanceira.Open;
end;

procedure TFFinLancamentoPagar.ConfigurarLayoutTela;
begin
  PanelEdits.Enabled := True;

  if StatusTela = stNavegandoEdits then
  begin
    PanelMestre.Enabled := False;
    PanelItensLancamento.Enabled := False;
    ActionGerarParcelas.Enabled := False;
  end
  else
  begin
    PanelMestre.Enabled := True;
    PanelItensLancamento.Enabled := True;
    ActionGerarParcelas.Enabled := True;
  end;
end;

function TFFinLancamentoPagar.VerificarTotalNaturezaFinanceira: Boolean;
var
  Total: Extended;
begin
  Total := 0;
  CDSLancamentoNaturezaFinanceira.DisableControls;
  CDSLancamentoNaturezaFinanceira.First;
  while not CDSLancamentoNaturezaFinanceira.Eof do
  begin
    Total := Total + CDSLancamentoNaturezaFinanceira.FieldByName('VALOR').AsFloat;
    CDSLancamentoNaturezaFinanceira.Next;
  end;
  CDSLancamentoNaturezaFinanceira.First;
  CDSLancamentoNaturezaFinanceira.EnableControls;
  Result := (Total = EditValorAPagar.Value);
end;
{$ENDREGION}

{$REGION 'Controles CRUD'}
function TFFinLancamentoPagar.DoInserir: Boolean;
begin
  Result := inherited DoInserir;

  if Result then
  begin
    EditIdFornecedor.SetFocus;
  end;
end;

function TFFinLancamentoPagar.DoEditar: Boolean;
begin
  Result := inherited DoEditar;

  if Result then
  begin
    EditIdFornecedor.SetFocus;
  end;
end;

function TFFinLancamentoPagar.DoExcluir: Boolean;
begin
  if inherited DoExcluir then
  begin
    try
      Result := TFinLancamentoPagarController.Exclui(IdRegistroSelecionado);
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

function TFFinLancamentoPagar.DoSalvar: Boolean;
var
  ParcelaPagar: TFinParcelaPagarVO;
  LancamentoNaturezaFinanceira: TFinLctoPagarNtFinanceiraVO;
begin
  if not CDSLancamentoNaturezaFinanceira.IsEmpty then
  begin
    if not VerificarTotalNaturezaFinanceira then begin
      Application.MessageBox('Os valores informados nas naturezas financeiras não batem com o valor a pagar.', 'Mensagem do Sistema', MB_OK + MB_ICONINFORMATION);
      Exit(False);
    end;
  end;

  Result := inherited DoSalvar;

  if Result then
  begin
    try
      if not Assigned(ObjetoVO) then
        ObjetoVO := TFinLancamentoPagarVO.Create;

      TFinLancamentoPagarVO(ObjetoVO).IdFornecedor := EditIdFornecedor.AsInteger;
      TFinLancamentoPagarVO(ObjetoVO).FornecedorNome := EditFornecedor.Text;
      TFinLancamentoPagarVO(ObjetoVO).IdFinDocumentoOrigem := EditIdDocumentoOrigem.AsInteger;
      TFinLancamentoPagarVO(ObjetoVO).DocumentoOrigemSigla := EditDocumentoOrigem.Text;
      TFinLancamentoPagarVO(ObjetoVO).PagamentoCompartilhado := IfThen(ComboBoxPagamentoCompartilhado.ItemIndex = 0, 'S', 'N');
      TFinLancamentoPagarVO(ObjetoVO).QuantidadeParcela := EditQuantidadeParcelas.AsInteger;
      TFinLancamentoPagarVO(ObjetoVO).ValorTotal := EditValorTotal.Value;
      TFinLancamentoPagarVO(ObjetoVO).ValorAPagar := EditValorAPagar.Value;
      TFinLancamentoPagarVO(ObjetoVO).DataLancamento := EditDataLancamento.Date;
      TFinLancamentoPagarVO(ObjetoVO).NumeroDocumento := EditNumeroDocumento.Text;
      TFinLancamentoPagarVO(ObjetoVO).ImagemDocumento := EditImagemDocumento.Text;
      TFinLancamentoPagarVO(ObjetoVO).PrimeiroVencimento := EditPrimeiroVencimento.Date;
      TFinLancamentoPagarVO(ObjetoVO).IntervaloEntreParcelas := EditIntervalorEntreParcelas.AsInteger;

      // Parcelas
      CDSParcelaPagar.DisableControls;
      CDSParcelaPagar.First;
      while not CDSParcelaPagar.Eof do
      begin
          ParcelaPagar := TFinParcelaPagarVO.Create;
          ParcelaPagar.Id := CDSParcelaPagar.FieldByName('ID').AsInteger;
          ParcelaPagar.IdFinLancamentoPagar := TFinLancamentoPagarVO(ObjetoVO).Id;
          ParcelaPagar.IdContaCaixa := CDSParcelaPagar.FieldByName('ID_CONTA_CAIXA').AsInteger;
          ParcelaPagar.IdFinStatusParcela := AdmParametroVO.FinParcelaAberto;
          ParcelaPagar.NumeroParcela := CDSParcelaPagar.FieldByName('NUMERO_PARCELA').AsInteger;
          ParcelaPagar.DataEmissao := CDSParcelaPagar.FieldByName('DATA_EMISSAO').AsDateTime;
          ParcelaPagar.DataVencimento := CDSParcelaPagar.FieldByName('DATA_VENCIMENTO').AsDateTime;
          ParcelaPagar.DescontoAte := CDSParcelaPagar.FieldByName('DESCONTO_ATE').AsDateTime;
          ParcelaPagar.SofreRetencao := CDSParcelaPagar.FieldByName('SOFRE_RETENCAO').AsString;
          ParcelaPagar.Valor := CDSParcelaPagar.FieldByName('VALOR').AsFloat;

          ParcelaPagar.TaxaJuro := CDSParcelaPagar.FieldByName('TAXA_JURO').AsFloat;
          ParcelaPagar.TaxaMulta := CDSParcelaPagar.FieldByName('TAXA_MULTA').AsFloat;
          ParcelaPagar.TaxaDesconto := CDSParcelaPagar.FieldByName('TAXA_DESCONTO').AsFloat;
          ParcelaPagar.ValorJuro := CDSParcelaPagar.FieldByName('VALOR_JURO').AsFloat;
          ParcelaPagar.ValorMulta := CDSParcelaPagar.FieldByName('VALOR_MULTA').AsFloat;
          ParcelaPagar.ValorDesconto := CDSParcelaPagar.FieldByName('VALOR_DESCONTO').AsFloat;

          TFinLancamentoPagarVO(ObjetoVO).ListaParcelaPagarVO.Add(ParcelaPagar);

        CDSParcelaPagar.Next;
      end;
      CDSParcelaPagar.EnableControls;

      // Natureza Financeira
      CDSLancamentoNaturezaFinanceira.DisableControls;
      CDSLancamentoNaturezaFinanceira.First;
      while not CDSLancamentoNaturezaFinanceira.Eof do
      begin
          LancamentoNaturezaFinanceira := TFinLctoPagarNtFinanceiraVO.Create;

          LancamentoNaturezaFinanceira.Id := CDSLancamentoNaturezaFinanceira.FieldByName('ID').AsInteger;
          LancamentoNaturezaFinanceira.IdFinLancamentoPagar := CDSLancamentoNaturezaFinanceira.FieldByName('ID_FIN_LANCAMENTO_PAGAR').AsInteger;
          LancamentoNaturezaFinanceira.IdNaturezaFinanceira := CDSLancamentoNaturezaFinanceira.FieldByName('ID_NATUREZA_FINANCEIRA').AsInteger;
          LancamentoNaturezaFinanceira.DataInclusao := CDSLancamentoNaturezaFinanceira.FieldByName('DATA_INCLUSAO').AsDateTime;
          LancamentoNaturezaFinanceira.Valor := CDSLancamentoNaturezaFinanceira.FieldByName('VALOR').AsFloat;
          LancamentoNaturezaFinanceira.Percentual := CDSLancamentoNaturezaFinanceira.FieldByName('PERCENTUAL').AsFloat;

          TFinLancamentoPagarVO(ObjetoVO).ListaLancPagarNatFinanceiraVO.Add(LancamentoNaturezaFinanceira);

        CDSLancamentoNaturezaFinanceira.Next;
      end;
      CDSLancamentoNaturezaFinanceira.EnableControls;

      if StatusTela = stInserindo then
      begin
        TFinLancamentoPagarController.Insere(TFinLancamentoPagarVO(ObjetoVO));
      end
      else if StatusTela = stEditando then
      begin
        /// EXERCICIO: Verifique se tem como serializar as listas junto com o objeto para realizar a comparação
        //if TFinLancamentoPagarVO(ObjetoVO).ToJSONString <> StringObjetoOld then
        //begin
          TFinLancamentoPagarController.Altera(TFinLancamentoPagarVO(ObjetoVO));
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
procedure TFFinLancamentoPagar.EditIdFornecedorKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
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
      EditFornecedor.Clear;

        ViewPessoaFornecedorVO := TViewPessoaFornecedorController.ConsultaObjeto(Filtro);
        if Assigned(ViewPessoaFornecedorVO) then
      begin
        EditFornecedor.Text := ViewPessoaFornecedorVO.Nome;
      end
      else
      begin
        Exit;
      end;
    finally
      EditIdDocumentoOrigem.SetFocus;
    end;
  end;
end;

procedure TFFinLancamentoPagar.EditIdDocumentoOrigemKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  Filtro: String;
  FinDocumentoOrigemVO :TFinDocumentoOrigemVO ;
begin
  if Key = VK_F1 then
  begin
    if EditIdDocumentoOrigem.Value <> 0 then
      Filtro := 'ID = ' + EditIdDocumentoOrigem.Text
    else
      Filtro := 'ID=0';

    try
      EditDocumentoOrigem.Clear;

        FinDocumentoOrigemVO := TFinDocumentoOrigemController.ConsultaObjeto(Filtro);
        if Assigned(FinDocumentoOrigemVO) then
      begin
        EditDocumentoOrigem.Text := FinDocumentoOrigemVO.SiglaDocumento;
      end
      else
      begin
        Exit;
      end;
    finally
      EditNumeroDocumento.SetFocus;
    end;
  end;
end;

procedure TFFinLancamentoPagar.EditIdContaCaixaKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  Filtro: String;
  ContaCaixaVO :TContaCaixaVO ;
begin
  if Key = VK_F1 then
  begin
    if EditIdContaCaixa.Value <> 0 then
      Filtro := 'ID = ' + EditIdContaCaixa.Text
    else
      Filtro := 'ID=0';

    try
      EditContaCaixa.Clear;

        ContaCaixaVO := TContaCaixaController.ConsultaObjeto(Filtro);
        if Assigned(ContaCaixaVO) then
      begin
        EditContaCaixa.Text := ContaCaixaVO.Nome;
      end
      else
      begin
        Exit;
      end;
    finally
      GridParcelas.SetFocus;
    end;
  end;
end;
{$ENDREGION}

{$REGION 'Controle de Grid'}
procedure TFFinLancamentoPagar.GridDblClick(Sender: TObject);
begin
  inherited;
  ConfigurarLayoutTela;
end;

procedure TFFinLancamentoPagar.GridParaEdits;
var
  IdCabecalho: String;
  ParcelaPagar: TFinParcelaPagarVO;
  LancamentoNaturezaFinanceira: TFinLctoPagarNtFinanceiraVO;
  I: Integer;
begin
  inherited;

  if not CDSGrid.IsEmpty then
  begin
    IdCabecalho := IntToStr(IdRegistroSelecionado);
    ObjetoVO := TFinLancamentoPagarController.ConsultaObjeto('ID=' + IdCabecalho);
  end;

  if Assigned(ObjetoVO) then
  begin
    EditIdFornecedor.AsInteger := TFinLancamentoPagarVO(ObjetoVO).IdFornecedor;
    EditFornecedor.Text := TFinLancamentoPagarVO(ObjetoVO).FornecedorNome;
    EditIdDocumentoOrigem.AsInteger := TFinLancamentoPagarVO(ObjetoVO).IdFinDocumentoOrigem;
    EditDocumentoOrigem.Text := TFinLancamentoPagarVO(ObjetoVO).DocumentoOrigemSigla;
    ComboBoxPagamentoCompartilhado.ItemIndex := IfThen(TFinLancamentoPagarVO(ObjetoVO).PagamentoCompartilhado = 'S', 0, 1);
    EditQuantidadeParcelas.AsInteger := TFinLancamentoPagarVO(ObjetoVO).QuantidadeParcela;
    EditValorTotal.Value := TFinLancamentoPagarVO(ObjetoVO).ValorTotal;
    EditValorAPagar.Value := TFinLancamentoPagarVO(ObjetoVO).ValorAPagar;
    EditDataLancamento.Date := TFinLancamentoPagarVO(ObjetoVO).DataLancamento;
    EditNumeroDocumento.Text := TFinLancamentoPagarVO(ObjetoVO).NumeroDocumento;
    EditImagemDocumento.Text := TFinLancamentoPagarVO(ObjetoVO).ImagemDocumento;
    EditPrimeiroVencimento.Date := TFinLancamentoPagarVO(ObjetoVO).PrimeiroVencimento;
    EditIntervalorEntreParcelas.AsInteger := TFinLancamentoPagarVO(ObjetoVO).IntervaloEntreParcelas;

    if TFinLancamentoPagarVO(ObjetoVO).ListaParcelaPagarVO.Count > 0 then
    begin
      EditIdContaCaixa.AsInteger := TFinLancamentoPagarVO(ObjetoVO).ListaParcelaPagarVO[0].IdContaCaixa;
      //EditContaCaixa.Text := TFinLancamentoPagarVO(ObjetoVO).ListaParcelaPagarVO[0].ContaCaixaVO.Nome;
    end;

    // Parcelas
    for I := 0 to TFinLancamentoPagarVO(ObjetoVO).ListaParcelaPagarVO.Count - 1 do
    begin
      ParcelaPagar := TFinLancamentoPagarVO(ObjetoVO).ListaParcelaPagarVO[I];

      CDSParcelaPagar.Append;

      CDSParcelaPagar.FieldByName('ID').AsInteger := ParcelaPagar.Id;
      CDSParcelaPagar.FieldByName('ID_FIN_LANCAMENTO_PAGAR').AsInteger := ParcelaPagar.IdFinLancamentoPagar;
      CDSParcelaPagar.FieldByName('ID_CONTA_CAIXA').AsInteger := ParcelaPagar.IdContaCaixa;
      //CDSParcelaPagar.FieldByName('CONTA_CAIXANOME').AsString := ParcelaPagar.ContaCaixaVO.Nome;
      CDSParcelaPagar.FieldByName('NUMERO_PARCELA').AsInteger := ParcelaPagar.NumeroParcela;
      CDSParcelaPagar.FieldByName('DATA_EMISSAO').AsDateTime := ParcelaPagar.DataEmissao;
      CDSParcelaPagar.FieldByName('DATA_VENCIMENTO').AsDateTime := ParcelaPagar.DataVencimento;
      CDSParcelaPagar.FieldByName('DESCONTO_ATE').AsDateTime := ParcelaPagar.DescontoAte;
      CDSParcelaPagar.FieldByName('SOFRE_RETENCAO').AsString := ParcelaPagar.SofreRetencao;
      CDSParcelaPagar.FieldByName('VALOR').AsFloat := ParcelaPagar.Valor;
      CDSParcelaPagar.FieldByName('TAXA_JURO').AsFloat := ParcelaPagar.TaxaJuro;
      CDSParcelaPagar.FieldByName('TAXA_MULTA').AsFloat := ParcelaPagar.TaxaMulta;
      CDSParcelaPagar.FieldByName('TAXA_DESCONTO').AsFloat := ParcelaPagar.TaxaDesconto;
      CDSParcelaPagar.FieldByName('VALOR_JURO').AsFloat := ParcelaPagar.ValorJuro;
      CDSParcelaPagar.FieldByName('VALOR_MULTA').AsFloat := ParcelaPagar.ValorMulta;
      CDSParcelaPagar.FieldByName('VALOR_DESCONTO').AsFloat := ParcelaPagar.ValorDesconto;

      CDSParcelaPagar.Post;
    end;

    // Natureza Financeira
    for I := 0 to TFinLancamentoPagarVO(ObjetoVO).ListaLancPagarNatFinanceiraVO.Count - 1 do
    begin
      LancamentoNaturezaFinanceira := TFinLancamentoPagarVO(ObjetoVO).ListaLancPagarNatFinanceiraVO[I];

      CDSLancamentoNaturezaFinanceira.Append;

      CDSLancamentoNaturezaFinanceira.FieldByName('ID').AsInteger := LancamentoNaturezaFinanceira.Id;
      CDSLancamentoNaturezaFinanceira.FieldByName('ID_FIN_LANCAMENTO_PAGAR').AsInteger := LancamentoNaturezaFinanceira.IdFinLancamentoPagar;
      CDSLancamentoNaturezaFinanceira.FieldByName('ID_NATUREZA_FINANCEIRA').AsInteger := LancamentoNaturezaFinanceira.IdNaturezaFinanceira;
//      CDSLancamentoNaturezaFinanceira.FieldByName('NATUREZA_FINANCEIRACLASSIFICACAO.AsString := LancamentoNaturezaFinanceira.NaturezaFinanceiraVO.Classificacao;
//      CDSLancamentoNaturezaFinanceira.FieldByName('NATUREZA_FINANCEIRADESCRICAO.AsString := LancamentoNaturezaFinanceira.NaturezaFinanceiraVO.Descricao;
      CDSLancamentoNaturezaFinanceira.FieldByName('DATA_INCLUSAO').AsDateTime := LancamentoNaturezaFinanceira.DataInclusao;
      CDSLancamentoNaturezaFinanceira.FieldByName('VALOR').AsFloat := LancamentoNaturezaFinanceira.Valor;

      CDSLancamentoNaturezaFinanceira.Post;
    end;

    // Serializa o objeto para consultar posteriormente se houve alterações
    FormatSettings.DecimalSeparator := '.';
    StringObjetoOld := ObjetoVO.ToJSONString;
    FormatSettings.DecimalSeparator := ',';
  end;
  ConfigurarLayoutTela;
end;

procedure TFFinLancamentoPagar.JvDBUltimGrid1KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  Filtro: String;
begin
  /// EXERCICIO: Implemente a busca usando a janela FLookup

  (*
  if Key = VK_F1 then
  begin
    try
      if Assigned(ContaCaixaVO) then
      begin
        CDSLancamentoNaturezaFinanceira.Append;
        CDSLancamentoNaturezaFinanceira.FieldByName('ID_NATUREZA_FINANCEIRA').AsInteger := CDSTransiente.FieldByName('ID').AsInteger;
        CDSLancamentoNaturezaFinanceiraDATA_INCLUSAO.AsDateTime := Now;
        CDSLancamentoNaturezaFinanceira.FieldByName('NATUREZA_FINANCEIRACLASSIFICACAO').AsString := CDSTransiente.FieldByName('CLASSIFICACAO').AsString;
        CDSLancamentoNaturezaFinanceira.FieldByName('NATUREZA_FINANCEIRADESCRICAO').AsString := CDSTransiente.FieldByName('DESCRICAO').AsString;
      end;
    finally
    end;
  end;
  *)
end;

procedure TFFinLancamentoPagar.GridParcelasKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  If Key = VK_RETURN then
    GridParcelas.SelectedIndex := GridParcelas.SelectedIndex + 1;
end;

procedure TFFinLancamentoPagar.CDSLancamentoNaturezaFinanceiraAfterPost(DataSet: TDataSet);
begin
  if CDSLancamentoNaturezaFinanceira.FieldByName('ID_NATUREZA_FINANCEIRA').AsInteger = 0 then
    CDSLancamentoNaturezaFinanceira.Delete;
end;

procedure TFFinLancamentoPagar.CDSLancamentoNaturezaFinanceiraBeforePost(DataSet: TDataSet);
begin
  CDSLancamentoNaturezaFinanceira.FieldByName('PERCENTUAL').AsFloat := (CDSLancamentoNaturezaFinanceira.FieldByName('VALOR').AsFloat / EditValorAPagar.Value) * 100;
end;

procedure TFFinLancamentoPagar.CDSParcelaPagarAfterPost(DataSet: TDataSet);
begin
  if CDSParcelaPagar.FieldByName('NUMERO_PARCELA').AsInteger = 0 then
    CDSParcelaPagar.Delete;
end;

procedure TFFinLancamentoPagar.CDSParcelaPagarBeforeDelete(DataSet: TDataSet);
begin
  if CDSParcelaPagar.FieldByName('ID').AsInteger > 0 then
    TFinParcelaPagarController.Exclui(CDSParcelaPagar.FieldByName('ID').AsInteger);
end;
{$ENDREGION}

{$REGION 'Actions'}
procedure TFFinLancamentoPagar.ActionAcionarGedExecute(Sender: TObject);
var
  Parametros: String;
begin
  if EditNumeroDocumento.Text <> '' then
  begin
    {
      Parametros
      1 - Login
      2 - Senha
      3 - Aplicação que chamou
      4 - Nome do arquivo (Aplicacao que chamou + Tela que chamou + Numero Apólice
      }

    try
      //EditImagemDocumento.Text := 'LANCAMENTO_PAGAR_' + MD5String(EditNumeroDocumento.Text);

      Parametros := Sessao.Usuario.Login + ' ' +
                    Sessao.Usuario.Senha + ' ' +
                    'FINANCEIRO' + ' ' +
                    EditImagemDocumento.Text;
       OpenDocument('T2TiERPGed.exe');      /// EXERCICIO: Chame o GED passando os parâmetros necessários
    except
      Application.MessageBox('Erro ao tentar executar o módulo.', 'Erro do Sistema', MB_OK + MB_ICONERROR);
    end;
  end
  else
  begin
    Application.MessageBox('É preciso informar o número do documento.', 'Mensagem do Sistema', MB_OK + MB_ICONINFORMATION);
    EditNumeroDocumento.SetFocus;
  end;
end;

procedure TFFinLancamentoPagar.ActionGerarParcelasExecute(Sender: TObject);
begin
  if EditIdContaCaixa.AsInteger <=0 then
  begin
    Application.MessageBox('É necessário informar a conta/caixa para previsão das parcelas.', 'Mensagem do Sistema', MB_OK + MB_ICONINFORMATION);
    EditIdContaCaixa.SetFocus;
    Exit;
  end;

  if not CDSParcelaPagar.IsEmpty then
  begin
    if Application.MessageBox('Já existem parcelas geradas e serão excluídas. Deseja continuar?', 'Pergunta do Sistema', MB_YesNo + MB_IconQuestion) = IdYes then
    begin
      CDSParcelaPagar.DisableControls;
      CDSParcelaPagar.First;
      while not CDSParcelaPagar.Eof do
      begin
        if CDSParcelaPagar.FieldByName('ID').AsInteger > 0 then
          TFinParcelaPagarController.Exclui(CDSParcelaPagar.FieldByName('ID').AsInteger);

        CDSParcelaPagar.Next;
      end;
      CDSParcelaPagar.First;
      CDSParcelaPagar.EnableControls;

      CDSParcelaPagar.Close;
      CDSParcelaPagar.Open;
      GerarParcelas;
    end;
  end
  else
    GerarParcelas;
end;

procedure TFFinLancamentoPagar.GerarParcelas;
var
  i: integer;
  Vencimento: TDate;
  SomaParcelas, Residuo: Extended;
  FornecedorVO: TViewPessoaFornecedorVO;
  Filtro: String;
begin
  if EditQuantidadeParcelas.AsInteger <= 0 then
    EditQuantidadeParcelas.AsInteger := 1;

  if EditPrimeiroVencimento.Text = '  /  /    ' then
    EditPrimeiroVencimento.Date := Date;

  Vencimento := EditPrimeiroVencimento.Date;
  SomaParcelas := 0;
  Residuo := 0;

  Filtro := 'ID=' + QuotedStr(EditIdFornecedor.Text);
  FornecedorVO := TViewPessoaFornecedorController.ConsultaObjeto(Filtro);

  for i := 0 to EditQuantidadeParcelas.AsInteger - 1 do
  begin
    CDSParcelaPagar.Append;
    CDSParcelaPagar.FieldByName('NUMERO_PARCELA').AsInteger := i+1;
    CDSParcelaPagar.FieldByName('ID_CONTA_CAIXA').AsInteger := EditIdContaCaixa.AsInteger;
    CDSParcelaPagar.FieldByName('DATA_EMISSAO').AsString := DateToStr(Date);
    CDSParcelaPagar.FieldByName('DATA_VENCIMENTO').AsString := DateToStr(Vencimento + (EditIntervalorEntreParcelas.AsInteger * i));
    CDSParcelaPagar.FieldByName('DESCONTO_ATE').AsString := DateToStr(Date);
    CDSParcelaPagar.FieldByName('SOFRE_RETENCAO').AsString := FornecedorVO.SofreRetencao;
    CDSParcelaPagar.FieldByName('VALOR').AsFloat := ArredondaTruncaValor('A', EditValorAPagar.Value / EditQuantidadeParcelas.AsInteger, Constantes.TConstantes.DECIMAIS_VALOR);
    CDSParcelaPagar.FieldByName('CONTA_CAIXA.NOME').AsString := EditContaCaixa.Text;
    CDSParcelaPagar.Post;

    SomaParcelas := SomaParcelas + CDSParcelaPagar.FieldByName('VALOR').AsFloat;
  end;

  // calcula o resíduo e lança na última parcela
  Residuo := EditValorAPagar.Value - SomaParcelas;
  CDSParcelaPagar.Edit;
  CDSParcelaPagar.FieldByName('VALOR').AsFloat := CDSParcelaPagar.FieldByName('VALOR').AsFloat + Residuo;
  CDSParcelaPagar.Post;
end;

procedure TFFinLancamentoPagar.ActionGerarPagamentoFixoExecute(Sender: TObject);
var
  PagamentoFixoVO: TFinPagamentoFixoVO;
begin
  /// EXERCICIO - VERIFIQUE SE ESSE PAGAMENTO JA FOI MARCADO COMO FIXO E AJA DE ACORDO
  ///  01 - APAGUE O REGISTRO ANTERIOR E GRAVE O NOVO
  ///  02 - ALTERE O REGISTRO ANTERIOR
  ///  03 - INFORME QUE JÁ EXISE UM PAGAMENTO FIXO ARMAZENADO E QUE NÃO É POSSÍVEL REALIZAR ALTERAÇÕES
  ///  04 - SOLICITE UMA AÇÃO DO USUÁRIO

  if Application.MessageBox('Deseja gravar esse pagamento como recorrente? (Lançamento Mensal)', 'Pergunta do Sistema', MB_YesNo + MB_IconQuestion) = IdYes then
  begin
    PagamentoFixoVO := TFinPagamentoFixoVO.Create;

    PagamentoFixoVO.IdFornecedor := EditIdFornecedor.AsInteger;
    PagamentoFixoVO.IdFinDocumentoOrigem := EditIdDocumentoOrigem.AsInteger;
    PagamentoFixoVO.PagamentoCompartilhado := IfThen(ComboBoxPagamentoCompartilhado.ItemIndex = 0, 'S', 'N');
    PagamentoFixoVO.QuantidadeParcela := EditQuantidadeParcelas.AsInteger;
    PagamentoFixoVO.ValorTotal := EditValorTotal.Value;
    PagamentoFixoVO.ValorAPagar := EditValorAPagar.Value;
    PagamentoFixoVO.DataLancamento := EditDataLancamento.Date;
    PagamentoFixoVO.NumeroDocumento := EditNumeroDocumento.Text;
    PagamentoFixoVO.ImagemDocumento := EditImagemDocumento.Text;
    PagamentoFixoVO.PrimeiroVencimento := EditPrimeiroVencimento.Date;
    PagamentoFixoVO.IntervaloEntreParcelas := EditIntervalorEntreParcelas.AsInteger;

    TFinPagamentoFixoController.Insere(PagamentoFixoVO);

    Application.MessageBox('Lançamento realizado com sucesso.', 'Mensagem do Sistema', MB_OK + MB_ICONINFORMATION);
  end;
end;

{$ENDREGION}

end.

