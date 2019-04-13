{ *******************************************************************************
Title: T2Ti ERP
Description: Janela de conciliação dos clientes - Módulo Conciliação Contábil

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

t2ti.com@gmail.com
@author Albert Eije (T2Ti.COM)
@version 2.0
******************************************************************************* }
unit UConciliacaoCliente;

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

  { TFConciliacaoCliente }

  TFConciliacaoCliente = class(TFTelaCadastro)
    BevelEdits: TBevel;
    CDSParcelaRecebimento: TBufDataset;
    CDSContabilLancamento: TBufDataset;
    CDSLancamentoConciliado: TBufDataset;
    EditContabilConta: TLabeledEdit;
    DSParcelaRecebimento: TDataSource;
    CDSContabilLancamentoID: TIntegerField;
    CDSContabilLancamentoID_CONTABIL_CONTA: TIntegerField;
    CDSContabilLancamentoID_CONTABIL_HISTORICO: TIntegerField;
    CDSContabilLancamentoID_CONTABIL_LANCAMENTO_CAB: TIntegerField;
    CDSContabilLancamentoHISTORICO: TStringField;
    CDSContabilLancamentoTIPO: TStringField;
    CDSContabilLancamentoVALOR: TFMTBCDField;
    DSContabilLancamento: TDataSource;
    GroupBox4: TGroupBox;
    JvDBUltimGrid2: TRxDbGrid;
    DSLancamentoConciliado: TDataSource;
    ActionManager1: TActionList;
    ActionToolBar1: TToolPanel;
    ActionListarLancamentos: TAction;
    ActionConciliacao: TAction;
    EditIdCliente: TLabeledCalcEdit;
    EditCliente: TLabeledEdit;
    PanelLancamentos: TPanel;
    GroupBox2: TGroupBox;
    GridDetalhe: TRxDbGrid;
    GroupBox3: TGroupBox;
    GridLancamentoContabil: TRxDBGrid;
    Splitter1: TSplitter;
    EditPeriodoInicial: TLabeledDateEdit;
    EditPeriodoFinal: TLabeledDateEdit;
    procedure FormCreate(Sender: TObject);
    procedure GridDblClick(Sender: TObject);
    procedure ActionListarLancamentosExecute(Sender: TObject);
    procedure ActionConciliacaoExecute(Sender: TObject);
    procedure BotaoConsultarClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure GridParaEdits; override;
    procedure LimparCampos; override;
  end;

var
  FConciliacaoCliente: TFConciliacaoCliente;

implementation

uses UDataModule, ContabilContaVO, ContabilLancamentoDetalheController,
ViewConciliaClienteController, ClienteVO, ClienteController, ViewConciliaClienteVO,
ContabilLancamentoDetalheVO, ContabilContaController;
{$R *.lfm}

{$REGION 'Controles Infra'}
procedure TFConciliacaoCliente.BotaoConsultarClick(Sender: TObject);
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
    RetornoConsulta := TClienteController.Consulta(Filtro, IntToStr(Pagina));
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

