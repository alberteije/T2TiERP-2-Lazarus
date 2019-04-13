{ *******************************************************************************
Title: T2Ti ERP
Description: Janela de Pagamento das Parcelas

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

@author Albert Eije
@version 2.0
******************************************************************************* }
unit UFinParcelaPagamento;

{$MODE Delphi}

interface

uses
  BrookHTTPClient, BrookFCLHTTPClientBroker, BrookHTTPUtils, BrookUtils, FPJson, ZDataset,
  LCLIntf, LCLType, LMessages, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UTelaCadastro, Menus, StdCtrls, ExtCtrls, Buttons, Grids, DBGrids,
  ComCtrls, LabeledCtrls, rxdbgrid, rxtoolbar, DBCtrls, StrUtils,
  Math, Constantes, CheckLst, ActnList, ToolWin, db, BufDataset, Biblioteca,
  ULookup, VO, FinChequeEmitidoVO, AdmParametroVO, ViewFinLancamentoPagarVO,
  ViewFinLancamentoPagarController;

  type

  { TFFinParcelaPagamento }

  TFFinParcelaPagamento = class(TFTelaCadastro)
    BevelEdits: TBevel;
    CDSParcelaPagamento: TBufDataset;
    PanelEditsInterno: TPanel;
    EditDataPagamento: TLabeledDateEdit;
    EditTaxaJuro: TLabeledCalcEdit;
    EditValorJuro: TLabeledCalcEdit;
    EditValorMulta: TLabeledCalcEdit;
    EditValorDesconto: TLabeledCalcEdit;
    EditTaxaDesconto: TLabeledCalcEdit;
    EditTaxaMulta: TLabeledCalcEdit;
    MemoHistorico: TLabeledMemo;
    ActionManager: TActionList;
    ActionBaixarParcela: TAction;
    DSParcelaPagamento: TDataSource;
    CDSParcelaPagamentoID: TIntegerField;
    CDSParcelaPagamentoID_FIN_PARCELA_PAGAR: TIntegerField;
    CDSParcelaPagamentoID_FIN_CHEQUE_EMITIDO: TIntegerField;
    CDSParcelaPagamentoID_FIN_TIPO_PAGAMENTO: TIntegerField;
    CDSParcelaPagamentoID_CONTA_CAIXA: TIntegerField;
    CDSParcelaPagamentoDATA_PAGAMENTO: TDateField;
    CDSParcelaPagamentoTAXA_JURO: TFMTBCDField;
    CDSParcelaPagamentoTAXA_MULTA: TFMTBCDField;
    CDSParcelaPagamentoTAXA_DESCONTO: TFMTBCDField;
    CDSParcelaPagamentoVALOR_JURO: TFMTBCDField;
    CDSParcelaPagamentoVALOR_MULTA: TFMTBCDField;
    CDSParcelaPagamentoVALOR_DESCONTO: TFMTBCDField;
    CDSParcelaPagamentoVALOR_PAGO: TFMTBCDField;
    CDSParcelaPagamentoCONTA_CAIXANOME: TStringField;
    CDSParcelaPagamentoTIPO_PAGAMENTODESCRICAO: TStringField;
    CDSParcelaPagamentoCHEQUENUMERO: TIntegerField;
    EditIdTipoPagamento: TLabeledCalcEdit;
    EditCodigoTipoPagamento: TLabeledEdit;
    EditTipoPagamento: TLabeledEdit;
    EditIdContaCaixa: TLabeledCalcEdit;
    EditContaCaixa: TLabeledEdit;
    EditValorPago: TLabeledCalcEdit;
    EditValorAPagar: TLabeledCalcEdit;
    EditDataVencimento: TLabeledDateEdit;
    CDSParcelaPagamentoHISTORICO: TStringField;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    EditDataInicio: TLabeledDateEdit;
    EditDataFim: TLabeledDateEdit;
    PanelParcelaPaga: TPanel;
    GridPagamentos: TRxDbGrid;
    ActionToolBar1: TToolPanel;
    ComboBoxTipoBaixa: TLabeledComboBox;
    PanelTotaisPagos: TPanel;
    ActionExcluirParcela: TAction;
    procedure FormCreate(Sender: TObject);
    procedure ActionBaixarParcelaExecute(Sender: TObject);
    procedure CalcularTotalPago(Sender: TObject);
    procedure BotaoConsultarClick(Sender: TObject);
    procedure BotaoSalvarClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure BaixarParcela;
    procedure BaixarParcelaCheque;
    procedure CalcularTotais;
    procedure GridCellClick(Column: TColumn);
