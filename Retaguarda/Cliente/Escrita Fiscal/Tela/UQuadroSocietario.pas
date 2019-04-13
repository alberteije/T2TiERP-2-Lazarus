{*******************************************************************************
Title: T2Ti ERP
Description: Janela Cadastro de Quadro Societário

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
*******************************************************************************}
unit UQuadroSocietario;

{$MODE Delphi}

interface

uses
  BrookHTTPClient, BrookFCLHTTPClientBroker, BrookHTTPUtils, BrookUtils, FPJson, ZDataset,
  LCLIntf, LCLType, LMessages, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UTelaCadastro, Menus, StdCtrls, ExtCtrls, Buttons, Grids, DBGrids,
  ComCtrls, LabeledCtrls, rxdbgrid, rxtoolbar, DBCtrls, StrUtils,
  Math, Constantes, CheckLst, ActnList, ToolWin, db, BufDataset, Biblioteca,
  ULookup, VO, QuadroSocietarioVO,
  QuadroSocietarioController;

  type

  TFQuadroSocietario = class(TFTelaCadastro)
    BevelEdits: TBevel;
    EditDataRegistro: TLabeledDateEdit;
    EditCapitalSocial: TLabeledCalcEdit;
    EditValorQuota: TLabeledCalcEdit;
    EditQuantidadeQuota: TLabeledCalcEdit;
    EditIdEmpresa: TLabeledCalcEdit;
    EditEmpresa: TLabeledEdit;
    procedure FormCreate(Sender: TObject);
    procedure EditIdEmpresaKeyUp(Sender: TObject; var Key: Word;
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
  FQuadroSocietario: TFQuadroSocietario;

implementation

uses ULookup, EmpresaVO, EmpresaController, Biblioteca, UDataModule,
  SessaoUsuario;
{$R *.lfm}

{$REGION 'Infra'}
procedure TFQuadroSocietario.BotaoConsultarClick(Sender: TObject);
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
    RetornoConsulta := TQuadroSocietarioController.Consulta(Filtro, IntToStr(Pagina));
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

procedure TFQuadroSocietario.BotaoSalvarClick(Sender: TObject);
begin
  inherited;
  BotaoConsultarClick(Sender);
end;

procedure TFQuadroSocietario.FormCreate(Sender: TObject);
begin
  ClasseObjetoGridVO := TQuadroSocietarioVO;
  ObjetoController := TQuadroSocietarioController.Create;

  inherited;
end;
{$ENDREGION}

{$REGION 'Controles CRUD'}
function TFQuadroSocietario.DoInserir: Boolean;
begin
  Result := inherited DoInserir;

  if Result then
  begin
    EditIdEmpresa.SetFocus;
  end;
end;

function TFQuadroSocietario.DoEditar: Boolean;
begin
  Result := inherited DoEditar;

  if Result then
  begin
    EditIdEmpresa.SetFocus;
  end;
end;

function TFQuadroSocietario.DoExcluir: Boolean;
begin
  if inherited DoExcluir then
  begin
    try
      Result := TQuadroSocietarioController.Exclui(IdRegistroSelecionado);
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

function TFQuadroSocietario.DoSalvar: Boolean;
begin
  Result := inherited DoSalvar;

  if Result then
  begin
    try
      if not Assigned(ObjetoVO) then
        ObjetoVO := TQuadroSocietarioVO.Create;

      TQuadroSocietarioVO(ObjetoVO).IdEmpresa := EditIdEmpresa.AsInteger;
      //TQuadroSocietarioVO(ObjetoVO).RazaoSocial := EditEmpresa.Text;
      TQuadroSocietarioVO(ObjetoVO).DataRegistro := EditDataRegistro.Date;
      TQuadroSocietarioVO(ObjetoVO).CapitalSocial := EditCapitalSocial.Value;
      TQuadroSocietarioVO(ObjetoVO).ValorQuota := EditValorQuota.Value;
      TQuadroSocietarioVO(ObjetoVO).QuantidadeCotas := EditQuantidadeQuota.AsInteger;

      if StatusTela = stInserindo then
      begin
        TQuadroSocietarioController.Insere(TQuadroSocietarioVO(ObjetoVO));
      end
      else if StatusTela = stEditando then
      begin
        /// EXERCICIO: Verifique se tem como serializar as listas junto com o objeto para realizar a comparação
        //if TQuadroSocietarioVO(ObjetoVO).ToJSONString <> StringObjetoOld then
        //begin
          TQuadroSocietarioController.Altera(TQuadroSocietarioVO(ObjetoVO));
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

{$REGION 'Controle de GRID'}
procedure TFQuadroSocietario.GridParaEdits;
var
  IdCabecalho: String;
begin
  inherited;

  if not CDSGrid.IsEmpty then
  begin
    IdCabecalho := IntToStr(IdRegistroSelecionado);
    ObjetoVO := TQuadroSocietarioController.ConsultaObjeto('ID=' + IdCabecalho);
  end;

  if Assigned(ObjetoVO) then
  begin
    EditIdEmpresa.AsInteger := TQuadroSocietarioVO(ObjetoVO).IdEmpresa;
    //EditEmpresa.Text := TQuadroSocietarioVO(ObjetoVO).RazaoSocial;
    EditDataRegistro.Date := TQuadroSocietarioVO(ObjetoVO).DataRegistro;
    EditCapitalSocial.Value := TQuadroSocietarioVO(ObjetoVO).CapitalSocial;
    EditValorQuota.Value := TQuadroSocietarioVO(ObjetoVO).ValorQuota;
    EditQuantidadeQuota.AsInteger := TQuadroSocietarioVO(ObjetoVO).QuantidadeCotas;

    // Serializa o objeto para consultar posteriormente se houve alterações
    FormatSettings.DecimalSeparator := '.';
    StringObjetoOld := ObjetoVO.ToJSONString;
    FormatSettings.DecimalSeparator := ',';
  end;
end;
{$ENDREGION}

{$REGION 'Campos transientes'}
procedure TFQuadroSocietario.EditIdEmpresaKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  Filtro: String;
begin
  if Key = VK_F1 then
  begin
    if EditIdEmpresa.Value <> 0 then
      Filtro := 'ID = ' + EditIdEmpresa.Text
    else
      Filtro := 'ID=0';

    try
      EditIdEmpresa.Clear;
      EditEmpresa.Clear;

        EmpresaVO := TEmpresaController.ConsultaObjeto(Filtro);
        if Assigned(EmpresaVO) then
      begin
        EditIdEmpresa.Text := CDSTransiente.FieldByName('ID').AsString;
        EditEmpresa.Text := CDSTransiente.FieldByName('RAZAO_SOCIAL').AsString;
      end
      else
      begin
        Exit;
        EditDataRegistro.SetFocus;
      end;
    finally
    end;
  end;
end;
{$ENDREGION}

end.

