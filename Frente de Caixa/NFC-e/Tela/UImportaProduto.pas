{*******************************************************************************
Title: T2TiPDV
Description: Pesquisa por produto e importação para a venda.

The MIT License

Copyright: Copyright (C) 2012 T2Ti.COM

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
unit UImportaProduto;

{$mode objfpc}{$H+}

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Grids, DBGrids, StdCtrls, Buttons, ExtCtrls, DB, FMTBcd,
  ZAbstractRODataset, ZAbstractDataset, ZDataset, ACBrBase, ACBrEnterTab, UBase, Tipos;

type
  TCustomDBGridCracker = class(TCustomDBGrid);

  { TFImportaProduto }

  TFImportaProduto = class(TFBase)
    ACBrEnterTab1: TACBrEnterTab;
    Image1: TImage;
    botaoConfirma: TBitBtn;
    botaoCancela: TBitBtn;
    GridPrincipal: TDBGrid;
    Image2: TImage;
    Panel1: TPanel;
    Label1: TLabel;
    EditLocaliza: TEdit;
    SpeedButton1: TSpeedButton;
    DSProduto: TDataSource;
    Label2: TLabel;
    procedure botaoCancelaClick(Sender: TObject);
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
    QuemChamou: string;
  end;

var
  FImportaProduto: TFImportaProduto;
  QProduto: TZQuery;

implementation

uses UDataModule, ProdutoController, UCaixa;

{$R *.lfm}

{$REGION 'Infra'}
procedure TFImportaProduto.FormActivate(Sender: TObject);
begin
  Color := StringToColor(Sessao.Configuracao.CorJanelasInternas);
end;

procedure TFImportaProduto.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  FCaixa.editCodigo.SetFocus;
  CloseAction := caFree;
end;

procedure TFImportaProduto.EditLocalizaKeyDown(Sender: TObject; var Key: word; Shift: TShiftState);
begin
  if (Key = VK_RETURN) or (Key = VK_UP) or (Key = VK_DOWN) then
    GridPrincipal.SetFocus;
end;

procedure TFImportaProduto.FormKeyDown(Sender: TObject; var Key: word; Shift: TShiftState);
begin
  if Key = VK_F2 then
    Localiza;
  if Key = VK_F12 then
    Confirma;
  if key = VK_ESCAPE then
    botaoCancela.Click;
end;

procedure TFImportaProduto.GridPrincipalKeyDown(Sender: TObject; var Key: word; Shift: TShiftState);
begin
  if Key = VK_RETURN then
    EditLocaliza.SetFocus;
end;

procedure TFImportaProduto.botaoCancelaClick(Sender: TObject);
begin
  Close;
end;
{$ENDREGION 'Infra'}

{$REGION 'Pesquisa e Confirmação'}
procedure TFImportaProduto.SpeedButton1Click(Sender: TObject);
begin
  Localiza;
end;

procedure TFImportaProduto.botaoConfirmaClick(Sender: TObject);
begin
  if GridPrincipal.DataSource.DataSet.Active then
  begin
    if GridPrincipal.DataSource.DataSet.RecordCount > 0 then
      Confirma
    else
    begin
      Application.MessageBox('Não produto para importação!', 'Informação do Sistema', MB_OK + MB_ICONINFORMATION);
      EditLocaliza.SetFocus;
    end;
  end
  else
  begin
    Application.MessageBox('Não produto para importação!', 'Informação do Sistema', MB_OK + MB_ICONINFORMATION);
    EditLocaliza.SetFocus;
  end;
end;

procedure TFImportaProduto.Confirma;
begin
  if QProduto.FieldByName('VALOR_VENDA').AsFloat > 0 then
  begin
    if (Sessao.StatusCaixa = scVendaEmAndamento) then
    begin
      FCaixa.editCodigo.Text := QProduto.FieldByName('ID').AsString;
    end;
    Close;
  end
  else
    Application.MessageBox('Produto não pode ser vendido com valor zerado ou negativo.', 'Informação do Sistema', MB_OK + MB_ICONINFORMATION);
end;


procedure TFImportaProduto.EditLocalizaKeyUp(Sender: TObject; var Key: word; Shift: TShiftState);
begin
  if Length(trim(EditLocaliza.Text)) > 1 then
    Localiza;
end;

procedure TFImportaProduto.localiza;
var
  ProcurePor, Filtro: string;
begin
  ProcurePor := '%' + EditLocaliza.Text + '%';
  Filtro := 'NOME LIKE ' + QuotedStr(ProcurePor);

  QProduto := TProdutoController.Consulta(Filtro, '-1');
  QProduto.Active := True;
  DSproduto.DataSet := QProduto;
end;
{$ENDREGION 'Pesquisa e Confirmação'}



end.
