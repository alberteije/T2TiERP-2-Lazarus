{*******************************************************************************
Title: T2Ti ERP
Description: Janela Cadastro de Objetivos / Metas para Comissão

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

@author T2Ti
@version 2.0
*******************************************************************************}
unit UComissaoObjetivo;

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
  Dialogs, UTelaCadastro, DB, DBClient, Menus, StdCtrls, ExtCtrls, Buttons, Grids,
  DBGrids, JvExDBGrids, JvDBGrid, JvDBUltimGrid, ComCtrls, ComissaoObjetivoVO,
  ComissaoObjetivoController, Tipos, Atributos, Constantes, LabeledCtrls, Mask,
  JvExMask, JvToolEdit, JvBaseEdits, Controller;

}type
  TFComissaoObjetivo = class(TFTelaCadastro)
    EditCodigo: TLabeledEdit;
    EditPerfil: TLabeledEdit;
    EditNome: TLabeledEdit;
    BevelEdits: TBevel;
    MemoDescricao: TLabeledMemo;
    EditIdPerfil: TLabeledCalcEdit;
    EditIdProduto: TLabeledCalcEdit;
    EditProduto: TLabeledEdit;
    ComboboxFormaPagamento: TLabeledComboBox;
    EditTaxaPagamento: TLabeledCalcEdit;
    EditValorPagamento: TLabeledCalcEdit;
    EditValorMeta: TLabeledCalcEdit;
    EditQuantidade: TLabeledCalcEdit;
    procedure FormCreate(Sender: TObject);
    procedure EditIdPerfilKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure EditIdProdutoKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
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
  FComissaoObjetivo: TFComissaoObjetivo;

implementation

uses ULookup, Biblioteca, ComissaoPerfilVO, ComissaoPerfilController,
ProdutoVO, ProdutoController;
{$R *.dfm}

{$REGION 'Infra'}
procedure TFComissaoObjetivo.BotaoConsultarClick(Sender: TObject);
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
    RetornoConsulta := TComissaoObjetivoController.Consulta(Filtro, IntToStr(Pagina));
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

procedure TFComissaoObjetivo.BotaoSalvarClick(Sender: TObject);
begin
  inherited;
  BotaoConsultarClick(Sender);
end;

procedure TFComissaoObjetivo.FormCreate(Sender: TObject);
begin
  ClasseObjetoGridVO := TComissaoObjetivoVO;
  ObjetoController := TComissaoObjetivoController.Create;
  inherited;
end;
{$ENDREGION}

{$REGION 'Controles CRUD'}
function TFComissaoObjetivo.DoInserir: Boolean;
begin
  Result := inherited DoInserir;

  if Result then
  begin
    EditCodigo.SetFocus;
  end;
end;

function TFComissaoObjetivo.DoEditar: Boolean;
begin
  Result := inherited DoEditar;

  if Result then
  begin
    EditCodigo.SetFocus;
  end;
end;

function TFComissaoObjetivo.DoExcluir: Boolean;
begin
  if inherited DoExcluir then
  begin
    try
      Result := TComissaoObjetivoController.Exclui(IdRegistroSelecionado);
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

function TFComissaoObjetivo.DoSalvar: Boolean;
begin
  Result := inherited DoSalvar;

  if Result then
  begin
    try
      if not Assigned(ObjetoVO) then
        ObjetoVO := TComissaoObjetivoVO.Create;

      TComissaoObjetivoVO(ObjetoVO).Codigo := EditCodigo.Text;
      TComissaoObjetivoVO(ObjetoVO).IdComissaoPerfil := EditIdPerfil.AsInteger;
      TComissaoObjetivoVO(ObjetoVO).IdProduto := EditIdProduto.AsInteger;
      TComissaoObjetivoVO(ObjetoVO).Nome := EditNome.Text;
      TComissaoObjetivoVO(ObjetoVO).Descricao := MemoDescricao.Text;
      TComissaoObjetivoVO(ObjetoVO).FormaPagamento := IntToStr(ComboboxFormaPagamento.ItemIndex);
      TComissaoObjetivoVO(ObjetoVO).TaxaPagamento := EditTaxaPagamento.Value;
      TComissaoObjetivoVO(ObjetoVO).ValorPagamento := EditValorPagamento.Value;
      TComissaoObjetivoVO(ObjetoVO).ValorMeta := EditValorMeta.Value;
      TComissaoObjetivoVO(ObjetoVO).Quantidade := EditQuantidade.Value;

      if StatusTela = stInserindo then
      begin
        TComissaoObjetivoController.Insere(TComissaoObjetivoVO(ObjetoVO));
      end
      else if StatusTela = stEditando then
      begin
        if TComissaoObjetivoVO(ObjetoVO).ToJSONString <> StringObjetoOld then
        begin
          TComissaoObjetivoController.Altera(TComissaoObjetivoVO(ObjetoVO));
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