//    procedure GridDrawColumnCell(Sender: TObject; const Rect: TRect; DataCol: Integer; Column: TColumn; State: TGridDrawState);
    function VerificarPacotePagamentoCheque: Boolean;
    procedure EditIdTipoPagamentoKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure EditIdContaCaixaKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure ActionExcluirParcelaExecute(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure GridParaEdits; override;
    procedure LimparCampos; override;
    function MontaFiltro: string; override;

    // Controles CRUD
    function DoEditar: Boolean; override;
  end;

var
  FFinParcelaPagamento: TFFinParcelaPagamento;
  ChequeEmitido: TFinChequeEmitidoVO;
  SomaCheque: Extended;
  AdmParametroVO: TAdmParametroVO;

implementation

uses
  FinParcelaPagamentoVO, FinParcelaPagamentoController, FinParcelaPagarVO,
  FinParcelaPagarController, FinTipoPagamentoVO, FinTipoPagamentoController,
  ContaCaixaVO, ContaCaixaController, UTela, USelecionaCheque, UDataModule,
  AdmParametroController;

{$R *.lfm}

{$REGION 'Infra'}
procedure TFFinParcelaPagamento.BotaoConsultarClick(Sender: TObject);
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
    RetornoConsulta := TViewFinLancamentoPagarController.Consulta(Filtro, IntToStr(Pagina));
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

procedure TFFinParcelaPagamento.BotaoSalvarClick(Sender: TObject);
begin
  inherited;
  BotaoConsultarClick(Sender);
end;

procedure TFFinParcelaPagamento.FormCreate(Sender: TObject);
var
  Filtro: String;
begin
  ClasseObjetoGridVO := TViewFinLancamentoPagarVO;
  ObjetoController := TViewFinLancamentoPagarController.Create;

  inherited;

  Filtro := 'ID_EMPRESA = ' + IntToStr(Sessao.Empresa.Id);
  AdmParametroVO := TAdmParametroController.ConsultaObjeto(Filtro);

  ConfiguraCDSFromVO(CDSParcelaPagamento, TFinParcelaPagamentoVO);
end;

procedure TFFinParcelaPagamento.FormShow(Sender: TObject);
begin
  inherited;
  EditDataInicio.Date := Now;
  EditDataFim.Date := Now;

  BotaoInserir.Visible := False;
  BotaoExcluir.Visible := False;
  BotaoCancelar.Visible := False;
  BotaoAlterar.Caption := 'Confirmar [F3]';
  BotaoSalvar.Caption := 'Retornar [F12]';

  MenuInserir.Visible := False;
  MenuExcluir.Visible := False;
  MenuCancelar.Visible := False;
  MenuAlterar.Caption := 'Confirmar [F3]';
  menuSalvar.Caption := 'Retornar [F12]';
end;

procedure TFFinParcelaPagamento.LimparCampos;
var
  DataInicioInformada, DataFimInformada: TDateTime;
begin
  DataInicioInformada := EditDataInicio.Date;
  DataFimInformada := EditDataFim.Date;
  inherited;
  CDSParcelaPagamento.Close;
  CDSParcelaPagamento.Open;

  EditDataInicio.Date := DataInicioInformada;
  EditDataFim.Date := DataFimInformada;
end;
{$ENDREGION}

{$REGION 'Controles CRUD'}
function TFFinParcelaPagamento.DoEditar: Boolean;
begin
  if not CDSGrid.IsEmpty then
  begin

    if CDSGrid.FieldByName('SITUACAO_PARCELA').AsString = '02' then
    begin
      Application.MessageBox('Procedimento não permitido. Parcela já quitada.', 'Mensagem do Sistema', MB_OK + MB_ICONINFORMATION);
      Exit;
    end;

    if CDSGrid.FieldByName('FORNECEDOR_SOFRE_RETENCAO').AsString = 'S' then
    begin
      Application.MessageBox('Procedimento não permitido. Fornecedor com retenção.', 'Mensagem do Sistema', MB_OK + MB_ICONINFORMATION);
      Exit;
    end;

    if VerificarPacotePagamentoCheque then
    begin
      ChequeEmitido := TFinChequeEmitidoVO.Create;

      Application.CreateForm(TFSelecionaCheque, FSelecionaCheque);
      FSelecionaCheque.EditValorCheque.Value := SomaCheque;
      FSelecionaCheque.ShowModal;

      if FSelecionaCheque.Confirmou then
      begin
        ChequeEmitido.IdCheque := FSelecionaCheque.CDSChequesEmSer.FieldByName('ID_CHEQUE').AsInteger;
        ChequeEmitido.DataEmissao := now;
        ChequeEmitido.Valor := FSelecionaCheque.EditValorCheque.Value;
        ChequeEmitido.NominalA := FSelecionaCheque.EditNominalA.Text;
        ChequeEmitido.BomPara := FSelecionaCheque.EditBomPara.Date;
        BaixarParcelaCheque;
        FreeAndNil(FSelecionaCheque);
      end;
    end
    else
    begin
      Result := inherited DoEditar;

      if Result then
      begin
        ComboBoxTipoBaixa.SetFocus;
      end;
    end;
  end;
end;

function TFFinParcelaPagamento.VerificarPacotePagamentoCheque: Boolean;
var
  LinhaAtual: TBookMark;
  ParcelasVencidas: Boolean;
begin
  Result := False;
  ParcelasVencidas := False;
  LinhaAtual := CDSGrid.GetBookmark;
  SomaCheque := 0;

  CDSGrid.DisableControls;
  CDSGrid.First;
  while not CDSGrid.Eof do
  begin
    if CDSGrid.FieldByName('EmitirCheque').AsString = 'S' then
      SomaCheque := SomaCheque + CDSGrid.FieldByName('VALOR_PARCELA').AsFloat;
    ParcelasVencidas := CDSGrid.FieldByName('DATA_VENCIMENTO').AsDateTime < Date;
    CDSGrid.Next;
  end;

  if CDSGrid.BookmarkValid(LinhaAtual) then
  begin
    CDSGrid.GotoBookmark(LinhaAtual);
    CDSGrid.FreeBookmark(LinhaAtual);
  end;
  CDSGrid.EnableControls;

  if SomaCheque = 0 then
    Exit;

  if ParcelasVencidas then
  begin
    Application.MessageBox('Procedimento não permitido. Parcela sem valores ou vencidas.', 'Mensagem do Sistema', MB_OK + MB_ICONINFORMATION);
    CDSGrid.EnableControls;
    Exit;
  end;

  Result := True;
end;
{$ENDREGION}

{$REGION 'Campos Transientes'}
procedure TFFinParcelaPagamento.EditIdTipoPagamentoKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  Filtro: String;
  FinTipoPagamentoVO :TFinTipoPagamentoVO ;
begin
  if Key = VK_F1 then
  begin
    if EditIdTipoPagamento.Value <> 0 then
      Filtro := 'ID = ' + EditIdTipoPagamento.Text
    else
      Filtro := 'ID=0';

    try
      EditCodigoTipoPagamento.Clear;
      EditTipoPagamento.Clear;

        FinTipoPagamentoVO := TFinTipoPagamentoController.ConsultaObjeto(Filtro);
        if Assigned(FinTipoPagamentoVO) then
      begin
        EditCodigoTipoPagamento.Text := FinTipoPagamentoVO.Tipo;
        EditTipoPagamento.Text := FinTipoPagamentoVO.Descricao;
      end
      else
      begin
        Exit;
      end;
    finally
      EditIdContaCaixa.SetFocus;
    end;
  end;
end;

procedure TFFinParcelaPagamento.EditIdContaCaixaKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
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
      EditDataVencimento.SetFocus;
    end;
  end;
end;
{$ENDREGION}

{$REGION 'Controle de Grid'}
procedure TFFinParcelaPagamento.GridCellClick(Column: TColumn);
begin
  if Column.Index = 1 then
  begin
    if CDSGrid.FieldByName('SITUACAO_PARCELA').AsString = '02' then
    begin
      Application.MessageBox('Procedimento não permitido. Parcela já quitada.', 'Mensagem do Sistema', MB_OK + MB_ICONINFORMATION);
      Exit;
    end;

    if CDSGrid.FieldByName('FORNECEDOR_SOFRE_RETENCAO').AsString = 'S' then
    begin
      Application.MessageBox('Procedimento não permitido. Fornecedor com retenção.', 'Mensagem do Sistema', MB_OK + MB_ICONINFORMATION);
      Exit;
    end;

    CDSGrid.Edit;
    if CDSGrid.FieldByName('EmitirCheque').AsString = '' then
      CDSGrid.FieldByName('EmitirCheque').AsString := 'S'
    else
      CDSGrid.FieldByName('EmitirCheque').AsString := '';
    CDSGrid.Post;
  end;
end;
{
procedure TFFinParcelaPagamento.GridDrawColumnCell(Sender: TObject; const Rect: TRect; DataCol: Integer; Column: TColumn; State: TGridDrawState);
var
  lIcone : TBitmap;
  lRect: TRect;
begin
  lRect := Rect;
  lIcone := TBitmap.Create;

  if Column.Index = 0 then
  begin
    if Grid.Columns[0].Width <> 32 then
      Grid.Columns[0].Width := 32;

    try
      if Grid.Columns[1].Field.Value = '' then
      begin
        FDataModule.ImagensCheck.GetBitmap(0, lIcone);
        Grid.Canvas.Draw(Rect.Left+8 ,Rect.Top+1, lIcone);
      end
      else if Grid.Columns[1].Field.Value = 'S' then
      begin
        FDataModule.ImagensCheck.GetBitmap(1, lIcone);
        Grid.Canvas.Draw(Rect.Left+8,Rect.Top+1, lIcone);
      end
    finally
      lIcone.Free;
    end;
  end;
end;
}
procedure TFFinParcelaPagamento.GridParaEdits;
var
  IdCabecalho: String;
  Filtro: String;
  RetornoConsulta: TZQuery;
  ListaCampos: TStringList;
  I: Integer;
begin
  inherited;

  if not CDSGrid.IsEmpty then
  begin
    IdCabecalho := IntToStr(IdRegistroSelecionado);
    ObjetoVO := TViewFinLancamentoPagarController.ConsultaObjeto('ID=' + IdCabecalho);
  end;

  if Assigned(ObjetoVO) then
  begin

    EditIdContaCaixa.AsInteger := TViewFinLancamentoPagarVO(ObjetoVO).IdContaCaixa;
    EditContaCaixa.Text := TViewFinLancamentoPagarVO(ObjetoVO).NomeContaCaixa;
    EditDataVencimento.Date := TViewFinLancamentoPagarVO(ObjetoVO).DataVencimento;
    EditValorAPagar.Value := TViewFinLancamentoPagarVO(ObjetoVO).ValorParcela;
    EditTaxaJuro.Value := TViewFinLancamentoPagarVO(ObjetoVO).TaxaJuro;
    EditValorJuro.Value := TViewFinLancamentoPagarVO(ObjetoVO).ValorJuro;
    EditTaxaMulta.Value := TViewFinLancamentoPagarVO(ObjetoVO).TaxaMulta;
    EditValorMulta.Value := TViewFinLancamentoPagarVO(ObjetoVO).ValorMulta;
    EditTaxaDesconto.Value := TViewFinLancamentoPagarVO(ObjetoVO).TaxaDesconto;
    EditValorDesconto.Value := TViewFinLancamentoPagarVO(ObjetoVO).ValorDesconto;
    CalcularTotalPago(nil);

    CDSParcelaPagamento.Close;
    CDSParcelaPagamento.Open;

    Filtro := 'ID_FIN_PARCELA_PAGAR=' + QuotedStr(IntToStr(CDSGrid.FieldByName('ID_PARCELA_PAGAR').AsInteger));
    ListaCampos  := TStringList.Create;
    RetornoConsulta := TFinParcelaPagamentoController.Consulta(Filtro, '0');
    RetornoConsulta.Active := True;

    RetornoConsulta.GetFieldNames(ListaCampos);

    RetornoConsulta.First;
    while not RetornoConsulta.EOF do begin
      CDSParcelaPagamento.Append;
      for i := 0 to ListaCampos.Count - 1 do
      begin
        CDSParcelaPagamento.FieldByName(ListaCampos[i]).Value := RetornoConsulta.FieldByName(ListaCampos[i]).Value;
      end;
      CDSParcelaPagamento.Post;
      RetornoConsulta.Next;
    end;

    CalcularTotais;
  end;
end;
{$ENDREGION}

{$REGION 'Actions'}
procedure TFFinParcelaPagamento.ActionBaixarParcelaExecute(Sender: TObject);
begin
  if EditIdTipoPagamento.AsInteger <= 0 then
  begin
    Application.MessageBox('É necessário informar o tipo de pagamento.', 'Mensagem do Sistema', MB_OK + MB_ICONINFORMATION);
    EditIdTipoPagamento.SetFocus;
    Exit;
  end;
  if EditIdContaCaixa.AsInteger <= 0 then
  begin
    Application.MessageBox('É necessário informar a conta caixa.', 'Mensagem do Sistema', MB_OK + MB_ICONINFORMATION);
    EditIdContaCaixa.SetFocus;
    Exit;
  end;

  ChequeEmitido := TFinChequeEmitidoVO.Create;

  if EditCodigoTipoPagamento.Text = '02' then
  begin
    Application.CreateForm(TFSelecionaCheque, FSelecionaCheque);
    FSelecionaCheque.EditBomPara.Date := EditDataPagamento.Date;
    FSelecionaCheque.EditValorCheque.Value := EditValorPago.Value;
    FSelecionaCheque.MemoHistorico.Text := MemoHistorico.Text;
    FSelecionaCheque.ShowModal;

    if FSelecionaCheque.Confirmou then
    begin
      ChequeEmitido.IdCheque := FSelecionaCheque.CDSChequesEmSer.FieldByName('ID_CHEQUE').AsInteger;
      ChequeEmitido.DataEmissao := now;
      ChequeEmitido.Valor := FSelecionaCheque.EditValorCheque.Value;
      ChequeEmitido.NominalA := FSelecionaCheque.EditNominalA.Text;
      ChequeEmitido.BomPara := FSelecionaCheque.EditBomPara.Date;
      BaixarParcela;
      FreeAndNil(FSelecionaCheque);
    end;
  end
  else
    BaixarParcela;
end;

procedure TFFinParcelaPagamento.ActionExcluirParcelaExecute(Sender: TObject);
var
  ParcelaPagar: TFinParcelaPagarVO;
begin
  /// EXERCICIO: VERIFIQUE SE A IMPLEMENTAÇÃO ESTÁ CORRETA. CORRIJA O QUE FOR NECESSÁRIO.

  if CDSParcelaPagamentoID.AsInteger > 0 then
    TFinParcelaPagamentoController.Exclui(CDSParcelaPagamento.FieldByName('ID').AsInteger);
  CDSParcelaPagamento.Delete;

  if CDSParcelaPagamento.IsEmpty then
  begin
    ParcelaPagar := TFinParcelaPagarController.ConsultaObjeto('ID=' + CDSGrid.FieldByName('ID_PARCELA_PAGAR').AsString);
    ParcelaPagar.IdFinStatusParcela := AdmParametroVO.FinParcelaAberto;
    TFinParcelaPagarController.Altera(ParcelaPagar);
  end;
  CalcularTotais;
end;

procedure TFFinParcelaPagamento.BaixarParcela;
var
  ParcelaPagar: TFinParcelaPagarVO;
  RetornoConsulta: TZQuery;
  ListaCampos: TStringList;
  I: Integer;
begin
  ParcelaPagar := TFinParcelaPagarController.ConsultaObjeto('ID=' + CDSGrid.FieldByName('ID_PARCELA_PAGAR').AsString);

  if ComboBoxTipoBaixa.ItemIndex = 0 then
    ParcelaPagar.IdFinStatusParcela := AdmParametroVO.FinParcelaQuitado
  else if ComboBoxTipoBaixa.ItemIndex = 1 then
    ParcelaPagar.IdFinStatusParcela := AdmParametroVO.FinParcelaQuitadoParcial;

  ParcelaPagar.FinParcelaPagamentoVO := TFinParcelaPagamentoVO.Create;

  ParcelaPagar.FinParcelaPagamentoVO.IdFinTipoPagamento := EditIdTipoPagamento.AsInteger;
  ParcelaPagar.FinParcelaPagamentoVO.IdFinParcelaPagar := ParcelaPagar.Id;
  ParcelaPagar.FinParcelaPagamentoVO.IdContaCaixa := EditIdContaCaixa.AsInteger;
  ParcelaPagar.FinParcelaPagamentoVO.DataPagamento := EditDataPagamento.Date;
  ParcelaPagar.FinParcelaPagamentoVO.TaxaJuro := EditTaxaJuro.Value;
  ParcelaPagar.FinParcelaPagamentoVO.ValorJuro := EditValorJuro.Value;
  ParcelaPagar.FinParcelaPagamentoVO.TaxaMulta := EditTaxaMulta.Value;
  ParcelaPagar.FinParcelaPagamentoVO.ValorMulta := EditValorMulta.Value;
  ParcelaPagar.FinParcelaPagamentoVO.TaxaDesconto := EditTaxaDesconto.Value;
  ParcelaPagar.FinParcelaPagamentoVO.ValorDesconto := EditValorDesconto.Value;
  ParcelaPagar.FinParcelaPagamentoVO.Historico := Trim(MemoHistorico.Text);
  ParcelaPagar.FinParcelaPagamentoVO.ValorPago := EditValorPago.Value;

  ParcelaPagar.FinChequeEmitidoVO := ChequeEmitido;

  TFinParcelaPagarController.Altera(ParcelaPagar);


  CDSParcelaPagamento.Close;
  CDSParcelaPagamento.Open;

  Filtro := 'ID_FIN_PARCELA_PAGAR=' + QuotedStr(IntToStr(CDSGrid.FieldByName('ID_PARCELA_PAGAR').AsInteger));
  ListaCampos  := TStringList.Create;
  RetornoConsulta := TFinParcelaPagamentoController.Consulta(Filtro, '0');
  RetornoConsulta.Active := True;

  RetornoConsulta.GetFieldNames(ListaCampos);

  RetornoConsulta.First;
  while not RetornoConsulta.EOF do begin
    CDSParcelaPagamento.Append;
    for i := 0 to ListaCampos.Count - 1 do
    begin
      CDSParcelaPagamento.FieldByName(ListaCampos[i]).Value := RetornoConsulta.FieldByName(ListaCampos[i]).Value;
    end;
    CDSParcelaPagamento.Post;
    RetornoConsulta.Next;
  end;

  CalcularTotais;
end;

procedure TFFinParcelaPagamento.BaixarParcelaCheque;
var
  ParcelaPagar, ObjetoPersistencia: TFinParcelaPagarVO;
  ParcelaPagamento: TFinParcelaPagamentoVO;
  ListaParcelaPagar: TListaFinParcelaPagarVO;
  ListaParcelaPagamento: TListaFinParcelaPagamentoVO;
begin
  try
    ListaParcelaPagar := TListaFinParcelaPagarVO.Create;
    ListaParcelaPagamento := TListaFinParcelaPagamentoVO.Create;

    CDSGrid.DisableControls;
    CDSGrid.First;
    while not CDSGrid.Eof do
    begin
      if CDSGrid.FieldByName('EmitirCheque').AsString = 'S' then
      begin
        ParcelaPagar := TFinParcelaPagarController.ConsultaObjeto('ID=' + CDSGrid.FieldByName('ID_PARCELA_PAGAR').AsString);
        ParcelaPagar.IdFinStatusParcela := AdmParametroVO.FinParcelaQuitado;

        ParcelaPagamento := TFinParcelaPagamentoVO.Create;
        ParcelaPagamento.IdFinTipoPagamento := 2;
        ParcelaPagamento.IdFinParcelaPagar := ParcelaPagar.Id;
        ParcelaPagamento.IdContaCaixa := FSelecionaCheque.CDSChequesEmSerID_CONTA_CAIXA.AsInteger;
        ParcelaPagamento.DataPagamento := FSelecionaCheque.EditBomPara.Date;
        ParcelaPagamento.Historico := FSelecionaCheque.MemoHistorico.Text;
        ParcelaPagamento.ValorPago := ParcelaPagar.Valor;

        ListaParcelaPagar.Add(ParcelaPagar);
        ListaParcelaPagamento.Add(ParcelaPagamento);
      end;
      CDSGrid.Next;
    end;
    CDSGrid.First;
    CDSGrid.EnableControls;

    ObjetoPersistencia := TFinParcelaPagarVO.Create;
//    ObjetoPersistencia.ListaParcelaPagarVO := ListaParcelaPagar;
    ObjetoPersistencia.ListaParcelaPagamentoVO := ListaParcelaPagamento;
    ObjetoPersistencia.FinChequeEmitidoVO := ChequeEmitido;

    TFinParcelaPagarController.BaixarParcelaCheque(ObjetoPersistencia);

    BotaoConsultar.Click;
  finally
  end;
end;

/// EXERCICIO: LEVE EM CONSIDERACAO O STATUS DA PARCELA

function TFFinParcelaPagamento.MontaFiltro: string;
var
  Item: TItemComboBox;
  Idx: Integer;
  DataSetField: TField;
  DataSet: TBufDataset;
begin
  DataSet := CDSGrid;
  if ComboBoxCampos.ItemIndex <> -1 then
  begin
    Idx := ComboBoxCampos.ItemIndex;
    Item := TItemComboBox(ComboBoxCampos.Items.Objects[Idx]);
    DataSetField := DataSet.FindField(Item.Campo);

    Result := '(DATA_VENCIMENTO between ' + QuotedStr(DataParaTexto(EditDataInicio.Date)) + ' and ' + QuotedStr(DataParaTexto(EditDataFim.Date)) + ') and ' + Item.Campo + ' LIKE ' + QuotedStr('%' + EditCriterioRapido.Text + '%');
  end
  else
  begin
    Result := ' 1=1 ';
  end;
end;

procedure TFFinParcelaPagamento.CalcularTotalPago(Sender: TObject);
begin
  EditValorJuro.Value := (EditValorAPagar.Value * (EditTaxaJuro.Value / 30) / 100) * (Now - EditDataVencimento.Date);
  EditValorMulta.Value := EditValorAPagar.Value * (EditTaxaMulta.Value / 100);
  EditValorDesconto.Value := EditValorAPagar.Value * (EditTaxaDesconto.Value / 100);
  EditValorPago.Value := EditValorAPagar.Value + EditValorJuro.Value + EditValorMulta.Value - EditValorDesconto.Value;
end;

procedure TFFinParcelaPagamento.CalcularTotais;
var
  Juro, Multa, Desconto, Total, Saldo: Extended;
begin
  Juro := 0;
  Multa := 0;
  Desconto := 0;
  Total := 0;
  Saldo := 0;
  //
  CDSParcelaPagamento.DisableControls;
  CDSParcelaPagamento.First;
  while not CDSParcelaPagamento.Eof do
  begin
    Juro := Juro + CDSParcelaPagamento.FieldByName('VALOR_JURO').AsFloat;
    Multa := Multa + CDSParcelaPagamento.FieldByName('VALOR_MULTA').AsFloat;
    Desconto := Desconto + CDSParcelaPagamento.FieldByName('VALOR_DESCONTO').AsFloat;
    Total := Total + CDSParcelaPagamento.FieldByName('VALOR_PAGO').AsFloat;
    CDSParcelaPagamento.Next;
  end;
  CDSParcelaPagamento.First;
  CDSParcelaPagamento.EnableControls;
  //
  PanelTotaisPagos.Caption := '|      Juros: ' +  FloatToStrF(Juro, ffCurrency, 15, 2) +
                        '      |      Multa: ' +   FloatToStrF(Multa, ffCurrency, 15, 2) +
                        '      |      Desconto: ' +   FloatToStrF(Desconto, ffCurrency, 15, 2) +
                        '      |      Total Pago: ' +   FloatToStrF(Total, ffCurrency, 15, 2) +
                        '      |      Saldo: ' +   FloatToStrF(Total - EditValorAPagar.Value, ffCurrency, 15, 2) + '      |';
end;
{$ENDREGION}

end.

