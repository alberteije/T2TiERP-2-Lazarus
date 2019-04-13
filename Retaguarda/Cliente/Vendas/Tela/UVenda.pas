{ *******************************************************************************
Title: T2Ti ERP
Description: Janela de Vendas

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
t2ti.com@gmail.com

@author Albert Eije
@version 2.0
******************************************************************************* }
unit UVenda;

interface

uses
  BrookHTTPClient, BrookFCLHTTPClientBroker, BrookHTTPUtils, BrookUtils, FPJson, ZDataset,
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UTelaCadastro, Menus, StdCtrls, ExtCtrls, Buttons, Grids, DBGrids,
  ComCtrls, LabeledCtrls, rxdbgrid, rxtoolbar, DBCtrls, StrUtils,
  Math, Constantes, CheckLst, ActnList, ToolWin, ShellApi, db, BufDataset, Biblioteca,
  ULookup, VO;

  type

  TFVenda = class(TFTelaCadastro)
    CDSVendaDetalhe: TBufDataSet;
    DSVendaDetalhe: TDataSource;
    GroupBoxParcelas: TGroupBox;
    GridParcelas: TRxDbGrid;
    ScrollBox1: TScrollBox;
    BevelEdits: TBevel;
    EditLocalEntrega: TLabeledEdit;
    MemoObservacao: TLabeledMemo;
    EditValorSubtotal: TLabeledCalcEdit;
    EditValorFrete: TLabeledCalcEdit;
    EditValorComissao: TLabeledCalcEdit;
    EditTaxaComissao: TLabeledCalcEdit;
    EditVendedor: TLabeledEdit;
    EditCliente: TLabeledEdit;
    EditCondicoesPagamento: TLabeledEdit;
    EditTransportadora: TLabeledEdit;
    ComboBoxTipoVenda: TLabeledComboBox;
    ComboBoxTipoFrete: TLabeledComboBox;
    EditDataVenda: TLabeledDateEdit;
    EditDataSaida: TLabeledDateEdit;
    EditValorDesconto: TLabeledCalcEdit;
    EditTaxaDesconto: TLabeledCalcEdit;
    EditValorTotal: TLabeledCalcEdit;
    EditIdVendedor: TLabeledCalcEdit;
    EditIdCliente: TLabeledCalcEdit;
    EditIdCondicoesPagamento: TLabeledCalcEdit;
    EditIdTransportadora: TLabeledCalcEdit;
    EditIdTipoNotaFiscal: TLabeledCalcEdit;
    EditTipoNotaFiscal: TLabeledEdit;
    EditIdOrcamentoVendaCabecalho: TLabeledCalcEdit;
    EditOrcamentoVendaCabecalho: TLabeledEdit;
    EditHoraSaida: TLabeledMaskEdit;
    EditNumeroFatura: TLabeledCalcEdit;
    EditLocalCobranca: TLabeledEdit;
    ComboBoxFormaPagamento: TLabeledComboBox;
    ActionManager1: TActionList;
    ActionAtualizarTotais: TAction;
    ActionToolBar1: TToolPanel;
    ActionAdicionarProduto: TAction;
    EditValorSeguro: TLabeledCalcEdit;
    ActionExcluirItem: TAction;
    procedure FormCreate(Sender: TObject);
    procedure EditIdVendedorKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure EditIdClienteKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure EditIdTransportadoraKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure EditIdCondicoesPagamentoKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure EditIdCondicoesPagamentoExit(Sender: TObject);
    procedure EditTaxaDescontoExit(Sender: TObject);
    procedure CDSVendaDetalheBeforePost(DataSet: TDataSet);
    procedure EditIdOrcamentoVendaCabecalhoKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure EditIdTipoNotaFiscalKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure ComboBoxTipoVendaChange(Sender: TObject);
    procedure EditIdVendedorExit(Sender: TObject);
    procedure EditIdClienteExit(Sender: TObject);
    procedure EditIdTransportadoraExit(Sender: TObject);
    procedure EditIdTipoNotaFiscalExit(Sender: TObject);
    procedure EditIdOrcamentoVendaCabecalhoExit(Sender: TObject);
    procedure EditIdOrcamentoVendaCabecalhoKeyPress(Sender: TObject; var Key: Char);
    procedure EditIdTipoNotaFiscalKeyPress(Sender: TObject; var Key: Char);
    procedure EditIdVendedorKeyPress(Sender: TObject; var Key: Char);
    procedure EditIdClienteKeyPress(Sender: TObject; var Key: Char);
    procedure EditIdCondicoesPagamentoKeyPress(Sender: TObject; var Key: Char);
    procedure EditIdTransportadoraKeyPress(Sender: TObject; var Key: Char);
    procedure ActionAtualizarTotaisExecute(Sender: TObject);
    procedure GridParcelasKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure ActionAdicionarProdutoExecute(Sender: TObject);
    procedure ActionExcluirItemExecute(Sender: TObject);
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
    procedure HabilitarEditVendaOrcamento;
  end;

var
  FVenda: TFVenda;
  VistaPrazo: String;
  LimiteCredito: Extended;

implementation

