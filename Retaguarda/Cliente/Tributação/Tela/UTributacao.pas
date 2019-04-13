{ *******************************************************************************
Title: T2Ti ERP
Description: Janela Cadastro de Tributação

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
unit UTributacao;

{$MODE Delphi}

interface

uses
  BrookHTTPClient, BrookFCLHTTPClientBroker, BrookHTTPUtils, BrookUtils, FPJson, ZDataset,
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UTelaCadastro, Menus, StdCtrls, ExtCtrls, Buttons, Grids, DBGrids,
  ComCtrls, LabeledCtrls, rxdbgrid, rxtoolbar, DBCtrls, BufDataset, db, StrUtils,
  Math, Constantes, CheckLst, ActnList, ToolWin, ShellApi, Biblioteca, VO;

type

  { TFTributacao }

  TFTributacao = class(TFTelaCadastro)
    CDSIcms: TBufDataset;
    GridIcms: TRxDBGrid;
    ScrollBox: TScrollBox;
    BevelEdits: TBevel;
    PageControlDadosTributacao: TPageControl;
    ToolPanel1: TToolPanel;
    tsPis: TTabSheet;
    tsIcms: TTabSheet;
    PanelIcms: TPanel;
    tsCofins: TTabSheet;
    PanelCofins: TPanel;
    EditIdOperacaoFiscal: TLabeledCalcEdit;
    EditOperacaoFiscal: TLabeledEdit;
    EditIdGrupoTributario: TLabeledCalcEdit;
    EditGrupoTributario: TLabeledEdit;
    PanelPis: TPanel;
    EditPorcentoBaseCalculoPis: TLabeledCalcEdit;
    DSIcms: TDataSource;
    tsIpi: TTabSheet;
    PanelIpi: TPanel;
    ActionManager1: TActionList;
    ActionUf: TAction;
    EditCodigoCstPis: TLabeledCalcEdit;
    EditCstPis: TLabeledEdit;
    EditCodigoApuracaoEfdPis: TLabeledCalcEdit;
    EditDescricaoCodigoApuracaoEfdPis: TLabeledEdit;
    ComboboxModalidadeBcPis: TLabeledComboBox;
    EditAliquotaPorcentoPis: TLabeledCalcEdit;
    EditAliquotaUnidadePis: TLabeledCalcEdit;
    EditValorPrecoMaximoPis: TLabeledCalcEdit;
    EditValorPautaFiscalPis: TLabeledCalcEdit;
    EditPorcentoBaseCalculoCofins: TLabeledCalcEdit;
    EditCodigoCstCofins: TLabeledCalcEdit;
    EditCstCofins: TLabeledEdit;
    EditCodigoApuracaoEfdCofins: TLabeledCalcEdit;
    EditDescricaoCodigoApuracaoEfdCofins: TLabeledEdit;
    ComboboxModalidadeBcCofins: TLabeledComboBox;
    EditAliquotaPorcentoCofins: TLabeledCalcEdit;
    EditAliquotaUnidadeCofins: TLabeledCalcEdit;
    EditValorPrecoMaximoCofins: TLabeledCalcEdit;
    EditValorPautaFiscalCofins: TLabeledCalcEdit;
    EditPorcentoBaseCalculoIpi: TLabeledCalcEdit;
    EditCodigoCstIpi: TLabeledCalcEdit;
    EditCstIpi: TLabeledEdit;
    EditIdTipoReceitaDipi: TLabeledCalcEdit;
    EditTipoReceitaDipi: TLabeledEdit;
    ComboboxModalidadeBcIpi: TLabeledComboBox;
    EditAliquotaPorcentoIpi: TLabeledCalcEdit;
    EditAliquotaUnidadeIpi: TLabeledCalcEdit;
    EditValorPrecoMaximoIpi: TLabeledCalcEdit;
    EditValorPautaFiscalIpi: TLabeledCalcEdit;
    ActionExcluirItem: TAction;
    procedure FormCreate(Sender: TObject);
    procedure GridIcmsKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure ActionUfExecute(Sender: TObject);
    procedure ActionExcluirItemExecute(Sender: TObject);
    procedure EditIdOperacaoFiscalKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure EditIdGrupoTributarioKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
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
  FTributacao: TFTributacao;

implementation

uses UDataModule, ULookup, TributConfiguraOfGtVO, TributConfiguraOfGtController,
  TributGrupoTributarioVO, TributOperacaoFiscalVO, TributPisCodApuracaoVO,
  TributCofinsCodApuracaoVO, TributIpiDipiVO, TributIcmsUfVO, TributOperacaoFiscalController,
  TributGrupoTributarioController, UfVO, UfController, CfopVO, CfopController,
  CsosnBVO, CsosnBController, CstIcmsBVO, CstIcmsBController, CstPisVO, CstPisController,
  CstCofinsVO, EfdTabela435VO, EfdTabela435Controller, CstCofinsController,
  CstIpiVO, CstIpiController, TipoReceitaDipiVO, TipoReceitaDipiController;

{$R *.lfm}

{$REGION 'Infra'}
procedure TFTributacao.BotaoConsultarClick(Sender: TObject);
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
    RetornoConsulta := TTributConfiguraOfGtController.Consulta(Filtro, IntToStr(Pagina));
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

procedure TFTributacao.BotaoSalvarClick(Sender: TObject);
begin
  inherited;
  BotaoConsultarClick(Sender);
end;

procedure TFTributacao.FormCreate(Sender: TObject);
begin
  ClasseObjetoGridVO := TTributConfiguraOfGtVO;
  ObjetoController := TTributConfiguraOfGtController.Create;

  inherited;

  ConfiguraCDSFromVO(CDSIcms, TTributIcmsUfVO);
  ConfiguraGridFromVO(GridIcms, TTributIcmsUfVO);
end;

procedure TFTributacao.LimparCampos;
begin
  inherited;
  CDSIcms.Close;
  CDSIcms.Open;
end;

procedure TFTributacao.ConfigurarLayoutTela;
begin
  PanelEdits.Enabled := True;
  PageControlDadosTributacao.ActivePageIndex := 0;

  if StatusTela = stNavegandoEdits then
  begin
    GridIcms.ReadOnly := True;
    PanelPis.Enabled := False;
    PanelCofins.Enabled := False;
    PanelIpi.Enabled := False;
  end
  else
  begin
    GridIcms.ReadOnly := False;
    PanelPis.Enabled := True;
    PanelCofins.Enabled := True;
    PanelIpi.Enabled := True;
  end;
end;
{$ENDREGION}

{$REGION 'Controles CRUD'}
function TFTributacao.DoInserir: Boolean;
begin
  Result := inherited DoInserir;

  if Result then
  begin
    ConfigurarLayoutTela;
    EditIdOperacaoFiscal.SetFocus;
  end;
end;

function TFTributacao.DoEditar: Boolean;
begin
  Result := inherited DoEditar;

  if Result then
  begin
    ConfigurarLayoutTela;
    EditIdOperacaoFiscal.SetFocus;
  end;
end;

function TFTributacao.DoExcluir: Boolean;
begin
  if inherited DoExcluir then
  begin
    try
      Result := TTributConfiguraOfGtController.Exclui(IdRegistroSelecionado);
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

function TFTributacao.DoSalvar: Boolean;
var
  TributIcmsUf: TTributIcmsUfVO;
begin
  if (EditIdOperacaoFiscal.AsInteger <= 0) or (EditIdGrupoTributario.AsInteger <= 0) then
  begin
    Application.MessageBox('Operação Fiscal ou Grupo Tributário não podem ficar em branco.', 'Mensagem do Sistema', MB_OK + MB_ICONINFORMATION);
    EditIdOperacaoFiscal.SetFocus;
    Exit(False);
  end;

  Result := inherited DoSalvar;

  if Result then
  begin
    try
      if not Assigned(ObjetoVO) then
        ObjetoVO := TTributConfiguraOfGtVO.Create;

      { Cabeçalho - Configura }
      TTributConfiguraOfGtVO(ObjetoVO).IdTributOperacaoFiscal := EditIdOperacaoFiscal.AsInteger;
      TTributConfiguraOfGtVO(ObjetoVO).TributOperacaoFiscalDescricao := EditOperacaoFiscal.Text;
      TTributConfiguraOfGtVO(ObjetoVO).IdTributGrupoTributario := EditIdGrupoTributario.AsInteger;
      TTributConfiguraOfGtVO(ObjetoVO).TributGrupoTributarioDescricao := EditGrupoTributario.Text;

      { Pis }
      if (EditCodigoCstPis.AsInteger > 0) and (EditCodigoApuracaoEfdPis.AsInteger > 0) then
      begin
        TTributConfiguraOfGtVO(ObjetoVO).TributPisCodApuracaoVO.CstPis := StringOfChar('0', 2 - Length(EditCodigoCstPis.Text)) + EditCodigoCstPis.Text;
        TTributConfiguraOfGtVO(ObjetoVO).TributPisCodApuracaoVO.EfdTabela435 := StringOfChar('0', 2 - Length(EditCodigoApuracaoEfdPis.Text)) + EditCodigoApuracaoEfdPis.Text;
        TTributConfiguraOfGtVO(ObjetoVO).TributPisCodApuracaoVO.ModalidadeBaseCalculo := IntToStr(ComboboxModalidadeBcPis.ItemIndex);
        TTributConfiguraOfGtVO(ObjetoVO).TributPisCodApuracaoVO.PorcentoBaseCalculo := EditPorcentoBaseCalculoPis.Value;
        TTributConfiguraOfGtVO(ObjetoVO).TributPisCodApuracaoVO.AliquotaPorcento := EditAliquotaPorcentoPis.Value;
        TTributConfiguraOfGtVO(ObjetoVO).TributPisCodApuracaoVO.AliquotaUnidade := EditAliquotaUnidadePis.Value;
        TTributConfiguraOfGtVO(ObjetoVO).TributPisCodApuracaoVO.ValorPrecoMaximo := EditValorPrecoMaximoPis.Value;
        TTributConfiguraOfGtVO(ObjetoVO).TributPisCodApuracaoVO.ValorPautaFiscal := EditValorPautaFiscalPis.Value;
      end;

      { Cofins }
      if (EditCodigoCstCofins.AsInteger > 0) and (EditCodigoApuracaoEfdCofins.AsInteger > 0) then
      begin
        TTributConfiguraOfGtVO(ObjetoVO).TributCofinsCodApuracaoVO.CstCofins := StringOfChar('0', 2 - Length(EditCodigoCstCofins.Text)) + EditCodigoCstCofins.Text;
        TTributConfiguraOfGtVO(ObjetoVO).TributCofinsCodApuracaoVO.EfdTabela435 := StringOfChar('0', 2 - Length(EditCodigoApuracaoEfdCofins.Text)) + EditCodigoApuracaoEfdCofins.Text;
        TTributConfiguraOfGtVO(ObjetoVO).TributCofinsCodApuracaoVO.ModalidadeBaseCalculo := IntToStr(ComboboxModalidadeBcCofins.ItemIndex);
        TTributConfiguraOfGtVO(ObjetoVO).TributCofinsCodApuracaoVO.PorcentoBaseCalculo := EditPorcentoBaseCalculoCofins.Value;
        TTributConfiguraOfGtVO(ObjetoVO).TributCofinsCodApuracaoVO.AliquotaPorcento := EditAliquotaPorcentoCofins.Value;
        TTributConfiguraOfGtVO(ObjetoVO).TributCofinsCodApuracaoVO.AliquotaUnidade := EditAliquotaUnidadeCofins.Value;
        TTributConfiguraOfGtVO(ObjetoVO).TributCofinsCodApuracaoVO.ValorPrecoMaximo := EditValorPrecoMaximoCofins.Value;
        TTributConfiguraOfGtVO(ObjetoVO).TributCofinsCodApuracaoVO.ValorPautaFiscal := EditValorPautaFiscalCofins.Value;
      end;

      { Ipi }
      if Trim(EditCstIpi.Text) <> '' then
      begin
        TTributConfiguraOfGtVO(ObjetoVO).TributIpiDipiVO.CstIpi := StringOfChar('0', 2 - Length(EditCodigoCstIpi.Text)) + EditCodigoCstIpi.Text;
        TTributConfiguraOfGtVO(ObjetoVO).TributIpiDipiVO.IdTipoReceitaDipi := EditIdTipoReceitaDipi.AsInteger;
        TTributConfiguraOfGtVO(ObjetoVO).TributIpiDipiVO.ModalidadeBaseCalculo := IntToStr(ComboboxModalidadeBcIpi.ItemIndex);
        TTributConfiguraOfGtVO(ObjetoVO).TributIpiDipiVO.PorcentoBaseCalculo := EditPorcentoBaseCalculoIpi.Value;
        TTributConfiguraOfGtVO(ObjetoVO).TributIpiDipiVO.AliquotaPorcento := EditAliquotaPorcentoIpi.Value;
        TTributConfiguraOfGtVO(ObjetoVO).TributIpiDipiVO.AliquotaUnidade := EditAliquotaUnidadeIpi.Value;
        TTributConfiguraOfGtVO(ObjetoVO).TributIpiDipiVO.ValorPrecoMaximo := EditValorPrecoMaximoIpi.Value;
        TTributConfiguraOfGtVO(ObjetoVO).TributIpiDipiVO.ValorPautaFiscal := EditValorPautaFiscalIpi.Value;
      end;

      { ICMS por UF }
      /// EXERCICIO: persista os dados de ICMS

      if StatusTela = stInserindo then
      begin
        TTributConfiguraOfGtController.Insere(TTributConfiguraOfGtVO(ObjetoVO));
      end
      else if StatusTela = stEditando then
      begin
        if TTributConfiguraOfGtVO(ObjetoVO).ToJSONString <> StringObjetoOld then
        begin
          TTributConfiguraOfGtController.Altera(TTributConfiguraOfGtVO(ObjetoVO));
        end
        else
          Application.MessageBox('Nenhum dado foi alterado.', 'Mensagem do Sistema', MB_OK + MB_ICONINFORMATION);
      end;

    except
      Result := False;
    end;
  end;
end;
{$ENDREGION}

{$REGION 'Controle de Grid'}
procedure TFTributacao.GridParaEdits;
var
  IdCabecalho: String;
begin
  inherited;

  if not CDSGrid.IsEmpty then
  begin
    IdCabecalho := IntToStr(IdRegistroSelecionado);
    ObjetoVO := TTributConfiguraOfGtController.ConsultaObjeto('ID=' + IdCabecalho);
  end;

  if Assigned(ObjetoVO) then
  begin

    { Cabeçalho - Configura }
    EditIdOperacaoFiscal.AsInteger := TTributConfiguraOfGtVO(ObjetoVO).IdTributOperacaoFiscal;
    EditOperacaoFiscal.Text := TTributConfiguraOfGtVO(ObjetoVO).TributOperacaoFiscalVO.Descricao;
    EditIdGrupoTributario.AsInteger := TTributConfiguraOfGtVO(ObjetoVO).IdTributGrupoTributario;
    EditGrupoTributario.Text := TTributConfiguraOfGtVO(ObjetoVO).TributGrupoTributarioVO.Descricao;

    { Pis }
    EditCodigoCstPis.Text := TTributConfiguraOfGtVO(ObjetoVO).TributPisCodApuracaoVO.CstPis;
    EditCstPis.Text := TTributConfiguraOfGtVO(ObjetoVO).TributPisCodApuracaoVO.CstPisVO.Descricao;
    EditCodigoApuracaoEfdPis.Text := TTributConfiguraOfGtVO(ObjetoVO).TributPisCodApuracaoVO.EfdTabela435;
    EditDescricaoCodigoApuracaoEfdPis.Text := TTributConfiguraOfGtVO(ObjetoVO).TributPisCodApuracaoVO.CodigoApuracaoEfdVO.Descricao;
    ComboboxModalidadeBcPis.ItemIndex := AnsiIndexStr(TTributConfiguraOfGtVO(ObjetoVO).TributPisCodApuracaoVO.ModalidadeBaseCalculo, ['0', '1']);
    EditPorcentoBaseCalculoPis.Value := TTributConfiguraOfGtVO(ObjetoVO).TributPisCodApuracaoVO.PorcentoBaseCalculo;
    EditAliquotaPorcentoPis.Value := TTributConfiguraOfGtVO(ObjetoVO).TributPisCodApuracaoVO.AliquotaPorcento;
    EditAliquotaUnidadePis.Value := TTributConfiguraOfGtVO(ObjetoVO).TributPisCodApuracaoVO.AliquotaUnidade;
    EditValorPrecoMaximoPis.Value := TTributConfiguraOfGtVO(ObjetoVO).TributPisCodApuracaoVO.ValorPrecoMaximo;
    EditValorPautaFiscalPis.Value := TTributConfiguraOfGtVO(ObjetoVO).TributPisCodApuracaoVO.ValorPautaFiscal;

    { Cofins }
    EditCodigoCstCofins.Text := TTributConfiguraOfGtVO(ObjetoVO).TributCofinsCodApuracaoVO.CstCofins;
    EditCstCofins.Text := TTributConfiguraOfGtVO(ObjetoVO).TributCofinsCodApuracaoVO.CstCofinsVO.Descricao;
    EditCodigoApuracaoEfdCofins.Text := TTributConfiguraOfGtVO(ObjetoVO).TributCofinsCodApuracaoVO.EfdTabela435;
    EditDescricaoCodigoApuracaoEfdCofins.Text := TTributConfiguraOfGtVO(ObjetoVO).TributCofinsCodApuracaoVO.CodigoApuracaoEfdVO.Descricao;
    ComboboxModalidadeBcCofins.ItemIndex := AnsiIndexStr(TTributConfiguraOfGtVO(ObjetoVO).TributCofinsCodApuracaoVO.ModalidadeBaseCalculo, ['0', '1']);
    EditPorcentoBaseCalculoCofins.Value := TTributConfiguraOfGtVO(ObjetoVO).TributCofinsCodApuracaoVO.PorcentoBaseCalculo;
    EditAliquotaPorcentoCofins.Value := TTributConfiguraOfGtVO(ObjetoVO).TributCofinsCodApuracaoVO.AliquotaPorcento;
    EditAliquotaUnidadeCofins.Value := TTributConfiguraOfGtVO(ObjetoVO).TributCofinsCodApuracaoVO.AliquotaUnidade;
    EditValorPrecoMaximoCofins.Value := TTributConfiguraOfGtVO(ObjetoVO).TributCofinsCodApuracaoVO.ValorPrecoMaximo;
    EditValorPautaFiscalCofins.Value := TTributConfiguraOfGtVO(ObjetoVO).TributCofinsCodApuracaoVO.ValorPautaFiscal;

    { Ipi }
    EditCodigoCstIpi.Text := TTributConfiguraOfGtVO(ObjetoVO).TributIpiDipiVO.CstIpi;
    EditCstIpi.Text:= TTributConfiguraOfGtVO(ObjetoVO).TributIpiDipiVO.CstIpiVO.Descricao;
    EditIdTipoReceitaDipi.AsInteger := TTributConfiguraOfGtVO(ObjetoVO).TributIpiDipiVO.IdTipoReceitaDipi;
    EditTipoReceitaDipi.Text := TTributConfiguraOfGtVO(ObjetoVO).TributIpiDipiVO.TipoReceitaDipiVO.Descricao;
    ComboboxModalidadeBcIpi.ItemIndex := AnsiIndexStr(TTributConfiguraOfGtVO(ObjetoVO).TributIpiDipiVO.ModalidadeBaseCalculo, ['0', '1']);
    EditPorcentoBaseCalculoIpi.Value := TTributConfiguraOfGtVO(ObjetoVO).TributIpiDipiVO.PorcentoBaseCalculo;
    EditAliquotaPorcentoIpi.Value := TTributConfiguraOfGtVO(ObjetoVO).TributIpiDipiVO.AliquotaPorcento;
    EditAliquotaUnidadeIpi.Value := TTributConfiguraOfGtVO(ObjetoVO).TributIpiDipiVO.AliquotaUnidade;
    EditValorPrecoMaximoIpi.Value := TTributConfiguraOfGtVO(ObjetoVO).TributIpiDipiVO.ValorPrecoMaximo;
    EditValorPautaFiscalIpi.Value := TTributConfiguraOfGtVO(ObjetoVO).TributIpiDipiVO.ValorPautaFiscal;

    /// EXERCICIO
    /// carregue os dados de ICMS

    // Serializa o objeto para consultar posteriormente se houve alterações
    FormatSettings.DecimalSeparator := '.';
    StringObjetoOld := ObjetoVO.ToJSONString;
    FormatSettings.DecimalSeparator := ',';
  end;
end;

procedure TFTributacao.GridIcmsKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  UfVO: TUfVO;
  CfopVO: TCfopVO;
  CsosnBVO: TCsosnBVO;
  CstIcmsBVO: TCstIcmsBVO;
begin
  (*

  /// EXERCICIO: Implemente a busca usando a janela FLookup

  if Key = VK_F1 then
  begin
    if CDSIcms.IsEmpty then
    begin
      CDSIcms.Append;
      CDSIcms.Post;
    end;

    { UF }
    if GridIcms.SelectedIndex = 0 then
    begin
      try
        FLookup.ShowModal;

        UfVO := TUfVO.Create;
        ConsultarVO(FLookup.IdSelecionado, TVO(UfVO));

        if UfVO.Id > 0 then
        begin
          CDSIcms.Edit;
          CDSIcms.FieldByName('UF_DESTINO').AsString := UfVO.Sigla;
          CDSIcms.Post;
        end;
      finally
        CDSTransiente.Close;
      end;
    end;

    { CFOP }
    if GridIcms.SelectedIndex = 1 then
    begin
      try
        FLookup.ShowModal;

        CfopVO := TCfopVO.Create;
        ConsultarVO(FLookup.IdSelecionado, TVO(CfopVO));

        if CfopVO.Id > 0 then
        begin
          CDSIcms.Edit;
          CDSIcms.FieldByName('CFOP').AsInteger := CfopVO.Cfop;
          CDSIcms.Post;
        end;
      finally
        CDSTransiente.Close;
      end;
    end;

    { CSOSN }
    if GridIcms.SelectedIndex = 2 then
    begin
      try
        FLookup.ShowModal;

        CsosnBVO := TCsosnBVO.Create;
        ConsultarVO(FLookup.IdSelecionado, TVO(CsosnBVO));

        if CsosnBVO.Id > 0 then
        begin
          CDSIcms.Edit;
          CDSIcms.FieldByName('CSOSN_B').AsString := CsosnBVO.Codigo;
          CDSIcms.Post;
        end;
      finally
        CDSTransiente.Close;
      end;
    end;

    { CST }
    if GridIcms.SelectedIndex = 3 then
    begin
      try
        FLookup.ShowModal;

        CstIcmsBVO := TCstIcmsBVO.Create;
        ConsultarVO(FLookup.IdSelecionado, TVO(CstIcmsBVO));

        if CstIcmsBVO.Id > 0 then
        begin
          CDSIcms.Edit;
          CDSIcms.FieldByName('CST_B').AsString := CstIcmsBVO.Codigo;
          CDSIcms.Post;
        end;
      finally
        CDSTransiente.Close;
      end;
    end;

  end;

  *)

  //
  If Key = VK_RETURN then
    GridIcms.SelectedIndex := GridIcms.SelectedIndex + 1;
end;
{$ENDREGION}

{$REGION 'Actions'}
procedure TFTributacao.ActionUfExecute(Sender: TObject);
var
  Filtro: String;
  RetornoConsulta: TZQuery;
begin
  if Application.MessageBox('Deseja Importar as UFs? [os dados atuais serão excluídos]', 'Pergunta do Sistema', MB_YesNo + MB_IconQuestion) = IdYes then
  begin
    CDSIcms.DisableControls;
    CDSIcms.Close;
    CDSIcms.Open;

    Filtro := 'ID > 0';
    RetornoConsulta := TUfController.Consulta(Filtro, IntToStr(Pagina));
    RetornoConsulta.Active := True;
    RetornoConsulta.First;

    while not RetornoConsulta.eof do
    begin
      CDSIcms.Append;
      CDSIcms.FieldByName('UF_DESTINO').AsString := RetornoConsulta.FieldByName('SIGLA').AsString;
      CDSIcms.Post;
      RetornoConsulta.Next;
    end;
    CDSIcms.First;
    CDSIcms.EnableControls;
  end;
end;

procedure TFTributacao.ActionExcluirItemExecute(Sender: TObject);
begin
  if not CDSIcms.IsEmpty then
  begin
    if Application.MessageBox('Tem certeza que deseja excluir o registro selecionado?', 'Pergunta do Sistema', MB_YesNo + MB_IconQuestion) = IdYes then
    begin
      if StatusTela = stInserindo then
        CDSIcms.Delete
      else if StatusTela = stEditando then
      begin
        /// EXERCICIO: exclua o registro no banco de dados também
        CDSIcms.Delete;
      end;
    end;
  end
  else
    Application.MessageBox('Não existem dados para serem excluídos.', 'Mensagem do Sistema', MB_OK + MB_ICONINFORMATION);
end;
{$ENDREGION}

{$REGION 'Campos Transientes'}
procedure TFTributacao.EditIdOperacaoFiscalKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  Filtro: String;
  TributOperacaoFiscalVO: TTributOperacaoFiscalVO;
begin
  if Key = VK_F1 then
  begin
    if EditIdOperacaoFiscal.Value <> 0 then
      Filtro := 'ID = ' + EditIdOperacaoFiscal.Text
    else
      Filtro := 'ID=0';

    if EditIdOperacaoFiscal.Value <> 0 then
    begin
      try
        EditIdOperacaoFiscal.Clear;
        EditOperacaoFiscal.Clear;

        TributOperacaoFiscalVO := TTributOperacaoFiscalController.ConsultaObjeto(Filtro);

        if Assigned(TributOperacaoFiscalVO) then
        begin
          EditOperacaoFiscal.Text := TributOperacaoFiscalVO.Descricao;
          EditIdGrupoTributario.SetFocus;
        end
        else
        begin
          Application.MessageBox('Nenhum dado encontrado para o critério informado.', 'Mensagem do Sistema', MB_OK + MB_ICONINFORMATION);
          Exit;
          EditIdOperacaoFiscal.SetFocus;
        end;
      finally
      end;
    end;
  end;
end;

procedure TFTributacao.EditIdGrupoTributarioKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  Filtro: String;
  TributGrupoTributarioVO : TTributGrupoTributarioVO;
begin
  if Key = VK_F1 then
  begin
    if EditIdGrupoTributario.Value <> 0 then
      Filtro := 'ID = ' + EditIdGrupoTributario.Text
    else
      Filtro := 'ID=0';

    if EditIdOperacaoFiscal.Value <> 0 then
    begin
      try
        EditIdGrupoTributario.Clear;
        EditGrupoTributario.Clear;

        TributGrupoTributarioVO := TTributGrupoTributarioController.ConsultaObjeto(Filtro);

        if Assigned(TributGrupoTributarioVO) then
        begin
          EditGrupoTributario.Text := TributGrupoTributarioVO.Descricao;
          GridIcms.SetFocus;
        end
        else
        begin
          Exit;
          EditIdGrupoTributario.SetFocus;
        end;
      finally
      end;
    end;
  end;
end;

/// EXERCICIO: Implemente os demais campos de lookup

{$ENDREGION}

end.
