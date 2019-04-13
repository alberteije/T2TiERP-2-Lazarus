{ *******************************************************************************
Title: T2Ti ERP
Description: Janela Cadastro de Contratos

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

@author Albert Eije (T2Ti.COM)
@version 2.0
******************************************************************************* }

unit UContrato;

interface

uses
  BrookHTTPClient, BrookFCLHTTPClientBroker, BrookHTTPUtils, BrookUtils, FPJson, ZDataset,
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UTelaCadastro, Menus, StdCtrls, ExtCtrls, Buttons, Grids, DBGrids,
  ComCtrls, LabeledCtrls, rxdbgrid, rxtoolbar, DBCtrls, StrUtils,
  Math, Constantes, CheckLst, ActnList, ToolWin, ShellApi, db, BufDataset, Biblioteca,
  ULookup, VO, ComObj;

  type

  TFContrato = class(TFTelaCadastro)
    ScrollBox: TScrollBox;
    EditNome: TLabeledEdit;
    EditNumero: TLabeledEdit;
    BevelEdits: TBevel;
    PageControlDadosContrato: TPageControl;
    tsDadosComplementares: TTabSheet;
    tsHistoricoFaturamento: TTabSheet;
    PanelHistoricoFaturamento: TPanel;
    GridHistoricoFaturamento: TRxDbGrid;
    tsHistoricoReajuste: TTabSheet;
    PanelHistoricoReajuste: TPanel;
    GridHistoricoReajuste: TRxDbGrid;
    EditIdTipoContrato: TLabeledCalcEdit;
    EditTipoContrato: TLabeledEdit;
    EditContaContabil: TLabeledEdit;
    PanelDadosComplementares: TPanel;
    EditDataCadastro: TLabeledDateEdit;
    MemoDescricao: TLabeledMemo;
    EditDataInicioVigencia: TLabeledDateEdit;
    EditDataFimVigencia: TLabeledDateEdit;
    EditDiaFaturamento: TLabeledMaskEdit;
    EditValor: TLabeledCalcEdit;
    EditQuantidadeParcelas: TLabeledCalcEdit;
    EditIntervaloEntreParcelas: TLabeledCalcEdit;
    MemoObservacao: TLabeledMemo;
    CDSHistoricoFaturamento: TBufDataSet;
    DSHistoricoFaturamento: TDataSource;
    CDSHistoricoReajuste: TBufDataSet;
    DSHistoricoReajuste: TDataSource;
    tsPrevisaoFaturamento: TTabSheet;
    PanelPrevisaoFaturamento: TPanel;
    GridPrevisaoFaturamento: TRxDbGrid;
    CDSPrevisaoFaturamento: TBufDataSet;
    DSPrevisaoFaturamento: TDataSource;
    EditIdSolicitacaoServico: TLabeledCalcEdit;
    EditDescricaoSolicitacao: TLabeledEdit;
    ActionManager1: TActionList;
    ActionToolBar1: TToolPanel;
    ActionGerarPrevisaoFaturamento: TAction;
    ActionContratoDoTemplate: TAction;
    ActionToolBar2: TToolPanel;
    ActionGed: TAction;
    procedure FormCreate(Sender: TObject);
    procedure GridHistoricoFaturamentoKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure GridHistoricoReajusteKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure GridPrevisaoFaturamentoKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure GridDblClick(Sender: TObject);
    procedure ActionGerarPrevisaoFaturamentoExecute(Sender: TObject);
    procedure ActionContratoDoTemplateExecute(Sender: TObject);
    procedure ActionGedExecute(Sender: TObject);
    procedure EditIdTipoContratoKeyUp(Sender: TObject; var Key: Word;Shift: TShiftState);
    procedure EditIdSolicitacaoServicoKeyUp(Sender: TObject; var Key: Word;  Shift: TShiftState);
    procedure EditContaContabilKeyUp(Sender: TObject; var Key: Word;   Shift: TShiftState);
    procedure BotaoConsultarClick(Sender: TObject);
    procedure BotaoSalvarClick(Sender: TObject);
  private
    { Private declarations }
    procedure DeletarArquivoTemporario;
    procedure UploadArquivo;
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
  FContrato: TFContrato;
  FormEditor: TForm;

implementation

