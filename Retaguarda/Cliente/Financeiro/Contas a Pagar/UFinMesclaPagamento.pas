{ *******************************************************************************
Title: T2Ti ERP
Description: Janela para Mesclar Lançamentos

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
unit UFinMesclaPagamento;

{$MODE Delphi}

interface

uses
  BrookHTTPClient, BrookFCLHTTPClientBroker, BrookHTTPUtils, BrookUtils, FPJson, ZDataset,
  LCLIntf, LCLType, LMessages, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UTelaCadastro, Menus, StdCtrls, ExtCtrls, Buttons, Grids, DBGrids,
  ComCtrls, LabeledCtrls, rxdbgrid, rxtoolbar, DBCtrls, StrUtils,
  Math, Constantes, CheckLst, ActnList, ToolWin, db, BufDataset, Biblioteca,
  ULookup, VO, FinChequeEmitidoVO, AdmParametroVO, ViewFinLancamentoPagarVO,
  ViewFinLancamentoPagarController;

  type

  { TFFinMesclaPagamento }

  TFFinMesclaPagamento = class(TFTelaCadastro)
    BevelEdits: TBevel;
    CDSLancamentoSelecionado: TBufDataset;
    PanelMestre: TPanel;
    EditIdFornecedor: TLabeledCalcEdit;
    EditFornecedor: TLabeledEdit;
    EditIdDocumentoOrigem: TLabeledCalcEdit;
    EditDocumentoOrigem: TLabeledEdit;
    ComboBoxPagamentoCompartilhado: TLabeledComboBox;
    EditImagemDocumento: TLabeledEdit;
    EditPrimeiroVencimento: TLabeledDateEdit;
    EditQuantidadeParcelas: TLabeledCalcEdit;
    EditValorAPagar: TLabeledCalcEdit;
    EditValorTotal: TLabeledCalcEdit;
    EditDataLancamento: TLabeledDateEdit;
    EditNumeroDocumento: TLabeledEdit;
    EditIntervalorEntreParcelas: TLabeledCalcEdit;
    PageControlItensLancamento: TPageControl;
    tsLancamentos: TTabSheet;
    PanelItensLancamento: TPanel;
    GridItens: TRxDbGrid;
    PanelTotais: TPanel;
    DSLancamentoSelecionado: TDataSource;
    procedure FormCreate(Sender: TObject);
    procedure CalcularTotais;
    procedure GridCellClick(Column: TColumn);
//    procedure GridDrawColumnCell(Sender: TObject; const Rect: TRect; DataCol: Integer; Column: TColumn; State: TGridDrawState);
    procedure EditIdFornecedorKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure EditIdDocumentoOrigemKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure BotaoConsultarClick(Sender: TObject);
    procedure BotaoSalvarClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }

    // Controles CRUD
    function DoEditar: Boolean; override;
  end;

var
  FFinMesclaPagamento: TFFinMesclaPagamento;
  ChequeEmitido: TFinChequeEmitidoVO;
  SomaCheque: Extended;
  AdmParametroVO: TAdmParametroVO;

implementation

uses
  FinLancamentoPagarVO, FinLancamentoPagarController, FinParcelaPagarVO,
  FinParcelaPagarController, FinTipoPagamentoVO, FinTipoPagamentoController,
  ContaCaixaVO, ContaCaixaController, UTela, USelecionaCheque, UDataModule,
  AdmParametroController, FinDocumentoOrigemVO, FinDocumentoOrigemController,
  ViewPessoaFornecedorVO, ViewPessoaFornecedorController;

{$R *.lfm}

{$REGION 'Infra'}
procedure TFFinMesclaPagamento.BotaoConsultarClick(Sender: TObject);
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
    RetornoConsulta := TFinLancamentoPagarController.Consulta(Filtro, IntToStr(Pagina));
    RetornoConsulta.Active := True;

    RetornoConsulta.GetFieldNames(ListaCampos);

    RetornoConsulta.First;
    while not RetornoConsulta.EOF do begin
      CDSGrid.Append;
      for i := 0 to ListaCampos.Count - 1 do
      begin
        Filtro := ListaCampos[i];
        CDSGrid.FieldByName(ListaCampos[i]).Value := RetornoConsulta.FieldByName(ListaCampos[i]).Value;
      end;
      CDSGrid.Post;
      RetornoConsulta.Next;
    end;
  end;
end;

procedure TFFinMesclaPagamento.BotaoSalvarClick(Sender: TObject);
begin
  inherited;
  BotaoConsultarClick(Sender);
end;

procedure TFFinMesclaPagamento.FormCreate(Sender: TObject);
var
  Filtro: String;
