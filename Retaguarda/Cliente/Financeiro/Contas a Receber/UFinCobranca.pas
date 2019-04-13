{ *******************************************************************************
Title: T2Ti ERP
Description: Janela Cobrança

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
unit UFinCobranca;

{$MODE Delphi}

interface

uses
  BrookHTTPClient, BrookFCLHTTPClientBroker, BrookHTTPUtils, BrookUtils, FPJson, ZDataset,
  LCLIntf, LCLType, LMessages, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UTelaCadastro, Menus, StdCtrls, ExtCtrls, Buttons, Grids, DBGrids,
  ComCtrls, LabeledCtrls, rxdbgrid, rxtoolbar, DBCtrls, StrUtils,
  Math, Constantes, CheckLst, ActnList, ToolWin, db, BufDataset, Biblioteca,
  ULookup, VO, FinCobrancaVO,
  FinCobrancaController;

  type

  { TFFinCobranca }

  TFFinCobranca = class(TFTelaCadastro)
    ActionManager: TActionList;
    ActionConsultarParcelas: TAction;
    CDSParcelaReceber: TBufDataset;
    CDSParcelasVencidas: TBufDataset;
    PanelParcelas: TPanel;
    PanelMestre: TPanel;
    EditIdCliente: TLabeledCalcEdit;
    EditCliente: TLabeledEdit;
    EditDataAcertoPagamento: TLabeledDateEdit;
    EditValorTotal: TLabeledCalcEdit;
    EditDataContato: TLabeledDateEdit;
    DSParcelaReceber: TDataSource;
    EditHoraContato: TLabeledMaskEdit;
    ActionMarcarDataHoraContato: TAction;
    EditTelefoneContato: TLabeledMaskEdit;
    PageControlItensLancamento: TPageControl;
    tsParcelasSimuladoAcordo: TTabSheet;
    PanelItensLancamento: TPanel;
    GridParcelas: TRxDbGrid;
    tsParcelasVencidas: TTabSheet;
    PanelParcelasVencidas: TPanel;
    GridParcelasVencidas: TRxDbGrid;
    DSParcelasVencidas: TDataSource;
    ActionToolBar2: TToolPanel;
    ActionCalcularMultaJuros: TAction;
    EditValorTotalJuros: TLabeledCalcEdit;
    EditValorTotalMulta: TLabeledCalcEdit;
    EditValorTotalAtrasado: TLabeledCalcEdit;
    ActionSimularValores: TAction;
    ActionGeraNovoLancamento: TAction;
    procedure FormCreate(Sender: TObject);
    procedure GridDblClick(Sender: TObject);
    procedure GridParcelasKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure CDSParcelaReceberBeforeDelete(DataSet: TDataSet);
    procedure CDSParcelaReceberAfterPost(DataSet: TDataSet);
    procedure EditIdClienteKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure ActionMarcarDataHoraContatoExecute(Sender: TObject);
    procedure ActionConsultarParcelasExecute(Sender: TObject);
    procedure ActionCalcularMultaJurosExecute(Sender: TObject);
    procedure CDSParcelasVencidasBeforePost(DataSet: TDataSet);
    procedure ActionSimularValoresExecute(Sender: TObject);
    procedure CDSParcelaReceberBeforePost(DataSet: TDataSet);
    procedure ActionGeraNovoLancamentoExecute(Sender: TObject);
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
  end;

var
  FFinCobranca: TFFinCobranca;

implementation

uses UDataModule, PessoaVO, PessoaController,
  FinParcelaReceberVO, FinParcelaReceberController, ContaCaixaVO, ContaCaixaController,
  ViewPessoaClienteVO, ViewPessoaClienteController, FinCobrancaParcelaReceberVO,
  ViewFinLancamentoReceberVO, ViewFinLancamentoReceberController;
{$R *.lfm}

{$REGION 'Infra'}
procedure TFFinCobranca.BotaoConsultarClick(Sender: TObject);
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
    RetornoConsulta := TFinCobrancaController.Consulta(Filtro, IntToStr(Pagina));
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

procedure TFFinCobranca.BotaoSalvarClick(Sender: TObject);
begin
  inherited;
  BotaoConsultarClick(Sender);
end;

procedure TFFinCobranca.FormCreate(Sender: TObject);
var
  Filtro: String;
begin
  ClasseObjetoGridVO := TFinCobrancaVO;
  ObjetoController := TFinCobrancaController.Create;

  inherited;

  // Configura a Grid das parcelas vencidas
  ConfiguraCDSFromVO(CDSParcelasVencidas, TViewFinLancamentoReceberVO);
  ConfiguraGridFromVO(GridParcelasVencidas, TViewFinLancamentoReceberVO);
end;

procedure TFFinCobranca.LimparCampos;
begin
  inherited;
  CDSParcelaReceber.Close;
  CDSParcelaReceber.Open;
end;

procedure TFFinCobranca.ConfigurarLayoutTela;
begin
  PanelEdits.Enabled := True;

  if StatusTela = stNavegandoEdits then
  begin
    PanelMestre.Enabled := False;
    PanelItensLancamento.Enabled := False;
  end
  else
  begin
    PanelMestre.Enabled := True;
    PanelItensLancamento.Enabled := True;
  end;
end;
{$ENDREGION}

{$REGION 'Controles CRUD'}
function TFFinCobranca.DoInserir: Boolean;
begin
  Result := inherited DoInserir;

  if Result then
  begin
    EditIdCliente.SetFocus;
  end;
end;

function TFFinCobranca.DoEditar: Boolean;
begin
  Result := inherited DoEditar;

  if Result then
  begin
    EditIdCliente.SetFocus;
  end;
end;

function TFFinCobranca.DoExcluir: Boolean;
begin
  if inherited DoExcluir then
  begin
    try
      Result := TFinCobrancaController.Exclui(IdRegistroSelecionado);
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

function TFFinCobranca.DoSalvar: Boolean;
var
  ParcelaReceber: TFinCobrancaParcelaReceberVO;
begin
  Result := inherited DoSalvar;

  if Result then
  begin
    try
      if not Assigned(ObjetoVO) then
        ObjetoVO := TFinCobrancaVO.Create;

      TFinCobrancaVO(ObjetoVO).IdCliente := EditIdCliente.AsInteger;
      TFinCobrancaVO(ObjetoVO).ClienteNome := EditCliente.Text;
      TFinCobrancaVO(ObjetoVO).DataContato := EditDataContato.Date;
      TFinCobrancaVO(ObjetoVO).HoraContato := EditHoraContato.Text;
      TFinCobrancaVO(ObjetoVO).TelefoneContato := EditTelefoneContato.Text;
      TFinCobrancaVO(ObjetoVO).DataAcertoPagamento := EditDataAcertoPagamento.Date;
      TFinCobrancaVO(ObjetoVO).TotalReceberNaData := EditValorTotal.Value;

      // Parcelas
      CDSParcelaReceber.DisableControls;
      CDSParcelaReceber.First;
      while not CDSParcelaReceber.Eof do
      begin
          ParcelaReceber := TFinCobrancaParcelaReceberVO.Create;
          ParcelaReceber.Id := CDSParcelaReceber.FieldByName('ID').AsInteger;
          ParcelaReceber.IdFinCobranca := TFinCobrancaVO(ObjetoVO).Id;
          ParcelaReceber.IdFinLancamentoReceber := CDSParcelaReceber.FieldByName('ID_FIN_LANCAMENTO_RECEBER').AsInteger;
          ParcelaReceber.IdFinParcelaReceber := CDSParcelaReceber.FieldByName('ID_FIN_PARCELA_RECEBER').AsInteger;
          ParcelaReceber.DataVencimento := CDSParcelaReceber.FieldByName('DATA_VENCIMENTO').AsDateTime;
          ParcelaReceber.ValorParcela := CDSParcelaReceber.FieldByName('VALOR_PARCELA').AsFloat;
          ParcelaReceber.ValorJuroSimulado := CDSParcelaReceber.FieldByName('VALOR_JURO_SIMULADO').AsFloat;
          ParcelaReceber.ValorJuroAcordo := CDSParcelaReceber.FieldByName('VALOR_JURO_ACORDO').AsFloat;
          ParcelaReceber.ValorMultaSimulado := CDSParcelaReceber.FieldByName('VALOR_MULTA_SIMULADO').AsFloat;
          ParcelaReceber.ValorMultaAcordo := CDSParcelaReceber.FieldByName('VALOR_MULTA_ACORDO').AsFloat;
          ParcelaReceber.ValorReceberSimulado := CDSParcelaReceber.FieldByName('VALOR_RECEBER_SIMULADO').AsFloat;
          ParcelaReceber.ValorReceberAcordo := CDSParcelaReceber.FieldByName('VALOR_RECEBER_ACORDO').AsFloat;

          TFinCobrancaVO(ObjetoVO).ListaCobrancaParcelaReceberVO.Add(ParcelaReceber);

        CDSParcelaReceber.Next;
      end;
      CDSParcelaReceber.EnableControls;

      if StatusTela = stInserindo then
      begin
        TFinCobrancaController.Insere(TFinCobrancaVO(ObjetoVO));
      end
      else if StatusTela = stEditando then
      begin
        /// EXERCICIO: Verifique se tem como serializar as listas junto com o objeto para realizar a comparação
        //if TFinCobrancaVO(ObjetoVO).ToJSONString <> StringObjetoOld then
        //begin
          TFinCobrancaController.Altera(TFinCobrancaVO(ObjetoVO));
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
procedure TFFinCobranca.EditIdClienteKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  Filtro: String;
  ViewPessoaClienteVO :TViewPessoaClienteVO;
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
      end
      else
      begin
        Exit;
      end;
    finally
      EditDataContato.SetFocus;
    end;
  end;
end;
{$ENDREGION}

{$REGION 'Controle de Grid'}
procedure TFFinCobranca.GridDblClick(Sender: TObject);
begin
  inherited;
  ConfigurarLayoutTela;
end;

procedure TFFinCobranca.GridParaEdits;
var
  IdCabecalho: String;
begin
  inherited;

  if not CDSGrid.IsEmpty then
  begin
    IdCabecalho := IntToStr(IdRegistroSelecionado);
    ObjetoVO := TFinCobrancaController.ConsultaObjeto('ID=' + IdCabecalho);
  end;

  if Assigned(ObjetoVO) then
  begin
    EditIdCliente.AsInteger := TFinCobrancaVO(ObjetoVO).IdCliente;
    EditCliente.Text := TFinCobrancaVO(ObjetoVO).ClienteNome;
    EditDataContato.Date := TFinCobrancaVO(ObjetoVO).DataContato;
    EditHoraContato.Text := TFinCobrancaVO(ObjetoVO).HoraContato;
    EditTelefoneContato.Text := TFinCobrancaVO(ObjetoVO).TelefoneContato;
    EditDataAcertoPagamento.Date := TFinCobrancaVO(ObjetoVO).DataAcertoPagamento;
    EditValorTotal.Value := TFinCobrancaVO(ObjetoVO).TotalReceberNaData;

    /// EXERCICIO: carregue os dados de detalhe

    // Serializa o objeto para consultar posteriormente se houve alterações
    FormatSettings.DecimalSeparator := '.';
    StringObjetoOld := ObjetoVO.ToJSONString;
    FormatSettings.DecimalSeparator := ',';
  end;
  ConfigurarLayoutTela;
end;

procedure TFFinCobranca.GridParcelasKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  If Key = VK_RETURN then
    GridParcelas.SelectedIndex := GridParcelas.SelectedIndex + 1;
end;

procedure TFFinCobranca.CDSParcelaReceberAfterPost(DataSet: TDataSet);
begin
  if CDSParcelaReceber.FieldByName('DATA_VENCIMENTO').AsString = '' then
    CDSParcelaReceber.Delete;
end;

procedure TFFinCobranca.CDSParcelaReceberBeforeDelete(DataSet: TDataSet);
begin
  if CDSParcelaReceber.FieldByName('ID').AsInteger > 0 then
    TFinParcelaReceberController.Exclui(CDSParcelaReceber.FieldByName('ID').AsInteger);
end;

procedure TFFinCobranca.CDSParcelasVencidasBeforePost(DataSet: TDataSet);
begin
  /// EXERCICIO: SE CONSIDERAR NECESSARIO, PERMITA QUE O USUÁRIO SELECIONE SE DESEJA O CALCULO COM JUROS SIMPLES OU COMPOSTOS (USE COMBOBOXES)

  CDSParcelasVencidas.FieldByName('VALOR_JURO').AsFloat := (CDSParcelasVencidas.FieldByName('VALOR_PARCELA').AsFloat * (CDSParcelasVencidas.FieldByName('TAXA_JURO').AsFloat / 30) / 100) * (Now - CDSParcelasVencidas.FieldByName('DATA_VENCIMENTO').AsDateTime);
  CDSParcelasVencidas.FieldByName('VALOR_MULTA').AsFloat := CDSParcelasVencidas.FieldByName('VALOR_PARCELA').AsFloat * (CDSParcelasVencidas.FieldByName('TAXA_MULTA').AsFloat / 100);
end;

procedure TFFinCobranca.CDSParcelaReceberBeforePost(DataSet: TDataSet);
begin
  CDSParcelaReceber.FieldByName('VALOR_RECEBER_SIMULADO').AsFloat := CDSParcelaReceber.FieldByName('VALOR_PARCELA').AsFloat +
                                                                        CDSParcelaReceber.FieldByName('VALOR_JURO_SIMULADO').AsFloat +
                                                                        CDSParcelaReceber.FieldByName('VALOR_MULTA_SIMULADO').AsFloat;
end;
{$ENDREGION}

{$REGION 'Actions'}
procedure TFFinCobranca.ActionCalcularMultaJurosExecute(Sender: TObject);
var
  TotalAtraso, Total, Juros, Multa: Extended;
begin

  /// EXERCICIO: SE CONSIDERAR NECESSARIO, ARMAZENE NO BANCO DE DADOS OS TOTAIS DE JUROS E MULTAS

  Juros := 0;
  Multa := 0;
  Total := 0;
  TotalAtraso := 0;
  //
  CDSParcelaReceber.Close;
  CDSParcelaReceber.Open;
  //
  CDSParcelasVencidas.DisableControls;
  CDSParcelasVencidas.First;
  while not CDSParcelasVencidas.Eof do
  begin
    CDSParcelaReceber.Append;
    CDSParcelaReceber.FieldByName('ID_FIN_LANCAMENTO_RECEBER').AsInteger := CDSParcelasVencidas.FieldByName('ID_LANCAMENTO_RECEBER').AsInteger;
    CDSParcelaReceber.FieldByName('ID_FIN_PARCELA_RECEBER').AsInteger := CDSParcelasVencidas.FieldByName('ID_PARCELA_RECEBER').AsInteger;
    CDSParcelaReceber.FieldByName('DATA_VENCIMENTO').AsDateTime := CDSParcelasVencidas.FieldByName('DATA_VENCIMENTO').AsDateTime;
    CDSParcelaReceber.FieldByName('VALOR_PARCELA').AsFloat := CDSParcelasVencidas.FieldByName('VALOR_PARCELA').AsFloat;
    CDSParcelaReceber.FieldByName('VALOR_JURO_SIMULADO').AsFloat := CDSParcelasVencidas.FieldByName('VALOR_JURO').AsFloat;
    CDSParcelaReceber.FieldByName('VALOR_JURO_ACORDO').AsFloat := CDSParcelasVencidas.FieldByName('VALOR_JURO').AsFloat;
    CDSParcelaReceber.FieldByName('VALOR_MULTA_SIMULADO').AsFloat := CDSParcelasVencidas.FieldByName('VALOR_MULTA').AsFloat;
    CDSParcelaReceber.FieldByName('VALOR_MULTA_ACORDO').AsFloat := CDSParcelasVencidas.FieldByName('VALOR_MULTA').AsFloat;
    CDSParcelaReceber.FieldByName('VALOR_RECEBER_SIMULADO').AsFloat := CDSParcelasVencidas.FieldByName('VALOR_PARCELA').AsFloat +
                                                                        CDSParcelasVencidas.FieldByName('VALOR_JURO').AsFloat +
                                                                        CDSParcelasVencidas.FieldByName('VALOR_MULTA').AsFloat;
    CDSParcelaReceber.FieldByName('VALOR_RECEBER_ACORDO').AsFloat := CDSParcelaReceber.FieldByName('VALOR_RECEBER_SIMULADO').AsFloat;
    CDSParcelaReceber.Post;
    TotalAtraso := TotalAtraso + CDSParcelaReceber.FieldByName('VALOR_PARCELA').AsFloat;
    Total := Total + CDSParcelaReceber.FieldByName('VALOR_RECEBER_SIMULADO').AsFloat;
    Juros := Juros + CDSParcelaReceber.FieldByName('VALOR_JURO_SIMULADO').AsFloat;
    Multa := Multa + CDSParcelaReceber.FieldByName('VALOR_MULTA_SIMULADO').AsFloat;
    CDSParcelasVencidas.Next;
  end;
  CDSParcelasVencidas.First;
  CDSParcelasVencidas.EnableControls;
  //
  EditValorTotal.Value := Total;
  EditValorTotalJuros.Value := Juros;
  EditValorTotalMulta.Value := Multa;
  EditValorTotalAtrasado.Value := TotalAtraso;
end;

procedure TFFinCobranca.ActionConsultarParcelasExecute(Sender: TObject);
var
  Filtro: String;
begin
  /// EXERCICIO: ENCONTRE O ERRO NO FILTRO E CORRIJA - Complete o procedimento

  Filtro := 'SITUACAO_PARCELA=' + QuotedStr('01') + ' and DATA_VENCIMENTO < ' + QuotedStr(DataParaTexto(Now));
  TViewFinLancamentoReceberController.Consulta(Filtro, '0');
end;

procedure TFFinCobranca.ActionMarcarDataHoraContatoExecute(Sender: TObject);
begin
  EditDataContato.Date := Now;
  EditHoraContato.Text := FormatDateTime('hh:mm:ss', Now);
end;

procedure TFFinCobranca.ActionSimularValoresExecute(Sender: TObject);
var
  Total, Juros, Multa: Extended;
begin
  /// EXERCICIO: CRIE CAMPOS CALCULADOS PARA VER A DIFERENÇA ENTRE O SIMULADO E O ACORDADO

  Juros := 0;
  Multa := 0;
  Total := 0;

  CDSParcelaReceber.DisableControls;
  CDSParcelaReceber.First;
  while not CDSParcelaReceber.Eof do
  begin
    Total := Total + CDSParcelaReceber.FieldByName('VALOR_RECEBER_SIMULADO').AsFloat;
    Juros := Juros + CDSParcelaReceber.FieldByName('VALOR_JURO_SIMULADO').AsFloat;
    Multa := Multa + CDSParcelaReceber.FieldByName('VALOR_MULTA_SIMULADO').AsFloat;
    CDSParcelaReceber.Next;
  end;
  CDSParcelaReceber.First;
  CDSParcelaReceber.EnableControls;
  //
  EditValorTotal.Value := Total;
  EditValorTotalJuros.Value := Juros;
  EditValorTotalMulta.Value := Multa;
end;

procedure TFFinCobranca.ActionGeraNovoLancamentoExecute(Sender: TObject);
begin
  /// EXERCICIO: GERE UM NOVO LANÇAMENTO COM BASE NO QUE FOI ACORDADO
  Application.MessageBox('Lançamento efetuado com sucesso.', 'Mensagem do Sistema', MB_OK + MB_ICONINFORMATION);
  BotaoCancelar.Click;
end;

/// EXERCICIO: CRIE UMA ACTION QUE PERMITA O USUARIO BAIXAR OS VALORES DOS JUROS/MULTAS COM BASE NUM PERCENTUAL FORNECIDO

{$ENDREGION}

end.