uses VendaCabecalhoController, VendaCabecalhoVO,
  VendaDetalheVO, VendedorVO, VendedorController, VendaCondicoesPagamentoVO,
  VendaCondicoesPagamentoController, VendaOrcamentoCabecalhoVO, NotaFiscalTipoController,
  NotaFiscalTipoVO, VendaOrcamentoCabecalhoController, ViewPessoaTransportadoraVO,
  ViewPessoaTransportadoraController, ViewPessoaClienteVO, ViewPessoaClienteController,
  VendaComissaoVO, ProdutoVO, ProdutoController, VendaOrcamentoDetalheController,
  VendaDetalheController;
{$R *.lfm}
//

{$REGION 'Infra'}
procedure TFVenda.BotaoConsultarClick(Sender: TObject);
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
    RetornoConsulta := TVendaCabecalhoController.Consulta(Filtro, IntToStr(Pagina));
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

procedure TFVenda.BotaoSalvarClick(Sender: TObject);
begin
  inherited;
  BotaoConsultarClick(Sender);
end;

procedure TFVenda.FormCreate(Sender: TObject);
begin
  ClasseObjetoGridVO := TVendaCabecalhoVO;
  ObjetoController := TVendaCabecalhoController.Create;

  LimiteCredito := 0;

  inherited;

  ConfiguraCDSFromVO(CDSVendaDetalhe, TVendaDetalheVO);

  BotaoImprimir.Visible := False;
  MenuImprimir.Visible := False;
end;

procedure TFVenda.ComboBoxTipoVendaChange(Sender: TObject);
begin
  HabilitarEditVendaOrcamento;
  if ComboBoxTipoVenda.ItemIndex = 0 then
    EditIdOrcamentoVendaCabecalho.SetFocus
  else
    EditIdTipoNotaFiscal.SetFocus;
end;

procedure TFVenda.EditTaxaDescontoExit(Sender: TObject);
begin
  EditValorDesconto.Value := EditValorSubtotal.Value * (EditTaxaDesconto.Value / 100);
  EditValorTotal.Value := EditValorSubtotal.Value - EditValorDesconto.Value;
end;

procedure TFVenda.LimparCampos;
begin
  inherited;
  CDSVendaDetalhe.Close;
  CDSVendaDetalhe.Open;
end;
{$ENDREGION}

{$REGION 'Controles CRUD'}
function TFVenda.DoInserir: Boolean;
begin
  Result := inherited DoInserir;

  if Result then
  begin
    ComboBoxTipoVenda.SetFocus;
  end;
end;

function TFVenda.DoEditar: Boolean;
var
  Mensagem: String;
begin
  if CDSGrid.FieldByName('SITUACAO').AsString <> 'D' then
  begin
    case AnsiIndexStr(CDSGrid.FieldByName('SITUACAO').AsString, ['P', 'X', 'F', 'E']) of
      0:
        Mensagem := ' - Situação: Em Produção';
      1:
        Mensagem := ' - Situação: Em Expedição';
      2:
        Mensagem := ' - Situação: Faturado';
      3:
        Mensagem := ' - Situação: Entregue';
    end;

    Application.MessageBox(PChar('Esse registro não pode ser alterado' + Mensagem), 'Mensagem do Sistema', MB_OK + MB_ICONINFORMATION);
    Exit(False);
  end;

  Result := inherited DoEditar;

  if Result then
  begin
    ComboBoxTipoVenda.SetFocus;
  end;
end;

function TFVenda.DoExcluir: Boolean;
begin
  if inherited DoExcluir then
  begin
    try
      Result := TVendaCabecalhoController.Exclui(IdRegistroSelecionado);
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

function TFVenda.DoSalvar: Boolean;
var
  VendaDetalhe: TVendaDetalheVO;
  VendaComissao: TVendaComissaoVO;
