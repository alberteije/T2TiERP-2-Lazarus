{ *******************************************************************************
Title: T2Ti ERP
Description: Janela de Cadastro dos Tipos de Nota Fiscal

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

@author Albert Eije (T2Ti.COM)
@version 2.0
******************************************************************************* }
unit UTipoNotaFiscal;

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

  TFTipoNotaFiscal = class(TFTelaCadastro)
    EditModelo: TLabeledEdit;
    EditNome: TLabeledEdit;
    MemoDescricao: TLabeledMemo;
    BevelEdits: TBevel;
    EditSerie: TLabeledEdit;
    MemoTemplate: TLabeledMemo;
    EditNumeroItens: TLabeledCalcEdit;
    procedure FormCreate(Sender: TObject);
    procedure BotaoConsultarClick(Sender: TObject);
    procedure BotaoSalvarClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    { Public declarations }
    procedure GridParaEdits; override;

    // Controles CRUD
    function DoInserir: Boolean; override;
    function DoEditar: Boolean; override;
    function DoExcluir: Boolean; override;
    function DoSalvar: Boolean; override;
  end;

var
  FTipoNotaFiscal: TFTipoNotaFiscal;

implementation

uses NotaFiscalTipoController, NotaFiscalTipoVO;
{$R *.lfm}

{$REGION 'Infra'}
procedure TFTipoNotaFiscal.BotaoConsultarClick(Sender: TObject);
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
    RetornoConsulta := TNotaFiscalTipoController.Consulta(Filtro, IntToStr(Pagina));
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

procedure TFTipoNotaFiscal.BotaoSalvarClick(Sender: TObject);
begin
  inherited;
  BotaoConsultarClick(Sender);
end;

procedure TFTipoNotaFiscal.FormCreate(Sender: TObject);
begin
  ClasseObjetoGridVO := TNotaFiscalTipoVO;
  ObjetoController := TNotaFiscalTipoController.Create;

  inherited;
end;
{$ENDREGION}

{$REGION 'Controles CRUD'}
function TFTipoNotaFiscal.DoInserir: Boolean;
begin
  Result := inherited DoInserir;

  if Result then
  begin
    EditModelo.SetFocus;
  end;
end;

function TFTipoNotaFiscal.DoEditar: Boolean;
begin
  Result := inherited DoEditar;

  if Result then
  begin
    EditModelo.SetFocus;
  end;
end;

function TFTipoNotaFiscal.DoExcluir: Boolean;
begin
  if inherited DoExcluir then
  begin
    try
      Result := TNotaFiscalTipoController.Exclui(IdRegistroSelecionado);
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

function TFTipoNotaFiscal.DoSalvar: Boolean;
begin
  Result := inherited DoSalvar;

  if Result then
  begin
    try
      if not Assigned(ObjetoVO) then
        ObjetoVO := TNotaFiscalTipoVO.Create;

      TNotaFiscalTipoVO(ObjetoVO).IdEmpresa := Sessao.Empresa.Id;
//      TNotaFiscalTipoVO(ObjetoVO).Modelo := EditModelo.Text;
      TNotaFiscalTipoVO(ObjetoVO).Serie := EditSerie.Text;
//      TNotaFiscalTipoVO(ObjetoVO).NumeroItens := EditNumeroItens.AsInteger;
      TNotaFiscalTipoVO(ObjetoVO).Nome := EditNome.Text;
      TNotaFiscalTipoVO(ObjetoVO).Descricao := MemoDescricao.Text;
//      TNotaFiscalTipoVO(ObjetoVO).Template := MemoTemplate.Text;

      if StatusTela = stInserindo then
      begin
        TNotaFiscalTipoController.Insere(TNotaFiscalTipoVO(ObjetoVO));
      end
      else if StatusTela = stEditando then
      begin
        /// EXERCICIO: Verifique se tem como serializar as listas junto com o objeto para realizar a comparação
        //if TNotaFiscalTipoVO(ObjetoVO).ToJSONString <> StringObjetoOld then
        //begin
          TNotaFiscalTipoController.Altera(TNotaFiscalTipoVO(ObjetoVO));
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
procedure TFTipoNotaFiscal.GridParaEdits;
var
  IdCabecalho: String;
begin
  inherited;

  if not CDSGrid.IsEmpty then
  begin
    IdCabecalho := IntToStr(IdRegistroSelecionado);
    ObjetoVO := TNotaFiscalTipoController.ConsultaObjeto('ID=' + IdCabecalho);
  end;

  if Assigned(ObjetoVO) then
  begin
//    EditModelo.Text := TNotaFiscalTipoVO(ObjetoVO).Modelo;
    EditSerie.Text := TNotaFiscalTipoVO(ObjetoVO).Serie;
//    EditNumeroItens.AsInteger := TNotaFiscalTipoVO(ObjetoVO).NumeroItens;
    EditNome.Text := TNotaFiscalTipoVO(ObjetoVO).Nome;
    MemoDescricao.Text := TNotaFiscalTipoVO(ObjetoVO).Descricao;
//    MemoTemplate.Text := TNotaFiscalTipoVO(ObjetoVO).Template;

    // Serializa o objeto para consultar posteriormente se houve alterações
    FormatSettings.DecimalSeparator := '.';
    StringObjetoOld := ObjetoVO.ToJSONString;
    FormatSettings.DecimalSeparator := ',';

  end;
end;
{$ENDREGION}

end.

