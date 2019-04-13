{ *******************************************************************************
Title: T2Ti ERP
Description: Janela de Compromissos

The MIT License

Copyright: Copyright (C) 2015 T2Ti.COM

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
t2ti.com@gmail.com

@author Albert Eije
@version 2.0
******************************************************************************* }
unit UAgendaCompromisso;

{$MODE Delphi}

interface

uses
  BrookHTTPClient, BrookFCLHTTPClientBroker, BrookHTTPUtils, BrookUtils, FPJson, ZDataset,
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UTelaCadastro, Menus, StdCtrls, ExtCtrls, Buttons, Grids, DBGrids,
  ComCtrls, LabeledCtrls, rxdbgrid, rxtoolbar, DBCtrls, StrUtils,
  Math, Constantes, CheckLst, ActnList, ToolWin, ShellApi, db, BufDataset, Biblioteca,
  ULookup, VO;
{
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UTelaCadastro, Menus, StdCtrls, ExtCtrls, Buttons, Grids, DBGrids,
  JvExDBGrids, JvDBGrid, JvDBUltimGrid, ComCtrls, LabeledCtrls, Atributos, Constantes,
  Mask, JvExMask, JvToolEdit, JvBaseEdits, DB, DBClient, Generics.Collections,
  WideStrings, DBXMySql, FMTBcd, Provider, SqlExpr, StrUtils, System.Actions,
  Vcl.ActnList, Vcl.RibbonSilverStyleActnCtrls, Vcl.ActnMan, Vcl.ToolWin,
  Vcl.ActnCtrls, Controller, Biblioteca, Data.Win.ADODB, DBPlanner, Planner,
  Vcl.ImgList;

}type

  TFAgendaCompromisso = class(TFTelaCadastro)
    GroupBoxAgendaCompromissoDetalhe: TGroupBox;
    GridAgendaCompromissoDetalhe: TRxDbGrid;
    CDSAgendaCompromissoDetalhe: TClientDataSet;
    DSAgendaCompromissoDetalhe: TDataSource;
    ActionManager: TActionList;
    ActionIncluirConvidado: TAction;
    ActionExcluirItem: TAction;
    ActionAtualizarTotais: TAction;
    DBPlanner1: TDBPlanner;
    DBDaySource1: TDBDaySource;
    DataSource1: TDataSource;
    ADOTable1: TADOTable;
    ADOTable1KEYFIELD: TWideStringField;
    ADOTable1STARTTIME: TDateTimeField;
    ADOTable1ENDTIME: TDateTimeField;
    ADOTable1SUBJECT: TWideStringField;
    ADOTable1NOTES: TWideStringField;
    ADOTable1COLOR: TIntegerField;
    ADOTable1IMAGE: TIntegerField;
    ADOTable1CAPTION: TBooleanField;
    ImageList1: TImageList;
    ActionToolBar1: TToolPanel;
    procedure FormCreate(Sender: TObject);
    procedure DBDaySource1FieldsToItem(Sender: TObject; Fields: TFields;
      Item: TPlannerItem);
    procedure DBPlanner1ItemInsert(Sender: TObject; Position, FromSel,
      FromSelPrecise, ToSel, ToSelPrecise: Integer);
    procedure DBPlanner1ItemDelete(Sender: TObject; Item: TPlannerItem);
    procedure CDSAgendaCompromissoDetalheAfterDelete(DataSet: TDataSet);
    procedure DBDaySource1ItemToFields(Sender: TObject; Fields: TFields;
      Item: TPlannerItem);
    procedure ActionIncluirConvidadoExecute(Sender: TObject);
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
  end;

var
  FAgendaCompromisso: TFAgendaCompromisso;

implementation

uses AgendaCompromissoController, AgendaCompromissoVO, CompraTipoRequisicaoController,
  CompraTipoRequisicaoVO, ULookup,
  ViewPessoaColaboradorVO, ViewPessoaColaboradorController,
  ProdutoVO, ProdutoController;
{$R *.lfm}


/// EXERCICIO
///  Implemente a seleção do colaborador
///  Implemente a seleção da categoria do compromisso e carregue a cor de acordo
///  Implemente o controle de Alarme/Lembrete seguindo o Demo 9