begin
  try
    if VistaPrazo = 'P' then
    begin
      if LimiteCredito <= EditValorTotal.Value then
      begin
        Application.MessageBox('Cliente não tem limite de crédito para concluir essa venda a prazo.', 'Mensagem do Sistema', MB_OK + MB_ICONINFORMATION);
        EditIdCliente.SetFocus;
        Exit(False);
      end;
    end;
    if EditIdCondicoesPagamento.AsInteger <= 0 then
    begin
      Application.MessageBox('É necessário informar as condições de pagamento.', 'Mensagem do Sistema', MB_OK + MB_ICONINFORMATION);
      EditIdCondicoesPagamento.SetFocus;
      Exit(False);
    end;
    if EditIdTipoNotaFiscal.AsInteger <= 0 then
    begin
      Application.MessageBox('É necessário informar o tipo de nota fiscal.', 'Mensagem do Sistema', MB_OK + MB_ICONINFORMATION);
      EditIdTipoNotaFiscal.SetFocus;
      Exit(False);
    end;
    if EditIdCliente.AsInteger <= 0 then
    begin
      Application.MessageBox('É necessário informar o cliente.', 'Mensagem do Sistema', MB_OK + MB_ICONINFORMATION);
      EditIdCliente.SetFocus;
      Exit(False);
    end;
    if EditIdVendedor.AsInteger <= 0 then
    begin
      Application.MessageBox('É necessário informar o vendedor.', 'Mensagem do Sistema', MB_OK + MB_ICONINFORMATION);
      EditIdVendedor.SetFocus;
      Exit(False);
    end;

    Result := inherited DoSalvar;

    if Result then
    begin
      try
        if not Assigned(ObjetoVO) then
          ObjetoVO := TVendaCabecalhoVO.Create;

        ActionAtualizarTotais.Execute;

        TVendaCabecalhoVO(ObjetoVO).IdTipoNotaFiscal := EditIdTipoNotaFiscal.AsInteger;
        TVendaCabecalhoVO(ObjetoVO).TipoNotaFiscalModelo := EditTipoNotaFiscal.Text;
        TVendaCabecalhoVO(ObjetoVO).IdVendedor := EditIdVendedor.AsInteger;
        TVendaCabecalhoVO(ObjetoVO).VendedorNome := EditVendedor.Text;
        TVendaCabecalhoVO(ObjetoVO).IdTransportadora := EditIdTransportadora.AsInteger;
        TVendaCabecalhoVO(ObjetoVO).TransportadoraNome := EditTransportadora.Text;
        TVendaCabecalhoVO(ObjetoVO).IdCliente := EditIdCliente.AsInteger;
        TVendaCabecalhoVO(ObjetoVO).ClienteNome := EditCliente.Text;
        TVendaCabecalhoVO(ObjetoVO).IdVendaCondicoesPagamento := EditIdCondicoesPagamento.AsInteger;
        TVendaCabecalhoVO(ObjetoVO).VendaCondicoesPagamentoNome := EditCondicoesPagamento.Text;
        TVendaCabecalhoVO(ObjetoVO).IdVendaOrcamentoCabecalho := EditIdOrcamentoVendaCabecalho.AsInteger;
        TVendaCabecalhoVO(ObjetoVO).VendaOrcamentoCabecalhoCodigo := EditOrcamentoVendaCabecalho.Text;
        TVendaCabecalhoVO(ObjetoVO).DataVenda := EditDataVenda.Date;
        TVendaCabecalhoVO(ObjetoVO).DataSaida := EditDataSaida.Date;
        TVendaCabecalhoVO(ObjetoVO).HoraSaida := EditHoraSaida.Text;
        TVendaCabecalhoVO(ObjetoVO).NumeroFatura := EditNumeroFatura.AsInteger;
        TVendaCabecalhoVO(ObjetoVO).LocalEntrega := EditLocalEntrega.Text;
        TVendaCabecalhoVO(ObjetoVO).LocalCobranca := EditLocalCobranca.Text;
        TVendaCabecalhoVO(ObjetoVO).ValorSubtotal := EditValorSubtotal.Value;
        TVendaCabecalhoVO(ObjetoVO).TaxaComissao := EditTaxaComissao.Value;
        TVendaCabecalhoVO(ObjetoVO).ValorComissao := EditValorComissao.Value;
        TVendaCabecalhoVO(ObjetoVO).TaxaDesconto := EditTaxaDesconto.Value;
        TVendaCabecalhoVO(ObjetoVO).ValorDesconto := EditValorDesconto.Value;
        TVendaCabecalhoVO(ObjetoVO).ValorTotal := EditValorTotal.Value;
        TVendaCabecalhoVO(ObjetoVO).TipoFrete := IfThen(ComboBoxTipoFrete.ItemIndex = 0, 'C', 'F');
        TVendaCabecalhoVO(ObjetoVO).FormaPagamento := Copy(ComboBoxFormaPagamento.Text, 1, 1);
        TVendaCabecalhoVO(ObjetoVO).ValorFrete := EditValorFrete.Value;
        TVendaCabecalhoVO(ObjetoVO).ValorSeguro := EditValorSeguro.Value;
        TVendaCabecalhoVO(ObjetoVO).Observacao := MemoObservacao.Text;
        TVendaCabecalhoVO(ObjetoVO).Situacao := 'D';

        if StatusTela = stEditando then
          TVendaCabecalhoVO(ObjetoVO).Id := IdRegistroSelecionado;

        // Itens da venda
        CDSVendaDetalhe.DisableControls;
        CDSVendaDetalhe.First;
        while not CDSVendaDetalhe.Eof do
        begin
            VendaDetalhe := TVendaDetalheVO.Create;
            VendaDetalhe.Id := CDSVendaDetalhe.FieldByName('ID').AsInteger;
            VendaDetalhe.IdVendaCabecalho := TVendaCabecalhoVO(ObjetoVO).Id;
            VendaDetalhe.IdProduto := CDSVendaDetalhe.FieldByName('ID_PRODUTO').AsInteger;
            VendaDetalhe.Quantidade := CDSVendaDetalhe.FieldByName('QUANTIDADE').AsFloat;
            VendaDetalhe.ValorUnitario := CDSVendaDetalhe.FieldByName('VALOR_UNITARIO').AsFloat;
            VendaDetalhe.ValorSubtotal := CDSVendaDetalhe.FieldByName('VALOR_SUBTOTAL').AsFloat;
            VendaDetalhe.TaxaDesconto := CDSVendaDetalhe.FieldByName('TAXA_DESCONTO').AsFloat;
            VendaDetalhe.ValorDesconto := CDSVendaDetalhe.FieldByName('VALOR_DESCONTO').AsFloat;
            VendaDetalhe.ValorTotal := CDSVendaDetalhe.FieldByName('VALOR_TOTAL').AsFloat;
            VendaDetalhe.TaxaComissao := CDSVendaDetalhe.FieldByName('TAXA_COMISSAO').AsFloat;
            VendaDetalhe.ValorComissao := CDSVendaDetalhe.FieldByName('VALOR_COMISSAO').AsFloat;
            TVendaCabecalhoVO(ObjetoVO).ListaVendaDetalheVO.Add(VendaDetalhe);

          CDSVendaDetalhe.Next;
        end;
        CDSVendaDetalhe.EnableControls;

        if StatusTela = stInserindo then
        begin
        TVendaCabecalhoController.Insere(TVendaCabecalhoVO(ObjetoVO));
        end
        else if StatusTela = stEditando then
      begin
        /// EXERCICIO: Verifique se tem como serializar as listas junto com o objeto para realizar a comparação
        //if TVendaCabecalhoVO(ObjetoVO).ToJSONString <> StringObjetoOld then
        //begin
          TVendaCabecalhoController.Altera(TVendaCabecalhoVO(ObjetoVO));
        //end
        //else
        //Application.MessageBox('Nenhum dado foi alterado.', 'Mensagem do Sistema', MB_OK + MB_ICONINFORMATION);
        end;
      except
        Result := False;
      end;
    end;
  finally
  end;
