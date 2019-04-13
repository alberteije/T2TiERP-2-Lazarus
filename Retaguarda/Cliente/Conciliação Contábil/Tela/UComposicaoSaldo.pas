{ *******************************************************************************
Title: T2Ti ERP
Description: Janela Composição do Saldo - módulo Conciliação Contábil

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
unit UComposicaoSaldo;

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

  { TFComposicaoSaldo }

  TFComposicaoSaldo = class(TFTelaCadastro)
    CDSLancamentoExtrato: TBufDataset;
    EditPlanoConta: TLabeledEdit;
    EditClassificacao: TLabeledEdit;
    EditDescricao: TLabeledEdit;
    BevelEdits: TBevel;
    EditPlanoContaRefSped: TLabeledEdit;
    EditIdPlanoConta: TLabeledCalcEdit;
    EditIdPlanoContaRefSped: TLabeledCalcEdit;
    EditIdContaPai: TLabeledCalcEdit;
    EditContaPai: TLabeledEdit;
    ComboBoxTipo: TLabeledComboBox;
    GroupBox4: TGroupBox;
    ActionManager1: TActionList;
    ActionListarLancamentos: TAction;
    ActionToolBar1: TToolPanel;
    ActionImpressao: TAction;
    LabelSaldo: TLabel;
    GridDetalhe: TRxDbGrid;
    DSLancamentoExtrato: TDataSource;
    procedure FormCreate(Sender: TObject);
    procedure GridDblClick(Sender: TObject);
    procedure ActionListarLancamentosExecute(Sender: TObject);
    procedure BotaoConsultarClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure GridParaEdits; override;
    procedure LimparCampos; override;
  end;

var
  FComposicaoSaldo: TFComposicaoSaldo;

implementation

uses UDataModule, FinExtratoContaBancoController, ContabilContaVO, ContabilContaController,
  FinExtratoContaBancoVO;
{$R *.lfm}

{$REGION 'Controles Infra'}
procedure TFComposicaoSaldo.BotaoConsultarClick(Sender: TObject);
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
    RetornoConsulta := TContabilContaController.Consulta(Filtro, IntToStr(Pagina));
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

procedure TFComposicaoSaldo.FormCreate(Sender: TObject);
begin
  ClasseObjetoGridVO := TContabilContaVO;
  ObjetoController := TContabilContaController.Create;

  inherited;
  BotaoInserir.Visible := False;
  BotaoAlterar.Visible := False;
  BotaoExcluir.Visible := False;
  BotaoSalvar.Visible := False;

  ConfiguraCDSFromVO(CDSLancamentoExtrato, TFinExtratoContaBancoVO);
  ConfiguraGridFromVO(GridDetalhe, TFinExtratoContaBancoVO);
end;

procedure TFComposicaoSaldo.LimparCampos;
begin
  inherited;
  CDSLancamentoExtrato.Close;
  CDSLancamentoExtrato.Open;
end;
{$ENDREGION}

{$REGION 'Controle de Grid'}
procedure TFComposicaoSaldo.GridParaEdits;
var
  IdCabecalho: String;
begin
  inherited;

  if not CDSGrid.IsEmpty then
  begin
    IdCabecalho := IntToStr(IdRegistroSelecionado);
    ObjetoVO := TContabilContaController.ConsultaObjeto('ID=' + IdCabecalho);
  end;

  if Assigned(ObjetoVO) then
  begin

    EditIdPlanoConta.AsInteger := TContabilContaVO(ObjetoVO).IdPlanoConta;
    EditPlanoConta.Text := TContabilContaVO(ObjetoVO).PlanoContaNome;
    EditIdPlanoContaRefSped.AsInteger := TContabilContaVO(ObjetoVO).IdPlanoContaRefSped;
    EditPlanoContaRefSped.Text := TContabilContaVO(ObjetoVO).PlanoContaSpedDescricao;
    EditIdContaPai.AsInteger:= TContabilContaVO(ObjetoVO).IdContabilConta;
    EditClassificacao.Text := TContabilContaVO(ObjetoVO).Classificacao;
    // S=Sintética | A=Analítica
    ComboBoxTipo.ItemIndex := IfThen(TContabilContaVO(ObjetoVO).Tipo = 'S', 0, 1);
    EditDescricao.Text := TContabilContaVO(ObjetoVO).Descricao;
  end;
end;

procedure TFComposicaoSaldo.GridDblClick(Sender: TObject);
begin
  inherited;
  PanelEdits.Enabled := True;
  EditIdPlanoConta.SetFocus;
end;
{$ENDREGION}

{$REGION 'Actions'}
{
Manual de Orientação e de Procedimentos para as Organizações Contábeis
9 - CONCILIAÇÃO CONTÁBIL E COMPOSIÇÃO DE SALDOS
}
procedure TFComposicaoSaldo.ActionListarLancamentosExecute(Sender: TObject);
var
  Valor: Double;
  RetornoConsulta: TZQuery;
  ListaCampos: TStringList;
  i:integer;
begin
  CDSLancamentoExtrato.Close;
  CDSLancamentoExtrato.Open;
  //
  Valor := 0;
  //
  RetornoConsulta := TFinExtratoContaBancoController.Consulta('ID>0', '0');
  RetornoConsulta.Active := True;

  ListaCampos  := TStringList.Create;
  RetornoConsulta.GetFieldNames(ListaCampos);

  RetornoConsulta.First;
  while not RetornoConsulta.EOF do begin
    CDSLancamentoExtrato.Append;
    for i := 0 to ListaCampos.Count - 1 do
    begin
      CDSLancamentoExtrato.FieldByName(ListaCampos[i]).Value := RetornoConsulta.FieldByName(ListaCampos[i]).Value;
    end;
    CDSLancamentoExtrato.Post;
    RetornoConsulta.Next;
  end;

  //

  CDSLancamentoExtrato.DisableControls;
  CDSLancamentoExtrato.First;
  while not CDSLancamentoExtrato.Eof do
  begin
    Valor := Valor + CDSLancamentoExtrato.FieldByName('VALOR').AsFloat;
    CDSLancamentoExtrato.Next;
  end;
  CDSLancamentoExtrato.First;
  CDSLancamentoExtrato.EnableControls;

  LabelSaldo.Caption := 'Saldo da Conta: ' + FloatToStrF(Valor, ffCurrency, 10, 2);
end;
{$ENDREGION}

end.

