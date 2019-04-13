{ *******************************************************************************
Title: T2Ti ERP
Description: Janela Para Contagem e Conferência de Material em Estoque

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
t2ti.com@gmail.com

@author Albert Eije (alberteije@gmail.com)
@version 2.0
******************************************************************************* }
unit UInventarioContagem;

{$MODE Delphi}

interface

uses
  BrookHTTPClient, BrookFCLHTTPClientBroker, BrookHTTPUtils, BrookUtils, FPJson, ZDataset,
  LCLIntf, LCLType, LMessages, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UTelaCadastro, Menus, StdCtrls, ExtCtrls, Buttons, Grids, DBGrids,
  ComCtrls, LabeledCtrls, rxdbgrid, rxtoolbar, DBCtrls, StrUtils,
  Math, Constantes, CheckLst, ActnList, ToolWin, db, BufDataset, Biblioteca,
  ULookup, VO;

type

  { TFInventarioContagem }

  TFInventarioContagem = class(TFTelaCadastro)
    BevelEdits: TBevel;
    CDSInventarioContagemDetalhe: TBufDataset;
    DSInventarioContagemDetalhe: TDataSource;
    GroupBoxParcelas: TGroupBox;
    GridItens: TRxDbGrid;
    EditDataContagem: TLabeledDateEdit;
    ActionManager: TActionList;
    ActionSelecionarItens: TAction;
    ActionRealizarCalculos: TAction;
    ActionToolBarEdits: TToolPanel;
    CheckBoxAtualizaEstoque: TCheckBox;
    ComboBoxTipo: TLabeledComboBox;
    procedure CDSInventarioContagemDetalheBeforePost(DataSet: TDataSet);
    procedure FormCreate(Sender: TObject);
    procedure ActionSelecionarItensExecute(Sender: TObject);
    procedure ActionRealizarCalculosExecute(Sender: TObject);
    procedure CDSInventarioContagemDetalheAfterPost(DataSet: TDataSet);
    procedure CDSInventarioContagemDetalheAfterEdit(DataSet: TDataSet);
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
  FInventarioContagem: TFInventarioContagem;

implementation

uses InventarioContagemCabController, InventarioContagemCabVO,
  InventarioContagemDetVO, UDataModule, ProdutoVO, ProdutoController,
  ProdutoSubGrupoVO, ProdutoSubGrupoController;
{$R *.lfm}

{$REGION 'Infra'}
procedure TFInventarioContagem.BotaoConsultarClick(Sender: TObject);
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
    RetornoConsulta := TInventarioContagemCabController.Consulta(Filtro, IntToStr(Pagina));
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

procedure TFInventarioContagem.BotaoSalvarClick(Sender: TObject);
begin
  inherited;
  BotaoConsultarClick(Sender);
end;

procedure TFInventarioContagem.FormCreate(Sender: TObject);
begin
  ClasseObjetoGridVO := TInventarioContagemCabVO;
  ObjetoController := TInventarioContagemCabController.Create;

  inherited;

  // Configura a Grid dos itens
  ConfiguraCDSFromVO(CDSInventarioContagemDetalhe, TInventarioContagemDetVO);
  ConfiguraGridFromVO(GridItens, TInventarioContagemDetVO);
end;

procedure TFInventarioContagem.LimparCampos;
begin
  inherited;
  // Itens
  CDSInventarioContagemDetalhe.Close;
  CDSInventarioContagemDetalhe.Open;
  CheckBoxAtualizaEstoque.Checked := False;
end;
{$ENDREGION}

{$REGION 'Controles CRUD'}
function TFInventarioContagem.DoInserir: Boolean;
begin
  Result := inherited DoInserir;

  if Result then
  begin
    CheckBoxAtualizaEstoque.Enabled := False;
    EditDataContagem.SetFocus;
  end;
end;

function TFInventarioContagem.DoEditar: Boolean;
begin
  if CDSGrid.FieldByName('ESTOQUE_ATUALIZADO').AsString = 'S' then
  begin
    Application.MessageBox('Esse registro não pode ser alterado. O estoque dessa contagem já foi atualizado.', 'Mensagem do Sistema', MB_OK + MB_ICONINFORMATION);
    Exit(False);
  end;

  Result := inherited DoEditar;

  if Result then
  begin
    EditDataContagem.SetFocus;
  end;
end;

function TFInventarioContagem.DoExcluir: Boolean;
begin
  if inherited DoExcluir then
  begin
    try
      Result := TInventarioContagemCabController.Exclui(IdRegistroSelecionado);
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