end;
{$ENDREGION}

{$REGION 'Controle de Grid'}
procedure TFVenda.GridParaEdits;
var
  IdCabecalho: String;
  Current: TVendaDetalheVO;
  I: Integer;
begin
  inherited;

  if not CDSGrid.IsEmpty then
  begin
    IdCabecalho := IntToStr(IdRegistroSelecionado);
    ObjetoVO := TVendaCabecalhoController.ConsultaObjeto('ID=' + IdCabecalho);
  end;

  if Assigned(ObjetoVO) then
  begin

    if TVendaCabecalhoVO(ObjetoVO).IdVendaOrcamentoCabecalho = 0 then
      ComboBoxTipoVenda.ItemIndex := 0
    else
    begin
      ComboBoxTipoVenda.ItemIndex := 1;
      EditIdOrcamentoVendaCabecalho.AsInteger := TVendaCabecalhoVO(ObjetoVO).IdVendaOrcamentoCabecalho;
      EditOrcamentoVendaCabecalho.Text := TVendaCabecalhoVO(ObjetoVO).VendaOrcamentoCabecalhoCodigo;
    end;

    EditIdVendedor.AsInteger := TVendaCabecalhoVO(ObjetoVO).IdVendedor;
    EditVendedor.Text := TVendaCabecalhoVO(ObjetoVO).VendedorVO.ColaboradorVO.PessoaVO.Nome;
    EditIdTransportadora.AsInteger := TVendaCabecalhoVO(ObjetoVO).IdTransportadora;
    EditTransportadora.Text := TVendaCabecalhoVO(ObjetoVO).TransportadoraVO.Nome;
    EditIdCliente.AsInteger := TVendaCabecalhoVO(ObjetoVO).IdCliente;
    EditCliente.Text := TVendaCabecalhoVO(ObjetoVO).ClienteVO.Nome;
    EditIdCondicoesPagamento.AsInteger := TVendaCabecalhoVO(ObjetoVO).IdVendaCondicoesPagamento;
    EditCondicoesPagamento.Text := TVendaCabecalhoVO(ObjetoVO).VendaCondicoesPagamentoVO.Nome;
    EditIdTipoNotaFiscal.AsInteger := TVendaCabecalhoVO(ObjetoVO).IdTipoNotaFiscal;
    EditTipoNotaFiscal.Text := TVendaCabecalhoVO(ObjetoVO).TipoNotaFiscalModelo;
    EditDataVenda.Date := TVendaCabecalhoVO(ObjetoVO).DataVenda;
    EditDataSaida.Date := TVendaCabecalhoVO(ObjetoVO).DataSaida;
    EditHoraSaida.Text := TVendaCabecalhoVO(ObjetoVO).HoraSaida;
    EditNumeroFatura.AsInteger := TVendaCabecalhoVO(ObjetoVO).NumeroFatura;
    EditLocalEntrega.Text := TVendaCabecalhoVO(ObjetoVO).LocalEntrega;
    EditLocalCobranca.Text := TVendaCabecalhoVO(ObjetoVO).LocalCobranca;
    EditValorSubtotal.Value := TVendaCabecalhoVO(ObjetoVO).ValorSubtotal;
    EditTaxaComissao.Value := TVendaCabecalhoVO(ObjetoVO).TaxaComissao;
    EditValorComissao.Value := TVendaCabecalhoVO(ObjetoVO).ValorComissao;
    EditTaxaDesconto.Value := TVendaCabecalhoVO(ObjetoVO).TaxaDesconto;
    EditValorDesconto.Value := TVendaCabecalhoVO(ObjetoVO).ValorDesconto;
    EditValorTotal.Value := TVendaCabecalhoVO(ObjetoVO).ValorTotal;
    EditValorFrete.Value := TVendaCabecalhoVO(ObjetoVO).ValorFrete;
    EditValorSeguro.Value := TVendaCabecalhoVO(ObjetoVO).ValorSeguro;

    ComboBoxTipoFrete.ItemIndex := AnsiIndexStr(TVendaCabecalhoVO(ObjetoVO).TipoFrete, ['C', 'F']);

    ComboBoxFormaPagamento.ItemIndex := StrToInt(TVendaCabecalhoVO(ObjetoVO).FormaPagamento);
    MemoObservacao.Text := TVendaCabecalhoVO(ObjetoVO).Observacao;

    // Itens da venda
    for I := 0 to TVendaCabecalhoVO(ObjetoVO).ListaVendaDetalheVO.Count - 1 do
    begin
      Current := TVendaCabecalhoVO(ObjetoVO).ListaVendaDetalheVO[I];
      CDSVendaDetalhe.Append;

      CDSVendaDetalhe.FieldByName('ID').AsInteger := Current.Id;
      CDSVendaDetalhe.FieldByName('ID_VENDA_CABECALHO').AsInteger := Current.IdVendaCabecalho;
      CDSVendaDetalhe.FieldByName('ID_PRODUTO').AsInteger := Current.IdProduto;
      CDSVendaDetalhe.FieldByName('QUANTIDADE').AsFloat := Current.Quantidade;
      CDSVendaDetalhe.FieldByName('VALOR_UNITARIO').AsFloat := Current.ValorUnitario;
      CDSVendaDetalhe.FieldByName('VALOR_SUBTOTAL').AsFloat := Current.ValorSubtotal;
      CDSVendaDetalhe.FieldByName('TAXA_DESCONTO').AsFloat := Current.TaxaDesconto;
      CDSVendaDetalhe.FieldByName('VALOR_DESCONTO').AsFloat := Current.ValorDesconto;
      CDSVendaDetalhe.FieldByName('VALOR_TOTAL').AsFloat := Current.ValorTotal;
      CDSVendaDetalhe.FieldByName('TAXA_COMISSAO').AsFloat := Current.TaxaComissao;
      CDSVendaDetalhe.FieldByName('VALOR_COMISSAO').AsFloat := Current.ValorComissao;

      CDSVendaDetalhe.Post;
    end;

    // Serializa o objeto para consultar posteriormente se houve alterações
    FormatSettings.DecimalSeparator := '.';
    StringObjetoOld := ObjetoVO.ToJSONString;
    FormatSettings.DecimalSeparator := ',';
  end;
