{ *******************************************************************************
Title: T2Ti ERP
Description: Janela Cadastro de Instruções da Ordem de Produção

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

@author Albert Eije
@version 2.0
******************************************************************************* }
unit UPcpOp;

{$MODE Delphi}

interface

uses
  BrookHTTPClient, BrookFCLHTTPClientBroker, BrookHTTPUtils, BrookUtils,
  FPJson, ZDataset,
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UTelaCadastro, Menus, StdCtrls, ExtCtrls, Buttons, Grids, DBGrids,
  ComCtrls, LabeledCtrls, rxdbgrid, rxtoolbar, curredit, DBCtrls, StrUtils,
  Math, Constantes, CheckLst, ActnList, ToolWin, ShellApi, DB, BufDataset, Biblioteca,
  ULookup, PcpOpController, VO, PcpOpCabecalhoVO;

type

  { TFPcpOp }

  TFPcpOp = class(TFTelaCadastro)
    CDSColaboradores: TBufDataset;
    CDSEquipamentos: TBufDataset;
    CDSInstrucoes: TBufDataset;
    CDSItens: TBufDataset;
    CDSItensCUSTO_PREVISTO: TFloatField;
    CDSItensCUSTO_REALIZADO: TFloatField;
    CDSItensID1: TIntegerField;
    CDSItensID_PCP_OP_CABECALHO: TIntegerField;
    CDSItensID_PRODUTO: TIntegerField;
    CDSItensPERSISTE: TStringField;
    CDSItensPRODUTONOME: TStringField;
    CDSItensQUANTIDADE_ENTREGUE: TFloatField;
    CDSItensQUANTIDADE_PRODUZIDA: TFloatField;
    CDSItensQUANTIDADE_PRODUZIR: TFloatField;
    CDSServicos: TBufDataset;
    EditCustoTotalPrevisto: TLabeledCalcEdit;
    EditCustoTotalRealizado: TLabeledCalcEdit;
    EditPercentualEstoque: TLabeledCalcEdit;
    EditPercentualVenda: TLabeledCalcEdit;
    ScrollBox: TScrollBox;
    EditInicio: TLabeledDateEdit;
    EditPrevisaoEntrega: TLabeledDateEdit;
    EditTermino: TLabeledDateEdit;
    Bevel1: TBevel;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    Panel1: TPanel;
    GridItens: TRxDbGrid;
    DSItens: TDataSource;
    Panel2: TPanel;
    DSInstrucoes: TDataSource;
    ActionManager: TActionList;
    ActionAdicionarItem: TAction;
    ActionRemoverItem: TAction;
    ActionRemoverServico: TAction;
    ActionInstrucao: TAction;
    ActionRemoverInstrucao: TAction;
    JvDBUltimGrid2: TRxDbGrid;
    ActionToolBarItens: TToolPanel;
    ActionToolBarInstrucoes: TToolPanel;
    DSServicos: TDataSource;
    GridServicos: TRxDbGrid;
    Panel3: TPanel;
    GridColaborador: TRxDbGrid;
    Panel4: TPanel;
    GridEquipamentos: TRxDbGrid;
    ActionToolBarColaboradores: TToolPanel;
    ActionToolBarEquipamentos: TToolPanel;
    ActionToolBarServicos: TToolPanel;
    ActionAdicionarColaborador: TAction;
    ActionAdicionarEquipamento: TAction;
    ActionRemoverColaborador: TAction;
    ActionRemoverEquipamento: TAction;
    DSColaboradores: TDataSource;
    DSEquipamentos: TDataSource;
    ActionAdicionarServico: TAction;
    procedure ActionInstrucaoExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ActionRemoverInstrucaoExecute(Sender: TObject);
    procedure ActionAdicionarItemExecute(Sender: TObject);
    procedure ActionRemoverItemExecute(Sender: TObject);
    procedure ActionAdicionarColaboradorExecute(Sender: TObject);
    procedure ActionAdicionarEquipamentoExecute(Sender: TObject);
    procedure ActionRemoverServicoExecute(Sender: TObject);
    procedure ActionRemoverColaboradorExecute(Sender: TObject);
    procedure ActionRemoverEquipamentoExecute(Sender: TObject);
    procedure ControlaPersistencia(pDataSet: TDataSet);
    procedure ActionAdicionarServicoExecute(Sender: TObject);
    procedure BotaoConsultarClick(Sender: TObject);
    procedure BotaoSalvarClick(Sender: TObject);
  private
    function DoInserir: boolean; override;
    function DoEditar: boolean; override;
    function DoExcluir: boolean; override;
    function DoSalvar: boolean; override;

    procedure GridParaEdits; override;
    procedure LimparCampos; override;

  public

  end;

