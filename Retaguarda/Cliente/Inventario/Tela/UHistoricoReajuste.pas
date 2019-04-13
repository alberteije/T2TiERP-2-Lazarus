{ *******************************************************************************
Title: T2Ti ERP
Description: Janela Para Reajustar Preços de Mercadorias e Manter um Histórico

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
unit UHistoricoReajuste;

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

  { TFHistoricoReajuste }

  TFHistoricoReajuste = class(TFTelaCadastro)
    BevelEdits: TBevel;
    CDSEstoqueReajusteDetalhe: TBufDataset;
    DSEstoqueReajusteDetalhe: TDataSource;
    GroupBoxParcelas: TGroupBox;
    GridItens: TRxDbGrid;
    ActionManager: TActionList;
    ActionSelecionarItens: TAction;
    ActionRealizarCalculos: TAction;
    ActionToolBarEdits: TToolPanel;
    EditIdColaborador: TLabeledCalcEdit;
    EditColaborador: TLabeledEdit;
    EditDataReajuste: TLabeledDateEdit;
    EditPorcentagemReajuste: TLabeledCalcEdit;
    ComboBoxTipoReajuste: TLabeledComboBox;
    CDSEstoqueReajusteDetalheID: TIntegerField;
    CDSEstoqueReajusteDetalheID_PRODUTO: TIntegerField;
    CDSEstoqueReajusteDetalheVALOR_ORIGINAL: TFloatField;
    CDSEstoqueReajusteDetalheVALOR_REAJUSTE: TFloatField;
    CDSEstoqueReajusteDetalhePRODUTONOME: TStringField;
    CDSProduto: TBufDataSet;
    CDSProdutoID: TIntegerField;
    CDSProdutoNOME: TStringField;
    CDSEstoqueReajusteDetalheID_ESTOQUE_REAJUSTE_CABECALHO: TIntegerField;
    CDSProdutoVALOR_VENDA: TFloatField;
    LabeledEdit1: TLabeledEdit;
    procedure FormCreate(Sender: TObject);
    procedure ActionSelecionarItensExecute(Sender: TObject);
    procedure ActionRealizarCalculosExecute(Sender: TObject);
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
  FHistoricoReajuste: TFHistoricoReajuste;

implementation

uses EstoqueReajusteCabecalhoController, EstoqueReajusteCabecalhoVO,
  EstoqueReajusteDetalheVO, UDataModule, ProdutoVO, ProdutoController,
  ViewPessoaColaboradorVO, ViewPessoaColaboradorController, ProdutoSubGrupoVO,
  ProdutoSubGrupoController;
{$R *.lfm}

{$REGION 'Infra'}
procedure TFHistoricoReajuste.BotaoConsultarClick(Sender: TObject);
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
    RetornoConsulta := TEstoqueReajusteCabecalhoController.Consulta(Filtro, IntToStr(Pagina));
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

procedure TFHistoricoReajuste.BotaoSalvarClick(Sender: TObject);
begin
  inherited;
  BotaoConsultarClick(Sender);
end;

procedure TFHistoricoReajuste.FormCreate(Sender: TObject);
begin
  ClasseObjetoGridVO := TEstoqueReajusteCabecalhoVO;
  ObjetoController := TEstoqueReajusteCabecalhoController.Create;

  inherited;

  ConfiguraCDSFromVO(CDSEstoqueReajusteDetalhe, TEstoqueReajusteDetalheVO);
  ConfiguraGridFromVO(GridItens, TEstoqueReajusteDetalheVO);
end;

procedure TFHistoricoReajuste.LimparCampos;
begin
  inherited;
  CDSEstoqueReajusteDetalhe.Close;
  CDSEstoqueReajusteDetalhe.Open;
end;
{$ENDREGION}

{$REGION 'Controles CRUD'}
function TFHistoricoReajuste.DoInserir: Boolean;
begin
  Result := inherited DoInserir;

  if Result then
  begin
    EditIdColaborador.SetFocus;
  end;
end;

function TFHistoricoReajuste.DoEditar: Boolean;
begin
  Result := inherited DoEditar;

  if Result then
  begin
    EditIdColaborador.SetFocus;
  end;
end;

function TFHistoricoReajuste.DoExcluir: Boolean;
begin
  if inherited DoExcluir then
  begin
    try
      Result := TEstoqueReajusteCabecalhoController.Exclui(IdRegistroSelecionado);
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

function TFHistoricoReajuste.DoSalvar: Boolean;
var
  EstoqueReajusteDetalhe: TEstoqueReajusteDetalheVO;
begin
  Result := inherited DoSalvar;

  if Result then
  begin
    try
      ObjetoVO := TEstoqueReajusteCabecalhoVO.Create;

      TEstoqueReajusteCabecalhoVO(ObjetoVO).IdColaborador := EditIdColaborador.AsInteger;
      TEstoqueReajusteCabecalhoVO(ObjetoVO).ColaboradorPessoaNome := EditColaborador.Text;
      TEstoqueReajusteCabecalhoVO(ObjetoVO).DataReajuste := EditDataReajuste.Date;
      TEstoqueReajusteCabecalhoVO(ObjetoVO).Porcentagem := EditPorcentagemReajuste.Value;
      TEstoqueReajusteCabecalhoVO(ObjetoVO).TipoReajuste := Copy(ComboBoxTipoReajuste.Text, 1, 1);

      // Itens
      CDSEstoqueReajusteDetalhe.DisableControls;
      CDSEstoqueReajusteDetalhe.First;
      while not CDSEstoqueReajusteDetalhe.Eof do
      begin
        EstoqueReajusteDetalhe := TEstoqueReajusteDetalheVO.Create;
        EstoqueReajusteDetalhe.Id := CDSEstoqueReajusteDetalhe.FieldByName('ID').AsInteger;
        EstoqueReajusteDetalhe.IdEstoqueReajusteCabecalho := TEstoqueReajusteCabecalhoVO(ObjetoVO).Id;
        EstoqueReajusteDetalhe.IdProduto := CDSEstoqueReajusteDetalhe.FieldByName('ID_PRODUTO').AsInteger;
        //EstoqueReajusteDetalhe.ProdutoNome := CDSEstoqueReajusteDetalhe.FieldByName('PRODUTONOME').AsString;
        EstoqueReajusteDetalhe.ValorOriginal := CDSEstoqueReajusteDetalhe.FieldByName('VALOR_ORIGINAL').AsFloat;
        EstoqueReajusteDetalhe.ValorReajuste := CDSEstoqueReajusteDetalhe.FieldByName('VALOR_REAJUSTE').AsFloat;

        TEstoqueReajusteCabecalhoVO(ObjetoVO).ListaEstoqueReajusteDetalheVO.Add(EstoqueReajusteDetalhe);

        CDSEstoqueReajusteDetalhe.Next;
      end;
      CDSEstoqueReajusteDetalhe.EnableControls;

      if StatusTela = stInserindo then
      begin
        TEstoqueReajusteCabecalhoController.Insere(TEstoqueReajusteCabecalhoVO(ObjetoVO));
      end
      else if StatusTela = stEditando then
      begin
        /// EXERCICIO: Verifique se tem como serializar as listas junto com o objeto para realizar a comparação
        //if TEstoqueReajusteCabecalhoVO(ObjetoVO).ToJSONString <> StringObjetoOld then
        //begin
          TEstoqueReajusteCabecalhoController.Altera(TEstoqueReajusteCabecalhoVO(ObjetoVO));
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
procedure TFHistoricoReajuste.GridParaEdits;
var
  IdCabecalho: String;
  I: Integer;
  Current: TEstoqueReajusteDetalheVO;
begin
  inherited;

  if not CDSGrid.IsEmpty then
  begin
    IdCabecalho := IntToStr(IdRegistroSelecionado);
    ObjetoVO := TEstoqueReajusteCabecalhoController.ConsultaObjeto('ID=' + IdCabecalho);
  end;

  if Assigned(ObjetoVO) then
  begin
    EditIdColaborador.AsInteger := TEstoqueReajusteCabecalhoVO(ObjetoVO).IdColaborador;
    EditColaborador.Text := TEstoqueReajusteCabecalhoVO(ObjetoVO).ColaboradorPessoaNome;
    EditDataReajuste.Date := TEstoqueReajusteCabecalhoVO(ObjetoVO).DataReajuste;
    EditPorcentagemReajuste.Value := TEstoqueReajusteCabecalhoVO(ObjetoVO).Porcentagem;

    ComboBoxTipoReajuste.ItemIndex := AnsiIndexStr(TEstoqueReajusteCabecalhoVO(ObjetoVO).TipoReajuste, ['A', 'D']);

    // Itens
    for I := 0 to TEstoqueReajusteCabecalhoVO(ObjetoVO).ListaEstoqueReajusteDetalheVO.Count - 1 do
    begin
      Current := TEstoqueReajusteCabecalhoVO(ObjetoVO).ListaEstoqueReajusteDetalheVO[I];

      CDSEstoqueReajusteDetalhe.Append;

      CDSEstoqueReajusteDetalhe.FieldByName('ID').AsInteger := Current.Id;
      CDSEstoqueReajusteDetalhe.FieldByName('ID_PRODUTO').AsInteger := Current.IdProduto;
      //CDSEstoqueReajusteDetalhePRODUTONOME.AsString := Current.ProdutoVO.Nome;
      CDSEstoqueReajusteDetalhe.FieldByName('ID_ESTOQUE_REAJUSTE_CABECALHO').AsInteger := Current.IdEstoqueReajusteCabecalho;
      CDSEstoqueReajusteDetalhe.FieldByName('VALOR_ORIGINAL').AsFloat := Current.ValorOriginal;
      CDSEstoqueReajusteDetalhe.FieldByName('VALOR_REAJUSTE').AsFloat := Current.ValorReajuste;

      CDSEstoqueReajusteDetalhe.Post;
    end;

    // Serializa o objeto para consultar posteriormente se houve alterações
    FormatSettings.DecimalSeparator := '.';
    StringObjetoOld := ObjetoVO.ToJSONString;
    FormatSettings.DecimalSeparator := ',';
  end;
end;
{$ENDREGION}

{$REGION 'Campos Transientes'}
procedure TFHistoricoReajuste.EditIdColaboradorKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  Filtro: String;
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
      ComboBoxTipoReajuste.SetFocus;
    end;
  end;
end;
{$ENDREGION}

{$REGION 'Actions'}
procedure TFHistoricoReajuste.ActionSelecionarItensExecute(Sender: TObject);
var
  CDSProduto: TZQuery;
  Filtro: String;
  SubGrupoLocal: TProdutoSubGrupoVO;
begin
  //Filtra os produtos por SubGrupo

  /// EXERCICIO: Utilize a janela FLookup para inserir itens

  FLookup.ShowModal;

  SubGrupoLocal := TProdutoSubGrupoController.ConsultaObjeto('ID='+FLookup.IdSelecionado);

  if Assigned(SubGrupoLocal) then
  begin
    Filtro := 'ID_SUBGRUPO = ' + IntToStr(SubGrupoLocal.Id);

    CDSProduto := TProdutoController.Consulta(Filtro, '0');
    CDSProduto.Active := True;

    CDSProduto.First;
    while not CDSProduto.Eof do
    begin
      CDSEstoqueReajusteDetalhe.Append;

      CDSEstoqueReajusteDetalhe.FieldByName('ID_PRODUTO').AsInteger := CDSProduto.FieldByName('ID').AsInteger;
      //CDSEstoqueReajusteDetalhe.FieldByName('PRODUTONOME').AsString := CDSProduto.FieldByName('NOME').AsString;
      CDSEstoqueReajusteDetalhe.FieldByName('ID_ESTOQUE_REAJUSTE_CABECALHO').AsInteger := 0;
      CDSEstoqueReajusteDetalhe.FieldByName('VALOR_ORIGINAL').AsFloat := CDSProduto.FieldByName('VALOR_VENDA').AsFloat;
      CDSEstoqueReajusteDetalhe.FieldByName('VALOR_REAJUSTE').AsFloat := 0;

      CDSEstoqueReajusteDetalhe.Post;
      CDSProduto.Next;
    end;
  end;
end;

procedure TFHistoricoReajuste.ActionRealizarCalculosExecute(Sender: TObject);
begin
  CDSEstoqueReajusteDetalhe.DisableControls;
  CDSEstoqueReajusteDetalhe.First;
  while not CDSEstoqueReajusteDetalhe.Eof do
  begin
    CDSEstoqueReajusteDetalhe.Edit;
    if ComboBoxTipoReajuste.ItemIndex = 0 then
      CDSEstoqueReajusteDetalhe.FieldByName('VALOR_REAJUSTE').AsFloat := CDSEstoqueReajusteDetalhe.FieldByName('VALOR_ORIGINAL').AsFloat * (1 + (EditPorcentagemReajuste.Value / 100))
    else
      CDSEstoqueReajusteDetalhe.FieldByName('VALOR_REAJUSTE').AsFloat := CDSEstoqueReajusteDetalhe.FieldByName('VALOR_ORIGINAL').AsFloat * (1 - (EditPorcentagemReajuste.Value / 100));

    CDSEstoqueReajusteDetalhe.Post;
    CDSEstoqueReajusteDetalhe.Next;
  end;
  CDSEstoqueReajusteDetalhe.First;
  CDSEstoqueReajusteDetalhe.EnableControls;
end;
{$ENDREGION}


/// EXERCICIO
///  Adapte essa janela para ajustar também a quantidade do estoque de forma
///  manual fornecendo uma justificativa, de acordo com o requisito 011.
///  Observe no Change-log quais campos foram adicionados nas tabelas para
///  permitir o reajuste na quantidade.

end.

