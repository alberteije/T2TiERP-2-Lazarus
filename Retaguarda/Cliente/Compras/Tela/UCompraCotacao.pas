{ *******************************************************************************
Title: T2Ti ERP
Description: Janela para realizar a Cotação de Compra

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
t2ti.com@gmail.com</p>

@author Albert Eije
@version 2.0
******************************************************************************* }
unit UCompraCotacao;

{$MODE Delphi}

interface

uses
  BrookHTTPClient, BrookFCLHTTPClientBroker, BrookHTTPUtils, BrookUtils, FPJson, ZDataset,
  LCLIntf, LCLType, LMessages, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UTelaCadastro, Menus, StdCtrls, ExtCtrls, Buttons, Grids, DBGrids,
  ComCtrls, LabeledCtrls, rxdbgrid, rxtoolbar, DBCtrls, StrUtils,
  Math, Constantes, CheckLst, ActnList, ToolWin, Spin, db, BufDataset, Biblioteca,
  ULookup, VO;

type

  { TFCompraCotacao }

  TFCompraCotacao = class(TFTelaCadastro)
    BevelEdits: TBevel;
    CDSCompraRequisicaoDetalhe: TBufDataset;
    CDSCompraFornecedorCotacao: TBufDataset;
    CDSCompraCotacaoDetalhe: TBufDataset;
    EditDescricao: TLabeledEdit;
    EditDataCotacao: TLabeledDateEdit;
    GroupBoxItensCotacao: TGroupBox;
    GridCompraCotacaoDetalhe: TRxDbGrid;
    GroupBoxFornecedores: TGroupBox;
    GridCompraFornecedorCotacao: TRxDbGrid;
    DSCompraFornecedorCotacao: TDataSource;
    DSCompraCotacaoDetalhe: TDataSource;
    DSCompraRequisicaoDetalhe: TDataSource;
    GroupBoxCompraRequisicaoDetalhe: TGroupBox;
    GridCompraRequisicaoDetalhe: TRxDbGrid;
    PanelActions: TPanel;
    SpinEditQuantidade: TSpinEdit;
    ActionManager1: TActionList;
    ActionToolBar1: TToolPanel;
    ActionInserirCotacao: TAction;
    ActionToolBar2: TToolPanel;
    ActionRetirarCotacao: TAction;
    procedure FormCreate(Sender: TObject);
    procedure GridCompraFornecedorCotacaoKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure CDSCompraRequisicaoDetalheAfterScroll(DataSet: TDataSet);
    procedure ActionInserirCotacaoExecute(Sender: TObject);
    procedure ConfigurarSpinQuantidade;
    procedure ActionRetirarCotacaoExecute(Sender: TObject);
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
  FCompraCotacao: TFCompraCotacao;

implementation

uses CompraFornecedorCotacaoVO, CompraCotacaoDetalheVO, ProdutoVO, ProdutoController,
  ViewPessoaFornecedorVO, ViewPessoaFornecedorController, CompraRequisicaoDetalheVO,
  CompraRequisicaoDetalheController, UDataModule, CompraReqCotacaoDetalheVO,
  CompraFornecedorCotacaoController, CompraCotacaoDetalheController,
  ViewCompraReqItemCotadoController, CompraCotacaoController, CompraCotacaoVO,
  ViewCompraReqItemCotadoVO;
{$R *.lfm}

{$REGION 'Infra'}
procedure TFCompraCotacao.BotaoConsultarClick(Sender: TObject);
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
    RetornoConsulta := TCompraCotacaoController.Consulta(Filtro, IntToStr(Pagina));
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

procedure TFCompraCotacao.BotaoSalvarClick(Sender: TObject);
begin
  inherited;
  BotaoConsultarClick(Sender);
end;

procedure TFCompraCotacao.FormCreate(Sender: TObject);
begin
  ClasseObjetoGridVO := TCompraCotacaoVO;
  ObjetoController := TCompraCotacaoController.Create;
  inherited;

  ConfiguraCDSFromVO(CDSCompraRequisicaoDetalhe, TViewCompraReqItemCotadoVO);
  ConfiguraGridFromVO(GridCompraRequisicaoDetalhe, TViewCompraReqItemCotadoVO);

  ConfiguraCDSFromVO(CDSCompraCotacaoDetalhe, TCompraCotacaoDetalheVO);
  ConfiguraGridFromVO(GridCompraCotacaoDetalhe, TCompraCotacaoDetalheVO);

  ConfiguraCDSFromVO(CDSCompraFornecedorCotacao, TCompraFornecedorCotacaoVO);
  ConfiguraGridFromVO(GridCompraFornecedorCotacao, TCompraFornecedorCotacaoVO);
