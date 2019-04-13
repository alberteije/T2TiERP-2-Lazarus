{ *******************************************************************************
Title: T2Ti ERP
Description: Janela Plano de Saúde para o módulo Folha de Pagamento

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

@author Albert Eije
@version 2.0
******************************************************************************* }

unit UFolhaPlanoSaude;

{$MODE Delphi}

interface

uses
  BrookHTTPClient, BrookFCLHTTPClientBroker, BrookHTTPUtils, BrookUtils, FPJson, ZDataset,
  LCLIntf, LCLType, LMessages, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UTelaCadastro, Menus, StdCtrls, ExtCtrls, Buttons, Grids, DBGrids,
  ComCtrls, LabeledCtrls, rxdbgrid, rxtoolbar, DBCtrls, StrUtils,
  Math, Constantes, CheckLst, ActnList, ToolWin, db, BufDataset, Biblioteca,
  ULookup, VO, FolhaPlanoSaudeVO, FolhaPlanoSaudeController;

  type

  TFFolhaPlanoSaude = class(TFTelaCadastro)
    BevelEdits: TBevel;
    EditIdColaborador: TLabeledCalcEdit;
    EditColaborador: TLabeledEdit;
    EditDataInicio: TLabeledDateEdit;
    ComboBoxBeneficiario: TLabeledComboBox;
    EditIdOperadoraPlanoSaude: TLabeledCalcEdit;
    EditOperadoraPlanoSaude: TLabeledEdit;
    procedure FormCreate(Sender: TObject);
    procedure EditIdColaboradorKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure EditIdOperadoraPlanoSaudeKeyUp(Sender: TObject; var Key: Word;
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
  FFolhaPlanoSaude: TFFolhaPlanoSaude;

implementation

uses ViewPessoaColaboradorVO, ViewPessoaColaboradorController,
OperadoraPlanoSaudeVO, OperadoraPlanoSaudeController;

{$R *.lfm}

{$REGION 'Controles Infra'}
procedure TFFolhaPlanoSaude.BotaoConsultarClick(Sender: TObject);
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
    RetornoConsulta := TFolhaPlanoSaudeController.Consulta(Filtro, IntToStr(Pagina));
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

procedure TFFolhaPlanoSaude.BotaoSalvarClick(Sender: TObject);
begin
  inherited;
  BotaoConsultarClick(Sender);
end;

procedure TFFolhaPlanoSaude.FormCreate(Sender: TObject);
begin
  ClasseObjetoGridVO := TFolhaPlanoSaudeVO;
  ObjetoController := TFolhaPlanoSaudeController.Create;

  inherited;
  BotaoImprimir.Visible := False;
  MenuImprimir.Visible := False;
end;
{$ENDREGION}

{$REGION 'Controles CRUD'}
function TFFolhaPlanoSaude.DoInserir: Boolean;
begin
  Result := inherited DoInserir;

  if Result then
  begin
    EditIdColaborador.SetFocus;
  end;
end;

function TFFolhaPlanoSaude.DoEditar: Boolean;
begin
  Result := inherited DoEditar;

  if Result then
  begin
    EditIdColaborador.SetFocus;
  end;
end;

function TFFolhaPlanoSaude.DoExcluir: Boolean;
begin
  if inherited DoExcluir then
  begin
    try
      Result := TFolhaPlanoSaudeController.Exclui(IdRegistroSelecionado);
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

function TFFolhaPlanoSaude.DoSalvar: Boolean;
begin
  Result := inherited DoSalvar;

  if Result then
  begin
    try
      if not Assigned(ObjetoVO) then
        ObjetoVO := TFolhaPlanoSaudeVO.Create;

      TFolhaPlanoSaudeVO(ObjetoVO).IdColaborador := EditIdColaborador.AsInteger;
      TFolhaPlanoSaudeVO(ObjetoVO).ColaboradorNome := EditColaborador.Text;
      TFolhaPlanoSaudeVO(ObjetoVO).IdOperadoraPlanoSaude := EditIdOperadoraPlanoSaude.AsInteger;
      TFolhaPlanoSaudeVO(ObjetoVO).OperadoraNome := EditOperadoraPlanoSaude.Text;
      TFolhaPlanoSaudeVO(ObjetoVO).DataInicio := EditDataInicio.Date;
      TFolhaPlanoSaudeVO(ObjetoVO).Beneficiario := IntToStr(ComboBoxBeneficiario.ItemIndex + 1);

      if StatusTela = stInserindo then
      begin
        TFolhaPlanoSaudeController.Insere(TFolhaPlanoSaudeVO(ObjetoVO));
      end
      else if StatusTela = stEditando then
      begin
        if TFolhaPlanoSaudeVO(ObjetoVO).ToJSONString <> StringObjetoOld then
        begin
          TFolhaPlanoSaudeController.Altera(TFolhaPlanoSaudeVO(ObjetoVO));
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
procedure TFFolhaPlanoSaude.GridParaEdits;
var
  IdCabecalho: String;
begin
  inherited;

  if not CDSGrid.IsEmpty then
  begin
    IdCabecalho := IntToStr(IdRegistroSelecionado);
    ObjetoVO := TFolhaPlanoSaudeController.ConsultaObjeto('ID=' + IdCabecalho);
  end;

  if Assigned(ObjetoVO) then
  begin
    EditIdColaborador.AsInteger := TFolhaPlanoSaudeVO(ObjetoVO).IdColaborador;
    EditColaborador.Text := TFolhaPlanoSaudeVO(ObjetoVO).ColaboradorNome;
    EditIdOperadoraPlanoSaude.AsInteger := TFolhaPlanoSaudeVO(ObjetoVO).IdOperadoraPlanoSaude;
    EditOperadoraPlanoSaude.Text := TFolhaPlanoSaudeVO(ObjetoVO).OperadoraNome;
    EditDataInicio.Date := TFolhaPlanoSaudeVO(ObjetoVO).DataInicio;
    ComboBoxBeneficiario.ItemIndex := StrToInt(TFolhaPlanoSaudeVO(ObjetoVO).Beneficiario) - 1;

    // Serializa o objeto para consultar posteriormente se houve alterações
    FormatSettings.DecimalSeparator := '.';
    StringObjetoOld := ObjetoVO.ToJSONString;
    FormatSettings.DecimalSeparator := ',';
  end;
end;
{$ENDREGION}

{$REGION 'Campos Transientes'}
procedure TFFolhaPlanoSaude.EditIdColaboradorKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  Filtro: String;
  ViewPessoaColaboradorVO :TViewPessoaColaboradorVO ;
begin
  if Key = VK_F1 then
  begin
    if EditIdColaborador.Value <> 0 then
      Filtro := 'ID = ' + EditIdColaborador.Text
    else
      Filtro := 'ID=0';

    try
      EditColaborador.Clear;

        ViewPessoaColaboradorVO := TViewPessoaColaboradorController.ConsultaObjeto(Filtro);
        if Assigned(ViewPessoaColaboradorVO) then
      begin
        EditColaborador.Text := ViewPessoaColaboradorVO.Nome;
      end
      else
      begin
        Exit;
      end;
    finally
      EditIdOperadoraPlanoSaude.SetFocus;
    end;
  end;
end;

procedure TFFolhaPlanoSaude.EditIdOperadoraPlanoSaudeKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  Filtro: String;
  OperadoraPlanoSaudeVO :TOperadoraPlanoSaudeVO ;
begin
  if Key = VK_F1 then
  begin
    if EditIdOperadoraPlanoSaude.Value <> 0 then
      Filtro := 'ID = ' + EditIdOperadoraPlanoSaude.Text
    else
      Filtro := 'ID=0';

    try
      EditOperadoraPlanoSaude.Clear;

        OperadoraPlanoSaudeVO := TOperadoraPlanoSaudeController.ConsultaObjeto(Filtro);
        if Assigned(OperadoraPlanoSaudeVO) then
      begin
        EditOperadoraPlanoSaude.Text := OperadoraPlanoSaudeVO.Nome;
      end
      else
      begin
        Exit;
      end;
    finally
      EditDataInicio.SetFocus;
    end;
  end;
end;
{$ENDREGION}

end.

