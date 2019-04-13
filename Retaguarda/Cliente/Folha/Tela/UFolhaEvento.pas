{ *******************************************************************************
Title: T2Ti ERP
Description: Janela Eventos para a Folha de Pagamento

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
unit UFolhaEvento;

{$MODE Delphi}

interface

uses
  BrookHTTPClient, BrookFCLHTTPClientBroker, BrookHTTPUtils, BrookUtils, FPJson, ZDataset,
  LCLIntf, LCLType, LMessages, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UTelaCadastro, Menus, StdCtrls, ExtCtrls, Buttons, Grids, DBGrids,
  ComCtrls, LabeledCtrls, rxdbgrid, rxtoolbar, DBCtrls, StrUtils,
  Math, Constantes, CheckLst, ActnList, ToolWin, db, BufDataset, Biblioteca,
  ULookup, VO, FolhaEventoVO,
  FolhaEventoController;

  type

  TFFolhaEvento = class(TFTelaCadastro)
    BevelEdits: TBevel;
    ComboBoxBaseCalculo: TLabeledComboBox;
    EditTaxa: TLabeledCalcEdit;
    EditCodigo: TLabeledEdit;
    EditNome: TLabeledEdit;
    MemoDescricao: TLabeledMemo;
    ComboBoxTipo: TLabeledComboBox;
    ComboBoxUnidade: TLabeledComboBox;
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
  FFolhaEvento: TFFolhaEvento;

implementation

{$R *.lfm}

{$REGION 'Controles Infra'}
procedure TFFolhaEvento.BotaoConsultarClick(Sender: TObject);
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
    RetornoConsulta := TFolhaEventoController.Consulta(Filtro, IntToStr(Pagina));
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

procedure TFFolhaEvento.BotaoSalvarClick(Sender: TObject);
begin
  inherited;
  BotaoConsultarClick(Sender);
end;

procedure TFFolhaEvento.FormCreate(Sender: TObject);
begin
  ClasseObjetoGridVO := TFolhaEventoVO;
  ObjetoController := TFolhaEventoController.Create;

  inherited;
end;
{$ENDREGION}

{$REGION 'Controles CRUD'}
function TFFolhaEvento.DoInserir: Boolean;
begin
  Result := inherited DoInserir;

  if Result then
  begin
    EditCodigo.SetFocus;
  end;
end;

function TFFolhaEvento.DoEditar: Boolean;
begin
  Result := inherited DoEditar;

  if Result then
  begin
    EditCodigo.SetFocus;
  end;
end;

function TFFolhaEvento.DoExcluir: Boolean;
begin
  if inherited DoExcluir then
  begin
    try
      Result := TFolhaEventoController.Exclui(IdRegistroSelecionado);
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

function TFFolhaEvento.DoSalvar: Boolean;
begin
  Result := inherited DoSalvar;

  if Result then
  begin
    try
      if not Assigned(ObjetoVO) then
        ObjetoVO := TFolhaEventoVO.Create;

      TFolhaEventoVO(ObjetoVO).IdEmpresa := Sessao.Empresa.Id;
      TFolhaEventoVO(ObjetoVO).Codigo := EditCodigo.Text;
      TFolhaEventoVO(ObjetoVO).Nome := EditNome.Text;
      TFolhaEventoVO(ObjetoVO).Descricao := MemoDescricao.Text;
      TFolhaEventoVO(ObjetoVO).BaseCalculo := Copy(ComboBoxBaseCalculo.Text, 1, 2);
      TFolhaEventoVO(ObjetoVO).Tipo := IfThen(ComboBoxTipo.ItemIndex = 0, 'P', 'D');
      TFolhaEventoVO(ObjetoVO).Unidade := IfThen(ComboBoxUnidade.ItemIndex = 0, 'V', 'P');
      TFolhaEventoVO(ObjetoVO).Taxa := EditTaxa.Value;

      if StatusTela = stInserindo then
      begin
        TFolhaEventoController.Insere(TFolhaEventoVO(ObjetoVO));
      end
      else if StatusTela = stEditando then
      begin
        if TFolhaEventoVO(ObjetoVO).ToJSONString <> StringObjetoOld then
        begin
          TFolhaEventoController.Altera(TFolhaEventoVO(ObjetoVO));
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
procedure TFFolhaEvento.GridParaEdits;
var
  IdCabecalho: String;
begin
  inherited;

  if not CDSGrid.IsEmpty then
  begin
    IdCabecalho := IntToStr(IdRegistroSelecionado);
    ObjetoVO := TFolhaEventoController.ConsultaObjeto('ID=' + IdCabecalho);
  end;

  if Assigned(ObjetoVO) then
  begin
    EditCodigo.Text := TFolhaEventoVO(ObjetoVO).Codigo;
    EditNome.Text := TFolhaEventoVO(ObjetoVO).Nome;
    MemoDescricao.Text := TFolhaEventoVO(ObjetoVO).Descricao;
    ComboBoxBaseCalculo.ItemIndex := StrToInt(TFolhaEventoVO(ObjetoVO).BaseCalculo) - 1;
    ComboBoxTipo.ItemIndex := AnsiIndexStr(TFolhaEventoVO(ObjetoVO).Tipo, ['P', 'D']);
    ComboBoxUnidade.ItemIndex := AnsiIndexStr(TFolhaEventoVO(ObjetoVO).Unidade, ['V', 'P']);
    EditTaxa.Value := TFolhaEventoVO(ObjetoVO).Taxa;

    // Serializa o objeto para consultar posteriormente se houve alterações
    FormatSettings.DecimalSeparator := '.';
    StringObjetoOld := ObjetoVO.ToJSONString;
    FormatSettings.DecimalSeparator := ',';
  end;
end;
{$ENDREGION}

/// EXERCICIO
///  Inclua na tela os seguintes campos
///  [+] Tabela FOLHA_EVENTO. Campo RUBRICA_ESOCIAL incluído.
///  [+] Tabela FOLHA_EVENTO. Campo COD_INCIDENCIA_PREVIDENCIA incluído.
///  [+] Tabela FOLHA_EVENTO. Campo COD_INCIDENCIA_IRRF incluído.
///  [+] Tabela FOLHA_EVENTO. Campo COD_INCIDENCIA_FGTS incluído.
///  [+] Tabela FOLHA_EVENTO. Campo COD_INCIDENCIA_SINDICATO incluído.
///  [+] Tabela FOLHA_EVENTO. Campo REPERCUTE_DSR incluído.
///  [+] Tabela FOLHA_EVENTO. Campo REPERCUTE_13 incluído.
///  [+] Tabela FOLHA_EVENTO. Campo REPERCUTE_FERIAS incluído.
///  [+] Tabela FOLHA_EVENTO. Campo REPERCUTE_AVISO incluído.

end.

