{*******************************************************************************
Title: T2TiPDV
Description: Janela para cadastros de produtos produzidos pelo estabelecimento.

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
unit UFichaTecnica;

{$mode objfpc}{$H+}

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, Buttons, Grids, DBGrids, FMTBcd, DB, ZDataset,
  ACBrBase, ACBrEnterTab, CurrEdit, UBase;

type

  { TFFichaTecnica }

  TFFichaTecnica = class(TFBase)
    ACBrEnterTab1: TACBrEnterTab;
    botaoConfirma: TBitBtn;
    botaoCancela: TBitBtn;
    Image1: TImage;
    GridPrincipal: TDBGrid;
    Panel2: TPanel;
    GridComposicao: TDBGrid;
    Label2: TLabel;
    Panel3: TPanel;
    Label5: TLabel;
    Panel5: TPanel;
    SpeedButton1: TSpeedButton;
    EditLocaliza: TEdit;
    DSProduto: TDataSource;
    DSComposicao: TDataSource;
    procedure botaoCancelaClick(Sender: TObject);
    procedure botaoConfirmaClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure EditLocalizaKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure DSProdutoDataChange(Sender: TObject; Field: TField);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure SpeedButton1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
  private
    procedure LocalizaPrincipal;
    procedure MostraDados;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FFichaTecnica: TFFichaTecnica;
  QProduto, QComposicao: TZQuery;

implementation

uses UDataModule, FichaTecnicaVO, FichaTecnicaController, ProdutoController;

{$R *.lfm}

procedure TFFichaTecnica.DSProdutoDataChange(Sender: TObject; Field: TField);
begin
  MostraDados;
end;

procedure TFFichaTecnica.MostraDados;
var
  Filtro: String;
begin
  if not (QProduto.IsEmpty) then
  begin
    Filtro := 'ID_PRODUTO = ' + QProduto.FieldByName('ID').AsString;
    QComposicao := TFichaTecnicaController.Consulta(Filtro, '-1');
    QComposicao.Open;
    DSComposicao.DataSet := QComposicao;
  end;
end;

procedure TFFichaTecnica.SpeedButton1Click(Sender: TObject);
begin
  LocalizaPrincipal;
end;

procedure TFFichaTecnica.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if key = 123 then
    BotaoConfirma.Click;
  if key = VK_ESCAPE then
    botaoCancela.Click;
end;

procedure TFFichaTecnica.EditLocalizaKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = 113 then
    LocalizaPrincipal;
end;

procedure TFFichaTecnica.LocalizaPrincipal;
var
  ProcurePor, Filtro: String;
begin
  ProcurePor := '%' + EditLocaliza.Text + '%';
  Filtro := 'IPPT = ' + QuotedStr('P');
  Filtro := Filtro + ' AND NOME LIKE '+ QuotedStr(ProcurePor);

  QProduto := TProdutoController.Consulta(Filtro, '-1');
  QProduto.Active := True;
  DSProduto.DataSet := QProduto;
  GridPrincipal.SetFocus;
end;

procedure TFFichaTecnica.FormActivate(Sender: TObject);
begin
  Color := StringToColor(Sessao.Configuracao.CorJanelasInternas);
  EditLocaliza.SetFocus;
end;

procedure TFFichaTecnica.botaoCancelaClick(Sender: TObject);
begin
  Close;
end;

procedure TFFichaTecnica.botaoConfirmaClick(Sender: TObject);
begin
  Close;
end;

procedure TFFichaTecnica.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  CloseAction:=caFree;
  FFichaTecnica:=nil;
end;

end.