procedure TFConciliacaoCliente.FormCreate(Sender: TObject);
begin
  ClasseObjetoGridVO := TClienteVO;
  ObjetoController := TClienteController.Create;

  inherited;

  BotaoInserir.Visible := False;
  BotaoAlterar.Visible := False;
  BotaoExcluir.Visible := False;
  BotaoSalvar.Visible := False;

  ConfiguraCDSFromVO(CDSParcelaRecebimento, TViewConciliaClienteVO);
  ConfiguraGridFromVO(GridDetalhe, TViewConciliaClienteVO);

  ConfiguraCDSFromVO(CDSContabilLancamento, TContabilLancamentoDetalheVO);
  ConfiguraGridFromVO(GridLancamentoContabil, TContabilLancamentoDetalheVO);

  //configura Dataset transiente
  CDSLancamentoConciliado.Close;
  CDSLancamentoConciliado.FieldDefs.Clear;

  CDSLancamentoConciliado.FieldDefs.add('MES', ftString, 2);
  CDSLancamentoConciliado.FieldDefs.add('ANO', ftString, 4);
  CDSLancamentoConciliado.FieldDefs.add('DATA_MOVIMENTO', ftDate);
  CDSLancamentoConciliado.FieldDefs.add('DATA_RECEBIMENTO', ftDate);
  CDSLancamentoConciliado.FieldDefs.add('DATA_BALANCETE', ftDate);
  CDSLancamentoConciliado.FieldDefs.add('HISTORICO_PAGAMENTO', ftString, 50);
  CDSLancamentoConciliado.FieldDefs.add('VALOR_PAGAMENTO', ftFloat);
  CDSLancamentoConciliado.FieldDefs.add('HISTORICO_EXTRATO', ftString, 50);
  CDSLancamentoConciliado.FieldDefs.add('VALOR_EXTRATO', ftFloat);
  CDSLancamentoConciliado.FieldDefs.add('HISTORICO_RECEBIMENTO', ftString, 50);
  CDSLancamentoConciliado.FieldDefs.add('VALOR_RECEBIMENTO', ftFloat);
  CDSLancamentoConciliado.FieldDefs.add('CLASSIFICACAO', ftString, 30);
  CDSLancamentoConciliado.FieldDefs.add('HISTORICO_CONTA', ftString, 250);
  CDSLancamentoConciliado.FieldDefs.add('TIPO', ftString, 1);
  CDSLancamentoConciliado.FieldDefs.add('VALOR_CONTA', ftFloat);
  CDSLancamentoConciliado.CreateDataset;
  CDSLancamentoConciliado.Open;
end;

procedure TFConciliacaoCliente.LimparCampos;
begin
  inherited;
  CDSParcelaRecebimento.Close;
  CDSContabilLancamento.Close;
  CDSLancamentoConciliado.Close;
  CDSParcelaRecebimento.Open;
  CDSContabilLancamento.Open;
  CDSLancamentoConciliado.Open;
end;
{$ENDREGION}

{$REGION 'Controle de Grid'}
procedure TFConciliacaoCliente.GridParaEdits;
var
  IdCabecalho: String;
begin
  inherited;

  if not CDSGrid.IsEmpty then
  begin
    IdCabecalho := IntToStr(IdRegistroSelecionado);
    ObjetoVO := TClienteController.ConsultaObjeto('ID=' + IdCabecalho);
  end;

  if Assigned(ObjetoVO) then
  begin
    EditContabilConta.Text := TClienteVO(ObjetoVO).ClassificacaoContabilConta;
    EditIdCliente.AsInteger := TClienteVO(ObjetoVO).Id;
    //EditCliente.Text := TClienteVO(ObjetoVO).PessoaNome;
  end;
end;

procedure TFConciliacaoCliente.GridDblClick(Sender: TObject);
begin
  inherited;
  PanelEdits.Enabled := True;
  EditPeriodoInicial.SetFocus;
  if TClienteVO(ObjetoVO).ClassificacaoContabilConta = '' then
  begin
    Application.MessageBox('Cliente sem conta contábil vinculada.', 'Informação do Sistema', MB_OK + MB_IconInformation);
    BotaoCancelar.Click;
  end
end;
{$ENDREGION}

{$REGION 'Actions'}
procedure TFConciliacaoCliente.ActionListarLancamentosExecute(Sender: TObject);
var
  Filtro: String;
  Conta: TContabilContaVO;
  ListaCampos: TStringList;
  QCliente, QLancamento: TZQuery;
  i:Integer;