end;

procedure TFVenda.GridParcelasKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = VK_F1 then
  begin
    ActionAdicionarProduto.Execute;
  end;
  If Key = VK_RETURN then
    EditIdVendedor.SetFocus;
end;

procedure TFVenda.CDSVendaDetalheBeforePost(DataSet: TDataSet);
begin
  CDSVendaDetalhe.FieldByName('VALOR_SUBTOTAL').AsFloat := CDSVendaDetalhe.FieldByName('QUANTIDADE').AsFloat * CDSVendaDetalhe.FieldByName('VALOR_UNITARIO').AsFloat;
  CDSVendaDetalhe.FieldByName('VALOR_DESCONTO').AsFloat := CDSVendaDetalhe.FieldByName('VALOR_SUBTOTAL').AsFloat * (CDSVendaDetalhe.FieldByName('TAXA_DESCONTO').AsFloat / 100);
  CDSVendaDetalhe.FieldByName('VALOR_TOTAL').AsFloat := CDSVendaDetalhe.FieldByName('VALOR_SUBTOTAL').AsFloat - CDSVendaDetalhe.FieldByName('VALOR_DESCONTO').AsFloat;
end;
{$ENDREGION}

{$REGION 'Campos Transientes'}

/// EXERCICIO: Adapte para a forma de pesquisa usando o evento OnKeyUP e use a janela FLookup

// Orçamento
procedure TFVenda.EditIdOrcamentoVendaCabecalhoExit(Sender: TObject);
var
  VendaOrcamentoCabecalhoVO :TVendaOrcamentoCabecalhoVO ;
  CDSOrcamentoPedidoVendaDet : TZQuery;
