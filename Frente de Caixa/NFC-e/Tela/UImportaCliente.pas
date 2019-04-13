{*******************************************************************************
Title: T2TiPDV
Description: Pesquisa por cliente e importação para a venda.

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
unit UImportaCliente;

{$mode objfpc}{$H+}

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Grids, DBGrids, StdCtrls, Buttons, ExtCtrls, DB, FMTBcd, ZAbstractRODataset,
  ZAbstractDataset, ZDataset, ACBrBase, ACBrEnterTab, UBase, Tipos;

type

  { TFImportaCliente }

  TFImportaCliente = class(TFBase)
    ACBrEnterTab1: TACBrEnterTab;
    Image1: TImage;
    GridPrincipal: TDBGrid;
    Image2: TImage;
    Panel1: TPanel;
    Label1: TLabel;
    botaoConfirma: TBitBtn;
    botaoCancela: TBitBtn;
    DSCliente: TDataSource;
    EditLocaliza: TEdit;
    SpeedButton1: TSpeedButton;
    Label2: TLabel;
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure Localiza;
    procedure Confirma;
    procedure FormActivate(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure GridPrincipalKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure botaoConfirmaClick(Sender: TObject);
  private
    { Private declarations }
  public
    CpfCnpjPassou, QuemChamou: string;
    IdClientePassou: Integer;
    { Public declarations }
  end;

var
  FImportaCliente: TFImportaCliente;
  QCliente: TZQuery;

implementation

uses
  ViewNfceClienteVO,
  ViewNfceClienteController,
  UCaixa, UIdentificaCliente;
{$R *.lfm}

{$REGION 'Infra'}
procedure TFImportaCliente.FormActivate(Sender: TObject);
begin
  EditLocaliza.SetFocus;
  Color := StringToColor(Sessao.Configuracao.CorJanelasInternas);
end;

procedure TFImportaCliente.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  CloseAction := caFree;
end;


procedure TFImportaCliente.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = 113 then
    Localiza;
  if Key = 123 then
    Confirma;
  if Key = VK_ESCAPE then
    botaoCancela.Click;
end;


procedure TFImportaCliente.GridPrincipalKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = 13 then
    EditLocaliza.SetFocus;
end;
{$ENDREGION 'Infra'}

{$REGION 'Pesquisa e Confirmação'}
procedure TFImportaCliente.botaoConfirmaClick(Sender: TObject);
begin
  Confirma;
end;

procedure TFImportaCliente.Confirma;
begin
  if Sessao.MenuAberto = snNao then
  begin
    if QCliente.FieldByName('CPF').AsString = '' then
      Application.MessageBox('Cliente sem CPF cadastrado.', 'Informação do Sistema', MB_OK + MB_ICONINFORMATION)
    else
    begin
      FIdentificaCliente.editCpfCnpj.Text := QCliente.FieldByName('CPF').AsString;
      FIdentificaCliente.editNome.Text := QCliente.FieldByName('NOME').AsString;
      FIdentificaCliente.editIDCliente.AsInteger:= QCliente.FieldByName('ID').AsInteger;
    end;
  end;
  Close;
end;

procedure TFImportaCliente.Localiza;
var
  ProcurePor, Filtro: string;
begin
  ProcurePor := '%' + EditLocaliza.Text + '%';
  Filtro := 'NOME LIKE ' + QuotedStr(ProcurePor);

  QCliente := TViewNfceClienteController.Consulta(Filtro, '-1');
  QCliente.Active := True;
  DSCliente.DataSet := QCliente;
end;

procedure TFImportaCliente.SpeedButton1Click(Sender: TObject);
begin
  Localiza;
end;
{$ENDREGION 'Pesquisa e Confirmação'}

end.