end;

procedure TFCompraCotacao.LimparCampos;
begin
  inherited;
  CDSCompraFornecedorCotacao.Close;
  CDSCompraCotacaoDetalhe.Close;
  CDSCompraRequisicaoDetalhe.Close;
  CDSCompraFornecedorCotacao.Open;
  CDSCompraCotacaoDetalhe.Open;
  CDSCompraRequisicaoDetalhe.Open;
end;

procedure TFCompraCotacao.ConfigurarLayoutTela;
begin
  PanelEdits.Enabled := True;
  if (StatusTela = stNavegandoEdits) or (StatusTela = stEditando) then
  begin
    PanelActions.Enabled := False;
  end
  else
  begin
    PanelActions.Enabled := True;
  end;
end;
{$ENDREGION}

{$REGION 'Controles CRUD'}
function TFCompraCotacao.DoInserir: Boolean;
var
  Filtro: string;
  RetornoConsulta: TZQuery;
  ListaCampos: TStringList;
  I: Integer;
begin
  Result := inherited DoInserir;

  ConfigurarLayoutTela;
  if Result then
  begin
    EditDataCotacao.SetFocus;
    EditDataCotacao.Date := Now;

    Filtro := 'ITEM_COTADO=' + QuotedStr('N') + ' or ITEM_COTADO IS NULL';
    ListaCampos  := TStringList.Create;
    RetornoConsulta := TCompraRequisicaoDetalheController.Consulta(Filtro, '0');
    RetornoConsulta.Active := True;

    RetornoConsulta.GetFieldNames(ListaCampos);

    RetornoConsulta.First;
    while not RetornoConsulta.EOF do begin
      CDSCompraRequisicaoDetalhe.Append;
      for i := 0 to ListaCampos.Count - 1 do
      begin
        CDSCompraRequisicaoDetalhe.FieldByName(ListaCampos[i]).Value := RetornoConsulta.FieldByName(ListaCampos[i]).Value;
      end;
      CDSCompraRequisicaoDetalhe.Post;
      RetornoConsulta.Next;
    end;
    BotaoConsultar.Click;
  end;
end;

function TFCompraCotacao.DoEditar: Boolean;
begin
  Result := inherited DoEditar;

  ConfigurarLayoutTela;

  if Result then
  begin
    EditDataCotacao.SetFocus;
  end;
end;

function TFCompraCotacao.DoExcluir: Boolean;
begin
  if inherited DoExcluir then
  begin
    try
      Result := TCompraCotacaoController.Exclui(IdRegistroSelecionado);
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

function TFCompraCotacao.DoSalvar: Boolean;
var
  CompraFornecedorCotacao: TCompraFornecedorCotacaoVO;
  CompraCotacaoDetalhe: TCompraCotacaoDetalheVO;
  CompraReqCotacaoDetalhe: TCompraReqCotacaoDetalheVO;
