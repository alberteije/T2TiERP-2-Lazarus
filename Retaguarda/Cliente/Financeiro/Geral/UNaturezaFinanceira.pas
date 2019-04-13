{ *******************************************************************************
Title: T2Ti ERP
Description: Janela Cadastro de Natureza Financeira

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
unit UNaturezaFinanceira;

{$MODE Delphi}

interface

uses
  BrookHTTPClient, BrookFCLHTTPClientBroker, BrookHTTPUtils, BrookUtils, FPJson, ZDataset,
  LCLIntf, LCLType, LMessages, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UTelaCadastro, Menus, StdCtrls, ExtCtrls, Buttons, Grids, DBGrids,
  ComCtrls, LabeledCtrls, rxdbgrid, rxtoolbar, DBCtrls, StrUtils,
  Math, Constantes, CheckLst, ActnList, ToolWin, db, BufDataset, Biblioteca,
  ULookup, VO, NaturezaFinanceiraVO,
  NaturezaFinanceiraController;

  type

  TFNaturezaFinanceira = class(TFTelaCadastro)
    BevelEdits: TBevel;
    EditPlanoNaturezaFinanceira: TLabeledEdit;
    EditContabilConta: TLabeledEdit;
    EditAplicacao: TLabeledEdit;
    EditDescricao: TLabeledEdit;
    EditClassificacao: TLabeledEdit;
    EditIdPlanoNaturezaFinanceira: TLabeledCalcEdit;
    EditIdContabilConta: TLabeledCalcEdit;
    GroupBoxOpcoes: TGroupBox;
    ComboBoxTipo: TLabeledComboBox;
    ComboBoxAPagar: TLabeledComboBox;
    ComboBoxAReceber: TLabeledComboBox;
    procedure FormCreate(Sender: TObject);
    procedure EditIdPlanoNaturezaFinanceiraKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure EditIdContabilContaKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);

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
  FNaturezaFinanceira: TFNaturezaFinanceira;

implementation

uses UDataModule, PlanoNaturezaFinanceiraVO, PlanoNaturezaFinanceiraController,
  CentroResultadoVO, CentroResultadoController, ContabilContaVO, ContabilContaController;
{$R *.lfm}

{$REGION 'Infra'}
procedure TFNaturezaFinanceira.BotaoConsultarClick(Sender: TObject);
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
    RetornoConsulta := TNaturezaFinanceiraController.Consulta(Filtro, IntToStr(Pagina));
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

procedure TFNaturezaFinanceira.BotaoSalvarClick(Sender: TObject);
begin
  inherited;
  BotaoConsultarClick(Sender);
end;

procedure TFNaturezaFinanceira.FormCreate(Sender: TObject);
begin
  ClasseObjetoGridVO := TNaturezaFinanceiraVO;
  ObjetoController := TNaturezaFinanceiraController.Create;

  inherited;
end;
{$ENDREGION}

{$REGION 'Controles CRUD'}
function TFNaturezaFinanceira.DoInserir: Boolean;
begin
  Result := inherited DoInserir;

  if Result then
  begin
    EditIdPlanoNaturezaFinanceira.SetFocus;
  end;
end;

function TFNaturezaFinanceira.DoEditar: Boolean;
begin
  Result := inherited DoEditar;

  if Result then
  begin
    EditIdPlanoNaturezaFinanceira.SetFocus;
  end;
end;

function TFNaturezaFinanceira.DoExcluir: Boolean;
begin
  if inherited DoExcluir then
  begin
    try
      Result := TNaturezaFinanceiraController.Exclui(IdRegistroSelecionado);
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

function TFNaturezaFinanceira.DoSalvar: Boolean;
begin
  Result := inherited DoSalvar;

  if Result then
  begin
    try
      if not Assigned(ObjetoVO) then
        ObjetoVO := TNaturezaFinanceiraVO.Create;

      TNaturezaFinanceiraVO(ObjetoVO).IdPlanoNaturezaFinanceira := EditIdPlanoNaturezaFinanceira.AsInteger;
      TNaturezaFinanceiraVO(ObjetoVO).PlanoNaturezaFinanceiraNome := EditPlanoNaturezaFinanceira.Text;
      TNaturezaFinanceiraVO(ObjetoVO).IdContabilConta := EditIdContabilConta.AsInteger;
      TNaturezaFinanceiraVO(ObjetoVO).ContabilContaClassificacao := EditContabilConta.Text;
      TNaturezaFinanceiraVO(ObjetoVO).Descricao := EditDescricao.Text;
      TNaturezaFinanceiraVO(ObjetoVO).Classificacao := EditClassificacao.Text;
      TNaturezaFinanceiraVO(ObjetoVO).Aplicacao := EditAplicacao.Text;
      TNaturezaFinanceiraVO(ObjetoVO).Tipo := IfThen(ComboBoxTipo.ItemIndex = 0, 'R', 'D');
      TNaturezaFinanceiraVO(ObjetoVO).ApareceAPagar := IfThen(ComboBoxAPagar.ItemIndex = 0, 'S', 'N');
      TNaturezaFinanceiraVO(ObjetoVO).ApareceAReceber := IfThen(ComboBoxAReceber.ItemIndex = 0, 'S', 'N');

      if StatusTela = stInserindo then
      begin
        TNaturezaFinanceiraController.Insere(TNaturezaFinanceiraVO(ObjetoVO));
      end
      else if StatusTela = stEditando then
      begin
        if TNaturezaFinanceiraVO(ObjetoVO).ToJSONString <> StringObjetoOld then
        begin
          TNaturezaFinanceiraController.Altera(TNaturezaFinanceiraVO(ObjetoVO));
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