begin
  // Contas Recebidas
  Filtro := 'ID_CLIENTE=' + IntToStr(TClienteVO(ObjetoVO).Id) + ' and (DATA_RECEBIMENTO BETWEEN ' + QuotedStr(DataParaTexto(EditPeriodoInicial.Date)) + ' and ' + QuotedStr(DataParaTexto(EditPeriodoFinal.Date)) + ')';
  QCliente := TViewConciliaClienteController.Consulta(Filtro, '0');
  QCliente.Active := True;

  ListaCampos  := TStringList.Create;
  QCliente.GetFieldNames(ListaCampos);

  QCliente.First;
  while not QCliente.EOF do begin
    CDSParcelaRecebimento.Append;
    for i := 0 to ListaCampos.Count - 1 do
    begin
      CDSParcelaRecebimento.FieldByName(ListaCampos[i]).Value := QCliente.FieldByName(ListaCampos[i]).Value;
    end;
    CDSParcelaRecebimento.Post;
    QCliente.Next;
  end;

  // Pega o ID da conta
  Filtro := 'CLASSIFICACAO=' + QuotedStr(TClienteVO(ObjetoVO).ClassificacaoContabilConta);
  Conta := TContabilContaController.ConsultaObjeto(Filtro);

  // Lançamentos Contábeis
  Filtro := 'ID_CONTABIL_CONTA=' + IntToStr(Conta.Id);
  QLancamento := TContabilLancamentoDetalheController.Consulta(Filtro, '0');
  QLancamento.Active := True;

  ListaCampos  := TStringList.Create;
  QLancamento.GetFieldNames(ListaCampos);

  QLancamento.First;
  while not QLancamento.EOF do begin
    CDSContabilLancamento.Append;
    for i := 0 to ListaCampos.Count - 1 do
    begin
      CDSContabilLancamento.FieldByName(ListaCampos[i]).Value := QLancamento.FieldByName(ListaCampos[i]).Value;
    end;
    CDSContabilLancamento.Post;
    QLancamento.Next;
  end;
end;

procedure TFConciliacaoCliente.ActionConciliacaoExecute(Sender: TObject);
begin
  CDSParcelaRecebimento.DisableControls;
  CDSContabilLancamento.DisableControls;

  CDSParcelaRecebimento.First;
  while not CDSParcelaRecebimento.Eof do
  begin

    CDSContabilLancamento.First;
    while not CDSContabilLancamento.Eof do
    begin

      if CDSParcelaRecebimento.FieldByName('VALOR_RECEBIDO').AsFloat = CDSContabilLancamento.FieldByName('VALOR').AsFloat then
      begin
        CDSLancamentoConciliado.Append;
        CDSLancamentoConciliado.FieldByName('DATA_RECEBIMENTO').AsDateTime := CDSParcelaRecebimento.FieldByName('DATA_RECEBIMENTO').AsDateTime;
        CDSLancamentoConciliado.FieldByName('DATA_BALANCETE').AsDateTime := CDSParcelaRecebimento.FieldByName('DATA_RECEBIMENTO').AsDateTime;
        CDSLancamentoConciliado.FieldByName('HISTORICO_RECEBIMENTO').AsString := CDSParcelaRecebimento.FieldByName('HISTORICO').AsString;
        CDSLancamentoConciliado.FieldByName('VALOR_RECEBIMENTO').AsFloat := CDSParcelaRecebimento.FieldByName('VALOR_RECEBIDO').AsFloat;
        //CDSLancamentoConciliado.FieldByName('CLASSIFICACAO').AsString := CDSContabilLancamento.FieldByName('CONTABIL_CONTACLASSIFICACAO').AsString;
        CDSLancamentoConciliado.FieldByName('HISTORICO_CONTA').AsString := CDSContabilLancamento.FieldByName('HISTORICO').AsString;
        CDSLancamentoConciliado.FieldByName('TIPO').AsString := CDSContabilLancamento.FieldByName('TIPO').AsString;
        CDSLancamentoConciliado.FieldByName('VALOR_CONTA').AsFloat := CDSContabilLancamento.FieldByName('VALOR').AsFloat;
        CDSLancamentoConciliado.Post;
      end;

      CDSContabilLancamento.Next;
    end;
    CDSParcelaRecebimento.Next;
  end;

  CDSParcelaRecebimento.EnableControls;
  CDSContabilLancamento.EnableControls;
end;

{$ENDREGION}

end.

