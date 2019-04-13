{ *******************************************************************************
Title: T2Ti ERP
Description: Janela Cadastro do Plano de Contas Referencial do SPED

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
unit UPlanoContaRefSped;

{$MODE Delphi}

interface

uses
  BrookHTTPClient, BrookFCLHTTPClientBroker, BrookHTTPUtils, BrookUtils, FPJson, ZDataset,
  LCLIntf, LCLType, LMessages, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UTelaCadastro, Menus, StdCtrls, ExtCtrls, Buttons, Grids, DBGrids,
  ComCtrls, LabeledCtrls, rxdbgrid, rxtoolbar, DBCtrls, StrUtils,
  Math, Constantes, CheckLst, ActnList, ToolWin, db, BufDataset, Biblioteca,
  ULookup, VO, PlanoContaRefSpedVO,
  PlanoContaRefSpedController;

  type

  TFPlanoContaRefSped = class(TFTelaCadastro)
    EditDescricao: TLabeledEdit;
    EditCodCtaRef: TLabeledEdit;
    BevelEdits: TBevel;
    EditInicioValidade: TLabeledDateEdit;
    MemoOrientacoes: TLabeledMemo;
    EditFimValidade: TLabeledDateEdit;
    ComboBoxTipo: TLabeledComboBox;
    procedure FormCreate(Sender: TObject);
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
  FPlanoContaRefSped: TFPlanoContaRefSped;

implementation

uses UDataModule;
{$R *.lfm}

{$REGION 'Controles Infra'}
procedure TFPlanoContaRefSped.BotaoConsultarClick(Sender: TObject);
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
    RetornoConsulta := TPlanoContaRefSpedController.Consulta(Filtro, IntToStr(Pagina));
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

procedure TFPlanoContaRefSped.BotaoSalvarClick(Sender: TObject);
begin
  inherited;
  BotaoConsultarClick(Sender);
end;

procedure TFPlanoContaRefSped.FormCreate(Sender: TObject);
begin
  ClasseObjetoGridVO := TPlanoContaRefSpedVO;
  ObjetoController := TPlanoContaRefSpedController.Create;
  inherited;
  BotaoImprimir.Visible := False;
  MenuImprimir.Visible := False;
end;
{$ENDREGION}

{$REGION 'Controles CRUD'}
function TFPlanoContaRefSped.DoInserir: Boolean;
begin
  Result := inherited DoInserir;

  if Result then
  begin
    EditCodCtaRef.SetFocus;
  end;
end;

function TFPlanoContaRefSped.DoEditar: Boolean;
begin
  Result := inherited DoEditar;

  if Result then
  begin
    EditCodCtaRef.SetFocus;
  end;
end;

function TFPlanoContaRefSped.DoExcluir: Boolean;
begin
  if inherited DoExcluir then
  begin
    try
      Result := TPlanoContaRefSpedController.Exclui(IdRegistroSelecionado);
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

function TFPlanoContaRefSped.DoSalvar: Boolean;
begin
  Result := inherited DoSalvar;

  if Result then
  begin
    try
      ObjetoVO := TPlanoContaRefSpedVO.Create;

      TPlanoContaRefSpedVO(ObjetoVO).CodCtaRef := EditCodCtaRef.Text;
      TPlanoContaRefSpedVO(ObjetoVO).Descricao := EditDescricao.Text;
      TPlanoContaRefSpedVO(ObjetoVO).Orientacoes := MemoOrientacoes.Text;
      TPlanoContaRefSpedVO(ObjetoVO).InicioValidade := EditInicioValidade.Date;
      TPlanoContaRefSpedVO(ObjetoVO).FimValidade := EditFimValidade.Date;
      // S=Sintética | A=Analítica
      TPlanoContaRefSpedVO(ObjetoVO).Tipo := IfThen(ComboBoxTipo.ItemIndex = 0, 'S', 'A');

      if StatusTela = stInserindo then
      begin
        TPlanoContaRefSpedController.Insere(TPlanoContaRefSpedVO(ObjetoVO));
      end
      else if StatusTela = stEditando then
      begin
        if TPlanoContaRefSpedVO(ObjetoVO).ToJSONString <> StringObjetoOld then
        begin
          TPlanoContaRefSpedController.Altera(TPlanoContaRefSpedVO(ObjetoVO));
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

{$REGION 'Controle de Grid'}
procedure TFPlanoContaRefSped.GridParaEdits;
var
  IdCabecalho: String;
begin
  inherited;

  if not CDSGrid.IsEmpty then
  begin
    IdCabecalho := IntToStr(IdRegistroSelecionado);
    ObjetoVO := TPlanoContaRefSpedController.ConsultaObjeto('ID=' + IdCabecalho);
  end;

  if Assigned(ObjetoVO) then
  begin
    EditCodCtaRef.Text := TPlanoContaRefSpedVO(ObjetoVO).CodCtaRef;
    EditDescricao.Text := TPlanoContaRefSpedVO(ObjetoVO).Descricao;
    MemoOrientacoes.Text := TPlanoContaRefSpedVO(ObjetoVO).Orientacoes;
    EditInicioValidade.Date := TPlanoContaRefSpedVO(ObjetoVO).InicioValidade;
    EditFimValidade.Date := TPlanoContaRefSpedVO(ObjetoVO).FimValidade;
    // S=Sintética | A=Analítica
    ComboBoxTipo.ItemIndex := AnsiIndexStr(TPlanoContaRefSpedVO(ObjetoVO).Tipo, ['S', 'A']);

    // Serializa o objeto para consultar posteriormente se houve alterações
    FormatSettings.DecimalSeparator := '.';
    StringObjetoOld := ObjetoVO.ToJSONString;
    FormatSettings.DecimalSeparator := ',';
  end;
end;
{$ENDREGION}

end.

