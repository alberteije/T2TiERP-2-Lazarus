{ *******************************************************************************
Title: T2Ti ERP
Description: Janela de Encerramento do Exercício para o módulo Contabilidade

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
unit UContabilEncerramentoExercicio;

{$MODE Delphi}

interface

uses
  BrookHTTPClient, BrookFCLHTTPClientBroker, BrookHTTPUtils, BrookUtils, FPJson, ZDataset,
  LCLIntf, LCLType, LMessages, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UTelaCadastro, Menus, StdCtrls, ExtCtrls, Buttons, Grids, DBGrids,
  ComCtrls, LabeledCtrls, rxdbgrid, rxtoolbar, DBCtrls, StrUtils,
  Math, Constantes, CheckLst, ActnList, ToolWin, db, BufDataset, Biblioteca,
  ULookup, VO, ContabilEncerramentoExeCabVO,
  ContabilEncerramentoExeCabController;

  type

  { TFContabilEncerramentoExercicio }

  TFContabilEncerramentoExercicio = class(TFTelaCadastro)
    CDSContabilEncerramentoExercicioDetalhe: TBufDataset;
    DSContabilEncerramentoExercicioDetalhe: TDataSource;
    PanelMestre: TPanel;
    PageControlItens: TPageControl;
    tsItens: TTabSheet;
    PanelItens: TPanel;
    GridDetalhe: TRxDbGrid;
    EditDataInicio: TLabeledDateEdit;
    EditDataInclusao: TLabeledDateEdit;
    EditMotivo: TLabeledEdit;
    EditDataFim: TLabeledDateEdit;
    procedure FormCreate(Sender: TObject);
    procedure GridDblClick(Sender: TObject);

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
  FContabilEncerramentoExercicio: TFContabilEncerramentoExercicio;

implementation

uses UDataModule, ContabilEncerramentoExeDetVO;
{$R *.lfm}

{$REGION 'Controles Infra'}
procedure TFContabilEncerramentoExercicio.BotaoConsultarClick(Sender: TObject);
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
    RetornoConsulta := TContabilEncerramentoExeCabController.Consulta(Filtro, IntToStr(Pagina));
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

procedure TFContabilEncerramentoExercicio.BotaoSalvarClick(Sender: TObject);
begin
  inherited;
  BotaoConsultarClick(Sender);
end;

procedure TFContabilEncerramentoExercicio.FormCreate(Sender: TObject);
begin
  ClasseObjetoGridVO := TContabilEncerramentoExeCabVO;
  ObjetoController := TContabilEncerramentoExeCabController.Create;

  inherited;
  BotaoImprimir.Visible := False;
  MenuImprimir.Visible := False;

  ConfiguraCDSFromVO(CDSContabilEncerramentoExercicioDetalhe, TContabilEncerramentoExeDetVO);
  ConfiguraGridFromVO(GridDetalhe, TContabilEncerramentoExeDetVO);
end;

procedure TFContabilEncerramentoExercicio.LimparCampos;
begin
  inherited;
  CDSContabilEncerramentoExercicioDetalhe.Close;
  CDSContabilEncerramentoExercicioDetalhe.Open;
end;

procedure TFContabilEncerramentoExercicio.ConfigurarLayoutTela;
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
function TFContabilEncerramentoExercicio.DoInserir: Boolean;
begin
  Result := inherited DoInserir;

  ConfigurarLayoutTela;
  if Result then
  begin
    EditMotivo.SetFocus;
  end;
end;

function TFContabilEncerramentoExercicio.DoEditar: Boolean;
begin
  Result := inherited DoEditar;

  ConfigurarLayoutTela;
  if Result then
  begin
    EditMotivo.SetFocus;
  end;
end;

function TFContabilEncerramentoExercicio.DoExcluir: Boolean;
begin
  if inherited DoExcluir then
  begin
    try
      Result := TContabilEncerramentoExeCabController.Exclui(IdRegistroSelecionado);
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

function TFContabilEncerramentoExercicio.DoSalvar: Boolean;
var
  ContabilEncerramentoExercicioDetalhe: TContabilEncerramentoExeDetVO;
begin
  Result := inherited DoSalvar;

  if Result then
  begin
    try
      if not Assigned(ObjetoVO) then
        ObjetoVO := TContabilEncerramentoExeCabVO.Create;

      TContabilEncerramentoExeCabVO(ObjetoVO).IdEmpresa := Sessao.Empresa.Id;
      TContabilEncerramentoExeCabVO(ObjetoVO).Motivo := EditMotivo.Text;
      TContabilEncerramentoExeCabVO(ObjetoVO).DataInicio := EditDataInicio.Date;
      TContabilEncerramentoExeCabVO(ObjetoVO).DataFim := EditDataFim.Date;
      TContabilEncerramentoExeCabVO(ObjetoVO).DataInclusao := EditDataInclusao.Date;

      // Detalhes
      CDSContabilEncerramentoExercicioDetalhe.DisableControls;
      CDSContabilEncerramentoExercicioDetalhe.First;
      while not CDSContabilEncerramentoExercicioDetalhe.Eof do
      begin
        ContabilEncerramentoExercicioDetalhe := TContabilEncerramentoExeDetVO.Create;
        ContabilEncerramentoExercicioDetalhe.Id := CDSContabilEncerramentoExercicioDetalhe.FieldByName('ID').AsInteger;
        ContabilEncerramentoExercicioDetalhe.IdContabilEncerramentoExe := TContabilEncerramentoExeCabVO(ObjetoVO).Id;
        ContabilEncerramentoExercicioDetalhe.IdContabilConta := CDSContabilEncerramentoExercicioDetalhe.FieldByName('ID_CONTABIL_CONTA').AsInteger;
        ContabilEncerramentoExercicioDetalhe.SaldoAnterior := CDSContabilEncerramentoExercicioDetalhe.FieldByName('SALDO_ANTERIOR').AsFloat;
        ContabilEncerramentoExercicioDetalhe.ValorDebito := CDSContabilEncerramentoExercicioDetalhe.FieldByName('VALOR_DEBITO').AsFloat;
        ContabilEncerramentoExercicioDetalhe.ValorCredito := CDSContabilEncerramentoExercicioDetalhe.FieldByName('VALOR_CREDITO').AsFloat;
        ContabilEncerramentoExercicioDetalhe.Saldo := CDSContabilEncerramentoExercicioDetalhe.FieldByName('SALDO').AsFloat;
        TContabilEncerramentoExeCabVO(ObjetoVO).ListaContabilEncerramentoExeDetVO.Add(ContabilEncerramentoExercicioDetalhe);
        CDSContabilEncerramentoExercicioDetalhe.Next;
      end;
      CDSContabilEncerramentoExercicioDetalhe.EnableControls;

      if StatusTela = stInserindo then
      begin
        TContabilEncerramentoExeCabController.Insere(TContabilEncerramentoExeCabVO(ObjetoVO));
      end
      else if StatusTela = stEditando then
      begin
        /// EXERCICIO: Verifique se tem como serializar as listas junto com o objeto para realizar a comparação
        //if TContabilEncerramentoExeCabVO(ObjetoVO).ToJSONString <> StringObjetoOld then
        //begin
          TContabilEncerramentoExeCabController.Altera(TContabilEncerramentoExeCabVO(ObjetoVO));
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
procedure TFContabilEncerramentoExercicio.GridDblClick(Sender: TObject);
begin
  inherited;
  ConfigurarLayoutTela;
end;

procedure TFContabilEncerramentoExercicio.GridParaEdits;
var
  IdCabecalho: String;
  Current: TContabilEncerramentoExeDetVO;
  i:integer;
begin
  inherited;

  if not CDSGrid.IsEmpty then
  begin
    IdCabecalho := IntToStr(IdRegistroSelecionado);
    ObjetoVO := TContabilEncerramentoExeCabController.ConsultaObjeto('ID=' + IdCabecalho);
  end;

  if Assigned(ObjetoVO) then
  begin
    EditMotivo.Text := TContabilEncerramentoExeCabVO(ObjetoVO).Motivo;
    EditDataInicio.Date := TContabilEncerramentoExeCabVO(ObjetoVO).DataInicio;
    EditDataFim.Date := TContabilEncerramentoExeCabVO(ObjetoVO).DataFim;
    EditDataInclusao.Date := TContabilEncerramentoExeCabVO(ObjetoVO).DataInclusao;

    // Detalhes
    for I := 0 to TContabilEncerramentoExeCabVO(ObjetoVO).ListaContabilEncerramentoExeDetVO.Count - 1 do
    begin
      Current := TContabilEncerramentoExeCabVO(ObjetoVO).ListaContabilEncerramentoExeDetVO[I];

      CDSContabilEncerramentoExercicioDetalhe.Append;
      CDSContabilEncerramentoExercicioDetalhe.FieldByName('ID').AsInteger := Current.id;
      CDSContabilEncerramentoExercicioDetalhe.FieldByName('ID_CONTABIL_ENCERRAMENTO_EXE').AsInteger := Current.IdContabilEncerramentoExe;
      CDSContabilEncerramentoExercicioDetalhe.FieldByName('ID_CONTABIL_CONTA').AsInteger := Current.IdContabilConta;
      CDSContabilEncerramentoExercicioDetalhe.FieldByName('SALDO_ANTERIOR').AsFloat := Current.SaldoAnterior;
      CDSContabilEncerramentoExercicioDetalhe.FieldByName('VALOR_DEBITO').AsFloat := Current.ValorDebito;
      CDSContabilEncerramentoExercicioDetalhe.FieldByName('VALOR_CREDITO').AsFloat := Current.ValorCredito;
      CDSContabilEncerramentoExercicioDetalhe.FieldByName('SALDO').AsFloat := Current.Saldo;
      CDSContabilEncerramentoExercicioDetalhe.Post;
    end;

    // Serializa o objeto para consultar posteriormente se houve alterações
    FormatSettings.DecimalSeparator := '.';
    StringObjetoOld := ObjetoVO.ToJSONString;
    FormatSettings.DecimalSeparator := ',';

  end;

  ConfigurarLayoutTela;
end;
{$ENDREGION}

/// EXERCICIO
///  Implemente as rotinas automáticas no sistema

end.

