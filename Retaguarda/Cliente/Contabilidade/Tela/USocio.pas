{*******************************************************************************
Title: T2Ti ERP
Description: Janela Cadastro de Sócio

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
*******************************************************************************}
unit USocio;

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

  TFSocio = class(TFTelaCadastro)
    CDSSocioDependente: TBufDataSet;
    DSSocioDependente: TDataSource;
    CDSSocioDependenteID: TIntegerField;
    CDSParticipacaoSocietaria: TBufDataSet;
    DSParticipacaoSocietaria: TDataSource;
    PageControlSocio: TPageControl;
    tsDependente: TTabSheet;
    TabSheetParticipacaoSocietaria: TTabSheet;
    PanelParticipacaoSocietaria: TPanel;
    PanelDados: TPanel;
    EditIdQuadroSocietario: TLabeledCalcEdit;
    EditCep: TLabeledMaskEdit;
    EditLogradouro: TLabeledEdit;
    EditComplemento: TLabeledEdit;
    EditMunicipio: TLabeledEdit;
    EditUf: TLabeledEdit;
    EditFone: TLabeledMaskEdit;
    EditCelular: TLabeledMaskEdit;
    EditEmail: TLabeledEdit;
    EditBairro: TLabeledEdit;
    EditNumero: TLabeledCalcEdit;
    PanelDependente: TPanel;
    GridDependente: TDBGrid;
    GridParticipacaoSocietaria: TDBGrid;
    EditDataIngresso: TLabeledDateEdit;
    EditDataSaida: TLabeledDateEdit;
    EditParticipacao: TLabeledCalcEdit;
    EditQuotas: TLabeledCalcEdit;
    EditIntegralizar: TLabeledCalcEdit;
    CDSSocioDependenteTIPO_RELACIONAMENTONOME: TStringField;
    procedure FormCreate(Sender: TObject);
    procedure GridDependenteKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure GridParticipacaoSocietariaKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure GridDblClick(Sender: TObject);
    procedure EditIdQuadroSocietarioKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
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
  FSocio: TFSocio;

implementation

uses UDataModule,
  //
  PessoaController, QuadroSocietarioController, TipoRelacionamentoController,
  EmpresaController, SocioController,
  //
  QuadroSocietarioVO, TipoRelacionamentoVO, SocioDependenteVO, PessoaVO,
  ContabilContaVO, SocioParticipacaoSocietariaVO, EmpresaVO, SocioVO;
{$R *.lfm}

{$REGION 'Infra'}
procedure TFSocio.BotaoConsultarClick(Sender: TObject);
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
    RetornoConsulta := TSocioController.Consulta(Filtro, IntToStr(Pagina));
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

procedure TFSocio.BotaoSalvarClick(Sender: TObject);
begin
  inherited;
  BotaoConsultarClick(Sender);
end;

procedure TFSocio.FormCreate(Sender: TObject);
begin
  ClasseObjetoGridVO := TSocioVO;
  ObjetoController := TSocioController.Create;

  inherited;
end;

procedure TFSocio.LimparCampos;
begin
  inherited;
  CDSSocioDependente.Close;
  CDSParticipacaoSocietaria.Close;
  CDSSocioDependente.Open;
  CDSParticipacaoSocietaria.Open;
end;

procedure TFSocio.ConfigurarLayoutTela;
begin
  PageControlSocio.ActivePageIndex := 0;
  PanelEdits.Enabled := True;

  if StatusTela = stNavegandoEdits then
  begin
    PanelDados.Enabled := False;
    PanelDependente.Enabled := False;
    PanelParticipacaoSocietaria.Enabled := False;
  end
  else
  begin
    PanelDependente.Enabled := True;
    PanelParticipacaoSocietaria.Enabled := True;
    PanelDados.Enabled := True;
  end;
end;
{$ENDREGION}

{$REGION 'Controles CRUD'}
function TFSocio.DoInserir: Boolean;
begin
  Result := inherited DoInserir;

  if Result then
  begin
    EditIdQuadroSocietario.SetFocus;
  end;
end;

function TFSocio.DoEditar: Boolean;
begin
  Result := inherited DoEditar;

  if Result then
  begin
    EditIdQuadroSocietario.SetFocus;
  end;
end;

function TFSocio.DoExcluir: Boolean;
begin
  if inherited DoExcluir then
  begin
    try
      Result := TSocioController.Exclui(IdRegistroSelecionado);
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

function TFSocio.DoSalvar: Boolean;
var
  SocioDependente: TSocioDependenteVO;
  SocioParticipacaoSocietaria: TSocioParticipacaoSocietariaVO;
