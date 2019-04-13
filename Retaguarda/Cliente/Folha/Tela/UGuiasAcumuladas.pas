{ *******************************************************************************
Title: T2Ti ERP
Description: Janela Cadastro de Guias Acumuladas para a Folha de Pagamento

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
unit UGuiasAcumuladas;

{$MODE Delphi}

interface

uses
  BrookHTTPClient, BrookFCLHTTPClientBroker, BrookHTTPUtils, BrookUtils, FPJson, ZDataset,
  LCLIntf, LCLType, LMessages, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UTelaCadastro, Menus, StdCtrls, ExtCtrls, Buttons, Grids, DBGrids,
  ComCtrls, LabeledCtrls, rxdbgrid, rxtoolbar, DBCtrls, StrUtils,
  Math, Constantes, CheckLst, ActnList, ToolWin, db, BufDataset, Biblioteca,
  ULookup, VO, GuiasAcumuladasVO,
  GuiasAcumuladasController;

  type

  TFGuiasAcumuladas = class(TFTelaCadastro)
    BevelEdits: TBevel;
    GroupBox1: TGroupBox;
    ComboBoxGpsTipo: TLabeledComboBox;
    EditGpsValorInss: TLabeledCalcEdit;
    GroupBox2: TGroupBox;
    GroupBox3: TGroupBox;
    EditGpsCompetencia: TLabeledMaskEdit;
    EditGpsValorOutrasEntidades: TLabeledCalcEdit;
    EditGpsDataPagamento: TLabeledDateEdit;
    EditIrrfCompetencia: TLabeledMaskEdit;
    EditIrrfCodigoRecolhimento: TLabeledCalcEdit;
    EditIrrfValorAcumulado: TLabeledCalcEdit;
    EditIrrfDataPagamento: TLabeledDateEdit;
    EditPisCompetencia: TLabeledMaskEdit;
    EditPisValorAcumulado: TLabeledCalcEdit;
    EditPisDataPagamento: TLabeledDateEdit;
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
  end;

var
  FGuiasAcumuladas: TFGuiasAcumuladas;

implementation

{$R *.lfm}

{$REGION 'Controles Infra'}
procedure TFGuiasAcumuladas.BotaoConsultarClick(Sender: TObject);
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
    RetornoConsulta := TGuiasAcumuladasController.Consulta(Filtro, IntToStr(Pagina));
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

procedure TFGuiasAcumuladas.BotaoSalvarClick(Sender: TObject);
begin
  inherited;
  BotaoConsultarClick(Sender);
end;

procedure TFGuiasAcumuladas.FormCreate(Sender: TObject);
begin
  ClasseObjetoGridVO := TGuiasAcumuladasVO;
  ObjetoController := TGuiasAcumuladasController.Create;

  inherited;

  BotaoImprimir.Visible := False;
  MenuImprimir.Visible := False;
end;
{$ENDREGION}

{$REGION 'Controles CRUD'}
function TFGuiasAcumuladas.DoInserir: Boolean;
begin
  Result := inherited DoInserir;

  if Result then
  begin
    ComboBoxGpsTipo.SetFocus;
  end;
end;

function TFGuiasAcumuladas.DoEditar: Boolean;
begin
  Result := inherited DoEditar;

  if Result then
  begin
    ComboBoxGpsTipo.SetFocus;
  end;
end;

function TFGuiasAcumuladas.DoExcluir: Boolean;
begin
  if inherited DoExcluir then
  begin
    try
      Result := TGuiasAcumuladasController.Exclui(IdRegistroSelecionado);
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

function TFGuiasAcumuladas.DoSalvar: Boolean;
begin
  Result := inherited DoSalvar;

  if Result then
  begin
    try
      if not Assigned(ObjetoVO) then
        ObjetoVO := TGuiasAcumuladasVO.Create;

      TGuiasAcumuladasVO(ObjetoVO).IdEmpresa := Sessao.Empresa.Id;
      TGuiasAcumuladasVO(ObjetoVO).GpsTipo := IntToStr(ComboBoxGpsTipo.ItemIndex + 1);
      TGuiasAcumuladasVO(ObjetoVO).GpsCompetencia := EditGpsCompetencia.Text;
      TGuiasAcumuladasVO(ObjetoVO).GpsValorInss := EditGpsValorInss.Value;
      TGuiasAcumuladasVO(ObjetoVO).GpsValorOutrasEnt := EditGpsValorOutrasEntidades.Value;
      TGuiasAcumuladasVO(ObjetoVO).GpsDataPagamento := EditGpsDataPagamento.Date;
      TGuiasAcumuladasVO(ObjetoVO).IrrfCompetencia := EditIrrfCompetencia.Text;
      TGuiasAcumuladasVO(ObjetoVO).IrrfCodigoRecolhimento := EditIrrfCodigoRecolhimento.AsInteger;
      TGuiasAcumuladasVO(ObjetoVO).IrrfValorAcumulado := EditIrrfValorAcumulado.Value;
      TGuiasAcumuladasVO(ObjetoVO).IrrfDataPagamento := EditIrrfDataPagamento.Date;
      TGuiasAcumuladasVO(ObjetoVO).PisCompetencia := EditPisCompetencia.Text;
      TGuiasAcumuladasVO(ObjetoVO).PisValorAcumulado := EditPisValorAcumulado.Value;
      TGuiasAcumuladasVO(ObjetoVO).PisDataPagamento := EditPisDataPagamento.Date;

      if StatusTela = stInserindo then
      begin
        TGuiasAcumuladasController.Insere(TGuiasAcumuladasVO(ObjetoVO));
      end
      else if StatusTela = stEditando then
      begin
        if TGuiasAcumuladasVO(ObjetoVO).ToJSONString <> StringObjetoOld then
        begin
          TGuiasAcumuladasController.Altera(TGuiasAcumuladasVO(ObjetoVO));
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
procedure TFGuiasAcumuladas.GridParaEdits;
var
  IdCabecalho: String;
begin
  inherited;

  if not CDSGrid.IsEmpty then
  begin
    IdCabecalho := IntToStr(IdRegistroSelecionado);
    ObjetoVO := TGuiasAcumuladasController.ConsultaObjeto('ID=' + IdCabecalho);
  end;

  if Assigned(ObjetoVO) then
  begin

    ComboBoxGpsTipo.ItemIndex := StrToInt(TGuiasAcumuladasVO(ObjetoVO).GpsTipo) - 1;
    EditGpsCompetencia.Text := TGuiasAcumuladasVO(ObjetoVO).GpsCompetencia;
    EditGpsValorInss.Value := TGuiasAcumuladasVO(ObjetoVO).GpsValorInss;
    EditGpsValorOutrasEntidades.Value := TGuiasAcumuladasVO(ObjetoVO).GpsValorOutrasEnt;
    EditGpsDataPagamento.Date := TGuiasAcumuladasVO(ObjetoVO).GpsDataPagamento;
    EditIrrfCompetencia.Text := TGuiasAcumuladasVO(ObjetoVO).IrrfCompetencia;
    EditIrrfCodigoRecolhimento.AsInteger := TGuiasAcumuladasVO(ObjetoVO).IrrfCodigoRecolhimento;
    EditIrrfValorAcumulado.Value := TGuiasAcumuladasVO(ObjetoVO).IrrfValorAcumulado;
    EditIrrfDataPagamento.Date := TGuiasAcumuladasVO(ObjetoVO).IrrfDataPagamento;
    EditPisCompetencia.Text := TGuiasAcumuladasVO(ObjetoVO).PisCompetencia;
    EditPisValorAcumulado.Value := TGuiasAcumuladasVO(ObjetoVO).PisValorAcumulado;
    EditPisDataPagamento.Date := TGuiasAcumuladasVO(ObjetoVO).PisDataPagamento;

    // Serializa o objeto para consultar posteriormente se houve alterações
    FormatSettings.DecimalSeparator := '.';
    StringObjetoOld := ObjetoVO.ToJSONString;
    FormatSettings.DecimalSeparator := ',';
  end;
end;
{$ENDREGION}

end.

