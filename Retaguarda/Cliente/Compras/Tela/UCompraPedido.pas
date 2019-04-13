{ *******************************************************************************
Title: T2Ti ERP
Description: Janela de CompraPedidos

The MIT License

Copyright: Copyright (C) 2010 T2Ti.COM

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
unit UCompraPedido;

{$MODE Delphi}

interface

uses
  BrookHTTPClient, BrookFCLHTTPClientBroker, BrookHTTPUtils, BrookUtils, FPJson, ZDataset,
  LCLIntf, LCLType, LMessages, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UTelaCadastro, Menus, StdCtrls, ExtCtrls, Buttons, Grids, DBGrids,
  ComCtrls, LabeledCtrls, rxdbgrid, rxtoolbar, DBCtrls, StrUtils,
  Math, Constantes, CheckLst, ActnList, ToolWin, db, BufDataset, Biblioteca,
  ULookup, VO, AdmParametroVO;

type

  { TFCompraPedido }

  TFCompraPedido = class(TFTelaCadastro)
    CDSCompraPedidoDetalhe: TBufDataset;
    DSCompraPedidoDetalhe: TDataSource;
    GroupBoxItensPedido: TGroupBox;
    GridCompraPedidoDetalhe: TRxDbGrid;
    BevelEdits: TBevel;
    EditLocalEntrega: TLabeledEdit;
    EditValorSubtotal: TLabeledCalcEdit;
    EditValorFrete: TLabeledCalcEdit;
    EditValorIcmsSt: TLabeledCalcEdit;
    EditValorICMS: TLabeledCalcEdit;
    EditFornecedor: TLabeledEdit;
    ComboBoxTipoFrete: TLabeledComboBox;
    EditDataPedido: TLabeledDateEdit;
    EditDataPrevistaEntrega: TLabeledDateEdit;
    EditValorDesconto: TLabeledCalcEdit;
    EditTaxaDesconto: TLabeledCalcEdit;
    EditValorTotalPedido: TLabeledCalcEdit;
    EditIdFornecedor: TLabeledCalcEdit;
    EditIdCompraTipoPedido: TLabeledCalcEdit;
    EditCompraTipoPedido: TLabeledEdit;
    EditQuantidadeParcelas: TLabeledCalcEdit;
    EditLocalCobranca: TLabeledEdit;
    ComboBoxFormaPagamento: TLabeledComboBox;
    EditDataPrevisaoPagamento: TLabeledDateEdit;
    EditContato: TLabeledEdit;
    EditBaseCalculoIcmsSt: TLabeledCalcEdit;
    EditValorSeguro: TLabeledCalcEdit;
    EditValorOutrasDespesas: TLabeledCalcEdit;
    EditValorIPI: TLabeledCalcEdit;
    EditBaseCalculoICMS: TLabeledCalcEdit;
    EditValorTotalProdutos: TLabeledCalcEdit;
    EditValorTotalNF: TLabeledCalcEdit;
    EditDiasPrimeiroVencimento: TLabeledCalcEdit;
    EditDiasIntervalo: TLabeledCalcEdit;
    ActionManager1: TActionList;
    ActionAtualizarValores: TAction;
    ActionToolBar1: TToolPanel;
    procedure FormCreate(Sender: TObject);
    procedure CDSCompraPedidoDetalheBeforePost(DataSet: TDataSet);
    procedure GridCompraPedidoDetalheKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure ActionAtualizarValoresExecute(Sender: TObject);
    procedure EditIdFornecedorKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure EditIdCompraTipoPedidoKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure BotaoConsultarClick(Sender: TObject);
    procedure BotaoSalvarClick(Sender: TObject);
  private
    { Private declarations }
    procedure AtualizaTotaisItens(pEditarValores: Boolean);
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
  FCompraPedido: TFCompraPedido;
  AdmParametroVO: TAdmParametroVO;

implementation

uses UDataModule,
    CompraPedidoVO, CompraPedidoDetalheVO, CompraTipoPedidoVO, ProdutoVO,
    CompraTipoPedidoController, ProdutoController, CompraPedidoController,
    FinLancamentoPagarVO, FinParcelaPagarVO, FinLancamentoPagarController,
    AdmParametroController, ViewPessoaFornecedorVO, ViewPessoaFornecedorController;
{$R *.lfm}

{$REGION 'Infra'}
procedure TFCompraPedido.BotaoConsultarClick(Sender: TObject);
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
    RetornoConsulta := TCompraPedidoController.Consulta(Filtro, IntToStr(Pagina));
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

procedure TFCompraPedido.BotaoSalvarClick(Sender: TObject);
begin
  inherited;
  BotaoConsultarClick(Sender);
end;

procedure TFCompraPedido.FormCreate(Sender: TObject);
var
  Filtro: String;
begin
  ClasseObjetoGridVO := TCompraPedidoVO;
  ObjetoController := TCompraPedidoController.Create;

  inherited;

  Filtro := 'ID_EMPRESA = ' + IntToStr(Sessao.Empresa.Id);
  AdmParametroVO := TAdmParametroController.ConsultaObjeto(Filtro);

  ConfiguraCDSFromVO(CDSCompraPedidoDetalhe, TCompraPedidoDetalheVO);
  ConfiguraGridFromVO(GridCompraPedidoDetalhe, TCompraPedidoDetalheVO);
end;

procedure TFCompraPedido.LimparCampos;
begin
  inherited;
  CDSCompraPedidoDetalhe.Close;
  CDSCompraPedidoDetalhe.Open;
end;
{$ENDREGION}

{$REGION 'Controles CRUD'}
function TFCompraPedido.DoInserir: Boolean;
begin
  Result := inherited DoInserir;

  if Result then
  begin
    EditIdFornecedor.SetFocus;
  end;
end;

function TFCompraPedido.DoEditar: Boolean;
begin
  Result := inherited DoEditar;

  if Result then
  begin
    EditIdFornecedor.SetFocus;
    AtualizaTotaisItens(True);
  end;
end;

function TFCompraPedido.DoExcluir: Boolean;
begin
  if inherited DoExcluir then
  begin
    try
      Result := TCompraPedidoController.Exclui(IdRegistroSelecionado);
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

function TFCompraPedido.DoSalvar: Boolean;
var
  CompraPedidoDetalhe: TCompraPedidoDetalheVO;
  LancamentoPagar: TFinLancamentoPagarVO;
  ParcelaPagar: TFinParcelaPagarVO;
  i: Integer;
begin
  Result := inherited DoSalvar;

  if Result then
  begin
    try
      if not Assigned(ObjetoVO) then
        ObjetoVO := TCompraPedidoVO.Create;

      AtualizaTotaisItens(False);

      TCompraPedidoVO(ObjetoVO).IdFornecedor := EditIdFornecedor.AsInteger;
      TCompraPedidoVO(ObjetoVO).FornecedorNome := EditFornecedor.Text;
      TCompraPedidoVO(ObjetoVO).IdCompraTipoPedido := EditIdCompraTipoPedido.AsInteger;
      TCompraPedidoVO(ObjetoVO).CompraTipoPedidoNome := EditCompraTipoPedido.Text;
      TCompraPedidoVO(ObjetoVO).DataPedido := EditDataPedido.Date;
      TCompraPedidoVO(ObjetoVO).DataPrevistaEntrega := EditDataPrevistaEntrega.Date;
      TCompraPedidoVO(ObjetoVO).DataPrevisaoPagamento := EditDataPrevisaoPagamento.Date;
      TCompraPedidoVO(ObjetoVO).LocalEntrega := EditLocalEntrega.Text;
      TCompraPedidoVO(ObjetoVO).LocalCobranca := EditLocalCobranca.Text;
      TCompraPedidoVO(ObjetoVO).Contato := EditContato.Text;
      TCompraPedidoVO(ObjetoVO).ValorSubtotal := EditValorSubtotal.Value;
      TCompraPedidoVO(ObjetoVO).TaxaDesconto := EditTaxaDesconto.Value;
      TCompraPedidoVO(ObjetoVO).ValorDesconto := EditValorDesconto.Value;
      TCompraPedidoVO(ObjetoVO).ValorTotalPedido := EditValorTotalPedido.Value;
      TCompraPedidoVO(ObjetoVO).TipoFrete := IfThen(ComboBoxTipoFrete.ItemIndex = 0, 'C', 'F');
      TCompraPedidoVO(ObjetoVO).FormaPagamento := Copy(ComboBoxFormaPagamento.Text, 1, 1);
      TCompraPedidoVO(ObjetoVO).QuantidadeParcelas := EditQuantidadeParcelas.AsInteger;
      TCompraPedidoVO(ObjetoVO).DiasPrimeiroVencimento := EditDiasPrimeiroVencimento.AsInteger;
      TCompraPedidoVO(ObjetoVO).DiasIntervalo := EditDiasIntervalo.AsInteger;
      TCompraPedidoVO(ObjetoVO).BaseCalculoIcms := EditBaseCalculoICMS.Value;
      TCompraPedidoVO(ObjetoVO).ValorIcms := EditValorICMS.Value;
      TCompraPedidoVO(ObjetoVO).BaseCalculoIcmsSt := EditBaseCalculoIcmsSt.Value;
      TCompraPedidoVO(ObjetoVO).ValorIcmsSt := EditValorIcmsSt.Value;
      TCompraPedidoVO(ObjetoVO).ValorTotalProdutos := EditValorTotalProdutos.Value;
      TCompraPedidoVO(ObjetoVO).ValorFrete := EditValorFrete.Value;
      TCompraPedidoVO(ObjetoVO).ValorSeguro := EditValorSeguro.Value;
      TCompraPedidoVO(ObjetoVO).ValorOutrasDespesas := EditValorOutrasDespesas.Value;
      TCompraPedidoVO(ObjetoVO).ValorIpi := EditValorIPI.Value;
      TCompraPedidoVO(ObjetoVO).ValorTotalNf := EditValorTotalNF.Value;

      if StatusTela = stEditando then
        TCompraPedidoVO(ObjetoVO).Id := IdRegistroSelecionado;

      // Itens do Pedido de Compra
      CDSCompraPedidoDetalhe.DisableControls;
      CDSCompraPedidoDetalhe.First;
      while not CDSCompraPedidoDetalhe.Eof do
      begin
          CompraPedidoDetalhe := TCompraPedidoDetalheVO.Create;
          CompraPedidoDetalhe.Id := CDSCompraPedidoDetalhe.FieldByName('ID').AsInteger;
          CompraPedidoDetalhe.IdCompraPedido := TCompraPedidoVO(ObjetoVO).Id;
          CompraPedidoDetalhe.IdProduto := CDSCompraPedidoDetalhe.FieldByName('ID_PRODUTO').AsInteger;
          //CompraPedidoDetalhe.ProdutoNome := CDSCompraPedidoDetalhe.FieldByName('PRODUTONOME').AsString;
          CompraPedidoDetalhe.Quantidade := CDSCompraPedidoDetalhe.FieldByName('QUANTIDADE').AsFloat;
          CompraPedidoDetalhe.ValorUnitario := CDSCompraPedidoDetalhe.FieldByName('VALOR_UNITARIO').AsFloat;
          CompraPedidoDetalhe.ValorSubtotal := CDSCompraPedidoDetalhe.FieldByName('VALOR_SUBTOTAL').AsFloat;
          CompraPedidoDetalhe.TaxaDesconto := CDSCompraPedidoDetalhe.FieldByName('TAXA_DESCONTO').AsFloat;
          CompraPedidoDetalhe.ValorDesconto := CDSCompraPedidoDetalhe.FieldByName('VALOR_DESCONTO').AsFloat;
          CompraPedidoDetalhe.ValorTotal := CDSCompraPedidoDetalhe.FieldByName('VALOR_TOTAL').AsFloat;
          CompraPedidoDetalhe.CstCsosn := CDSCompraPedidoDetalhe.FieldByName('CST_CSOSN').AsString;
          CompraPedidoDetalhe.Cfop := CDSCompraPedidoDetalhe.FieldByName('CFOP').AsInteger;
          CompraPedidoDetalhe.BaseCalculoIcms := CDSCompraPedidoDetalhe.FieldByName('BASE_CALCULO_ICMS').AsFloat;
          CompraPedidoDetalhe.ValorIcms := CDSCompraPedidoDetalhe.FieldByName('VALOR_ICMS').AsFloat;
          CompraPedidoDetalhe.ValorIpi := CDSCompraPedidoDetalhe.FieldByName('VALOR_IPI').AsFloat;
          CompraPedidoDetalhe.AliquotaIcms := CDSCompraPedidoDetalhe.FieldByName('ALIQUOTA_ICMS').AsFloat;
          CompraPedidoDetalhe.AliquotaIpi := CDSCompraPedidoDetalhe.FieldByName('ALIQUOTA_IPI').AsFloat;
          TCompraPedidoVO(ObjetoVO).ListaCompraPedidoDetalheVO.Add(CompraPedidoDetalhe);
        CDSCompraPedidoDetalhe.Next;
      end;
      CDSCompraPedidoDetalhe.First;
      CDSCompraPedidoDetalhe.EnableControls;

      if StatusTela = stInserindo then
      begin
        TCompraPedidoController.Insere(TCompraPedidoVO(ObjetoVO));
      end
      else if StatusTela = stEditando then
      begin
        /// EXERCICIO: Verifique se tem como serializar as listas junto com o objeto para realizar a comparação
        //if TCompraPedidoVO(ObjetoVO).ToJSONString <> StringObjetoOld then
        //begin
          TCompraPedidoController.Altera(TCompraPedidoVO(ObjetoVO));
        //end
        //else
        //Application.MessageBox('Nenhum dado foi alterado.', 'Mensagem do Sistema', MB_OK + MB_ICONINFORMATION);
      end;

      /// EXERCICIO: IDENTIFICAR SE JA EXISTE UM LANÇAMENTO E AGIR DE ACORDO COM A SUA REALIDADE
      ///  01-APAGAR O LANCAMENTO ANTERIOR E INSERIR O NOVO
      ///  02-ALTERAR O LANCAMENTO ANTERIOR
      ///  03-NAO FAZER NADA, APENAS DEIXAR O LANCAMENTO ANTERIOR
      ///  04-SOLICITAR UMA SOLUCAO PARA O USUÁRIO

      if Application.MessageBox('Deseja gerar os lançamentos para o contas a pagar?', 'Pergunta do Sistema', MB_YesNo + MB_IconQuestion) = IdYes then
      begin
        LancamentoPagar := TFinLancamentoPagarVO.Create;

        LancamentoPagar.IdFornecedor := EditIdFornecedor.AsInteger;
        LancamentoPagar.FornecedorNome := EditFornecedor.Text;
        LancamentoPagar.IdFinDocumentoOrigem := AdmParametroVO.CompraFinDocOrigem;
        LancamentoPagar.PagamentoCompartilhado := 'N';
        LancamentoPagar.QuantidadeParcela := EditQuantidadeParcelas.AsInteger;
        LancamentoPagar.ValorTotal := EditValorTotalNF.Value;
        LancamentoPagar.ValorAPagar := EditValorTotalNF.Value;
        LancamentoPagar.DataLancamento := now;
        LancamentoPagar.NumeroDocumento := 'PEDIDO COMPRA';
        LancamentoPagar.PrimeiroVencimento := now + EditDiasPrimeiroVencimento.AsInteger;
        LancamentoPagar.IntervaloEntreParcelas := EditDiasIntervalo.AsInteger;

        for i := 0 to EditQuantidadeParcelas.AsInteger - 1 do
        begin
          ParcelaPagar := TFinParcelaPagarVO.Create;
          ParcelaPagar.NumeroParcela := i+1;
          ParcelaPagar.IdContaCaixa := AdmParametroVO.CompraContaCaixa;
          ParcelaPagar.IdFinStatusParcela := 1;
          ParcelaPagar.DataEmissao := now;
          ParcelaPagar.DataVencimento := LancamentoPagar.PrimeiroVencimento + (EditDiasIntervalo.AsInteger * i);
          ParcelaPagar.Valor := ArredondaTruncaValor('A', LancamentoPagar.ValorAPagar / EditQuantidadeParcelas.AsInteger, Constantes.TConstantes.DECIMAIS_VALOR);

          LancamentoPagar.ListaParcelaPagarVO.Add(ParcelaPagar);
        end;
        TFinLancamentoPagarController.Insere(TFinLancamentoPagarVO(LancamentoPagar));
      end;

    except
      Result := False;
    end;
  end;
end;
{$ENDREGION}

{$REGION 'Campos Transientes'}
/// EXERCICIO: Implemente a busca usando o FLookup
procedure TFCompraPedido.EditIdFornecedorKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
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
      EditIdCompraTipoPedido.SetFocus;
    end;
  end;
end;

procedure TFCompraPedido.EditIdCompraTipoPedidoKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  Filtro: String;
  CompraTipoPedidoVO :TCompraTipoPedidoVO ;
begin
  if Key = VK_F1 then
  begin
    if EditIdCompraTipoPedido.Value <> 0 then
      Filtro := 'ID = ' + EditIdCompraTipoPedido.Text
    else
      Filtro := 'ID=0';

    try
      EditCompraTipoPedido.Clear;

        CompraTipoPedidoVO := TCompraTipoPedidoController.ConsultaObjeto(Filtro);
        if Assigned(CompraTipoPedidoVO) then
      begin
        EditCompraTipoPedido.Text := CompraTipoPedidoVO.Nome;
      end
      else
      begin
        Exit;
      end;
    finally
      EditDataPedido.SetFocus;
    end;
  end;
end;
{$ENDREGION}

{$REGION 'Controle de Grid'}
procedure TFCompraPedido.CDSCompraPedidoDetalheBeforePost(DataSet: TDataSet);
begin
  CDSCompraPedidoDetalhe.FieldByName('VALOR_SUBTOTAL').AsFloat := CDSCompraPedidoDetalhe.FieldByName('QUANTIDADE').AsFloat * CDSCompraPedidoDetalhe.FieldByName('VALOR_UNITARIO').AsFloat;
  CDSCompraPedidoDetalhe.FieldByName('VALOR_DESCONTO').AsFloat := CDSCompraPedidoDetalhe.FieldByName('VALOR_SUBTOTAL').AsFloat * (CDSCompraPedidoDetalhe.FieldByName('TAXA_DESCONTO').AsFloat / 100);
  CDSCompraPedidoDetalhe.FieldByName('VALOR_ICMS').AsFloat := CDSCompraPedidoDetalhe.FieldByName('BASE_CALCULO_ICMS').AsFloat * (CDSCompraPedidoDetalhe.FieldByName('ALIQUOTA_ICMS').AsFloat / 100);
  CDSCompraPedidoDetalhe.FieldByName('VALOR_IPI').AsFloat := CDSCompraPedidoDetalhe.FieldByName('VALOR_SUBTOTAL').AsFloat * (CDSCompraPedidoDetalhe.FieldByName('ALIQUOTA_IPI').AsFloat / 100);
  CDSCompraPedidoDetalhe.FieldByName('VALOR_TOTAL').AsFloat := CDSCompraPedidoDetalhe.FieldByName('VALOR_SUBTOTAL').AsFloat - CDSCompraPedidoDetalhe.FieldByName('VALOR_DESCONTO').AsFloat + CDSCompraPedidoDetalhe.FieldByName('VALOR_ICMS').AsFloat + CDSCompraPedidoDetalhe.FieldByName('VALOR_IPI').AsFloat;
end;

procedure TFCompraPedido.GridCompraPedidoDetalheKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  Filtro: String;
begin
  /// EXERCICIO: Implemente a busca usando o FLookup
  if Key = VK_F1 then
  begin
    CDSCompraPedidoDetalhe.Append;
    CDSCompraPedidoDetalhe.FieldByName('ID_PRODUTO').AsInteger := 1;//CDSTransiente.FieldByName('ID').AsInteger;
    //CDSCompraPedidoDetalhe.FieldByName('ProdutoNome').AsString := CDSTransiente.FieldByName('NOME').AsString;
    CDSCompraPedidoDetalhe.FieldByName('VALOR_UNITARIO').AsFloat := 5;//CDSTransiente.FieldByName('VALOR_VENDA').AsFloat;
  end;
  If Key = VK_RETURN then
    EditIdFornecedor.SetFocus;
end;

procedure TFCompraPedido.GridParaEdits;
var
  IdCabecalho: String;
  i: Integer;
  Current: TCompraPedidoDetalheVO;
begin
  inherited;

  if not CDSGrid.IsEmpty then
  begin
    IdCabecalho := IntToStr(IdRegistroSelecionado);
    ObjetoVO := TCompraPedidoController.ConsultaObjeto('ID=' + IdCabecalho);
  end;

  if Assigned(ObjetoVO) then
  begin

    EditIdCompraTipoPedido.AsInteger := TCompraPedidoVO(ObjetoVO).IdCompraTipoPedido;
    EditCompraTipoPedido.Text := TCompraPedidoVO(ObjetoVO).CompraTipoPedidoNome;
    EditIdFornecedor.AsInteger := TCompraPedidoVO(ObjetoVO).IdFornecedor;
    EditFornecedor.Text := TCompraPedidoVO(ObjetoVO).FornecedorNome;
    EditDataPedido.Date := TCompraPedidoVO(ObjetoVO).DataPedido;
    EditDataPrevistaEntrega.Date := TCompraPedidoVO(ObjetoVO).DataPrevistaEntrega;
    EditDataPrevisaoPagamento.Date := TCompraPedidoVO(ObjetoVO).DataPrevisaoPagamento;
    EditLocalEntrega.Text := TCompraPedidoVO(ObjetoVO).LocalEntrega;
    EditLocalCobranca.Text := TCompraPedidoVO(ObjetoVO).LocalCobranca;
    EditContato.Text := TCompraPedidoVO(ObjetoVO).Contato;

    case AnsiIndexStr(TCompraPedidoVO(ObjetoVO).TipoFrete, ['0', '1', '2']) of
      0:
        ComboBoxFormaPagamento.ItemIndex := 0;
      1:
        ComboBoxFormaPagamento.ItemIndex := 1;
      2:
        ComboBoxFormaPagamento.ItemIndex := 2;
    else
      ComboBoxTipoFrete.ItemIndex := -1;
    end;

    case AnsiIndexStr(TCompraPedidoVO(ObjetoVO).TipoFrete, ['C', 'F']) of
      0:
        ComboBoxTipoFrete.ItemIndex := 0;
      1:
        ComboBoxTipoFrete.ItemIndex := 1;
    else
      ComboBoxTipoFrete.ItemIndex := -1;
    end;

    EditQuantidadeParcelas.AsInteger := TCompraPedidoVO(ObjetoVO).QuantidadeParcelas;
    EditDiasPrimeiroVencimento.AsInteger := TCompraPedidoVO(ObjetoVO).DiasPrimeiroVencimento;
    EditDiasIntervalo.AsInteger := TCompraPedidoVO(ObjetoVO).DiasIntervalo;
    EditValorSubtotal.Value := TCompraPedidoVO(ObjetoVO).ValorSubtotal;
    EditTaxaDesconto.Value := TCompraPedidoVO(ObjetoVO).TaxaDesconto;
    EditValorDesconto.Value := TCompraPedidoVO(ObjetoVO).ValorDesconto;
    EditValorTotalPedido.Value := TCompraPedidoVO(ObjetoVO).ValorTotalPedido;
    EditBaseCalculoICMS.Value := TCompraPedidoVO(ObjetoVO).BaseCalculoIcms;
    EditValorICMS.Value := TCompraPedidoVO(ObjetoVO).ValorIcms;
    EditBaseCalculoIcmsSt.Value := TCompraPedidoVO(ObjetoVO).BaseCalculoIcmsSt;
    EditValorIcmsSt.Value := TCompraPedidoVO(ObjetoVO).ValorIcmsSt;
    EditValorTotalProdutos.Value := TCompraPedidoVO(ObjetoVO).ValorTotalProdutos;
    EditValorFrete.Value := TCompraPedidoVO(ObjetoVO).ValorFrete;
    EditValorSeguro.Value := TCompraPedidoVO(ObjetoVO).ValorSeguro;
    EditValorOutrasDespesas.Value := TCompraPedidoVO(ObjetoVO).ValorOutrasDespesas;
    EditValorIPI.Value := TCompraPedidoVO(ObjetoVO).ValorIpi;
    EditValorTotalNF.Value := TCompraPedidoVO(ObjetoVO).ValorTotalNf;

    // Itens do Pedido de Compra
    for I := 0 to TCompraPedidoVO(ObjetoVO).ListaCompraPedidoDetalheVO.Count - 1 do
    begin
      Current := TCompraPedidoVO(ObjetoVO).ListaCompraPedidoDetalheVO[I];
      CDSCompraPedidoDetalhe.Append;

      CDSCompraPedidoDetalhe.FieldByName('ID').AsInteger := Current.Id;
      CDSCompraPedidoDetalhe.FieldByName('ID_COMPRA_PEDIDO').AsInteger := Current.IdCompraPedido;
      CDSCompraPedidoDetalhe.FieldByName('ID_PRODUTO').AsInteger := Current.IdProduto;
      //CDSCompraPedidoDetalhe.FieldByName('PRODUTONOME').AsString := Current.ProdutoVO.Nome;
      CDSCompraPedidoDetalhe.FieldByName('QUANTIDADE').AsFloat := Current.Quantidade;
      CDSCompraPedidoDetalhe.FieldByName('VALOR_UNITARIO').AsFloat := Current.ValorUnitario;
      CDSCompraPedidoDetalhe.FieldByName('VALOR_SUBTOTAL').AsFloat := Current.ValorSubtotal;
      CDSCompraPedidoDetalhe.FieldByName('TAXA_DESCONTO').AsFloat := Current.TaxaDesconto;
      CDSCompraPedidoDetalhe.FieldByName('VALOR_DESCONTO').AsFloat := Current.ValorDesconto;
      CDSCompraPedidoDetalhe.FieldByName('VALOR_TOTAL').AsFloat := Current.ValorTotal;
      CDSCompraPedidoDetalhe.FieldByName('CST_CSOSN').AsString := Current.CstCsosn;
      CDSCompraPedidoDetalhe.FieldByName('CFOP').AsInteger := Current.Cfop;
      CDSCompraPedidoDetalhe.FieldByName('BASE_CALCULO_ICMS').AsFloat := Current.BaseCalculoIcms;
      CDSCompraPedidoDetalhe.FieldByName('VALOR_ICMS').AsFloat := Current.ValorIcms;
      CDSCompraPedidoDetalhe.FieldByName('VALOR_IPI').AsFloat := Current.ValorIpi;
      CDSCompraPedidoDetalhe.FieldByName('ALIQUOTA_ICMS').AsFloat := Current.AliquotaIcms;
      CDSCompraPedidoDetalhe.FieldByName('ALIQUOTA_IPI').AsFloat := Current.AliquotaIpi;

      CDSCompraPedidoDetalhe.Post;
    end;

    // Serializa o objeto para consultar posteriormente se houve alterações
    FormatSettings.DecimalSeparator := '.';
    StringObjetoOld := ObjetoVO.ToJSONString;
    FormatSettings.DecimalSeparator := ',';
  end;
end;
{$ENDREGION}

{$REGION 'Actions'}
procedure TFCompraPedido.ActionAtualizarValoresExecute(Sender: TObject);
begin
  AtualizaTotaisItens(False);
end;

procedure TFCompraPedido.AtualizaTotaisItens(pEditarValores: Boolean);
var
  SubTotal, TotalDesconto, TotalGeral, TotalBaseCalculoIcms, TotalIcms, TotalIpi: Extended;
begin
  SubTotal := 0;
  TotalDesconto := 0;
  TotalGeral := 0;
  TotalBaseCalculoIcms := 0;
  TotalIcms := 0;
  TotalIpi := 0;
  //
  CDSCompraPedidoDetalhe.DisableControls;
  CDSCompraPedidoDetalhe.First;
  while not CDSCompraPedidoDetalhe.Eof do
  begin
    if pEditarValores then
    begin
      CDSCompraPedidoDetalhe.Edit;
      CDSCompraPedidoDetalhe.FieldByName('VALOR_SUBTOTAL').AsFloat := CDSCompraPedidoDetalhe.FieldByName('QUANTIDADE').AsFloat * CDSCompraPedidoDetalhe.FieldByName('VALOR_UNITARIO').AsFloat;
      CDSCompraPedidoDetalhe.FieldByName('VALOR_DESCONTO').AsFloat := CDSCompraPedidoDetalhe.FieldByName('VALOR_SUBTOTAL').AsFloat * (CDSCompraPedidoDetalhe.FieldByName('TAXA_DESCONTO').AsFloat / 100);
      CDSCompraPedidoDetalhe.FieldByName('VALOR_TOTAL').AsFloat := CDSCompraPedidoDetalhe.FieldByName('VALOR_SUBTOTAL').AsFloat - CDSCompraPedidoDetalhe.FieldByName('VALOR_DESCONTO').AsFloat;
      CDSCompraPedidoDetalhe.FieldByName('BASE_CALCULO_ICMS').AsFloat := CDSCompraPedidoDetalhe.FieldByName('VALOR_TOTAL').AsFloat;
      CDSCompraPedidoDetalhe.FieldByName('VALOR_ICMS').AsFloat := CDSCompraPedidoDetalhe.FieldByName('BASE_CALCULO_ICMS').AsFloat * (CDSCompraPedidoDetalhe.FieldByName('ALIQUOTA_ICMS').AsFloat / 100);
      CDSCompraPedidoDetalhe.FieldByName('VALOR_IPI').AsFloat := CDSCompraPedidoDetalhe.FieldByName('VALOR_TOTAL').AsFloat * (CDSCompraPedidoDetalhe.FieldByName('ALIQUOTA_IPI').AsFloat / 100);
      CDSCompraPedidoDetalhe.Post;
    end;
    SubTotal := SubTotal + CDSCompraPedidoDetalhe.FieldByName('VALOR_SUBTOTAL').AsFloat;
    TotalDesconto := TotalDesconto + CDSCompraPedidoDetalhe.FieldByName('VALOR_DESCONTO').AsFloat;
    TotalGeral := TotalGeral + CDSCompraPedidoDetalhe.FieldByName('VALOR_TOTAL').AsFloat;
    TotalBaseCalculoIcms := TotalBaseCalculoIcms + CDSCompraPedidoDetalhe.FieldByName('BASE_CALCULO_ICMS').AsFloat;
    TotalIcms := TotalIcms + CDSCompraPedidoDetalhe.FieldByName('VALOR_ICMS').AsFloat;
    TotalIpi := TotalIpi + CDSCompraPedidoDetalhe.FieldByName('VALOR_IPI').AsFloat;
    //
    CDSCompraPedidoDetalhe.Next;
  end;
  CDSCompraPedidoDetalhe.First;
  CDSCompraPedidoDetalhe.EnableControls;
  //
  EditValorSubtotal.Value := SubTotal;
  EditValorDesconto.Value := TotalDesconto;
  EditValorTotalPedido.Value := TotalGeral;
  EditBaseCalculoICMS.Value := TotalBaseCalculoIcms;
  EditValorICMS.Value := TotalIcms;
  EditValorTotalProdutos.Value := TotalGeral;
  EditValorIPI.Value := TotalIpi;
  EditValorTotalNF.Value := TotalGeral + TotalIcms;
end;
{$ENDREGION}

end.

