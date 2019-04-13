{ *******************************************************************************
Title: T2Ti ERP
Description: Janela Vale Transporte para o módulo Folha de Pagamento

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

unit UFolhaValeTransporte;

{$MODE Delphi}

interface

uses
  BrookHTTPClient, BrookFCLHTTPClientBroker, BrookHTTPUtils, BrookUtils, FPJson, ZDataset,
  LCLIntf, LCLType, LMessages, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UTelaCadastro, Menus, StdCtrls, ExtCtrls, Buttons, Grids, DBGrids,
  ComCtrls, LabeledCtrls, rxdbgrid, rxtoolbar, DBCtrls, StrUtils,
  Math, Constantes, CheckLst, ActnList, ToolWin, db, BufDataset, Biblioteca,
  ULookup, VO, FolhaValeTransporteVO,
  FolhaValeTransporteController;

  type

  TFFolhaValeTransporte = class(TFTelaCadastro)
    BevelEdits: TBevel;
    EditIdColaborador: TLabeledCalcEdit;
    EditColaborador: TLabeledEdit;
    EditIdItinerario: TLabeledCalcEdit;
    EditItinerario: TLabeledEdit;
    EditQuantidade: TLabeledCalcEdit;
    procedure FormCreate(Sender: TObject);
    procedure EditIdColaboradorKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure EditIdItinerarioKeyUp(Sender: TObject; var Key: Word;
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
  FFolhaValeTransporte: TFFolhaValeTransporte;

implementation

uses ViewPessoaColaboradorVO, ViewPessoaColaboradorController, EmpresaTransporteItinerarioVO,
EmpresaTransporteItinerarioController;

{$R *.lfm}

{$REGION 'Controles Infra'}
procedure TFFolhaValeTransporte.BotaoConsultarClick(Sender: TObject);
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
    RetornoConsulta := TFolhaValeTransporteController.Consulta(Filtro, IntToStr(Pagina));
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

procedure TFFolhaValeTransporte.BotaoSalvarClick(Sender: TObject);
begin
  inherited;
  BotaoConsultarClick(Sender);
end;

procedure TFFolhaValeTransporte.FormCreate(Sender: TObject);
begin
  ClasseObjetoGridVO := TFolhaValeTransporteVO;
  ObjetoController := TFolhaValeTransporteController.Create;

  inherited;
  BotaoImprimir.Visible := False;
  MenuImprimir.Visible := False;
end;
{$ENDREGION}

{$REGION 'Controles CRUD'}
function TFFolhaValeTransporte.DoInserir: Boolean;
begin
  Result := inherited DoInserir;

  if Result then
  begin
    EditIdColaborador.SetFocus;
  end;
end;

function TFFolhaValeTransporte.DoEditar: Boolean;
begin
  Result := inherited DoEditar;

  if Result then
  begin
    EditIdColaborador.SetFocus;
  end;
end;

function TFFolhaValeTransporte.DoExcluir: Boolean;
begin
  if inherited DoExcluir then
  begin
    try
      Result := TFolhaValeTransporteController.Exclui(IdRegistroSelecionado);
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

function TFFolhaValeTransporte.DoSalvar: Boolean;
begin
  Result := inherited DoSalvar;

  if Result then
  begin
    try
      if not Assigned(ObjetoVO) then
        ObjetoVO := TFolhaValeTransporteVO.Create;

      TFolhaValeTransporteVO(ObjetoVO).IdColaborador := EditIdColaborador.AsInteger;
      TFolhaValeTransporteVO(ObjetoVO).ColaboradorNome := EditColaborador.Text;
      TFolhaValeTransporteVO(ObjetoVO).IdEmpresaTranspItin := EditIdItinerario.AsInteger;
      TFolhaValeTransporteVO(ObjetoVO).EmpresaTransporteItinerarioNome := EditItinerario.Text;
      TFolhaValeTransporteVO(ObjetoVO).Quantidade := EditQuantidade.AsInteger;

      if StatusTela = stInserindo then
      begin
        TFolhaValeTransporteController.Insere(TFolhaValeTransporteVO(ObjetoVO));
      end
      else if StatusTela = stEditando then
      begin
        if TFolhaValeTransporteVO(ObjetoVO).ToJSONString <> StringObjetoOld then
        begin
          TFolhaValeTransporteController.Altera(TFolhaValeTransporteVO(ObjetoVO));
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
procedure TFFolhaValeTransporte.GridParaEdits;
var
  IdCabecalho: String;
begin
  inherited;

  if not CDSGrid.IsEmpty then
  begin
    IdCabecalho := IntToStr(IdRegistroSelecionado);
    ObjetoVO := TFolhaValeTransporteController.ConsultaObjeto('ID=' + IdCabecalho);
  end;

  if Assigned(ObjetoVO) then
  begin
    EditIdColaborador.AsInteger := TFolhaValeTransporteVO(ObjetoVO).IdColaborador;
    EditColaborador.Text := TFolhaValeTransporteVO(ObjetoVO).ColaboradorNome;
    EditIdItinerario.AsInteger := TFolhaValeTransporteVO(ObjetoVO).IdEmpresaTranspItin;
    EditItinerario.Text := TFolhaValeTransporteVO(ObjetoVO).EmpresaTransporteItinerarioNome;
    EditQuantidade.AsInteger := TFolhaValeTransporteVO(ObjetoVO).Quantidade;

    // Serializa o objeto para consultar posteriormente se houve alterações
    FormatSettings.DecimalSeparator := '.';
    StringObjetoOld := ObjetoVO.ToJSONString;
    FormatSettings.DecimalSeparator := ',';
  end;
end;
{$ENDREGION}

{$REGION 'Campos Transientes'}
procedure TFFolhaValeTransporte.EditIdColaboradorKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
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
      EditIdItinerario.SetFocus;
    end;
  end;
end;

procedure TFFolhaValeTransporte.EditIdItinerarioKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  Filtro: String;
  EmpresaTransporteItinerarioVO :TEmpresaTransporteItinerarioVO ;
begin
  if Key = VK_F1 then
  begin
    if EditIdItinerario.Value <> 0 then
      Filtro := 'ID = ' + EditIdItinerario.Text
    else
      Filtro := 'ID=0';

    try
      EditItinerario.Clear;

        EmpresaTransporteItinerarioVO := TEmpresaTransporteItinerarioController.ConsultaObjeto(Filtro);
        if Assigned(EmpresaTransporteItinerarioVO) then
      begin
        EditItinerario.Text := EmpresaTransporteItinerarioVO.Nome;
      end
      else
      begin
        Exit;
      end;
    finally
      EditQuantidade.SetFocus;
    end;
  end;
end;
{$ENDREGION}

end.