function TFInventarioContagem.DoSalvar: Boolean;
var
  InventarioContagemDetalhe: TInventarioContagemDetVO;
begin
  Result := inherited DoSalvar;

  if Result then
  begin
    try
      ObjetoVO := TInventarioContagemCabVO.Create;

      TInventarioContagemCabVO(ObjetoVO).IdEmpresa := Sessao.Empresa.Id;
      TInventarioContagemCabVO(ObjetoVO).DataContagem := EditDataContagem.Date;
      TInventarioContagemCabVO(ObjetoVO).Tipo := Copy(ComboBoxTipo.Text, 1, 1);
      if CheckBoxAtualizaEstoque.Checked then
        TInventarioContagemCabVO(ObjetoVO).EstoqueAtualizado := 'S'
      else
        TInventarioContagemCabVO(ObjetoVO).EstoqueAtualizado := 'N';

      if StatusTela = stEditando then
        TInventarioContagemCabVO(ObjetoVO).Id := IdRegistroSelecionado;

      // Itens
      CDSInventarioContagemDetalhe.DisableControls;
      CDSInventarioContagemDetalhe.First;
      while not CDSInventarioContagemDetalhe.Eof do
      begin
  		  InventarioContagemDetalhe := TInventarioContagemDetVO.Create;
  		  InventarioContagemDetalhe.Id := CDSInventarioContagemDetalhe.FieldByName('ID').AsInteger;
  		  InventarioContagemDetalhe.IdInventarioContagemCab := TInventarioContagemCabVO(ObjetoVO).Id;
  		  InventarioContagemDetalhe.IdProduto := CDSInventarioContagemDetalhe.FieldByName('ID_PRODUTO').AsInteger;
  		  //InventarioContagemDetalhe.ProdutoNome := CDSInventarioContagemDetalhe.FieldByName('PRODUTONOME').AsString;
        InventarioContagemDetalhe.Contagem01 := CDSInventarioContagemDetalhe.FieldByName('CONTAGEM01').AsFloat;
        InventarioContagemDetalhe.Contagem02 := CDSInventarioContagemDetalhe.FieldByName('CONTAGEM02').AsFloat;
        InventarioContagemDetalhe.Contagem03 := CDSInventarioContagemDetalhe.FieldByName('CONTAGEM03').AsFloat;
        InventarioContagemDetalhe.FechadoContagem := CDSInventarioContagemDetalhe.FieldByName('FECHADO_CONTAGEM').AsString;  //Informar qual contagem já bateu com a quantidade do sistema
  		  InventarioContagemDetalhe.QuantidadeSistema := CDSInventarioContagemDetalhe.FieldByName('QUANTIDADE_SISTEMA').AsFloat;
  		  InventarioContagemDetalhe.Acuracidade := CDSInventarioContagemDetalhe.FieldByName('ACURACIDADE').AsFloat;
  		  InventarioContagemDetalhe.Divergencia := CDSInventarioContagemDetalhe.FieldByName('DIVERGENCIA').AsFloat;

  		  TInventarioContagemCabVO(ObjetoVO).ListaInventarioContagemDetVO.Add(InventarioContagemDetalhe);

        CDSInventarioContagemDetalhe.Next;
      end;
      CDSInventarioContagemDetalhe.EnableControls;

      if StatusTela = stInserindo then
      begin
        TInventarioContagemCabController.Insere(TInventarioContagemCabVO(ObjetoVO))
      end
      else if StatusTela = stEditando then
      begin
        /// EXERCICIO: Verifique se tem como serializar as listas junto com o objeto para realizar a comparação
        //if TInventarioContagemCabVO(ObjetoVO).ToJSONString <> TInventarioContagemCabVO(ObjetoOldVO).ToJSONString then
        //begin
          TInventarioContagemCabController.Altera(TInventarioContagemCabVO(ObjetoVO));
        //Result := TInventarioContagemCabController(ObjetoController).Altera(TInventarioContagemCabVO(ObjetoVO), TInventarioContagemCabVO(ObjetoOldVO));
        //end
        //else
        //Application.MessageBox('Nenhum dado foi alterado.', 'Mensagem do Sistema', MB_OK + MB_ICONINFORMATION);
      end;

      Result := True;
    except
      Result := False;
    end;
  end;
end;
{$ENDREGION}

{$REGION 'Controle de Grid'}
procedure TFInventarioContagem.GridParaEdits;
var
  IdCabecalho: String;
  I: Integer;
  Current: TInventarioContagemDetVO;
