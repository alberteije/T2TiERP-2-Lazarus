{ *******************************************************************************
Title: T2Ti ERP
Description: Janela Cadastro de TalonarioCheque

The MIT License

Copyright: Copyright (C) 2015 T2Ti.COM

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

t2ti.com@gmail.com
@author Albert Eije (T2Ti.COM)
@version 2.0
******************************************************************************* }
unit UTalonarioCheque;

{$MODE Delphi}

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UTelaCadastro, DB, DBClient, Menus, StdCtrls, ExtCtrls, Buttons, Grids,
  DBGrids, JvExDBGrids, JvDBGrid, JvDBUltimGrid, ComCtrls, TalonarioChequeVO,
  TalonarioChequeController, Tipos, Atributos, Constantes, LabeledCtrls, JvToolEdit,
  Mask, JvExMask, JvBaseEdits, Math, StrUtils, Controller, rxdbgrid;

type

  { TFTalonarioCheque }

  TFTalonarioCheque = class(TFTelaCadastro)
    BevelEdits: TBevel;
    BotaoExportar: TSpeedButton;
    BotaoImprimir: TSpeedButton;
    BotaoSair: TSpeedButton;
    BotaoSeparador1: TSpeedButton;
    EditContaCaixa: TLabeledEdit;
    EditTalao: TLabeledEdit;
    EditIdContaCaixa: TLabeledCalcEdit;
    EditNumero: TLabeledCalcEdit;
    ComboboxStatusTalao: TLabeledComboBox;
    Grid: TRxDBGrid;
    PageControl: TPageControl;
    PaginaGrid: TTabSheet;
    PanelFiltroRapido: TPanel;
    PanelGrid: TPanel;
    PanelToolBar: TPanel;
    procedure FormCreate(Sender: TObject);
    procedure EditIdContaCaixaKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);

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
  FTalonarioCheque: TFTalonarioCheque;

implementation

uses ULookup, Biblioteca, UDataModule, ContaCaixaVO, ContaCaixaController;
{$R *.lfm}

{$REGION 'Infra'}
procedure TFTalonarioCheque.FormCreate(Sender: TObject);
begin
  ClasseObjetoGridVO := TTalonarioChequeVO;
  ObjetoController := TTalonarioChequeController.Create;

  inherited;
end;
{$ENDREGION}

{$REGION 'Controles CRUD'}
function TFTalonarioCheque.DoInserir: Boolean;
begin
  Result := inherited DoInserir;

  if Result then
  begin
    EditIdContaCaixa.SetFocus;
  end;
end;

function TFTalonarioCheque.DoEditar: Boolean;
begin
  Result := inherited DoEditar;

  if Result then
  begin
    EditIdContaCaixa.SetFocus;
  end;
end;

function TFTalonarioCheque.DoExcluir: Boolean;
begin
  if inherited DoExcluir then
  begin
    try
      TController.ExecutarMetodo('TalonarioChequeController.TTalonarioChequeController', 'Exclui', [IdRegistroSelecionado], 'DELETE', 'Boolean');
      Result := TController.RetornoBoolean;
    except
      Result := False;
    end;
  end
  else
  begin
    Result := False;
  end;

  if Result then
    TController.ExecutarMetodo('TalonarioChequeController.TTalonarioChequeController', 'Consulta', [Trim(Filtro), Pagina.ToString, False], 'GET', 'Lista');
end;

function TFTalonarioCheque.DoSalvar: Boolean;
begin
  Result := inherited DoSalvar;

  if Result then
  begin
    try
      if not Assigned(ObjetoVO) then
        ObjetoVO := TTalonarioChequeVO.Create;

      TTalonarioChequeVO(ObjetoVO).IdContaCaixa := EditIdContaCaixa.AsInteger;
      TTalonarioChequeVO(ObjetoVO).IdEmpresa := Sessao.Empresa.Id;
      TTalonarioChequeVO(ObjetoVO).Numero := EditNumero.AsInteger;
      TTalonarioChequeVO(ObjetoVO).Talao := EditTalao.Text;
      TTalonarioChequeVO(ObjetoVO).StatusTalao := Copy(ComboboxStatusTalao.Text, 1, 1);

      if StatusTela = stInserindo then
      begin
        TController.ExecutarMetodo('TalonarioChequeController.TTalonarioChequeController', 'Insere', [TTalonarioChequeVO(ObjetoVO)], 'PUT', 'Lista');
      end
      else if StatusTela = stEditando then
      begin
        if TTalonarioChequeVO(ObjetoVO).ToJSONString <> StringObjetoOld then
        begin
          TController.ExecutarMetodo('TalonarioChequeController.TTalonarioChequeController', 'Altera', [TTalonarioChequeVO(ObjetoVO)], 'POST', 'Boolean');
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
procedure TFTalonarioCheque.GridParaEdits;
begin
  inherited;

  if not CDSGrid.IsEmpty then
  begin
    ObjetoVO := TTalonarioChequeVO(TController.BuscarObjeto('TalonarioChequeController.TTalonarioChequeController', 'ConsultaObjeto', ['ID=' + IdRegistroSelecionado.ToString], 'GET'));
  end;

  if Assigned(ObjetoVO) then
  begin
    EditIdContaCaixa.AsInteger := TTalonarioChequeVO(ObjetoVO).IdContaCaixa;
    EditContaCaixa.Text := TTalonarioChequeVO(ObjetoVO).ContaCaixaNome;
    EditTalao.Text := TTalonarioChequeVO(ObjetoVO).Talao;
    EditNumero.AsInteger := TTalonarioChequeVO(ObjetoVO).Numero;
    ComboboxStatusTalao.ItemIndex := AnsiIndexStr(TTalonarioChequeVO(ObjetoVO).StatusTalao, ['N', 'C', 'E', 'U']);

    // Serializa o objeto para consultar posteriormente se houve alterações
    FormatSettings.DecimalSeparator := '.';
    StringObjetoOld := ObjetoVO.ToJSONString;
    FormatSettings.DecimalSeparator := ',';
  end;
end;
{$ENDREGION}

{$REGION 'Campos Transientes '}
procedure TFTalonarioCheque.EditIdContaCaixaKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  Filtro: String;
begin
  if Key = VK_F1 then
  begin
    if EditIdContaCaixa.Value <> 0 then
      Filtro := 'ID = ' + EditIdContaCaixa.Text
    else
      Filtro := 'ID=0';

    try
      EditIdContaCaixa.Clear;
      EditContaCaixa.Clear;
      if not PopulaCamposTransientes(Filtro, TContaCaixaVO, TContaCaixaController) then
        PopulaCamposTransientesLookup(TContaCaixaVO, TContaCaixaController);
      if CDSTransiente.RecordCount > 0 then
      begin
        EditIdContaCaixa.Text := CDSTransiente.FieldByName('ID').AsString;
        EditContaCaixa.Text := CDSTransiente.FieldByName('NOME').AsString;
      end
      else
      begin
        Exit;
        EditIdContaCaixa.SetFocus;
      end;
    finally
      CDSTransiente.Close;
    end;
  end;
end;
{$ENDREGION}

end.
