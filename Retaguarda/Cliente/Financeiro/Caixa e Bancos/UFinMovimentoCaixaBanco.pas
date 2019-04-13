{ *******************************************************************************
Title: T2Ti ERP
Description: Janela de Movimento Caixa/Banco

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
unit UFinMovimentoCaixaBanco;

{$MODE Delphi}

interface

uses
  BrookHTTPClient, BrookFCLHTTPClientBroker, BrookHTTPUtils, BrookUtils, FPJson, ZDataset,
  LCLIntf, LCLType, LMessages, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UTelaCadastro, Menus, StdCtrls, ExtCtrls, Buttons, Grids, DBGrids,
  ComCtrls, LabeledCtrls, rxdbgrid, rxtoolbar, DBCtrls, StrUtils,
  Math, Constantes, CheckLst, ActnList, ToolWin, maskedit, db, BufDataset, Biblioteca,
  ULookup, VO, ViewFinMovimentoCaixaBancoVO,
  ViewFinMovimentoCaixaBancoController, FinFechamentoCaixaBancoVO;

  type

  { TFFinMovimentoCaixaBanco }

  TFFinMovimentoCaixaBanco = class(TFTelaCadastro)
    BevelEdits: TBevel;
    CDSMovimentoCaixaBanco: TBufDataset;
    PanelEditsInterno: TPanel;
    DSMovimentoCaixaBanco: TDataSource;
    EditIdContaCaixa: TLabeledCalcEdit;
    EditContaCaixa: TLabeledEdit;
    GroupBox1: TGroupBox;
    PanelGridInterna: TPanel;
    GridPagamentos: TRxDbGrid;
    PanelTotais: TPanel;
    PanelTotaisGeral: TPanel;
    ActionManager1: TActionList;
    ActionProcessarFechamento: TAction;
    ActionToolBar1: TToolPanel;
    EditMesAno: TMaskEdit;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure CalcularTotais;
    procedure CalcularTotaisGeral;
    procedure ActionProcessarFechamentoExecute(Sender: TObject);
    procedure BotaoConsultarClick(Sender: TObject);
    procedure BotaoSalvarClick(Sender: TObject);
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
  FFinMovimentoCaixaBanco: TFFinMovimentoCaixaBanco;
  Recebimentos, Pagamentos, Saldo: Extended;
  FechamentoVO: TFinFechamentoCaixaBancoVO;

implementation

uses
  UTela, UDataModule, FinFechamentoCaixaBancoController, ViewFinChequeNaoCompensadoVO,
  ViewFinChequeNaoCompensadoController;

{$R *.lfm}

{$REGION 'Infra'}
procedure TFFinMovimentoCaixaBanco.BotaoConsultarClick(Sender: TObject);
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
    RetornoConsulta := TViewFinMovimentoCaixaBancoController.Consulta(Filtro, IntToStr(Pagina));
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

  CalcularTotaisGeral;
end;

procedure TFFinMovimentoCaixaBanco.BotaoSalvarClick(Sender: TObject);
begin
  inherited;
  BotaoConsultarClick(Sender);
end;

procedure TFFinMovimentoCaixaBanco.FormCreate(Sender: TObject);
begin
  ClasseObjetoGridVO := TViewFinMovimentoCaixaBancoVO;
  ObjetoController := TViewFinMovimentoCaixaBancoController.Create;

  inherited;

  ConfiguraCDSFromVO(CDSMovimentoCaixaBanco, TViewFinMovimentoCaixaBancoVO);
end;

procedure TFFinMovimentoCaixaBanco.FormShow(Sender: TObject);
begin
  inherited;
  EditMesAno.Text := Copy(DateTimeToStr(Date), 4, 7);

  BotaoInserir.Visible := False;
  BotaoExcluir.Visible := False;
  BotaoCancelar.Visible := False;
  BotaoAlterar.Caption := 'Filtrar Conta [F3]';
  BotaoAlterar.Hint := 'Filtrar Conta [F3]';
  BotaoAlterar.Width := 120;
  BotaoSalvar.Caption := 'Retornar [F12]';
  BotaoSalvar.Hint := 'Retornar [F12]';

  MenuInserir.Visible := False;
  MenuExcluir.Visible := False;
  MenuCancelar.Visible := False;
  MenuAlterar.Caption := 'Filtrar Conta [F3]';
  menuSalvar.Caption := 'Retornar [F12]';
end;

procedure TFFinMovimentoCaixaBanco.LimparCampos;
var
  MesAnoInformado: String;
begin
  MesAnoInformado := EditMesAno.Text;
  inherited;
  CDSMovimentoCaixaBanco.Close;
  CDSMovimentoCaixaBanco.Open;
  EditMesAno.Text := MesAnoInformado;
end;
{$ENDREGION}

{$REGION 'Controles CRUD'}
function TFFinMovimentoCaixaBanco.DoEditar: Boolean;
begin
  Result := inherited DoEditar;
  if Result then
  begin
    EditIdContaCaixa.SetFocus;
  end;
end;
{$ENDREGION}

{$REGION 'Controle de Grid'}
procedure TFFinMovimentoCaixaBanco.GridParaEdits;
var
  IdCabecalho: String;
  FiltroLocal: String;
  RetornoConsulta: TZQuery;
  ListaCampos: TStringList;
  I: Integer;
begin
  inherited;

  EditIdContaCaixa.AsInteger := CDSGrid.FieldByName('ID_CONTA_CAIXA').AsInteger;
  EditContaCaixa.Text := CDSGrid.FieldByName('NOME_CONTA_CAIXA').AsString;

  //
  FiltroLocal := 'ID_CONTA_CAIXA=' + QuotedStr(EditIdContaCaixa.Text) + ' and extract(month from(DATA_PAGO_RECEBIDO))=' + Copy(EditMesAno.Text, 1, 2) + ' and extract(year from(DATA_PAGO_RECEBIDO))=' + Copy(EditMesAno.Text, 4, 4);
  ListaCampos  := TStringList.Create;
  RetornoConsulta := TViewFinMovimentoCaixaBancoController.Consulta(Filtro, '0');
  RetornoConsulta.Active := True;

  RetornoConsulta.GetFieldNames(ListaCampos);

  RetornoConsulta.First;
  while not RetornoConsulta.EOF do begin
    CDSMovimentoCaixaBanco.Append;
    for i := 0 to ListaCampos.Count - 1 do
    begin
      CDSMovimentoCaixaBanco.FieldByName(ListaCampos[i]).Value := RetornoConsulta.FieldByName(ListaCampos[i]).Value;
    end;
    CDSMovimentoCaixaBanco.Post;
    RetornoConsulta.Next;
  end;
  //
  FiltroLocal := 'MES_ANO=' + QuotedStr(EditMesAno.Text) + ' and ' + 'ID_CONTA_CAIXA=' + QuotedStr(EditIdContaCaixa.Text);
  FechamentoVO := TFinFechamentoCaixaBancoController.ConsultaObjeto(FiltroLocal);
  //
  CalcularTotais;
end;
{$ENDREGION}

{$REGION 'Actions'}
procedure TFFinMovimentoCaixaBanco.ActionProcessarFechamentoExecute(Sender: TObject);
var
  FiltroLocal: String;
  FechamentoAnteriorVO: TFinFechamentoCaixaBancoVO;
  SaldoAnterior, ChequesNaoCompensados: Extended;
  CDSChequeNaoCompensado: TZQuery;
  I: Integer;
begin
  SaldoAnterior := 0;
  Pagamentos := 0;
  Recebimentos := 0;
  ChequesNaoCompensados := 0;

  if Application.MessageBox('Deseja processar o fechamento?', 'Pergunta do Sistema', MB_YesNo + MB_IconQuestion) = IdYes then
  begin
    FiltroLocal := 'MES_ANO=' + QuotedStr(PeriodoAnterior(EditMesAno.Text)) + ' and ' + 'ID_CONTA_CAIXA=' + QuotedStr(EditIdContaCaixa.Text);
    FechamentoAnteriorVO := TFinFechamentoCaixaBancoController.ConsultaObjeto(FiltroLocal);

    if Assigned(FechamentoAnteriorVO) then
      SaldoAnterior := FechamentoAnteriorVO.SaldoDisponivel
    else
      SaldoAnterior := 0;

    CDSChequeNaoCompensado := TViewFinChequeNaoCompensadoController.Consulta('ID_CONTA_CAIXA=' + QuotedStr(EditIdContaCaixa.Text), '0');
    CDSChequeNaoCompensado.Active := True;

    CDSChequeNaoCompensado.First;
    while not CDSChequeNaoCompensado.Eof do
    begin
      ChequesNaoCompensados := ChequesNaoCompensados + CDSChequeNaoCompensado.FieldByName('VALOR').AsFloat;
      CDSChequeNaoCompensado.Next;
    end;
    CDSChequeNaoCompensado.First;

    CDSMovimentoCaixaBanco.DisableControls;
    CDSMovimentoCaixaBanco.First;
    while not CDSMovimentoCaixaBanco.Eof do
    begin
      if CDSMovimentoCaixaBanco.FieldByName('OPERACAO').AsString = 'S' then
        Pagamentos := Pagamentos + CDSMovimentoCaixaBanco.FieldByName('VALOR').AsFloat
      else if CDSMovimentoCaixaBanco.FieldByName('OPERACAO').AsString = 'E' then
        Recebimentos := Recebimentos + CDSMovimentoCaixaBanco.FieldByName('VALOR').AsFloat;
      CDSMovimentoCaixaBanco.Next;
    end;
    CDSMovimentoCaixaBanco.First;
    CDSMovimentoCaixaBanco.EnableControls;

    if not Assigned(FechamentoVO) then
      FechamentoVO := TFinFechamentoCaixaBancoVO.Create;

    FechamentoVO.IdContaCaixa := EditIdContaCaixa.AsInteger;
    FechamentoVO.DataFechamento := Now;
    FechamentoVO.MesAno := EditMesAno.Text;
    FechamentoVO.Mes := Copy(EditMesAno.Text, 1, 2);
    FechamentoVO.Ano := Copy(EditMesAno.Text, 4, 4);
    FechamentoVO.SaldoAnterior := SaldoAnterior;
    FechamentoVO.Recebimentos := Recebimentos;
    FechamentoVO.Pagamentos := Pagamentos;
    FechamentoVO.SaldoConta := SaldoAnterior + Recebimentos - Pagamentos;
    FechamentoVO.ChequeNaoCompensado := ChequesNaoCompensados;
    FechamentoVO.SaldoDisponivel := SaldoAnterior + Recebimentos - Pagamentos - ChequesNaoCompensados;

    if FechamentoVO.Id > 0 then
      TFinFechamentoCaixaBancoController.Altera(TFinFechamentoCaixaBancoVO(FechamentoVO))
    else
      TFinFechamentoCaixaBancoController.Insere(TFinFechamentoCaixaBancoVO(ObjetoVO));

    FiltroLocal := 'MES_ANO=' + QuotedStr(EditMesAno.Text) + ' and ' + 'ID_CONTA_CAIXA=' + QuotedStr(EditIdContaCaixa.Text);
    FechamentoVO := TFinFechamentoCaixaBancoController.ConsultaObjeto(FiltroLocal);

    CalcularTotais;
  end;
end;

function TFFinMovimentoCaixaBanco.MontaFiltro: string;
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

    Result := 'extract(month from(DATA_PAGO_RECEBIDO))=' + Copy(EditMesAno.Text, 1, 2) + ' and extract(year from(DATA_PAGO_RECEBIDO))=' + Copy(EditMesAno.Text, 4, 4) + ' and ' + Item.Campo + ' LIKE ' + QuotedStr('%' + EditCriterioRapido.Text + '%');
  end
  else
  begin
    Result := ' 1=1 ';
  end;
end;

procedure TFFinMovimentoCaixaBanco.CalcularTotais;
begin
  if Assigned(FechamentoVO) then
  begin
    PanelTotais.Caption :=

    '|      SaldoAnterior: ' +  FloatToStrF(FechamentoVO.SaldoAnterior, ffCurrency, 15, 2) +
    '      |      Recebimentos: ' +   FloatToStrF(FechamentoVO.Recebimentos, ffCurrency, 15, 2) +
    '      |      Pagamentos: ' +   FloatToStrF(FechamentoVO.Pagamentos, ffCurrency, 15, 2) +
    '      |      Saldo Conta: ' +   FloatToStrF(FechamentoVO.SaldoConta, ffCurrency, 15, 2) +
    '      |      Cheque não Compensado: ' +   FloatToStrF(FechamentoVO.ChequeNaoCompensado, ffCurrency, 15, 2) +
    '      |      Saldo Disponível: ' +   FloatToStrF(FechamentoVO.SaldoDisponivel, ffCurrency, 15, 2) + '      |';

  end
  else
    PanelTotais.Caption := 'Fechamento não realizado.';
end;

procedure TFFinMovimentoCaixaBanco.CalcularTotaisGeral;
begin
  Recebimentos := 0;
  Pagamentos := 0;
  Saldo := 0;
  //
  CDSGrid.DisableControls;
  CDSGrid.First;
  while not CDSGrid.Eof do
  begin
    if CDSGrid.FieldByName('OPERACAO').AsString = 'S' then
      Pagamentos := Pagamentos + CDSGrid.FieldByName('VALOR').AsFloat
    else if CDSGrid.FieldByName('OPERACAO').AsString = 'E' then
      Recebimentos := Recebimentos + CDSGrid.FieldByName('VALOR').AsFloat;
    CDSGrid.Next;
  end;
  CDSGrid.First;
  CDSGrid.EnableControls;
  //
  PanelTotaisGeral.Caption := '|      Recebimentos: ' +  FloatToStrF(Recebimentos, ffCurrency, 15, 2) +
                        '      |      Pagamentos: ' +   FloatToStrF(Pagamentos, ffCurrency, 15, 2) +
                        '      |      Saldo: ' +   FloatToStrF(Recebimentos - Pagamentos, ffCurrency, 15, 2) + '      |';
end;
{$ENDREGION}

end.