uses ContratoVO, ContratoController, ContratoHistFaturamentoVO,
  ContratoHistoricoReajusteVO, ContratoPrevFaturamentoVO, TipoContratoVO,
  TipoContratoController, ContabilContaVO, ContabilContaController, UDataModule,
  ContratoSolicitacaoServicoController, ContratoSolicitacaoServicoVO,
  ContratoTemplateController, ContratoTemplateVO, ViewContratoDadosContratanteVO,
  ViewContratoDadosContratanteController;
{$R *.lfm}

{$REGION 'Infra'}
procedure TFContrato.BotaoConsultarClick(Sender: TObject);
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
    RetornoConsulta := TContratoController.Consulta(Filtro, IntToStr(Pagina));
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

procedure TFContrato.BotaoSalvarClick(Sender: TObject);
begin
  inherited;
  BotaoConsultarClick(Sender);
end;

procedure TFContrato.FormCreate(Sender: TObject);
begin
  ClasseObjetoGridVO := TContratoVO;
  ObjetoController := TContratoController.Create;
  DeletarArquivoTemporario;

  {
  Quem desejar utilizar um editor próprio pode aproveitar o código abaixo
  Já existe um Editor anexo ao projeto, o mesmo que vem nos Demos do Delphi

  FormEditor := TFEditor.Create(PanelEditor);
  with FormEditor do
  begin
    Align := alClient;
    BorderStyle := bsNone;
    Parent := PanelEditor;
  end;
  FormEditor.Show;
  }
  inherited;
  BotaoImprimir.Visible := False;
  MenuImprimir.Visible := False;

  ConfiguraCDSFromVO(CDSHistoricoFaturamento, TContratoHistFaturamentoVO);
  ConfiguraGridFromVO(GridHistoricoFaturamento, TContratoHistFaturamentoVO);

  ConfiguraCDSFromVO(CDSHistoricoReajuste, TContratoHistoricoReajusteVO);
  ConfiguraGridFromVO(GridHistoricoReajuste, TContratoHistoricoReajusteVO);

  ConfiguraCDSFromVO(CDSPrevisaoFaturamento, TContratoPrevFaturamentoVO);
  ConfiguraGridFromVO(GridPrevisaoFaturamento, TContratoPrevFaturamentoVO);
end;

procedure TFContrato.LimparCampos;
var
  i: Integer;
begin
  inherited;
  CDSHistoricoFaturamento.Close;
  CDSHistoricoReajuste.Close;
  CDSPrevisaoFaturamento.Close;
  CDSHistoricoFaturamento.Open;
  CDSHistoricoReajuste.Open;
  CDSPrevisaoFaturamento.Open;
end;

procedure TFContrato.ConfigurarLayoutTela;
begin
  PanelEdits.Enabled := True;
  PageControlDadosContrato.ActivePageIndex := 0;

  if StatusTela = stNavegandoEdits then
  begin
    PanelDadosComplementares.Enabled := False;
    GridHistoricoFaturamento.ReadOnly := True;
    GridHistoricoReajuste.ReadOnly := True;
    GridPrevisaoFaturamento.ReadOnly := True;
  end
  else
  begin
    PanelDadosComplementares.Enabled := True;
    GridHistoricoFaturamento.ReadOnly := False;
    GridHistoricoReajuste.ReadOnly := False;
    GridPrevisaoFaturamento.ReadOnly := False;
  end;
end;
{$ENDREGION}

{$REGION 'Controles CRUD'}
function TFContrato.DoInserir: Boolean;
begin
  Result := inherited DoInserir;

  ConfigurarLayoutTela;
  if Result then
  begin
    DeletarArquivoTemporario;
    EditIdTipoContrato.SetFocus;
  end;
end;

function TFContrato.DoEditar: Boolean;
begin
  Result := inherited DoEditar;

  ConfigurarLayoutTela;
  if Result then
  begin
    EditIdTipoContrato.SetFocus;
  end;
end;

function TFContrato.DoExcluir: Boolean;
begin
  if inherited DoExcluir then
  begin
    try
      Result := TContratoController.Exclui(IdRegistroSelecionado);
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

function TFContrato.DoSalvar: Boolean;
var
  HistoricoFaturamento: TContratoHistFaturamentoVO;
  HistoricoReajuste: TContratoHistoricoReajusteVO;
  PrevisaoFaturamento: TContratoPrevFaturamentoVO;
