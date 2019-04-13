{ *******************************************************************************
Title: T2Ti ERP
Description: Janela de Cadastro do Grupo do Bem - Módulo Patrimônio

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
unit UPatrimGrupoBem;

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

  { TFPatrimGrupoBem }

  TFPatrimGrupoBem = class(TFTelaCadastro)
    EditNome: TLabeledEdit;
    MemoDescricao: TLabeledMemo;
    BevelEdits: TBevel;
    EditCodigo: TLabeledEdit;
    EditContaAtivoImobilizadoDescricao: TLabeledEdit;
    EditContaAtivoImobilizado: TLabeledEdit;
    EditContaDepreciacaoAcumulada: TLabeledEdit;
    EditContaDepreciacaoAcumuladaDescricao: TLabeledEdit;
    EditContaDespesaDepreciacao: TLabeledEdit;
    EditContaDespesaDepreciacaoDescricao: TLabeledEdit;
    EditCodigoHistorico: TLabeledEdit;
    EditCodigoHistoricoDescricao: TLabeledEdit;
    procedure EditCodigoHistoricoKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure EditContaAtivoImobilizadoKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure EditContaDepreciacaoAcumuladaKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure EditContaDespesaDepreciacaoKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
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
  FPatrimGrupoBem: TFPatrimGrupoBem;

implementation

uses PatrimGrupoBemController, PatrimGrupoBemVO, ContabilContaVO, ContabilContaController,
ContabilHistoricoVO, ContabilHistoricoController;
{$R *.lfm}

{$REGION 'Infra'}
procedure TFPatrimGrupoBem.BotaoConsultarClick(Sender: TObject);
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
    RetornoConsulta := TPatrimGrupoBemController.Consulta(Filtro, IntToStr(Pagina));
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

procedure TFPatrimGrupoBem.BotaoSalvarClick(Sender: TObject);
begin
  inherited;
  BotaoConsultarClick(Sender);
end;

procedure TFPatrimGrupoBem.FormCreate(Sender: TObject);
begin
  ClasseObjetoGridVO := TPatrimGrupoBemVO;
  ObjetoController := TPatrimGrupoBemController.Create;

  inherited;
end;
{$ENDREGION}

{$REGION 'Controles CRUD'}
function TFPatrimGrupoBem.DoInserir: Boolean;
begin
  Result := inherited DoInserir;

  if Result then
  begin
    EditCodigo.SetFocus;
  end;
end;

function TFPatrimGrupoBem.DoEditar: Boolean;
begin
  Result := inherited DoEditar;

  if Result then
  begin
    EditCodigo.SetFocus;
  end;
end;

function TFPatrimGrupoBem.DoExcluir: Boolean;
begin
  if inherited DoExcluir then
  begin
    try
      Result := TPatrimGrupoBemController.Exclui(IdRegistroSelecionado);
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

function TFPatrimGrupoBem.DoSalvar: Boolean;
begin
  Result := inherited DoSalvar;

  if Result then
  begin
    try
      if not Assigned(ObjetoVO) then
        ObjetoVO := TPatrimGrupoBemVO.Create;

      TPatrimGrupoBemVO(ObjetoVO).IdEmpresa := Sessao.Empresa.Id;
      TPatrimGrupoBemVO(ObjetoVO).Codigo := EditCodigo.Text;
      TPatrimGrupoBemVO(ObjetoVO).Nome := EditNome.Text;
      TPatrimGrupoBemVO(ObjetoVO).Descricao := MemoDescricao.Text;
      TPatrimGrupoBemVO(ObjetoVO).ContaAtivoImobilizado := EditContaAtivoImobilizado.Text;
      TPatrimGrupoBemVO(ObjetoVO).DescricaoContaAtivoImobilizado := EditContaAtivoImobilizadoDescricao.Text;
      TPatrimGrupoBemVO(ObjetoVO).ContaDepreciacaoAcumulada := EditContaDepreciacaoAcumulada.Text;
      TPatrimGrupoBemVO(ObjetoVO).DescricaoContaDepreciacaoAcumulada := EditContaDepreciacaoAcumuladaDescricao.Text;
      TPatrimGrupoBemVO(ObjetoVO).ContaDespesaDepreciacao := EditContaDespesaDepreciacao.Text;
      TPatrimGrupoBemVO(ObjetoVO).DescricaoContaDespesaDepreciacao := EditContaDespesaDepreciacaoDescricao.Text;
      TPatrimGrupoBemVO(ObjetoVO).CodigoHistorico := StrToInt(EditCodigoHistorico.Text);
      TPatrimGrupoBemVO(ObjetoVO).DescricaoHistorico := EditCodigoHistoricoDescricao.Text;

      if StatusTela = stInserindo then
      begin
        TPatrimGrupoBemController.Insere(TPatrimGrupoBemVO(ObjetoVO));
      end
      else if StatusTela = stEditando then
      begin
        if TPatrimGrupoBemVO(ObjetoVO).ToJSONString <> StringObjetoOld then
        begin
          TPatrimGrupoBemController.Altera(TPatrimGrupoBemVO(ObjetoVO));
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
procedure TFPatrimGrupoBem.EditCodigoHistoricoKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  Filtro: String;
  ContabilHistoricoVO: TContabilHistoricoVO;
begin
  if Key = VK_F1 then
  begin
  if EditCodigoHistorico.Text <> '' then
  begin
    try
      Filtro := 'ID = ' + QuotedStr(EditCodigoHistorico.Text);
      EditCodigoHistorico.Clear;
      EditCodigoHistoricoDescricao.Clear;

      ContabilHistoricoVO := TContabilHistoricoController.ConsultaObjeto(Filtro);
      if Assigned(ContabilHistoricoVO) then
      begin
        EditCodigoHistorico.Text := IntToStr(ContabilHistoricoVO.Id);
        EditCodigoHistoricoDescricao.Text := ContabilHistoricoVO.Descricao;
      end
      else
      begin
        Exit;
      end;
    finally
      EditCodigo.SetFocus;
    end;
  end
  else
  begin
    EditCodigoHistoricoDescricao.Clear;
  end;
  end;
end;

procedure TFPatrimGrupoBem.EditContaAtivoImobilizadoKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  Filtro: String;
  ContabilContaVO: TContabilContaVO;
begin
    if Key = VK_F1 then
  begin
  if EditContaAtivoImobilizado.Text <> '' then
  begin
    try
      Filtro := 'CLASSIFICACAO = ' + QuotedStr(EditContaAtivoImobilizado.Text);
      EditContaAtivoImobilizado.Clear;
      EditContaAtivoImobilizadoDescricao.Clear;

      ContabilContaVO := TContabilContaController.ConsultaObjeto(Filtro);
      if Assigned(ContabilContaVO) then
      begin
        EditContaAtivoImobilizado.Text := ContabilContaVO.Classificacao;
        EditContaAtivoImobilizadoDescricao.Text := ContabilContaVO.Descricao;
      end
      else
      begin
        Exit;
      end;
    finally
      EditContaDepreciacaoAcumulada.SetFocus;
    end;
  end
  else
  begin
    EditContaAtivoImobilizadoDescricao.Clear;
  end;

  end;
end;

procedure TFPatrimGrupoBem.EditContaDepreciacaoAcumuladaKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  Filtro: String;
  ContabilContaVO: TContabilContaVO;
begin
  if Key = VK_F1 then
  begin
  if EditContaDepreciacaoAcumulada.Text <> '' then
  begin
    try
      Filtro := 'CLASSIFICACAO = ' + QuotedStr(EditContaDepreciacaoAcumulada.Text);
      EditContaDepreciacaoAcumulada.Clear;
      EditContaDepreciacaoAcumuladaDescricao.Clear;

      ContabilContaVO := TContabilContaController.ConsultaObjeto(Filtro);
      if Assigned(ContabilContaVO) then
      begin
        EditContaDepreciacaoAcumulada.Text := ContabilContaVO.Classificacao;
        EditContaDepreciacaoAcumuladaDescricao.Text := ContabilContaVO.Descricao;
      end
      else
      begin
        Exit;
      end;
    finally
      EditContaDespesaDepreciacao.SetFocus;
    end;
  end
  else
  begin
    EditContaDepreciacaoAcumuladaDescricao.Clear;
  end;
  end;
end;

procedure TFPatrimGrupoBem.EditContaDespesaDepreciacaoKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  Filtro: String;
  ContabilContaVO: TContabilContaVO;
begin
  if Key = VK_F1 then
  begin
  if EditContaDespesaDepreciacao.Text <> '' then
  begin
    try
      Filtro := 'CLASSIFICACAO = ' + QuotedStr(EditContaDespesaDepreciacao.Text);
      EditContaDespesaDepreciacao.Clear;
      EditContaDespesaDepreciacaoDescricao.Clear;

      ContabilContaVO := TContabilContaController.ConsultaObjeto(Filtro);
      if Assigned(ContabilContaVO) then
      begin
        EditContaDespesaDepreciacao.Text := ContabilContaVO.Classificacao;
        EditContaDespesaDepreciacaoDescricao.Text := ContabilContaVO.Descricao;
      end
      else
      begin
        Exit;
      end;
    finally
      EditCodigoHistorico.SetFocus;
    end;
  end
  else
  begin
    EditContaDespesaDepreciacaoDescricao.Clear;
  end;

  end;
end;
{$ENDREGION}

{$REGION 'Controle de Grid'}
procedure TFPatrimGrupoBem.GridParaEdits;
var
  IdCabecalho: String;
begin
  inherited;

  if not CDSGrid.IsEmpty then
  begin
    IdCabecalho := IntToStr(IdRegistroSelecionado);
    ObjetoVO := TPatrimGrupoBemController.ConsultaObjeto('ID=' + IdCabecalho);
  end;

  if Assigned(ObjetoVO) then
  begin
    EditCodigo.Text := TPatrimGrupoBemVO(ObjetoVO).Codigo;
    EditNome.Text := TPatrimGrupoBemVO(ObjetoVO).Nome;
    MemoDescricao.Text := TPatrimGrupoBemVO(ObjetoVO).Descricao;
    EditContaAtivoImobilizado.Text := TPatrimGrupoBemVO(ObjetoVO).ContaAtivoImobilizado;
    EditContaDepreciacaoAcumulada.Text := TPatrimGrupoBemVO(ObjetoVO).ContaDepreciacaoAcumulada;
    EditContaDespesaDepreciacao.Text := TPatrimGrupoBemVO(ObjetoVO).ContaDespesaDepreciacao;
    EditCodigoHistorico.Text := IntToStr(TPatrimGrupoBemVO(ObjetoVO).CodigoHistorico);
    EditContaAtivoImobilizadoDescricao.Text := TPatrimGrupoBemVO(ObjetoVO).DescricaoContaAtivoImobilizado;
    EditContaDepreciacaoAcumuladaDescricao.Text := TPatrimGrupoBemVO(ObjetoVO).DescricaoContaDepreciacaoAcumulada;
    EditContaDespesaDepreciacaoDescricao.Text := TPatrimGrupoBemVO(ObjetoVO).DescricaoContaDespesaDepreciacao;
    EditCodigoHistoricoDescricao.Text := TPatrimGrupoBemVO(ObjetoVO).DescricaoHistorico;

    // Serializa o objeto para consultar posteriormente se houve alterações
    FormatSettings.DecimalSeparator := '.';
    StringObjetoOld := ObjetoVO.ToJSONString;
    FormatSettings.DecimalSeparator := ',';
  end;
end;
{$ENDREGION}

end.