{$REGION 'Campos Transientes'}
procedure TFNaturezaFinanceira.EditIdPlanoNaturezaFinanceiraKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  Filtro: String;
  PlanoNaturezaFinanceiraVO :TPlanoNaturezaFinanceiraVO ;
begin
  if Key = VK_F1 then
  begin
    if EditIdPlanoNaturezaFinanceira.Value <> 0 then
      Filtro := 'ID = ' + EditIdPlanoNaturezaFinanceira.Text
    else
      Filtro := 'ID=0';

    try
      EditPlanoNaturezaFinanceira.Clear;

        PlanoNaturezaFinanceiraVO := TPlanoNaturezaFinanceiraController.ConsultaObjeto(Filtro);
        if Assigned(PlanoNaturezaFinanceiraVO) then
      begin
        EditPlanoNaturezaFinanceira.Text := PlanoNaturezaFinanceiraVO.Nome + ' [' + PlanoNaturezaFinanceiraVO.Mascara + ']';
      end
      else
      begin
        Exit;
      end;
    finally
      EditIdContabilConta.SetFocus;
    end;
  end;
end;

procedure TFNaturezaFinanceira.EditIdContabilContaKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  Filtro: String;
  ContabilContaVO :TContabilContaVO ;
begin
  if Key = VK_F1 then
  begin
    if EditIdContabilConta.Value <> 0 then
      Filtro := 'ID = ' + EditIdContabilConta.Text
    else
      Filtro := 'ID=0';

    try
      EditContabilConta.Clear;

        ContabilContaVO := TContabilContaController.ConsultaObjeto(Filtro);
        if Assigned(ContabilContaVO) then
      begin
        EditContabilConta.Text := ContabilContaVO.Classificacao;
      end
      else
      begin
        Exit;
      end;
    finally
      EditDescricao.SetFocus;
    end;
  end;
end;
{$ENDREGION}

{$REGION 'Controle de Grid'}
procedure TFNaturezaFinanceira.GridParaEdits;
var
  IdCabecalho: String;
begin
  inherited;

  if not CDSGrid.IsEmpty then
  begin
    IdCabecalho := IntToStr(IdRegistroSelecionado);
    ObjetoVO := TNaturezaFinanceiraController.ConsultaObjeto('ID=' + IdCabecalho);
  end;

  if Assigned(ObjetoVO) then
  begin
    EditIdPlanoNaturezaFinanceira.AsInteger := TNaturezaFinanceiraVO(ObjetoVO).IdPlanoNaturezaFinanceira;
    EditPlanoNaturezaFinanceira.Text := TNaturezaFinanceiraVO(ObjetoVO).PlanoNaturezaFinanceiraNome;
    EditIdContabilConta.AsInteger := TNaturezaFinanceiraVO(ObjetoVO).IdContabilConta;
    EditContabilConta.Text := TNaturezaFinanceiraVO(ObjetoVO).ContabilContaClassificacao;
    EditDescricao.Text := TNaturezaFinanceiraVO(ObjetoVO).Descricao;
    EditClassificacao.Text := TNaturezaFinanceiraVO(ObjetoVO).Classificacao;
    EditAplicacao.Text := TNaturezaFinanceiraVO(ObjetoVO).Aplicacao;
    ComboBoxTipo.ItemIndex := IfThen(TNaturezaFinanceiraVO(ObjetoVO).Tipo = 'R', 0, 1);
    ComboBoxAPagar.ItemIndex := IfThen(TNaturezaFinanceiraVO(ObjetoVO).ApareceAPagar = 'S', 0, 1);
    ComboBoxAReceber.ItemIndex := IfThen(TNaturezaFinanceiraVO(ObjetoVO).ApareceAReceber = 'S', 0, 1);

    // Serializa o objeto para consultar posteriormente se houve alterações
    FormatSettings.DecimalSeparator := '.';
    StringObjetoOld := ObjetoVO.ToJSONString;
    FormatSettings.DecimalSeparator := ',';
  end;
end;
{$ENDREGION}

end.