begin
  Result := inherited DoSalvar;

  if Result then
  begin
    try
      if not Assigned(ObjetoVO) then
        ObjetoVO := TContratoVO.Create;

      TContratoVO(ObjetoVO).IdTipoContrato := EditIdTipoContrato.AsInteger;
      TContratoVO(ObjetoVO).TipoContratoNome := EditTipoContrato.Text;
      TContratoVO(ObjetoVO).ClassificacaoContabilConta := EditContaContabil.Text;
      TContratoVO(ObjetoVO).IdSolicitacaoServico := EditIdSolicitacaoServico.AsInteger;
      TContratoVO(ObjetoVO).ContratoSolicitacaoServicoDescricao := EditDescricaoSolicitacao.Text;
      TContratoVO(ObjetoVO).Numero := EditNumero.Text;
      TContratoVO(ObjetoVO).Nome := EditNome.Text;
      TContratoVO(ObjetoVO).DataCadastro := EditDataCadastro.Date;
      TContratoVO(ObjetoVO).DataInicioVigencia := EditDataInicioVigencia.Date;
      TContratoVO(ObjetoVO).DataFimVigencia := EditDataFimVigencia.Date;
      TContratoVO(ObjetoVO).DiaFaturamento := EditDiaFaturamento.Text;
      TContratoVO(ObjetoVO).Valor := EditValor.Value;
      TContratoVO(ObjetoVO).QuantidadeParcelas := EditQuantidadeParcelas.AsInteger;
      TContratoVO(ObjetoVO).IntervaloEntreParcelas := EditIntervaloEntreParcelas.AsInteger;
      TContratoVO(ObjetoVO).Descricao := MemoDescricao.Text;
      TContratoVO(ObjetoVO).Observacao := MemoObservacao.Text;

      UploadArquivo;

      // Histórico Faturamento
      {
        Deve ser enviado pelo Financeiro. O usuário também poderá impostar manualmente.
      }
      CDSHistoricoFaturamento.DisableControls;
      CDSHistoricoFaturamento.First;
      while not CDSHistoricoFaturamento.Eof do
      begin
          HistoricoFaturamento := TContratoHistFaturamentoVO.Create;
          HistoricoFaturamento.Id := CDSHistoricoFaturamento.FieldByName('ID').AsInteger;
          HistoricoFaturamento.IdContrato := TContratoVO(ObjetoVO).Id;
          HistoricoFaturamento.DataFatura := CDSHistoricoFaturamento.FieldByName('DATA_FATURA').AsDateTime;
          HistoricoFaturamento.Valor := CDSHistoricoFaturamento.FieldByName('VALOR').AsFloat;
          TContratoVO(ObjetoVO).ListaContratoHistFaturamentoVO.Add(HistoricoFaturamento);

        CDSHistoricoFaturamento.Next;
      end;
      CDSHistoricoFaturamento.EnableControls;

      // Histórico Reajuste
      {
        Cadastro manual realizado pelo usuário.
      }
      CDSHistoricoReajuste.DisableControls;
      CDSHistoricoReajuste.First;
      while not CDSHistoricoReajuste.Eof do
      begin
          HistoricoReajuste := TContratoHistoricoReajusteVO.Create;
          HistoricoReajuste.Id := CDSHistoricoReajuste.FieldByName('ID').AsInteger;
          HistoricoReajuste.IdContrato := TContratoVO(ObjetoVO).Id;
          HistoricoReajuste.Indice := CDSHistoricoReajuste.FieldByName('INDICE').AsFloat;
          HistoricoReajuste.ValorAnterior := CDSHistoricoReajuste.FieldByName('VALOR_ANTERIOR').AsFloat;
          HistoricoReajuste.ValorAtual := CDSHistoricoReajuste.FieldByName('VALOR_ATUAL').AsFloat;
          HistoricoReajuste.DataReajuste := CDSHistoricoReajuste.FieldByName('DATA_REAJUSTE').AsDateTime;
          HistoricoReajuste.Observacao := CDSHistoricoReajuste.FieldByName('OBSERVACAO').AsString;
          TContratoVO(ObjetoVO).ListaContratoHistoricoReajusteVO.Add(HistoricoReajuste);

        CDSHistoricoReajuste.Next;
      end;
      CDSHistoricoReajuste.EnableControls;

      // Previsão Faturamento
      CDSPrevisaoFaturamento.DisableControls;
      CDSPrevisaoFaturamento.First;
      while not CDSPrevisaoFaturamento.Eof do
      begin
          PrevisaoFaturamento := TContratoPrevFaturamentoVO.Create;
          PrevisaoFaturamento.Id := CDSPrevisaoFaturamento.FieldByName('ID').AsInteger;
          PrevisaoFaturamento.IdContrato := TContratoVO(ObjetoVO).Id;
          PrevisaoFaturamento.DataPrevista := CDSPrevisaoFaturamento.FieldByName('DATA_PREVISTA').AsDateTime;
          PrevisaoFaturamento.Valor := CDSPrevisaoFaturamento.FieldByName('VALOR').AsFloat;
          TContratoVO(ObjetoVO).ListaContratoPrevFaturamentoVO.Add(PrevisaoFaturamento);

        CDSPrevisaoFaturamento.Next;
      end;
      CDSPrevisaoFaturamento.EnableControls;

      if StatusTela = stInserindo then
      begin
        TContratoController.Insere(TContratoVO(ObjetoVO));
      end
      else if StatusTela = stEditando then
      begin
          TContratoController.Altera(TContratoVO(ObjetoVO));
      end;
      except
      Result := False;
    end;
  end;
  DeletarArquivoTemporario;