{$REGION 'Infra'}
procedure TFAgendaCompromisso.BotaoConsultarClick(Sender: TObject);
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
    RetornoConsulta := TAgendaCompromissoController.Consulta(Filtro, IntToStr(Pagina));
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

procedure TFAgendaCompromisso.BotaoSalvarClick(Sender: TObject);
begin
  inherited;
  BotaoConsultarClick(Sender);
end;

procedure TFAgendaCompromisso.FormCreate(Sender: TObject);
begin
  ClasseObjetoGridVO := TAgendaCompromissoVO;
  ObjetoController := TAgendaCompromissoController.Create;

  inherited;

  // Configura a Grid dos itens
  ConfiguraCDSFromVO(CDSAgendaCompromissoDetalhe, TAgendaCompromissoVO);
  ConfiguraGridFromVO(GridAgendaCompromissoDetalhe, TAgendaCompromissoVO);
end;

procedure TFAgendaCompromisso.LimparCampos;
begin
  inherited;
  CDSAgendaCompromissoDetalhe.Close;
  CDSAgendaCompromissoDetalhe.Open;
end;
{$ENDREGION}

{$REGION 'Controles CRUD'}
function TFAgendaCompromisso.DoInserir: Boolean;
begin
  Result := inherited DoInserir;

  if Result then
  begin
    DBPlanner1.SetFocus;
  end;
end;

function TFAgendaCompromisso.DoEditar: Boolean;
begin
  Result := inherited DoEditar;

  if Result then
  begin
    DBPlanner1.SetFocus;
  end;
end;

function TFAgendaCompromisso.DoExcluir: Boolean;
begin
  if inherited DoExcluir then
  begin
    try
      Result := TAgendaCompromissoController.Exclui(IdRegistroSelecionado);
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

function TFAgendaCompromisso.DoSalvar: Boolean;
begin
  Result := inherited DoSalvar;

  if Result then
  begin
    try
      if not Assigned(ObjetoVO) then
        ObjetoVO := TAgendaCompromissoVO.Create;

      //Laço no CDS interno para persistência
      //Estamos sempre enviando todos os dados para o servidor

      /// EXERCICIO
      ///  Envie apenas os dados que foram incluídos ou alterados

      CDSAgendaCompromissoDetalhe.DisableControls;
      CDSAgendaCompromissoDetalhe.First;
      while not CDSAgendaCompromissoDetalhe.Eof do
      begin
        TAgendaCompromissoVO(ObjetoVO).Id := CDSAgendaCompromissoDetalhe.FieldByName('.FieldByName('ID')').AsInteger;
        TAgendaCompromissoVO(ObjetoVO).IdColaborador := CDSAgendaCompromissoDetalhe.FieldByName('.FieldByName('ID_COLABORADOR')').AsInteger;
        TAgendaCompromissoVO(ObjetoVO).IdAgendaCategoriaCompromisso := CDSAgendaCompromissoDetalhe.FieldByName('.FieldByName('ID_AGENDA_CATEGORIA_COMPROMISSO')').AsInteger;
        TAgendaCompromissoVO(ObjetoVO).DataCompromisso := CDSAgendaCompromissoDetalhe.FieldByName('.FieldByName('DATA_COMPROMISSO')').AsDateTime;
        TAgendaCompromissoVO(ObjetoVO).Hora := CDSAgendaCompromissoDetalhe.FieldByName('.FieldByName('HORA')').AsDateTime;
        TAgendaCompromissoVO(ObjetoVO).Duracao := CDSAgendaCompromissoDetalhe.FieldByName('.FieldByName('DURACAO')').AsDateTime;
        TAgendaCompromissoVO(ObjetoVO).Onde := CDSAgendaCompromissoDetalhe.FieldByName('.FieldByName('ONDE')').AsString;
        TAgendaCompromissoVO(ObjetoVO).Descricao := CDSAgendaCompromissoDetalhe.FieldByName('.FieldByName('DESCRICAO')').AsString;
        TAgendaCompromissoVO(ObjetoVO).Tipo := CDSAgendaCompromissoDetalhe.FieldByName('.FieldByName('TIPO')').AsInteger;
        TAgendaCompromissoVO(ObjetoVO).Chave := CDSAgendaCompromissoDetalhe.FieldByName('.FieldByName('KEYFIELD')').AsString;

        if TAgendaCompromissoVO(ObjetoVO).Id = 0 then
        TAgendaCompromissoController.Insere(TAgendaCompromissoVO(ObjetoVO));
        else
          TAgendaCompromissoController.Altera(TAgendaCompromissoVO(ObjetoVO));

        CDSAgendaCompromissoDetalhe.Next;
      end;
      CDSAgendaCompromissoDetalhe.EnableControls;

    except
      Result := False;
    end;
  end;