begin
  if Application.MessageBox('Confirma a operação? Os fornecedores e os items não poderão ser alterados depois.', 'Pergunta do sistema', MB_YesNo + MB_IconQuestion) = IdYes then
  begin

    if Trim(EditDescricao.Text) = '' then
    begin
      Application.MessageBox('Informe a descrição da cotação.', 'Mensagem do Sistema', MB_OK + MB_ICONINFORMATION);
      EditDescricao.SetFocus;
      Exit(False);
    end;
    if CDSCompraFornecedorCotacao.RecordCount = 0 then
    begin
      Application.MessageBox('É necessário informar pelo menos um fornecedor para a cotação.', 'Mensagem do Sistema', MB_OK + MB_ICONINFORMATION);
      GridCompraFornecedorCotacao.SetFocus;
      GridCompraFornecedorCotacao.SelectedIndex := 0;
      Exit(False);
    end;

    Result := inherited DoSalvar;

    if Result then
    begin
      try
        if not Assigned(ObjetoVO) then
          ObjetoVO := TCompraCotacaoVO.Create;

        TCompraCotacaoVO(ObjetoVO).DataCotacao := EditDataCotacao.Date;
        TCompraCotacaoVO(ObjetoVO).Descricao := EditDescricao.Text;
        TCompraCotacaoVO(ObjetoVO).Situacao := 'A';

        //As listas só são levadas em conta no momento da inserção. Não é possível alterar os dados da cotação

        ///EXERCICIO: implemente a capacidade de alterar os dados da cotação

        if StatusTela = stInserindo then
        begin
          // Carrega os itens cotados na lista vinculada à cotação
          CDSCompraRequisicaoDetalhe.DisableControls;
          CDSCompraRequisicaoDetalhe.First;
          while not CDSCompraRequisicaoDetalhe.Eof do
          begin
            if CDSCompraRequisicaoDetalhe.FieldByName('ITEM_COTADO').AsString = 'S' then
            begin
              CompraReqCotacaoDetalhe := TCompraReqCotacaoDetalheVO.Create;
              CompraReqCotacaoDetalhe.IdCompraRequisicaoDetalhe := CDSCompraRequisicaoDetalhe.FieldByName('ID').AsInteger;
              CompraReqCotacaoDetalhe.QuantidadeCotada := CDSCompraRequisicaoDetalhe.FieldByName('QUANTIDADE_COTADA').AsInteger;
              TCompraCotacaoVO(ObjetoVO).ListaCompraReqCotacaoDetalheVO.Add(CompraReqCotacaoDetalhe);
            end;
            CDSCompraRequisicaoDetalhe.Next;
          end;
          CDSCompraRequisicaoDetalhe.First;
          CDSCompraRequisicaoDetalhe.EnableControls;

          // Carrega os fornecedores numa lista
          CDSCompraFornecedorCotacao.DisableControls;
          CDSCompraFornecedorCotacao.First;
          while not CDSCompraFornecedorCotacao.Eof do
          begin
              CompraFornecedorCotacao := TCompraFornecedorCotacaoVO.Create;
              CompraFornecedorCotacao.Id := CDSCompraFornecedorCotacao.FieldByName('ID').AsInteger;
              CompraFornecedorCotacao.IdFornecedor := CDSCompraFornecedorCotacao.FieldByName('ID_FORNECEDOR').AsInteger;
              CompraFornecedorCotacao.IdCompraCotacao := TCompraCotacaoVO(ObjetoVO).Id;

              // Lista dos produtos por fornecedor
              CDSCompraCotacaoDetalhe.DisableControls;
              CDSCompraCotacaoDetalhe.First;
              while not CDSCompraCotacaoDetalhe.Eof do
              begin
                  CompraCotacaoDetalhe := TCompraCotacaoDetalheVO.Create;
                  CompraCotacaoDetalhe.Id := CDSCompraCotacaoDetalhe.FieldByName('ID').AsInteger;
                  CompraCotacaoDetalhe.IdCompraFornecedorCotacao := CompraFornecedorCotacao.Id;
                  CompraCotacaoDetalhe.IdProduto := CDSCompraCotacaoDetalhe.FieldByName('ID_PRODUTO').AsInteger;
                  CompraCotacaoDetalhe.Quantidade := CDSCompraCotacaoDetalhe.FieldByName('QUANTIDADE').AsInteger;

                  CompraFornecedorCotacao.ListaCompraCotacaoDetalhe.Add(CompraCotacaoDetalhe);
                CDSCompraCotacaoDetalhe.Next;
              end;
              CDSCompraCotacaoDetalhe.First;
              CDSCompraCotacaoDetalhe.EnableControls;

              TCompraCotacaoVO(ObjetoVO).ListaCompraFornecedorCotacao.Add(CompraFornecedorCotacao);

            CDSCompraFornecedorCotacao.Next;
          end;
          CDSCompraFornecedorCotacao.First;
          CDSCompraFornecedorCotacao.EnableControls;

        TCompraCotacaoController.Insere(TCompraCotacaoVO(ObjetoVO));
        end
        else if StatusTela = stEditando then
      begin
        /// EXERCICIO: Verifique se tem como serializar as listas junto com o objeto para realizar a comparação
        //if TCompraCotacaoVO(ObjetoVO).ToJSONString <> StringObjetoOld then
        //begin
          TCompraCotacaoController.Altera(TCompraCotacaoVO(ObjetoVO));
        //end
        //else
        //Application.MessageBox('Nenhum dado foi alterado.', 'Mensagem do Sistema', MB_OK + MB_ICONINFORMATION);
        end;
      except
        Result := False;
      end;
    end;

  end
  else
    Exit(False);
end;
{$ENDREGION}

{$REGION 'Controle de Grid'}
procedure TFCompraCotacao.GridCompraFornecedorCotacaoKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  Filtro: String;
begin
  /// EXERCICIO: Implemente a busca usando o FLookup
  if StatusTela = stInserindo then
  begin
    if Key = VK_F1 then
    begin
      CDSCompraFornecedorCotacao.Append;
      CDSCompraFornecedorCotacao.FieldByName('ID_FORNECEDOR').AsInteger := 1;//CDSTransiente.FieldByName('ID').AsInteger;
