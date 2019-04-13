{ *******************************************************************************
Title: T2Ti ERP
Description: Janela de Orçamento / Pedido de Venda

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
unit UOrcamentoPedidoVenda;

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

  { TFOrcamentoPedidoVenda }

  TFOrcamentoPedidoVenda = class(TFTelaCadastro)
    CDSOrcamentoPedidoVendaDet: TBufDataset;
    DSOrcamentoPedidoVendaDet: TDataSource;
    GroupBoxParcelas: TGroupBox;
    GridParcelas: TRxDbGrid;
    ScrollBox1: TScrollBox;
    BevelEdits: TBevel;
    EditCodigo: TLabeledEdit;
    MemoObservacao: TLabeledMemo;
    EditValorSubtotal: TLabeledCalcEdit;
    EditValorFrete: TLabeledCalcEdit;
    EditValorComissao: TLabeledCalcEdit;
    EditTaxaComissao: TLabeledCalcEdit;
    Panel1: TPanel;
    EditVendedor: TLabeledEdit;
    EditCliente: TLabeledEdit;
    EditCondicoesPagamento: TLabeledEdit;
    EditTransportadora: TLabeledEdit;
    ComboBoxTipoOrcamento: TLabeledComboBox;
    ComboBoxTipoFrete: TLabeledComboBox;
    EditDataCadastro: TLabeledDateEdit;
    EditDataEntrega: TLabeledDateEdit;
    EditDataValidade: TLabeledDateEdit;
    EditValorDesconto: TLabeledCalcEdit;
    EditTaxaDesconto: TLabeledCalcEdit;
    EditValorTotal: TLabeledCalcEdit;
    EditIdVendedor: TLabeledCalcEdit;
    EditIdCliente: TLabeledCalcEdit;
    EditIdCondicoesPagamento: TLabeledCalcEdit;
    EditIdTransportadora: TLabeledCalcEdit;
    ActionManager1: TActionList;
    ActionAtualizarTotais: TAction;
    ActionToolBar1: TToolPanel;
    ActionAdicionarProduto: TAction;
    procedure FormCreate(Sender: TObject);
    procedure EditIdVendedorKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure EditIdClienteKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure EditIdCondicoesPagamentoKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure EditIdCondicoesPagamentoExit(Sender: TObject);
    procedure EditTaxaDescontoExit(Sender: TObject);
    procedure EditIdVendedorExit(Sender: TObject);
    procedure EditIdClienteExit(Sender: TObject);
    procedure EditIdTransportadoraExit(Sender: TObject);
    procedure EditIdTransportadoraKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure EditIdVendedorKeyPress(Sender: TObject; var Key: Char);
    procedure EditIdClienteKeyPress(Sender: TObject; var Key: Char);
    procedure EditIdCondicoesPagamentoKeyPress(Sender: TObject; var Key: Char);
    procedure EditIdTransportadoraKeyPress(Sender: TObject; var Key: Char);
    procedure GridParcelasKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure ActionAtualizarTotaisExecute(Sender: TObject);
    procedure CDSOrcamentoPedidoVendaDetBeforePost(DataSet: TDataSet);
    procedure ActionAdicionarProdutoExecute(Sender: TObject);
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
  end;

var
  FOrcamentoPedidoVenda: TFOrcamentoPedidoVenda;

implementation

uses VendaOrcamentoCabecalhoController, VendaOrcamentoCabecalhoVO,
  VendaOrcamentoDetalheVO,  VendedorController, VendaCondicoesPagamentoController,
  ViewPessoaClienteVO, ViewPessoaClienteController, ViewPessoaTransportadoraVO,
  ViewPessoaTransportadoraController, PessoaVO, VendedorVO, VendaCondicoesPagamentoVO,
  ColaboradorVO, ProdutoVO, ProdutoController, UDataModule;
{$R *.lfm}

{$REGION 'Infra'}
procedure TFOrcamentoPedidoVenda.BotaoConsultarClick(Sender: TObject);
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
    RetornoConsulta := TVendaOrcamentoCabecalhoController.Consulta(Filtro, IntToStr(Pagina));
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

procedure TFOrcamentoPedidoVenda.BotaoSalvarClick(Sender: TObject);
begin
  inherited;
  BotaoConsultarClick(Sender);
end;

procedure TFOrcamentoPedidoVenda.FormCreate(Sender: TObject);
begin
  ClasseObjetoGridVO := TVendaOrcamentoCabecalhoVO;
  ObjetoController := TVendaOrcamentoCabecalhoController.Create;

  inherited;

  ConfiguraCDSFromVO(CDSOrcamentoPedidoVendaDet, TVendaOrcamentoDetalheVO);

  BotaoImprimir.Visible := False;
  MenuImprimir.Visible := False;
end;

procedure TFOrcamentoPedidoVenda.LimparCampos;
begin
  inherited;
  CDSOrcamentoPedidoVendaDet.Close;
  CDSOrcamentoPedidoVendaDet.Open;
end;

procedure TFOrcamentoPedidoVenda.EditTaxaDescontoExit(Sender: TObject);
begin
  EditValorDesconto.Value := EditValorSubtotal.Value * (EditTaxaDesconto.Value / 100);
  EditValorTotal.Value := EditValorSubtotal.Value - EditValorDesconto.Value;
end;
{$ENDREGION}

{$REGION 'Controles CRUD'}
function TFOrcamentoPedidoVenda.DoInserir: Boolean;
begin
  Result := inherited DoInserir;

  if Result then
  begin
    EditIdVendedor.SetFocus;
  end;
end;

function TFOrcamentoPedidoVenda.DoEditar: Boolean;
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
    EditIdVendedor.SetFocus;
  end;
end;

function TFOrcamentoPedidoVenda.DoExcluir: Boolean;
begin
  if inherited DoExcluir then
  begin
    try
      Result := TVendaOrcamentoCabecalhoController.Exclui(IdRegistroSelecionado);
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

function TFOrcamentoPedidoVenda.DoSalvar: Boolean;
var
  OrcamentoPedidoVendaDet: TVendaOrcamentoDetalheVO;
begin
  Result := inherited DoSalvar;

  if Result then
  begin
    try
      if not Assigned(ObjetoVO) then
        ObjetoVO := TVendaOrcamentoCabecalhoVO.Create;

      ActionAtualizarTotais.Execute;

      TVendaOrcamentoCabecalhoVO(ObjetoVO).IdVendedor := EditIdVendedor.AsInteger;
      TVendaOrcamentoCabecalhoVO(ObjetoVO).VendedorNome := EditVendedor.Text;
      TVendaOrcamentoCabecalhoVO(ObjetoVO).IdTransportadora := EditIdTransportadora.AsInteger;
      TVendaOrcamentoCabecalhoVO(ObjetoVO).TransportadoraNome := EditTransportadora.Text;
      TVendaOrcamentoCabecalhoVO(ObjetoVO).IdCliente := EditIdCliente.AsInteger;
      TVendaOrcamentoCabecalhoVO(ObjetoVO).ClienteNome := EditCliente.Text;
      TVendaOrcamentoCabecalhoVO(ObjetoVO).IdVendaCondicoesPagamento := EditIdCondicoesPagamento.AsInteger;
      TVendaOrcamentoCabecalhoVO(ObjetoVO).VendaCondicoesPagamentoNome := EditCondicoesPagamento.Text;
      TVendaOrcamentoCabecalhoVO(ObjetoVO).Tipo := IfThen(ComboBoxTipoOrcamento.ItemIndex = 0, 'O', 'P');
      TVendaOrcamentoCabecalhoVO(ObjetoVO).Codigo := EditCodigo.Text;
      TVendaOrcamentoCabecalhoVO(ObjetoVO).DataCadastro := EditDataCadastro.Date;
      TVendaOrcamentoCabecalhoVO(ObjetoVO).DataEntrega := EditDataEntrega.Date;
      TVendaOrcamentoCabecalhoVO(ObjetoVO).Validade := EditDataValidade.Date;
      TVendaOrcamentoCabecalhoVO(ObjetoVO).TipoFrete := IfThen(ComboBoxTipoFrete.ItemIndex = 0, 'C', 'F');
      TVendaOrcamentoCabecalhoVO(ObjetoVO).ValorSubtotal := EditValorSubtotal.Value;
      TVendaOrcamentoCabecalhoVO(ObjetoVO).ValorFrete := EditValorFrete.Value;
      TVendaOrcamentoCabecalhoVO(ObjetoVO).TaxaComissao := EditTaxaComissao.Value;
      TVendaOrcamentoCabecalhoVO(ObjetoVO).ValorComissao := EditValorComissao.Value;
      TVendaOrcamentoCabecalhoVO(ObjetoVO).TaxaDesconto := EditTaxaDesconto.Value;
      TVendaOrcamentoCabecalhoVO(ObjetoVO).ValorDesconto := EditValorDesconto.Value;
      TVendaOrcamentoCabecalhoVO(ObjetoVO).ValorTotal := EditValorTotal.Value;
      TVendaOrcamentoCabecalhoVO(ObjetoVO).Observacao := MemoObservacao.Text;
      TVendaOrcamentoCabecalhoVO(ObjetoVO).Situacao := 'D';

      if StatusTela = stEditando then
        TVendaOrcamentoCabecalhoVO(ObjetoVO).Id := IdRegistroSelecionado;

      // Itens do orçamento
      CDSOrcamentoPedidoVendaDet.DisableControls;
      CDSOrcamentoPedidoVendaDet.First;
      while not CDSOrcamentoPedidoVendaDet.Eof do
      begin
          OrcamentoPedidoVendaDet := TVendaOrcamentoDetalheVO.Create;
          OrcamentoPedidoVendaDet.Id := CDSOrcamentoPedidoVendaDet.FieldByName('ID').AsInteger;
          OrcamentoPedidoVendaDet.IdVendaOrcamentoCabecalho := TVendaOrcamentoCabecalhoVO(ObjetoVO).Id;
          OrcamentoPedidoVendaDet.IdProduto := CDSOrcamentoPedidoVendaDet.FieldByName('ID_PRODUTO').AsInteger;
          OrcamentoPedidoVendaDet.Quantidade := CDSOrcamentoPedidoVendaDet.FieldByName('QUANTIDADE').AsFloat;
          OrcamentoPedidoVendaDet.ValorUnitario := CDSOrcamentoPedidoVendaDet.FieldByName('VALOR_UNITARIO').AsFloat;
          OrcamentoPedidoVendaDet.ValorSubtotal := CDSOrcamentoPedidoVendaDet.FieldByName('VALOR_SUBTOTAL').AsFloat;
          OrcamentoPedidoVendaDet.TaxaDesconto := CDSOrcamentoPedidoVendaDet.FieldByName('TAXA_DESCONTO').AsFloat;
          OrcamentoPedidoVendaDet.ValorDesconto := CDSOrcamentoPedidoVendaDet.FieldByName('VALOR_DESCONTO').AsFloat;
          OrcamentoPedidoVendaDet.ValorTotal := CDSOrcamentoPedidoVendaDet.FieldByName('VALOR_TOTAL').AsFloat;
          TVendaOrcamentoCabecalhoVO(ObjetoVO).ListaVendaOrcamentoDetalheVO.Add(OrcamentoPedidoVendaDet);

        CDSOrcamentoPedidoVendaDet.Next;
      end;
      CDSOrcamentoPedidoVendaDet.EnableControls;

      if StatusTela = stInserindo then
      begin
        TVendaOrcamentoCabecalhoController.Insere(TVendaOrcamentoCabecalhoVO(ObjetoVO));
      end
      else if StatusTela = stEditando then
      begin
        /// EXERCICIO: Verifique se tem como serializar as listas junto com o objeto para realizar a comparação
        //if TVendaOrcamentoCabecalhoVO(ObjetoVO).ToJSONString <> StringObjetoOld then
        //begin
          TVendaOrcamentoCabecalhoController.Altera(TVendaOrcamentoCabecalhoVO(ObjetoVO));
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

{$REGION 'Controle de Grid'}
procedure TFOrcamentoPedidoVenda.GridParaEdits;
var
  IdCabecalho: String;
  Current: TVendaOrcamentoDetalheVO;
  I: Integer;
begin
  inherited;

  if not CDSGrid.IsEmpty then
  begin
    IdCabecalho := IntToStr(IdRegistroSelecionado);
    ObjetoVO := TVendaOrcamentoCabecalhoController.ConsultaObjeto('ID=' + IdCabecalho);
  end;

  if Assigned(ObjetoVO) then
  begin
    EditIdVendedor.AsInteger := TVendaOrcamentoCabecalhoVO(ObjetoVO).IdVendedor;
    EditVendedor.Text := TVendaOrcamentoCabecalhoVO(ObjetoVO).VendedorVO.ColaboradorVO.PessoaVO.Nome;
    EditIdTransportadora.AsInteger := TVendaOrcamentoCabecalhoVO(ObjetoVO).IdTransportadora;
    EditTransportadora.Text := TVendaOrcamentoCabecalhoVO(ObjetoVO).TransportadoraVO.Nome;
    EditIdCliente.AsInteger := TVendaOrcamentoCabecalhoVO(ObjetoVO).IdCliente;
    EditCliente.Text := TVendaOrcamentoCabecalhoVO(ObjetoVO).ClienteVO.Nome;
    EditIdCondicoesPagamento.AsInteger := TVendaOrcamentoCabecalhoVO(ObjetoVO).IdVendaCondicoesPagamento;
    EditCondicoesPagamento.Text := TVendaOrcamentoCabecalhoVO(ObjetoVO).VendaCondicoesPagamentoVO.Nome;

    ComboBoxTipoOrcamento.ItemIndex := AnsiIndexStr(TVendaOrcamentoCabecalhoVO(ObjetoVO).Tipo, ['O', 'P']);

    EditCodigo.Text := TVendaOrcamentoCabecalhoVO(ObjetoVO).Codigo;
    EditDataCadastro.Date := TVendaOrcamentoCabecalhoVO(ObjetoVO).DataCadastro;
    EditDataEntrega.Date := TVendaOrcamentoCabecalhoVO(ObjetoVO).DataEntrega;
    EditDataValidade.Date := TVendaOrcamentoCabecalhoVO(ObjetoVO).Validade;

    ComboBoxTipoFrete.ItemIndex := AnsiIndexStr(TVendaOrcamentoCabecalhoVO(ObjetoVO).TipoFrete, ['C', 'F']);

    EditValorSubtotal.Value := TVendaOrcamentoCabecalhoVO(ObjetoVO).ValorSubtotal;
    EditValorFrete.Value := TVendaOrcamentoCabecalhoVO(ObjetoVO).ValorFrete;
    EditTaxaComissao.Value := TVendaOrcamentoCabecalhoVO(ObjetoVO).TaxaComissao;
    EditValorComissao.Value := TVendaOrcamentoCabecalhoVO(ObjetoVO).ValorComissao;
    EditTaxaDesconto.Value := TVendaOrcamentoCabecalhoVO(ObjetoVO).TaxaDesconto;
    EditValorDesconto.Value := TVendaOrcamentoCabecalhoVO(ObjetoVO).ValorDesconto;
    EditValorTotal.Value := TVendaOrcamentoCabecalhoVO(ObjetoVO).ValorTotal;
    MemoObservacao.Text := TVendaOrcamentoCabecalhoVO(ObjetoVO).Observacao;

    // Itens do orçamento
    for I := 0 to TVendaOrcamentoCabecalhoVO(ObjetoVO).ListaVendaOrcamentoDetalheVO.Count - 1 do
    begin
      Current := TVendaOrcamentoCabecalhoVO(ObjetoVO).ListaVendaOrcamentoDetalheVO[I];

      CDSOrcamentoPedidoVendaDet.Append;

      CDSOrcamentoPedidoVendaDet.FieldByName('ID').AsInteger := Current.Id;
      CDSOrcamentoPedidoVendaDet.FieldByName('ID_VENDA_ORCAMENTO_CABECALHO').AsInteger := Current.IdVendaOrcamentoCabecalho;
      CDSOrcamentoPedidoVendaDet.FieldByName('ID_PRODUTO').AsInteger := Current.IdProduto;
      //CDSOrcamentoPedidoVendaDetProdutoNome.AsString := Current.ProdutoVO.Nome;
      CDSOrcamentoPedidoVendaDet.FieldByName('QUANTIDADE').AsFloat := Current.Quantidade;
      CDSOrcamentoPedidoVendaDet.FieldByName('VALOR_UNITARIO').AsFloat := Current.ValorUnitario;
      CDSOrcamentoPedidoVendaDet.FieldByName('VALOR_SUBTOTAL').AsFloat := Current.ValorSubtotal;
      CDSOrcamentoPedidoVendaDet.FieldByName('TAXA_DESCONTO').AsFloat := Current.TaxaDesconto;
      CDSOrcamentoPedidoVendaDet.FieldByName('VALOR_DESCONTO').AsFloat := Current.ValorDesconto;
      CDSOrcamentoPedidoVendaDet.FieldByName('VALOR_TOTAL').AsFloat := Current.ValorTotal;

      CDSOrcamentoPedidoVendaDet.Post;
    end;

    // Serializa o objeto para consultar posteriormente se houve alterações
    FormatSettings.DecimalSeparator := '.';
    StringObjetoOld := ObjetoVO.ToJSONString;
    FormatSettings.DecimalSeparator := ',';
  end;
end;

procedure TFOrcamentoPedidoVenda.GridParcelasKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  Filtro: String;
begin
  if Key = VK_F1 then
  begin
    ActionAdicionarProduto.Execute;
  end;
  If Key = VK_RETURN then
    EditIdVendedor.SetFocus;
end;

procedure TFOrcamentoPedidoVenda.CDSOrcamentoPedidoVendaDetBeforePost(DataSet: TDataSet);
begin
  CDSOrcamentoPedidoVendaDet.FieldByName('VALOR_SUBTOTAL').AsFloat := CDSOrcamentoPedidoVendaDet.FieldByName('QUANTIDADE').AsFloat * CDSOrcamentoPedidoVendaDet.FieldByName('VALOR_UNITARIO').AsFloat;
  CDSOrcamentoPedidoVendaDet.FieldByName('VALOR_DESCONTO').AsFloat := CDSOrcamentoPedidoVendaDet.FieldByName('VALOR_SUBTOTAL').AsFloat * (CDSOrcamentoPedidoVendaDet.FieldByName('TAXA_DESCONTO').AsFloat / 100);
  CDSOrcamentoPedidoVendaDet.FieldByName('VALOR_TOTAL').AsFloat := CDSOrcamentoPedidoVendaDet.FieldByName('VALOR_SUBTOTAL').AsFloat - CDSOrcamentoPedidoVendaDet.FieldByName('VALOR_DESCONTO').AsFloat;
end;
{$ENDREGION}

{$REGION 'Campos Transientes'}

/// EXERCICIO: Adapte para forma de pesquisa usando o evento OnKeyUP e use a janela FLookup

// Vendedor
procedure TFOrcamentoPedidoVenda.EditIdVendedorExit(Sender: TObject);
var
  Filtro: String;
  VendedorVO :TVendedorVO ;
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

procedure TFOrcamentoPedidoVenda.EditIdVendedorKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = VK_F1 then
  begin
    EditIdVendedor.Value := -1;
    EditIdCliente.SetFocus;
  end;
end;

procedure TFOrcamentoPedidoVenda.EditIdVendedorKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
  begin
    Key := #0;
    EditIdCliente.SetFocus;
  end;
end;

// Cliente
procedure TFOrcamentoPedidoVenda.EditIdClienteExit(Sender: TObject);
var
  Filtro: String;
  ViewPessoaClienteVO :TViewPessoaClienteVO ;
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

procedure TFOrcamentoPedidoVenda.EditIdClienteKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = VK_F1 then
  begin
    EditIdCliente.Value := -1;
    EditIdCondicoesPagamento.SetFocus;
  end;
end;

procedure TFOrcamentoPedidoVenda.EditIdClienteKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
  begin
    Key := #0;
    EditIdCondicoesPagamento.SetFocus;
  end;
end;

// Condicoes Pagamentos
procedure TFOrcamentoPedidoVenda.EditIdCondicoesPagamentoExit(Sender: TObject);
var
  Filtro: String;
  VendaCondicoesPagamentoVO :TVendaCondicoesPagamentoVO ;
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

procedure TFOrcamentoPedidoVenda.EditIdCondicoesPagamentoKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = VK_F1 then
  begin
    EditIdCondicoesPagamento.Value := -1;
    EditIdTransportadora.SetFocus;
  end;
end;

procedure TFOrcamentoPedidoVenda.EditIdCondicoesPagamentoKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
  begin
    Key := #0;
    EditIdTransportadora.SetFocus;
  end;
end;

// Transportadora
procedure TFOrcamentoPedidoVenda.EditIdTransportadoraExit(Sender: TObject);
var
  Filtro: String;
  ViewPessoaTransportadoraVO :TViewPessoaTransportadoraVO ;
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

procedure TFOrcamentoPedidoVenda.EditIdTransportadoraKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = VK_F1 then
  begin
    EditIdTransportadora.Value := -1;
    ComboBoxTipoOrcamento.SetFocus;
  end;
end;

procedure TFOrcamentoPedidoVenda.EditIdTransportadoraKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
  begin
    Key := #0;
    ComboBoxTipoOrcamento.SetFocus;
  end;
end;
{$ENDREGION}

{$REGION 'Actions'}
procedure TFOrcamentoPedidoVenda.ActionAdicionarProdutoExecute(Sender: TObject);
begin
  (*

  /// EXERCICIO: use a janela FLookup
  try
    if Assigned(ViewPessoaTransportadoraVO) then
    begin
      CDSOrcamentoPedidoVendaDet.Append;
      CDSOrcamentoPedidoVendaDet.FieldByName('ID_PRODUTO').AsInteger := CDSTransiente.FieldByName('ID').AsInteger;
      CDSOrcamentoPedidoVendaDet.FieldByName('PRODUTONOME').AsString := CDSTransiente.FieldByName('NOME').AsString;
      CDSOrcamentoPedidoVendaDet.FieldByName('VALOR_UNITARIO').AsFloat := CDSTransiente.FieldByName('VALOR_VENDA').AsFloat;
    end;
  finally
  end;
  *)
end;

procedure TFOrcamentoPedidoVenda.ActionAtualizarTotaisExecute(Sender: TObject);
var
  SubTotal, TotalDesconto: Extended;
begin
  SubTotal := 0;
  TotalDesconto := 0;
  //
  CDSOrcamentoPedidoVendaDet.DisableControls;
  CDSOrcamentoPedidoVendaDet.First;
  while not CDSOrcamentoPedidoVendaDet.Eof do
  begin
    SubTotal := SubTotal + CDSOrcamentoPedidoVendaDet.FieldByName('VALOR_SUBTOTAL').AsFloat;
    TotalDesconto := TotalDesconto + CDSOrcamentoPedidoVendaDet.FieldByName('VALOR_DESCONTO').AsFloat;

    CDSOrcamentoPedidoVendaDet.Next;
  end;
  CDSOrcamentoPedidoVendaDet.First;
  CDSOrcamentoPedidoVendaDet.EnableControls;
  //
  EditValorSubtotal.Value := SubTotal;
  if TotalDesconto > 0 then
  begin
    EditValorDesconto.Value := TotalDesconto;
    EditTaxaDesconto.Value := TotalDesconto / SubTotal * 100;
  end;
  EditValorTotal.Value := SubTotal + EditValorFrete.Value - EditValorDesconto.Value;
  EditValorComissao.Value := SubTotal - EditValorDesconto.Value * EditTaxaComissao.Value / 100;
end;
{$ENDREGION}

end.

