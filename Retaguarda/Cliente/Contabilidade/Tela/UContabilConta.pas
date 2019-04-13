{ *******************************************************************************
Title: T2Ti ERP
Description: Janela Cadastro das Contas Contábeis

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
unit UContabilConta;

{$MODE Delphi}

interface

uses
  BrookHTTPClient, BrookFCLHTTPClientBroker, BrookHTTPUtils, BrookUtils, FPJson, ZDataset,
  LCLIntf, LCLType, LMessages, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UTelaCadastro, Menus, StdCtrls, ExtCtrls, Buttons, Grids, DBGrids,
  ComCtrls, LabeledCtrls, rxdbgrid, rxtoolbar, DBCtrls, StrUtils,
  Math, Constantes, CheckLst, ActnList, ToolWin, db, BufDataset, Biblioteca,
  ULookup, VO, ContabilContaVO,
  ContabilContaController;

  type

  TFContabilConta = class(TFTelaCadastro)
    EditPlanoConta: TLabeledEdit;
    EditClassificacao: TLabeledEdit;
    EditDescricao: TLabeledEdit;
    BevelEdits: TBevel;
    EditPlanoContaRefSped: TLabeledEdit;
    EditDataInclusao: TLabeledDateEdit;
    EditOrdem: TLabeledEdit;
    EditCodigoReduzido: TLabeledEdit;
    EditIdPlanoConta: TLabeledCalcEdit;
    EditIdPlanoContaRefSped: TLabeledCalcEdit;
    EditIdContaPai: TLabeledCalcEdit;
    EditContaPai: TLabeledEdit;
    ComboBoxTipo: TLabeledComboBox;
    ComboBoxSituacao: TLabeledComboBox;
    ComboBoxNatureza: TLabeledComboBox;
    ComboBoxPatrimonioResultado: TLabeledComboBox;
    ComboBoxLivroCaixa: TLabeledComboBox;
    ComboBoxDfc: TLabeledComboBox;
    ComboBoxCodigoEfd: TLabeledComboBox;
    procedure FormCreate(Sender: TObject);
    procedure EditIdPlanoContaKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure EditIdPlanoContaRefSpedKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure EditIdContaPaiKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
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
  end;

var
  FContabilConta: TFContabilConta;

implementation

uses  PlanoContaController, PlanoContaVO, PlanoContaRefSpedController,
PlanoContaRefSpedVO, UDataModule;
{$R *.lfm}

{$REGION 'Controles Infra'}
procedure TFContabilConta.BotaoConsultarClick(Sender: TObject);
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

procedure TFContabilConta.BotaoSalvarClick(Sender: TObject);
begin
  inherited;
  BotaoConsultarClick(Sender);
end;

procedure TFContabilConta.FormCreate(Sender: TObject);
begin
  ClasseObjetoGridVO := TContabilContaVO;
  ObjetoController := TContabilContaController.Create;

  inherited;
end;
{$ENDREGION}

{$REGION 'Controles CRUD'}
function TFContabilConta.DoInserir: Boolean;
begin
  Result := inherited DoInserir;

  if Result then
  begin
    EditIdPlanoConta.SetFocus;
  end;
end;

function TFContabilConta.DoEditar: Boolean;
begin
  Result := inherited DoEditar;

  if Result then
  begin
    EditIdPlanoConta.SetFocus;
  end;
end;

function TFContabilConta.DoExcluir: Boolean;
begin
  if inherited DoExcluir then
  begin
    try
      Result := TContabilContaController.Exclui(IdRegistroSelecionado);
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

function TFContabilConta.DoSalvar: Boolean;
begin
  Result := inherited DoSalvar;

  if Result then
  begin
    try
      ObjetoVO := TContabilContaVO.Create;

      TContabilContaVO(ObjetoVO).IdPlanoConta := EditIdPlanoConta.AsInteger;
      TContabilContaVO(ObjetoVO).PlanoContaNome := EditPlanoConta.Text;
      TContabilContaVO(ObjetoVO).IdPlanoContaRefSped := EditIdPlanoContaRefSped.AsInteger;
      TContabilContaVO(ObjetoVO).PlanoContaSpedDescricao := EditPlanoContaRefSped.Text;
      TContabilContaVO(ObjetoVO).IdContabilConta := EditIdContaPai.AsInteger;
      TContabilContaVO(ObjetoVO).ContabilContaPai := EditContaPai.Text;
      TContabilContaVO(ObjetoVO).Classificacao := EditClassificacao.Text;
      // S=Sintética | A=Analítica
      TContabilContaVO(ObjetoVO).Tipo := IfThen(ComboBoxTipo.ItemIndex = 0, 'S', 'A');
      TContabilContaVO(ObjetoVO).Descricao := EditDescricao.Text;
      TContabilContaVO(ObjetoVO).DataInclusao := EditDataInclusao.Date;
      // A=Ativa | I=Inativa
      TContabilContaVO(ObjetoVO).Situacao := IfThen(ComboBoxSituacao.ItemIndex = 0, 'A', 'I');
      // C=Credora | D=Devedora
      TContabilContaVO(ObjetoVO).Natureza := IfThen(ComboBoxNatureza.ItemIndex = 0, 'C', 'D');
      // P=Patrimonio | R=Resultado
      TContabilContaVO(ObjetoVO).PatrimonioResultado := IfThen(ComboBoxPatrimonioResultado.ItemIndex = 0, 'P', 'R');
      // S=Sim | N=Não
      TContabilContaVO(ObjetoVO).LivroCaixa := IfThen(ComboBoxLivroCaixa.ItemIndex = 0, 'S', 'N');
      // N=Não participa | O=Atividades Operacionais | F=Atividades de Financiamento | I=Atividades de Investimento
      case ComboBoxDfc.ItemIndex of
        0:
          TContabilContaVO(ObjetoVO).Dfc := 'N';
        1:
          TContabilContaVO(ObjetoVO).Dfc := 'O';
        2:
          TContabilContaVO(ObjetoVO).Dfc := 'F';
        3:
          TContabilContaVO(ObjetoVO).Dfc := 'I';
      end;
      TContabilContaVO(ObjetoVO).Ordem := EditOrdem.Text;
      TContabilContaVO(ObjetoVO).CodigoReduzido := EditCodigoReduzido.Text;
      TContabilContaVO(ObjetoVO).CodigoEfd := Copy(ComboBoxCodigoEfd.Text, 1, 2);

      if StatusTela = stInserindo then
      begin
        TContabilContaController.Insere(TContabilContaVO(ObjetoVO));
      end
      else if StatusTela = stEditando then
      begin
        if TContabilContaVO(ObjetoVO).ToJSONString <> StringObjetoOld then
        begin
          TContabilContaController.Altera(TContabilContaVO(ObjetoVO));
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
procedure TFContabilConta.GridParaEdits;
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
    EditContaPai.Text := TContabilContaVO(ObjetoVO).ContabilContaPai;
    EditClassificacao.Text := TContabilContaVO(ObjetoVO).Classificacao;
    // S=Sintética | A=Analítica
    ComboBoxTipo.ItemIndex := AnsiIndexStr(TContabilContaVO(ObjetoVO).Tipo, ['S', 'A']);
    EditDescricao.Text := TContabilContaVO(ObjetoVO).Descricao;
    EditDataInclusao.Date := TContabilContaVO(ObjetoVO).DataInclusao;
    // A=Ativa | I=Inativa
    ComboBoxSituacao.ItemIndex := AnsiIndexStr(TContabilContaVO(ObjetoVO).Situacao, ['A', 'I']);
    // C=Credora | D=Devedora
    ComboBoxNatureza.ItemIndex := AnsiIndexStr(TContabilContaVO(ObjetoVO).Natureza, ['C', 'D']);
    // P=Patrimonio | R=Resultado
    ComboBoxPatrimonioResultado.ItemIndex := AnsiIndexStr(TContabilContaVO(ObjetoVO).PatrimonioResultado, ['P', 'R']);
    // S=Sim | N=Não
    ComboBoxLivroCaixa.ItemIndex := AnsiIndexStr(TContabilContaVO(ObjetoVO).LivroCaixa, ['S', 'N']);
    // N=Não participa | O=Atividades Operacionais | F=Atividades de Financiamento | I=Atividades de Investimento
    ComboBoxDFC.ItemIndex := AnsiIndexStr(TContabilContaVO(ObjetoVO).Dfc, ['N', 'O', 'F', 'I']);
    EditOrdem.Text := TContabilContaVO(ObjetoVO).Ordem;
    EditCodigoReduzido.Text := TContabilContaVO(ObjetoVO).CodigoReduzido;
    ComboBoxCodigoEfd.ItemIndex := AnsiIndexStr(TContabilContaVO(ObjetoVO).CodigoEfd, ['01', '02', '03', '04', '05', '09']);

    // Serializa o objeto para consultar posteriormente se houve alterações
    FormatSettings.DecimalSeparator := '.';
    StringObjetoOld := ObjetoVO.ToJSONString;
    FormatSettings.DecimalSeparator := ',';
  end;
end;
{$ENDREGION}

{$REGION 'Campos Transientes'}
procedure TFContabilConta.EditIdContaPaiKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  Filtro: String;
  ContabilContaVO :TContabilContaVO ;
begin
  if Key = VK_F1 then
  begin
    if EditIdContaPai.Value <> 0 then
      Filtro := 'ID = ' + EditIdContaPai.Text
    else
      Filtro := 'ID=0';

    try
      EditIdContaPai.Clear;
      EditContaPai.Clear;

      ContabilContaVO := TContabilContaController.ConsultaObjeto(Filtro);
      if Assigned(ContabilContaVO) then
      begin
        EditContaPai.Text := ContabilContaVO.Descricao;
        EditClassificacao.SetFocus;
      end
      else
      begin
        Exit;
      end;
    finally
    end;
  end;
end;
procedure TFContabilConta.EditIdPlanoContaKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  Filtro: String;
  PlanoContaVO :TPlanoContaVO;
begin
  if Key = VK_F1 then
  begin
    if EditIdPlanoConta.Value <> 0 then
      Filtro := 'ID = ' + EditIdPlanoConta.Text
    else
      Filtro := 'ID=0';

    try
      EditIdPlanoConta.Clear;
      EditPlanoConta.Clear;

      PlanoContaVO := TPlanoContaController.ConsultaObjeto(Filtro);
      if Assigned(PlanoContaVO) then
      begin
        EditPlanoConta.Text := PlanoContaVO.Nome;
        EditIdPlanoContaRefSped.SetFocus;
      end
      else
      begin
        Exit;
      end;
    finally
    end;
  end;
end;

procedure TFContabilConta.EditIdPlanoContaRefSpedKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  Filtro: String;
  PlanoContaRefSpedVO :TPlanoContaRefSpedVO ;
begin
  if Key = VK_F1 then
  begin
    if EditIdPlanoContaRefSped.Value <> 0 then
      Filtro := 'ID = ' + EditIdPlanoContaRefSped.Text
    else
      Filtro := 'ID=0';

    try
      EditIdPlanoContaRefSped.Clear;
      EditPlanoContaRefSped.Clear;

      PlanoContaRefSpedVO := TPlanoContaRefSpedController.ConsultaObjeto(Filtro);
      if Assigned(PlanoContaRefSpedVO) then
      begin
        EditPlanoContaRefSped.Text := PlanoContaRefSpedVO.Descricao;
        EditIdContaPai.SetFocus;
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

