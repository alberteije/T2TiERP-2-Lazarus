{*******************************************************************************
Title: T2TiPDV
Description: Lista as NFC-e.

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
           alberteije@gmail.com

@author T2Ti.COM
@version 1.0
*******************************************************************************}
unit UListaNfce;

{$mode objfpc}{$H+}

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Grids, DBGrids, StdCtrls, Buttons, ExtCtrls, LabeledCtrls, DB, FMTBcd,
  ZAbstractRODataset, ZAbstractDataset, ZDataset, ACBrBase, ACBrEnterTab, UBase, Tipos;

type
  TCustomDBGridCracker = class(TCustomDBGrid);

  { TFListaNfce }

  TFListaNfce = class(TFBase)
    ACBrEnterTab1: TACBrEnterTab;
    ComboBoxProcedimento: TLabeledComboBox;
    Image1: TImage;
    botaoConfirma: TBitBtn;
    botaoCancela: TBitBtn;
    GridPrincipal: TDBGrid;
    Image2: TImage;
    Panel1: TPanel;
    Label1: TLabel;
    EditLocaliza: TEdit;
    SpeedButton1: TSpeedButton;
    DSNFCe: TDataSource;
    Label2: TLabel;
    procedure botaoCancelaClick(Sender: TObject);
    procedure ComboBoxProcedimentoChange(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormKeyDown(Sender: TObject; var Key: word; Shift: TShiftState);
    procedure Localiza;
    procedure Confirma;
    procedure SpeedButton1Click(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure GridPrincipalKeyDown(Sender: TObject; var Key: word; Shift: TShiftState);
    procedure botaoConfirmaClick(Sender: TObject);
    procedure EditLocalizaKeyDown(Sender: TObject; var Key: word; Shift: TShiftState);
    procedure EditLocalizaKeyUp(Sender: TObject; var Key: word; Shift: TShiftState);

  private
    { Private declarations }
  public
    { Public declarations }
    Operacao: String;
    Confirmou: Boolean;
    QNFCe: TZQuery;
  end;

var
  FListaNfce: TFListaNfce;

implementation

uses UDataModule, VendaController, UCaixa;

{$R *.lfm}

{$REGION 'Infra'}
procedure TFListaNfce.FormActivate(Sender: TObject);
begin
  Color := StringToColor(Sessao.Configuracao.CorJanelasInternas);

  Confirmou := False;

  ComboBoxProcedimento.Clear;
  if Operacao = 'RecuperarVenda' then
  begin
    ComboBoxProcedimento.Items.Add('Recuperar Venda');
  end
  else if Operacao = 'CancelaInutiliza' then
  begin
    ComboBoxProcedimento.Items.Add('Cancelar NFC-e');
    ComboBoxProcedimento.Items.Add('Inutilizar Número');
  end;
  ComboBoxProcedimento.ItemIndex := 0;
end;

procedure TFListaNfce.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  FCaixa.editCodigo.SetFocus;
  CloseAction := caFree;
end;

procedure TFListaNfce.EditLocalizaKeyDown(Sender: TObject; var Key: word; Shift: TShiftState);
begin
  if (Key = VK_RETURN) or (Key = VK_UP) or (Key = VK_DOWN) then
    GridPrincipal.SetFocus;
end;

procedure TFListaNfce.FormKeyDown(Sender: TObject; var Key: word; Shift: TShiftState);
begin
  if Key = VK_F2 then
    Localiza;
  if Key = VK_F12 then
    Confirma;
  if key = VK_ESCAPE then
    botaoCancela.Click;
end;

procedure TFListaNfce.GridPrincipalKeyDown(Sender: TObject; var Key: word; Shift: TShiftState);
begin
  if Key = VK_RETURN then
    EditLocaliza.SetFocus;
end;

procedure TFListaNfce.botaoCancelaClick(Sender: TObject);
begin
  Close;
end;
{$ENDREGION 'Infra'}

{$REGION 'Pesquisa e Confirmação'}
procedure TFListaNfce.SpeedButton1Click(Sender: TObject);
begin
  Localiza;
end;

procedure TFListaNfce.botaoConfirmaClick(Sender: TObject);
begin
  if GridPrincipal.DataSource.DataSet.Active then
  begin
    if GridPrincipal.DataSource.DataSet.RecordCount > 0 then
      Confirma
    else
    begin
      Application.MessageBox('Não existem registros selecionados!', 'Informação do Sistema', MB_OK + MB_ICONINFORMATION);
      EditLocaliza.SetFocus;
    end;
  end
  else
  begin
    Application.MessageBox('Não existem registros selecionados!', 'Informação do Sistema', MB_OK + MB_ICONINFORMATION);
    EditLocaliza.SetFocus;
  end;
end;

procedure TFListaNfce.ComboBoxProcedimentoChange(Sender: TObject);
begin
  if ComboBoxProcedimento.Text <> 'Recuperar Venda' then
    Localiza;
end;

procedure TFListaNfce.Confirma;
begin
  Confirmou := True;
  Close;
end;


procedure TFListaNfce.EditLocalizaKeyUp(Sender: TObject; var Key: word; Shift: TShiftState);
begin
  if Length(trim(EditLocaliza.Text)) > 1 then
    Localiza;
end;

procedure TFListaNfce.localiza;
var
  ProcurePor, Filtro: string;
begin
  ProcurePor := '%' + EditLocaliza.Text + '%';

  if ComboBoxProcedimento.Text = 'Recuperar Venda' then
    Filtro := 'STATUS_NOTA < 4 AND NUMERO LIKE '+ QuotedStr(ProcurePor)
  else if ComboBoxProcedimento.Text = 'Cancelar NFC-e' then
    Filtro := 'STATUS_NOTA = 4 AND NUMERO LIKE '+ QuotedStr(ProcurePor)
  else if ComboBoxProcedimento.Text = 'Inutilizar Número' then
    Filtro := 'STATUS_NOTA < 4 AND NUMERO LIKE '+ QuotedStr(ProcurePor);

  QNFCe := TVendaController.Consulta(Filtro, '-1');
  QNFCe.Active := True;
  DSNFCe.DataSet := QNFCe;
end;
{$ENDREGION 'Pesquisa e Confirmação'}



end.
