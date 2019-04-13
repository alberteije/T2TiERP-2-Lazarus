{ *******************************************************************************
Title: T2Ti ERP
Description: Janela para Cadastrar Pagamentos Fixos

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

@author Albert Eije (t2ti.com@gmail.com)
@version 2.0
******************************************************************************* }
unit UFinPagamentoFixo;

{$MODE Delphi}

interface

uses
  BrookHTTPClient, BrookFCLHTTPClientBroker, BrookHTTPUtils, BrookUtils, FPJson, ZDataset,
  LCLIntf, LCLType, LMessages, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UTelaCadastro, Menus, StdCtrls, ExtCtrls, Buttons, Grids, DBGrids,
  ComCtrls, LabeledCtrls, rxdbgrid, rxtoolbar, DBCtrls, StrUtils,
  Math, Constantes, CheckLst, ActnList, ToolWin, db, BufDataset, Biblioteca,
  ULookup, VO, AdmParametroVO, FinPagamentoFixoVO,
  FinPagamentoFixoController;

  type

  TFFinPagamentoFixo = class(TFTelaCadastro)
    PanelParcelas: TPanel;
    PanelMestre: TPanel;
    EditIdFornecedor: TLabeledCalcEdit;
    EditFornecedor: TLabeledEdit;
    EditIdDocumentoOrigem: TLabeledCalcEdit;
    EditDocumentoOrigem: TLabeledEdit;
    ComboBoxPagamentoCompartilhado: TLabeledComboBox;
    EditPrimeiroVencimento: TLabeledDateEdit;
    EditQuantidadeParcelas: TLabeledCalcEdit;
    EditValorAPagar: TLabeledCalcEdit;
    EditValorTotal: TLabeledCalcEdit;
    EditDataLancamento: TLabeledDateEdit;
    EditNumeroDocumento: TLabeledEdit;
    EditIntervalorEntreParcelas: TLabeledCalcEdit;
    procedure FormCreate(Sender: TObject);
    procedure EditIdFornecedorKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure EditIdDocumentoOrigemKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
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
  FFinPagamentoFixo: TFFinPagamentoFixo;
  AdmParametroVO: TAdmParametroVO;

implementation

uses UDataModule,
  FinDocumentoOrigemVO, FinDocumentoOrigemController, ViewPessoaFornecedorVO,
  ViewPessoaFornecedorController;
{$R *.lfm}

{$REGION 'Infra'}
procedure TFFinPagamentoFixo.BotaoConsultarClick(Sender: TObject);
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
    RetornoConsulta := TFinPagamentoFixoController.Consulta(Filtro, IntToStr(Pagina));
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

procedure TFFinPagamentoFixo.BotaoSalvarClick(Sender: TObject);
begin
  inherited;
  BotaoConsultarClick(Sender);
end;

procedure TFFinPagamentoFixo.FormCreate(Sender: TObject);
var
  Filtro: String;
begin
  ClasseObjetoGridVO := TFinPagamentoFixoVO;
  ObjetoController := TFinPagamentoFixoController.Create;

  inherited;
end;
{$ENDREGION}

{$REGION 'Controles CRUD'}
function TFFinPagamentoFixo.DoInserir: Boolean;
begin
  Result := inherited DoInserir;

  if Result then
  begin
    EditIdFornecedor.SetFocus;
  end;
end;

function TFFinPagamentoFixo.DoEditar: Boolean;
begin
  Result := inherited DoEditar;

  if Result then
  begin
    EditIdFornecedor.SetFocus;
  end;
end;

function TFFinPagamentoFixo.DoExcluir: Boolean;
begin
  if inherited DoExcluir then
  begin
    try
      Result := TFinPagamentoFixoController.Exclui(IdRegistroSelecionado);
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