end;
{$ENDREGION}

{$REGION 'Campos Transientes'}
procedure TFContrato.EditContaContabilKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  ContabilContaVO :TContabilContaVO ;
begin
  if Key = VK_F1 then
  begin
    if EditContaContabil.Text <> '' then
      Filtro := 'CLASSIFICACAO = ' + EditContaContabil.Text
    else
      Filtro := 'ID=0';

    try
      EditContaContabil.Clear;

        ContabilContaVO := TContabilContaController.ConsultaObjeto(Filtro);
        if Assigned(ContabilContaVO) then
      begin
        EditContaContabil.Text := ContabilContaVO.Classificacao;
      end
      else
      begin
        Exit;
      end;
    finally
      EditIdSolicitacaoServico.SetFocus;
    end;
  end;
end;

procedure TFContrato.EditIdSolicitacaoServicoKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  ContratoSolicitacaoServicoVO :TContratoSolicitacaoServicoVO ;
begin
  if Key = VK_F1 then
  begin
    if EditIdSolicitacaoServico.Value <> 0 then
      Filtro := 'ID = ' + EditIdSolicitacaoServico.Text
    else
      Filtro := 'ID=0';

    try
      EditDescricaoSolicitacao.Clear;

        ContratoSolicitacaoServicoVO := TContratoSolicitacaoServicoController.ConsultaObjeto(Filtro);
        if Assigned(ContratoSolicitacaoServicoVO) then
      begin
        EditDescricaoSolicitacao.Text := ContratoSolicitacaoServicoVO.Descricao;
      end
      else
      begin
        Exit;
      end;
    finally
      EditIdSolicitacaoServico.SetFocus;
    end;
  end;
end;
procedure TFContrato.EditIdTipoContratoKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  TipoContratoVO :TTipoContratoVO ;
begin
  if Key = VK_F1 then
  begin
    if EditIdTipoContrato.Value <> 0 then
      Filtro := 'ID = ' + EditIdTipoContrato.Text
    else
      Filtro := 'ID=0';

    try
      EditTipoContrato.Clear;

        TipoContratoVO := TTipoContratoController.ConsultaObjeto(Filtro);
        if Assigned(TipoContratoVO) then
      begin
        EditTipoContrato.Text := TipoContratoVO.Nome;
      end
      else
      begin
        Exit;
      end;
    finally
      EditContaContabil.SetFocus;
    end;
  end;
end;
{$ENDREGION}

{$REGION 'Controle de Grid'}
procedure TFContrato.GridParaEdits;
var
  IdCabecalho: String;
  HistoricoFaturamento: TContratoHistFaturamentoVO;
  HistoricoReajuste: TContratoHistoricoReajusteVO;
  PrevisaoFaturamento: TContratoPrevFaturamentoVO;
  i: Integer;
