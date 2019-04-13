{ *******************************************************************************
Title: T2Ti ERP
Description: Janela de Requisições Internas de Material

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
unit URequisicaoInterna;

interface

uses
  BrookHTTPClient, BrookFCLHTTPClientBroker, BrookHTTPUtils, BrookUtils, FPJson, ZDataset,
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UTelaCadastro, Menus, StdCtrls, ExtCtrls, Buttons, Grids, DBGrids,
  ComCtrls, LabeledCtrls, rxdbgrid, rxtoolbar, DBCtrls, StrUtils,
  Math, Constantes, CheckLst, ActnList, ToolWin, ShellApi, db, BufDataset, Biblioteca,
  ULookup, VO;

  type

  { TFRequisicaoInterna }

  TFRequisicaoInterna = class(TFTelaCadastro)
    BevelEdits: TBevel;
    CDSRequisicaoInternaDetalhe: TBufDataSet;
    DSRequisicaoInternaDetalhe: TDataSource;
    GroupBoxParcelas: TGroupBox;
    GridItens: TRxDbGrid;
    EditIdColaborador: TLabeledCalcEdit;
    EditColaborador: TLabeledEdit;
    EditDataRequisicao: TLabeledDateEdit;
    ActionToolBar1: TToolPanel;
    ActionManager1: TActionList;
    ActionAdicionarItem: TAction;
    ActionDeferirSolicitacao: TAction;
    ActionIndeferirSolicitacao: TAction;
    PopupMenu1: TPopupMenu;
    ExcluirItem1: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure GridItensKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure ActionAdicionarItemExecute(Sender: TObject);
    procedure ExcluirItem1Click(Sender: TObject);
    procedure ActionDeferirSolicitacaoExecute(Sender: TObject);
    procedure ActionIndeferirSolicitacaoExecute(Sender: TObject);
    procedure EditIdColaboradorKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
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
  FRequisicaoInterna: TFRequisicaoInterna;
  CriterioRapido: String;

implementation

uses RequisicaoInternaCabecalhoController, RequisicaoInternaCabecalhoVO,
  RequisicaoInternaDetalheVO, UDataModule, ViewPessoaColaboradorVO,
  ViewPessoaColaboradorController, ProdutoVO, ProdutoController,
  RequisicaoInternaDetalheController;
{$R *.lfm}

{$REGION 'Infra'}
procedure TFRequisicaoInterna.BotaoConsultarClick(Sender: TObject);
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
    RetornoConsulta := TRequisicaoInternaCabecalhoController.Consulta(Filtro, IntToStr(Pagina));
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

procedure TFRequisicaoInterna.BotaoSalvarClick(Sender: TObject);
begin
  inherited;
  BotaoConsultarClick(Sender);
end;

procedure TFRequisicaoInterna.FormCreate(Sender: TObject);
begin
  ClasseObjetoGridVO := TRequisicaoInternaCabecalhoVO;
  ObjetoController := TRequisicaoInternaCabecalhoController.Create;

  inherited;
  BotaoImprimir.Visible := False;
  menuImprimir.Visible := False;

  {
  ConfiguraCDSFromVO(CDSRequisicaoInternaDetalhe, TRequisicaoInternaDetalheVO);
  ConfiguraGridFromVO(GridItens, TRequisicaoInternaDetalheVO);

  OBS: vamos configurar manualmente abaixo para trabalhar com os campos transientes
  Pense numa maneira de fazer isso automaticamente nos métodos acima
  }

  //configura Dataset
  CDSRequisicaoInternaDetalhe.Close;
  CDSRequisicaoInternaDetalhe.FieldDefs.Clear;

  CDSRequisicaoInternaDetalhe.FieldDefs.add('ID', ftInteger);
  CDSRequisicaoInternaDetalhe.FieldDefs.add('ID_REQ_INTERNA_CABECALHO', ftInteger);
  CDSRequisicaoInternaDetalhe.FieldDefs.add('ID_PRODUTO', ftInteger);
  CDSRequisicaoInternaDetalhe.FieldDefs.add('PRODUTO.NOME', ftString, 100);
  CDSRequisicaoInternaDetalhe.FieldDefs.add('QUANTIDADE', ftFloat);
  CDSRequisicaoInternaDetalhe.FieldDefs.add('QUANTIDADE_ESTOQUE', ftFloat);
  CDSRequisicaoInternaDetalhe.CreateDataset;
  CDSRequisicaoInternaDetalhe.Open;
end;

procedure TFRequisicaoInterna.LimparCampos;
begin
  CriterioRapido := EditCriterioRapido.Text;
  inherited;
  CDSRequisicaoInternaDetalhe.Close;
  CDSRequisicaoInternaDetalhe.Open;
end;
{$ENDREGION}

{$REGION 'Controles CRUD'}
function TFRequisicaoInterna.DoInserir: Boolean;
begin
  Result := inherited DoInserir;

  if Result then
  begin
    EditIdColaborador.SetFocus;
  end;
end;

function TFRequisicaoInterna.DoEditar: Boolean;
var
  Mensagem: String;
begin
  if CDSGrid.FieldByName('SITUACAO').AsString <> 'A' then
  begin
    case AnsiIndexStr(CDSGrid.FieldByName('SITUACAO').AsString, ['D', 'I']) of
      0:
        Mensagem := ' - Situação: Deferida';
      1:
        Mensagem := ' - Situação: Indeferida';
    end;

    Application.MessageBox(PChar('Esse registro não pode ser alterado' + Mensagem), 'Mensagem do Sistema', MB_OK + MB_ICONINFORMATION);
    Exit(False);
  end;

  Result := inherited DoEditar;

  if Result then
  begin
    EditIdColaborador.SetFocus;
  end;
end;

function TFRequisicaoInterna.DoExcluir: Boolean;
begin
  if CDSGrid.FieldByName('SITUACAO').AsString <> 'A' then
  begin
    Application.MessageBox(PChar('Esse registro não pode ser excluído'), 'Mensagem do Sistema', MB_OK + MB_ICONINFORMATION);
    Exit(False);
  end;

  if inherited DoExcluir then
  begin
    try
      Result := TRequisicaoInternaCabecalhoController.Exclui(IdRegistroSelecionado);
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

function TFRequisicaoInterna.DoSalvar: Boolean;
var
  RequisicaoInternaDetalhe: TRequisicaoInternaDetalheVO;
begin
  Result := inherited DoSalvar;

  if Result then
  begin
    try
      if not Assigned(ObjetoVO) then
        ObjetoVO := TRequisicaoInternaCabecalhoVO.Create;

      TRequisicaoInternaCabecalhoVO(ObjetoVO).IdColaborador := EditIdColaborador.AsInteger;
      TRequisicaoInternaCabecalhoVO(ObjetoVO).DataRequisicao := EditDataRequisicao.Date;
      TRequisicaoInternaCabecalhoVO(ObjetoVO).Situacao := 'A';

      if StatusTela = stEditando then
        TRequisicaoInternaCabecalhoVO(ObjetoVO).Id := IdRegistroSelecionado;

      // Itens
      CDSRequisicaoInternaDetalhe.DisableControls;
      CDSRequisicaoInternaDetalhe.First;
      while not CDSRequisicaoInternaDetalhe.Eof do
      begin
          RequisicaoInternaDetalhe := TRequisicaoInternaDetalheVO.Create;
          RequisicaoInternaDetalhe.Id := CDSRequisicaoInternaDetalhe.FieldByName('ID').AsInteger;
          RequisicaoInternaDetalhe.IdReqInternaCabecalho := TRequisicaoInternaCabecalhoVO(ObjetoVO).Id;
          RequisicaoInternaDetalhe.IdProduto := CDSRequisicaoInternaDetalhe.FieldByName('ID_PRODUTO').AsInteger;
          RequisicaoInternaDetalhe.Quantidade := CDSRequisicaoInternaDetalhe.FieldByName('QUANTIDADE').AsFloat;

          TRequisicaoInternaCabecalhoVO(ObjetoVO).ListaRequisicaoInterna.Add(RequisicaoInternaDetalhe);

        CDSRequisicaoInternaDetalhe.Next;
      end;
      CDSRequisicaoInternaDetalhe.EnableControls;

      if StatusTela = stInserindo then
      begin
        TRequisicaoInternaCabecalhoController.Insere(TRequisicaoInternaCabecalhoVO(ObjetoVO));
      end
      else if StatusTela = stEditando then
      begin
        /// EXERCICIO: Verifique se tem como serializar as listas junto com o objeto para realizar a comparação
        //if TRequisicaoInternaCabecalhoVO(ObjetoVO).ToJSONString <> StringObjetoOld then
        //begin
          TRequisicaoInternaCabecalhoController.Altera(TRequisicaoInternaCabecalhoVO(ObjetoVO));
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
procedure TFRequisicaoInterna.GridItensKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = VK_F1 then
  begin
    ActionAdicionarItem.Execute;
  end;
  If Key = VK_RETURN then
    EditIdColaborador.SetFocus;
end;

procedure TFRequisicaoInterna.GridParaEdits;
var
  IdCabecalho: String;
  I: Integer;
  Current: TRequisicaoInternaDetalheVO;
begin
  inherited;

  if not CDSGrid.IsEmpty then
  begin
    IdCabecalho := IntToStr(IdRegistroSelecionado);
    ObjetoVO := TRequisicaoInternaCabecalhoController.ConsultaObjeto('ID=' + IdCabecalho);
  end;

  if Assigned(ObjetoVO) then
  begin
    EditIdColaborador.AsInteger := TRequisicaoInternaCabecalhoVO(ObjetoVO).IdColaborador;
    EditColaborador.Text := TRequisicaoInternaCabecalhoVO(ObjetoVO).ColaboradorPessoaNome;
    EditDataRequisicao.Date := TRequisicaoInternaCabecalhoVO(ObjetoVO).DataRequisicao;

    // Itens
    for I := 0 to TRequisicaoInternaCabecalhoVO(ObjetoVO).ListaRequisicaoInterna.Count - 1 do
    begin
      Current := TRequisicaoInternaCabecalhoVO(ObjetoVO).ListaRequisicaoInterna[I];
      CDSRequisicaoInternaDetalhe.Append;

      CDSRequisicaoInternaDetalhe.FieldByName('ID').AsInteger := Current.Id;
      CDSRequisicaoInternaDetalhe.FieldByName('ID_PRODUTO').AsInteger := Current.IdProduto;
      CDSRequisicaoInternaDetalhe.FieldByName('ID_REQ_INTERNA_CABECALHO').AsInteger := Current.IdReqInternaCabecalho;
      CDSRequisicaoInternaDetalhe.FieldByName('QUANTIDADE').AsFloat := Current.Quantidade;
      //CDSRequisicaoInternaDetalhe.FieldByName('QUANTIDADE_ESTOQUE').AsFloat := Current.ProdutoVO.QuantidadeEstoque;
      //CDSRequisicaoInternaDetalhe.FieldByName('PRODUTONOME').AsString := Current.ProdutoVO.Nome;

      CDSRequisicaoInternaDetalhe.Post;
    end;

    // Serializa o objeto para consultar posteriormente se houve alterações
    FormatSettings.DecimalSeparator := '.';
    StringObjetoOld := ObjetoVO.ToJSONString;
    FormatSettings.DecimalSeparator := ',';
  end;
end;

procedure TFRequisicaoInterna.ExcluirItem1Click(Sender: TObject);
begin
  if CDSRequisicaoInternaDetalhe.IsEmpty then
    Application.MessageBox('Não existe registro selecionado.', 'Erro', MB_OK + MB_ICONERROR)
  else
  begin
    if Application.MessageBox('Deseja realmente excluir o registro selecionado?', 'Pergunta do sistema', MB_YESNO + MB_ICONQUESTION) = IDYES then
    begin
      if StatusTela = stInserindo then
        CDSRequisicaoInternaDetalhe.Delete
      else if StatusTela = stEditando then
      begin
        if TRequisicaoInternaDetalheController.Exclui(IdRegistroSelecionado) then
          CDSRequisicaoInternaDetalhe.Delete;
      end;
    end;
  end;
end;
{$ENDREGION}

{$REGION 'Campos Transientes'}
/// EXERCICIO: Implemente a busca usando a janela FLookup
procedure TFRequisicaoInterna.EditIdColaboradorKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  ViewPessoaColaboradorVO :TViewPessoaColaboradorVO ;
begin
  if Key = VK_F1 then
  begin
    if EditIdColaborador.Value <> 0 then
      Filtro := 'ID = ' + EditIdColaborador.Text
    else
      Filtro := 'ID=0';

    try
      EditColaborador.Clear;

        ViewPessoaColaboradorVO := TViewPessoaColaboradorController.ConsultaObjeto(Filtro);
        if Assigned(ViewPessoaColaboradorVO) then
      begin
        EditColaborador.Text := ViewPessoaColaboradorVO.Nome;
      end
      else
      begin
        Exit;
      end;
    finally
      EditDataRequisicao.SetFocus;
    end;
  end;
end;
{$ENDREGION}

{$REGION 'Actions'}
procedure TFRequisicaoInterna.ActionAdicionarItemExecute(Sender: TObject);
var
  ProdutoLocal: TProdutoVO;
begin
  /// EXERCICIO: Utilize a janela FLookup para inserir itens
  try
    FLookup.ShowModal;

    ProdutoLocal := TProdutoController.ConsultaObjeto('ID='+FLookup.IdSelecionado);

    if Assigned(ProdutoLocal) then
    begin
      CDSRequisicaoInternaDetalhe.Append;
      CDSRequisicaoInternaDetalhe.FieldByName('ID_PRODUTO').AsInteger := ProdutoLocal.Id;//CDSTransiente.FieldByName('ID').AsInteger;
      CDSRequisicaoInternaDetalhe.FieldByName('PRODUTO.NOME').AsString := ProdutoLocal.Nome;//CDSTransiente.FieldByName('NOME').AsString;
      CDSRequisicaoInternaDetalhe.FieldByName('QUANTIDADE_ESTOQUE').AsFloat := ProdutoLocal.QuantidadeEstoque;// CDSTransiente.FieldByName('QUANTIDADE_ESTOQUE').AsFloat;
    end;
  finally
  end;
end;

procedure TFRequisicaoInterna.ActionDeferirSolicitacaoExecute(Sender: TObject);
var
  RequisicaoInternaDetalhe: TRequisicaoInternaDetalheVO;
begin
  if StatusTela = stInserindo then
    Application.MessageBox('A requisição ainda não foi salva.', 'Mensagem do Sistema', MB_OK + MB_ICONINFORMATION)
  else if StatusTela = stEditando then
  begin
    TRequisicaoInternaCabecalhoVO(ObjetoVO).Situacao := 'D';

    // Itens
    CDSRequisicaoInternaDetalhe.DisableControls;
    CDSRequisicaoInternaDetalhe.First;
    while not CDSRequisicaoInternaDetalhe.Eof do
    begin
      RequisicaoInternaDetalhe := TRequisicaoInternaDetalheVO.Create;
      RequisicaoInternaDetalhe.Id := CDSRequisicaoInternaDetalhe.FieldByName('ID').AsInteger;
      RequisicaoInternaDetalhe.IdReqInternaCabecalho := TRequisicaoInternaCabecalhoVO(ObjetoVO).Id;
      RequisicaoInternaDetalhe.IdProduto := CDSRequisicaoInternaDetalhe.FieldByName('ID_PRODUTO').AsInteger;
      RequisicaoInternaDetalhe.Quantidade := CDSRequisicaoInternaDetalhe.FieldByName('QUANTIDADE').AsFloat;
      TRequisicaoInternaCabecalhoVO(ObjetoVO).ListaRequisicaoInterna.Add(RequisicaoInternaDetalhe);

      CDSRequisicaoInternaDetalhe.Next;
    end;
    CDSRequisicaoInternaDetalhe.EnableControls;

    if TRequisicaoInternaCabecalhoController.Altera(TRequisicaoInternaCabecalhoVO(ObjetoVO)) then
    begin
      Application.MessageBox('Requisição deferida com sucesso.', 'Mensagem do Sistema', MB_OK + MB_ICONINFORMATION);
      BotaoCancelar.Click;
      EditCriterioRapido.Text := CriterioRapido;
      BotaoConsultar.Click;
    end;
  end;
end;

procedure TFRequisicaoInterna.ActionIndeferirSolicitacaoExecute(Sender: TObject);
begin
  if StatusTela = stInserindo then
    Application.MessageBox('A requisição ainda não foi salva.', 'Mensagem do Sistema', MB_OK + MB_ICONINFORMATION)
  else if StatusTela = stEditando then
  begin
    TRequisicaoInternaCabecalhoVO(ObjetoVO).Situacao := 'I';

    if TRequisicaoInternaCabecalhoController.Altera(TRequisicaoInternaCabecalhoVO(ObjetoVO)) then
    begin
      Application.MessageBox('Requisição indeferida com sucesso.', 'Mensagem do Sistema', MB_OK + MB_ICONINFORMATION);
      BotaoCancelar.Click;
      EditCriterioRapido.Text := CriterioRapido;
      BotaoConsultar.Click;
    end;
  end;
end;
{$ENDREGION}

end.