var
  FPcpOp: TFPcpOp;

implementation

{$R *.lfm}

uses
  PcpInstrucaoVO, ProdutoVO, ProdutoController, PcpInstrucaoOpVO, PcpInstrucaoController,
  PcpOpDetalheVO, Controller, PcpServicoVO, PcpServicoColaboradorVO,
  PcpServicoEquipamentoVO, ColaboradorVO, ColaboradorController,
  PatrimBemVO, PatrimBemController, ViewPessoaColaboradorVO,
  ViewPessoaColaboradorController;

{$REGION 'Infra'}
procedure TFPcpOp.BotaoConsultarClick(Sender: TObject);
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

    ListaCampos := TStringList.Create;
    RetornoConsulta := TPcpOpController.Consulta(Filtro, IntToStr(Pagina));
    RetornoConsulta.Active := True;

    RetornoConsulta.GetFieldNames(ListaCampos);

    RetornoConsulta.First;
    while not RetornoConsulta.EOF do
    begin
      CDSGrid.Append;
      for i := 0 to ListaCampos.Count - 1 do
      begin
        CDSGrid.FieldByName(ListaCampos[i]).Value :=
          RetornoConsulta.FieldByName(ListaCampos[i]).Value;
      end;
      CDSGrid.Post;
      RetornoConsulta.Next;
    end;
  end;
end;

procedure TFPcpOp.BotaoSalvarClick(Sender: TObject);
begin
  inherited;
  BotaoConsultarClick(Sender);
end;

procedure TFPcpOp.FormCreate(Sender: TObject);
begin
  ClasseObjetoGridVO := TPcpOpCabecalhoVO;
  ObjetoController := TPcpOpController.Create;

  inherited;
  ConfiguraCDSFromVO(CDSItens, TPcpOpDetalheVO);
  ConfiguraCDSFromVO(CDSInstrucoes, TPcpInstrucaoOpVO);
  ConfiguraCDSFromVO(CDSServicos, TPcpServicoVO);
  ConfiguraCDSFromVO(CDSColaboradores, TPcpServicoColaboradorVO);
  ConfiguraCDSFromVO(CDSEquipamentos, TPcpServicoEquipamentoVO);

  LimparCampos;
end;

procedure TFPcpOp.LimparCampos;
begin
  inherited;
  CDSItens.Close;
  CDSItens.Open;
  CDSInstrucoes.Close;
  CDSInstrucoes.Open;
  CDSServicos.Close;
  CDSServicos.Open;
  CDSColaboradores.Close;
  CDSColaboradores.Open;
  CDSEquipamentos.Close;
  CDSEquipamentos.Open;
end;
{$ENDREGION}

{$REGION 'Controles CRUD'}
function TFPcpOp.DoInserir: boolean;
begin
  Result := inherited DoInserir;

  if Result then
  begin
    EditInicio.SetFocus;
  end;
end;

function TFPcpOp.DoEditar: boolean;
begin
  Result := inherited DoEditar;

  if Result then
  begin
    EditInicio.SetFocus;
  end;
end;

function TFPcpOp.DoExcluir: boolean;
begin
  if inherited DoExcluir then
  begin
    try
      Result := TPcpOpController.Exclui(IdRegistroSelecionado);
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

function TFPcpOp.DoSalvar: boolean;
var
  PcpOpDetalhe: TPcpOpDetalheVO;
  PcpInstrucaoOp: TPcpInstrucaoOpVO;
