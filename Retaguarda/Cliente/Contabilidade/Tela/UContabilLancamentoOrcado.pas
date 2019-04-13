{ *******************************************************************************
Title: T2Ti ERP
Description: Janela de Lançamento Orçado para o módulo Contabilidade

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
unit UContabilLancamentoOrcado;

{$MODE Delphi}

interface

uses
  BrookHTTPClient, BrookFCLHTTPClientBroker, BrookHTTPUtils, BrookUtils, FPJson, ZDataset,
  LCLIntf, LCLType, LMessages, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UTelaCadastro, Menus, StdCtrls, ExtCtrls, Buttons, Grids, DBGrids,
  ComCtrls, LabeledCtrls, rxdbgrid, rxtoolbar, DBCtrls, StrUtils,
  Math, Constantes, CheckLst, ActnList, ToolWin, db, BufDataset, Biblioteca,
  ULookup, VO, ContabilLancamentoOrcadoVO,
  ContabilLancamentoOrcadoController;

  type

  { TFContabilLancamentoOrcado }

  TFContabilLancamentoOrcado = class(TFTelaCadastro)
    BevelEdits: TBevel;
    CDSMeses: TBufDataset;
    PageControlItens: TPageControl;
    tsMeses: TTabSheet;
    PanelContas: TPanel;
    GridMeses: TRxDbGrid;
    DSMeses: TDataSource;
    EditIdContabilConta: TLabeledCalcEdit;
    EditContabilConta: TLabeledEdit;
    EditAno: TLabeledMaskEdit;
    CDSMesesMES: TStringField;
    CDSMesesVALOR: TFMTBCDField;
    procedure FormCreate(Sender: TObject);
    procedure GridDblClick(Sender: TObject);
    procedure CDSMesesAfterPost(DataSet: TDataSet);
    procedure EditIdContabilContaKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure BotaoConsultarClick(Sender: TObject);
    procedure BotaoSalvarClick(Sender: TObject);
  private
    { Private declarations }
    procedure PopularGridMeses;
  public
    { Public declarations }
    procedure GridParaEdits; override;
    procedure LimparCampos; override;

    // Controles CRUD
    function DoInserir: Boolean; override;
    function DoEditar: Boolean; override;
    function DoExcluir: Boolean; override;
    function DoSalvar: Boolean; override;
  end;

var
  FContabilLancamentoOrcado: TFContabilLancamentoOrcado;

implementation

uses ContabilContaVO, ContabilContaController;

{$R *.lfm}

{$REGION 'Controles Infra'}
procedure TFContabilLancamentoOrcado.BotaoConsultarClick(Sender: TObject);
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
    RetornoConsulta := TContabilLancamentoOrcadoController.Consulta(Filtro, IntToStr(Pagina));
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

procedure TFContabilLancamentoOrcado.BotaoSalvarClick(Sender: TObject);
begin
  inherited;
  BotaoConsultarClick(Sender);
end;

procedure TFContabilLancamentoOrcado.FormCreate(Sender: TObject);
begin
  ClasseObjetoGridVO := TContabilLancamentoOrcadoVO;
  ObjetoController := TContabilLancamentoOrcadoController.Create;

  inherited;
  BotaoImprimir.Visible := False;
  MenuImprimir.Visible := False;

  //configura Dataset
  CDSMeses.Close;
  CDSMeses.FieldDefs.Clear;

  CDSMeses.FieldDefs.add('MES', ftString, 30);
  CDSMeses.FieldDefs.add('VALOR', ftFloat);
  CDSMeses.CreateDataset;
  CDSMeses.Open;
end;

procedure TFContabilLancamentoOrcado.LimparCampos;
begin
  inherited;
  CDSMeses.Close;
  CDSMeses.Open;
end;
{$ENDREGION}

{$REGION 'Controles CRUD'}
function TFContabilLancamentoOrcado.DoInserir: Boolean;
begin
  Result := inherited DoInserir;

  if Result then
  begin
    PopularGridMeses;
    EditIdContabilConta.SetFocus;
  end;
end;

function TFContabilLancamentoOrcado.DoEditar: Boolean;
begin
  Result := inherited DoEditar;

  if Result then
  begin
    PopularGridMeses;
    EditIdContabilConta.SetFocus;
  end;
end;

function TFContabilLancamentoOrcado.DoExcluir: Boolean;
begin
  if inherited DoExcluir then
  begin
    try
      Result := TContabilLancamentoOrcadoController.Exclui(IdRegistroSelecionado);
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

function TFContabilLancamentoOrcado.DoSalvar: Boolean;
begin
  Result := inherited DoSalvar;

  if Result then
  begin
    try
      if not Assigned(ObjetoVO) then
        ObjetoVO := TContabilLancamentoOrcadoVO.Create;

      TContabilLancamentoOrcadoVO(ObjetoVO).IdEmpresa := Sessao.Empresa.Id;
      TContabilLancamentoOrcadoVO(ObjetoVO).IdContabilConta := EditIdContabilConta.AsInteger;
      TContabilLancamentoOrcadoVO(ObjetoVO).ContabilConta := EditContabilConta.Text;
      TContabilLancamentoOrcadoVO(ObjetoVO).Ano := EditAno.Text;

      // Meses
      CDSMeses.DisableControls;
      CDSMeses.First;
      while not CDSMeses.Eof do
      begin
        TContabilLancamentoOrcadoVO(ObjetoVO).Janeiro := CDSMeses.FieldByName('VALOR').AsFloat;
        CDSMeses.Next;
        TContabilLancamentoOrcadoVO(ObjetoVO).Fevereiro := CDSMeses.FieldByName('VALOR').AsFloat;
        CDSMeses.Next;
        TContabilLancamentoOrcadoVO(ObjetoVO).Marco := CDSMeses.FieldByName('VALOR').AsFloat;
        CDSMeses.Next;
        TContabilLancamentoOrcadoVO(ObjetoVO).Abril := CDSMeses.FieldByName('VALOR').AsFloat;
        CDSMeses.Next;
        TContabilLancamentoOrcadoVO(ObjetoVO).Maio := CDSMeses.FieldByName('VALOR').AsFloat;
        CDSMeses.Next;
        TContabilLancamentoOrcadoVO(ObjetoVO).Junho := CDSMeses.FieldByName('VALOR').AsFloat;
        CDSMeses.Next;
        TContabilLancamentoOrcadoVO(ObjetoVO).Julho := CDSMeses.FieldByName('VALOR').AsFloat;
        CDSMeses.Next;
        TContabilLancamentoOrcadoVO(ObjetoVO).Agosto := CDSMeses.FieldByName('VALOR').AsFloat;
        CDSMeses.Next;
        TContabilLancamentoOrcadoVO(ObjetoVO).Setembro := CDSMeses.FieldByName('VALOR').AsFloat;
        CDSMeses.Next;
        TContabilLancamentoOrcadoVO(ObjetoVO).Outubro := CDSMeses.FieldByName('VALOR').AsFloat;
        CDSMeses.Next;
        TContabilLancamentoOrcadoVO(ObjetoVO).Novembro := CDSMeses.FieldByName('VALOR').AsFloat;
        CDSMeses.Next;
        TContabilLancamentoOrcadoVO(ObjetoVO).Dezembro := CDSMeses.FieldByName('VALOR').AsFloat;
        CDSMeses.Next;
      end;
      CDSMeses.First;
      CDSMeses.EnableControls;

      if StatusTela = stInserindo then
      begin
        TContabilLancamentoOrcadoController.Insere(TContabilLancamentoOrcadoVO(ObjetoVO));
      end
      else if StatusTela = stEditando then
      begin
        if TContabilLancamentoOrcadoVO(ObjetoVO).ToJSONString <> StringObjetoOld then
        begin
          TContabilLancamentoOrcadoController.Altera(TContabilLancamentoOrcadoVO(ObjetoVO));
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
procedure TFContabilLancamentoOrcado.GridDblClick(Sender: TObject);
begin
  inherited;
  PopularGridMeses;
end;

procedure TFContabilLancamentoOrcado.GridParaEdits;
var
  IdCabecalho: String;
begin
  inherited;

  if not CDSGrid.IsEmpty then
  begin
    IdCabecalho := IntToStr(IdRegistroSelecionado);
    ObjetoVO := TContabilLancamentoOrcadoController.ConsultaObjeto('ID=' + IdCabecalho);
  end;

  if Assigned(ObjetoVO) then
  begin
    EditIdContabilConta.AsInteger := TContabilLancamentoOrcadoVO(ObjetoVO).IdContabilConta;
    EditContabilConta.Text := TContabilLancamentoOrcadoVO(ObjetoVO).ContabilConta;
    EditAno.Text := TContabilLancamentoOrcadoVO(ObjetoVO).Ano;

    // Serializa o objeto para consultar posteriormente se houve alterações
    FormatSettings.DecimalSeparator := '.';
    StringObjetoOld := ObjetoVO.ToJSONString;
    FormatSettings.DecimalSeparator := ',';
  end;
end;

procedure TFContabilLancamentoOrcado.PopularGridMeses;
var
  i: Integer;
begin
  for i := 1 to 12 do
  begin
    CDSMeses.Append;
    case i of
      1:
        begin
          CDSMeses.FieldByName('MES').AsString := 'Janeiro';
          if (StatusTela = stEditando) or (StatusTela = stNavegandoEdits) then
          begin
            CDSMeses.FieldByName('VALOR').AsFloat := TContabilLancamentoOrcadoVO(ObjetoVO).Janeiro;
          end;
        end;
      2:
        begin
          CDSMeses.FieldByName('MES').AsString := 'Fevereiro';
          if (StatusTela = stEditando) or (StatusTela = stNavegandoEdits) then
          begin
            CDSMeses.FieldByName('VALOR').AsFloat := TContabilLancamentoOrcadoVO(ObjetoVO).Fevereiro;
          end;
        end;
      3:
        begin
          CDSMeses.FieldByName('MES').AsString := 'Março';
          if (StatusTela = stEditando) or (StatusTela = stNavegandoEdits) then
          begin
            CDSMeses.FieldByName('VALOR').AsFloat := TContabilLancamentoOrcadoVO(ObjetoVO).Marco;
          end;
        end;
      4:
        begin
          CDSMeses.FieldByName('MES').AsString := 'Abril';
          if (StatusTela = stEditando) or (StatusTela = stNavegandoEdits) then
          begin
            CDSMeses.FieldByName('VALOR').AsFloat := TContabilLancamentoOrcadoVO(ObjetoVO).Abril;
          end;
        end;
      5:
        begin
          CDSMeses.FieldByName('MES').AsString := 'Maio';
          if (StatusTela = stEditando) or (StatusTela = stNavegandoEdits) then
          begin
            CDSMeses.FieldByName('VALOR').AsFloat := TContabilLancamentoOrcadoVO(ObjetoVO).Maio;
          end;
        end;
      6:
        begin
          CDSMeses.FieldByName('MES').AsString := 'Junho';
          if (StatusTela = stEditando) or (StatusTela = stNavegandoEdits) then
          begin
            CDSMeses.FieldByName('VALOR').AsFloat := TContabilLancamentoOrcadoVO(ObjetoVO).Junho;
          end;
        end;
      7:
        begin
          CDSMeses.FieldByName('MES').AsString := 'Julho';
          if (StatusTela = stEditando) or (StatusTela = stNavegandoEdits) then
          begin
            CDSMeses.FieldByName('VALOR').AsFloat := TContabilLancamentoOrcadoVO(ObjetoVO).Julho;
          end;
        end;
      8:
        begin
          CDSMeses.FieldByName('MES').AsString := 'Agosto';
          if (StatusTela = stEditando) or (StatusTela = stNavegandoEdits) then
          begin
            CDSMeses.FieldByName('VALOR').AsFloat := TContabilLancamentoOrcadoVO(ObjetoVO).Agosto;
          end;
        end;
      9:
        begin
          CDSMeses.FieldByName('MES').AsString := 'Setembro';
          if (StatusTela = stEditando) or (StatusTela = stNavegandoEdits) then
          begin
            CDSMeses.FieldByName('VALOR').AsFloat := TContabilLancamentoOrcadoVO(ObjetoVO).Setembro;
          end;
        end;
      10:
        begin
          CDSMeses.FieldByName('MES').AsString := 'Outubro';
          if (StatusTela = stEditando) or (StatusTela = stNavegandoEdits) then
          begin
            CDSMeses.FieldByName('VALOR').AsFloat := TContabilLancamentoOrcadoVO(ObjetoVO).Outubro;
          end;
        end;
      11:
        begin
          CDSMeses.FieldByName('MES').AsString := 'Novembro';
          if (StatusTela = stEditando) or (StatusTela = stNavegandoEdits) then
          begin
            CDSMeses.FieldByName('VALOR').AsFloat := TContabilLancamentoOrcadoVO(ObjetoVO).Novembro;
          end;
        end;
      12:
        begin
          CDSMeses.FieldByName('MES').AsString := 'Dezembro';
          if (StatusTela = stEditando) or (StatusTela = stNavegandoEdits) then
          begin
            CDSMeses.FieldByName('VALOR').AsFloat := TContabilLancamentoOrcadoVO(ObjetoVO).Dezembro;
          end;
        end;
    end;
    CDSMeses.Post;
  end;
  CDSMeses.First;
end;

procedure TFContabilLancamentoOrcado.CDSMesesAfterPost(DataSet: TDataSet);
begin
  if CDSMesesMES.AsString = '' then
    CDSMeses.Delete;
end;
{$ENDREGION}

{$REGION 'Campos Transientes'}
procedure TFContabilLancamentoOrcado.EditIdContabilContaKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
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
      EditIdContabilConta.Clear;
      EditContabilConta.Clear;

      ContabilContaVO := TContabilContaController.ConsultaObjeto(Filtro);
      if Assigned(ContabilContaVO) then
      begin
        EditIdContabilConta.Text := CDSTransiente.FieldByName('ID').AsString;
        EditContabilConta.Text := ContabilContaVO.Descricao;
        EditAno.SetFocus;
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