begin
  if EditIdOrcamentoVendaCabecalho.Value <> 0 then
  begin
    try
      Filtro := 'ID = ' + EditIdOrcamentoVendaCabecalho.Text +  ' AND SITUACAO = ' + QuotedStr('D');
      EditIdOrcamentoVendaCabecalho.Clear;
      EditOrcamentoVendaCabecalho.Clear;

        VendaOrcamentoCabecalhoVO := TVendaOrcamentoCabecalhoController.ConsultaObjeto(Filtro);
        if Assigned(VendaOrcamentoCabecalhoVO) then
      begin
        EditIdOrcamentoVendaCabecalho.Text := CDSTransiente.FieldByName('ID').AsString;
        EditOrcamentoVendaCabecalho.Text := CDSTransiente.FieldByName('CODIGO').AsString;
        // Vendedor
        EditIdVendedor.Text := CDSTransiente.FieldByName('ID_VENDEDOR').AsString;
        EditVendedor.Text := CDSTransiente.FieldByName('VENDEDOR.NOME').AsString;
        // Cliente
        EditIdCliente.Text := CDSTransiente.FieldByName('ID_CLIENTE').AsString;
        EditCliente.Text := CDSTransiente.FieldByName('CLIENTE.NOME').AsString;
        // Condicoes Pagamento
        EditIdCondicoesPagamento.Text := CDSTransiente.FieldByName('ID_VENDA_CONDICOES_PAGAMENTO').AsString;
        EditCondicoesPagamento.Text := CDSTransiente.FieldByName('CONDICOESPAGAMENTO.NOME').AsString;
        // Transportadora
        EditIdTransportadora.Text := CDSTransiente.FieldByName('ID_TRANSPORTADORA').AsString;
        EditTransportadora.Text := CDSTransiente.FieldByName('TRANSPORTADORA.NOME').AsString;
        // Frete
        EditValorFrete.Value := CDSTransiente.FieldByName('VALOR_FRETE').AsFloat;
        ComboBoxTipoFrete.ItemIndex := AnsiIndexStr(CDSTransiente.FieldByName('TIPO_FRETE').AsString, ['C', 'F']);
        // Valores
        EditValorSubtotal.Value := CDSTransiente.FieldByName('VALOR_SUBTOTAL').AsFloat;
        EditTaxaComissao.Value := CDSTransiente.FieldByName('TAXA_COMISSAO').AsFloat;
        EditValorComissao.Value := CDSTransiente.FieldByName('VALOR_COMISSAO').AsFloat;
        EditTaxaDesconto.Value := CDSTransiente.FieldByName('TAXA_DESCONTO').AsFloat;
        EditValorDesconto.Value := CDSTransiente.FieldByName('VALOR_DESCONTO').AsFloat;
        EditValorTotal.Value := CDSTransiente.FieldByName('VALOR_TOTAL').AsFloat;

        MemoObservacao.Text := CDSTransiente.FieldByName('OBSERVACAO').AsString;

        // Detalhes
        if StatusTela = stInserindo then
        begin
          CDSVendaDetalhe.Close;
          CDSVendaDetalhe.Open;

          /// EXERCICIO: Carregue os dados do orcamento da venda

          while not CDSOrcamentoPedidoVendaDet.Eof do
          begin
            CDSVendaDetalhe.Append;
            CDSVendaDetalhe.FieldByName('ID_PRODUTO').AsInteger := CDSOrcamentoPedidoVendaDet.FieldByName('ID_PRODUTO').AsInteger;
            CDSVendaDetalhe.FieldByName('PRODUTONOME').AsString := CDSOrcamentoPedidoVendaDet.FieldByName('PRODUTONOME').AsString;
            CDSVendaDetalhe.FieldByName('QUANTIDADE').AsFloat := CDSOrcamentoPedidoVendaDet.FieldByName('QUANTIDADE').AsFloat;
            CDSVendaDetalhe.FieldByName('VALOR_UNITARIO').AsFloat := CDSOrcamentoPedidoVendaDet.FieldByName('VALOR_UNITARIO').AsFloat;
            CDSVendaDetalhe.FieldByName('VALOR_SUBTOTAL').AsFloat := CDSOrcamentoPedidoVendaDet.FieldByName('VALOR_SUBTOTAL').AsFloat;
            CDSVendaDetalhe.FieldByName('TAXA_DESCONTO').AsFloat := CDSOrcamentoPedidoVendaDet.FieldByName('TAXA_DESCONTO').AsFloat;
            CDSVendaDetalhe.FieldByName('VALOR_DESCONTO').AsFloat := CDSOrcamentoPedidoVendaDet.FieldByName('VALOR_DESCONTO').AsFloat;
            CDSVendaDetalhe.FieldByName('VALOR_TOTAL').AsFloat := CDSOrcamentoPedidoVendaDet.FieldByName('VALOR_TOTAL').AsFloat;
            CDSVendaDetalhe.Post;

            CDSOrcamentoPedidoVendaDet.Next;
          end;
        end;
        //
        HabilitarEditVendaOrcamento;
      end
      else
      begin
        Exit;
        EditIdOrcamentoVendaCabecalho.SetFocus;
      end;
    finally
    end;
  end
  else
  begin
    EditOrcamentoVendaCabecalho.Clear;
  end;
end;

procedure TFVenda.EditIdOrcamentoVendaCabecalhoKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = VK_F1 then
  begin
    EditIdOrcamentoVendaCabecalho.Value := -1;
    EditIdTipoNotaFiscal.SetFocus;
  end;
end;

procedure TFVenda.EditIdOrcamentoVendaCabecalhoKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
  begin
    Key := #0;
    EditIdTipoNotaFiscal.SetFocus;
  end;
end;

// Tipo de Nota Fiscal
procedure TFVenda.EditIdTipoNotaFiscalExit(Sender: TObject);
var
  NotaFiscalTipoVO :TNotaFiscalTipoVO ;
begin
  if EditIdTipoNotaFiscal.Value <> 0 then
  begin
    try
      Filtro := 'ID = ' + EditIdTipoNotaFiscal.Text;
      EditIdTipoNotaFiscal.Clear;
      EditTipoNotaFiscal.Clear;

        NotaFiscalTipoVO := TNotaFiscalTipoController.ConsultaObjeto(Filtro);
        if Assigned(NotaFiscalTipoVO) then
      begin
        EditIdTipoNotaFiscal.Text := CDSTransiente.FieldByName('ID').AsString;
        EditTipoNotaFiscal.Text := CDSTransiente.FieldByName('NOME').AsString;
      end
      else
      begin
        Exit;
        EditIdTipoNotaFiscal.SetFocus;
      end;
    finally
    end;
  end
  else
  begin
    EditTipoNotaFiscal.Clear;
  end;
end;

procedure TFVenda.EditIdTipoNotaFiscalKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = VK_F1 then
  begin
    EditIdTipoNotaFiscal.Value := -1;
    if ComboBoxTipoVenda.ItemIndex = 1 then
      EditIdVendedor.SetFocus
    else
      ComboBoxTipoFrete.SetFocus;
  end;
end;

procedure TFVenda.EditIdTipoNotaFiscalKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
  begin
    Key := #0;
    if ComboBoxTipoVenda.ItemIndex = 1 then
      EditIdVendedor.SetFocus
    else
      ComboBoxTipoFrete.SetFocus;
  end;