begin
  inherited;

  if not CDSGrid.IsEmpty then
  begin
    IdCabecalho := IntToStr(IdRegistroSelecionado);
    ObjetoVO := TInventarioContagemCabController.ConsultaObjeto('ID=' + IdCabecalho);
  end;

  if Assigned(ObjetoVO) then
  begin
    EditDataContagem.Date := TInventarioContagemCabVO(ObjetoVO).DataContagem;
    ComboBoxTipo.ItemIndex := AnsiIndexStr(TInventarioContagemCabVO(ObjetoVO).Tipo, ['G', 'D', 'R', 'A']);

    // Itens
    for I := 0 to TInventarioContagemCabVO(ObjetoVO).ListaInventarioContagemDetVO.Count - 1 do
    begin
      Current := TInventarioContagemCabVO(ObjetoVO).ListaInventarioContagemDetVO[I];

      CDSInventarioContagemDetalhe.Append;

      CDSInventarioContagemDetalhe.FieldByName('ID').AsInteger := Current.Id;
      CDSInventarioContagemDetalhe.FieldByName('ID_PRODUTO').AsInteger := Current.IdProduto;
      //CDSInventarioContagemDetalhe.FieldByName('PRODUTONOME.AsString := Current.ProdutoVO.Nome;
      CDSInventarioContagemDetalhe.FieldByName('ID_INVENTARIO_CONTAGEM_CAB').AsInteger := Current.IdInventarioContagemCab;
      CDSInventarioContagemDetalhe.FieldByName('CONTAGEM01').AsFloat := Current.Contagem01;
      CDSInventarioContagemDetalhe.FieldByName('CONTAGEM02').AsFloat := Current.Contagem02;
      CDSInventarioContagemDetalhe.FieldByName('CONTAGEM03').AsFloat := Current.Contagem03;
      CDSInventarioContagemDetalhe.FieldByName('FECHADO_CONTAGEM').AsString := Current.FechadoContagem;  //Informar qual contagem já bateu com a quantidade do sistema
      CDSInventarioContagemDetalhe.FieldByName('QUANTIDADE_SISTEMA').AsFloat := Current.QuantidadeSistema;
      CDSInventarioContagemDetalhe.FieldByName('ACURACIDADE').AsFloat := Current.Acuracidade;
      CDSInventarioContagemDetalhe.FieldByName('DIVERGENCIA').AsFloat := Current.Divergencia;

      CDSInventarioContagemDetalhe.Post;
    end;

    // Serializa o objeto para consultar posteriormente se houve alterações
    FormatSettings.DecimalSeparator := '.';
    StringObjetoOld := ObjetoVO.ToJSONString;
    FormatSettings.DecimalSeparator := ',';
  end;
end;

procedure TFInventarioContagem.CDSInventarioContagemDetalheAfterEdit(DataSet: TDataSet);
begin
  //CDSInventarioContagemDetalhePERSISTE.AsString := 'S';
end;

procedure TFInventarioContagem.CDSInventarioContagemDetalheAfterPost(DataSet: TDataSet);
begin
  if CDSInventarioContagemDetalhe.FieldByName('ID_PRODUTO').AsInteger = 0 then
    CDSInventarioContagemDetalhe.Delete;
end;

procedure TFInventarioContagem.CDSInventarioContagemDetalheBeforePost(DataSet: TDataSet);
begin
  if CDSInventarioContagemDetalhe.FieldByName('CONTAGEM01').AsFloat = CDSInventarioContagemDetalhe.FieldByName('QUANTIDADE_SISTEMA').AsFloat then
    CDSInventarioContagemDetalhe.FieldByName('FECHADO_CONTAGEM').AsString := '01'
  else if CDSInventarioContagemDetalhe.FieldByName('CONTAGEM02').AsFloat = CDSInventarioContagemDetalhe.FieldByName('QUANTIDADE_SISTEMA').AsFloat then
    CDSInventarioContagemDetalhe.FieldByName('FECHADO_CONTAGEM').AsString := '02'
  else if CDSInventarioContagemDetalhe.FieldByName('CONTAGEM03').AsFloat = CDSInventarioContagemDetalhe.FieldByName('QUANTIDADE_SISTEMA').AsFloat then
    CDSInventarioContagemDetalhe.FieldByName('FECHADO_CONTAGEM').AsString := '03';
end;
{$ENDREGION}