begin
  Result := inherited DoSalvar;

  if Result then
  begin

    try
      if not Assigned(ObjetoVO) then
        ObjetoVO := TPcpOpCabecalhoVO.Create;

      TPcpOpCabecalhoVO(ObjetoVO).IdEmpresa := Sessao.Empresa.Id;
      TPcpOpCabecalhoVO(ObjetoVO).Inicio := EditInicio.Date;
      TPcpOpCabecalhoVO(ObjetoVO).PrevisaoEntrega := EditPrevisaoEntrega.Date;
      TPcpOpCabecalhoVO(ObjetoVO).Termino := EditTermino.Date;
      TPcpOpCabecalhoVO(ObjetoVO).CustoTotalPrevisto := EditCustoTotalPrevisto.Value;
      TPcpOpCabecalhoVO(ObjetoVO).CustoTotalRealizado := EditCustoTotalRealizado.Value;
      TPcpOpCabecalhoVO(ObjetoVO).PorcentoVenda := EditPercentualVenda.Value;
      TPcpOpCabecalhoVO(ObjetoVO).PorcentoEstoque := EditPercentualEstoque.Value;

      // Detalhes
      CDSItens.DisableControls;
      CDSItens.First;
      while not CDSItens.EOF do
      begin
          PcpOpDetalhe := TPcpOpDetalheVO.Create;
          PcpOpDetalhe.Id := CDSItens.FieldByName('ID').AsInteger;
          PcpOpDetalhe.IdPcpOpCabecalho := TPcpOpCabecalhoVO(ObjetoVO).Id;
          PcpOpDetalhe.IdProduto := CDSItens.FieldByName('ID_PRODUTO').AsInteger;
          PcpOpDetalhe.QuantidadeProduzir := CDSItens.FieldByName('QUANTIDADE_PRODUZIR').AsFloat;
          PcpOpDetalhe.QuantidadeProduzida := CDSItens.FieldByName('QUANTIDADE_PRODUZIDA').AsFloat;
          PcpOpDetalhe.QuantidadeEntregue := CDSItens.FieldByName('QUANTIDADE_ENTREGUE').AsFloat;
          PcpOpDetalhe.CustoPrevisto := CDSItens.FieldByName('CUSTO_PREVISTO').AsFloat;
          PcpOpDetalhe.CustoRealizado := CDSItens.FieldByName('CUSTO_REALIZADO').AsFloat;

          TPcpOpCabecalhoVO(ObjetoVO).ListaPcpOpDetalheVO.Add(PcpOpDetalhe);

          CDSItens.Next;
      end;
      CDSItens.First;
      CDSItens.EnableControls;


      // Instruções
      CDSInstrucoes.DisableControls;
      CDSInstrucoes.First;
      while not CDSInstrucoes.EOF do
      begin
          PcpInstrucaoOp := TPcpInstrucaoOpVO.Create;
          PcpInstrucaoOp.Id := CDSInstrucoes.FieldByName('ID').AsInteger;
          PcpInstrucaoOp.IdPcpOpCabecalho := TPcpOpCabecalhoVO(ObjetoVO).Id;
          PcpInstrucaoOp.IdPcpInstrucao := CDSInstrucoes.FieldByName('ID_PCP_INSTRUCAO').AsInteger;

          TPcpOpCabecalhoVO(ObjetoVO).ListaPcpInstrucaoOpVO.Add(PcpInstrucaoOp);

          CDSInstrucoes.Next;
      end;
      CDSInstrucoes.First;
      CDSInstrucoes.EnableControls;


      /// EXERCICIO
      ///  Persista as demais listas. Tome a janela NF-e como exemplo.

      if StatusTela = stInserindo then
      begin
        TPcpOpController.Insere(TPcpOpCabecalhoVO(ObjetoVO));
      end
      else if StatusTela = stEditando then
      begin
        /// EXERCICIO: Verifique se tem como serializar as listas junto com o objeto para realizar a comparação
        //if TPcpOpCabecalhoVO(ObjetoVO).ToJSONString <> StringObjetoOld then
        //begin
        TPcpOpController.Altera(TPcpOpCabecalhoVO(ObjetoVO));
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

{$REGION 'Controle de Grid e Edits'}
procedure TFPcpOp.GridParaEdits;
var
  IdCabecalho: string;
