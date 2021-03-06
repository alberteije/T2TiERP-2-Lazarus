{ *******************************************************************************
Title: T2Ti ERP
Description: Janela Rescis�o para o m�dulo Folha de Pagamento

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

unit UFolhaRescisao;

{$MODE Delphi}

interface

uses
  BrookHTTPClient, BrookFCLHTTPClientBroker, BrookHTTPUtils, BrookUtils, FPJson, ZDataset,
  LCLIntf, LCLType, LMessages, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UTelaCadastro, Menus, StdCtrls, ExtCtrls, Buttons, Grids, DBGrids,
  ComCtrls, LabeledCtrls, rxdbgrid, rxtoolbar, DBCtrls, StrUtils,
  Math, Constantes, CheckLst, ActnList, ToolWin, db, BufDataset, Biblioteca,
  ULookup, VO, FolhaRescisaoVO, 
  FolhaRescisaoController;

  type

  TFFolhaRescisao = class(TFTelaCadastro)
    BevelEdits: TBevel;
    EditIdColaborador: TLabeledCalcEdit;
    EditColaborador: TLabeledEdit;
    EditDataDemissao: TLabeledDateEdit;
    EditDataPagamento: TLabeledDateEdit;
    EditDiasAvisoPrevio: TLabeledCalcEdit;
    EditDataAvisoPrevio: TLabeledDateEdit;
    ComboBoxComprovouNovoEmprego: TLabeledComboBox;
    ComboBoxDispensouEmpregado: TLabeledComboBox;
    EditMotivo: TLabeledEdit;
    EditPensaoAlimenticia: TLabeledCalcEdit;
    EditPensaoAlimenticiaFgts: TLabeledCalcEdit;
    GroupBox2: TGroupBox;
    EditFgtsValorRescisao: TLabeledCalcEdit;
    EditFgtsSaldoBanco: TLabeledCalcEdit;
    EditFgtsComplementoSaldo: TLabeledCalcEdit;
    EditFgtsCodigoAfastamento: TLabeledEdit;
    EditFgtsCodigoSaque: TLabeledEdit;
    procedure FormCreate(Sender: TObject);
    procedure EditIdColaboradorKeyUp(Sender: TObject; var Key: Word;
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
  FFolhaRescisao: TFFolhaRescisao;

implementation

uses ViewPessoaColaboradorVO, ViewPessoaColaboradorController;

{$R *.lfm}

{$REGION 'Controles Infra'}
procedure TFFolhaRescisao.BotaoConsultarClick(Sender: TObject);
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
    RetornoConsulta := TFolhaRescisaoController.Consulta(Filtro, IntToStr(Pagina));
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

procedure TFFolhaRescisao.BotaoSalvarClick(Sender: TObject);
begin
  inherited;
  BotaoConsultarClick(Sender);
end;

procedure TFFolhaRescisao.FormCreate(Sender: TObject);
begin
  ClasseObjetoGridVO := TFolhaRescisaoVO;
  ObjetoController := TFolhaRescisaoController.Create;

  inherited;
  BotaoImprimir.Visible := False;
  MenuImprimir.Visible := False;
end;
{$ENDREGION}

{$REGION 'Controles CRUD'}
function TFFolhaRescisao.DoInserir: Boolean;
begin
  Result := inherited DoInserir;

  if Result then
  begin
    EditIdColaborador.SetFocus;
  end;
end;

function TFFolhaRescisao.DoEditar: Boolean;
begin
  Result := inherited DoEditar;

  if Result then
  begin
    EditIdColaborador.SetFocus;
  end;
end;

function TFFolhaRescisao.DoExcluir: Boolean;
begin
  if inherited DoExcluir then
  begin
    try
      Result := TFolhaRescisaoController.Exclui(IdRegistroSelecionado);
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

function TFFolhaRescisao.DoSalvar: Boolean;
begin
  Result := inherited DoSalvar;

  if Result then
  begin
    try
      if not Assigned(ObjetoVO) then
        ObjetoVO := TFolhaRescisaoVO.Create;

      TFolhaRescisaoVO(ObjetoVO).IdColaborador := EditIdColaborador.AsInteger;
      TFolhaRescisaoVO(ObjetoVO).ColaboradorNome := EditColaborador.Text;
      TFolhaRescisaoVO(ObjetoVO).DataDemissao := EditDataDemissao.Date;
      TFolhaRescisaoVO(ObjetoVO).DataPagamento := EditDataPagamento.Date;
      TFolhaRescisaoVO(ObjetoVO).Motivo := EditMotivo.Text;
      TFolhaRescisaoVO(ObjetoVO).DataAvisoPrevio := EditDataAvisoPrevio.Date;
      TFolhaRescisaoVO(ObjetoVO).DiasAvisoPrevio := EditDiasAvisoPrevio.AsInteger;
      TFolhaRescisaoVO(ObjetoVO).ComprovouNovoEmprego := IfThen(ComboBoxComprovouNovoEmprego.ItemIndex = 0, 'S', 'N');
      TFolhaRescisaoVO(ObjetoVO).DispensouEmpregado := IfThen(ComboBoxDispensouEmpregado.ItemIndex = 0, 'S', 'N');
      TFolhaRescisaoVO(ObjetoVO).PensaoAlimenticia := EditPensaoAlimenticia.Value;
      TFolhaRescisaoVO(ObjetoVO).PensaoAlimenticiaFgts := EditPensaoAlimenticiaFgts.Value;
      TFolhaRescisaoVO(ObjetoVO).FgtsValorRescisao := EditFgtsValorRescisao.Value;
      TFolhaRescisaoVO(ObjetoVO).FgtsSaldoBanco := EditFgtsSaldoBanco.Value;
      TFolhaRescisaoVO(ObjetoVO).FgtsComplementoSaldo := EditFgtsComplementoSaldo.Value;
      TFolhaRescisaoVO(ObjetoVO).FgtsCodigoAfastamento := EditFgtsCodigoAfastamento.Text;
      TFolhaRescisaoVO(ObjetoVO).FgtsCodigoSaque := EditFgtsCodigoSaque.Text;

      if StatusTela = stInserindo then
      begin
        TFolhaRescisaoController.Insere(TFolhaRescisaoVO(ObjetoVO));
      end
      else if StatusTela = stEditando then
      begin
        if TFolhaRescisaoVO(ObjetoVO).ToJSONString <> StringObjetoOld then
        begin
          TFolhaRescisaoController.Altera(TFolhaRescisaoVO(ObjetoVO));
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
procedure TFFolhaRescisao.GridParaEdits;
var
  IdCabecalho: String;
begin
  inherited;

  if not CDSGrid.IsEmpty then
  begin
    IdCabecalho := IntToStr(IdRegistroSelecionado);
    ObjetoVO := TFolhaRescisaoController.ConsultaObjeto('ID=' + IdCabecalho);
  end;

  if Assigned(ObjetoVO) then
  begin
    EditIdColaborador.AsInteger := TFolhaRescisaoVO(ObjetoVO).IdColaborador;
    EditColaborador.Text := TFolhaRescisaoVO(ObjetoVO).ColaboradorNome;
    EditDataDemissao.Date := TFolhaRescisaoVO(ObjetoVO).DataDemissao;
    EditDataPagamento.Date := TFolhaRescisaoVO(ObjetoVO).DataPagamento;
    EditMotivo.Text := TFolhaRescisaoVO(ObjetoVO).Motivo;
    EditDataAvisoPrevio.Date := TFolhaRescisaoVO(ObjetoVO).DataAvisoPrevio;
    EditDiasAvisoPrevio.AsInteger := TFolhaRescisaoVO(ObjetoVO).DiasAvisoPrevio;
    ComboBoxComprovouNovoEmprego.ItemIndex := AnsiIndexStr(TFolhaRescisaoVO(ObjetoVO).ComprovouNovoEmprego, ['S', 'N']);
    ComboBoxDispensouEmpregado.ItemIndex := AnsiIndexStr(TFolhaRescisaoVO(ObjetoVO).DispensouEmpregado, ['S', 'N']);
    EditPensaoAlimenticia.Value := TFolhaRescisaoVO(ObjetoVO).PensaoAlimenticia;
    EditPensaoAlimenticiaFgts.Value := TFolhaRescisaoVO(ObjetoVO).PensaoAlimenticiaFgts;
    EditFgtsValorRescisao.Value := TFolhaRescisaoVO(ObjetoVO).FgtsValorRescisao;
    EditFgtsSaldoBanco.Value := TFolhaRescisaoVO(ObjetoVO).FgtsSaldoBanco;
    EditFgtsComplementoSaldo.Value := TFolhaRescisaoVO(ObjetoVO).FgtsComplementoSaldo;
    EditFgtsCodigoAfastamento.Text := TFolhaRescisaoVO(ObjetoVO).FgtsCodigoAfastamento;
    EditFgtsCodigoSaque.Text := TFolhaRescisaoVO(ObjetoVO).FgtsCodigoSaque;

    // Serializa o objeto para consultar posteriormente se houve altera��es
    FormatSettings.DecimalSeparator := '.';
    StringObjetoOld := ObjetoVO.ToJSONString;
    FormatSettings.DecimalSeparator := ',';
  end;
end;
{$ENDREGION}

{$REGION 'Campos Transientes'}
procedure TFFolhaRescisao.EditIdColaboradorKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  Filtro: String;
  ViewPessoaColaboradorVO :TViewPessoaColaboradorVO ;
begin
  if Key = VK_F1 then
  begin
    if EditIdColaborador.Value <> 0 then
      Filtro := 'ID = ' + EditIdColaborador.Text
    else
      Filtro := 'ID=0';

    try
      EditColaborador.Clear;

        ViewPessoaColaboradorVO := TViewPessoaColaboradorController.ConsultaObjeto(Filtro);
        if Assigned(ViewPessoaColaboradorVO) then
      begin
        EditColaborador.Text := ViewPessoaColaboradorVO.Nome;
      end
      else
      begin
        Exit;
      end;
    finally
      EditMotivo.SetFocus;
    end;
  end;
end;
{$ENDREGION}

end.

