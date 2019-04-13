{ *******************************************************************************
Title: T2Ti ERP
Description: Janela Cadastro de Pessoas

The MIT License

Copyright: Copyright (C) 2014 T2Ti.COM

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

unit UPessoa;

{$MODE Delphi}

interface

uses
  BrookHTTPClient, BrookFCLHTTPClientBroker, BrookHTTPUtils, BrookUtils, FPJson,
  LCLIntf, LCLType, LMessages, Messages, SysUtils, Variants, Classes, Graphics,
  Controls, Forms, Dialogs, UTelaCadastro, Menus, StdCtrls, ExtCtrls, Buttons,
  Grids, DBGrids, ComCtrls, MaskEdit, LabeledCtrls, rxdbgrid, rxtoolbar, DBCtrls,
  DB, StrUtils, Math, VO, Constantes, CheckLst, ActnList, ToolWin, BufDataset, Biblioteca;

type

  { TFPessoa }

  TFPessoa = class(TFTelaCadastro)
    PageControl: TPageControl;
    PaginaGrid: TTabSheet;
    ScrollBox: TScrollBox;
    PageControlDadosPessoa: TPageControl;
    tsTipoPessoa: TTabSheet;
    PanelDadosPessoa: TPanel;
    PageControlTipoPessoa: TPageControl;
    tsPessoaFisica: TTabSheet;
    PanelPessoaFisica: TPanel;
    EditCPF: TLabeledMaskEdit;
    GroupBoxRG: TGroupBox;
    EditRGNumero: TLabeledEdit;
    EditRGEmissao: TLabeledDateEdit;
    EditRGOrgaoEmissor: TLabeledEdit;
    EditNascimento: TLabeledDateEdit;
    RadioGroupSexo: TRadioGroup;
    LComboBoxEstadoCivil: TLabeledComboBox;
    tsPessoaJuridica: TTabSheet;
    PanelPessoaJuridica: TPanel;
    EditFantasia: TLabeledEdit;
    EditCNPJ: TLabeledMaskEdit;
    EditInscricaoMunicipal: TLabeledEdit;
    EditDataConstituicao: TLabeledDateEdit;
    tsContato: TTabSheet;
    PanelContatos: TPanel;
    GridContato: TRxDBGrid;
    EditNomeMae: TLabeledEdit;
    EditNaturalidade: TLabeledEdit;
    EditNacionalidade: TLabeledEdit;
    ComboBoxRaca: TLabeledComboBox;
    ComboBoxTipoSangue: TLabeledComboBox;
    GroupBoxCNH: TGroupBox;
    EditCNHNumero: TLabeledEdit;
    EditCNHVencimento: TLabeledDateEdit;
    ComboBoxCNHCategoria: TLabeledComboBox;
    GroupBoxTituloEleitoral: TGroupBox;
    EditTituloNumero: TLabeledEdit;
    EditTituloZona: TLabeledCalcEdit;
    EditTituloSecao: TLabeledCalcEdit;
    EditNomePai: TLabeledEdit;
    GroupBoxReservista: TGroupBox;
    EditReservistaNumero: TLabeledEdit;
    ComboBoxReservistaCategoria: TLabeledComboBox;
    EditInscricaoEstadual: TLabeledEdit;
    EditSuframa: TLabeledEdit;
    ComboBoxTipoRegime: TLabeledComboBox;
    ComboBoxCRT: TLabeledComboBox;
    tsEndereco: TTabSheet;
    PanelEnderecos: TPanel;
    GridEndereco: TRxDBGrid;
    PanelPessoaDadosBase: TPanel;
    EditEmail: TLabeledEdit;
    EditNome: TLabeledEdit;
    ComboboxTipoPessoa: TLabeledComboBox;
    CheckListBoxPessoa: TCheckListBox;
    EditSite: TLabeledEdit;
    CDSEndereco: TBufDataSet;
    DSEndereco: TDataSource;
    CDSContato: TBufDataSet;
    DSContato: TDataSource;
    CDSEstadoCivil: TBufDataSet;
    DSEstadoCivil: TDataSource;
    ActionToolBar2: TToolPanel;
    ActionManager: TActionList;
    ActionExcluirContato: TAction;
    ActionExcluirEndereco: TAction;
    ActionExcluirTelefone: TAction;
    ActionToolBar1: TToolPanel;
    tsTelefone: TTabSheet;
    CDSTelefone: TBufDataSet;
    DSTelefone: TDataSource;
    PanelTelefones: TPanel;
    GridTelefone: TRxDBGrid;
    ActionToolBar3: TToolPanel;
    tsCliente: TTabSheet;
    PanelCliente: TPanel;
    EditIdSituacaoCliente: TLabeledCalcEdit;
    EditSituacaoCliente: TLabeledEdit;
    EditIdAtividadeCliente: TLabeledCalcEdit;
    EditAtividadeCliente: TLabeledEdit;
    EditDataDesde: TLabeledDateEdit;
    EditContaTomador: TLabeledEdit;
    ComboBoxGeraFinanceiro: TLabeledComboBox;
    ComboBoxIndicadorPreco: TLabeledComboBox;
    ComboBoxTipoFrete: TLabeledComboBox;
    ComboBoxFormaDesconto: TLabeledComboBox;
    EditDesconto: TLabeledCalcEdit;
    EditLimiteCredito: TLabeledCalcEdit;
    MemoObservacao: TLabeledMemo;
    tsFornecedor: TTabSheet;
    PanelFornecedor: TPanel;
    EditIdSituacaoFornecedor: TLabeledCalcEdit;
    EditSituacaoFornecedor: TLabeledEdit;
    EditIdAtividadeFornecedor: TLabeledCalcEdit;
    EditAtividadeFornecedor: TLabeledEdit;
    LabeledDateEdit1: TLabeledDateEdit;
    EditContaRemetente: TLabeledEdit;
    ComboBoxGeraFaturamento: TLabeledComboBox;
    ComboBoxOptanteSimples: TLabeledComboBox;
    ComboBoxLocalizacao: TLabeledComboBox;
    ComboBoxSofreRetencao: TLabeledComboBox;
    EditPrazoMedioEntrega: TLabeledCalcEdit;
    EditNumDiasPrimeiroVencimento: TLabeledCalcEdit;
    EditNumDiasIntervalo: TLabeledCalcEdit;
    EditQuantidadeParcelas: TLabeledCalcEdit;
    EditChequeNominal: TLabeledEdit;
    LabeledMemo1: TLabeledMemo;
    tsTransportadora: TTabSheet;
    PanelTransportadora: TPanel;
    LabeledMemo2: TLabeledMemo;
    procedure ActionExcluirContatoExecute(Sender: TObject);
    procedure ActionExcluirEnderecoExecute(Sender: TObject);
    procedure ActionExcluirTelefoneExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ComboboxTipoPessoaChange(Sender: TObject);
    procedure EditIdSituacaoClienteKeyUp(Sender: TObject; var Key: Word;  Shift: TShiftState);
    procedure EditIdAtividadeClienteKeyUp(Sender: TObject; var Key: Word;  Shift: TShiftState);
    procedure CheckListBoxPessoaClick(Sender: TObject);
  private
    { Private declarations }
    IdTipoPessoa: Integer;
  public
    { Public declarations }
    procedure GridParaEdits; override;
    procedure LimparCampos; override;

    // Controles CRUD
    function DoInserir: Boolean; override;
    function DoEditar: Boolean; override;
    function DoExcluir: Boolean; override;
    function DoSalvar: Boolean; override;

    procedure ExibirDadosTipoPessoa;
    procedure ExibirDadosAgregados;
    procedure ConfigurarLayoutTela;
    procedure PopulaComboEstadoCivil(Sender: TObject);
  end;

var
  FPessoa: TFPessoa;

implementation

uses
      EstadoCivilVO, PessoaVO, PessoaContatoVO, PessoaEnderecoVO, PessoaTelefoneVO, PessoaFisicaVO, PessoaJuridicaVO;
{$R *.lfm}

{$Region 'Infra'}
procedure TFPessoa.FormCreate(Sender: TObject);
var
  I: Integer;
begin
  ClasseObjetoGridVO := TPessoaVO;

  inherited;

  PopulaComboEstadoCivil(Self);

  // Configura a Grid dos Endereços
  //ConfiguraCDSFromVO(CDSEndereco, TPessoaEnderecoVO);
  //ConfiguraGridFromVO(GridEndereco, TPessoaEnderecoVO);

  // Configura a Grid dos Contatos
  //ConfiguraCDSFromVO(CDSContato, TPessoaContatoVO);
  //ConfiguraGridFromVO(GridContato, TPessoaContatoVO);

  // Configura a Grid dos Telefones
  //ConfiguraCDSFromVO(CDSTelefone, TPessoaTelefoneVO);
  //ConfiguraGridFromVO(GridTelefone, TPessoaTelefoneVO);

  //
  tsCliente.Visible := False;
  tsFornecedor.Visible := False;
  tsTransportadora.Visible := False;
end;

procedure TFPessoa.ConfigurarLayoutTela;
begin
  PageControlDadosPessoa.ActivePageIndex := 0;
  PanelEdits.Enabled := True;

  if StatusTela = stNavegandoEdits then
  begin
    PanelDadosPessoa.Enabled := False;
    PanelContatos.Enabled := False;
    PanelEnderecos.Enabled := False;
    PanelPessoaDadosBase.Enabled := False;
    PanelTelefones.Enabled := False;
  end
  else
  begin
    PanelDadosPessoa.Enabled := True;
    PanelContatos.Enabled := True;
    PanelEnderecos.Enabled := True;
    PanelTelefones.Enabled := True;
    PanelPessoaDadosBase.Enabled := True;
  end;
  ExibirDadosTipoPessoa;
  ExibirDadosAgregados;
end;

procedure TFPessoa.ExibirDadosAgregados;
begin
  if CheckListBoxPessoa.Checked[0] then
    tsCliente.TabVisible := True
  else
    tsCliente.TabVisible := False;
  //
  if CheckListBoxPessoa.Checked[1] then
    tsFornecedor.TabVisible := True
  else
    tsFornecedor.TabVisible := False;
  //
  if CheckListBoxPessoa.Checked[2] then
    tsTransportadora.TabVisible := True
  else
    tsTransportadora.TabVisible := False;
end;

procedure TFPessoa.ExibirDadosTipoPessoa;
begin
  case ComboboxTipoPessoa.ItemIndex of
    0:
      begin
        PanelPessoaFisica.Parent := PanelDadosPessoa;
        PanelPessoaFisica.Visible := True;
        PanelPessoaJuridica.Visible := False;
      end;
    1:
      begin
        PanelPessoaJuridica.Parent := PanelDadosPessoa;
        PanelPessoaFisica.Visible := False;
        PanelPessoaJuridica.Visible := True;
      end;
  end;
end;

procedure TFPessoa.PopulaComboEstadoCivil(Sender: TObject);
begin
  //ConfiguraCDSFromVO(CDSEstadoCivil, TEstadoCivilVO);

  //Exercício: preencha o combobox com os estados civis
end;

procedure TFPessoa.LimparCampos;
var
  I: Integer;
begin
  inherited;

  // Pessoa
  ComboboxTipoPessoa.ItemIndex := 0;

  // Pessoa Física
  RadioGroupSexo.ItemIndex := -1;

  // Contatos
  CDSContato.Close;
  CDSContato.Open;
  // Endereços
  CDSEndereco.Close;
  CDSEndereco.Open;
  // Telefones
  CDSTelefone.Close;
  CDSTelefone.Open;

  // CheckListBox
  for I := 0 to CheckListBoxPessoa.Items.Count - 1 do
    CheckListBoxPessoa.Checked[I] := False;
end;

procedure TFPessoa.ComboboxTipoPessoaChange(Sender: TObject);
begin
  ExibirDadosTipoPessoa;
end;

procedure TFPessoa.CheckListBoxPessoaClick(Sender: TObject);
begin
  ExibirDadosAgregados;
end;
{$EndRegion 'Infra'}

{$REGION 'Controles CRUD'}
function TFPessoa.DoInserir: Boolean;
begin
  Result := inherited DoInserir;

  if Result then
  begin
    ConfigurarLayoutTela;
    IdTipoPessoa := 0;
    EditNome.SetFocus;
    ComboboxTipoPessoa.Enabled := True;
    ExibirDadosTipoPessoa;
  end;
end;

function TFPessoa.DoEditar: Boolean;
begin
  Result := inherited DoEditar;

  if Result then
  begin
    EditNome.SetFocus;
    ComboboxTipoPessoa.Enabled := False;
  end;
end;

function TFPessoa.DoExcluir: Boolean;
begin
  if inherited DoExcluir then
  begin
    try
      Result := ProcessRequest(BrookHttpRequest(Sessao.URL + NomeTabelaBanco + '/' + IntToStr(IdRegistroSelecionado), rmDelete ));
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

function TFPessoa.DoSalvar: Boolean;
var
  ObjetoJson: TJSONObject;
begin
  try
    DecimalSeparator := '.';

    if EditNome.Text = '' then
    begin
      Application.MessageBox('Informe o nome da pessoa.', 'Mensagem do Sistema', MB_OK + MB_ICONINFORMATION);
      EditNome.SetFocus;
      Exit(False);
    end
    else if ComboboxTipoPessoa.ItemIndex = 0 then
    begin
      if EditCPF.Text = '' then
      begin
        Application.MessageBox('Informe o CPF da pessoa.', 'Mensagem do Sistema', MB_OK + MB_ICONINFORMATION);
        EditCPF.SetFocus;
        Exit(False);
      end
      else if EditNomeMae.Text = '' then
      begin
        Application.MessageBox('Informe o nome da mãe.', 'Mensagem do Sistema', MB_OK + MB_ICONINFORMATION);
        EditNomeMae.SetFocus;
        Exit(False);
      end
    end
    else if ComboboxTipoPessoa.ItemIndex = 1 then
    begin
      if EditCNPJ.Text = '' then
      begin
        Application.MessageBox('Informe o CNPJ da pessoa.', 'Mensagem do Sistema', MB_OK + MB_ICONINFORMATION);
        EditCNPJ.SetFocus;
        Exit(False);
      end;
    end;

    Result := inherited DoSalvar;

    if Result then
    begin
      try
        if not Assigned(ObjetoVO) then
          ObjetoVO := TPessoaVO.Create;

        TPessoaVO(ObjetoVO).Nome := EditNome.Text;
        TPessoaVO(ObjetoVO).Tipo := IfThen(ComboboxTipoPessoa.ItemIndex = 0, 'F', 'J');
        TPessoaVO(ObjetoVO).Email := EditEmail.Text;
        TPessoaVO(ObjetoVO).Site := EditSite.Text;
        TPessoaVO(ObjetoVO).Cliente := IfThen(CheckListBoxPessoa.Checked[0], 'S', 'N');
        TPessoaVO(ObjetoVO).Fornecedor := IfThen(CheckListBoxPessoa.Checked[1], 'S', 'N');
        TPessoaVO(ObjetoVO).Colaborador := IfThen(CheckListBoxPessoa.Checked[2], 'S', 'N');
        TPessoaVO(ObjetoVO).Transportadora := IfThen(CheckListBoxPessoa.Checked[3], 'S', 'N');

        // Exercício: Tipo de Pessoa - Implemente a persistência para PF e PJ
        if TPessoaVO(ObjetoVO).Tipo = 'F' then
        begin
        end
        else if TPessoaVO(ObjetoVO).Tipo = 'J' then
        begin
        end;

        // Exercício: Contatos - Implemente a persistência dos Contatos

        // Exercício: Endereços - Implemente a persistência dos Endereços

        // Exercício: Telefones - Implemente a persistência dos Telefones

        if StatusTela = stInserindo then
        begin
          ObjetoJson := TPessoaVO(ObjetoVO).ToJSON;
          ProcessRequest(BrookHttpRequest(ObjetoJson, Sessao.URL + NomeTabelaBanco));
          ObjetoJson := Nil;
        end
        else if StatusTela = stEditando then
        begin
          if TPessoaVO(ObjetoVO).ToJSONString <> StringObjetoOld then
          begin
            ObjetoJson := TPessoaVO(ObjetoVO).ToJSON;
            ProcessRequest(BrookHttpRequest(ObjetoJson, Sessao.URL + NomeTabelaBanco + '/' + IntToStr(TPessoaVO(ObjetoVO).Id), rmPut ));
            ObjetoJson := Nil;
          end
          else
            Application.MessageBox('Nenhum dado foi alterado.', 'Mensagem do Sistema', MB_OK + MB_ICONINFORMATION);
        end;
      except
        Result := False;
      end;
    end;

  finally
    DecimalSeparator := ',';
  end;
end;
{$ENDREGION}

{$REGION 'Controle de Grids e BufDataSets'}
procedure TFPessoa.GridParaEdits;
begin
  inherited;

  if not CDSGrid.IsEmpty then
  begin
    ObjetoVO := TPessoaVO.Create;
    ConsultarVO(IntToStr(IdRegistroSelecionado), ObjetoVO);
  end;

  if Assigned(ObjetoVO) then
  begin
    // Pessoa
    EditNome.Text := TPessoaVO(ObjetoVO).Nome;
    ComboboxTipoPessoa.ItemIndex := IfThen(TPessoaVO(ObjetoVO).Tipo = 'F', 0, 1);
    EditEmail.Text := TPessoaVO(ObjetoVO).Email;
    EditSite.Text := TPessoaVO(ObjetoVO).Site;
    if TPessoaVO(ObjetoVO).Cliente = 'S' then
      CheckListBoxPessoa.Checked[0] := True;
    if TPessoaVO(ObjetoVO).Fornecedor = 'S' then
      CheckListBoxPessoa.Checked[1] := True;
    if TPessoaVO(ObjetoVO).Colaborador = 'S' then
      CheckListBoxPessoa.Checked[2] := True;
    if TPessoaVO(ObjetoVO).Transportadora = 'S' then
      CheckListBoxPessoa.Checked[3] := True;

    // Exercício: Tipo Pessoa - Carregue os dados do tipo de pessoa
    if (TPessoaVO(ObjetoVO).Tipo = 'F') then // Pessoa Física
    begin
      EditCPF.Text := '11111111111';
      EditNascimento.Date := Date;
      ComboBoxRaca.ItemIndex := 0;
      ComboBoxTipoSangue.ItemIndex := 0;

      EditNaturalidade.Text := 'BRASILIA';
      EditNacionalidade.Text := 'BRASILEIRA';
      EditNomePai.Text := 'PAI';
      EditNomeMae.Text := 'MAE';
      EditRGNumero.Text := '111';
      RadioGroupSexo.ItemIndex := 0;
      ComboBoxCNHCategoria.ItemIndex := 0;
      EditTituloNumero.Text := '';
    end;

    // Exercício: Preencha as grids internas com os dados das Listas que vieram no objeto

    // Serializa o objeto para consultar posteriormente se houve alterações
    FormatSettings.DecimalSeparator := '.';
    StringObjetoOld := ObjetoVO.ToJSONString;
    FormatSettings.DecimalSeparator := ',';
  end;
  ConfigurarLayoutTela;
end;
{$ENDREGION}

{$REGION 'Exclusões Internas'}
procedure TFPessoa.ActionExcluirContatoExecute(Sender: TObject);
begin
  if not CDSContato.IsEmpty then
  begin
    if Application.MessageBox('Tem certeza que deseja excluir o registro selecionado?', 'Pergunta do Sistema', MB_YesNo + MB_IconQuestion) = IdYes then
    begin
      if StatusTela = stInserindo then
        CDSContato.Delete
      else if StatusTela = stEditando then
      begin
        if ProcessRequest(BrookHttpRequest(Sessao.URL + 'pessoa_contato' + '/' + CDSContato.FieldByName('ID').AsString, rmDelete )) then
          CDSContato.Delete;
      end;
    end;
  end
  else
    Application.MessageBox('Não existem dados para serem excluídos.', 'Mensagem do Sistema', MB_OK + MB_ICONINFORMATION);
end;

procedure TFPessoa.ActionExcluirEnderecoExecute(Sender: TObject);
begin
  if not CDSEndereco.IsEmpty then
  begin
    if Application.MessageBox('Tem certeza que deseja excluir o registro selecionado?', 'Pergunta do Sistema', MB_YesNo + MB_IconQuestion) = IdYes then
    begin
      if StatusTela = stInserindo then
        CDSEndereco.Delete
      else if StatusTela = stEditando then
      begin
        if ProcessRequest(BrookHttpRequest(Sessao.URL + 'pessoa_endereco' + '/' + CDSEndereco.FieldByName('ID').AsString, rmDelete )) then
          CDSEndereco.Delete;
      end;
    end;
  end
  else
    Application.MessageBox('Não existem dados para serem excluídos.', 'Mensagem do Sistema', MB_OK + MB_ICONINFORMATION);
end;

procedure TFPessoa.ActionExcluirTelefoneExecute(Sender: TObject);
begin
  if not CDSTelefone.IsEmpty then
  begin
    if Application.MessageBox('Tem certeza que deseja excluir o registro selecionado?', 'Pergunta do Sistema', MB_YesNo + MB_IconQuestion) = IdYes then
    begin
      if StatusTela = stInserindo then
        CDSTelefone.Delete
      else if StatusTela = stEditando then
      begin
        if ProcessRequest(BrookHttpRequest(Sessao.URL + 'pessoa_telefone' + '/' + CDSTelefone.FieldByName('ID').AsString, rmDelete )) then
      end;
    end;
  end
  else
    Application.MessageBox('Não existem dados para serem excluídos.', 'Mensagem do Sistema', MB_OK + MB_ICONINFORMATION);
end;

{$EndREGION 'Exclusões Internas'}

{$REGION 'Campos Transientes'}
procedure TFPessoa.EditIdAtividadeClienteKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  Filtro: String;
begin
  if Key = VK_F1 then
  begin
    if EditIdAtividadeCliente.Value <> 0 then
      Filtro := 'ID = ' + EditIdAtividadeCliente.Text
    else
      Filtro := 'ID=0';
    (*
    try
      EditIdAtividadeCliente.Clear;
      EditAtividadeCliente.Clear;
      if not PopulaCamposTransientes(Filtro, TAtividadeForCliVO, TAtividadeForCliController) then
        PopulaCamposTransientesLookup(TAtividadeForCliVO, TAtividadeForCliController);
      if CDSTransiente.RecordCount > 0 then
      begin
        EditIdAtividadeCliente.Text := CDSTransiente.FieldByName('ID').AsString;
        EditAtividadeCliente.Text := CDSTransiente.FieldByName('NOME').AsString;
      end
      else
      begin
        Exit;
        EditIdAtividadeCliente.SetFocus;
      end;
    finally
      CDSTransiente.Close;
    end;
    *)
  end;
end;


procedure TFPessoa.EditIdSituacaoClienteKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  Filtro: String;
begin
  if Key = VK_F1 then
  begin
    if EditIdSituacaoCliente.Value <> 0 then
      Filtro := 'ID = ' + EditIdSituacaoCliente.Text
    else
      Filtro := 'ID=0';
    (*
    try
      EditIdSituacaoCliente.Clear;
      EditSituacaoCliente.Clear;
      if not PopulaCamposTransientes(Filtro, TSituacaoForCliVO, TSituacaoForCliController) then
        PopulaCamposTransientesLookup(TSituacaoForCliVO, TSituacaoForCliController);
      if CDSTransiente.RecordCount > 0 then
      begin
        EditIdSituacaoCliente.Text := CDSTransiente.FieldByName('ID').AsString;
        EditSituacaoCliente.Text := CDSTransiente.FieldByName('NOME').AsString;
      end
      else
      begin
        Exit;
        EditIdSituacaoCliente.SetFocus;
      end;
    finally
      CDSTransiente.Close;
    end;
    *)
  end;
end;
{$ENDREGION}

end.