{$REGION 'Controles de Grid'}
procedure TFComissaoObjetivo.GridParaEdits;
var
  IdCabecalho: String;
begin
  inherited;

  if not CDSGrid.IsEmpty then
  begin
    IdCabecalho := IntToStr(IdRegistroSelecionado);
    ObjetoVO := TComissaoObjetivoController.ConsultaObjeto('ID=' + IdCabecalho);
  end;

  if Assigned(ObjetoVO) then
  begin
    EditCodigo.Text := TComissaoObjetivoVO(ObjetoVO).Codigo;
    EditIdPerfil.AsInteger := TComissaoObjetivoVO(ObjetoVO).IdComissaoPerfil;
    EditIdProduto.AsInteger := TComissaoObjetivoVO(ObjetoVO).IdProduto;
    EditNome.Text := TComissaoObjetivoVO(ObjetoVO).Nome;
    MemoDescricao.Text := TComissaoObjetivoVO(ObjetoVO).Descricao;
    ComboboxFormaPagamento.ItemIndex := StrToInt(TComissaoObjetivoVO(ObjetoVO).FormaPagamento);
    EditTaxaPagamento.Value := TComissaoObjetivoVO(ObjetoVO).TaxaPagamento;
    EditValorPagamento.Value := TComissaoObjetivoVO(ObjetoVO).ValorPagamento;
    EditValorMeta.Value := TComissaoObjetivoVO(ObjetoVO).ValorMeta;
    EditQuantidade.Value := TComissaoObjetivoVO(ObjetoVO).Quantidade;

    // Serializa o objeto para consultar posteriormente se houve alterações
    FormatSettings.DecimalSeparator := '.';
    StringObjetoOld := ObjetoVO.ToJSONString;
    FormatSettings.DecimalSeparator := ',';
  end;
end;
{$ENDREGION}

{$REGION 'Campos Transientes'}
procedure TFComissaoObjetivo.EditIdPerfilKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  Filtro: String;
begin
  if Key = VK_F1 then
  begin
    if EditIdPerfil.Value <> 0 then
      Filtro := 'ID = ' + EditIdPerfil.Text
    else
      Filtro := 'ID=0';

    try
      EditIdPerfil.Clear;
      EditPerfil.Clear;

        ComissaoPerfilVO := TComissaoPerfilController.ConsultaObjeto(Filtro);
        if Assigned(ComissaoPerfilVO) then
      begin
        EditIdPerfil.Text := CDSTransiente.FieldByName('ID').AsString;
        EditPerfil.Text := CDSTransiente.FieldByName('NOME').AsString;
      end
      else
      begin
        Exit;
        EditIdProduto.SetFocus;
      end;
    finally
    end;
  end;
end;

procedure TFComissaoObjetivo.EditIdProdutoKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  Filtro: String;
begin
  if Key = VK_F1 then
  begin
    if EditIdProduto.Value <> 0 then
      Filtro := 'ID = ' + EditIdProduto.Text
    else
      Filtro := 'ID=0';

    try
      EditIdProduto.Clear;
      EditProduto.Clear;

        ProdutoVO := TProdutoController.ConsultaObjeto(Filtro);
        if Assigned(ProdutoVO) then
      begin
        EditIdProduto.Text := CDSTransiente.FieldByName('ID').AsString;
        EditProduto.Text := CDSTransiente.FieldByName('NOME').AsString;
      end
      else
      begin
        Exit;
        EditNome.SetFocus;
      end;
    finally
    end;
  end;
end;

{$ENDREGION}

end.

