{ *******************************************************************************
Title: T2Ti ERP
Description: Janela para confirmar a Cotação de Compra

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
unit UCompraMapaComparativo;

{$MODE Delphi}

interface

uses
  BrookHTTPClient, BrookFCLHTTPClientBroker, BrookHTTPUtils, BrookUtils, FPJson, ZDataset,
  LCLIntf, LCLType, LMessages, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UTelaCadastro, Menus, StdCtrls, ExtCtrls, Buttons, Grids, DBGrids,
  ComCtrls, LabeledCtrls, rxdbgrid, rxtoolbar, DBCtrls, StrUtils,
  Math, Constantes, CheckLst, ActnList, ToolWin, db, BufDataset, Biblioteca,
  ULookup, VO, CompraCotacaoController, CompraCotacaoVO;

type

  { TFCompraMapaComparativo }

  TFCompraMapaComparativo = class(TFTelaCadastro)
    BevelEdits: TBevel;
    CDSCompraMapaComparativo: TBufDataset;
    EditDescricao: TLabeledEdit;
    EditDataCotacao: TLabeledDateEdit;
    GroupBoxItensCotacao: TGroupBox;
    GridCompraMapaComparativo: TRxDbGrid;
    GroupBoxFornecedores: TGroupBox;
    GridCompraFornecedorCotacao: TRxDbGrid;
    DSCompraFornecedorCotacao: TDataSource;
    DSCompraMapaComparativo: TDataSource;
    CDSCompraFornecedorCotacao: TBufDataSet;
    ActionManager1: TActionList;
    procedure FormCreate(Sender: TObject);
    procedure GridDblClick(Sender: TObject);
    procedure CDSCompraMapaComparativoAfterPost(DataSet: TDataSet);
    procedure BotaoConsultarClick(Sender: TObject);
    procedure BotaoSalvarClick(Sender: TObject);
  private
    { Private declarations }
    function ValidarDadosInformados: Boolean;
  public
    { Public declarations }
    procedure GridParaEdits; override;
    procedure LimparCampos; override;

    // Controles CRUD
    function DoEditar: Boolean; override;
    function DoSalvar: Boolean; override;

    procedure ConfigurarLayoutTela;
  end;

var
  FCompraMapaComparativo: TFCompraMapaComparativo;

implementation

uses UDataModule, ViewCompraMapaComparativoVO, ViewCompraMapaComparativoController,
CompraFornecedorCotacaoController, CompraFornecedorCotacaoVO;

{$R *.lfm}

{$REGION 'Infra'}
procedure TFCompraMapaComparativo.BotaoConsultarClick(Sender: TObject);
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

procedure TFCompraMapaComparativo.BotaoSalvarClick(Sender: TObject);
begin
  inherited;
  BotaoConsultarClick(Sender);
end;

procedure TFCompraMapaComparativo.FormCreate(Sender: TObject);
begin
  ClasseObjetoGridVO := TCompraCotacaoVO;
  ObjetoController := TCompraCotacaoController.Create;
  inherited;
  BotaoInserir.Visible := False;
  BotaoExcluir.Visible := False;

  ConfiguraCDSFromVO(CDSCompraMapaComparativo, TViewCompraMapaComparativoVO);
  ConfiguraGridFromVO(GridCompraMapaComparativo, TViewCompraMapaComparativoVO);

  ConfiguraCDSFromVO(CDSCompraFornecedorCotacao, TCompraFornecedorCotacaoVO);
  ConfiguraGridFromVO(GridCompraFornecedorCotacao, TCompraFornecedorCotacaoVO);
end;

procedure TFCompraMapaComparativo.LimparCampos;
begin
  inherited;
  CDSCompraFornecedorCotacao.Close;
  CDSCompraMapaComparativo.Close;
  CDSCompraFornecedorCotacao.Open;
  CDSCompraMapaComparativo.Open;
end;

procedure TFCompraMapaComparativo.ConfigurarLayoutTela;
begin
  if TCompraCotacaoVO(ObjetoVO).Situacao = 'F' then
  begin
    Application.MessageBox('Cotação já fechada. Os dados serão exibidos apenas para consulta.', 'Mensagem do Sistema', MB_OK + MB_ICONINFORMATION);
    GridCompraMapaComparativo.ReadOnly := True;
  end;
  EditDataCotacao.ReadOnly := True;
  EditDescricao.ReadOnly := True;
  PanelEdits.Enabled := True;
end;
{$ENDREGION}

{$REGION 'Controles CRUD'}
function TFCompraMapaComparativo.DoEditar: Boolean;
begin
  Result := inherited DoEditar;

  ConfigurarLayoutTela;
  if Result then
  begin
    EditDataCotacao.SetFocus;
  end;
end;

function TFCompraMapaComparativo.DoSalvar: Boolean;
var
 CompraMapaComparativo: TViewCompraMapaComparativoVO;
 DadosAlterados: Boolean;
begin
  if TCompraCotacaoVO(ObjetoVO).Situacao <> 'F' then
  begin
    if ValidarDadosInformados then
    begin
      DadosAlterados := False;
      Result := inherited DoSalvar;

      if Result then
      begin
        try

          // Carrega os itens do mapa comparativo numa lista
          CDSCompraMapaComparativo.DisableControls;
          CDSCompraMapaComparativo.First;
          while not CDSCompraMapaComparativo.Eof do
          begin
            if CDSCompraMapaComparativo.FieldByName('QUANTIDADE_PEDIDA').AsFloat > 0 then
            begin
              DadosAlterados := True;

              CompraMapaComparativo := TViewCompraMapaComparativoVO.Create;
              CompraMapaComparativo.IdCompraCotacao := CDSCompraMapaComparativo.FieldByName('ID_COMPRA_COTACAO').AsInteger;
              CompraMapaComparativo.IdCompraFornecedorCotacao := CDSCompraMapaComparativo.FieldByName('ID_COMPRA_FORNECEDOR_COTACAO').AsInteger;
              CompraMapaComparativo.IdCompraCotacaoDetalhe := CDSCompraMapaComparativo.FieldByName('ID_COMPRA_COTACAO_DETALHE').AsInteger;
              CompraMapaComparativo.IdProduto := CDSCompraMapaComparativo.FieldByName('ID_PRODUTO').AsInteger;
              CompraMapaComparativo.IdFornecedor := CDSCompraMapaComparativo.FieldByName('ID_FORNECEDOR').AsInteger;
              CompraMapaComparativo.ProdutoNome := CDSCompraMapaComparativo.FieldByName('PRODUTO_NOME').AsString;
              CompraMapaComparativo.FornecedorNome := CDSCompraMapaComparativo.FieldByName('FORNECEDOR_NOME').AsString;
              CompraMapaComparativo.Quantidade := CDSCompraMapaComparativo.FieldByName('QUANTIDADE').AsFloat;
              CompraMapaComparativo.QuantidadePedida := CDSCompraMapaComparativo.FieldByName('QUANTIDADE_PEDIDA').AsFloat;
              CompraMapaComparativo.ValorUnitario := CDSCompraMapaComparativo.FieldByName('VALOR_UNITARIO').AsFloat;
              CompraMapaComparativo.ValorSubtotal := CDSCompraMapaComparativo.FieldByName('VALOR_SUBTOTAL').AsFloat;
              CompraMapaComparativo.TaxaDesconto := CDSCompraMapaComparativo.FieldByName('TAXA_DESCONTO').AsFloat;
              CompraMapaComparativo.ValorDesconto := CDSCompraMapaComparativo.FieldByName('VALOR_DESCONTO').AsFloat;
              CompraMapaComparativo.ValorTotal := CDSCompraMapaComparativo.FieldByName('VALOR_TOTAL').AsFloat;
              TCompraCotacaoVO(ObjetoVO).ListaMapaComparativo.Add(CompraMapaComparativo);
            end;
            CDSCompraMapaComparativo.Next;
          end;
          CDSCompraMapaComparativo.First;
          CDSCompraMapaComparativo.EnableControls;

          if DadosAlterados then
          begin
            TViewCompraMapaComparativoController.GerarPedidos(TCompraCotacaoVO(ObjetoVO));
          end
          else
            Application.MessageBox('Nenhum dado foi alterado.', 'Mensagem do Sistema', MB_OK + MB_ICONINFORMATION);
        except
          Result := False;
        end;
      end;
    end
    else
      Exit(False);
  end;
end;
{$ENDREGION}

{$REGION 'Controle de Grid'}
procedure TFCompraMapaComparativo.GridParaEdits;
var
  IdCabecalho: String;
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

    // Itens do mapa comparativo
    Filtro := 'ID_COMPRA_COTACAO=' + QuotedStr(IntToStr(TCompraCotacaoVO(ObjetoVO).Id));
    ListaCampos  := TStringList.Create;
    RetornoConsulta := TViewCompraMapaComparativoController.Consulta(Filtro, '0');
    RetornoConsulta.Active := True;

    RetornoConsulta.GetFieldNames(ListaCampos);

    RetornoConsulta.First;
    while not RetornoConsulta.EOF do begin
      CDSCompraMapaComparativo.Append;
      for i := 0 to ListaCampos.Count - 1 do
      begin
        CDSCompraMapaComparativo.FieldByName(ListaCampos[i]).Value := RetornoConsulta.FieldByName(ListaCampos[i]).Value;
      end;
      CDSCompraMapaComparativo.Post;
      RetornoConsulta.Next;
    end;
  end;
end;

procedure TFCompraMapaComparativo.CDSCompraMapaComparativoAfterPost(DataSet: TDataSet);
begin
  if CDSCompraMapaComparativo.FieldByName('ID_COMPRA_COTACAO').AsInteger = 0 then
    CDSCompraMapaComparativo.Delete;
end;

procedure TFCompraMapaComparativo.GridDblClick(Sender: TObject);
begin
  inherited;
  ConfigurarLayoutTela;
end;
{$ENDREGION}

{$REGION 'Actions'}
function TFCompraMapaComparativo.ValidarDadosInformados: Boolean;
var
  Mensagem: String;
  Quantidade, SomaQuantidadePedida: Extended;
  ProdutoAtual: Integer;
begin
  SomaQuantidadePedida := 0;
  //
  CDSCompraMapaComparativo.DisableControls;
  CDSCompraMapaComparativo.First;
  //
  ProdutoAtual := CDSCompraMapaComparativo.FieldByName('ID_PRODUTO').AsInteger;
  Quantidade := CDSCompraMapaComparativo.FieldByName('QUANTIDADE').AsFloat;
  while not CDSCompraMapaComparativo.Eof do
  begin
    if CDSCompraMapaComparativo.FieldByName('QUANTIDADE_PEDIDA').AsFloat  > CDSCompraMapaComparativo.FieldByName('QUANTIDADE').AsFloat then
      Mensagem := Mensagem + #13 + 'A quantidade pedida é maior que a quantidade cotada. [Id Produto = ' + CDSCompraMapaComparativo.FieldByName('ID_PRODUTO').AsString + '] - [Cotada: ' + CDSCompraMapaComparativo.FieldByName('QUANTIDADE').AsString + '] - [Pedida: ' + CDSCompraMapaComparativo.FieldByName('QUANTIDADE_PEDIDA').AsString + ']';

    SomaQuantidadePedida := SomaQuantidadePedida + CDSCompraMapaComparativo.FieldByName('QUANTIDADE_PEDIDA').AsFloat;

    CDSCompraMapaComparativo.Next;

    if CDSCompraMapaComparativo.FieldByName('ID_PRODUTO').AsInteger <> ProdutoAtual then
    begin
      if Quantidade <> SomaQuantidadePedida then
        Mensagem := Mensagem + #13 + 'A soma das quantidades pedidas é maior do que a quantidade cotada. [Id Produto = ' + IntToStr(ProdutoAtual) + '] - [Cotada: ' + FloatToStr(Quantidade) + '] - [Soma Pedida: ' + FloatToStr(SomaQuantidadePedida) + ']';
      //
      ProdutoAtual := CDSCompraMapaComparativo.FieldByName('ID_PRODUTO').AsInteger;
      Quantidade := CDSCompraMapaComparativo.FieldByName('QUANTIDADE').AsFloat;
      SomaQuantidadePedida := 0;
    end;
  end;
  // Teste deve ser realizado aqui novamente para o último produto da lista
  if Quantidade <> SomaQuantidadePedida then
    Mensagem := Mensagem + #13 + 'A soma das quantidades pedidas é maior do que a quantidade cotada. [Id Produto = ' + IntToStr(ProdutoAtual) + '] - [Cotada: ' + FloatToStr(Quantidade) + '] - [Soma Pedida: ' + FloatToStr(SomaQuantidadePedida) + ']';

  CDSCompraMapaComparativo.First;
  CDSCompraMapaComparativo.EnableControls;
  //
  if Mensagem <> '' then
  begin
    Application.MessageBox(PChar('Ocorreram erros na validação dos dados informados. Lista de erros abaixo: ' + #13 + Mensagem), 'Erro do sistema', MB_OK + MB_ICONERROR);
    Result := False;
  end
  else
    Result := True;
end;
{$ENDREGION}

end.

