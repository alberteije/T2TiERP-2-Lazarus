{ *******************************************************************************
Title: T2Ti ERP
Description: Janela de Parâmetros para o módulo Escrita Fiscal

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
unit UFiscalParametros;

{$MODE Delphi}

interface

uses
  BrookHTTPClient, BrookFCLHTTPClientBroker, BrookHTTPUtils, BrookUtils, FPJson, ZDataset,
  LCLIntf, LCLType, LMessages, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UTelaCadastro, Menus, StdCtrls, ExtCtrls, Buttons, Grids, DBGrids,
  ComCtrls, LabeledCtrls, rxdbgrid, rxtoolbar, DBCtrls, StrUtils,
  Math, Constantes, CheckLst, ActnList, ToolWin, db, BufDataset, Biblioteca,
  ULookup, VO, FiscalParametroVO,
  FiscalParametroController;

  type

  TFFiscalParametros = class(TFTelaCadastro)
    PanelMestre: TPanel;
    PageControlItens: TPageControl;
    tsFederal: TTabSheet;
    PanelFederal: TPanel;
    EditVigencia: TLabeledMaskEdit;
    EditDescricaoVigencia: TLabeledEdit;
    tsEstadual: TTabSheet;
    PanelEstadual: TPanel;
    tsMunicipal: TTabSheet;
    PanelMunicipal: TPanel;
    ComboBoxApuracao: TLabeledComboBox;
    ComboBoxMicroempreendedorIndividual: TLabeledComboBox;
    ComboBoxCalcPisCofinsEfd: TLabeledComboBox;
    EditSimplesCodigoAcesso: TLabeledEdit;
    ComboBoxSimplesTabela: TLabeledComboBox;
    ComboBoxSimplesAtividade: TLabeledComboBox;
    ComboBoxPerfilSped: TLabeledComboBox;
    ComboBoxApuracaoConsolidada: TLabeledComboBox;
    ComboBoxSubstituicaoTributaria: TLabeledComboBox;
    ComboBoxFormaCalculoIss: TLabeledComboBox;
    ComboBoxCriterioLancamento: TLabeledComboBox;
    procedure FormCreate(Sender: TObject);

    procedure BotaoConsultarClick(Sender: TObject);
    procedure BotaoSalvarClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure GridParaEdits; override;

    // Controles CRUD
    function DoInserir: Boolean; override;
    function DoEditar: Boolean; override;
    function DoExcluir: Boolean; override;
    function DoSalvar: Boolean; override;

    procedure ConfigurarLayoutTela;
  end;

var
  FFiscalParametros: TFFiscalParametros;

implementation

uses UDataModule;
{$R *.lfm}

{$REGION 'Controles Infra'}
procedure TFFiscalParametros.BotaoConsultarClick(Sender: TObject);
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
    RetornoConsulta := TFiscalParametroController.Consulta(Filtro, IntToStr(Pagina));
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

procedure TFFiscalParametros.BotaoSalvarClick(Sender: TObject);
begin
  inherited;
  BotaoConsultarClick(Sender);
end;

procedure TFFiscalParametros.FormCreate(Sender: TObject);
begin
  ClasseObjetoGridVO := TFiscalParametroVO;
  ObjetoController := TFiscalParametroController.Create;

  inherited;
  BotaoImprimir.Visible := False;
end;

procedure TFFiscalParametros.ConfigurarLayoutTela;
begin
  PanelEdits.Enabled := True;

  if StatusTela = stNavegandoEdits then
  begin
    PanelMestre.Enabled := False;
    PanelFederal.Enabled := False;
    PanelEstadual.Enabled := False;
    PanelMunicipal.Enabled := False;
  end
  else
  begin
    PanelMestre.Enabled := True;
    PanelFederal.Enabled := True;
    PanelEstadual.Enabled := True;
    PanelMunicipal.Enabled := True;
  end;
end;
{$ENDREGION}

{$REGION 'Controles CRUD'}
function TFFiscalParametros.DoInserir: Boolean;
begin
  Result := inherited DoInserir;

  ConfigurarLayoutTela;
  if Result then
  begin
    EditVigencia.SetFocus;
  end;
end;

function TFFiscalParametros.DoEditar: Boolean;
begin
  Result := inherited DoEditar;

  ConfigurarLayoutTela;
  if Result then
  begin
    EditVigencia.SetFocus;
  end;
end;

function TFFiscalParametros.DoExcluir: Boolean;
begin
  if inherited DoExcluir then
  begin
    try
      Result := TFiscalParametroController.Exclui(IdRegistroSelecionado);
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

function TFFiscalParametros.DoSalvar: Boolean;
begin
  Result := inherited DoSalvar;

  if Result then
  begin
    try
      if not Assigned(ObjetoVO) then
        ObjetoVO := TFiscalParametroVO.Create;

      TFiscalParametroVO(ObjetoVO).IdEmpresa := Sessao.Empresa.Id;
      TFiscalParametroVO(ObjetoVO).Vigencia := EditVigencia.Text;
      TFiscalParametroVO(ObjetoVO).DescricaoVigencia := EditDescricaoVigencia.Text;
      TFiscalParametroVO(ObjetoVO).CriterioLancamento := Copy(ComboBoxCriterioLancamento.Text, 1, 1);
      // Federal
      TFiscalParametroVO(ObjetoVO).Apuracao := IntToStr(ComboBoxApuracao.ItemIndex + 1);
      TFiscalParametroVO(ObjetoVO).MicroempreeIndividual := IfThen(ComboBoxMicroempreendedorIndividual.ItemIndex = 0, 'S', 'N');
      TFiscalParametroVO(ObjetoVO).CalcPisCofinsEfd := Copy(ComboBoxCalcPisCofinsEfd.Text, 1, 2);
      TFiscalParametroVO(ObjetoVO).SimplesCodigoAcesso := EditSimplesCodigoAcesso.Text;
      TFiscalParametroVO(ObjetoVO).SimplesTabela := IntToStr(ComboBoxSimplesTabela.ItemIndex + 1);
      TFiscalParametroVO(ObjetoVO).SimplesAtividade := Copy(ComboBoxSimplesAtividade.Text, 1, 2);
      // Estadual
      TFiscalParametroVO(ObjetoVO).PerfilSped := Copy(ComboBoxPerfilSped.Text, 1, 1);
      TFiscalParametroVO(ObjetoVO).ApuracaoConsolidada := IfThen(ComboBoxApuracaoConsolidada.ItemIndex = 0, 'S', 'N');
      TFiscalParametroVO(ObjetoVO).SubstituicaoTributaria := IfThen(ComboBoxSubstituicaoTributaria.ItemIndex = 0, 'S', 'N');
      // Municipal
      TFiscalParametroVO(ObjetoVO).FormaCalculoIss := Copy(ComboBoxFormaCalculoIss.Text, 1, 2);

      if StatusTela = stInserindo then
      begin
        TFiscalParametroController.Insere(TFiscalParametroVO(ObjetoVO));
      end
      else if StatusTela = stEditando then
      begin
        if TFiscalParametroVO(ObjetoVO).ToJSONString <> StringObjetoOld then
        begin
          TFiscalParametroController.Altera(TFiscalParametroVO(ObjetoVO));
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
procedure TFFiscalParametros.GridParaEdits;
var
  IdCabecalho: String;
begin
  inherited;

  if not CDSGrid.IsEmpty then
  begin
    IdCabecalho := IntToStr(IdRegistroSelecionado);
    ObjetoVO := TFiscalParametroController.ConsultaObjeto('ID=' + IdCabecalho);
  end;

  if Assigned(ObjetoVO) then
  begin
    EditVigencia.Text := TFiscalParametroVO(ObjetoVO).Vigencia;
    EditDescricaoVigencia.Text := TFiscalParametroVO(ObjetoVO).DescricaoVigencia;
    ComboBoxCriterioLancamento.ItemIndex := AnsiIndexStr(TFiscalParametroVO(ObjetoVO).CriterioLancamento, ['L', 'A', 'N']);
    // Federal
    ComboBoxApuracao.ItemIndex := AnsiIndexStr(TFiscalParametroVO(ObjetoVO).Apuracao, ['1', '2']);
    ComboBoxMicroempreendedorIndividual.ItemIndex := AnsiIndexStr(TFiscalParametroVO(ObjetoVO).MicroempreeIndividual, ['S', 'N']);
    ComboBoxCalcPisCofinsEfd.ItemIndex := AnsiIndexStr(TFiscalParametroVO(ObjetoVO).CalcPisCofinsEfd, ['AB', 'AD', 'UP']);
    EditSimplesCodigoAcesso.Text := TFiscalParametroVO(ObjetoVO).SimplesCodigoAcesso;
    ComboBoxSimplesTabela.ItemIndex := AnsiIndexStr(TFiscalParametroVO(ObjetoVO).SimplesTabela, ['1', '2']);
    ComboBoxSimplesAtividade.ItemIndex := AnsiIndexStr(TFiscalParametroVO(ObjetoVO).SimplesAtividade, ['CO', 'IN', 'S1', 'S2', 'S3']);
    // Estadual
    ComboBoxPerfilSped.ItemIndex := AnsiIndexStr(TFiscalParametroVO(ObjetoVO).PerfilSped, ['A', 'B', 'C']);
    ComboBoxApuracaoConsolidada.ItemIndex := AnsiIndexStr(TFiscalParametroVO(ObjetoVO).ApuracaoConsolidada, ['S', 'N']);
    ComboBoxSubstituicaoTributaria.ItemIndex := AnsiIndexStr(TFiscalParametroVO(ObjetoVO).SubstituicaoTributaria, ['S', 'N']);
    // Municipal
    ComboBoxFormaCalculoIss.ItemIndex := AnsiIndexStr(TFiscalParametroVO(ObjetoVO).FormaCalculoIss, ['NO', 'PH', 'VF']);
  end;

  ConfigurarLayoutTela;
end;
{$ENDREGION}

/// EXERCICIO
///  Atenção para as tabelas FISCAL_MUNICIPAL_REGIME, FISCAL_ESTADUAL_REGIME e FISCAL_ESTADUAL_PORTE

end.