{$REGION 'Actions'}
procedure TFInventarioContagem.ActionSelecionarItensExecute(Sender: TObject);
var
  CDSProduto: TZQuery;
  i: integer;
  Filtro: String;
begin
  if (StatusTela = stEditando) or (StatusTela = stInserindo) then
  begin
    //Filtra os produtos por SubGrupo

    /// EXERCICIO: Utilize a janela FLookup para inserir itens

    FLookup.ShowModal;

    Filtro := 'ID_SUBGRUPO = ' + FLookup.IdSelecionado;

    CDSProduto := TProdutoController.Consulta(Filtro, IntToStr(Pagina));
    CDSProduto.Active := True;

    if Assigned(CDSProduto) then
    begin

      CDSProduto.First;
      while not CDSProduto.Eof do
      begin
        CDSInventarioContagemDetalhe.Append;

        CDSInventarioContagemDetalhe.FieldByName('ID_PRODUTO').AsInteger := CDSProduto.FieldByName('ID').AsInteger;
        //CDSInventarioContagemDetalhePRODUTONOME.AsString := CDSProduto.FieldByName('NOME').AsString;
        CDSInventarioContagemDetalhe.FieldByName('ID_INVENTARIO_CONTAGEM_CAB').AsInteger := 0;
        CDSInventarioContagemDetalhe.FieldByName('CONTAGEM01').AsFloat := 0;
        CDSInventarioContagemDetalhe.FieldByName('CONTAGEM02').AsFloat := 0;
        CDSInventarioContagemDetalhe.FieldByName('CONTAGEM03').AsFloat := 0;
        CDSInventarioContagemDetalhe.FieldByName('FECHADO_CONTAGEM').AsString := '00';  //Informar qual contagem já bateu com a quantidade do sistema
        CDSInventarioContagemDetalhe.FieldByName('QUANTIDADE_SISTEMA').AsFloat := CDSProduto.FieldByName('QUANTIDADE_ESTOQUE').AsFloat;
        CDSInventarioContagemDetalhe.FieldByName('ACURACIDADE').AsFloat := 0;
        CDSInventarioContagemDetalhe.FieldByName('DIVERGENCIA').AsFloat := 0;

        CDSInventarioContagemDetalhe.Post;
        CDSProduto.Next;
      end;
    end;
  end;
end;

procedure TFInventarioContagem.ActionRealizarCalculosExecute(Sender: TObject);
begin
  if (StatusTela = stEditando) or (StatusTela = stInserindo) then
  begin
    CDSInventarioContagemDetalhe.DisableControls;
    CDSInventarioContagemDetalhe.First;
    while not CDSInventarioContagemDetalhe.Eof do
    begin
      CDSInventarioContagemDetalhe.Edit;

      /// EXERCICIO
      ///  Verifique qual dos três campos foi selecionado para o fechamento da contagem (FECHADO_CONTAGEM)
      ///  e realize o calculo bom base nesse campo

      //acuracidade dos registros = (registros sistema / registros contados) X 100 }
      if CDSInventarioContagemDetalhe.FieldByName('CONTAGEM01').AsFloat > 0 then
        CDSInventarioContagemDetalhe.FieldByName('ACURACIDADE').AsFloat := CDSInventarioContagemDetalhe.FieldByName('QUANTIDADE_SISTEMA').AsFloat / CDSInventarioContagemDetalhe.FieldByName('CONTAGEM01').AsFloat * 100
      else
        CDSInventarioContagemDetalhe.FieldByName('ACURACIDADE').AsFloat := 0;

      //divergencia dos registros = ((registros contados - registros sistema) / registros sistema) X 100 }
      if CDSInventarioContagemDetalhe.FieldByName('QUANTIDADE_SISTEMA').AsFloat <> 0 then
        CDSInventarioContagemDetalhe.FieldByName('DIVERGENCIA').AsFloat := (CDSInventarioContagemDetalhe.FieldByName('CONTAGEM01').AsFloat - CDSInventarioContagemDetalhe.FieldByName('QUANTIDADE_SISTEMA').AsFloat) / CDSInventarioContagemDetalhe.FieldByName('QUANTIDADE_SISTEMA').AsFloat * 100
      else
        CDSInventarioContagemDetalhe.FieldByName('DIVERGENCIA').AsFloat := 0;

      CDSInventarioContagemDetalhe.Post;
      CDSInventarioContagemDetalhe.Next;
    end;
    CDSInventarioContagemDetalhe.First;
    CDSInventarioContagemDetalhe.EnableControls;
  end;
end;
{$ENDREGION}

end.

