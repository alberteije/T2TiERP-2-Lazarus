{ *******************************************************************************
Title: T2Ti ERP
Description: Janela de conciliação de lançamentos contábeis

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

@author Albert Eije (alberteije@gmail.com)
@version 2.0
******************************************************************************* }
unit UConciliaContabilLancamento;

interface

uses
  BrookHTTPClient, BrookFCLHTTPClientBroker, BrookHTTPUtils, BrookUtils, FPJson, ZDataset,
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UTelaCadastro, Menus, StdCtrls, ExtCtrls, Buttons, Grids, DBGrids,
  ComCtrls, LabeledCtrls, rxdbgrid, rxtoolbar, DBCtrls, StrUtils,
  Math, Constantes, CheckLst, ActnList, ToolWin, ShellApi, db, BufDataset, Biblioteca,
  ULookup, VO;

  type

  TFConciliaContabilLancamento = class(TFTelaCadastro)
    DSContabilLancamentoDetalhe: TDataSource;
    CDSContabilLancamentoDetalhe: TBufDataSet;
    PanelMestre: TPanel;
    EditIdLote: TLabeledCalcEdit;
    EditLote: TLabeledEdit;
    PageControlItens: TPageControl;
    tsItens: TTabSheet;
    PanelItens: TPanel;
    GridDetalhe: TRxDbGrid;
    ComboBoxTipo: TLabeledComboBox;
    EditDataLancamento: TLabeledDateEdit;
    EditDataInclusao: TLabeledDateEdit;
    ComboBoxLiberado: TLabeledComboBox;
    ActionManager1: TActionList;
    ActionConciliacao: TAction;
    ActionToolBar1: TToolPanel;
    ActionEstorno: TAction;
    Transferencia: TAction;
    ActionComplementacao: TAction;
    procedure FormCreate(Sender: TObject);
    procedure GridDblClick(Sender: TObject);
    procedure ActionConciliacaoExecute(Sender: TObject);
    procedure ActionEstornoExecute(Sender: TObject);
    procedure TransferenciaExecute(Sender: TObject);
    procedure ActionComplementacaoExecute(Sender: TObject);
    procedure BotaoConsultarClick(Sender: TObject);

  private
    { Private declarations }
  public
    { Public declarations }
    procedure GridParaEdits; override;
    procedure LimparCampos; override;
  end;

var
  FConciliaContabilLancamento: TFConciliaContabilLancamento;

implementation

uses UDataModule, ContabilLancamentoDetalheVO, ContabilLoteVO, ContabilLancamentoCabecalhoVO,
  ContabilLancamentoCabecalhoController;
{$R *.lfm}

{$REGION 'Controles Infra'}
procedure TFConciliaContabilLancamento.BotaoConsultarClick(Sender: TObject);
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
    RetornoConsulta := TContabilLancamentoCabecalhoController.Consulta(Filtro, IntToStr(Pagina));
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

procedure TFConciliaContabilLancamento.FormCreate(Sender: TObject);
begin
  ClasseObjetoGridVO := TContabilLancamentoCabecalhoVO;
  ObjetoController := TContabilLancamentoCabecalhoController.Create;

  inherited;
  BotaoInserir.Visible := False;
  BotaoAlterar.Visible := False;
  BotaoExcluir.Visible := False;
  BotaoSalvar.Visible := False;

  ConfiguraCDSFromVO(CDSContabilLancamentoDetalhe, TContabilLancamentoDetalheVO);
  ConfiguraGridFromVO(GridDetalhe, TContabilLancamentoDetalheVO);

end;

procedure TFConciliaContabilLancamento.LimparCampos;
begin
  inherited;
  CDSContabilLancamentoDetalhe.Close;
  CDSContabilLancamentoDetalhe.Open;
end;
{$ENDREGION}

{$REGION 'Controle de Grid'}
procedure TFConciliaContabilLancamento.GridParaEdits;
var
  IdCabecalho: String;
  I: Integer;
  Current: TContabilLancamentoDetalheVO;
