{ *******************************************************************************
Title: T2Ti ERP
Description: Janela Cadastro do Centro de Resultado

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
unit UCentroResultado;

{$MODE Delphi}

interface

uses
  BrookHTTPClient, BrookFCLHTTPClientBroker, BrookHTTPUtils, BrookUtils, FPJson, ZDataset,
  LCLIntf, LCLType, LMessages, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UTelaCadastro, Menus, StdCtrls, ExtCtrls, Buttons, Grids, DBGrids,
  ComCtrls, LabeledCtrls, rxdbgrid, rxtoolbar, DBCtrls, StrUtils,
  Math, Constantes, CheckLst, ActnList, ToolWin, db, BufDataset, Biblioteca,
  ULookup, VO, CentroResultadoVO,
  CentroResultadoController;

  type

  TFCentroResultado = class(TFTelaCadastro)
    BevelEdits: TBevel;
    EditDescricao: TLabeledEdit;
    EditClassificacao: TLabeledEdit;
    EditIdPlanoCentroResultado: TLabeledCalcEdit;
    EditPlanoCentroResultado: TLabeledEdit;
    ComboBoxSofreRateio: TLabeledComboBox;
    procedure FormCreate(Sender: TObject);
    procedure EditIdPlanoCentroResultadoKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
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
  FCentroResultado: TFCentroResultado;

implementation

uses UDataModule, PlanoCentroResultadoVO, PlanoCentroResultadoController;
{$R *.lfm}

{$REGION 'Infra'}
procedure TFCentroResultado.BotaoConsultarClick(Sender: TObject);
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
    RetornoConsulta := TCentroResultadoController.Consulta(Filtro, IntToStr(Pagina));
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

procedure TFCentroResultado.BotaoSalvarClick(Sender: TObject);
begin
  inherited;
  BotaoConsultarClick(Sender);
end;

procedure TFCentroResultado.FormCreate(Sender: TObject);
begin
  ClasseObjetoGridVO := TCentroResultadoVO;
  ObjetoController := TCentroResultadoController.Create;

  inherited;
end;
{$ENDREGION}

{$REGION 'Controles CRUD'}
function TFCentroResultado.DoInserir: Boolean;
begin
  Result := inherited DoInserir;

  if Result then
  begin
    EditIdPlanoCentroResultado.SetFocus;
  end;
end;

function TFCentroResultado.DoEditar: Boolean;
begin
  Result := inherited DoEditar;

  if Result then
  begin
    EditIdPlanoCentroResultado.SetFocus;
  end;
end;

function TFCentroResultado.DoExcluir: Boolean;
begin
  if inherited DoExcluir then
  begin
    try
      Result := TCentroResultadoController.Exclui(IdRegistroSelecionado);
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

function TFCentroResultado.DoSalvar: Boolean;
begin
  Result := inherited DoSalvar;

  if Result then
  begin
    try
      if not Assigned(ObjetoVO) then
        ObjetoVO := TCentroResultadoVO.Create;

      TCentroResultadoVO(ObjetoVO).IdPlanoCentroResultado := EditIdPlanoCentroResultado.AsInteger;
      TCentroResultadoVO(ObjetoVO).Descricao := EditDescricao.Text;
      TCentroResultadoVO(ObjetoVO).Classificacao := EditClassificacao.Text;
      TCentroResultadoVO(ObjetoVO).SofreRateiro := IfThen(ComboBoxSofreRateio.ItemIndex = 0, 'S', 'N');

      if StatusTela = stInserindo then
      begin
        TCentroResultadoController.Insere(TCentroResultadoVO(ObjetoVO));
      end
      else if StatusTela = stEditando then
      begin
        if TCentroResultadoVO(ObjetoVO).ToJSONString <> StringObjetoOld then
        begin
          TCentroResultadoController.Altera(TCentroResultadoVO(ObjetoVO));
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
procedure TFCentroResultado.EditIdPlanoCentroResultadoKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  Filtro: String;
  PlanoCentroResultadoVO :TPlanoCentroResultadoVO ;
begin
  if Key = VK_F1 then
  begin
    if EditIdPlanoCentroResultado.Value <> 0 then
      Filtro := 'ID = ' + EditIdPlanoCentroResultado.Text
    else
      Filtro := 'ID=0';

    try
      EditPlanoCentroResultado.Clear;

        PlanoCentroResultadoVO := TPlanoCentroResultadoController.ConsultaObjeto(Filtro);
        if Assigned(PlanoCentroResultadoVO) then
      begin
        EditPlanoCentroResultado.Text := PlanoCentroResultadoVO.Nome + ' [' + PlanoCentroResultadoVO.Mascara + ']';
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
procedure TFCentroResultado.GridParaEdits;
var
  IdCabecalho: String;
begin
  inherited;

  if not CDSGrid.IsEmpty then
  begin
    IdCabecalho := IntToStr(IdRegistroSelecionado);
    ObjetoVO := TCentroResultadoController.ConsultaObjeto('ID=' + IdCabecalho);
  end;

  if Assigned(ObjetoVO) then
  begin
    EditIdPlanoCentroResultado.AsInteger := TCentroResultadoVO(ObjetoVO).IdPlanoCentroResultado;
    EditPlanoCentroResultado.Text := TCentroResultadoVO(ObjetoVO).PlanoCentroResultadoNome;
    EditDescricao.Text := TCentroResultadoVO(ObjetoVO).Descricao;
    EditClassificacao.Text := TCentroResultadoVO(ObjetoVO).Classificacao;
    ComboBoxSofreRateio.ItemIndex := IfThen(TCentroResultadoVO(ObjetoVO).SofreRateiro = 'S', 0, 1);

    // Serializa o objeto para consultar posteriormente se houve alterações
    FormatSettings.DecimalSeparator := '.';
    StringObjetoOld := ObjetoVO.ToJSONString;
    FormatSettings.DecimalSeparator := ',';
  end;
end;
{$ENDREGION}

end.

