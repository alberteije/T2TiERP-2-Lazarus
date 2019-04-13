{ *******************************************************************************
Title: T2Ti ERP
Description: Janela de Cadastro das Operações Fiscais

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

@author Albert Eije
@version 2.0
******************************************************************************* }
unit UTributOperacaoFiscal;

{$MODE Delphi}

interface

uses
  BrookHTTPClient, BrookFCLHTTPClientBroker, BrookHTTPUtils, BrookUtils, FPJson,
  LCLIntf, LCLType, LMessages, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UTelaCadastro, Menus, StdCtrls, ExtCtrls, Buttons, Grids, DBGrids,
  ComCtrls, LabeledCtrls, Constantes, MaskEdit, StrUtils, Biblioteca, VO, ZDataset;

type

  TFTributOperacaoFiscal = class(TFTelaCadastro)
    EditDescricao: TLabeledEdit;
    BevelEdits: TBevel;
    EditCfop: TLabeledCalcEdit;
    EditDescricaoNf: TLabeledEdit;
    MemoObservacao: TLabeledMemo;
    EditCfopDescricao: TLabeledEdit;
    procedure BotaoConsultarClick(Sender: TObject);
    procedure BotaoSalvarClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure EditCfopKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);

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
  FTributOperacaoFiscal: TFTributOperacaoFiscal;

implementation

uses ULookup, TributOperacaoFiscalVO, TributOperacaoFiscalController, CfopVO, CfopController;

{$R *.lfm}

{$REGION 'Infra'}
procedure TFTributOperacaoFiscal.BotaoConsultarClick(Sender: TObject);
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
    RetornoConsulta := TTributOperacaoFiscalController.Consulta(Filtro, IntToStr(Pagina));
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

procedure TFTributOperacaoFiscal.BotaoSalvarClick(Sender: TObject);
begin
  inherited;
  BotaoConsultarClick(Sender);
end;

procedure TFTributOperacaoFiscal.FormCreate(Sender: TObject);
begin
  ClasseObjetoGridVO := TTributOperacaoFiscalVO;
  ObjetoController := TTributOperacaoFiscalController.Create;
  inherited;
end;
{$ENDREGION}

{$REGION 'Controles CRUD'}
function TFTributOperacaoFiscal.DoInserir: Boolean;
begin
  Result := inherited DoInserir;

  if Result then
  begin
    EditCfop.SetFocus;
  end;
end;

function TFTributOperacaoFiscal.DoEditar: Boolean;
begin
  Result := inherited DoEditar;

  if Result then
  begin
    EditCfop.SetFocus;
  end;
end;

function TFTributOperacaoFiscal.DoExcluir: Boolean;
begin
  if inherited DoExcluir then
  begin
    try
      Result := TTributOperacaoFiscalController.Exclui(IdRegistroSelecionado);
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

function TFTributOperacaoFiscal.DoSalvar: Boolean;
begin
  Result := inherited DoSalvar;

  if Result then
  begin
    try
      if not Assigned(ObjetoVO) then
        ObjetoVO := TTributOperacaoFiscalVO.Create;

      TTributOperacaoFiscalVO(ObjetoVO).IdEmpresa := Sessao.Empresa.Id;
      TTributOperacaoFiscalVO(ObjetoVO).Cfop := EditCfop.AsInteger;
      TTributOperacaoFiscalVO(ObjetoVO).Descricao := EditDescricao.Text;
      TTributOperacaoFiscalVO(ObjetoVO).DescricaoNaNf := EditDescricaoNf.Text;
      TTributOperacaoFiscalVO(ObjetoVO).Observacao := MemoObservacao.Text;

      if StatusTela = stInserindo then
      begin
        TTributOperacaoFiscalController.Insere(TTributOperacaoFiscalVO(ObjetoVO));
      end
      else if StatusTela = stEditando then
      begin
        if TTributOperacaoFiscalVO(ObjetoVO).ToJSONString <> StringObjetoOld then
        begin
          TTributOperacaoFiscalController.Altera(TTributOperacaoFiscalVO(ObjetoVO));
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
procedure TFTributOperacaoFiscal.GridParaEdits;
var
  IdCabecalho: String;
begin
  inherited;

  if not CDSGrid.IsEmpty then
  begin
    IdCabecalho := IntToStr(IdRegistroSelecionado);
    ObjetoVO := TTributOperacaoFiscalController.ConsultaObjeto('ID=' + IdCabecalho);
  end;

  if Assigned(ObjetoVO) then
  begin
    EditCfop.AsInteger := TTributOperacaoFiscalVO(ObjetoVO).Cfop;
    EditCfopDescricao.Text := TTributOperacaoFiscalVO(ObjetoVO).CfopDescricao;
    EditDescricao.Text := TTributOperacaoFiscalVO(ObjetoVO).Descricao;
    EditDescricaoNf.Text := TTributOperacaoFiscalVO(ObjetoVO).DescricaoNaNf;
    MemoObservacao.Text := TTributOperacaoFiscalVO(ObjetoVO).Observacao;

    // Serializa o objeto para consultar posteriormente se houve alterações
    FormatSettings.DecimalSeparator := '.';
    StringObjetoOld := ObjetoVO.ToJSONString;
    FormatSettings.DecimalSeparator := ',';
  end;
end;
{$ENDREGION}

{$REGION 'Campos Transientes'}
/// EXERCICIO: Implemente a busca usando o FLookup
procedure TFTributOperacaoFiscal.EditCfopKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  Filtro: String;
  CfopVO: TCfopVO;
begin
  if Key = VK_F1 then
  begin
    if EditCfop.Value <> 0 then
      Filtro := 'CFOP = ' + QuotedStr(EditCfop.Text)
    else
      Filtro := 'CFOP=' + QuotedStr('0000');

    if EditCfop.Value <> 0 then
    begin
      try
        EditCfop.Clear;
        EditCfopDescricao.Clear;

        CfopVO := TCfopController.ConsultaObjeto(Filtro);

        if Assigned(CfopVO) then
        begin
          EditCfopDescricao.Text := CfopVO.Descricao;
          EditDescricao.SetFocus;
        end
        else
        begin
          Application.MessageBox('Nenhum dado encontrado para o critério informado.', 'Mensagem do Sistema', MB_OK + MB_ICONINFORMATION);
          Exit;
          EditCfop.SetFocus;
        end;
      finally
      end;
    end
    else
    begin
      EditCfopDescricao.Clear;
    end;
  end;
end;
{$ENDREGION}

end.