begin
  inherited;

  if not CDSGrid.IsEmpty then
  begin
    IdCabecalho := IntToStr(IdRegistroSelecionado);
    ObjetoVO := TContabilLancamentoCabecalhoController.ConsultaObjeto('ID=' + IdCabecalho);
  end;

  if Assigned(ObjetoVO) then
  begin
    EditIdLote.AsInteger := TContabilLancamentoCabecalhoVO(ObjetoVO).IdContabilLote;
    EditLote.Text := TContabilLancamentoCabecalhoVO(ObjetoVO).LoteDescricao;
    EditDataLancamento.Date := TContabilLancamentoCabecalhoVO(ObjetoVO).DataLancamento;
    EditDataInclusao.Date := TContabilLancamentoCabecalhoVO(ObjetoVO).DataInclusao;
    ComboBoxLiberado.ItemIndex := IfThen(TContabilLancamentoCabecalhoVO(ObjetoVO).Liberado = 'S', 0, 1);

    case AnsiIndexStr(TContabilLancamentoCabecalhoVO(ObjetoVO).Tipo, ['UDVC', 'UCVD', 'UDUC', 'VDVC']) of
      0:
        ComboBoxTipo.ItemIndex := 0;
      1:
        ComboBoxTipo.ItemIndex := 1;
      2:
        ComboBoxTipo.ItemIndex := 2;
      3:
        ComboBoxTipo.ItemIndex := 3;
    end;

    // Detalhes
    // Detalhes
    for I := 0 to TContabilLancamentoCabecalhoVO(ObjetoVO).ListaContabilLancamentoDetalheVO.Count - 1 do
    begin
      Current := TContabilLancamentoCabecalhoVO(ObjetoVO).ListaContabilLancamentoDetalheVO[I];

      CDSContabilLancamentoDetalhe.Append;
      CDSContabilLancamentoDetalhe.FieldByName('ID').AsInteger := Current.id;
      CDSContabilLancamentoDetalhe.FieldByName('ID_CONTABIL_LANCAMENTO_CAB').AsInteger := Current.IdContabilLancamentoCab;
      CDSContabilLancamentoDetalhe.FieldByName('ID_CONTABIL_CONTA').AsInteger := Current.IdContabilConta;
      CDSContabilLancamentoDetalhe.FieldByName('ID_CONTABIL_HISTORICO').AsInteger := Current.IdContabilHistorico;
      CDSContabilLancamentoDetalhe.FieldByName('HISTORICO').AsString := Current.Historico;
      CDSContabilLancamentoDetalhe.FieldByName('TIPO').AsString := Current.Tipo;
      CDSContabilLancamentoDetalhe.FieldByName('VALOR').AsFloat := Current.Valor;
      CDSContabilLancamentoDetalhe.Post;
    end;
  end;
end;

procedure TFConciliaContabilLancamento.GridDblClick(Sender: TObject);
begin
  inherited;
  PanelEdits.Enabled := True;
  EditIdLote.SetFocus;
end;
{$ENDREGION}

{$REGION 'Actions'}
procedure TFConciliaContabilLancamento.ActionConciliacaoExecute(Sender: TObject);
var
  TotalDebitos, TotalCreditos: Double;
begin
  TotalDebitos := 0;
  TotalCreditos := 0;
  //
  CDSContabilLancamentoDetalhe.DisableControls;
  CDSContabilLancamentoDetalhe.First;
  while not CDSContabilLancamentoDetalhe.Eof do
  begin
    if CDSContabilLancamentoDetalhe.FieldByName('TIPO').AsString = 'C' then
      TotalCreditos := TotalCreditos + CDSContabilLancamentoDetalhe.FieldByName('VALOR').AsFloat
    else if CDSContabilLancamentoDetalhe.FieldByName('TIPO').AsString = 'D' then
      TotalDebitos := TotalDebitos + CDSContabilLancamentoDetalhe.FieldByName('VALOR').AsFloat;
    CDSContabilLancamentoDetalhe.Next;
  end;

  CDSContabilLancamentoDetalhe.First;
  while not CDSContabilLancamentoDetalhe.Eof do
  begin
    CDSContabilLancamentoDetalhe.Edit;
    if TotalCreditos = TotalDebitos then
      CDSContabilLancamentoDetalhe.FieldByName('CONCILIADO').AsString := 'S'
    else
      CDSContabilLancamentoDetalhe.FieldByName('CONCILIADO').AsString := 'N';
    CDSContabilLancamentoDetalhe.Post;
    CDSContabilLancamentoDetalhe.Next;
  end;

  CDSContabilLancamentoDetalhe.First;
  CDSContabilLancamentoDetalhe.EnableControls;
end;

procedure TFConciliaContabilLancamento.ActionEstornoExecute(Sender: TObject);
begin
  { Implementado a critério do Participante do T2Ti ERP }
  CDSContabilLancamentoDetalhe.Edit;
  CDSContabilLancamentoDetalhe.FieldByName('CONCILIADO').AsString := 'E';
  CDSContabilLancamentoDetalhe.Post;
end;

procedure TFConciliaContabilLancamento.TransferenciaExecute(Sender: TObject);
begin
  { Implementado a critério do Participante do T2Ti ERP }
  CDSContabilLancamentoDetalhe.Edit;
  CDSContabilLancamentoDetalhe.FieldByName('CONCILIADO').AsString := 'T';
  CDSContabilLancamentoDetalhe.Post;
end;

procedure TFConciliaContabilLancamento.ActionComplementacaoExecute(Sender: TObject);
begin
  { Implementado a critério do Participante do T2Ti ERP }
  CDSContabilLancamentoDetalhe.Edit;
  CDSContabilLancamentoDetalhe.FieldByName('CONCILIADO').AsString := 'C';
  CDSContabilLancamentoDetalhe.Post;
end;
{$ENDREGION}

end.

