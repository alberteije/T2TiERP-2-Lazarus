{ *******************************************************************************
Title: T2Ti ERP
Description: Janela de Fechamentos para o módulo Escrita Fiscal

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
unit UFiscalFechamento;

interface

uses
  BrookHTTPClient, BrookFCLHTTPClientBroker, BrookHTTPUtils, BrookUtils, FPJson, ZDataset,
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UTelaCadastro, Menus, StdCtrls, ExtCtrls, Buttons, Grids, DBGrids,
  ComCtrls, LabeledCtrls, rxdbgrid, rxtoolbar, DBCtrls, StrUtils,
  Math, Constantes, CheckLst, ActnList, ToolWin, ShellApi, db, BufDataset, Biblioteca,
  ULookup, VO, FiscalFechamentoVO,
  FiscalFechamentoController;

  type

  TFFiscalFechamento = class(TFTelaCadastro)
    BevelEdits: TBevel;
    EditDataInicio: TLabeledDateEdit;
    EditDataFim: TLabeledDateEdit;
    ComboBoxCriterioLancamento: TLabeledComboBox;
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
  FFiscalFechamento: TFFiscalFechamento;

implementation

{$R *.lfm}

{TODO -oT2Ti -cFiscalidade : Devemos permitir mais do que um registro por empresa nessa tabela? Por que?}

{$REGION 'Controles Infra'}
procedure TFFiscalFechamento.BotaoConsultarClick(Sender: TObject);
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
    RetornoConsulta := TFiscalFechamentoController.Consulta(Filtro, IntToStr(Pagina));
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

procedure TFFiscalFechamento.BotaoSalvarClick(Sender: TObject);
begin
  inherited;
  BotaoConsultarClick(Sender);
end;

procedure TFFiscalFechamento.FormCreate(Sender: TObject);
begin
  ClasseObjetoGridVO := TFiscalFechamentoVO;
  ObjetoController := TFiscalFechamentoController.Create;

  inherited;
end;
{$ENDREGION}

{$REGION 'Controles CRUD'}
function TFFiscalFechamento.DoInserir: Boolean;
begin
  Result := inherited DoInserir;

  if Result then
  begin
    EditDataInicio.SetFocus;
  end;
end;

function TFFiscalFechamento.DoEditar: Boolean;
begin
  Result := inherited DoEditar;

  if Result then
  begin
    EditDataInicio.SetFocus;
  end;
end;

function TFFiscalFechamento.DoExcluir: Boolean;
begin
  if inherited DoExcluir then
  begin
    try
      Result := TFiscalFechamentoController(ObjetoController).Exclui(IdRegistroSelecionado);
    except
      Result := False;
    end;
  end
  else
  begin
    Result := False;
  end;

  if Result then
    TFiscalFechamentoController(ObjetoController).Consulta(Filtro, Pagina);
end;

function TFFiscalFechamento.DoSalvar: Boolean;
begin
  Result := inherited DoSalvar;

  if Result then
  begin
    try
      if not Assigned(ObjetoVO) then
        ObjetoVO := TFiscalFechamentoVO.Create;

      TFiscalFechamentoVO(ObjetoVO).IdEmpresa := Sessao.IdEmpresa;
      TFiscalFechamentoVO(ObjetoVO).DataInicio := EditDataInicio.Date;
      TFiscalFechamentoVO(ObjetoVO).DataFim := EditDataFim.Date;
      TFiscalFechamentoVO(ObjetoVO).CriterioLancamento := Copy(ComboBoxCriterioLancamento.Text, 1, 1);

      if StatusTela = stInserindo then
        Result := TFiscalFechamentoController(ObjetoController).Insere(TFiscalFechamentoVO(ObjetoVO))
      else if StatusTela = stEditando then
      begin
        /// EXERCICIO: Verifique se tem como serializar as listas junto com o objeto para realizar a comparação
        //begin
        //TFiscalFechamentoVO(ObjetoVO).Id := IdRegistroSelecionado;
          TFiscalFechamentoController.Altera(TFiscalFechamentoVO(ObjetoVO));
        //end
        //else
        //Application.MessageBox('Nenhum dado foi alterado.', 'Mensagem do Sistema', MB_OK + MB_ICONINFORMATION);
    except
      Result := False;
    end;
  end;
end;
{$ENDREGION}

{$REGION 'Controle de Grid'}
procedure TFFiscalFechamento.GridParaEdits;
var
  IdCabecalho: String;
begin
  inherited;

  if not CDSGrid.IsEmpty then
  begin
    ObjetoVO := ObjetoController.VO<TFiscalFechamentoVO>(IdRegistroSelecionado);
    if StatusTela = stEditando then
      ObjetoOldVO := ObjetoController.VO<TFiscalFechamentoVO>(IdRegistroSelecionado);
  end;

  if Assigned(ObjetoVO) then
  begin
    EditDataInicio.Date := TFiscalFechamentoVO(ObjetoVO).DataInicio;
    EditDataFim.Date := TFiscalFechamentoVO(ObjetoVO).DataFim;

    case AnsiIndexStr(TFiscalFechamentoVO(ObjetoVO).CriterioLancamento, ['L', 'A', 'N']) of
      0:
        ComboBoxCriterioLancamento.ItemIndex := 0;
      1:
        ComboBoxCriterioLancamento.ItemIndex := 1;
      2:
        ComboBoxCriterioLancamento.ItemIndex := 2;
    end;
  end;
end;
{$ENDREGION}

end.