begin
  inherited;

  if not CDSGrid.IsEmpty then
  begin
    IdCabecalho := IntToStr(IdRegistroSelecionado);
    ObjetoVO := TContratoController.ConsultaObjeto('ID=' + IdCabecalho);
 end;

  if Assigned(ObjetoVO) then
  begin

    EditIdTipoContrato.AsInteger := TContratoVO(ObjetoVO).IdTipoContrato;
    EditTipoContrato.Text := TContratoVO(ObjetoVO).TipoContratoNome;
    EditContaContabil.Text := TContratoVO(ObjetoVO).ClassificacaoContabilConta;
    EditIdSolicitacaoServico.AsInteger := TContratoVO(ObjetoVO).IdSolicitacaoServico;
    EditDescricaoSolicitacao.Text := TContratoVO(ObjetoVO).ContratoSolicitacaoServicoDescricao;
    EditNumero.Text := TContratoVO(ObjetoVO).Numero;
    EditNome.Text := TContratoVO(ObjetoVO).Nome;
    EditDataCadastro.Date := TContratoVO(ObjetoVO).DataCadastro;
    EditDataInicioVigencia.Date := TContratoVO(ObjetoVO).DataInicioVigencia;
    EditDataFimVigencia.Date := TContratoVO(ObjetoVO).DataFimVigencia;
    EditDiaFaturamento.Text := TContratoVO(ObjetoVO).DiaFaturamento;
    EditValor.Value := TContratoVO(ObjetoVO).Valor;
    EditQuantidadeParcelas.AsInteger := TContratoVO(ObjetoVO).QuantidadeParcelas;
    EditIntervaloEntreParcelas.AsInteger := TContratoVO(ObjetoVO).IntervaloEntreParcelas;
    MemoDescricao.Text := TContratoVO(ObjetoVO).Descricao;
    MemoObservacao.Text := TContratoVO(ObjetoVO).Observacao;

    // Histórico Faturamento
    for i := 0 to TContratoVO(ObjetoVO).ListaContratoHistFaturamentoVO.Count - 1 do
    begin
      HistoricoFaturamento := TContratoVO(ObjetoVO).ListaContratoHistFaturamentoVO[i];

      CDSHistoricoFaturamento.Append;
      CDSHistoricoFaturamento.FieldByName('ID').AsInteger := HistoricoFaturamento.Id;
      CDSHistoricoFaturamento.FieldByName('ID_CONTRATO').AsInteger := HistoricoFaturamento.IdContrato;
      CDSHistoricoFaturamento.FieldByName('DATA_FATURA').AsDateTime := HistoricoFaturamento.DataFatura;
      CDSHistoricoFaturamento.FieldByName('VALOR').AsFloat := HistoricoFaturamento.Valor;
      CDSHistoricoFaturamento.Post;
    end;

    // Histórico Reajuste
    for i := 0 to TContratoVO(ObjetoVO).ListaContratoHistoricoReajusteVO.Count - 1 do
    begin
      HistoricoReajuste := TContratoVO(ObjetoVO).ListaContratoHistoricoReajusteVO[i];

      CDSHistoricoReajuste.Append;
      CDSHistoricoReajuste.FieldByName('ID').AsInteger := HistoricoReajuste.Id;
      CDSHistoricoReajuste.FieldByName('ID_CONTRATO').AsInteger := HistoricoReajuste.IdContrato;
      CDSHistoricoReajuste.FieldByName('INDICE').AsFloat := HistoricoReajuste.Indice;
      CDSHistoricoReajuste.FieldByName('VALOR_ANTERIOR').AsFloat := HistoricoReajuste.ValorAnterior;
      CDSHistoricoReajuste.FieldByName('VALOR_ATUAL').AsFloat := HistoricoReajuste.ValorAtual;
      CDSHistoricoReajuste.FieldByName('DATA_REAJUSTE').AsDateTime := HistoricoReajuste.DataReajuste;
      CDSHistoricoReajuste.FieldByName('OBSERVACAO').AsString := HistoricoReajuste.Observacao;
      CDSHistoricoReajuste.Post;
    end;

    // Previsão Faturamento
    for i := 0 to TContratoVO(ObjetoVO).ListaContratoPrevFaturamentoVO.Count - 1 do
    begin
      PrevisaoFaturamento := TContratoVO(ObjetoVO).ListaContratoPrevFaturamentoVO[i];

      CDSPrevisaoFaturamento.Append;
      CDSPrevisaoFaturamento.FieldByName('ID').AsInteger := PrevisaoFaturamento.Id;
      CDSPrevisaoFaturamento.FieldByName('ID_CONTRATO').AsInteger := PrevisaoFaturamento.IdContrato;
      CDSPrevisaoFaturamento.FieldByName('DATA_PREVISTA').AsDateTime := PrevisaoFaturamento.DataPrevista;
      CDSPrevisaoFaturamento.FieldByName('VALOR').AsFloat := PrevisaoFaturamento.Valor;
      CDSPrevisaoFaturamento.Post;
    end;

    // Serializa o objeto para consultar posteriormente se houve alterações
    FormatSettings.DecimalSeparator := '.';
    StringObjetoOld := ObjetoVO.ToJSONString;
    FormatSettings.DecimalSeparator := ',';

  end;
  ConfigurarLayoutTela;