begin
  Result := inherited DoSalvar;

  if Result then
  begin
    try
      if not Assigned(ObjetoVO) then
        ObjetoVO := TSocioVO.Create;

      TSocioVO(ObjetoVO).IdQuadroSocietario := EditIdQuadroSocietario.AsInteger;
      TSocioVO(ObjetoVO).Logradouro := EditLogradouro.Text;
      TSocioVO(ObjetoVO).Numero := EditNumero.AsInteger;
      TSocioVO(ObjetoVO).Complemento := EditComplemento.Text;
      TSocioVO(ObjetoVO).Bairro := EditBairro.Text;
      TSocioVO(ObjetoVO).Municipio := EditMunicipio.Text;
      TSocioVO(ObjetoVO).Uf := EditUf.Text;
      TSocioVO(ObjetoVO).Cep := EditCep.Text;
      TSocioVO(ObjetoVO).Fone := EditFone.Text;
      TSocioVO(ObjetoVO).Celular := EditCelular.Text;
      TSocioVO(ObjetoVO).Email := EditEmail.Text;
      TSocioVO(ObjetoVO).Participacao := EditParticipacao.Value;
      TSocioVO(ObjetoVO).Quotas := EditQuotas.AsInteger;
      TSocioVO(ObjetoVO).Integralizar := EditIntegralizar.Value;
      TSocioVO(ObjetoVO).DataIngresso := EditDataIngresso.Date;
      TSocioVO(ObjetoVO).DataSaida := EditDataSaida.Date;

      // Dependentes
      CDSSocioDependente.DisableControls;
      CDSSocioDependente.First;
      while not CDSSocioDependente.Eof do
      begin
          SocioDependente := TSocioDependenteVO.Create;
          SocioDependente.Id := CDSSocioDependente.FieldByName('ID').AsInteger;
          SocioDependente.IdSocio := CDSSocioDependente.FieldByName('ID_SOCIO').AsInteger;
          SocioDependente.IdTipoRelacionamento := CDSSocioDependente.FieldByName('ID_TIPO_RELACIONAMENTO').AsInteger;
          SocioDependente.Nome := CDSSocioDependente.FieldByName('NOME').AsString;
          SocioDependente.DataNascimento := CDSSocioDependente.FieldByName('DATA_NASCIMENTO').AsDateTime;
          SocioDependente.DataInicioDepedencia := CDSSocioDependente.FieldByName('DATA_INICIO_DEPENDENCIA').AsDateTime;
          SocioDependente.DataFimDependencia := CDSSocioDependente.FieldByName('DATA_FIM_DEPENDENCIA').AsDateTime;
          SocioDependente.Cpf := CDSSocioDependente.FieldByName('CPF').AsString;
          TSocioVO(ObjetoVO).ListaSocioDependenteVO.Add(SocioDependente);
        CDSSocioDependente.Next;
      end;
      CDSSocioDependente.EnableControls;

      // Dependentes
      CDSParticipacaoSocietaria.DisableControls;
      CDSParticipacaoSocietaria.First;
      while not CDSParticipacaoSocietaria.Eof do
      begin
          SocioParticipacaoSocietaria := TSocioParticipacaoSocietariaVO.Create;
          SocioParticipacaoSocietaria.Id := CDSParticipacaoSocietaria.FieldByName('ID').AsInteger;
          SocioParticipacaoSocietaria.IdSocio := CDSParticipacaoSocietaria.FieldByName('ID_SOCIO').AsInteger;
          SocioParticipacaoSocietaria.Cnpj := CDSParticipacaoSocietaria.FieldByName('CNPJ').AsString;
          SocioParticipacaoSocietaria.RazaoSocial := CDSParticipacaoSocietaria.FieldByName('RAZAO_SOCIAL').AsString;
          SocioParticipacaoSocietaria.DataEntrada := CDSParticipacaoSocietaria.FieldByName('DATA_ENTRADA').AsDateTime;
          SocioParticipacaoSocietaria.DataSaida := CDSParticipacaoSocietaria.FieldByName('DATA_SAIDA').AsDateTime;
          SocioParticipacaoSocietaria.Dirigente := CDSParticipacaoSocietaria.FieldByName('DIRIGENTE').AsString;
          TSocioVO(ObjetoVO).ListaSocioParticipacaoSocietariaVO.Add(SocioParticipacaoSocietaria);
        CDSParticipacaoSocietaria.Next;
      end;
      CDSParticipacaoSocietaria.EnableControls;

      if StatusTela = stInserindo then
      begin
        TSocioController.Insere(TSocioVO(ObjetoVO));
      end
      else if StatusTela = stEditando then
      begin
        /// EXERCICIO: Verifique se tem como serializar as listas junto com o objeto para realizar a comparação
        //if TSocioVO(ObjetoVO).ToJSONString <> StringObjetoOld then
        //begin
          TSocioController.Altera(TSocioVO(ObjetoVO));
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
procedure TFSocio.EditIdQuadroSocietarioKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  Filtro: String;
  QuadroSocietarioVO :TQuadroSocietarioVO ;