begin
  ClasseObjetoGridVO := TFinLancamentoPagarVO;
  ObjetoController := TFinLancamentoPagarController.Create;

  inherited;

  BotaoInserir.Visible := False;
  BotaoExcluir.Visible := False;
  BotaoAlterar.Caption := 'Mesclar [F3]';

  MenuInserir.Visible := False;
  MenuExcluir.Visible := False;
  MenuAlterar.Caption := 'Mesclar [F3]';

  // Configura a Grid dos itens
  ConfiguraCDSFromVO(CDSLancamentoSelecionado, TViewFinLancamentoPagarVO);
  ConfiguraGridFromVO(GridItens, TViewFinLancamentoPagarVO);
end;
{$ENDREGION}

{$REGION 'Controles CRUD'}
function TFFinMesclaPagamento.DoEditar: Boolean;
var
  Contador: Integer;
  Filtro, FiltroIN: String;
  RetornoConsulta: TZQuery;
  ListaCampos: TStringList;
  I: Integer;
begin
  Contador := 0;

  if not CDSGrid.IsEmpty then
  begin

    CDSGrid.DisableControls;
    CDSGrid.First;
    while not CDSGrid.Eof do
    begin
      if CDSGrid.FieldByName('MesclarPagamento').AsString = 'S' then
      begin
        Inc(Contador);

        if Contador = 1 then
          FiltroIN := '(' + CDSGrid.FieldByName('ID').AsString
        else
          FiltroIN := FiltroIN + ',' + CDSGrid.FieldByName('ID').AsString;
      end;
      CDSGrid.Next;
    end;
    CDSGrid.First;
    CDSGrid.EnableControls;

    if Contador <= 1 then
    begin
      Application.MessageBox('É preciso selecionar mais do que UM lançamento para realizar a mesclagem.', 'Mensagem do Sistema', MB_OK + MB_ICONINFORMATION);
      Exit;
    end;

    FiltroIN := FiltroIN + ')';

    CDSLancamentoSelecionado.Close;
    CDSLancamentoSelecionado.Open;

    Filtro := 'ID_LANCAMENTO_PAGAR in ' + FiltroIN;

    ListaCampos  := TStringList.Create;
    RetornoConsulta := TViewFinLancamentoPagarController.Consulta(Filtro, '0');
    RetornoConsulta.Active := True;

    RetornoConsulta.GetFieldNames(ListaCampos);

    RetornoConsulta.First;
    while not RetornoConsulta.EOF do begin
      CDSLancamentoSelecionado.Append;
      for i := 0 to ListaCampos.Count - 1 do
      begin
        CDSLancamentoSelecionado.FieldByName(ListaCampos[i]).Value := RetornoConsulta.FieldByName(ListaCampos[i]).Value;
      end;
      CDSLancamentoSelecionado.Post;
      RetornoConsulta.Next;
    end;

    CalcularTotais;

    Result := inherited DoEditar;

    if Result then
    begin
      EditIdFornecedor.SetFocus;
    end;

  end;
end;
{$ENDREGION}

{$REGION 'Campos Transientes'}
procedure TFFinMesclaPagamento.EditIdFornecedorKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  Filtro: String;
  ViewPessoaFornecedorVO :TViewPessoaFornecedorVO ;
begin
  if Key = VK_F1 then
  begin
    if EditIdFornecedor.Value <> 0 then
      Filtro := 'ID = ' + EditIdFornecedor.Text
    else
      Filtro := 'ID=0';

    try
      EditFornecedor.Clear;

        ViewPessoaFornecedorVO := TViewPessoaFornecedorController.ConsultaObjeto(Filtro);
        if Assigned(ViewPessoaFornecedorVO) then
      begin
        EditFornecedor.Text := ViewPessoaFornecedorVO.Nome;
      end
      else
      begin
        Exit;
      end;
    finally
      EditIdDocumentoOrigem.SetFocus;
    end;
  end;
end;


procedure TFFinMesclaPagamento.EditIdDocumentoOrigemKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  Filtro: String;
  FinDocumentoOrigemVO :TFinDocumentoOrigemVO ;
begin
  if Key = VK_F1 then
  begin
    if EditIdDocumentoOrigem.Value <> 0 then
      Filtro := 'ID = ' + EditIdDocumentoOrigem.Text
    else
      Filtro := 'ID=0';

    try
      EditDocumentoOrigem.Clear;

        FinDocumentoOrigemVO := TFinDocumentoOrigemController.ConsultaObjeto(Filtro);
        if Assigned(FinDocumentoOrigemVO) then
      begin
        EditDocumentoOrigem.Text := FinDocumentoOrigemVO.SiglaDocumento;
      end
      else
      begin
        Exit;
      end;
    finally
      EditNumeroDocumento.SetFocus;
    end;
  end;