//      CDSCompraFornecedorCotacao.FieldByName('FornecedorNome').AsString := CDSTransiente.FieldByName('NOME').AsString;
      CDSCompraFornecedorCotacao.Post;
    end;
  end;
end;

procedure TFCompraCotacao.GridParaEdits;
var
  IdCabecalho: String;
  Filtro: String;
  RetornoConsulta: TZQuery;
  ListaCampos: TStringList;
  I: Integer;
begin
  inherited;
  if not CDSGrid.IsEmpty then
  begin
    IdCabecalho := IntToStr(IdRegistroSelecionado);
    ObjetoVO := TCompraCotacaoController.ConsultaObjeto('ID=' + IdCabecalho);
  end;

  if Assigned(ObjetoVO) then
  begin
    EditDataCotacao.Date := TCompraCotacaoVO(ObjetoVO).DataCotacao;
    EditDescricao.Text := TCompraCotacaoVO(ObjetoVO).Descricao;

    // Fornecedores da Cotação
    Filtro := 'ID_COMPRA_COTACAO=' + QuotedStr(IntToStr(TCompraCotacaoVO(ObjetoVO).Id));
    ListaCampos  := TStringList.Create;
    RetornoConsulta := TCompraFornecedorCotacaoController.Consulta(Filtro, '0');
    RetornoConsulta.Active := True;

    RetornoConsulta.GetFieldNames(ListaCampos);

    RetornoConsulta.First;
    while not RetornoConsulta.EOF do begin
      CDSCompraFornecedorCotacao.Append;
      for i := 0 to ListaCampos.Count - 1 do
      begin
        CDSCompraFornecedorCotacao.FieldByName(ListaCampos[i]).Value := RetornoConsulta.FieldByName(ListaCampos[i]).Value;
      end;
      CDSCompraFornecedorCotacao.Post;
      RetornoConsulta.Next;
    end;

    // Itens da Cotação
    Filtro := 'ID_COMPRA_FORNECEDOR_COTACAO=' + QuotedStr(CDSCompraFornecedorCotacao.FieldByName('ID').AsString);
    ListaCampos  := TStringList.Create;
    RetornoConsulta := TCompraCotacaoDetalheController.Consulta(Filtro, '0');
    RetornoConsulta.Active := True;

    RetornoConsulta.GetFieldNames(ListaCampos);

    RetornoConsulta.First;
    while not RetornoConsulta.EOF do begin
      CDSCompraCotacaoDetalhe.Append;
      for i := 0 to ListaCampos.Count - 1 do
      begin
        CDSCompraCotacaoDetalhe.FieldByName(ListaCampos[i]).Value := RetornoConsulta.FieldByName(ListaCampos[i]).Value;
      end;
      CDSCompraCotacaoDetalhe.Post;
      RetornoConsulta.Next;
    end;

    // Carrega itens que foram cotados a partir da view
    Filtro := 'ID_COTACAO=' + QuotedStr(IntToStr(TCompraCotacaoVO(ObjetoVO).Id));
    ListaCampos  := TStringList.Create;
    RetornoConsulta := TViewCompraReqItemCotadoController.Consulta(Filtro, '0');
    RetornoConsulta.Active := True;

    RetornoConsulta.GetFieldNames(ListaCampos);

    RetornoConsulta.First;
    while not RetornoConsulta.EOF do begin
      CDSCompraRequisicaoDetalhe.Append;
      for i := 0 to ListaCampos.Count - 1 do
      begin
        CDSCompraRequisicaoDetalhe.FieldByName(ListaCampos[i]).Value := RetornoConsulta.FieldByName(ListaCampos[i]).Value;
      end;
      CDSCompraRequisicaoDetalhe.Post;
      RetornoConsulta.Next;
    end;
  end;
end;

procedure TFCompraCotacao.CDSCompraRequisicaoDetalheAfterScroll(DataSet: TDataSet);
begin
  ConfigurarSpinQuantidade;
end;

procedure TFCompraCotacao.ConfigurarSpinQuantidade;
begin
  SpinEditQuantidade.MaxValue := CDSCompraRequisicaoDetalhe.FieldByName('QUANTIDADE').AsFloat - CDSCompraRequisicaoDetalhe.FieldByName('QUANTIDADE_COTADA').AsFloat;
  if CDSCompraRequisicaoDetalhe.FieldByName('QUANTIDADE').AsFloat - CDSCompraRequisicaoDetalhe.FieldByName('QUANTIDADE_COTADA').AsFloat = 0 then
  begin
    SpinEditQuantidade.Value := 0;
    SpinEditQuantidade.Enabled := False;
  end
  else
  begin
    SpinEditQuantidade.Enabled := True;
    SpinEditQuantidade.Value := CDSCompraRequisicaoDetalhe.FieldByName('QUANTIDADE').AsFloat - CDSCompraRequisicaoDetalhe.FieldByName('QUANTIDADE_COTADA').AsFloat;
  end;
