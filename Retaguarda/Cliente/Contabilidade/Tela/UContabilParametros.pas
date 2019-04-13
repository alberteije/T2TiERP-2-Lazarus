{ *******************************************************************************
Title: T2Ti ERP
Description: Janela Cadastro de Parâmetros para o módulo Contabilidade

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
unit UContabilParametros;

{$MODE Delphi}

interface

uses
  BrookHTTPClient, BrookFCLHTTPClientBroker, BrookHTTPUtils, BrookUtils, FPJson, ZDataset,
  LCLIntf, LCLType, LMessages, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UTelaCadastro, Menus, StdCtrls, ExtCtrls, Buttons, Grids, DBGrids,
  ComCtrls, LabeledCtrls, rxdbgrid, rxtoolbar, DBCtrls, StrUtils,
  Math, Constantes, CheckLst, ActnList, ToolWin, db, BufDataset, Biblioteca,
  ULookup, VO, ContabilParametroVO,
  ContabilParametroController;

  type

  { TFContabilParametros }

  TFContabilParametros = class(TFTelaCadastro)
    BevelEdits: TBevel;
    CDSContas: TBufDataset;
    EditNiveis: TLabeledCalcEdit;
    ComboBoxCompartilhaPlanoConta: TLabeledComboBox;
    ComboBoxInformarContaPor: TLabeledComboBox;
    EditMascara: TLabeledEdit;
    ComboBoxCompartilhaHistoricos: TLabeledComboBox;
    ComboBoxAlteraLancamentoOutro: TLabeledComboBox;
    ComboBoxHistoricoObrigatorio: TLabeledComboBox;
    ComboBoxPermiteLancamentoZerado: TLabeledComboBox;
    ComboBoxGeraInformativoSped: TLabeledComboBox;
    ComboBoxSpedFormaEscrituracaoContabil: TLabeledComboBox;
    EditSpedNomeLivroDiario: TLabeledEdit;
    PageControlItens: TPageControl;
    tsComplemento: TTabSheet;
    PanelComplemento: TPanel;
    tsContas: TTabSheet;
    PanelContas: TPanel;
    GroupBox1: TGroupBox;
    MemoAssinaturaEsquerda: TLabeledMemo;
    MemoAssinaturaDireita: TLabeledMemo;
    EditHistoricoPadraoResultado: TLabeledEdit;
    EditHistoricoPadraoLucro: TLabeledEdit;
    EditHistoricoPadraoPrejuizo: TLabeledEdit;
    GridContas: TRxDbGrid;
    DSContas: TDataSource;
    CDSContasCONTA: TStringField;
    CDSContasCLASSIFICACAO: TStringField;
    EditIdHistoricoPadraoResultado: TLabeledCalcEdit;
    EditIdHistoricoPadraoLucro: TLabeledCalcEdit;
    EditIdHistoricoPadraoPrejuizo: TLabeledCalcEdit;
    procedure FormCreate(Sender: TObject);
    procedure GridDblClick(Sender: TObject);
    procedure CDSContasAfterPost(DataSet: TDataSet);
    procedure GridContasKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure EditIdHistoricoPadraoResultadoKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure EditIdHistoricoPadraoLucroKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure EditIdHistoricoPadraoPrejuizoKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure BotaoConsultarClick(Sender: TObject);
    procedure BotaoSalvarClick(Sender: TObject);
  private
    { Private declarations }
    procedure PopularGridContas;
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
  FContabilParametros: TFContabilParametros;

implementation

uses ContabilContaController, ContabilContaVO, ContabilHistoricoVO, ContabilHistoricoController;

{$R *.lfm}

{$REGION 'Controles Infra'}
procedure TFContabilParametros.BotaoConsultarClick(Sender: TObject);
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
    RetornoConsulta := TContabilParametroController.Consulta(Filtro, IntToStr(Pagina));
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

procedure TFContabilParametros.BotaoSalvarClick(Sender: TObject);
begin
  inherited;
  BotaoConsultarClick(Sender);
end;

procedure TFContabilParametros.FormCreate(Sender: TObject);
begin
  ClasseObjetoGridVO := TContabilParametroVO;
  ObjetoController := TContabilParametroController.Create;

  inherited;
  BotaoImprimir.Visible := False;
  MenuImprimir.Visible := False;

  //configura Dataset
  CDSContas.Close;
  CDSContas.FieldDefs.Clear;

  CDSContas.FieldDefs.add('CONTA', ftString, 30);
  CDSContas.FieldDefs.add('CLASSIFICACAO', ftString, 30);
  CDSContas.CreateDataset;
  CDSContas.Open;
end;

procedure TFContabilParametros.LimparCampos;
begin
  inherited;
  CDSContas.Close;
  CDSContas.Open;
end;

procedure TFContabilParametros.ConfigurarLayoutTela;
begin
  PanelEdits.Enabled := True;

  if StatusTela = stNavegandoEdits then
  begin
    PanelComplemento.Enabled := False;
    PanelContas.Enabled := False;
  end
  else
  begin
    PanelComplemento.Enabled := True;
    PanelContas.Enabled := True;
  end;
end;
{$ENDREGION}

{$REGION 'Controles CRUD'}
function TFContabilParametros.DoInserir: Boolean;
begin
  Result := inherited DoInserir;

  if Result then
  begin
    ConfigurarLayoutTela;
    PopularGridContas;
    EditMascara.SetFocus;
  end;
end;

function TFContabilParametros.DoEditar: Boolean;
begin
  Result := inherited DoEditar;

  if Result then
  begin
    ConfigurarLayoutTela;
    PopularGridContas;
    EditMascara.SetFocus;
  end;
end;

function TFContabilParametros.DoExcluir: Boolean;
begin
  if inherited DoExcluir then
  begin
    try
      Result := TContabilParametroController.Exclui(IdRegistroSelecionado);
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

function TFContabilParametros.DoSalvar: Boolean;
begin
  Result := inherited DoSalvar;

  if Result then
  begin
    try
      if not Assigned(ObjetoVO) then
        ObjetoVO := TContabilParametroVO.Create;

      TContabilParametroVO(ObjetoVO).IdEmpresa := Sessao.Empresa.Id;
      TContabilParametroVO(ObjetoVO).Mascara := EditMascara.Text;
      TContabilParametroVO(ObjetoVO).Niveis := EditNiveis.AsInteger;
      TContabilParametroVO(ObjetoVO).InformarContaPor := IfThen(ComboBoxInformarContaPor.ItemIndex = 0, 'C', 'M');
      TContabilParametroVO(ObjetoVO).CompartilhaPlanoConta := IfThen(ComboBoxCompartilhaPlanoConta.ItemIndex = 0, 'S', 'N');
      TContabilParametroVO(ObjetoVO).CompartilhaHistoricos := IfThen(ComboBoxCompartilhaHistoricos.ItemIndex = 0, 'S', 'N');
      TContabilParametroVO(ObjetoVO).AlteraLancamentoOutro := IfThen(ComboBoxAlteraLancamentoOutro.ItemIndex = 0, 'S', 'N');
      TContabilParametroVO(ObjetoVO).HistoricoObrigatorio := IfThen(ComboBoxHistoricoObrigatorio.ItemIndex = 0, 'S', 'N');
      TContabilParametroVO(ObjetoVO).PermiteLancamentoZerado := IfThen(ComboBoxPermiteLancamentoZerado.ItemIndex = 0, 'S', 'N');
      TContabilParametroVO(ObjetoVO).GeraInformativoSped := IfThen(ComboBoxGeraInformativoSped.ItemIndex = 0, 'S', 'N');
      TContabilParametroVO(ObjetoVO).SpedFormaEscritDiario := Copy(ComboBoxSpedFormaEscrituracaoContabil.Text, 1, 3);
      TContabilParametroVO(ObjetoVO).SpedNomeLivroDiario := EditSpedNomeLivroDiario.Text;
      TContabilParametroVO(ObjetoVO).AssinaturaDireita := MemoAssinaturaDireita.Text;
      TContabilParametroVO(ObjetoVO).AssinaturaEsquerda := MemoAssinaturaEsquerda.Text;
      TContabilParametroVO(ObjetoVO).IdHistPadraoResultado := EditIdHistoricoPadraoResultado.AsInteger;
      TContabilParametroVO(ObjetoVO).IdHistPadraoLucro := EditIdHistoricoPadraoLucro.AsInteger;
      TContabilParametroVO(ObjetoVO).IdHistPadraoPrejuizo := EditIdHistoricoPadraoPrejuizo.AsInteger;

      // Contas
      CDSContas.DisableControls;
      CDSContas.First;
      while not CDSContas.Eof do
      begin
        TContabilParametroVO(ObjetoVO).ContaAtivo := CDSContas.FieldByName('CLASSIFICACAO').AsString;
        CDSContas.Next;
        TContabilParametroVO(ObjetoVO).ContaPassivo := CDSContas.FieldByName('CLASSIFICACAO').AsString;
        CDSContas.Next;
        TContabilParametroVO(ObjetoVO).ContaPatrimonioLiquido := CDSContas.FieldByName('CLASSIFICACAO').AsString;
        CDSContas.Next;
        TContabilParametroVO(ObjetoVO).ContaDepreciacaoAcumulada := CDSContas.FieldByName('CLASSIFICACAO').AsString;
        CDSContas.Next;
        TContabilParametroVO(ObjetoVO).ContaCapitalSocial := CDSContas.FieldByName('CLASSIFICACAO').AsString;
        CDSContas.Next;
        TContabilParametroVO(ObjetoVO).ContaResultadoExercicio := CDSContas.FieldByName('CLASSIFICACAO').AsString;
        CDSContas.Next;
        TContabilParametroVO(ObjetoVO).ContaPrejuizoAcumulado := CDSContas.FieldByName('CLASSIFICACAO').AsString;
        CDSContas.Next;
        TContabilParametroVO(ObjetoVO).ContaLucroAcumulado := CDSContas.FieldByName('CLASSIFICACAO').AsString;
        CDSContas.Next;
        TContabilParametroVO(ObjetoVO).ContaTituloPagar := CDSContas.FieldByName('CLASSIFICACAO').AsString;
        CDSContas.Next;
        TContabilParametroVO(ObjetoVO).ContaTituloReceber := CDSContas.FieldByName('CLASSIFICACAO').AsString;
        CDSContas.Next;
        TContabilParametroVO(ObjetoVO).ContaJurosPassivo := CDSContas.FieldByName('CLASSIFICACAO').AsString;
        CDSContas.Next;
        TContabilParametroVO(ObjetoVO).ContaJurosAtivo := CDSContas.FieldByName('CLASSIFICACAO').AsString;
        CDSContas.Next;
        TContabilParametroVO(ObjetoVO).ContaDescontoObtido := CDSContas.FieldByName('CLASSIFICACAO').AsString;
        CDSContas.Next;
        TContabilParametroVO(ObjetoVO).ContaDescontoConcedido := CDSContas.FieldByName('CLASSIFICACAO').AsString;
        CDSContas.Next;
        TContabilParametroVO(ObjetoVO).ContaCmv := CDSContas.FieldByName('CLASSIFICACAO').AsString;
        CDSContas.Next;
        TContabilParametroVO(ObjetoVO).ContaVenda := CDSContas.FieldByName('CLASSIFICACAO').AsString;
        CDSContas.Next;
        TContabilParametroVO(ObjetoVO).ContaVendaServico := CDSContas.FieldByName('CLASSIFICACAO').AsString;
        CDSContas.Next;
        TContabilParametroVO(ObjetoVO).ContaEstoque := CDSContas.FieldByName('CLASSIFICACAO').AsString;
        CDSContas.Next;
        TContabilParametroVO(ObjetoVO).ContaApuraResultado := CDSContas.FieldByName('CLASSIFICACAO').AsString;
        CDSContas.Next;
        TContabilParametroVO(ObjetoVO).ContaJurosApropriar := CDSContas.FieldByName('CLASSIFICACAO').AsString;
        CDSContas.Next;
      end;
      CDSContas.First;
      CDSContas.EnableControls;

      if StatusTela = stInserindo then
      begin
        TContabilParametroController.Insere(TContabilParametroVO(ObjetoVO));
      end
      else if StatusTela = stEditando then
      begin
        if TContabilParametroVO(ObjetoVO).ToJSONString <> StringObjetoOld then
        begin
          TContabilParametroController.Altera(TContabilParametroVO(ObjetoVO));
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
procedure TFContabilParametros.GridDblClick(Sender: TObject);
begin
  inherited;
  ConfigurarLayoutTela;
  PopularGridContas;
end;

procedure TFContabilParametros.GridParaEdits;
var
  IdCabecalho: String;
  HistoricoVO: TContabilHistoricoVO;
begin
  inherited;

  if not CDSGrid.IsEmpty then
  begin
    IdCabecalho := IntToStr(IdRegistroSelecionado);
    ObjetoVO := TContabilParametroController.ConsultaObjeto('ID=' + IdCabecalho);
  end;

  if Assigned(ObjetoVO) then
  begin

    EditMascara.Text := TContabilParametroVO(ObjetoVO).Mascara;
    EditNiveis.AsInteger := TContabilParametroVO(ObjetoVO).Niveis;
    ComboBoxInformarContaPor.ItemIndex := AnsiIndexStr(TContabilParametroVO(ObjetoVO).InformarContaPor, ['C', 'M']);
    ComboBoxCompartilhaPlanoConta.ItemIndex := AnsiIndexStr(TContabilParametroVO(ObjetoVO).CompartilhaPlanoConta, ['S', 'N']);
    ComboBoxCompartilhaHistoricos.ItemIndex := AnsiIndexStr(TContabilParametroVO(ObjetoVO).CompartilhaHistoricos, ['S', 'N']);
    ComboBoxAlteraLancamentoOutro.ItemIndex := AnsiIndexStr(TContabilParametroVO(ObjetoVO).AlteraLancamentoOutro, ['S', 'N']);
    ComboBoxHistoricoObrigatorio.ItemIndex := AnsiIndexStr(TContabilParametroVO(ObjetoVO).HistoricoObrigatorio, ['S', 'N']);
    ComboBoxPermiteLancamentoZerado.ItemIndex := AnsiIndexStr(TContabilParametroVO(ObjetoVO).PermiteLancamentoZerado, ['S', 'N']);
    ComboBoxGeraInformativoSped.ItemIndex := AnsiIndexStr(TContabilParametroVO(ObjetoVO).GeraInformativoSped, ['S', 'N']);
    ComboBoxSpedFormaEscrituracaoContabil.ItemIndex := AnsiIndexStr(TContabilParametroVO(ObjetoVO).SpedFormaEscritDiario, ['LDC', 'LDE', 'LBD']);

    EditSpedNomeLivroDiario.Text := TContabilParametroVO(ObjetoVO).SpedNomeLivroDiario;
    MemoAssinaturaDireita.Text := TContabilParametroVO(ObjetoVO).AssinaturaDireita;
    MemoAssinaturaEsquerda.Text := TContabilParametroVO(ObjetoVO).AssinaturaEsquerda;

    EditIdHistoricoPadraoResultado.AsInteger := TContabilParametroVO(ObjetoVO).IdHistPadraoResultado;
    if EditIdHistoricoPadraoResultado.AsInteger > 0 then
    begin
      HistoricoVO := TContabilHistoricoController.ConsultaObjeto('ID=' + EditIdHistoricoPadraoResultado.Text);
      if Assigned(HistoricoVO) then
        EditHistoricoPadraoResultado.Text := HistoricoVO.Descricao;
    end;

    EditIdHistoricoPadraoLucro.AsInteger := TContabilParametroVO(ObjetoVO).IdHistPadraoLucro;
    if EditIdHistoricoPadraoLucro.AsInteger > 0 then
    begin
      HistoricoVO := TContabilHistoricoController.ConsultaObjeto('ID=' + EditIdHistoricoPadraoLucro.Text);
      if Assigned(HistoricoVO) then
        EditHistoricoPadraoLucro.Text := HistoricoVO.Descricao;
    end;

    EditIdHistoricoPadraoPrejuizo.AsInteger := TContabilParametroVO(ObjetoVO).IdHistPadraoPrejuizo;
    if EditIdHistoricoPadraoPrejuizo.AsInteger > 0 then
    begin
      HistoricoVO := TContabilHistoricoController.ConsultaObjeto('ID=' + EditIdHistoricoPadraoPrejuizo.Text);
      if Assigned(HistoricoVO) then
        EditHistoricoPadraoPrejuizo.Text := HistoricoVO.Descricao;
    end;
  end;
end;

procedure TFContabilParametros.GridContasKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  {
  //EXERCICIO: implemente a busca através da janela de lookup
  if Key = VK_F1 then
  begin
    try
      if Assigned(ContabilContaVO) then
      begin
        CDSContas.Edit;
        CDSContas.FieldByName('CLASSIFICACAO').AsString := CDSTransiente.FieldByName('CLASSIFICACAO').AsString;
        CDSContas.Post;
      end;
    finally
    end;
  end;
  }
  If Key = VK_RETURN then
    EditMascara.SetFocus;
end;

procedure TFContabilParametros.PopularGridContas;
var
  i: Integer;
begin
  for i := 1 to 20 do
  begin
    CDSContas.Append;
    case i of
      1:
        begin
          CDSContas.FieldByName('CONTA').AsString := 'Conta Ativo';
          if (StatusTela = stEditando) or (StatusTela = stNavegandoEdits) then
          begin
            CDSContas.FieldByName('CLASSIFICACAO').AsString := TContabilParametroVO(ObjetoVO).ContaAtivo;
          end;
        end;
      2:
        begin
          CDSContas.FieldByName('CONTA').AsString := 'Conta Passivo';
          if (StatusTela = stEditando) or (StatusTela = stNavegandoEdits) then
          begin
            CDSContas.FieldByName('CLASSIFICACAO').AsString := TContabilParametroVO(ObjetoVO).ContaPassivo;
          end;
        end;
      3:
        begin
          CDSContas.FieldByName('CONTA').AsString := 'Conta Patrimônio Líquido';
          if (StatusTela = stEditando) or (StatusTela = stNavegandoEdits) then
          begin
            CDSContas.FieldByName('CLASSIFICACAO').AsString := TContabilParametroVO(ObjetoVO).ContaPatrimonioLiquido;
          end;
        end;
      4:
        begin
          CDSContas.FieldByName('CONTA').AsString := 'Conta Depreciação Acumulada';
          if (StatusTela = stEditando) or (StatusTela = stNavegandoEdits) then
          begin
            CDSContas.FieldByName('CLASSIFICACAO').AsString := TContabilParametroVO(ObjetoVO).ContaDepreciacaoAcumulada;
          end;
        end;
      5:
        begin
          CDSContas.FieldByName('CONTA').AsString := 'Conta Capital Social';
          if (StatusTela = stEditando) or (StatusTela = stNavegandoEdits) then
          begin
            CDSContas.FieldByName('CLASSIFICACAO').AsString := TContabilParametroVO(ObjetoVO).ContaCapitalSocial;
          end;
        end;
      6:
        begin
          CDSContas.FieldByName('CONTA').AsString := 'Conta Resultado Exercício';
          if (StatusTela = stEditando) or (StatusTela = stNavegandoEdits) then
          begin
            CDSContas.FieldByName('CLASSIFICACAO').AsString := TContabilParametroVO(ObjetoVO).ContaResultadoExercicio;
          end;
        end;
      7:
        begin
          CDSContas.FieldByName('CONTA').AsString := 'Conta Prejuízo Acumulado';
          if (StatusTela = stEditando) or (StatusTela = stNavegandoEdits) then
          begin
            CDSContas.FieldByName('CLASSIFICACAO').AsString := TContabilParametroVO(ObjetoVO).ContaPrejuizoAcumulado;
          end;
        end;
      8:
        begin
          CDSContas.FieldByName('CONTA').AsString := 'Conta Lucro Acumulado';
          if (StatusTela = stEditando) or (StatusTela = stNavegandoEdits) then
          begin
            CDSContas.FieldByName('CLASSIFICACAO').AsString := TContabilParametroVO(ObjetoVO).ContaLucroAcumulado;
          end;
        end;
      9:
        begin
          CDSContas.FieldByName('CONTA').AsString := 'Conta Título a Pagar';
          if (StatusTela = stEditando) or (StatusTela = stNavegandoEdits) then
          begin
            CDSContas.FieldByName('CLASSIFICACAO').AsString := TContabilParametroVO(ObjetoVO).ContaTituloPagar;
          end;
        end;
      10:
        begin
          CDSContas.FieldByName('CONTA').AsString := 'Conta Título a Receber';
          if (StatusTela = stEditando) or (StatusTela = stNavegandoEdits) then
          begin
            CDSContas.FieldByName('CLASSIFICACAO').AsString := TContabilParametroVO(ObjetoVO).ContaTituloReceber;
          end;
        end;
      11:
        begin
          CDSContas.FieldByName('CONTA').AsString := 'Conta Juros Passivo';
          if (StatusTela = stEditando) or (StatusTela = stNavegandoEdits) then
          begin
            CDSContas.FieldByName('CLASSIFICACAO').AsString := TContabilParametroVO(ObjetoVO).ContaJurosPassivo;
          end;
        end;
      12:
        begin
          CDSContas.FieldByName('CONTA').AsString := 'Conta Juros Ativo';
          if (StatusTela = stEditando) or (StatusTela = stNavegandoEdits) then
          begin
            CDSContas.FieldByName('CLASSIFICACAO').AsString := TContabilParametroVO(ObjetoVO).ContaJurosAtivo;
          end;
        end;
      13:
        begin
          CDSContas.FieldByName('CONTA').AsString := 'Conta Desconto Obtido';
          if (StatusTela = stEditando) or (StatusTela = stNavegandoEdits) then
          begin
            CDSContas.FieldByName('CLASSIFICACAO').AsString := TContabilParametroVO(ObjetoVO).ContaDescontoObtido;
          end;
        end;
      14:
        begin
          CDSContas.FieldByName('CONTA').AsString := 'Conta Desconto Concedido';
          if (StatusTela = stEditando) or (StatusTela = stNavegandoEdits) then
          begin
            CDSContas.FieldByName('CLASSIFICACAO').AsString := TContabilParametroVO(ObjetoVO).ContaDescontoConcedido;
          end;
        end;
      15:
        begin
          CDSContas.FieldByName('CONTA').AsString := 'Conta CMV';
          if (StatusTela = stEditando) or (StatusTela = stNavegandoEdits) then
          begin
            CDSContas.FieldByName('CLASSIFICACAO').AsString := TContabilParametroVO(ObjetoVO).ContaCmv;
          end;
        end;
      16:
        begin
          CDSContas.FieldByName('CONTA').AsString := 'Conta Venda';
          if (StatusTela = stEditando) or (StatusTela = stNavegandoEdits) then
          begin
            CDSContas.FieldByName('CLASSIFICACAO').AsString := TContabilParametroVO(ObjetoVO).ContaVenda;
          end;
        end;
      17:
        begin
          CDSContas.FieldByName('CONTA').AsString := 'Conta Venda Serviço';
          if (StatusTela = stEditando) or (StatusTela = stNavegandoEdits) then
          begin
            CDSContas.FieldByName('CLASSIFICACAO').AsString := TContabilParametroVO(ObjetoVO).ContaVendaServico;
          end;
        end;
      18:
        begin
          CDSContas.FieldByName('CONTA').AsString := 'Conta Estoque';
          if (StatusTela = stEditando) or (StatusTela = stNavegandoEdits) then
          begin
            CDSContas.FieldByName('CLASSIFICACAO').AsString := TContabilParametroVO(ObjetoVO).ContaEstoque;
          end;
        end;
      19:
        begin
          CDSContas.FieldByName('CONTA').AsString := 'Conta Apura Resultado';
          if (StatusTela = stEditando) or (StatusTela = stNavegandoEdits) then
          begin
            CDSContas.FieldByName('CLASSIFICACAO').AsString := TContabilParametroVO(ObjetoVO).ContaApuraResultado;
          end;
        end;
      20:
        begin
          CDSContas.FieldByName('CONTA').AsString := 'Conta Juros Apropriar';
          if (StatusTela = stEditando) or (StatusTela = stNavegandoEdits) then
          begin
            CDSContas.FieldByName('CLASSIFICACAO').AsString := TContabilParametroVO(ObjetoVO).ContaJurosApropriar;
          end;
        end;
    end;
    CDSContas.Post;
  end;
  CDSContas.First;
end;

procedure TFContabilParametros.CDSContasAfterPost(DataSet: TDataSet);
begin
  if CDSContasCONTA.AsString = '' then
    CDSContas.Delete;
end;
{$ENDREGION}

{$REGION 'Campos Transientes'}
procedure TFContabilParametros.EditIdHistoricoPadraoLucroKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  Filtro: String;
  ContabilHistoricoVO: TContabilHistoricoVO;
begin
  if Key = VK_F1 then
  begin
    if EditIdHistoricoPadraoLucro.Value <> 0 then
      Filtro := 'ID = ' + EditIdHistoricoPadraoLucro.Text
    else
      Filtro := 'ID=0';

    try
      EditIdHistoricoPadraoLucro.Clear;
      EditHistoricoPadraoLucro.Clear;

      ContabilHistoricoVO := TContabilHistoricoController.ConsultaObjeto(Filtro);
      if Assigned(ContabilHistoricoVO) then
      begin
        EditHistoricoPadraoLucro.Text := ContabilHistoricoVO.Descricao;
        EditIdHistoricoPadraoPrejuizo.SetFocus;
      end
      else
      begin
        Exit;
      end;
    finally
    end;
  end;
end;

procedure TFContabilParametros.EditIdHistoricoPadraoPrejuizoKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  Filtro: String;
  ContabilHistoricoVO: TContabilHistoricoVO;
begin
  if Key = VK_F1 then
  begin
    if EditIdHistoricoPadraoPrejuizo.Value <> 0 then
      Filtro := 'ID = ' + EditIdHistoricoPadraoPrejuizo.Text
    else
      Filtro := 'ID=0';

    try
      EditIdHistoricoPadraoPrejuizo.Clear;
      EditHistoricoPadraoPrejuizo.Clear;

      ContabilHistoricoVO := TContabilHistoricoController.ConsultaObjeto(Filtro);
      if Assigned(ContabilHistoricoVO) then
      begin
        EditHistoricoPadraoPrejuizo.Text := ContabilHistoricoVO.Descricao;
        EditMascara.SetFocus;
      end
      else
      begin
        Exit;
      end;
    finally
    end;
  end;
end;

procedure TFContabilParametros.EditIdHistoricoPadraoResultadoKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  Filtro: String;
  ContabilHistoricoVO :TContabilHistoricoVO ;
begin
  if Key = VK_F1 then
  begin
    if EditIdHistoricoPadraoResultado.Value <> 0 then
      Filtro := 'ID = ' + EditIdHistoricoPadraoResultado.Text
    else
      Filtro := 'ID=0';

    try
      EditIdHistoricoPadraoResultado.Clear;
      EditHistoricoPadraoResultado.Clear;

      ContabilHistoricoVO := TContabilHistoricoController.ConsultaObjeto(Filtro);
      if Assigned(ContabilHistoricoVO) then
      begin
        EditHistoricoPadraoResultado.Text := ContabilHistoricoVO.Descricao;
        EditIdHistoricoPadraoLucro.SetFocus;
      end
      else
      begin
        Exit;
      end;
    finally
    end;
  end;
end;
{$ENDREGION}


end.