end;
{$ENDREGION}

{$REGION 'Controle de Grid'}
procedure TFAgendaCompromisso.GridParaEdits;
var
  IdCabecalho: String;
begin
  inherited;

  if not CDSGrid.IsEmpty then
  begin
    IdCabecalho := IntToStr(IdRegistroSelecionado);
    ObjetoVO := TAgendaCompromissoController.ConsultaObjeto('ID=' + IdCabecalho);
  end;

  if Assigned(ObjetoVO) then
  begin
    // Preenche a grid interna
    TAgendaCompromissoController.SetDataSet(CDSAgendaCompromissoDetalhe);
    BotaoConsultar.Click;

    // Serializa o objeto para consultar posteriormente se houve alterações
    FormatSettings.DecimalSeparator := '.';
    StringObjetoOld := ObjetoVO.ToJSONString;
    FormatSettings.DecimalSeparator := ',';
  end;
end;
{$ENDREGION}

{$REGION 'Actions'}
procedure TFAgendaCompromisso.ActionIncluirConvidadoExecute(Sender: TObject);
begin
  try
        if Assigned(VO) then
    begin
      /// EXERCICIO
      ///  Crie uma lista dentro de AgendaCompromissoVO para guardar os convidados e
      ///  realize a persistência dos mesmos no momento de salvar os dados
      ///  Crie uma nova aba para apresentar os convidados para cada compromisso
      ///  numa grid - Atenção com o Mestre/Detalhe.
      ///
      ///  Como realizar o controle do nível estratégico para que um chefe
      ///  possa adicionar compromissos para um subordinado? É possível fazer isso
      ///  utilizando o campo ID_CARGO da tabela Colaborador?
      ShowMessage('Convidado Incluído');
    end;
  finally
  end;
end;

procedure TFAgendaCompromisso.CDSAgendaCompromissoDetalheAfterDelete(DataSet: TDataSet);
begin
  dbdaysource1.SynchDBItems;
end;

procedure TFAgendaCompromisso.DBDaySource1FieldsToItem(Sender: TObject; Fields: TFields; Item: TPlannerItem);
begin
  inherited;
//
end;

procedure TFAgendaCompromisso.DBDaySource1ItemToFields(Sender: TObject; Fields: TFields; Item: TPlannerItem);
begin
  Fields.FieldByName('DATA_COMPROMISSO').AsDateTime := Fields.FieldByName('HORA').Value;
  Fields.FieldByName('ID_COLABORADOR').AsInteger := 1;
  Fields.FieldByName('ID_AGENDA_CATEGORIA_COMPROMISSO').AsInteger := 1;
end;

procedure TFAgendaCompromisso.DBPlanner1ItemDelete(Sender: TObject; Item: TPlannerItem);
begin
  DBPlanner1.FreeItem(Item);
end;

procedure TFAgendaCompromisso.DBPlanner1ItemInsert(Sender: TObject; Position,  FromSel, FromSelPrecise, ToSel, ToSelPrecise: Integer);
begin
  with DBPlanner1.CreateItem do
  begin
    {take the settings from the Default item - just set properties below}
    ItemBegin := FromSel;
    ItemEnd := ToSel;
    ItemPos := Position;
    Text.Text := 'Novo compromisso criado em ' + Formatdatetime('dd/mm/yyyy hh:nn', Now);
    Update;
  end;
end;

{$ENDREGION}

/// EXERCICIO
///  Crie uma aba com uma grid onde apresente o mapa de disponibilidade de determinado
///  colaborador. Ou então, verifique se é possível adicionar um colaborador
///  em determinado compromisso de acordo com os compromissos que ele já possui
///  agendados, realizando uma consulta nas tabelas do sistema.
///
end.

