{ *******************************************************************************
Title: T2Ti ERP
Description: Janela Para Formação de Preços de Produtos

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
unit UFormacaoPreco;

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

  { TFFormacaoPreco }

  TFFormacaoPreco = class(TFTelaCadastro)
    BevelEdits: TBevel;
    CDSFormacaoPreco: TBufDataset;
    DSFormacaoPreco: TDataSource;
    GroupBoxParcelas: TGroupBox;
    GridItens: TRxDbGrid;
    ActionManager: TActionList;
    ActionRealizarCalculos: TAction;
    ActionToolBarEdits: TToolPanel;
    EditIdSubgrupoProduto: TLabeledCalcEdit;
    EditGrupoProduto: TLabeledEdit;
    EditSubGrupoProduto: TLabeledEdit;
    CDSFormacaoPrecoID: TIntegerField;
    CDSFormacaoPrecoNOME: TStringField;
    CDSFormacaoPrecoVALOR_COMPRA: TFloatField;
    CDSFormacaoPrecoVALOR_VENDA: TFloatField;
    CDSFormacaoPrecoMARKUP: TFloatField;
    CDSFormacaoPrecoENCARGOS_SOBRE_VENDA: TFloatField;
    EditEncargos: TLabeledCalcEdit;
    EditMarkup: TLabeledCalcEdit;
    procedure FormCreate(Sender: TObject);
    procedure ActionRealizarCalculosExecute(Sender: TObject);
    procedure BotaoConsultarClick(Sender: TObject);
    procedure BotaoSalvarClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure GridParaEdits; override;
    procedure LimparCampos; override;

    // Controles CRUD
    function DoEditar: Boolean; override;
    function DoSalvar: Boolean; override;
  end;

var
  FFormacaoPreco: TFFormacaoPreco;

implementation

uses UDataModule, ProdutoSubGrupoVO, ProdutoSubGrupoController, ProdutoVO, ProdutoController;
{$R *.lfm}

{$REGION 'Infra'}
procedure TFFormacaoPreco.BotaoConsultarClick(Sender: TObject);
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
    RetornoConsulta := TProdutoSubGrupoController.Consulta(Filtro, IntToStr(Pagina));
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

procedure TFFormacaoPreco.BotaoSalvarClick(Sender: TObject);
begin
  inherited;
  BotaoConsultarClick(Sender);
end;

procedure TFFormacaoPreco.FormCreate(Sender: TObject);
begin
  ClasseObjetoGridVO := TProdutoSubGrupoVO;
  ObjetoController := TProdutoSubGrupoController.Create;

  inherited;

  //configura Dataset
  CDSFormacaoPreco.Close;
  CDSFormacaoPreco.FieldDefs.Clear;

  CDSFormacaoPreco.FieldDefs.add('ID', ftInteger);
  CDSFormacaoPreco.FieldDefs.add('NOME', ftString, 100);
  CDSFormacaoPreco.FieldDefs.add('VALOR_COMPRA', ftFloat);
  CDSFormacaoPreco.FieldDefs.add('VALOR_VENDA', ftFloat);
  CDSFormacaoPreco.FieldDefs.add('MARKUP', ftFloat);
  CDSFormacaoPreco.FieldDefs.add('ENCARGOS_SOBRE_VENDA', ftFloat);
  CDSFormacaoPreco.CreateDataset;
  CDSFormacaoPreco.Open;

  BotaoImprimir.Visible := False;
  BotaoInserir.Visible := False;
  BotaoExcluir.Visible := False;
  BotaoAlterar.Caption := 'Formar Precos [F3]';
  BotaoAlterar.Hint := 'Formar Precos [F3]';
  BotaoAlterar.Width := 120;

  menuImprimir.Visible := False;
  MenuInserir.Visible := False;
  MenuExcluir.Visible := False;
  MenuAlterar.Caption := 'Formar Precos [F3]';
end;

procedure TFFormacaoPreco.LimparCampos;
begin
  inherited;
  CDSFormacaoPreco.Close;
  CDSFormacaoPreco.Open;
end;
{$ENDREGION}

{$REGION 'Controles CRUD'}
function TFFormacaoPreco.DoEditar: Boolean;
begin
  Result := inherited DoEditar;

  if Result then
  begin
    EditIdSubgrupoProduto.SetFocus;
  end;
end;

function TFFormacaoPreco.DoSalvar: Boolean;
var
  ProdutoVO: TProdutoVO;
begin
  Result := inherited DoSalvar;
  if Result then
  begin
    try
      CDSFormacaoPreco.DisableControls;
      CDSFormacaoPreco.First;
      while not CDSFormacaoPreco.Eof do
      begin
        ProdutoVO := TProdutoVO.Create;
        ProdutoVO.Id := CDSFormacaoPreco.FieldByName('ID').AsInteger;
        ProdutoVO.Markup := CDSFormacaoPreco.FieldByName('MARKUP').AsFloat;
        ProdutoVO.ValorVenda := CDSFormacaoPreco.FieldByName('VALOR_VENDA').AsFloat;

        TProdutoController.Altera(ProdutoVO);

        CDSFormacaoPreco.Next;
      end;
      CDSFormacaoPreco.EnableControls;

      Result := True;
    except
      Result := False;
    end;
  end;
end;
{$ENDREGION}

{$REGION 'Controle de Grid'}
procedure TFFormacaoPreco.GridParaEdits;
var
  IdCabecalho: String;
  RetornoConsulta: TZQuery;
  i: integer;
begin
  if not CDSGrid.IsEmpty then
  begin
    IdCabecalho := IntToStr(IdRegistroSelecionado);
    ObjetoVO := TProdutoSubGrupoController.ConsultaObjeto('ID=' + IdCabecalho);
  end;

  if Assigned(ObjetoVO) then
  begin
    EditIdSubgrupoProduto.AsInteger := TProdutoSubGrupoVO(ObjetoVO).Id;
    EditGrupoProduto.Text := TProdutoSubGrupoVO(ObjetoVO).ProdutoGrupoVO.Nome;
    EditSubGrupoProduto.Text := TProdutoSubGrupoVO(ObjetoVO).Nome;

    // Itens
    CDSFormacaoPreco.Close;
    CDSFormacaoPreco.Open;

    RetornoConsulta := TProdutoController.Consulta(Filtro, IntToStr(Pagina));
    RetornoConsulta.Active := True;

    RetornoConsulta.First;
    while not RetornoConsulta.EOF do begin
      CDSFormacaoPreco.Append;

      CDSFormacaoPreco.FieldByName('ID').AsInteger := RetornoConsulta.FieldByName('ID').AsInteger;
      CDSFormacaoPreco.FieldByName('NOME').AsString := RetornoConsulta.FieldByName('NOME').AsString;
      CDSFormacaoPreco.FieldByName('VALOR_COMPRA').AsFloat := RetornoConsulta.FieldByName('VALOR_COMPRA').AsFloat;
      CDSFormacaoPreco.FieldByName('VALOR_VENDA').AsFloat := RetornoConsulta.FieldByName('VALOR_VENDA').AsFloat;
      CDSFormacaoPreco.FieldByName('MARKUP').AsFloat := RetornoConsulta.FieldByName('MARKUP').AsFloat;

      CDSFormacaoPreco.Post;

      RetornoConsulta.Next;
    end;
  end;
end;
{$ENDREGION}

{$REGION 'Actions'}
procedure TFFormacaoPreco.ActionRealizarCalculosExecute(Sender: TObject);
begin
  {
  C = Valor Compra
  E = % de encargos sobre vendas
  M = % markup  sobre o custo
  P = preço de venda

  P = C(1 + M) ÷  (1-E)
  }

  CDSFormacaoPreco.DisableControls;
  CDSFormacaoPreco.First;
  while not CDSFormacaoPreco.Eof do
  begin
    CDSFormacaoPreco.Edit;

    if EditMarkup.Value > 0 then
      CDSFormacaoPreco.FieldByName('MARKUP').AsFloat := EditMarkup.Value;

    if EditEncargos.Value > 0 then
      CDSFormacaoPreco.FieldByName('ENCARGOS_SOBRE_VENDA').AsFloat := EditEncargos.Value;

    CDSFormacaoPreco.FieldByName('VALOR_VENDA').AsFloat := CDSFormacaoPreco.FieldByName('VALOR_COMPRA').AsFloat * (1 + (CDSFormacaoPreco.FieldByName('MARKUP').AsFloat / 100))
                                                    / (1 - (CDSFormacaoPreco.FieldByName('ENCARGOS_SOBRE_VENDA').AsFloat / 100));
    CDSFormacaoPreco.FieldByName('VALOR_VENDA').AsFloat := ArredondaTruncaValor('A', CDSFormacaoPreco.FieldByName('VALOR_VENDA').AsFloat, Constantes.TConstantes.DECIMAIS_VALOR);
    CDSFormacaoPreco.Post;
    CDSFormacaoPreco.Next;
  end;
  CDSFormacaoPreco.First;
  CDSFormacaoPreco.EnableControls;
end;
{$ENDREGION}

/// EXERCICIO
///  Implemente a formação do preço de compra. Tome a formação do preço de venda
///  como base.

end.