begin
  inherited;

  if not CDSGrid.IsEmpty then
  begin
    IdCabecalho := IntToStr(IdRegistroSelecionado);
    ObjetoVO := TPcpOpController.ConsultaObjeto('ID=' + IdCabecalho);
  end;

  if Assigned(ObjetoVO) then
  begin
    EditInicio.Date := TPcpOpCabecalhoVO(ObjetoVO).Inicio;
    EditPrevisaoEntrega.Date := TPcpOpCabecalhoVO(ObjetoVO).PrevisaoEntrega;
    EditTermino.Date := TPcpOpCabecalhoVO(ObjetoVO).Termino;
    EditCustoTotalPrevisto.Value := TPcpOpCabecalhoVO(ObjetoVO).CustoTotalPrevisto;
    EditCustoTotalRealizado.Value := TPcpOpCabecalhoVO(ObjetoVO).CustoTotalRealizado;
    EditPercentualVenda.Value := TPcpOpCabecalhoVO(ObjetoVO).PorcentoVenda;
    EditPercentualEstoque.Value := TPcpOpCabecalhoVO(ObjetoVO).PorcentoEstoque;

    /// EXERCICIO
    ///  Carregue os dados de todas as listas

    //TController.TratarRetorno<TPcpOpDetalheVO>(TPcpOpCabecalhoVO(ObjetoVO).ListaPcpOpDetalheVO, True, True, CDSItens);
    //TController.TratarRetorno<TPcpInstrucaoOpVO>(TPcpOpCabecalhoVO(ObjetoVO).ListaPcpInstrucaoOpVO, True, True, CDSInstrucoes);

    //PcpOpDetalheEnumerator := TPcpOpCabecalhoVO(ObjetoVO).ListaPcpOpDetalheVO.GetEnumerator;
    //try
    //  with PcpOpDetalheEnumerator do
    //  begin
    //    while MoveNext do
    //    begin
    //      TController.TratarRetorno<TPcpServicoVO>(Current.ListaPcpServicoVO, False, True, CDSServicos);

    //      PcpServicoEnumerator := TPcpOpDetalheVO(Current).ListaPcpServicoVO.GetEnumerator;
    //      try
    //        with PcpServicoEnumerator do
    //        begin
    //          while MoveNext do
    //          begin
    //            TController.TratarRetorno<TPcpServicoColaboradorVO>(Current.ListaPcpColabradorVO, False, True, CDSColaboradores);
    //            TController.TratarRetorno<TPcpServicoEquipamentoVO>(Current.ListaPcpServicoEquipamentoVO, False, True, CDSEquipamentos);
    //          end;
    //        end;
    //      finally
    //        FreeAndNil(PcpServicoEnumerator);
    //      end;
    //    end;
    //  end;
    //finally
    //  FreeAndNil(PcpOpDetalheEnumerator);
    //end;

    // Serializa o objeto para consultar posteriormente se houve alterações
    FormatSettings.DecimalSeparator := '.';
    StringObjetoOld := ObjetoVO.ToJSONString;
    FormatSettings.DecimalSeparator := ',';
  end;
end;

procedure TFPcpOp.ControlaPersistencia(pDataSet: TDataSet);
begin
  //pDataSet.FieldByName('PERSISTE').AsString := 'S';
end;

{$ENDREGION}

{$REGION 'Actions'}

/// EXERCICIO
///  Implemente a buca usando a janela FLookup

procedure TFPcpOp.ActionAdicionarItemExecute(Sender: TObject);
begin
  try
    // PopulaCamposTransientesLookup(TProduto, TProdutoController);
    //if CDSTransiente.RecordCount > 0 then
    //begin
      CDSItens.Append;
      CDSItens.FieldByName('ID_PRODUTO').AsInteger := 1;//CDSTransiente.FieldByName('ID').AsInteger;
//      CDSItens.FieldByName('PRODUTO.NOME').AsString := CDSTransiente.FieldByName('NOME').AsString;
      CDSItens.FieldByName('CUSTO_PREVISTO').AsFloat := 10;//CDSTransiente.FieldByName('CUSTO_UNITARIO').AsFloat;
    //end;
  finally
    CDSTransiente.Close;
  end;
end;

procedure TFPcpOp.ActionAdicionarServicoExecute(Sender: TObject);
begin
  inherited;
  /// EXERCICIO
  ///  Implemente essa action
end;

procedure TFPcpOp.ActionAdicionarColaboradorExecute(Sender: TObject);
begin
  try
    // PopulaCamposTransientesLookup(TPcpServicoColaboradorVO, TPcpServicoColaboradorController);
    //if CDSTransiente.RecordCount > 0 then
    //begin
      CDSColaboradores.Append;
      CDSColaboradores.FieldByName('ID_COLABORADOR').AsInteger := 1;//CDSTransiente.FieldByName('ID').AsInteger;
    //end;
  finally
    CDSTransiente.Close;
  end;
end;

