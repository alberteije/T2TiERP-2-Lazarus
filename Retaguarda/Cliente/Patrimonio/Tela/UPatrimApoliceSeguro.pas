{ *******************************************************************************
Title: T2Ti ERP
Description: Janela de Cadastro das Apólices de Seguro - Patrimônio

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
unit UPatrimApoliceSeguro;

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

  TFPatrimApoliceSeguro = class(TFTelaCadastro)
    BevelEdits: TBevel;
    EditIdBem: TLabeledCalcEdit;
    EditNomeBem: TLabeledEdit;
    EditIdSeguradora: TLabeledCalcEdit;
    EditNomeSeguradora: TLabeledEdit;
    EditDataContratacao: TLabeledDateEdit;
    EditDataVencimento: TLabeledDateEdit;
    EditNumero: TLabeledEdit;
    EditValorPremio: TLabeledCalcEdit;
    EditValorSegurado: TLabeledCalcEdit;
    MemoObservacao: TLabeledMemo;
    ActionManager1: TActionList;
    ActionAcionarGed: TAction;
    ActionToolBar1: TToolPanel;
    procedure FormCreate(Sender: TObject);
    procedure ActionAcionarGedExecute(Sender: TObject);
    procedure EditIdBemKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure EditIdSeguradoraKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
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
  FPatrimApoliceSeguro: TFPatrimApoliceSeguro;

implementation

uses PatrimApoliceSeguroController, PatrimApoliceSeguroVO, SeguradoraVO,
   UDataModule, PatrimBemVO, PatrimBemController, SeguradoraController;
{$R *.lfm}

{$REGION 'Infra'}
procedure TFPatrimApoliceSeguro.BotaoConsultarClick(Sender: TObject);
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
    RetornoConsulta := TPatrimApoliceSeguroController.Consulta(Filtro, IntToStr(Pagina));
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

procedure TFPatrimApoliceSeguro.BotaoSalvarClick(Sender: TObject);
begin
  inherited;
  BotaoConsultarClick(Sender);
end;

procedure TFPatrimApoliceSeguro.FormCreate(Sender: TObject);
begin
  ClasseObjetoGridVO := TPatrimApoliceSeguroVO;
  ObjetoController := TPatrimApoliceSeguroController.Create;

  inherited;
end;
{$ENDREGION}

{$REGION 'Controles CRUD'}
function TFPatrimApoliceSeguro.DoInserir: Boolean;
begin
  Result := inherited DoInserir;

  if Result then
  begin
    EditIdBem.SetFocus;
  end;
end;

function TFPatrimApoliceSeguro.DoEditar: Boolean;
begin
  Result := inherited DoEditar;

  if Result then
  begin
    EditIdBem.SetFocus;
  end;
end;

function TFPatrimApoliceSeguro.DoExcluir: Boolean;
begin
  if inherited DoExcluir then
  begin
    try
      Result := TPatrimApoliceSeguroController.Exclui(IdRegistroSelecionado);
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

function TFPatrimApoliceSeguro.DoSalvar: Boolean;
begin
  Result := inherited DoSalvar;

  if Result then
  begin
    try
      if not Assigned(ObjetoVO) then
        ObjetoVO := TPatrimApoliceSeguroVO.Create;

      TPatrimApoliceSeguroVO(ObjetoVO).IdPatrimBem := EditIdBem.AsInteger;
      TPatrimApoliceSeguroVO(ObjetoVO).PatrimBemNome := EditNomeBem.Text;
      TPatrimApoliceSeguroVO(ObjetoVO).IdSeguradora := EditIdSeguradora.AsInteger;
      TPatrimApoliceSeguroVO(ObjetoVO).SeguradoraNome := EditNomeSeguradora.Text;
      TPatrimApoliceSeguroVO(ObjetoVO).Numero := EditNumero.Text;
      TPatrimApoliceSeguroVO(ObjetoVO).DataContratacao := EditDataContratacao.Date;
      TPatrimApoliceSeguroVO(ObjetoVO).DataVencimento := EditDataVencimento.Date;
      TPatrimApoliceSeguroVO(ObjetoVO).ValorPremio := EditValorPremio.Value;
      TPatrimApoliceSeguroVO(ObjetoVO).ValorSegurado := EditValorSegurado.Value;
      TPatrimApoliceSeguroVO(ObjetoVO).Observacao := MemoObservacao.Text;
      TPatrimApoliceSeguroVO(ObjetoVO).Imagem := 'PATRIMONIO_APOLICE_' + EditNumero.Text;

      if StatusTela = stInserindo then
      begin
        TPatrimApoliceSeguroController.Insere(TPatrimApoliceSeguroVO(ObjetoVO));
      end
      else if StatusTela = stEditando then
      begin
        if TPatrimApoliceSeguroVO(ObjetoVO).ToJSONString <> StringObjetoOld then
        begin
          TPatrimApoliceSeguroController.Altera(TPatrimApoliceSeguroVO(ObjetoVO));
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
procedure TFPatrimApoliceSeguro.EditIdBemKeyUp(Sender: TObject; var Key: Word;  Shift: TShiftState);
var
  Filtro: String;
  PatrimBemVO: TPatrimBemVO;
begin
  if Key = VK_F1 then
  begin
    if EditIdBem.Value <> 0 then
      Filtro := 'ID = ' + EditIdBem.Text
    else
      Filtro := 'ID=0';

    try
      EditIdBem.Clear;
      EditNomeBem.Clear;

      PatrimBemVO := TPatrimBemController.ConsultaObjeto(Filtro);
      if Assigned(PatrimBemVO) then
      begin
        EditNomeBem.Text := PatrimBemVO.Nome;
      end
      else
      begin
        Exit;
      end;
    finally
      EditIdSeguradora.SetFocus;
    end;
  end;
end;

procedure TFPatrimApoliceSeguro.EditIdSeguradoraKeyUp(Sender: TObject;  var Key: Word; Shift: TShiftState);
var
  Filtro: String;
  SeguradoraVO: TSeguradoraVO;
begin
  if Key = VK_F1 then
  begin
    if EditIdSeguradora.Value <> 0 then
      Filtro := 'ID = ' + EditIdSeguradora.Text
    else
      Filtro := 'ID=0';

    try
      EditIdSeguradora.Clear;
      EditNomeSeguradora.Clear;

      SeguradoraVO := TSeguradoraController.ConsultaObjeto(Filtro);
      if Assigned(SeguradoraVO) then
      begin
        EditNomeSeguradora.Text := SeguradoraVO.Nome;
      end
      else
      begin
        Exit;
      end;
    finally
      EditNumero.SetFocus;
    end;
  end;
end;
{$ENDREGION}

{$REGION 'Controle de Grid'}
procedure TFPatrimApoliceSeguro.GridParaEdits;
var
  IdCabecalho: String;
begin
  inherited;

  if not CDSGrid.IsEmpty then
  begin
    IdCabecalho := IntToStr(IdRegistroSelecionado);
    ObjetoVO := TPatrimApoliceSeguroController.ConsultaObjeto('ID=' + IdCabecalho);
  end;

  if Assigned(ObjetoVO) then
  begin
    EditIdBem.AsInteger := TPatrimApoliceSeguroVO(ObjetoVO).IdPatrimBem;
    EditNomeBem.Text := TPatrimApoliceSeguroVO(ObjetoVO).PatrimBemNome;
    EditIdSeguradora.AsInteger := TPatrimApoliceSeguroVO(ObjetoVO).IdSeguradora;
    EditNomeSeguradora.Text := TPatrimApoliceSeguroVO(ObjetoVO).SeguradoraNome;
    EditNumero.Text := TPatrimApoliceSeguroVO(ObjetoVO).Numero;
    EditDataContratacao.Date := TPatrimApoliceSeguroVO(ObjetoVO).DataContratacao;
    EditDataVencimento.Date := TPatrimApoliceSeguroVO(ObjetoVO).DataVencimento;
    EditValorPremio.Value := TPatrimApoliceSeguroVO(ObjetoVO).ValorPremio;
    EditValorSegurado.Value := TPatrimApoliceSeguroVO(ObjetoVO).ValorSegurado;
    MemoObservacao.Text := TPatrimApoliceSeguroVO(ObjetoVO).Observacao;

    // Serializa o objeto para consultar posteriormente se houve alterações
    FormatSettings.DecimalSeparator := '.';
    StringObjetoOld := ObjetoVO.ToJSONString;
    FormatSettings.DecimalSeparator := ',';
  end;
end;
{$ENDREGION}

{$REGION 'Actions'}
procedure TFPatrimApoliceSeguro.ActionAcionarGedExecute(Sender: TObject);
var
  Parametros: String;
begin
  if EditNumero.Text <> '' then
  begin
    {
      Parametros
      1 - Login
      2 - Senha
      3 - Aplicação que chamou
      4 - Nome do arquivo (Aplicacao que chamou + Tela que chamou + Numero Apólice
      }

    try
      Parametros := Sessao.Usuario.Login + ' ' +
                    Sessao.Usuario.Senha + ' ' +
                    'PATRIMONIO' + ' ' +
                    'PATRIMONIO_APOLICE_' + EditNumero.Text;
       OpenDocument('T2TiERPGed.exe'); /// EXERCICIO: Chame o GED e passe os parâmetros acima para que ele armazene o documento
    except
      Application.MessageBox('Erro ao tentar executar o módulo.', 'Erro do Sistema', MB_OK + MB_ICONERROR);
    end;
  end
  else
  begin
    Application.MessageBox('É preciso informar o número da apólice.', 'Mensagem do Sistema', MB_OK + MB_ICONINFORMATION);
    EditNumero.SetFocus;
  end;
end;
{$ENDREGION}

end.

