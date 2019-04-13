{ *******************************************************************************
Title: T2Ti ERP
Description: Janela de Recebimento das Parcelas

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
unit UFinParcelaRecebimento;

{$MODE Delphi}

interface

uses
  BrookHTTPClient, BrookFCLHTTPClientBroker, BrookHTTPUtils, BrookUtils, FPJson, ZDataset,
  LCLIntf, LCLType, LMessages, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UTelaCadastro, Menus, StdCtrls, ExtCtrls, Buttons, Grids, DBGrids,
  ComCtrls, LabeledCtrls, rxdbgrid, rxtoolbar, DBCtrls, StrUtils,
  Math, Constantes, CheckLst, ActnList, ToolWin, db, BufDataset, Biblioteca,
  ULookup, VO, FinChequeRecebidoVO, AdmParametroVO, ViewFinLancamentoReceberVO,
  ViewFinLancamentoReceberController;

  type

  { TFFinParcelaRecebimento }

  TFFinParcelaRecebimento = class(TFTelaCadastro)
    BevelEdits: TBevel;
    CDSParcelaRecebimento: TBufDataset;
    PanelEditsInterno: TPanel;
    EditDataRecebimento: TLabeledDateEdit;
    EditTaxaJuro: TLabeledCalcEdit;
    EditValorJuro: TLabeledCalcEdit;
    EditValorMulta: TLabeledCalcEdit;
    EditValorDesconto: TLabeledCalcEdit;
    EditTaxaDesconto: TLabeledCalcEdit;
    EditTaxaMulta: TLabeledCalcEdit;
    MemoHistorico: TLabeledMemo;
    ActionManager: TActionList;
    ActionBaixarParcela: TAction;
    DSParcelaRecebimento: TDataSource;
    CDSParcelaRecebimentoID: TIntegerField;
    CDSParcelaRecebimentoID_FIN_PARCELA_Receber: TIntegerField;
    CDSParcelaRecebimentoID_FIN_CHEQUE_EMITIDO: TIntegerField;
    CDSParcelaRecebimentoID_FIN_TIPO_Recebimento: TIntegerField;
    CDSParcelaRecebimentoID_CONTA_CAIXA: TIntegerField;
    CDSParcelaRecebimentoDATA_Recebimento: TDateField;
    CDSParcelaRecebimentoTAXA_JURO: TFMTBCDField;
    CDSParcelaRecebimentoTAXA_MULTA: TFMTBCDField;
    CDSParcelaRecebimentoTAXA_DESCONTO: TFMTBCDField;
    CDSParcelaRecebimentoVALOR_JURO: TFMTBCDField;
    CDSParcelaRecebimentoVALOR_MULTA: TFMTBCDField;
    CDSParcelaRecebimentoVALOR_DESCONTO: TFMTBCDField;
    CDSParcelaRecebimentoVALOR_Recebido: TFMTBCDField;
    CDSParcelaRecebimentoCONTA_CAIXANOME: TStringField;
    CDSParcelaRecebimentoTIPO_RecebimentoDESCRICAO: TStringField;
    CDSParcelaRecebimentoCHEQUENUMERO: TIntegerField;
    EditIdTipoRecebimento: TLabeledCalcEdit;
    EditCodigoTipoRecebimento: TLabeledEdit;
    EditTipoRecebimento: TLabeledEdit;
    EditIdContaCaixa: TLabeledCalcEdit;
    EditContaCaixa: TLabeledEdit;
    EditValorRecebido: TLabeledCalcEdit;
    EditValorAReceber: TLabeledCalcEdit;
    EditDataVencimento: TLabeledDateEdit;
    CDSParcelaRecebimentoHISTORICO: TStringField;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    EditDataInicio: TLabeledDateEdit;
    EditDataFim: TLabeledDateEdit;
    PanelParcelaPaga: TPanel;
    GridRecebimentos: TRxDbGrid;
    ActionToolBar1: TToolPanel;
    ComboBoxTipoBaixa: TLabeledComboBox;
    PanelTotaisRecebidos: TPanel;
    ActionExcluirParcela: TAction;
    procedure FormCreate(Sender: TObject);
    procedure ActionBaixarParcelaExecute(Sender: TObject);
    procedure CalcularTotalRecebido(Sender: TObject);
    procedure BotaoConsultarClick(Sender: TObject);
    procedure BotaoSalvarClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure BaixarParcela;
    procedure BaixarParcelaCheque;
    procedure CalcularTotais;
    procedure GridCellClick(Column: TColumn);
//    procedure GridDrawColumnCell(Sender: TObject; const Rect: TRect; DataCol: Integer; Column: TColumn; State: TGridDrawState);
    function VerificarPacoteRecebimentoCheque: Boolean;
    procedure EditIdTipoRecebimentoKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
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
  FFinParcelaRecebimento: TFFinParcelaRecebimento;
  ChequeRecebido: TFinChequeRecebidoVO;
  SomaCheque: Extended;
  AdmParametroVO: TAdmParametroVO;

implementation

uses
  FinParcelaRecebimentoVO, FinParcelaRecebimentoController, FinParcelaReceberVO,
  FinParcelaReceberController, FinTipoRecebimentoVO, FinTipoRecebimentoController,
  ContaCaixaVO, ContaCaixaController, UTela, USelecionaCheque, UDataModule,
  AdmParametroController;

{$R *.lfm}

{$REGION 'Infra'}
procedure TFFinParcelaRecebimento.BotaoConsultarClick(Sender: TObject);
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
    RetornoConsulta := TViewFinLancamentoReceberController.Consulta(Filtro, IntToStr(Pagina));
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

procedure TFFinParcelaRecebimento.BotaoSalvarClick(Sender: TObject);
begin
  inherited;
  BotaoConsultarClick(Sender);
end;

procedure TFFinParcelaRecebimento.FormCreate(Sender: TObject);
var
  Filtro: String;
begin
  ClasseObjetoGridVO := TViewFinLancamentoReceberVO;
  ObjetoController := TViewFinLancamentoReceberController.Create;

  inherited;

  Filtro := 'ID_EMPRESA = ' + IntToStr(Sessao.Empresa.Id);
  AdmParametroVO := TAdmParametroController.ConsultaObjeto(Filtro);

  ConfiguraCDSFromVO(CDSParcelaRecebimento, TFinParcelaRecebimentoVO);
end;

procedure TFFinParcelaRecebimento.FormShow(Sender: TObject);
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

procedure TFFinParcelaRecebimento.LimparCampos;
var
  DataInicioInformada, DataFimInformada: TDateTime;
begin
  DataInicioInformada := EditDataInicio.Date;
  DataFimInformada := EditDataFim.Date;
  inherited;
  CDSParcelaRecebimento.Close;
  CDSParcelaRecebimento.Open;

  EditDataInicio.Date := DataInicioInformada;
  EditDataFim.Date := DataFimInformada;
end;
{$ENDREGION}

{$REGION 'Controles CRUD'}
function TFFinParcelaRecebimento.DoEditar: Boolean;
begin
  if not CDSGrid.IsEmpty then
  begin

    if CDSGrid.FieldByName('SITUACAO_PARCELA').AsString = '02' then
    begin
      Application.MessageBox('Procedimento não permitido. Parcela já quitada.', 'Mensagem do Sistema', MB_OK + MB_ICONINFORMATION);
      Exit;
    end;

    if VerificarPacoteRecebimentoCheque then
    begin
      ChequeRecebido := TFinChequeRecebidoVO.Create;

      Application.CreateForm(TFSelecionaCheque, FSelecionaCheque);
      FSelecionaCheque.EditValorCheque.Value := SomaCheque;
      FSelecionaCheque.EditDataEmissao.Date := Now;

      FSelecionaCheque.ShowModal;

      if FSelecionaCheque.Confirmou then
      begin
        ChequeRecebido.IdPessoa := FSelecionaCheque.EditIdPessoa.AsInteger;
        ChequeRecebido.Nome := FSelecionaCheque.EditPessoa.Text;
        ChequeRecebido.CpfCnpj := FSelecionaCheque.EditCpfCnpj.Text;
        ChequeRecebido.CodigoBanco := FSelecionaCheque.EditCodigoBanco.Text;
        ChequeRecebido.CodigoAgencia := FSelecionaCheque.EditCodigoAgencia.Text;
        ChequeRecebido.Conta := FSelecionaCheque.EditNumeroConta.Text;
        ChequeRecebido.Numero := FSelecionaCheque.EditNumeroCheque.AsInteger;
        ChequeRecebido.DataEmissao := FSelecionaCheque.EditDataEmissao.Date;
        ChequeRecebido.Valor := FSelecionaCheque.EditValorCheque.Value;
        ChequeRecebido.BomPara := FSelecionaCheque.EditBomPara.Date;
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

function TFFinParcelaRecebimento.VerificarPacoteRecebimentoCheque: Boolean;
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
procedure TFFinParcelaRecebimento.EditIdTipoRecebimentoKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  Filtro: String;
  FinTipoRecebimentoVO :TFinTipoRecebimentoVO ;
begin
  if Key = VK_F1 then
  begin
    if EditIdTipoRecebimento.Value <> 0 then
      Filtro := 'ID = ' + EditIdTipoRecebimento.Text
    else
      Filtro := 'ID=0';

    try
      EditCodigoTipoRecebimento.Clear;
      EditTipoRecebimento.Clear;

        FinTipoRecebimentoVO := TFinTipoRecebimentoController.ConsultaObjeto(Filtro);
        if Assigned(FinTipoRecebimentoVO) then
      begin
        EditCodigoTipoRecebimento.Text := FinTipoRecebimentoVO.Tipo;
        EditTipoRecebimento.Text := FinTipoRecebimentoVO.Descricao;
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

procedure TFFinParcelaRecebimento.EditIdContaCaixaKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
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
procedure TFFinParcelaRecebimento.GridCellClick(Column: TColumn);
begin
  if Column.Index = 1 then
  begin
    if CDSGrid.FieldByName('SITUACAO_PARCELA').AsString = '02' then
    begin
      Application.MessageBox('Procedimento não permitido. Parcela já quitada.', 'Mensagem do Sistema', MB_OK + MB_ICONINFORMATION);
      Exit;
    end
    else
    begin
      CDSGrid.Edit;
      if CDSGrid.FieldByName('EmitirCheque').AsString = '' then
        CDSGrid.FieldByName('EmitirCheque').AsString := 'S'
      else
        CDSGrid.FieldByName('EmitirCheque').AsString := '';
      CDSGrid.Post;
    end;
  end;
end;
{
procedure TFFinParcelaRecebimento.GridDrawColumnCell(Sender: TObject; const Rect: TRect; DataCol: Integer; Column: TColumn; State: TGridDrawState);
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
procedure TFFinParcelaRecebimento.GridParaEdits;
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
    ObjetoVO := TViewFinLancamentoReceberController.ConsultaObjeto('ID=' + IdCabecalho);
  end;

  if Assigned(ObjetoVO) then
  begin

    EditIdContaCaixa.AsInteger := TViewFinLancamentoReceberVO(ObjetoVO).IdContaCaixa;
    EditContaCaixa.Text := TViewFinLancamentoReceberVO(ObjetoVO).NomeContaCaixa;
    EditDataVencimento.Date := TViewFinLancamentoReceberVO(ObjetoVO).DataVencimento;
    EditValorAReceber.Value := TViewFinLancamentoReceberVO(ObjetoVO).ValorParcela;
    EditTaxaJuro.Value := TViewFinLancamentoReceberVO(ObjetoVO).TaxaJuro;
    EditValorJuro.Value := TViewFinLancamentoReceberVO(ObjetoVO).ValorJuro;
    EditTaxaMulta.Value := TViewFinLancamentoReceberVO(ObjetoVO).TaxaMulta;
    EditValorMulta.Value := TViewFinLancamentoReceberVO(ObjetoVO).ValorMulta;
    EditTaxaDesconto.Value := TViewFinLancamentoReceberVO(ObjetoVO).TaxaDesconto;
    EditValorDesconto.Value := TViewFinLancamentoReceberVO(ObjetoVO).ValorDesconto;
    CalcularTotalRecebido(nil);

    CDSParcelaRecebimento.Close;
    CDSParcelaRecebimento.Open;

    Filtro := 'ID_FIN_PARCELA_Receber=' + QuotedStr(IntToStr(CDSGrid.FieldByName('ID_PARCELA_Receber').AsInteger));
    ListaCampos  := TStringList.Create;
    RetornoConsulta := TFinParcelaRecebimentoController.Consulta(Filtro, '0');
    RetornoConsulta.Active := True;

    RetornoConsulta.GetFieldNames(ListaCampos);

    RetornoConsulta.First;
    while not RetornoConsulta.EOF do begin
      CDSParcelaRecebimento.Append;
      for i := 0 to ListaCampos.Count - 1 do
      begin
        CDSParcelaRecebimento.FieldByName(ListaCampos[i]).Value := RetornoConsulta.FieldByName(ListaCampos[i]).Value;
      end;
      CDSParcelaRecebimento.Post;
      RetornoConsulta.Next;
    end;

    CalcularTotais;
  end;
end;
{$ENDREGION}

{$REGION 'Actions'}
procedure TFFinParcelaRecebimento.ActionBaixarParcelaExecute(Sender: TObject);
begin
  if EditIdTipoRecebimento.AsInteger <= 0 then
  begin
    Application.MessageBox('É necessário informar o tipo de Recebimento.', 'Mensagem do Sistema', MB_OK + MB_ICONINFORMATION);
    EditIdTipoRecebimento.SetFocus;
    Exit;
  end;
  if EditIdContaCaixa.AsInteger <= 0 then
  begin
    Application.MessageBox('É necessário informar a conta caixa.', 'Mensagem do Sistema', MB_OK + MB_ICONINFORMATION);
    EditIdContaCaixa.SetFocus;
    Exit;
  end;

  ChequeRecebido := TFinChequeRecebidoVO.Create;

  if EditCodigoTipoRecebimento.Text = '02' then
  begin
  Application.CreateForm(TFSelecionaCheque, FSelecionaCheque);
  FSelecionaCheque.EditDataEmissao.Date := Now;
  FSelecionaCheque.EditBomPara.Date := EditDataRecebimento.Date;
  FSelecionaCheque.EditValorCheque.Value := EditValorRecebido.Value;
  FSelecionaCheque.MemoHistorico.Text := MemoHistorico.Text;
  FSelecionaCheque.EditIdContaCaixa.AsInteger := EditIdContaCaixa.AsInteger;
  FSelecionaCheque.EditContaCaixa.Text := EditContaCaixa.Text;
  FSelecionaCheque.ShowModal;

    if FSelecionaCheque.Confirmou then
    begin
    ChequeRecebido.IdPessoa := FSelecionaCheque.EditIdPessoa.AsInteger;
    ChequeRecebido.Nome := FSelecionaCheque.EditPessoa.Text;
    ChequeRecebido.CpfCnpj := FSelecionaCheque.EditCpfCnpj.Text;
    ChequeRecebido.CodigoBanco := FSelecionaCheque.EditCodigoBanco.Text;
    ChequeRecebido.CodigoAgencia := FSelecionaCheque.EditCodigoAgencia.Text;
    ChequeRecebido.Conta := FSelecionaCheque.EditNumeroConta.Text;
    ChequeRecebido.Numero := FSelecionaCheque.EditNumeroCheque.AsInteger;
    ChequeRecebido.DataEmissao := FSelecionaCheque.EditDataEmissao.Date;
    ChequeRecebido.Valor := FSelecionaCheque.EditValorCheque.Value;
    ChequeRecebido.BomPara := FSelecionaCheque.EditBomPara.Date;
    BaixarParcela;
    FreeAndNil(FSelecionaCheque);
    end;
  end
  else
    BaixarParcela;
end;

procedure TFFinParcelaRecebimento.ActionExcluirParcelaExecute(Sender: TObject);
var
  ParcelaReceber: TFinParcelaReceberVO;
begin
  /// EXERCICIO: VERIFIQUE SE A IMPLEMENTAÇÃO ESTÁ CORRETA. CORRIJA O QUE FOR NECESSÁRIO.

  if CDSParcelaRecebimentoID.AsInteger > 0 then
    TFinParcelaRecebimentoController.Exclui(CDSParcelaRecebimento.FieldByName('ID').AsInteger);
  CDSParcelaRecebimento.Delete;

  if CDSParcelaRecebimento.IsEmpty then
  begin
    ParcelaReceber := TFinParcelaReceberController.ConsultaObjeto('ID=' + CDSGrid.FieldByName('ID_PARCELA_Receber').AsString);
    ParcelaReceber.IdFinStatusParcela := AdmParametroVO.FinParcelaAberto;
    TFinParcelaReceberController.Altera(ParcelaReceber);
  end;
  CalcularTotais;
end;

procedure TFFinParcelaRecebimento.BaixarParcela;
var
  ParcelaReceber: TFinParcelaReceberVO;
  RetornoConsulta: TZQuery;
  ListaCampos: TStringList;
  I: Integer;
begin
  ParcelaReceber := TFinParcelaReceberController.ConsultaObjeto('ID=' + CDSGrid.FieldByName('ID_PARCELA_Receber').AsString);

  if ComboBoxTipoBaixa.ItemIndex = 0 then
    ParcelaReceber.IdFinStatusParcela := AdmParametroVO.FinParcelaQuitado
  else if ComboBoxTipoBaixa.ItemIndex = 1 then
    ParcelaReceber.IdFinStatusParcela := AdmParametroVO.FinParcelaQuitadoParcial;

  ParcelaReceber.FinParcelaRecebimentoVO := TFinParcelaRecebimentoVO.Create;

  ParcelaReceber.FinParcelaRecebimentoVO.IdFinTipoRecebimento := EditIdTipoRecebimento.AsInteger;
  ParcelaReceber.FinParcelaRecebimentoVO.IdFinParcelaReceber := ParcelaReceber.Id;
  ParcelaReceber.FinParcelaRecebimentoVO.IdContaCaixa := EditIdContaCaixa.AsInteger;
  ParcelaReceber.FinParcelaRecebimentoVO.DataRecebimento := EditDataRecebimento.Date;
  ParcelaReceber.FinParcelaRecebimentoVO.TaxaJuro := EditTaxaJuro.Value;
  ParcelaReceber.FinParcelaRecebimentoVO.ValorJuro := EditValorJuro.Value;
  ParcelaReceber.FinParcelaRecebimentoVO.TaxaMulta := EditTaxaMulta.Value;
  ParcelaReceber.FinParcelaRecebimentoVO.ValorMulta := EditValorMulta.Value;
  ParcelaReceber.FinParcelaRecebimentoVO.TaxaDesconto := EditTaxaDesconto.Value;
  ParcelaReceber.FinParcelaRecebimentoVO.ValorDesconto := EditValorDesconto.Value;
  ParcelaReceber.FinParcelaRecebimentoVO.Historico := Trim(MemoHistorico.Text);
  ParcelaReceber.FinParcelaRecebimentoVO.ValorRecebido := EditValorRecebido.Value;

  ParcelaReceber.FinChequeRecebidoVO := ChequeRecebido;

  TFinParcelaReceberController.Altera(ParcelaReceber);


  CDSParcelaRecebimento.Close;
  CDSParcelaRecebimento.Open;

  Filtro := 'ID_FIN_PARCELA_Receber=' + QuotedStr(IntToStr(CDSGrid.FieldByName('ID_PARCELA_Receber').AsInteger));
  ListaCampos  := TStringList.Create;
  RetornoConsulta := TFinParcelaRecebimentoController.Consulta(Filtro, '0');
  RetornoConsulta.Active := True;

  RetornoConsulta.GetFieldNames(ListaCampos);

  RetornoConsulta.First;
  while not RetornoConsulta.EOF do begin
    CDSParcelaRecebimento.Append;
    for i := 0 to ListaCampos.Count - 1 do
    begin
      CDSParcelaRecebimento.FieldByName(ListaCampos[i]).Value := RetornoConsulta.FieldByName(ListaCampos[i]).Value;
    end;
    CDSParcelaRecebimento.Post;
    RetornoConsulta.Next;
  end;

  CalcularTotais;
end;

procedure TFFinParcelaRecebimento.BaixarParcelaCheque;
var
  ParcelaReceber, ObjetoPersistencia: TFinParcelaReceberVO;
  ParcelaRecebimento: TFinParcelaRecebimentoVO;
  ListaParcelaReceber: TListaFinParcelaReceberVO;
  ListaParcelaRecebimento: TListaFinParcelaRecebimentoVO;
begin
  try
    ListaParcelaReceber := TListaFinParcelaReceberVO.Create;
    ListaParcelaRecebimento := TListaFinParcelaRecebimentoVO.Create;

    CDSGrid.DisableControls;
    CDSGrid.First;
    while not CDSGrid.Eof do
    begin
      if CDSGrid.FieldByName('EmitirCheque').AsString = 'S' then
      begin
        ParcelaReceber := TFinParcelaReceberController.ConsultaObjeto('ID=' + CDSGrid.FieldByName('ID_PARCELA_Receber').AsString);
        ParcelaReceber.IdFinStatusParcela := AdmParametroVO.FinParcelaQuitado;

        ParcelaRecebimento := TFinParcelaRecebimentoVO.Create;
        ParcelaRecebimento.IdFinTipoRecebimento := AdmParametroVO.FinTipoRecebimentoEdi;
        ParcelaRecebimento.IdFinParcelaReceber := ParcelaReceber.Id;
        ParcelaRecebimento.IdContaCaixa := FSelecionaCheque.EditIdContaCaixa.AsInteger;
        ParcelaRecebimento.DataRecebimento := FSelecionaCheque.EditBomPara.Date;
        ParcelaRecebimento.Historico := FSelecionaCheque.MemoHistorico.Text;
        ParcelaRecebimento.ValorRecebido := ParcelaReceber.Valor;

        ListaParcelaReceber.Add(ParcelaReceber);
        ListaParcelaRecebimento.Add(ParcelaRecebimento);
      end;
      CDSGrid.Next;
    end;
    CDSGrid.First;
    CDSGrid.EnableControls;

    ObjetoPersistencia := TFinParcelaReceberVO.Create;
//    ObjetoPersistencia.ListaParcelaReceberVO := ListaParcelaReceber;
    ObjetoPersistencia.ListaParcelaRecebimentoVO := ListaParcelaRecebimento;
    ObjetoPersistencia.FinChequeRecebidoVO := ChequeRecebido;

    TFinParcelaReceberController.BaixarParcelaCheque(ObjetoPersistencia);

    BotaoConsultar.Click;
  finally
  end;
end;

/// EXERCICIO: LEVE EM CONSIDERACAO O STATUS DA PARCELA

function TFFinParcelaRecebimento.MontaFiltro: string;
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

procedure TFFinParcelaRecebimento.CalcularTotalRecebido(Sender: TObject);
begin
  EditValorJuro.Value := (EditValorAReceber.Value * (EditTaxaJuro.Value / 30) / 100) * (Now - EditDataVencimento.Date);
  EditValorMulta.Value := EditValorAReceber.Value * (EditTaxaMulta.Value / 100);
  EditValorDesconto.Value := EditValorAReceber.Value * (EditTaxaDesconto.Value / 100);
  EditValorRecebido.Value := EditValorAReceber.Value + EditValorJuro.Value + EditValorMulta.Value - EditValorDesconto.Value;
end;

procedure TFFinParcelaRecebimento.CalcularTotais;
var
  Juro, Multa, Desconto, Total, Saldo: Extended;
begin
  Juro := 0;
  Multa := 0;
  Desconto := 0;
  Total := 0;
  Saldo := 0;
  //
  CDSParcelaRecebimento.DisableControls;
  CDSParcelaRecebimento.First;
  while not CDSParcelaRecebimento.Eof do
  begin
    Juro := Juro + CDSParcelaRecebimento.FieldByName('VALOR_JURO').AsFloat;
    Multa := Multa + CDSParcelaRecebimento.FieldByName('VALOR_MULTA').AsFloat;
    Desconto := Desconto + CDSParcelaRecebimento.FieldByName('VALOR_DESCONTO').AsFloat;
    Total := Total + CDSParcelaRecebimento.FieldByName('VALOR_Recebido').AsFloat;
    CDSParcelaRecebimento.Next;
  end;
  CDSParcelaRecebimento.First;
  CDSParcelaRecebimento.EnableControls;
  //
  PanelTotaisRecebidos.Caption := '|      Juros: ' +  FloatToStrF(Juro, ffCurrency, 15, 2) +
                        '      |      Multa: ' +   FloatToStrF(Multa, ffCurrency, 15, 2) +
                        '      |      Desconto: ' +   FloatToStrF(Desconto, ffCurrency, 15, 2) +
                        '      |      Total Recebido: ' +   FloatToStrF(Total, ffCurrency, 15, 2) +
                        '      |      Saldo: ' +   FloatToStrF(Total - EditValorAReceber.Value, ffCurrency, 15, 2) + '      |';
end;
{$ENDREGION}

end.