end;

// Vendedor
procedure TFVenda.EditIdVendedorExit(Sender: TObject);
var
  VendedorVO :TVendedorVO ;
begin
  if ComboBoxTipoVenda.ItemIndex = 1 then
  begin
    if EditIdVendedor.Value <> 0 then
    begin
      try
        Filtro := 'ID = ' + EditIdVendedor.Text;
        EditIdVendedor.Clear;
        EditVendedor.Clear;

        VendedorVO := TVendedorController.ConsultaObjeto(Filtro);
        if Assigned(VendedorVO) then
        begin
          EditIdVendedor.Text := CDSTransiente.FieldByName('ID').AsString;
          //EditVendedor.Text := CDSTransiente.FieldByName('COLABORADORPESSOA.NOME').AsString;
          EditTaxaComissao.Value := CDSTransiente.FieldByName('COMISSAO').AsFloat;
        end
        else
        begin
          Exit;
          EditIdVendedor.SetFocus;
        end;
      finally
      end;
    end
    else
    begin
      EditVendedor.Clear;
    end;
  end;
end;

procedure TFVenda.EditIdVendedorKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if ComboBoxTipoVenda.ItemIndex = 1 then
  begin
    if Key = VK_F1 then
    begin
      EditIdVendedor.Value := -1;
      EditIdCliente.SetFocus;
    end;
  end;
end;

procedure TFVenda.EditIdVendedorKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
  begin
    Key := #0;
    EditIdCliente.SetFocus;
  end;
end;

// Cliente
procedure TFVenda.EditIdClienteExit(Sender: TObject);
var
  ViewPessoaClienteVO :TViewPessoaClienteVO ;
begin
  if ComboBoxTipoVenda.ItemIndex = 1 then
  begin
    if EditIdCliente.Value <> 0 then
    begin
      try
        Filtro := 'ID = ' + EditIdCliente.Text;
        EditIdCliente.Clear;
        EditCliente.Clear;

        ViewPessoaClienteVO := TViewPessoaClienteController.ConsultaObjeto(Filtro);
        if Assigned(ViewPessoaClienteVO) then
        begin
          EditIdCliente.Text := CDSTransiente.FieldByName('ID').AsString;
          EditCliente.Text := CDSTransiente.FieldByName('NOME').AsString;
          LimiteCredito := CDSTransiente.FieldByName('LIMITE_CREDITO').AsFloat;
        end
        else
        begin
          Exit;
          EditIdCliente.SetFocus;
        end;
      finally
      end;
    end
    else
    begin
      EditCliente.Clear;
    end;
  end;
end;

procedure TFVenda.EditIdClienteKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if ComboBoxTipoVenda.ItemIndex = 1 then
  begin
    if Key = VK_F1 then
    begin
      EditIdCliente.Value := -1;
      EditIdCondicoesPagamento.SetFocus;
    end;
  end;
end;

procedure TFVenda.EditIdClienteKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
  begin
    Key := #0;
    EditIdCondicoesPagamento.SetFocus;
  end;
end;

// Condicoes Pagamentos
procedure TFVenda.EditIdCondicoesPagamentoExit(Sender: TObject);
var
  VendaCondicoesPagamentoVO :TVendaCondicoesPagamentoVO ;
begin
  if ComboBoxTipoVenda.ItemIndex = 1 then
  begin
    if EditIdCondicoesPagamento.Value <> 0 then
    begin
      try
        Filtro := 'ID = ' + EditIdCondicoesPagamento.Text;
        EditIdCondicoesPagamento.Clear;
        EditCondicoesPagamento.Clear;

        VendaCondicoesPagamentoVO := TVendaCondicoesPagamentoController.ConsultaObjeto(Filtro);
        if Assigned(VendaCondicoesPagamentoVO) then
        begin
          EditIdCondicoesPagamento.Text := CDSTransiente.FieldByName('ID').AsString;
          EditCondicoesPagamento.Text := CDSTransiente.FieldByName('NOME').AsString;
          VistaPrazo := CDSTransiente.FieldByName('VISTA_PRAZO').AsString
        end
        else
        begin
          Exit;
          EditIdCondicoesPagamento.SetFocus;
        end;
      finally
      end;
    end
    else
    begin
      EditCondicoesPagamento.Clear;
    end;
  end;
end;

procedure TFVenda.EditIdCondicoesPagamentoKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = VK_F1 then
  begin
    EditIdCondicoesPagamento.Value := -1;
    EditIdTransportadora.SetFocus;
  end;
end;

procedure TFVenda.EditIdCondicoesPagamentoKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
  begin
    Key := #0;
    EditIdTransportadora.SetFocus;
  end;
end;

// Transportadora
procedure TFVenda.EditIdTransportadoraExit(Sender: TObject);
var
  ViewPessoaTransportadoraVO :TViewPessoaTransportadoraVO ;
begin
  if ComboBoxTipoVenda.ItemIndex = 1 then
  begin
    if EditIdTransportadora.Value <> 0 then
    begin
      try
        Filtro := 'ID = ' + EditIdTransportadora.Text;
        EditIdTransportadora.Clear;
        EditTransportadora.Clear;

        ViewPessoaTransportadoraVO := TViewPessoaTransportadoraController.ConsultaObjeto(Filtro);
        if Assigned(ViewPessoaTransportadoraVO) then
        begin
          EditIdTransportadora.Text := CDSTransiente.FieldByName('ID').AsString;
          EditTransportadora.Text := CDSTransiente.FieldByName('NOME').AsString;
        end
        else
        begin
          Exit;
          EditIdTransportadora.SetFocus;
        end;
      finally
      end;
    end
    else
    begin
      EditTransportadora.Clear;
    end;
  end;
