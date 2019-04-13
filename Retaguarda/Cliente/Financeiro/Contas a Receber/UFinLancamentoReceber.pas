{ *******************************************************************************
Title: T2Ti ERP
Description: Janela Lançamento a Receber

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
unit UFinLancamentoReceber;

{$MODE Delphi}

interface

uses
  BrookHTTPClient, BrookFCLHTTPClientBroker, BrookHTTPUtils, BrookUtils, FPJson, ZDataset,
  LCLIntf, LCLType, LMessages, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UTelaCadastro, Menus, StdCtrls, ExtCtrls, Buttons, Grids, DBGrids,
  ComCtrls, LabeledCtrls, rxdbgrid, rxtoolbar, DBCtrls, StrUtils,
  Math, Constantes, CheckLst, ActnList, ToolWin, db, BufDataset, Biblioteca,
  ULookup, VO, ACBrBoleto, AdmParametroVO, FinLancamentoReceberVO,
  FinLancamentoReceberController;

  type

  { TFFinLancamentoReceber }

  TFFinLancamentoReceber = class(TFTelaCadastro)
    ActionManager: TActionList;
    ActionGerarParcelas: TAction;
    CDSLancamentoNaturezaFinanceira: TBufDataset;
    CDSParcelaReceber: TBufDataset;
    PanelParcelas: TPanel;
    PanelMestre: TPanel;
    EditIdCliente: TLabeledCalcEdit;
    EditCliente: TLabeledEdit;
    EditIdDocumentoOrigem: TLabeledCalcEdit;
    EditDocumentoOrigem: TLabeledEdit;
    EditPrimeiroVencimento: TLabeledDateEdit;
    EditQuantidadeParcelas: TLabeledCalcEdit;
    EditValorAReceber: TLabeledCalcEdit;
    EditValorTotal: TLabeledCalcEdit;
    EditDataLancamento: TLabeledDateEdit;
    DSParcelaReceber: TDataSource;
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
    ActionEmitirBoleto: TAction;
    tsNaturezaFinanceira: TTabSheet;
    PanelNaturezaFinanceira: TPanel;
    JvDBUltimGrid1: TRxDbGrid;
    DSLancamentoNaturezaFinanceira: TDataSource;
    EditTaxaComissao: TLabeledCalcEdit;
    EditValorComissao: TLabeledCalcEdit;
    CDSLancamentoNaturezaFinanceiraPERCENTUAL: TFMTBCDField;
    EditDescontoConvenio: TLabeledCalcEdit;
    EditTaxaConvenio: TLabeledCalcEdit;
    procedure FormCreate(Sender: TObject);
    procedure ActionGerarParcelasExecute(Sender: TObject);
    procedure GridDblClick(Sender: TObject);
    procedure GridParcelasKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure CDSParcelaReceberBeforeDelete(DataSet: TDataSet);
    procedure CDSParcelaReceberAfterPost(DataSet: TDataSet);
    procedure GerarParcelas;
    procedure ActionEmitirBoletoExecute(Sender: TObject);
    procedure JvDBUltimGrid1KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure CDSLancamentoNaturezaFinanceiraAfterPost(DataSet: TDataSet);
    procedure EditTaxaComissaoExit(Sender: TObject);
    procedure GridParcelasCellClick(Column: TColumn);
    procedure EditIdClienteKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure EditIdDocumentoOrigemKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure EditIdContaCaixaKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure CDSLancamentoNaturezaFinanceiraBeforePost(DataSet: TDataSet);
    procedure EditValorTotalExit(Sender: TObject);
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
  FFinLancamentoReceber: TFFinLancamentoReceber;
  AdmParametroVO: TAdmParametroVO;

implementation

uses UDataModule, PessoaVO, PessoaController,
  FinDocumentoOrigemVO, FinDocumentoOrigemController, FinParcelaReceberVO,
  FinParcelaReceberController, ContaCaixaVO, ContaCaixaController, NaturezaFinanceiraVO,
  NaturezaFinanceiraController, FinLctoReceberNtFinanceiraVO, FinConfiguracaoBoletoController,
  FinConfiguracaoBoletoVO, ViewPessoaClienteVO, ViewPessoaClienteController, AdmParametroController;
{$R *.lfm}

{$REGION 'Infra'}
procedure TFFinLancamentoReceber.BotaoConsultarClick(Sender: TObject);
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
    RetornoConsulta := TFinLancamentoReceberController.Consulta(Filtro, IntToStr(Pagina));
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

procedure TFFinLancamentoReceber.BotaoSalvarClick(Sender: TObject);
begin
  inherited;
  BotaoConsultarClick(Sender);
end;

procedure TFFinLancamentoReceber.FormCreate(Sender: TObject);
var
  Filtro: String;
begin
  ClasseObjetoGridVO := TFinLancamentoReceberVO;
  ObjetoController := TFinLancamentoReceberController.Create;

  inherited;

  Filtro := 'ID_EMPRESA = ' + IntToStr(Sessao.Empresa.Id);
  AdmParametroVO := TAdmParametroController.ConsultaObjeto(Filtro);

  /// EXERCICIO: Pense numa maneira de esconder a coluna "mesclar recebimento" que será utilizada na janela de mesclagem
  // Grid.Columns.Items[0].Visible := False;

  ConfiguraCDSFromVO(CDSParcelaReceber, TFinParcelaReceberVO);
  ConfiguraCDSFromVO(CDSLancamentoNaturezaFinanceira, TFinLctoReceberNtFinanceiraVO);
end;

procedure TFFinLancamentoReceber.LimparCampos;
begin
  inherited;
  CDSParcelaReceber.Close;
  CDSParcelaReceber.Open;
  CDSLancamentoNaturezaFinanceira.Close;
  CDSLancamentoNaturezaFinanceira.Open;
end;

procedure TFFinLancamentoReceber.ConfigurarLayoutTela;
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

function TFFinLancamentoReceber.VerificarTotalNaturezaFinanceira: Boolean;
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
  Result := (Total = EditValorAReceber.Value);
end;

procedure TFFinLancamentoReceber.EditTaxaComissaoExit(Sender: TObject);
begin
  EditValorComissao.Value := EditValorAReceber.Value * EditTaxaComissao.Value / 100;
end;

procedure TFFinLancamentoReceber.EditValorTotalExit(Sender: TObject);
begin
  EditDescontoConvenio.Value := EditValorTotal.Value * EditTaxaConvenio.Value / 100;
  EditValorAReceber.Value := EditValorTotal.Value - EditDescontoConvenio.Value;
end;

{$ENDREGION}

{$REGION 'Controles CRUD'}
function TFFinLancamentoReceber.DoInserir: Boolean;
begin
  Result := inherited DoInserir;

  if Result then
  begin
    EditIdCliente.SetFocus;
  end;
end;

function TFFinLancamentoReceber.DoEditar: Boolean;
begin
  Result := inherited DoEditar;

  if Result then
  begin
    EditIdCliente.SetFocus;
  end;
end;

function TFFinLancamentoReceber.DoExcluir: Boolean;
begin
  if inherited DoExcluir then
  begin
    try
      Result := TFinLancamentoReceberController.Exclui(IdRegistroSelecionado);
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

function TFFinLancamentoReceber.DoSalvar: Boolean;
var
  ParcelaReceber: TFinParcelaReceberVO;
  LancamentoNaturezaFinanceira: TFinLctoReceberNtFinanceiraVO;
begin
  if not CDSLancamentoNaturezaFinanceira.IsEmpty then
  begin
    if not VerificarTotalNaturezaFinanceira then begin
      Application.MessageBox('Os valores informados nas naturezas financeiras não batem com o valor a receber.', 'Mensagem do Sistema', MB_OK + MB_ICONINFORMATION);
      Exit(False);
    end;
  end;

  Result := inherited DoSalvar;

  if Result then
  begin
    try
      if not Assigned(ObjetoVO) then
        ObjetoVO := TFinLancamentoReceberVO.Create;

      TFinLancamentoReceberVO(ObjetoVO).IdCliente := EditIdCliente.AsInteger;
      TFinLancamentoReceberVO(ObjetoVO).ClienteNome := EditCliente.Text;
      TFinLancamentoReceberVO(ObjetoVO).IdFinDocumentoOrigem := EditIdDocumentoOrigem.AsInteger;
      TFinLancamentoReceberVO(ObjetoVO).DocumentoOrigemSigla := EditDocumentoOrigem.Text;
      TFinLancamentoReceberVO(ObjetoVO).QuantidadeParcela := EditQuantidadeParcelas.AsInteger;
      TFinLancamentoReceberVO(ObjetoVO).ValorTotal := EditValorTotal.Value;
      TFinLancamentoReceberVO(ObjetoVO).ValorDescontoConvenio := EditDescontoConvenio.Value;
      TFinLancamentoReceberVO(ObjetoVO).ValorAReceber := EditValorAReceber.Value;
      TFinLancamentoReceberVO(ObjetoVO).DataLancamento := EditDataLancamento.Date;
      TFinLancamentoReceberVO(ObjetoVO).NumeroDocumento := EditNumeroDocumento.Text;
      TFinLancamentoReceberVO(ObjetoVO).PrimeiroVencimento := EditPrimeiroVencimento.Date;
      TFinLancamentoReceberVO(ObjetoVO).IntervaloEntreParcelas := EditIntervalorEntreParcelas.AsInteger;
      TFinLancamentoReceberVO(ObjetoVO).TaxaComissao := EditTaxaComissao.Value;
      TFinLancamentoReceberVO(ObjetoVO).ValorComissao := EditValorComissao.Value;

      // Parcelas
      CDSParcelaReceber.DisableControls;
      CDSParcelaReceber.First;
      while not CDSParcelaReceber.Eof do
      begin
          ParcelaReceber := TFinParcelaReceberVO.Create;
          ParcelaReceber.Id := CDSParcelaReceber.FieldByName('ID').AsInteger;
          ParcelaReceber.IdFinLancamentoReceber := TFinLancamentoReceberVO(ObjetoVO).Id;
          ParcelaReceber.IdContaCaixa := CDSParcelaReceber.FieldByName('ID_CONTA_CAIXA').AsInteger;
          ParcelaReceber.IdFinStatusParcela := AdmParametroVO.FinParcelaAberto;
          ParcelaReceber.NumeroParcela := CDSParcelaReceber.FieldByName('NUMERO_PARCELA').AsInteger;
          ParcelaReceber.DataEmissao := CDSParcelaReceber.FieldByName('DATA_EMISSAO').AsDateTime;
          ParcelaReceber.DataVencimento := CDSParcelaReceber.FieldByName('DATA_VENCIMENTO').AsDateTime;
          ParcelaReceber.DescontoAte := CDSParcelaReceber.FieldByName('DESCONTO_ATE').AsDateTime;
          ParcelaReceber.Valor := CDSParcelaReceber.FieldByName('VALOR').AsFloat;

          ParcelaReceber.EmitiuBoleto := CDSParcelaReceber.FieldByName('EMITIU_BOLETO').AsString;
          ParcelaReceber.BoletoNossoNumero := CDSParcelaReceber.FieldByName('BOLETO_NOSSO_NUMERO').AsString;

          ParcelaReceber.TaxaJuro := CDSParcelaReceber.FieldByName('TAXA_JURO').AsFloat;
          ParcelaReceber.TaxaMulta := CDSParcelaReceber.FieldByName('TAXA_MULTA').AsFloat;
          ParcelaReceber.TaxaDesconto := CDSParcelaReceber.FieldByName('TAXA_DESCONTO').AsFloat;
          ParcelaReceber.ValorJuro := CDSParcelaReceber.FieldByName('VALOR_JURO').AsFloat;
          ParcelaReceber.ValorMulta := CDSParcelaReceber.FieldByName('VALOR_MULTA').AsFloat;
          ParcelaReceber.ValorDesconto := CDSParcelaReceber.FieldByName('VALOR_DESCONTO').AsFloat;

          TFinLancamentoReceberVO(ObjetoVO).ListaParcelaReceberVO.Add(ParcelaReceber);

        CDSParcelaReceber.Next;
      end;
      CDSParcelaReceber.EnableControls;

      // Natureza Financeira
      CDSLancamentoNaturezaFinanceira.DisableControls;
      CDSLancamentoNaturezaFinanceira.First;
      while not CDSLancamentoNaturezaFinanceira.Eof do
      begin
          LancamentoNaturezaFinanceira := TFinLctoReceberNtFinanceiraVO.Create;

          LancamentoNaturezaFinanceira.Id := CDSLancamentoNaturezaFinanceira.FieldByName('ID').AsInteger;
          LancamentoNaturezaFinanceira.IdFinLancamentoReceber := CDSLancamentoNaturezaFinanceira.FieldByName('ID_FIN_LANCAMENTO_RECEBER').AsInteger;
          LancamentoNaturezaFinanceira.IdNaturezaFinanceira := CDSLancamentoNaturezaFinanceira.FieldByName('ID_NATUREZA_FINANCEIRA').AsInteger;
          LancamentoNaturezaFinanceira.DataInclusao := CDSLancamentoNaturezaFinanceira.FieldByName('DATA_INCLUSAO').AsDateTime;
          LancamentoNaturezaFinanceira.Valor := CDSLancamentoNaturezaFinanceira.FieldByName('VALOR').AsFloat;

          TFinLancamentoReceberVO(ObjetoVO).ListaLancReceberNatFinanceiraVO.Add(LancamentoNaturezaFinanceira);

        CDSLancamentoNaturezaFinanceira.Next;
      end;
      CDSLancamentoNaturezaFinanceira.EnableControls;

      if StatusTela = stInserindo then
      begin
        TFinLancamentoReceberController.Insere(TFinLancamentoReceberVO(ObjetoVO));
      end
      else if StatusTela = stEditando then
      begin
        /// EXERCICIO: Verifique se tem como serializar as listas junto com o objeto para realizar a comparação
        //if TFinLancamentoReceberVO(ObjetoVO).ToJSONString <> StringObjetoOld then
        //begin
          TFinLancamentoReceberController.Altera(TFinLancamentoReceberVO(ObjetoVO));
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
procedure TFFinLancamentoReceber.EditIdClienteKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  Filtro: String;
  ViewPessoaClienteVO :TViewPessoaClienteVO ;
begin
  if Key = VK_F1 then
  begin
    if EditIdCliente.Value <> 0 then
      Filtro := 'ID = ' + EditIdCliente.Text
    else
      Filtro := 'ID=0';

    try
      EditCliente.Clear;

        ViewPessoaClienteVO := TViewPessoaClienteController.ConsultaObjeto(Filtro);
        if Assigned(ViewPessoaClienteVO) then
      begin
        EditCliente.Text := ViewPessoaClienteVO.Nome;
        EditTaxaConvenio.Value := ViewPessoaClienteVO.DescontoConvenio;
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

procedure TFFinLancamentoReceber.EditIdDocumentoOrigemKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
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

procedure TFFinLancamentoReceber.EditIdContaCaixaKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
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
procedure TFFinLancamentoReceber.GridDblClick(Sender: TObject);
begin
  inherited;
  ConfigurarLayoutTela;
end;

procedure TFFinLancamentoReceber.GridParaEdits;
var
  IdCabecalho: String;
  ParcelaReceber: TFinParcelaReceberVO;
  LancamentoNaturezaFinanceira: TFinLctoReceberNtFinanceiraVO;
  I: Integer;
begin
  inherited;

  if not CDSGrid.IsEmpty then
  begin
    IdCabecalho := IntToStr(IdRegistroSelecionado);
    ObjetoVO := TFinLancamentoReceberController.ConsultaObjeto('ID=' + IdCabecalho);
  end;

  if Assigned(ObjetoVO) then
  begin
    EditIdCliente.AsInteger := TFinLancamentoReceberVO(ObjetoVO).IdCliente;
    EditCliente.Text := TFinLancamentoReceberVO(ObjetoVO).ClienteNome;
    EditIdDocumentoOrigem.AsInteger := TFinLancamentoReceberVO(ObjetoVO).IdFinDocumentoOrigem;
    EditDocumentoOrigem.Text := TFinLancamentoReceberVO(ObjetoVO).DocumentoOrigemSigla;
    EditQuantidadeParcelas.AsInteger := TFinLancamentoReceberVO(ObjetoVO).QuantidadeParcela;
    EditValorTotal.Value := TFinLancamentoReceberVO(ObjetoVO).ValorTotal;
    EditDescontoConvenio.Value := TFinLancamentoReceberVO(ObjetoVO).ValorDescontoConvenio;
    EditValorAReceber.Value := TFinLancamentoReceberVO(ObjetoVO).ValorAReceber;
    EditDataLancamento.Date := TFinLancamentoReceberVO(ObjetoVO).DataLancamento;
    EditNumeroDocumento.Text := TFinLancamentoReceberVO(ObjetoVO).NumeroDocumento;
    EditPrimeiroVencimento.Date := TFinLancamentoReceberVO(ObjetoVO).PrimeiroVencimento;
    EditIntervalorEntreParcelas.AsInteger := TFinLancamentoReceberVO(ObjetoVO).IntervaloEntreParcelas;
    EditTaxaComissao.Value := TFinLancamentoReceberVO(ObjetoVO).TaxaComissao;
    EditValorComissao.Value := TFinLancamentoReceberVO(ObjetoVO).ValorComissao;

    // EXERCICIO: CASO O CLIENTE TENHA UM VALOR DE CONVENIO, CARREGUE O RESPECTIVO VALOR NO EDIT EditTaxaConvenio
    // EXERCICIO: CARREGUE OS DADOS DA CONTA CAIXA VINCULADA ÀS PARCELAS

    if TFinLancamentoReceberVO(ObjetoVO).ListaParcelaReceberVO.Count > 0 then
    begin
      EditIdContaCaixa.AsInteger := TFinLancamentoReceberVO(ObjetoVO).ListaParcelaReceberVO[0].IdContaCaixa;
      //EditContaCaixa.Text := TFinLancamentoReceberVO(ObjetoVO).ListaParcelaReceberVO[0].ContaCaixaVO.Nome;
    end;

    // Parcelas
    for I := 0 to TFinLancamentoReceberVO(ObjetoVO).ListaParcelaReceberVO.Count - 1 do
    begin
      ParcelaReceber := TFinLancamentoReceberVO(ObjetoVO).ListaParcelaReceberVO[I];

      CDSParcelaReceber.Append;

      CDSParcelaReceber.FieldByName('ID').AsInteger := ParcelaReceber.Id;
      CDSParcelaReceber.FieldByName('ID_FIN_LANCAMENTO_RECEBER').AsInteger := ParcelaReceber.IdFinLancamentoReceber;
      CDSParcelaReceber.FieldByName('ID_CONTA_CAIXA').AsInteger := ParcelaReceber.IdContaCaixa;
      //CDSParcelaReceber.FieldByName('CONTA_CAIXANOME.AsString := ParcelaReceber.ContaCaixaVO.Nome;
      CDSParcelaReceber.FieldByName('NUMERO_PARCELA').AsInteger := ParcelaReceber.NumeroParcela;
      CDSParcelaReceber.FieldByName('DATA_EMISSAO').AsDateTime := ParcelaReceber.DataEmissao;
      CDSParcelaReceber.FieldByName('DATA_VENCIMENTO').AsDateTime := ParcelaReceber.DataVencimento;
      CDSParcelaReceber.FieldByName('DESCONTO_ATE').AsDateTime := ParcelaReceber.DescontoAte;
      CDSParcelaReceber.FieldByName('VALOR').AsFloat := ParcelaReceber.Valor;
      CDSParcelaReceber.FieldByName('TAXA_JURO').AsFloat := ParcelaReceber.TaxaJuro;
      CDSParcelaReceber.FieldByName('TAXA_MULTA').AsFloat := ParcelaReceber.TaxaMulta;
      CDSParcelaReceber.FieldByName('TAXA_DESCONTO').AsFloat := ParcelaReceber.TaxaDesconto;
      CDSParcelaReceber.FieldByName('VALOR_JURO').AsFloat := ParcelaReceber.ValorJuro;
      CDSParcelaReceber.FieldByName('VALOR_MULTA').AsFloat := ParcelaReceber.ValorMulta;
      CDSParcelaReceber.FieldByName('VALOR_DESCONTO').AsFloat := ParcelaReceber.ValorDesconto;
      CDSParcelaReceber.FieldByName('EMITIU_BOLETO').AsString := ParcelaReceber.EmitiuBoleto;
      CDSParcelaReceber.FieldByName('BOLETO_NOSSO_NUMERO').AsString := ParcelaReceber.BoletoNossoNumero;

      CDSParcelaReceber.Post;
    end;

    // Natureza Financeira
    for I := 0 to TFinLancamentoReceberVO(ObjetoVO).ListaLancReceberNatFinanceiraVO.Count - 1 do
    begin
      LancamentoNaturezaFinanceira := TFinLancamentoReceberVO(ObjetoVO).ListaLancReceberNatFinanceiraVO[I];

      CDSLancamentoNaturezaFinanceira.Append;

      CDSLancamentoNaturezaFinanceira.FieldByName('ID').AsInteger := LancamentoNaturezaFinanceira.Id;
      CDSLancamentoNaturezaFinanceira.FieldByName('ID_FIN_LANCAMENTO_RECEBER').AsInteger := LancamentoNaturezaFinanceira.IdFinLancamentoReceber;
      CDSLancamentoNaturezaFinanceira.FieldByName('ID_NATUREZA_FINANCEIRA').AsInteger := LancamentoNaturezaFinanceira.IdNaturezaFinanceira;
      //CDSLancamentoNaturezaFinanceira.FieldByName('NATUREZA_FINANCEIRACLASSIFICACAO').AsString := LancamentoNaturezaFinanceira.NaturezaFinanceiraVO.Classificacao;
      //CDSLancamentoNaturezaFinanceira.FieldByName('NATUREZA_FINANCEIRADESCRICAO').AsString := LancamentoNaturezaFinanceira.NaturezaFinanceiraVO.Descricao;
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

procedure TFFinLancamentoReceber.JvDBUltimGrid1KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
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

procedure TFFinLancamentoReceber.GridParcelasKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  If Key = VK_RETURN then
    GridParcelas.SelectedIndex := GridParcelas.SelectedIndex + 1;
end;

procedure TFFinLancamentoReceber.CDSLancamentoNaturezaFinanceiraAfterPost(DataSet: TDataSet);
begin
  if CDSLancamentoNaturezaFinanceira.FieldByName('ID_NATUREZA_FINANCEIRA').AsInteger = 0 then
    CDSLancamentoNaturezaFinanceira.Delete;
end;

procedure TFFinLancamentoReceber.CDSLancamentoNaturezaFinanceiraBeforePost(DataSet: TDataSet);
begin
  CDSLancamentoNaturezaFinanceira.FieldByName('PERCENTUAL').AsFloat := (CDSLancamentoNaturezaFinanceira.FieldByName('VALOR').AsFloat / EditValorAReceber.Value) * 100;
end;

procedure TFFinLancamentoReceber.CDSParcelaReceberAfterPost(DataSet: TDataSet);
begin
  if CDSParcelaReceber.FieldByName('NUMERO_PARCELA').AsInteger = 0 then
    CDSParcelaReceber.Delete;
end;

procedure TFFinLancamentoReceber.CDSParcelaReceberBeforeDelete(DataSet: TDataSet);
begin
  if CDSParcelaReceber.FieldByName('ID').AsInteger > 0 then
  TFinParcelaReceberController.Exclui(CDSParcelaReceber.FieldByName('ID').AsInteger);
end;

procedure TFFinLancamentoReceber.GridParcelasCellClick(Column: TColumn);
var
  NossoNumero: String;
begin
  if Column.Index = 4 then
  begin
    CDSParcelaReceber.Edit;
    if CDSParcelaReceber.FieldByName('EMITIU_BOLETO').AsString = '' then
    begin
      NossoNumero := StringOfChar('0', 3 - Length(EditIdCliente.Text)) + EditIdCliente.Text;
      NossoNumero := NossoNumero + StringOfChar('0', 3 - Length(EditIdContaCaixa.Text)) + EditIdContaCaixa.Text;
      NossoNumero := NossoNumero + StringOfChar('0', 3 - Length(CDSParcelaReceber.FieldByName('NUMERO_PARCELA').AsString)) + CDSParcelaReceber.FieldByName('NUMERO_PARCELA').AsString;
      NossoNumero := NossoNumero + FormatDateTime('ddhhss', now);
      CDSParcelaReceber.FieldByName('EMITIU_BOLETO').AsString := 'S';
      CDSParcelaReceber.FieldByName('BOLETO_NOSSO_NUMERO').AsString := Copy(NossoNumero, 1, 10);
//      CDSParcelaReceber.FieldByName('PERSISTE').AsString := 'S';
    end
    else
    begin
      CDSParcelaReceber.FieldByName('EMITIU_BOLETO').AsString := '';
      CDSParcelaReceber.FieldByName('BOLETO_NOSSO_NUMERO').AsString := '';
    end;
    CDSParcelaReceber.Post;
  end;
end;
{$ENDREGION}

{$REGION 'Actions'}
procedure TFFinLancamentoReceber.ActionEmitirBoletoExecute(Sender: TObject);
var
  Titulo: TACBrTitulo;
  Pdir: Pchar;
  ConfiguracaoBoletoVO: TFinConfiguracaoBoletoVO;
  ClienteVO: TViewPessoaClienteVO;
  TemBoleto: Boolean;
  Filtro: String;
begin
  TemBoleto := False;

  CDSParcelaReceber.DisableControls;
  CDSParcelaReceber.First;
  while not CDSParcelaReceber.Eof do
  begin
    if CDSParcelaReceber.FieldByName('EMITIU_BOLETO').AsString = 'S' then
    begin
      TemBoleto := True;
    end;
    CDSParcelaReceber.Next;
  end;
  CDSParcelaReceber.First;
  CDSParcelaReceber.EnableControls;

  if not TemBoleto then
  begin
    Application.MessageBox('Não existem registros selecionados para emissão de boleto.', 'Mensagem do Sistema', MB_OK + MB_ICONINFORMATION);
    GridParcelas.SetFocus;
    Exit;
  end;

  if EditIdContaCaixa.AsInteger <= 0 then
  begin
    Application.MessageBox('É necessário informar a conta/caixa para previsão das parcelas.', 'Mensagem do Sistema', MB_OK + MB_ICONINFORMATION);
    EditIdContaCaixa.SetFocus;
    Exit;
  end;

  Filtro := 'ID_CONTA_CAIXA = ' + QuotedStr(EditIdContaCaixa.Text);
  ConfiguracaoBoletoVO := TFinConfiguracaoBoletoController.ConsultaObjeto(Filtro);

  if not Assigned(ConfiguracaoBoletoVO) then
  begin
    Application.MessageBox('Não existem configurações de boleto para a conta/caixa. Cadastre as configurações.', 'Mensagem do Sistema', MB_OK + MB_ICONINFORMATION);
    EditIdContaCaixa.SetFocus;
    Exit;
  end;
  
  if ConfiguracaoBoletoVO.ContaCaixaVO.AgenciaBancoVO.IdBanco = 0 then
  begin
    Application.MessageBox('A conta/caixa não está vinculada a um banco. Geração de boletos não permitida.', 'Mensagem do Sistema', MB_OK + MB_ICONINFORMATION);
    EditIdContaCaixa.SetFocus;
    Exit;
  end;

  Filtro := 'ID = ' + QuotedStr(EditIdCliente.Text);
  ClienteVO := TViewPessoaClienteController.ConsultaObjeto(Filtro);

  FDataModule.ACBrBoleto.ListadeBoletos.Clear;

  if ConfiguracaoBoletoVO.ContaCaixaVO.AgenciaBancoVO.BancoVO.Codigo = '001' then
    FDataModule.ACBrBoleto.Banco.TipoCobranca := cobBancoDoBrasil
  else if ConfiguracaoBoletoVO.ContaCaixaVO.AgenciaBancoVO.BancoVO.Codigo = '104' then
    FDataModule.ACBrBoleto.Banco.TipoCobranca := cobCaixaEconomica
  else if ConfiguracaoBoletoVO.ContaCaixaVO.AgenciaBancoVO.BancoVO.Codigo = '237' then
    FDataModule.ACBrBoleto.Banco.TipoCobranca := cobBradesco
  else if ConfiguracaoBoletoVO.ContaCaixaVO.AgenciaBancoVO.BancoVO.Codigo = '341' then
    FDataModule.ACBrBoleto.Banco.TipoCobranca := cobItau;

  FDataModule.ACBrBoleto.DirArqRemessa := StringReplace(ConfiguracaoBoletoVO.CaminhoArquivoRemessa,'/','\',[rfReplaceAll]);
  FDataModule.ACBrBoleto.DirArqRetorno := StringReplace(ConfiguracaoBoletoVO.CaminhoArquivoRetorno,'/','\',[rfReplaceAll]);
  if ConfiguracaoBoletoVO.LayoutRemessa = '240' then
    FDataModule.ACBrBoleto.LayoutRemessa := c240
  else if ConfiguracaoBoletoVO.LayoutRemessa = '400' then
    FDataModule.ACBrBoleto.LayoutRemessa := c400;

  FDataModule.ACBrBoleto.Cedente.Nome := Sessao.Empresa.RazaoSocial;
  FDataModule.ACBrBoleto.Cedente.Agencia := ConfiguracaoBoletoVO.ContaCaixaVO.AgenciaBancoVO.Codigo;
  FDataModule.ACBrBoleto.Cedente.AgenciaDigito := ConfiguracaoBoletoVO.ContaCaixaVO.AgenciaBancoVO.Digito;
  FDataModule.ACBrBoleto.Cedente.CNPJCPF := Sessao.Empresa.Cnpj;
  FDataModule.ACBrBoleto.Cedente.Conta := ConfiguracaoBoletoVO.ContaCaixaVO.Codigo;
  FDataModule.ACBrBoleto.Cedente.ContaDigito := ConfiguracaoBoletoVO.ContaCaixaVO.Digito;
  FDataModule.ACBrBoleto.Cedente.CodigoCedente := ConfiguracaoBoletoVO.CodigoCedente;
  FDataModule.ACBrBoleto.Cedente.Convenio := ConfiguracaoBoletoVO.CodigoConvenio;
  FDataModule.ACBrBoleto.Cedente.Logradouro := Sessao.Empresa.EnderecoPrincipal.Logradouro;
  FDataModule.ACBrBoleto.Cedente.Complemento := Sessao.Empresa.EnderecoPrincipal.Complemento;
  FDataModule.ACBrBoleto.Cedente.Bairro := Sessao.Empresa.EnderecoPrincipal.Bairro;
  FDataModule.ACBrBoleto.Cedente.CEP := Sessao.Empresa.EnderecoPrincipal.Cep;
  FDataModule.ACBrBoleto.Cedente.Cidade := Sessao.Empresa.EnderecoPrincipal.Cidade;
  FDataModule.ACBrBoleto.Cedente.UF := Sessao.Empresa.EnderecoPrincipal.Uf;


  CDSParcelaReceber.DisableControls;
  CDSParcelaReceber.First;
  while not CDSParcelaReceber.Eof do
  begin
    if CDSParcelaReceber.FieldByName('EMITIU_BOLETO').AsString = 'S' then
    begin
      Titulo := FDataModule.ACBrBoleto.CriarTituloNaLista;

      Titulo.LocalPagamento := ConfiguracaoBoletoVO.LocalPagamento;
      Titulo.Vencimento := CDSParcelaReceber.FieldByName('DATA_VENCIMENTO').AsDateTime;
      Titulo.DataDocumento := Now;
      Titulo.DataProcessamento := Now;
      Titulo.EspecieDoc := ConfiguracaoBoletoVO.Especie;
      if ConfiguracaoBoletoVO.Aceite = 'S' then
        Titulo.Aceite := atSim
      else
        Titulo.Aceite := atNao;
      Titulo.NumeroDocumento := CDSParcelaReceber.FieldByName('BOLETO_NOSSO_NUMERO').AsString;
      Titulo.NossoNumero := CDSParcelaReceber.FieldByName('BOLETO_NOSSO_NUMERO').AsString;
      Titulo.Carteira := ConfiguracaoBoletoVO.Carteira;

      Titulo.Sacado.NomeSacado := ClienteVO.Nome;
      Titulo.Sacado.CNPJCPF := ClienteVO.CpfCnpj;

      Titulo.Sacado.Logradouro := ClienteVO.Logradouro;
      Titulo.Sacado.Numero := ClienteVO.Numero;
      Titulo.Sacado.Bairro := ClienteVO.Bairro;
      Titulo.Sacado.Cidade := ClienteVO.Cidade;
      Titulo.Sacado.UF := ClienteVO.Uf;
      Titulo.Sacado.CEP := ClienteVO.Cep;

      Titulo.TotalParcelas := EditQuantidadeParcelas.AsInteger;
      Titulo.ValorDesconto := CDSParcelaReceber.FieldByName('VALOR_DESCONTO').AsFloat;
      Titulo.DataDesconto := CDSParcelaReceber.FieldByName('DESCONTO_ATE').AsDateTime;
      Titulo.ValorDocumento := CDSParcelaReceber.FieldByName('VALOR').AsFloat;
      Titulo.Parcela := CDSParcelaReceber.FieldByName('NUMERO_PARCELA').AsInteger;
      Titulo.PercentualMulta := CDSParcelaReceber.FieldByName('TAXA_MULTA').AsFloat;

      Titulo.Instrucao1 := ConfiguracaoBoletoVO.Instrucao01;
      Titulo.Instrucao2 := ConfiguracaoBoletoVO.Instrucao02;

      FDataModule.ACBrBoleto.AdicionarMensagensPadroes(Titulo, TStrings(ConfiguracaoBoletoVO.Mensagem));
    end;
    CDSParcelaReceber.Next;
  end;
  CDSParcelaReceber.First;
  CDSParcelaReceber.EnableControls;

  if Application.MessageBox('Deseja emitir os boletos?', 'Pergunta do Sistema', MB_YesNo + MB_IconQuestion) = IdYes then
  begin
    //FDataModule.ACBrBoleto.ACBrBoletoFC.DirArqPDF_HTML := StringReplace(ConfiguracaoBoletoVO.CaminhoArquivoPdf,'/','\',[rfReplaceAll]);
    //FDataModule.ACBrBoleto.ACBrBoletoFC.NomeArquivo := 'boleto.pdf';
    FDataModule.ACBrBoleto.ACBrBoletoFC.NomeArquivo := StringReplace(ConfiguracaoBoletoVO.CaminhoArquivoPdf,'/','\',[rfReplaceAll]) + 'boleto.pdf';
    FDataModule.ACBrBoleto.GerarPDF;

    GetMem(Pdir, 256);
    StrPCopy(Pdir, StringReplace(ConfiguracaoBoletoVO.CaminhoArquivoPdf,'/','\',[rfReplaceAll]));
    OpenDocument(ConfiguracaoBoletoVO.CaminhoArquivoPdf + 'boleto.pdf'); { *Converted from ShellExecute* }
    FreeMem(Pdir, 256);
  end;

  if Application.MessageBox('Deseja gerar o arquivo de remessa?', 'Pergunta do Sistema', MB_YesNo + MB_IconQuestion) = IdYes then
  begin
    FDataModule.ACBrBoleto.NomeArqRemessa := 'arquivo_remessa.txt';
    //FDataModule.ACBrBoleto.GerarRemessa(1);  /// EXERCICIO: Verifique se o método está devidamente implementado no ACBr
    Application.MessageBox('Remessa gerada com sucesso.', 'Informação do Sistema', MB_OK + MB_ICONINFORMATION)
  end;
end;

procedure TFFinLancamentoReceber.ActionGerarParcelasExecute(Sender: TObject);
begin
  if EditIdContaCaixa.AsInteger <= 0 then
  begin
    Application.MessageBox('É necessário informar a conta/caixa para previsão das parcelas.', 'Mensagem do Sistema', MB_OK + MB_ICONINFORMATION);
    EditIdContaCaixa.SetFocus;
    Exit;
  end;

  if not CDSParcelaReceber.IsEmpty then
  begin
    if Application.MessageBox('Já existem parcelas geradas e serão excluídas. Deseja continuar?', 'Pergunta do Sistema', MB_YesNo + MB_IconQuestion) = IdYes then
    begin
      CDSParcelaReceber.DisableControls;
      CDSParcelaReceber.First;
      while not CDSParcelaReceber.Eof do
      begin
        if CDSParcelaReceber.FieldByName('ID').AsInteger > 0 then
          TFinParcelaReceberController.Exclui(CDSParcelaReceber.FieldByName('ID').AsInteger);

        CDSParcelaReceber.Next;
      end;
      CDSParcelaReceber.First;
      CDSParcelaReceber.EnableControls;

      CDSParcelaReceber.Close;
      CDSParcelaReceber.Open;
      GerarParcelas;
    end;
  end
  else
    GerarParcelas;
end;

procedure TFFinLancamentoReceber.GerarParcelas;
var
  I: Integer;
  Vencimento: TDate;
  SomaParcelas, Residuo: Extended;
begin
  if EditQuantidadeParcelas.AsInteger <= 0 then
    EditQuantidadeParcelas.AsInteger := 1;

  if EditPrimeiroVencimento.Text = '  /  /    ' then
    EditPrimeiroVencimento.Date := Date;

  Vencimento := EditPrimeiroVencimento.Date;
  SomaParcelas := 0;
  Residuo := 0;

  for I := 0 to EditQuantidadeParcelas.AsInteger - 1 do
  begin
    CDSParcelaReceber.Append;
    CDSParcelaReceber.FieldByName('NUMERO_PARCELA').AsInteger := I + 1;
    CDSParcelaReceber.FieldByName('ID_CONTA_CAIXA').AsInteger := EditIdContaCaixa.AsInteger;
    CDSParcelaReceber.FieldByName('DATA_EMISSAO').AsString := DateToStr(Date);
    CDSParcelaReceber.FieldByName('DATA_VENCIMENTO').AsString := DateToStr(Vencimento + (EditIntervalorEntreParcelas.AsInteger * I));
    CDSParcelaReceber.FieldByName('DESCONTO_ATE').AsString := DateToStr(Date);
    CDSParcelaReceber.FieldByName('VALOR').AsFloat := ArredondaTruncaValor('A', EditValorAReceber.Value / EditQuantidadeParcelas.AsInteger, Constantes.TConstantes.DECIMAIS_VALOR);
    CDSParcelaReceber.FieldByName('CONTA_CAIXA.NOME').AsString := EditContaCaixa.Text;
    CDSParcelaReceber.Post;

    SomaParcelas := SomaParcelas + CDSParcelaReceber.FieldByName('VALOR').AsFloat;
  end;

  // calcula o resíduo e lança na última parcela
  Residuo := EditValorAReceber.Value - SomaParcelas;
  CDSParcelaReceber.Edit;
  CDSParcelaReceber.FieldByName('VALOR').AsFloat := CDSParcelaReceber.FieldByName('VALOR').AsFloat + Residuo;
  CDSParcelaReceber.Post;
end;
{$ENDREGION}


/// EXERCICIO: GERE OS LANCAMENTOS DOS RECEBIMENTOS VINCULADOS A FRENTE DE CAIXA E VENDAS EXTERNAS

end.