end;

{$ENDREGION}

{$REGION 'Controle de Grid'}
procedure TFFinMesclaPagamento.GridCellClick(Column: TColumn);
begin
  if Column.Index = 1 then
  begin
    if CDSGrid.FieldByName('MESCLADO_PARA').AsInteger > 0 then
    begin
      Application.MessageBox('Procedimento não permitido. Lançamento já mesclado.', 'Mensagem do Sistema', MB_OK + MB_ICONINFORMATION);
      Exit;
    end;

    CDSGrid.Edit;
    if CDSGrid.FieldByName('MesclarPagamento').AsString = '' then
      CDSGrid.FieldByName('MesclarPagamento').AsString := 'S'
    else
      CDSGrid.FieldByName('MesclarPagamento').AsString := '';
    CDSGrid.Post;
  end;
end;
{
procedure TFFinMesclaPagamento.GridDrawColumnCell(Sender: TObject; const Rect: TRect; DataCol: Integer; Column: TColumn; State: TGridDrawState);
var
  lIcone : TBitmap;
  lRect: TRect;
begin
  lRect := Rect;
  lIcone := TBitmap.Create;

  if Column.Index = 0 then
  begin
    if Grid.Columns[0].Width <> 32 then
      Grid.Columns[0].Width := 32;

    try
      if Grid.Columns[1].Field.Value = '' then
      begin
        FDataModule.ImagensCheck.GetBitmap(0, lIcone);
        Grid.Canvas.Draw(Rect.Left+8 ,Rect.Top+1, lIcone);
      end
      else if Grid.Columns[1].Field.Value = 'S' then
      begin
        FDataModule.ImagensCheck.GetBitmap(1, lIcone);
        Grid.Canvas.Draw(Rect.Left+8,Rect.Top+1, lIcone);
      end
    finally
      lIcone.Free;
    end;
  end;
end;
}
{$ENDREGION}

{$REGION 'Actions'}
procedure TFFinMesclaPagamento.CalcularTotais;
var
  Juro, Multa, Desconto, Total, Saldo: Extended;
begin

  /// EXERCICIO: VERIFIQUE SE HÁ A NECESSIDADE DE EXIBIR OS TOTAIS. CORRIJA O QUE FOR NECESSÁRIO NO PROCEDIMENTO E/OU NA VIEW.
  /// EXERCICIO: LEVE EM CONTA NO CALCULO AS PARCELAS JA QUITADAS.

  Juro := 0;
  Multa := 0;
  Desconto := 0;
  Total := 0;
  Saldo := 0;
  //
  CDSLancamentoSelecionado.DisableControls;
  CDSLancamentoSelecionado.First;
  while not CDSLancamentoSelecionado.Eof do
  begin
    Juro := Juro + CDSLancamentoSelecionado.FieldByName('VALOR_JURO').AsFloat;
    Multa := Multa + CDSLancamentoSelecionado.FieldByName('VALOR_MULTA').AsFloat;
    Desconto := Desconto + CDSLancamentoSelecionado.FieldByName('VALOR_DESCONTO').AsFloat;
    Total := Total + CDSLancamentoSelecionado.FieldByName('VALOR_PARCELA').AsFloat;
    CDSLancamentoSelecionado.Next;
  end;
  CDSLancamentoSelecionado.First;
  CDSLancamentoSelecionado.EnableControls;
  //
  PanelTotais.Caption := '|      Juros: ' +  FloatToStrF(Juro, ffCurrency, 15, 2) +
                        '      |      Multa: ' +   FloatToStrF(Multa, ffCurrency, 15, 2) +
                        '      |      Desconto: ' +   FloatToStrF(Desconto, ffCurrency, 15, 2) +
                        '      |      Total Parcelas: ' +   FloatToStrF(Total, ffCurrency, 15, 2) +
                        '      |      Saldo: ' +   FloatToStrF(Total - EditValorAPagar.Value, ffCurrency, 15, 2) + '      |';
end;
{$ENDREGION}

/// EXERCICIO: IMPLEMENTE A PERSISTENCIA DA NOVA PARCELA MESCLADA
/// EXERCICIO: ARMAZENE NO CAMPO MESCLADO_PARA O ID DO NOVO LANÇAMENTO GERADO PARA VINCULAR O HISTORICO DOS LANÇAMENTOS
/// EXERCICIO: DESENHE A JANELA DA MELHOR FORMA POSSÍVEL PARA O USUÁRIO

end.