end;

procedure TFVenda.EditIdTransportadoraKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = VK_F1 then
  begin
    EditIdTransportadora.Value := -1;
    ComboBoxTipoFrete.SetFocus;
  end;
end;

procedure TFVenda.EditIdTransportadoraKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
  begin
    Key := #0;
    ComboBoxTipoFrete.SetFocus;
  end;
end;
{$ENDREGION}

{$REGION 'Actions'}
procedure TFVenda.HabilitarEditVendaOrcamento;
begin
  if ComboBoxTipoVenda.ItemIndex = 0 then
  // Se orçamento desabilita edits
  begin
    EditIdOrcamentoVendaCabecalho.ReadOnly := False;
    EditIdVendedor.ReadOnly := True;
    EditIdCliente.ReadOnly := True;
    EditIdCondicoesPagamento.ReadOnly := True;
    EditIdTransportadora.ReadOnly := True;
  end
  else
  // Se venda direta habilita Edits.
  begin
    EditIdOrcamentoVendaCabecalho.Clear;
    EditIdVendedor.Clear;
    EditIdCliente.Clear;
    EditIdCondicoesPagamento.Clear;
    EditIdTransportadora.Clear;
    EditOrcamentoVendaCabecalho.Clear;
    EditVendedor.Clear;
    EditCliente.Clear;
    EditCondicoesPagamento.Clear;
    EditTransportadora.Clear;
    EditIdOrcamentoVendaCabecalho.ReadOnly := True;
    EditIdVendedor.ReadOnly := False;
    EditIdCliente.ReadOnly := False;
    EditIdCondicoesPagamento.ReadOnly := False;
    EditIdTransportadora.ReadOnly := False;
  end;
end;

procedure TFVenda.ActionAdicionarProdutoExecute(Sender: TObject);
begin
  (*

  /// EXERCICIO: use a janela FLookup
  try
    if Assigned(ViewPessoaTransportadoraVO) then
    begin
      CDSVendaDetalhe.Append;
      CDSVendaDetalhe.FieldByName('ID_PRODUTO').AsInteger := CDSTransiente.FieldByName('ID').AsInteger;
      CDSVendaDetalhe.FieldByName('ProdutoNome').AsString := CDSTransiente.FieldByName('NOME').AsString;
      CDSVendaDetalhe.FieldByName('VALOR_UNITARIO').AsFloat := CDSTransiente.FieldByName('VALOR_VENDA').AsFloat;
    end;
  finally
  end;
  *)
end;

procedure TFVenda.ActionAtualizarTotaisExecute(Sender: TObject);
var
  SubTotal, TotalDesconto: Extended;
begin
  SubTotal := 0;
  TotalDesconto := 0;
  //
  CDSVendaDetalhe.DisableControls;
  CDSVendaDetalhe.First;
  while not CDSVendaDetalhe.Eof do
  begin
    SubTotal := SubTotal + CDSVendaDetalhe.FieldByName('VALOR_SUBTOTAL').AsFloat;
    TotalDesconto := TotalDesconto + CDSVendaDetalhe.FieldByName('VALOR_DESCONTO').AsFloat;

    CDSVendaDetalhe.Next;
  end;
  CDSVendaDetalhe.First;
  CDSVendaDetalhe.EnableControls;
  //
  EditValorSubtotal.Value := SubTotal;
  if TotalDesconto > 0 then
  begin
    EditValorDesconto.Value := TotalDesconto;
    EditTaxaDesconto.Value := TotalDesconto / SubTotal * 100;
  end;
  if ComboBoxTipoFrete.ItemIndex = 0 then
    EditValorTotal.Value := SubTotal - EditValorDesconto.Value //CIF
  else
    EditValorTotal.Value := SubTotal + EditValorFrete.Value + EditValorSeguro.Value - EditValorDesconto.Value; //FOB
  EditValorComissao.Value := SubTotal - EditValorDesconto.Value * EditTaxaComissao.Value / 100;
end;

procedure TFVenda.ActionExcluirItemExecute(Sender: TObject);
begin
  if Application.MessageBox('Tem certeza que deseja remover o item da venda?', 'Pergunta do Sistema', MB_YesNo + MB_IconQuestion) = IdYes then
  begin
    if StatusTela = stInserindo then
      CDSVendaDetalhe.Delete
    else if StatusTela = stEditando then
    begin
      if TVendaDetalheController.Exclui(CDSVendaDetalhe.FieldByName('ID').AsInteger) then
        CDSVendaDetalhe.Delete;
    end;
  end;
end;

{$ENDREGION}


/// EXERCICIO
/// INTEGRAÇÃO NF-E
///  Faça a integração com o sistema NF-e
///  OBS: lembre que o NF-e já integra com o Financeiro
///
/// DEVOLUÇÃO
///  A devolução deve ser feita no sistema NF-e informando a natureza da operação devida.
///  Nesse momento deve-se alterar a situação da venda para Devolução e estornar os lançamentos do financeiro.
end.

