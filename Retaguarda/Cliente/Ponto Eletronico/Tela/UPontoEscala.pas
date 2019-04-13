{ *******************************************************************************
Title: T2Ti ERP
Description: Janela Cadastro de Escalas para o Ponto Eletrônico

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
unit UPontoEscala;

{$MODE Delphi}

interface

uses
  BrookHTTPClient, BrookFCLHTTPClientBroker, BrookHTTPUtils, BrookUtils, FPJson, ZDataset,
  LCLIntf, LCLType, LMessages, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UTelaCadastro, Menus, StdCtrls, ExtCtrls, Buttons, Grids, DBGrids,
  ComCtrls, LabeledCtrls, rxdbgrid, rxtoolbar, DBCtrls, StrUtils,
  Math, Constantes, CheckLst, ActnList, ToolWin, db, BufDataset, Biblioteca,
  ULookup, VO, PontoEscalaVO,
  PontoEscalaController;

  type

  { TFPontoEscala }

  TFPontoEscala = class(TFTelaCadastro)
    CDSHorarios: TBufDataset;
    CDSPontoTurma: TBufDataset;
    DSPontoTurma: TDataSource;
    PanelMestre: TPanel;
    EditNome: TLabeledEdit;
    EditDescontoHoraDia: TLabeledMaskEdit;
    EditDescontoDsr: TLabeledMaskEdit;
    PageControlItens: TPageControl;
    tsItens: TTabSheet;
    PanelItens: TPanel;
    GridTurmas: TRxDbGrid;
    GroupBoxHorarios: TGroupBox;
    GridHorarios: TRxDbGrid;
    DSHorarios: TDataSource;
    procedure FormCreate(Sender: TObject);
    procedure GridDblClick(Sender: TObject);
    procedure GridTurmasKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure CDSPontoTurmaBeforeDelete(DataSet: TDataSet);
    procedure GridHorariosKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure CDSHorariosAfterPost(DataSet: TDataSet);

    procedure BotaoConsultarClick(Sender: TObject);
    procedure BotaoSalvarClick(Sender: TObject);
  private
    { Private declarations }
    procedure PopularGridHorarios;
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
  FPontoEscala: TFPontoEscala;

implementation

uses UDataModule, PontoTurmaController, PontoTurmaVO,
  PontoHorarioVO, PontoHorarioController;
{$R *.lfm}

{$REGION 'Infra'}
procedure TFPontoEscala.BotaoConsultarClick(Sender: TObject);
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
    RetornoConsulta := TPontoEscalaController.Consulta(Filtro, IntToStr(Pagina));
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

procedure TFPontoEscala.BotaoSalvarClick(Sender: TObject);
begin
  inherited;
  BotaoConsultarClick(Sender);
end;

procedure TFPontoEscala.FormCreate(Sender: TObject);
begin
  ClasseObjetoGridVO := TPontoEscalaVO;
  ObjetoController := TPontoEscalaController.Create;

  inherited;

  BotaoImprimir.Visible := False;
  MenuImprimir.Visible := False;

  ConfiguraCDSFromVO(CDSPontoTurma, TPontoTurmaVO);

  //configura Dataset
  CDSHorarios.Close;
  CDSHorarios.FieldDefs.Clear;

  CDSHorarios.FieldDefs.add('DIA', ftString, 20);
  CDSHorarios.FieldDefs.add('CODIGO', ftString, 2);
  CDSHorarios.FieldDefs.add('NOME', ftString, 50);

  CDSHorarios.CreateDataset;
  CDSHorarios.Open;
end;

procedure TFPontoEscala.LimparCampos;
begin
  inherited;
  CDSPontoTurma.Close;
  CDSHorarios.Close;
  CDSPontoTurma.Open;
  CDSHorarios.Open;
end;

procedure TFPontoEscala.ConfigurarLayoutTela;
begin
  PanelEdits.Enabled := True;

  if StatusTela = stNavegandoEdits then
  begin
    PanelMestre.Enabled := False;
    PanelItens.Enabled := False;
  end
  else
  begin
    PanelMestre.Enabled := True;
    PanelItens.Enabled := True;
  end;
end;
{$ENDREGION}

{$REGION 'Controles CRUD'}
function TFPontoEscala.DoInserir: Boolean;
begin
  Result := inherited DoInserir;

  if Result then
  begin
    ConfigurarLayoutTela;
    PopularGridHorarios;
    EditNome.SetFocus;
  end;
end;

function TFPontoEscala.DoEditar: Boolean;
begin
  Result := inherited DoEditar;

  if Result then
  begin
    ConfigurarLayoutTela;
    PopularGridHorarios;
    EditNome.SetFocus;
  end;
end;

function TFPontoEscala.DoExcluir: Boolean;
begin
  if inherited DoExcluir then
  begin
    try
      Result := TPontoEscalaController.Exclui(IdRegistroSelecionado);
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

function TFPontoEscala.DoSalvar: Boolean;
var
  PontoTurma: TPontoTurmaVO;
begin
  Result := inherited DoSalvar;

  if Result then
  begin
    try
      if not Assigned(ObjetoVO) then
        ObjetoVO := TPontoEscalaVO.Create;

      TPontoEscalaVO(ObjetoVO).IdEmpresa := Sessao.Empresa.Id;
      TPontoEscalaVO(ObjetoVO).Nome := EditNome.Text;
      TPontoEscalaVO(ObjetoVO).DescontoHoraDia := EditDescontoHoraDia.Text;
      TPontoEscalaVO(ObjetoVO).DescontoDsr := EditDescontoDsr.Text;

      // Horários
      CDSHorarios.DisableControls;
      CDSHorarios.First;
      while not CDSHorarios.Eof do
      begin
        TPontoEscalaVO(ObjetoVO).CodigoHorarioDomingo := CDSHorarios.FieldByName('CODIGO').AsString;
        CDSHorarios.Next;
        TPontoEscalaVO(ObjetoVO).CodigoHorarioSegunda := CDSHorarios.FieldByName('CODIGO').AsString;
        CDSHorarios.Next;
        TPontoEscalaVO(ObjetoVO).CodigoHorarioTerca := CDSHorarios.FieldByName('CODIGO').AsString;
        CDSHorarios.Next;
        TPontoEscalaVO(ObjetoVO).CodigoHorarioQuarta := CDSHorarios.FieldByName('CODIGO').AsString;
        CDSHorarios.Next;
        TPontoEscalaVO(ObjetoVO).CodigoHorarioQuinta := CDSHorarios.FieldByName('CODIGO').AsString;
        CDSHorarios.Next;
        TPontoEscalaVO(ObjetoVO).CodigoHorarioSexta := CDSHorarios.FieldByName('CODIGO').AsString;
        CDSHorarios.Next;
        TPontoEscalaVO(ObjetoVO).CodigoHorarioSabado := CDSHorarios.FieldByName('CODIGO').AsString;
        CDSHorarios.Next;
      end;
      CDSHorarios.First;
      CDSHorarios.EnableControls;

      // Turmas
      CDSPontoTurma.DisableControls;
      CDSPontoTurma.First;
      while not CDSPontoTurma.Eof do
      begin
          PontoTurma := TPontoTurmaVO.Create;
          PontoTurma.Id := CDSPontoTurma.FieldByName('ID').AsInteger;
          PontoTurma.IdPontoEscala := TPontoEscalaVO(ObjetoVO).Id;
          PontoTurma.Codigo := CDSPontoTurma.FieldByName('CODIGO').AsString;
          PontoTurma.Nome := CDSPontoTurma.FieldByName('NOME').AsString;

          TPontoEscalaVO(ObjetoVO).ListaPontoTurmaVO.Add(PontoTurma);

        CDSPontoTurma.Next;
      end;
      CDSPontoTurma.EnableControls;

      if StatusTela = stInserindo then
      begin
        TPontoEscalaController.Insere(TPontoEscalaVO(ObjetoVO));
      end
      else if StatusTela = stEditando then
      begin
        /// EXERCICIO: Verifique se tem como serializar as listas junto com o objeto para realizar a comparação
        //if TPontoEscalaVO(ObjetoVO).ToJSONString <> StringObjetoOld then
        //begin
          TPontoEscalaController.Altera(TPontoEscalaVO(ObjetoVO));
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

{$REGION 'Controle de Grid'}
procedure TFPontoEscala.GridDblClick(Sender: TObject);
begin
  inherited;
  ConfigurarLayoutTela;
  PopularGridHorarios;
end;

procedure TFPontoEscala.GridParaEdits;
var
  IdCabecalho: String;
  Current: TPontoTurmaVO;
  I: Integer;
begin
  inherited;

  if not CDSGrid.IsEmpty then
  begin
    IdCabecalho := IntToStr(IdRegistroSelecionado);
    ObjetoVO := TPontoEscalaController.ConsultaObjeto('ID=' + IdCabecalho);
  end;

  if Assigned(ObjetoVO) then
  begin
    EditNome.Text := TPontoEscalaVO(ObjetoVO).Nome;
    EditDescontoHoraDia.Text := TPontoEscalaVO(ObjetoVO).DescontoHoraDia;
    EditDescontoDsr.Text := TPontoEscalaVO(ObjetoVO).DescontoDsr;

    // Turmas
    for I := 0 to TPontoEscalaVO(ObjetoVO).ListaPontoTurmaVO.Count - 1 do
    begin
      Current := TPontoEscalaVO(ObjetoVO).ListaPontoTurmaVO[I];

      CDSPontoTurma.Append;

      CDSPontoTurma.FieldByName('ID').AsInteger := Current.Id;
      CDSPontoTurma.FieldByName('ID_PONTO_ESCALA').AsInteger := Current.IdPontoEscala;
      CDSPontoTurma.FieldByName('CODIGO').AsString := Current.Codigo;
      CDSPontoTurma.FieldByName('NOME').AsString := Current.Nome;

      CDSPontoTurma.Post;
    end;

    // Serializa o objeto para consultar posteriormente se houve alterações
    FormatSettings.DecimalSeparator := '.';
    StringObjetoOld := ObjetoVO.ToJSONString;
    FormatSettings.DecimalSeparator := ',';
  end;
end;

procedure TFPontoEscala.GridHorariosKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  (*

  ///EXERCICIO: Implemente com a janela FLookup

  if Key = VK_F1 then
  begin
    try
        if Assigned(ViewPessoaColaboradorVO) then
      begin
      CDSHorarios.Edit;
      CDSHorarios.FieldByName('CODIGO').AsString := ULookup.FLookup.CDSLookup.FieldByName('CODIGO').AsString;
      CDSHorariosNOME.AsString := ULookup.FLookup.CDSLookup.FieldByName('NOME').AsString;
      CDSHorarios.Post;
      end;
    finally
    end;
  end;
  *)
end;

procedure TFPontoEscala.GridTurmasKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  If Key = VK_RETURN then
    GridTurmas.SelectedIndex := GridTurmas.SelectedIndex + 1;
end;

procedure TFPontoEscala.CDSHorariosAfterPost(DataSet: TDataSet);
begin
  if CDSHorarios.FieldByName('DIA').AsString = '' then
    CDSHorarios.Delete;
end;

procedure TFPontoEscala.CDSPontoTurmaBeforeDelete(DataSet: TDataSet);
begin
  if CDSPontoTurma.FieldByName('ID').AsInteger > 0 then
    TPontoTurmaController.Exclui(CDSPontoTurma.FieldByName('ID').AsInteger);
end;

procedure TFPontoEscala.PopularGridHorarios;
var
  i: Integer;
  Horario: TPontoHorarioVO;
begin
  CDSHorarios.DisableControls;
  for i := 1 to 7 do
  begin
    CDSHorarios.Append;
    case i of
      1:
        begin
          CDSHorarios.FieldByName('DIA').AsString := 'Domingo';
          if (StatusTela = stEditando) or (StatusTela = stNavegandoEdits) then
          begin
            CDSHorarios.FieldByName('CODIGO').AsString := TPontoEscalaVO(ObjetoVO).CodigoHorarioDomingo;
            Horario := TPontoHorarioController.ConsultaObjeto('CODIGO = ' + QuotedStr(TPontoEscalaVO(ObjetoVO).CodigoHorarioDomingo));
            CDSHorarios.FieldByName('NOME').AsString := Horario.Nome;
          end;
        end;
      2:
        begin
          CDSHorarios.FieldByName('DIA').AsString := 'Segunda';
          if (StatusTela = stEditando) or (StatusTela = stNavegandoEdits) then
          begin
            CDSHorarios.FieldByName('CODIGO').AsString := TPontoEscalaVO(ObjetoVO).CodigoHorarioSegunda;
            Horario := TPontoHorarioController.ConsultaObjeto('CODIGO = ' + QuotedStr(TPontoEscalaVO(ObjetoVO).CodigoHorarioSegunda));
            CDSHorarios.FieldByName('NOME').AsString := Horario.Nome;
          end;
        end;
      3:
        begin
          CDSHorarios.FieldByName('DIA').AsString := 'Terça';
          if (StatusTela = stEditando) or (StatusTela = stNavegandoEdits) then
          begin
            CDSHorarios.FieldByName('CODIGO').AsString := TPontoEscalaVO(ObjetoVO).CodigoHorarioTerca;
            Horario := TPontoHorarioController.ConsultaObjeto('CODIGO = ' + QuotedStr(TPontoEscalaVO(ObjetoVO).CodigoHorarioTerca));
            CDSHorarios.FieldByName('NOME').AsString := Horario.Nome;
          end;
        end;
      4:
        begin
          CDSHorarios.FieldByName('DIA').AsString := 'Quarta';
          if (StatusTela = stEditando) or (StatusTela = stNavegandoEdits) then
          begin
            CDSHorarios.FieldByName('CODIGO').AsString := TPontoEscalaVO(ObjetoVO).CodigoHorarioQuarta;
            Horario := TPontoHorarioController.ConsultaObjeto('CODIGO = ' + QuotedStr(TPontoEscalaVO(ObjetoVO).CodigoHorarioQuarta));
            CDSHorarios.FieldByName('NOME').AsString := Horario.Nome;
          end;
        end;
      5:
        begin
          CDSHorarios.FieldByName('DIA').AsString := 'Quinta';
          if (StatusTela = stEditando) or (StatusTela = stNavegandoEdits) then
          begin
            CDSHorarios.FieldByName('CODIGO').AsString := TPontoEscalaVO(ObjetoVO).CodigoHorarioQuinta;
            Horario := TPontoHorarioController.ConsultaObjeto('CODIGO = ' + QuotedStr(TPontoEscalaVO(ObjetoVO).CodigoHorarioQuinta));
            CDSHorarios.FieldByName('NOME').AsString := Horario.Nome;
          end;
        end;
      6:
        begin
          CDSHorarios.FieldByName('DIA').AsString := 'Sexta';
          if (StatusTela = stEditando) or (StatusTela = stNavegandoEdits) then
          begin
            CDSHorarios.FieldByName('CODIGO').AsString := TPontoEscalaVO(ObjetoVO).CodigoHorarioSexta;
            Horario := TPontoHorarioController.ConsultaObjeto('CODIGO = ' + QuotedStr(TPontoEscalaVO(ObjetoVO).CodigoHorarioSexta));
            CDSHorarios.FieldByName('NOME').AsString := Horario.Nome;
          end;
        end;
      7:
        begin
          CDSHorarios.FieldByName('DIA').AsString := 'Sábado';
          if (StatusTela = stEditando) or (StatusTela = stNavegandoEdits) then
          begin
            CDSHorarios.FieldByName('CODIGO').AsString := TPontoEscalaVO(ObjetoVO).CodigoHorarioSabado;
            Horario := TPontoHorarioController.ConsultaObjeto('CODIGO = ' + QuotedStr(TPontoEscalaVO(ObjetoVO).CodigoHorarioSabado));
            CDSHorarios.FieldByName('NOME').AsString := Horario.Nome;
          end;
        end;
    end;
    CDSHorarios.Post;
  end;
  CDSHorarios.First;
  CDSHorarios.EnableControls;
end;
{$ENDREGION}

end.

