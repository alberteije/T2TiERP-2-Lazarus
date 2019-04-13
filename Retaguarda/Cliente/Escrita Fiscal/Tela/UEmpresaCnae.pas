{*******************************************************************************
Title: T2Ti ERP
Description: Janela Cadastro de Empresa Cnae

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
unit UEmpresaCnae;

{$MODE Delphi}

interface

uses
  BrookHTTPClient, BrookFCLHTTPClientBroker, BrookHTTPUtils, BrookUtils, FPJson, ZDataset,
  LCLIntf, LCLType, LMessages, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UTelaCadastro, Menus, StdCtrls, ExtCtrls, Buttons, Grids, DBGrids,
  ComCtrls, LabeledCtrls, rxdbgrid, rxtoolbar, DBCtrls, StrUtils,
  Math, Constantes, CheckLst, ActnList, ToolWin, db, BufDataset, Biblioteca,
  ULookup, VO, EmpresaCnaeVO,
  EmpresaCnaeController;

  type

  TFEmpresaCnae = class(TFTelaCadastro)
    BevelEdits: TBevel;
    EditDescricaoCnae: TLabeledEdit;
    EditEmpresa: TLabeledEdit;
    EditRamoAtividade: TLabeledEdit;
    MemoObjetoSocial: TLabeledMemo;
    ComboBoxPrincipal: TLabeledComboBox;
    EditIdEmpresa: TLabeledCalcEdit;
    EditIdCnae: TLabeledCalcEdit;
    procedure FormCreate(Sender: TObject);
    procedure EditIdEmpresaKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure EditIdCnaeKeyUp(Sender: TObject; var Key: Word;
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
  FEmpresaCnae: TFEmpresaCnae;

implementation

uses ULookup, Biblioteca, UDataModule, CnaeVO, CnaeController,
  EmpresaController, EmpresaVO;
{$R *.lfm}

{$REGION 'Infra'}
procedure TFEmpresaCnae.BotaoConsultarClick(Sender: TObject);
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
    RetornoConsulta := TEmpresaCnaeController.Consulta(Filtro, IntToStr(Pagina));
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

procedure TFEmpresaCnae.BotaoSalvarClick(Sender: TObject);
begin
  inherited;
  BotaoConsultarClick(Sender);
end;

procedure TFEmpresaCnae.FormCreate(Sender: TObject);
begin
  ClasseObjetoGridVO := TEmpresaCnaeVO;
  ObjetoController := TEmpresaCnaeController.Create;

  inherited;
end;
{$ENDREGION}

{$REGION 'Controles CRUD'}
function TFEmpresaCnae.DoInserir: Boolean;
begin
  Result := inherited DoInserir;

  if Result then
  begin
    EditIdEmpresa.SetFocus;
  end;
end;

function TFEmpresaCnae.DoEditar: Boolean;
begin
  Result := inherited DoEditar;

  if Result then
  begin
    EditIdEmpresa.SetFocus;
  end;
end;

function TFEmpresaCnae.DoExcluir: Boolean;
begin
  if inherited DoExcluir then
  begin
    try
      Result := TEmpresaCnaeController.Exclui(IdRegistroSelecionado);
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

function TFEmpresaCnae.DoSalvar: Boolean;
begin
  Result := inherited DoSalvar;

  if Result then
  begin
    try
      if not Assigned(ObjetoVO) then
        ObjetoVO := TEmpresaCnaeVO.Create;

      TEmpresaCnaeVO(ObjetoVO).IdCnae := EditIdCnae.AsInteger;
      //TEmpresaCnaeVO(ObjetoVO).DescricaoCnae := EditDescricaoCnae.Text;
      TEmpresaCnaeVO(ObjetoVO).IdEmpresa := EditIdEmpresa.AsInteger;
      //TEmpresaCnaeVO(ObjetoVO).RazaoSocial := EditEmpresa.Text;
      TEmpresaCnaeVO(ObjetoVO).Principal := Copy(ComboBoxPrincipal.Text, 1, 1);
      TEmpresaCnaeVO(ObjetoVO).RamoAtividade := EditRamoAtividade.Text;
      TEmpresaCnaeVO(ObjetoVO).ObjetoSocial := MemoObjetoSocial.Text;

      if StatusTela = stInserindo then
      begin
        TEmpresaCnaeController.Insere(TEmpresaCnaeVO(ObjetoVO));
      end
      else if StatusTela = stEditando then
      begin
        /// EXERCICIO: Verifique se tem como serializar as listas junto com o objeto para realizar a comparação
        //if TEmpresaCnaeVO(ObjetoVO).ToJSONString <> StringObjetoOld then
        //begin
          TEmpresaCnaeController.Altera(TEmpresaCnaeVO(ObjetoVO));
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
procedure TFEmpresaCnae.GridParaEdits;
var
  IdCabecalho: String;
begin
  inherited;

  if not CDSGrid.IsEmpty then
  begin
    IdCabecalho := IntToStr(IdRegistroSelecionado);
    ObjetoVO := TEmpresaCnaeController.ConsultaObjeto('ID=' + IdCabecalho);
  end;

  if Assigned(ObjetoVO) then
  begin
    EditIdCnae.AsInteger := TEmpresaCnaeVO(ObjetoVO).IdCnae;
//    EditDescricaoCnae.Text := TEmpresaCnaeVO(ObjetoVO).DescricaoCnae;
    EditIdEmpresa.AsInteger := TEmpresaCnaeVO(ObjetoVO).IdEmpresa;
//    EditEmpresa.Text := TEmpresaCnaeVO(ObjetoVO).RazaoSocial;
    ComboBoxPrincipal.ItemIndex := AnsiIndexStr(TEmpresaCnaeVO(ObjetoVO).Principal, ['S', 'N']);
    EditRamoAtividade.Text := TEmpresaCnaeVO(ObjetoVO).RamoAtividade;
    MemoObjetoSocial.Text := TEmpresaCnaeVO(ObjetoVO).ObjetoSocial;

    // Serializa o objeto para consultar posteriormente se houve alterações
    FormatSettings.DecimalSeparator := '.';
    StringObjetoOld := ObjetoVO.ToJSONString;
    FormatSettings.DecimalSeparator := ',';
  end;
end;
{$ENDREGION}

{$REGION 'Campos Transientes'}
procedure TFEmpresaCnae.EditIdCnaeKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  Filtro: String;
begin
  if Key = VK_F1 then
  begin
    if EditIdCnae.Value <> 0 then
      Filtro := 'ID = ' + EditIdCnae.Text
    else
      Filtro := 'ID=0';

    try
      EditIdCnae.Clear;
      EditDescricaoCnae.Clear;

        CnaeVO := TCnaeController.ConsultaObjeto(Filtro);
        if Assigned(CnaeVO) then
      begin
        EditIdCnae.Text := CDSTransiente.FieldByName('ID').AsString;
        EditDescricaoCnae.Text := CDSTransiente.FieldByName('DENOMINACAO').AsString;
      end
      else
      begin
        Exit;
        ComboBoxPrincipal.SetFocus;
      end;
    finally
    end;
  end;
end;

procedure TFEmpresaCnae.EditIdEmpresaKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
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
        EditIdCnae.SetFocus;
      end;
    finally
    end;
  end;
end;
{$ENDREGION}

end.