function TFFinPagamentoFixo.DoSalvar: Boolean;
begin
  Result := inherited DoSalvar;

  if Result then
  begin
    try
      if not Assigned(ObjetoVO) then
        ObjetoVO := TFinPagamentoFixoVO.Create;

      /// EXERCICIO: IDENTIFIQUE NESSA JANELA QUAIS CAMPOS NÃO FAZEM SENTIDO EM APARECER

      TFinPagamentoFixoVO(ObjetoVO).IdFornecedor := EditIdFornecedor.AsInteger;
      TFinPagamentoFixoVO(ObjetoVO).FornecedorNome := EditFornecedor.Text;
      TFinPagamentoFixoVO(ObjetoVO).IdFinDocumentoOrigem := EditIdDocumentoOrigem.AsInteger;
      TFinPagamentoFixoVO(ObjetoVO).DocumentoOrigemSigla := EditDocumentoOrigem.Text;
      TFinPagamentoFixoVO(ObjetoVO).PagamentoCompartilhado := IfThen(ComboBoxPagamentoCompartilhado.ItemIndex = 0, 'S', 'N');
      TFinPagamentoFixoVO(ObjetoVO).QuantidadeParcela := EditQuantidadeParcelas.AsInteger;
      TFinPagamentoFixoVO(ObjetoVO).ValorTotal := EditValorTotal.Value;
      TFinPagamentoFixoVO(ObjetoVO).ValorAPagar := EditValorAPagar.Value;
      TFinPagamentoFixoVO(ObjetoVO).DataLancamento := EditDataLancamento.Date;
      TFinPagamentoFixoVO(ObjetoVO).NumeroDocumento := EditNumeroDocumento.Text;
      TFinPagamentoFixoVO(ObjetoVO).PrimeiroVencimento := EditPrimeiroVencimento.Date;
      TFinPagamentoFixoVO(ObjetoVO).IntervaloEntreParcelas := EditIntervalorEntreParcelas.AsInteger;

      if StatusTela = stInserindo then
      begin
        TFinPagamentoFixoController.Insere(TFinPagamentoFixoVO(ObjetoVO));
      end
      else if StatusTela = stEditando then
      begin
        if TFinPagamentoFixoVO(ObjetoVO).ToJSONString <> StringObjetoOld then
        begin
          TFinPagamentoFixoController.Altera(TFinPagamentoFixoVO(ObjetoVO));
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

{$REGION 'Campos Transientes'}
procedure TFFinPagamentoFixo.EditIdFornecedorKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
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

procedure TFFinPagamentoFixo.EditIdDocumentoOrigemKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
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
procedure TFFinPagamentoFixo.GridParaEdits;
var
  IdCabecalho: String;
begin
  inherited;

  if not CDSGrid.IsEmpty then
  begin
    IdCabecalho := IntToStr(IdRegistroSelecionado);
    ObjetoVO := TFinPagamentoFixoController.ConsultaObjeto('ID=' + IdCabecalho);
  end;

  if Assigned(ObjetoVO) then
  begin
    EditIdFornecedor.AsInteger := TFinPagamentoFixoVO(ObjetoVO).IdFornecedor;
    EditFornecedor.Text := TFinPagamentoFixoVO(ObjetoVO).FornecedorNome;
    EditIdDocumentoOrigem.AsInteger := TFinPagamentoFixoVO(ObjetoVO).IdFinDocumentoOrigem;
    EditDocumentoOrigem.Text := TFinPagamentoFixoVO(ObjetoVO).DocumentoOrigemSigla;
    ComboBoxPagamentoCompartilhado.ItemIndex := IfThen(TFinPagamentoFixoVO(ObjetoVO).PagamentoCompartilhado = 'S', 0, 1);
    EditQuantidadeParcelas.AsInteger := TFinPagamentoFixoVO(ObjetoVO).QuantidadeParcela;
    EditValorTotal.Value := TFinPagamentoFixoVO(ObjetoVO).ValorTotal;
    EditValorAPagar.Value := TFinPagamentoFixoVO(ObjetoVO).ValorAPagar;
    EditDataLancamento.Date := TFinPagamentoFixoVO(ObjetoVO).DataLancamento;
    EditNumeroDocumento.Text := TFinPagamentoFixoVO(ObjetoVO).NumeroDocumento;
    EditPrimeiroVencimento.Date := TFinPagamentoFixoVO(ObjetoVO).PrimeiroVencimento;
    EditIntervalorEntreParcelas.AsInteger := TFinPagamentoFixoVO(ObjetoVO).IntervaloEntreParcelas;

    // Serializa o objeto para consultar posteriormente se houve alterações
    FormatSettings.DecimalSeparator := '.';
    StringObjetoOld := ObjetoVO.ToJSONString;
    FormatSettings.DecimalSeparator := ',';
  end;
end;
{$ENDREGION}


/// EXERCICIO: IMPLEMENTE A GERAÇÃO DOS LANÇAMENTOS COM BASE NAS INFORMAÇÕES DOS PAGAMENTOS FIXOS
///  01 - UMA JANELA COM UM BOTÃO PARA GERAÇÃO
///  02 - SEMPRE QUE ENTRAR NO SISTEMA FINANCEIRO, UMA ROTINA REALIZA A VERIFICAÇÃO/GERAÇÃO

end.

