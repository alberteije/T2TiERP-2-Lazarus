{ *******************************************************************************
Title: T2Ti ERP
Description: Janela Cadastro de Dependentes dos Socios

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
unit USocioDependente;

{$MODE Delphi}

interface

uses
  BrookHTTPClient, BrookFCLHTTPClientBroker, BrookHTTPUtils, BrookUtils, FPJson, ZDataset,
  LCLIntf, LCLType, LMessages, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UTelaCadastro, Menus, StdCtrls, ExtCtrls, Buttons, Grids, DBGrids,
  ComCtrls, LabeledCtrls, rxdbgrid, rxtoolbar, DBCtrls, StrUtils,
  Math, Constantes, CheckLst, ActnList, ToolWin, db, BufDataset, Biblioteca,
  ULookup, VO, TipoRelacionamentoVO,
  TipoRelacionamentoController, SocioVO, SocioController, SocioDependenteVO,
  SocioDependenteController;

  type

  TFSocioDependente = class(TFTelaCadastro)
    BevelEdits: TBevel;
    EditDependente: TLabeledEdit;
    EditIdSocio: TLabeledEdit;
    EditIdRelacionamento: TLabeledEdit;
    EditCPF: TLabeledMaskEdit;
    EditNascimento: TLabeledDateEdit;
    EditInicioDependencia: TLabeledDateEdit;
    EditFimDependencia: TLabeledDateEdit;
    EditSocio: TLabeledEdit;
    EditRelacionamento: TLabeledEdit;
    procedure FormCreate(Sender: TObject);
    procedure EditCPFExit(Sender: TObject);
    procedure EditIdSocioKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure EditIdRelacionamentoKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
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

    function ConsultaCpf(Cpf: String): Boolean;

  end;

var
  FSocioDependente: TFSocioDependente;

implementation

uses ULookup, MunicipioController, MunicipioVO, Biblioteca, UDataModule;

{$R *.lfm}

{$REGION 'Infra'}
procedure TFSocioDependente.BotaoConsultarClick(Sender: TObject);
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
    RetornoConsulta := TSocioDependenteController.Consulta(Filtro, IntToStr(Pagina));
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

procedure TFSocioDependente.BotaoSalvarClick(Sender: TObject);
begin
  inherited;
  BotaoConsultarClick(Sender);
end;

procedure TFSocioDependente.FormCreate(Sender: TObject);
begin
  ClasseObjetoGridVO := TSocioDependenteVO;
  ObjetoController := TSocioDependenteController.Create;

  inherited;
end;

procedure TFSocioDependente.EditCPFExit(Sender: TObject);
begin
  if EditCPF.Text = '' then
    Exit;
  if not validacpf(EditCPF.Text) then
  begin
    Application.MessageBox('Cpf inválido.', 'Mensagem do Sistema', MB_OK + MB_ICONINFORMATION);
    // Mensagem('Cpf inválido.');
    EditCPF.SetFocus;
  end;
  if StatusTela = stInserindo then
  begin
    if ConsultaCpf(EditCPF.Text) then
    begin
      Application.MessageBox('Cpf já cadastrado.', 'Mensagem do Sistema', MB_OK + MB_ICONINFORMATION);
      // Mensagem('Cpf já cadastrado.');
      EditCPF.SetFocus;
    end;
  end;
end;

function TFSocioDependente.ConsultaCpf(Cpf: String): Boolean;
var
  Filtro: String;
begin
  Filtro := 'CPF = ' + Cpf;
  ConfiguraCDSFromVO(FDataModule.CDSLookup, TSocioDependenteVO);

  TSocioDependenteController.SetDataSet(FDataModule.CDSLookup);
    BotaoConsultar.Click;
  try
    if (FDataModule.CDSLookup.FieldByName('ID').AsString <> '') then
      Result := True
    else
      Result := False;
  finally
    FDataModule.CDSLookup.Close;
  end;
end;
{$ENDREGION}

{$REGION 'Controles CRUD'}
function TFSocioDependente.DoInserir: Boolean;
begin
  Result := inherited DoInserir;

  if Result then
  begin
    EditIdSocio.SetFocus;
  end;
end;

function TFSocioDependente.DoEditar: Boolean;
begin
  Result := inherited DoEditar;

  if Result then
  begin
    EditIdSocio.SetFocus;
  end;
end;

function TFSocioDependente.DoExcluir: Boolean;
begin
  if inherited DoExcluir then
  begin
    try
      Result := TSocioDependenteController.Exclui(IdRegistroSelecionado);
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

function TFSocioDependente.DoSalvar: Boolean;
begin
  Result := inherited DoSalvar;

  if Result then
  begin
    try
      if not Assigned(ObjetoVO) then
        ObjetoVO := TSocioDependenteVO.Create;

      TSocioDependenteVO(ObjetoVO).IdSocio := StrToInt(EditIdSocio.Text);
      TSocioDependenteVO(ObjetoVO).IdTipoRelacionamento := StrToInt(EditIdRelacionamento.Text);
      TSocioDependenteVO(ObjetoVO).Nome := EditDependente.Text;
      TSocioDependenteVO(ObjetoVO).Cpf := EditCPF.Text;
      TSocioDependenteVO(ObjetoVO).DataNascimento := EditNascimento.Date;
      TSocioDependenteVO(ObjetoVO).DataInicioDepedencia := EditInicioDependencia.Date;
      TSocioDependenteVO(ObjetoVO).DataFimDependencia := EditFimDependencia.Date;

      if StatusTela = stInserindo then
      begin
        TSocioDependenteController.Insere(TSocioDependenteVO(ObjetoVO));
      end
      else if StatusTela = stEditando then
      begin
        /// EXERCICIO: Verifique se tem como serializar as listas junto com o objeto para realizar a comparação
        //if TSocioVO(ObjetoVO).ToJSONString <> StringObjetoOld then
        //begin
          TSocioDependenteController.Altera(TSocioDependenteVO(ObjetoVO));
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
procedure TFSocioDependente.GridParaEdits;
var
  IdCabecalho: String;
begin
  inherited;

  if not CDSGrid.IsEmpty then
  begin
    IdCabecalho := IntToStr(IdRegistroSelecionado);
    ObjetoVO := TSocioDependenteController.ConsultaObjeto('ID=' + IdCabecalho);
  end;

  if Assigned(ObjetoVO) then
  begin
    EditIdSocio.Text := IntToStr(TSocioDependenteVO(ObjetoVO).IdSocio);
    EditSocio.Text := TSocioDependenteVO(ObjetoVO).Nome;
    EditIdRelacionamento.Text := IntToStr(TSocioDependenteVO(ObjetoVO).IdTipoRelacionamento);
    //EditRelacionamento.Text := TSocioDependenteVO(ObjetoVO).RelacionamentoNome;
    EditDependente.Text := TSocioDependenteVO(ObjetoVO).Nome;
    EditCPF.Text := TSocioDependenteVO(ObjetoVO).Cpf;
    EditNascimento.Date := TSocioDependenteVO(ObjetoVO).DataNascimento;
    EditInicioDependencia.Date := TSocioDependenteVO(ObjetoVO).DataInicioDepedencia;
    EditFimDependencia.Date := TSocioDependenteVO(ObjetoVO).DataFimDependencia;

    // Serializa o objeto para consultar posteriormente se houve alterações
    FormatSettings.DecimalSeparator := '.';
    StringObjetoOld := ObjetoVO.ToJSONString;
    FormatSettings.DecimalSeparator := ',';
  end;
end;
{$ENDREGION}

{$REGION 'Campos Transientes'}
procedure TFSocioDependente.EditIdSocioKeyUp(Sender: TObject; var Key: Word;  Shift: TShiftState);
var
  Filtro: String;
begin
  if Key = VK_F1 then
  begin
    if EditIdSocio.Text <> '' then
      Filtro := 'ID = ' + EditIdSocio.Text
    else
      Filtro := 'ID=0';

    try
      EditIdSocio.Clear;
      EditSocio.Clear;

        SocioVO := TSocioController.ConsultaObjeto(Filtro);
        if Assigned(SocioVO) then
      begin
        EditIdSocio.Text := CDSTransiente.FieldByName('ID').AsString;
        EditSocio.Text := CDSTransiente.FieldByName('NOME').AsString;
      end
      else
      begin
        Exit;
        EditIdRelacionamento.SetFocus;
      end;
    finally
    end;
  end;
end;

procedure TFSocioDependente.EditIdRelacionamentoKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  Filtro: String;
begin
  if Key = VK_F1 then
  begin
    if EditIdRelacionamento.Text <> '' then
      Filtro := 'ID = ' + EditIdRelacionamento.Text
    else
      Filtro := 'ID=0';

    try
      EditIdRelacionamento.Clear;
      EditRelacionamento.Clear;

        TipoRelacionamentoVO := TTipoRelacionamentoController.ConsultaObjeto(Filtro);
        if Assigned(TipoRelacionamentoVO) then
      begin
        EditIdRelacionamento.Text := CDSTransiente.FieldByName('ID').AsString;
        EditRelacionamento.Text := CDSTransiente.FieldByName('NOME').AsString;
      end
      else
      begin
        Exit;
        EditDependente.SetFocus;
      end;
    finally
    end;
  end;
end;
{$ENDREGION}


end.