begin
  if Key = VK_F1 then
  begin
    if EditIdQuadroSocietario.Value <> 0 then
      Filtro := 'ID = ' + EditIdQuadroSocietario.Text
    else
      Filtro := 'ID=0';

    try
      EditIdQuadroSocietario.Clear;

      QuadroSocietarioVO := TQuadroSocietarioController.ConsultaObjeto(Filtro);
      if Assigned(QuadroSocietarioVO) then
      begin
        EditIdQuadroSocietario.Text := IntToStr(QuadroSocietarioVO.Id);
        EditCep.SetFocus;
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

{$REGION 'Controle Grid'}
procedure TFSocio.GridDblClick(Sender: TObject);
begin
  inherited;
  ConfigurarLayoutTela;
end;

procedure TFSocio.GridDependenteKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = Vk_Return then
    GridDependente.SelectedIndex := GridDependente.SelectedIndex + 1;
  {kalel
  if Key = Vk_F1 then
  begin
    try
        if Assigned(QuadroSocietarioVO) then
      begin
        CDSSocioDependente.Edit;
        CDSSocioDependente.FieldByName('ID_TIPO_RELACIONAMENTO').AsInteger := CDSTransiente.FieldByName('ID').AsInteger;
        CDSSocioDependente.FieldByName('TIPO_RELACIONAMENTONOME').AsString := CDSTransiente.FieldByName('NOME').AsString;
      end;
    finally
    end;
  end;
  }
end;

procedure TFSocio.GridParticipacaoSocietariaKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = Vk_Return then
    GridParticipacaoSocietaria.SelectedIndex := GridParticipacaoSocietaria.SelectedIndex + 1;
end;

procedure TFSocio.GridParaEdits;
var
  IdCabecalho: String;
begin
  inherited;

  if not CDSGrid.IsEmpty then
  begin
    IdCabecalho := IntToStr(IdRegistroSelecionado);
    ObjetoVO := TSocioController.ConsultaObjeto('ID=' + IdCabecalho);
  end;

  if Assigned(ObjetoVO) then
  begin
    EditIdQuadroSocietario.AsInteger := TSocioVO(ObjetoVO).IdQuadroSocietario;
    EditLogradouro.Text := TSocioVO(ObjetoVO).Logradouro;
    EditNumero.AsInteger := TSocioVO(ObjetoVO).Numero;
    EditComplemento.Text := TSocioVO(ObjetoVO).Complemento;
    EditBairro.Text := TSocioVO(ObjetoVO).Bairro;
    EditMunicipio.Text := TSocioVO(ObjetoVO).Municipio;
    EditUf.Text := TSocioVO(ObjetoVO).Uf;
    EditCep.Text := TSocioVO(ObjetoVO).Cep;
    EditFone.Text := TSocioVO(ObjetoVO).Fone;
    EditCelular.Text := TSocioVO(ObjetoVO).Celular;
    EditEmail.Text := TSocioVO(ObjetoVO).Email;
    EditParticipacao.Value := TSocioVO(ObjetoVO).Participacao;
    EditQuotas.AsInteger := TSocioVO(ObjetoVO).Quotas;
    EditIntegralizar.Value := TSocioVO(ObjetoVO).Integralizar;
    EditDataIngresso.Date := TSocioVO(ObjetoVO).DataIngresso;
    EditDataSaida.Date := TSocioVO(ObjetoVO).DataSaida;

    // Preenche as grids internas com os dados das Listas que vieram no objeto
//kalel    TController.TratarRetorno<TSocioDependenteVO>(TSocioVO(ObjetoVO).ListaSocioDependenteVO, True, True, CDSSocioDependente);
//kalel    TController.TratarRetorno<TSocioParticipacaoSocietariaVO>(TSocioVO(ObjetoVO).ListaSocioParticipacaoSocietariaVO, True, True, CDSParticipacaoSocietaria);

    // Limpa as listas para comparar posteriormente se houve inclusões/alterações e subir apenas o necessário para o servidor
    TSocioVO(ObjetoVO).ListaSocioDependenteVO.Clear;
    TSocioVO(ObjetoVO).ListaSocioParticipacaoSocietariaVO.Clear;

    // Serializa o objeto para consultar posteriormente se houve alterações
    FormatSettings.DecimalSeparator := '.';
    StringObjetoOld := ObjetoVO.ToJSONString;
    FormatSettings.DecimalSeparator := ',';

  end;
  ConfigurarLayoutTela;
end;
{$ENDREGION}

end.