end;

procedure TFContrato.GridHistoricoFaturamentoKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  If Key = VK_RETURN then
    GridHistoricoFaturamento.SelectedIndex := GridHistoricoFaturamento.SelectedIndex + 1;
end;

procedure TFContrato.GridHistoricoReajusteKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  If Key = VK_RETURN then
    GridHistoricoReajuste.SelectedIndex := GridHistoricoReajuste.SelectedIndex + 1;
end;

procedure TFContrato.GridPrevisaoFaturamentoKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  If Key = VK_RETURN then
    GridPrevisaoFaturamento.SelectedIndex := GridPrevisaoFaturamento.SelectedIndex + 1;
end;

procedure TFContrato.GridDblClick(Sender: TObject);
begin
  inherited;
  ConfigurarLayoutTela;
end;
{$ENDREGION}

{$REGION 'Actions'}
procedure TFContrato.ActionGedExecute(Sender: TObject);
var
  Parametros: String;
begin
  if EditNumero.Text <> '' then
  begin
    {
      Parametros
      1 - Login
      2 - Senha
      3 - Aplicação que chamou
      4 - Nome do arquivo (Aplicacao que chamou + Tela que chamou + Numero Contrato
    }

    try
      Parametros := Sessao.Usuario.Login + ' ' +
                    Sessao.Usuario.Senha + ' ' +
                    'CONTRATOS' + ' ' +
                    'CONTRATOS_CONTRATO_' + EditNumero.Text;
      {
      ShellExecute(
            Handle,
            'open',
            'T2TiERPGed.exe',
            PChar(Parametros),
            '',
            SW_SHOWNORMAL
            );
            }

//      OpenDocument('T2TiERPGed.exe'); /// EXERCICIO: Chame o GED e passe os parâmetros acima para que ele armazene o documento
    except
      Application.MessageBox('Erro ao tentar executar o módulo.', 'Erro do Sistema', MB_OK + MB_ICONERROR);
    end;
  end
  else
  begin
    Application.MessageBox('É preciso informar o número do contrato.', 'Mensagem do Sistema', MB_OK + MB_ICONINFORMATION);
    EditNumero.SetFocus;
  end;
end;

procedure TFContrato.ActionGerarPrevisaoFaturamentoExecute(Sender: TObject);
var
  i: Integer;
  DataBase: TDateTime;
begin
  CDSPrevisaoFaturamento.Close;
  CDSPrevisaoFaturamento.Open;

  DataBase := StrToDateTime(EditDiaFaturamento.Text + Copy(EditDataInicioVigencia.Text, 3, 8));
  for i := 0 to EditQuantidadeParcelas.AsInteger - 1 do
  begin
    CDSPrevisaoFaturamento.Append;
    CDSPrevisaoFaturamento.FieldByName('ID_CONTRATO').AsInteger := IdRegistroSelecionado;

    {
      Se o usuário preencher o EditIntervaloEntreParcelas, o sistema vai ignorar o Dia do Faturamento
    }
    if EditIntervaloEntreParcelas.AsInteger = 0 then
      CDSPrevisaoFaturamento.FieldByName('DATA_PREVISTA').AsDateTime := StrToDateTime(EditDiaFaturamento.Text + Copy(DateToStr(DataBase + (i * 30)), 3, 8))
    else
      CDSPrevisaoFaturamento.FieldByName('DATA_PREVISTA').AsDateTime := DataBase + (i * EditIntervaloEntreParcelas.AsInteger);

    CDSPrevisaoFaturamento.FieldByName('VALOR').AsFloat := EditValor.Value;
    CDSPrevisaoFaturamento.Post;
  end;
end;

procedure TFContrato.ActionContratoDoTemplateExecute(Sender: TObject);
const
  ServerName = 'Word.Application';
var
  WordApp: Variant;
  Documento: widestring;
  Arquivo: String;
  AbrirArquivo: Boolean;
  DadosContratante: TViewContratoDadosContratanteVO;
  Texto: OLEVariant;
begin
  if EditIdSolicitacaoServico.AsInteger <> 0 then
  begin
    try
      try
        DadosContratante := TViewContratoDadosContratanteController.ConsultaObjeto('ID_SOLICITACAO=' + EditIdSolicitacaoServico.Text);

        if Assigned(DadosContratante) then
        begin
          AbrirArquivo := False;
          DeletarArquivoTemporario;
          // Se o usuário estiver inserindo um novo contrato, deixa ele fazer a consulta pelo template
          if StatusTela = stInserindo then
          begin
            /// EXERCICIO: Utilizar a janela FLookup
            //if CDSTransiente.RecordCount > 0 then
            if true then
            begin
              Filtro := '1.doc'; //CDSTransiente.FieldByName('ID').AsString + '.doc';
              TContratoTemplateController.BaixarArquivo(Filtro);
              AbrirArquivo := True;
            end;
          end
          else if StatusTela = stEditando then
          begin
            // Se o usuário estiver editando um Contrato, verifica se já existe um arquivo no servidor
            Filtro := IntToStr(TContratoVO(ObjetoVO).Id) + '.doc';
            Arquivo := TContratoController.BaixarArquivo(Filtro);
            // Caso não exista um arquivo de contrato, desce um Template
            if Arquivo = '' then
            begin
              Filtro := CDSTransiente.FieldByName('ID').AsString + '.doc';
              TContratoTemplateController.BaixarArquivo(Filtro);
              AbrirArquivo := True;
            end
            else
              AbrirArquivo := True;
          end;

          if AbrirArquivo then
          begin
            /// EXERCICIO: Tente usar o formulário FDocumentoWord em conjunto com o componente TActiveXContainer (LazActiveX)
            {
            Application.CreateForm(TFDocumentoWord, FDocumentoWord);
            FDocumentoWord.Operacao := 'Alterar';
            FDocumentoWord.NomeArquivo := Arquivo;
            }

            // Instancia o Word
            if Assigned(InitProc) then
              TProcedure(InitProc);

            try
              WordApp := CreateOleObject(ServerName);
            except
              WriteLn('Impossível Iniciar o Word.');
              Exit;
            end;

            if not FileExists(Arquivo) then
            begin
              /// EXERCICIO: Observe se existe algum problema neste procedimento. Tente criar o documento com o OLE.

              Handle := CreateFile(PChar(Arquivo), GENERIC_READ or GENERIC_WRITE, 0, nil, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, 0);
              CloseHandle(Handle);
              Handle := Unassigned;
            end;

            // Abre o word
            Documento := UTF8Decode(Arquivo);
            WordApp.Documents.Open(Documento);
            WordApp.Visible := True;

            {Substituições}
            WordApp.Selection.Find.ClearFormatting;

            WordApp.Selection.Find.Text := '<CONTRATADA>';
            Texto := Sessao.Empresa.RazaoSocial;
            WordApp.Selection.Find.Replacement.Text := Texto;
            WordApp.Selection.Find.Execute(Replace := 2);

            WordApp.Selection.Find.Text := '<CNPJ_CONTRATADA>';
            Texto := Sessao.Empresa.Cnpj;
            WordApp.Selection.Find.Replacement.Text := Texto;
            WordApp.Selection.Find.Execute(Replace := 2);

            WordApp.Selection.Find.Text := '<ENDERECO_CONTRATADA>';
            Texto := Sessao.Empresa.EnderecoPrincipal.Cidade;
            WordApp.Selection.Find.Replacement.Text := Texto;
            WordApp.Selection.Find.Execute(Replace := 2);

            WordApp.Selection.Find.Text := '<CONTRATANTE>';
            Texto := DadosContratante.Nome;
            WordApp.Selection.Find.Replacement.Text := Texto;
            WordApp.Selection.Find.Execute(Replace := 2);

            WordApp.Selection.Find.Text := '<CNPJ_CONTRATANTE>';
            Texto := DadosContratante.CpfCnpj;
            WordApp.Selection.Find.Replacement.Text := Texto;
            WordApp.Selection.Find.Execute(Replace := 2);

            WordApp.Selection.Find.Text := '<VALOR_MENSAL>';
            Texto := (FloatToStrf(EditValor.Value, ffNumber, 18, 2));
            WordApp.Selection.Find.Replacement.Text := Texto;
            WordApp.Selection.Find.Execute(Replace := 2);
            {
            // Contratada
            FDocumentoWord.ListaSubstituicoes.Add('<CONTRATADA>|' + Sessao.Empresa.RazaoSocial);
            FDocumentoWord.ListaSubstituicoes.Add('<CNPJ_CONTRATADA>|' + Sessao.Empresa.Cnpj);
            FDocumentoWord.ListaSubstituicoes.Add('<ENDERECO_CONTRATADA>|' + Sessao.Empresa.EnderecoPrincipal.Logradouro + Sessao.Empresa.EnderecoPrincipal.Numero + Sessao.Empresa.EnderecoPrincipal.Complemento);
            FDocumentoWord.ListaSubstituicoes.Add('<CIDADE_CONTRATADA>|' + Sessao.Empresa.EnderecoPrincipal.Cidade);
            FDocumentoWord.ListaSubstituicoes.Add('<UF_CONTRATADA>|' + Sessao.Empresa.EnderecoPrincipal.Uf);
            FDocumentoWord.ListaSubstituicoes.Add('<BAIRRO_CONTRATADA>|' + Sessao.Empresa.EnderecoPrincipal.Bairro);
            FDocumentoWord.ListaSubstituicoes.Add('<CEP_CONTRATADA>|' + Sessao.Empresa.EnderecoPrincipal.Cep);
            // Contratante
            FDocumentoWord.ListaSubstituicoes.Add('<CONTRATANTE>|' + DadosContratante.Nome);
            FDocumentoWord.ListaSubstituicoes.Add('<CNPJ_CONTRATANTE>|' + DadosContratante.CpfCnpj);
            FDocumentoWord.ListaSubstituicoes.Add('<ENDERECO_CONTRATANTE>|' + DadosContratante.Logradouro + DadosContratante.Numero + DadosContratante.Complemento);
            FDocumentoWord.ListaSubstituicoes.Add('<CIDADE_CONTRATANTE>|' + DadosContratante.Cidade);
            FDocumentoWord.ListaSubstituicoes.Add('<UF_CONTRATANTE>|' + DadosContratante.Uf);
            FDocumentoWord.ListaSubstituicoes.Add('<BAIRRO_CONTRATANTE>|' + DadosContratante.Bairro);
            FDocumentoWord.ListaSubstituicoes.Add('<CEP_CONTRATANTE>|' + DadosContratante.Cep);
            // Outros
            FDocumentoWord.ListaSubstituicoes.Add('<VALOR_MENSAL>|' + (FloatToStrf(EditValor.Value, ffNumber, 18, 2)));
            FDocumentoWord.ListaSubstituicoes.Add('<DATA_EXTENSO>|' + FormatDateTime('dddddd', EditDataInicioVigencia.Date));
            FDocumentoWord.ShowModal;
            }
          end;
        end
        else
          Application.MessageBox('Um template só pode ser utilizado para serviços prestados.', 'Mensagem do Sistema', MB_OK + MB_ICONINFORMATION);
      except
        on E: Exception do
          Application.MessageBox(PChar('Ocorreu um erro no acesso ao template. Informe a mensagem ao Administrador do sistema.' + #13 + #13 + E.Message), 'Erro do sistema', MB_OK + MB_ICONERROR);
      end;
    finally
    end;
  end
  else
  begin
    Application.MessageBox('É preciso informar a solicitação.', 'Mensagem do Sistema', MB_OK + MB_ICONINFORMATION);
    EditIdSolicitacaoServico.SetFocus;
  end;
end;

procedure TFContrato.DeletarArquivoTemporario;
begin
  if FileExists(ExtractFilePath(Application.ExeName)+'temp.doc') then
    DeleteFile(ExtractFilePath(Application.ExeName)+'temp.doc');
end;

procedure TFContrato.UploadArquivo;
begin
  /// EXERCICIO: caso esteja trabalhando em três camadas, implemente o upload do arquivo para o servidor
  /// Dica: o módulo Sped faz o download do arquivo do servidor para o cliente
end;
{$ENDREGION}

end.