procedure TFPcpOp.ActionAdicionarEquipamentoExecute(Sender: TObject);
begin
  try
    //PopulaCamposTransientesLookup(TPcpServicoEquipamentoVO, TPcpServicoEquipamentoController);
    //if CDSTransiente.RecordCount > 0 then
    //begin
      CDSEquipamentos.Append;
      CDSEquipamentos.FieldByName('ID_PATRIM_BEM').AsInteger := 1;// CDSTransiente.FieldByName('ID').AsInteger;
    //end;
  finally
    CDSTransiente.Close;
  end;
end;

procedure TFPcpOp.ActionInstrucaoExecute(Sender: TObject);
begin
  try
    // PopulaCamposTransientesLookup(TPcpInstrucaoVO, TPcpInstrucaoController);
    //if CDSTransiente.RecordCount > 0 then
    //begin
      CDSInstrucoes.Append;
      CDSInstrucoes.FieldByName('ID').AsInteger := 1;//CDSTransiente.FieldByName('ID').AsInteger;
      //CDSInstrucoes.FieldByName('PCP_INSTRUCAO.CODIGO').AsInteger := CDSTransiente.FieldByName('CODIGO').AsInteger;
      //CDSInstrucoes.FieldByName('PCP_INSTRUCAO.DESCRICAO').AsString := CDSTransiente.FieldByName('DESCRICAO').AsString;
    //end;
  finally
    CDSTransiente.Close;
  end;
end;
{$ENDREGION}

{$REGION 'Exclusões Internas'}
procedure TFPcpOp.ActionRemoverInstrucaoExecute(Sender: TObject);
begin
  if Application.MessageBox('Tem certeza que deseja remover esta instrução?', 'Pergunta do Sistema', MB_YesNo + MB_IconQuestion) = idYes then
  begin
    if StatusTela = stInserindo then
      CDSInstrucoes.Delete
    else if StatusTela = stEditando then
    begin
      TPcpOpController.ExcluiInstrucao(CDSInstrucoes.FieldByName('ID').AsInteger);
    end;
  end;
end;

procedure TFPcpOp.ActionRemoverItemExecute(Sender: TObject);
begin
  if Application.MessageBox('Tem certeza que deseja remover o item da Ordem de Produção?','Pergunta do Sistema', MB_YesNo + MB_IconQuestion) = idYes then
  begin
    if StatusTela = stInserindo then
      CDSInstrucoes.Delete
    else if StatusTela = stEditando then
    begin
      TPcpOpController.ExcluiItem(CDSItens.FieldByName('ID').AsInteger);
    end;
  end;
end;

procedure TFPcpOp.ActionRemoverServicoExecute(Sender: TObject);
begin
  if Application.MessageBox('Tem certeza que deseja remover o Serviço?', 'Pergunta do Sistema', MB_YesNo + MB_IconQuestion) = idYes then
  begin
    if StatusTela = stInserindo then
      CDSInstrucoes.Delete
    else if StatusTela = stEditando then
    begin
      TPcpOpController.ExcluiServico(CDSServicos.FieldByName('ID').AsInteger);
    end;
  end;
end;

procedure TFPcpOp.ActionRemoverColaboradorExecute(Sender: TObject);
begin
  if Application.MessageBox('Tem certeza que deseja remover o colaborador?', 'Pergunta do Sistema', MB_YesNo + MB_IconQuestion) = idYes then
  begin
    if StatusTela = stInserindo then
      CDSInstrucoes.Delete
    else if StatusTela = stEditando then
    begin
      TPcpOpController.ExcluiColaborador(CDSColaboradores.FieldByName('ID').AsInteger);
    end;
  end;
end;

procedure TFPcpOp.ActionRemoverEquipamentoExecute(Sender: TObject);
begin
  if Application.MessageBox('Tem certeza que deseja remover o equipamento?', 'Pergunta do Sistema', MB_YesNo + MB_IconQuestion) = idYes then
  begin
    if StatusTela = stInserindo then
      CDSInstrucoes.Delete
    else if StatusTela = stEditando then
    begin
      TPcpOpController.ExcluiEquipamento(CDSEquipamentos.FieldByName('ID').AsInteger);
    end;
  end;
end;
{$ENDREGION}

/// EXERCICIO
///  Implemente o mestre/detalhe entre os clientdatasets

/// EXERCICIO - Integração Compras
///  Verifique quais itens não estão no estoque e gere uma requisição de compra

/// EXERCICIO - Integração Estoque
///  Incremente no estoque os itens produzidos
///  Decremente do estoque os itens utilizados para produção

end.
