{ *******************************************************************************
Title: T2Ti ERP
Description: Janela Cadastro de Subgrupo de Produtos

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
unit UProdutoSubGrupo;

{$MODE Delphi}

interface

uses
  BrookHTTPClient, BrookFCLHTTPClientBroker, BrookHTTPUtils, BrookUtils, FPJson, ZDataset,
  LCLIntf, LCLType, LMessages, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UTelaCadastro, Menus, StdCtrls, ExtCtrls, Buttons, Grids, DBGrids,
  ComCtrls, LabeledCtrls, rxdbgrid, rxtoolbar, DBCtrls, StrUtils,
  Math, Constantes, CheckLst, ActnList, ToolWin, db, BufDataset, Biblioteca,
  ULookup, VO;
{
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UTelaCadastro, Menus, StdCtrls, ExtCtrls, Buttons, Grids, DBGrids,
  JvExDBGrids, JvDBGrid, JvDBUltimGrid, ComCtrls, LabeledCtrls, Atributos, Constantes,
  Mask, JvExMask, JvToolEdit, JvBaseEdits, Controller;

}type

  TFProdutoSubGrupo = class(TFTelaCadastro)
    EditNome: TLabeledEdit;
    MemoDescricao: TLabeledMemo;
    BevelEdits: TBevel;
    EditGrupoProduto: TLabeledEdit;
    EditIdGrupoProduto: TLabeledCalcEdit;
    procedure FormCreate(Sender: TObject);
    procedure EditIdGrupoProdutoKeyUp(Sender: TObject; var Key: Word;
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
  FProdutoSubGrupo: TFProdutoSubGrupo;

implementation

uses
  ProdutoSubGrupoController, ProdutoSubGrupoVO, ProdutoGrupoController,
  ProdutoGrupoVO, UDataModule;

{$R *.lfm}

{$REGION 'Infra'}
procedure TFProdutoSubGrupo.BotaoConsultarClick(Sender: TObject);
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

procedure TFProdutoSubGrupo.BotaoSalvarClick(Sender: TObject);
begin
  inherited;
  BotaoConsultarClick(Sender);
end;

procedure TFProdutoSubGrupo.FormCreate(Sender: TObject);
begin
  ClasseObjetoGridVO := TProdutoSubGrupoVO;
  ObjetoController := TProdutoSubGrupoController.Create;
  inherited;
end;
{$ENDREGION}

{$REGION 'Controles CRUD'}
function TFProdutoSubGrupo.DoInserir: Boolean;
begin
  Result := inherited DoInserir;

  if Result then
  begin
    EditIdGrupoProduto.SetFocus;
  end;
end;

function TFProdutoSubGrupo.DoEditar: Boolean;
begin
  Result := inherited DoEditar;

  if Result then
  begin
    EditIdGrupoProduto.SetFocus;
  end;
end;

function TFProdutoSubGrupo.DoExcluir: Boolean;
begin
  if inherited DoExcluir then
  begin
    try
      Result := TProdutoSubGrupoController.Exclui(IdRegistroSelecionado);
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

function TFProdutoSubGrupo.DoSalvar: Boolean;
begin
  Result := inherited DoSalvar;

  if Result then
  begin
    try
      if not Assigned(ObjetoVO) then
        ObjetoVO := TProdutoSubGrupoVO.Create;

      TProdutoSubGrupoVO(ObjetoVO).IdGrupo := EditIdGrupoProduto.AsInteger;
      TProdutoSubGrupoVO(ObjetoVO).Nome := EditNome.Text;
      TProdutoSubGrupoVO(ObjetoVO).Descricao := MemoDescricao.Text;

      if StatusTela = stInserindo then
      begin
        TProdutoSubGrupoController.Insere(TProdutoSubGrupoVO(ObjetoVO));
      end
      else if StatusTela = stEditando then
      begin
        /// EXERCICIO: Verifique se tem como serializar as listas junto com o objeto para realizar a comparação
        //if TProdutoSubGrupoVO(ObjetoVO).ToJSONString <> StringObjetoOld then
        //begin
          TProdutoSubGrupoController.Altera(TProdutoSubGrupoVO(ObjetoVO));
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
procedure TFProdutoSubGrupo.GridParaEdits;
var
  IdCabecalho: String;
begin
  inherited;

  if not CDSGrid.IsEmpty then
  begin
    IdCabecalho := IntToStr(IdRegistroSelecionado);
    ObjetoVO := TProdutoSubGrupoController.ConsultaObjeto('ID=' + IdCabecalho);
  end;

  if Assigned(ObjetoVO) then
  begin
    EditIdGrupoProduto.AsInteger := TProdutoSubGrupoVO(ObjetoVO).IdGrupo;
    EditGrupoProduto.Text := TProdutoSubGrupoVO(ObjetoVO).ProdutoGrupoVO.Nome;
    EditNome.Text := TProdutoSubGrupoVO(ObjetoVO).Nome;
    MemoDescricao.Text := TProdutoSubGrupoVO(ObjetoVO).Descricao;

    // Serializa o objeto para consultar posteriormente se houve alterações
    FormatSettings.DecimalSeparator := '.';
    StringObjetoOld := ObjetoVO.ToJSONString;
    FormatSettings.DecimalSeparator := ',';
  end;
end;
{$ENDREGION}

{$REGION 'Campos Transientes'}
procedure TFProdutoSubGrupo.EditIdGrupoProdutoKeyUp(Sender: TObject;  var Key: Word; Shift: TShiftState);
var
  Filtro: String;
begin
  if Key = VK_F1 then
  begin
    if EditIdGrupoProduto.Value <> 0 then
      Filtro := 'ID = ' + EditIdGrupoProduto.Text
    else
      Filtro := 'ID=0';

    try
      EditIdGrupoProduto.Clear;
      EditGrupoProduto.Clear;

      //  ProdutoGrupoVO := TProdutoGrupoController.ConsultaObjeto(Filtro);
      //  if Assigned(ProdutoGrupoVO) then
      //begin
      //  EditIdGrupoProduto.Text := CDSTransiente.FieldByName('ID').AsString;
      //  EditGrupoProduto.Text := CDSTransiente.FieldByName('NOME').AsString;
      //end
      //else
      //begin
      //  Exit;
      //  EditIdGrupoProduto.SetFocus;
      //end;
    finally
    end;
  end;
end;
{$ENDREGION}

end.