end;

procedure TFCompraCotacao.GridDblClick(Sender: TObject);
begin
  inherited;
  ConfigurarLayoutTela;
end;
{$ENDREGION}

{$REGION 'Actions'}
procedure TFCompraCotacao.ActionInserirCotacaoExecute(Sender: TObject);
begin
  if StatusTela = stInserindo then
  begin
    if not CDSCompraRequisicaoDetalhe.IsEmpty then
    begin
      if SpinEditQuantidade.Value = 0 then
      begin
        Application.MessageBox('Valor da quantidade deve ser maior que zero.', 'Mensagem do Sistema', MB_OK + MB_ICONINFORMATION);
      end
      else
      begin
        if CDSCompraRequisicaoDetalhe.FieldByName('ITEM_COTADO').AsString = 'S' then
        begin
          Application.MessageBox('Esse item já foi cotado nesta cotação.', 'Mensagem do Sistema', MB_OK + MB_ICONINFORMATION);
        end
        else
        begin
          CDSCompraCotacaoDetalhe.Append;
          CDSCompraCotacaoDetalhe.FieldByName('ID_PRODUTO').AsInteger := CDSCompraRequisicaoDetalhe.FieldByName('ID_PRODUTO').AsInteger;
//          CDSCompraCotacaoDetalhe.FieldByName('PRODUTONOME').AsString := CDSCompraRequisicaoDetalhe.FieldByName('PRODUTONOME').AsString;
          CDSCompraCotacaoDetalhe.FieldByName('QUANTIDADE').AsFloat := SpinEditQuantidade.Value;
          CDSCompraCotacaoDetalhe.Post;
          //
          CDSCompraRequisicaoDetalhe.Edit;
          CDSCompraRequisicaoDetalhe.FieldByName('QUANTIDADE_COTADA').AsFloat := CDSCompraRequisicaoDetalhe.FieldByName('QUANTIDADE_COTADA').AsFloat + SpinEditQuantidade.Value;
          CDSCompraRequisicaoDetalhe.FieldByName('ITEM_COTADO').AsString := 'S';
          CDSCompraRequisicaoDetalhe.Post;
          //
          ConfigurarSpinQuantidade;
        end;
      end;
    end;
  end
  else
    Application.MessageBox('Não é possível alterar os dados da cotação.', 'Mensagem do Sistema', MB_OK + MB_ICONINFORMATION);
end;

procedure TFCompraCotacao.ActionRetirarCotacaoExecute(Sender: TObject);
begin
  if StatusTela = stInserindo then
  begin
    if not CDSCompraCotacaoDetalhe.IsEmpty then
    begin
      CDSCompraRequisicaoDetalhe.DisableControls;
      CDSCompraRequisicaoDetalhe.First;
      while not CDSCompraRequisicaoDetalhe.Eof do
      begin
        if CDSCompraRequisicaoDetalhe.FieldByName('ID_PRODUTO').AsInteger = CDSCompraCotacaoDetalhe.FieldByName('ID_PRODUTO').AsInteger then
        begin
          CDSCompraRequisicaoDetalhe.Edit;
          CDSCompraRequisicaoDetalhe.FieldByName('QUANTIDADE_COTADA').AsFloat := CDSCompraRequisicaoDetalhe.FieldByName('QUANTIDADE_COTADA').AsFloat - CDSCompraCotacaoDetalhe.FieldByName('QUANTIDADE').AsFloat;
          CDSCompraRequisicaoDetalhe.FieldByName('ITEM_COTADO').AsString := 'N';
          CDSCompraRequisicaoDetalhe.Post;
          Break;
        end;
        CDSCompraRequisicaoDetalhe.Next;
      end;
      CDSCompraCotacaoDetalhe.Delete;
      CDSCompraRequisicaoDetalhe.First;
      CDSCompraRequisicaoDetalhe.EnableControls;
    end;
  end
  else
    Application.MessageBox('Não é possível alterar os dados da cotação.', 'Mensagem do Sistema', MB_OK + MB_ICONINFORMATION);
end;
{$ENDREGION}

end.

