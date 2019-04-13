{*******************************************************************************
Title: T2Ti ERP
Description: Permite a emissão do arquivo do SPED Contribuições

The MIT License

Copyright: Copyright (C) 2014 T2Ti.COM

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
           t2ti.com@gmail.com

@author Albert Eije
@version 2.0
*******************************************************************************}
unit USpedContribuicoes;

{$mode objfpc}{$H+}

interface

uses
  BrookHTTPClient, BrookFCLHTTPClientBroker, BrookHTTPUtils, BrookUtils,
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, ExtCtrls, MaskEdit, ComCtrls, DBGrids, rxdbgrid,
  UDataModule, db, BufDataset, DateUtils, UBase, FPJson, Biblioteca;

type

  { TFSpedContribuicoes }

  TFSpedContribuicoes = class(TFBase)
    Bevel1: TBevel;
    botaoCancela: TBitBtn;
    botaoConfirma: TBitBtn;
    CDSDetalhe: TBufDataset;
    DSDetalhe: TDatasource;
    GroupBox1: TGroupBox;
    Image1: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Label9: TLabel;
    mkeDataFim: TMaskEdit;
    mkeDataIni: TMaskEdit;
    Panel1: TPanel;
    PageControl1: TPageControl;
    PaginaSped: TTabSheet;
    Label6: TLabel;
    ComboBoxVersaoLeiauteSped: TComboBox;
    Label7: TLabel;
    ComboBoxTipoEscrituracao: TComboBox;
    GridDetalhe: TRxDBGrid;
    procedure botaoCancelaClick(Sender: TObject);
    procedure Confirma;
    procedure FormActivate(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure botaoConfirmaClick(Sender: TObject);
    procedure mkeDataIniExit(Sender: TObject);
    procedure mkeDataFimExit(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FSpedContribuicoes: TFSpedContribuicoes;

implementation

uses UPreview, ContadorVO;

{$R *.lfm}

{$Region Infra}
procedure TFSpedContribuicoes.FormActivate(Sender: TObject);
var
  VData: TJSONArray = nil;
begin
  try
    ConfiguraCDSFromVO(CDSDetalhe, TContadorVO);
    ProcessRequest(BrookHttpRequest(Sessao.URL + 'contador', VData));
    AtualizaGridJsonInterna(VData, CDSDetalhe);
    ConfiguraGridFromVO(GridDetalhe, TContadorVO);
  finally
    FreeAndNil(VData);
  end;

  mkeDataIni.Text := DateToStr(StartOfTheMonth(Now));
  mkeDataFim.Text := DateToStr(EndOfTheMonth(Now));
  mkeDataIni.SetFocus;
end;

procedure TFSpedContribuicoes.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  CloseAction := caFree;
end;

procedure TFSpedContribuicoes.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if key = 123 then
    Confirma;
  if key = VK_ESCAPE then
    botaoCancela.Click;
end;

procedure TFSpedContribuicoes.botaoCancelaClick(Sender: TObject);
begin
  Close;
end;

procedure TFSpedContribuicoes.mkeDataFimExit(Sender: TObject);
begin
  if  StrToDate(mkeDataIni.Text) > StrToDate(mkeDataFim.Text)  then
  begin
    Application.MessageBox('Data inicial não pode ser maior que data final!', 'Informação do Sistema', MB_OK + MB_ICONINFORMATION);
    mkeDataFim.setFocus;
  end;
end;

procedure TFSpedContribuicoes.mkeDataIniExit(Sender: TObject);
begin
  mkeDataFim.Text := DateToStr(EndOfTheMonth(strtodate(mkeDataIni.Text)));
end;
{$EndRegion Infra}

{$Region Confirmação}
procedure TFSpedContribuicoes.botaoConfirmaClick(Sender: TObject);
begin
  Confirma;
end;

procedure TFSpedContribuicoes.Confirma;
var
  DataIni, DataFim, Empresa, Versao, TipoEscrituracao, Contador: String;
  Arquivo: TBrookHttpResult;
begin
  if Application.MessageBox('Deseja gerar o arquivo da EFD Contribuições?', 'Pergunta do Sistema', Mb_YesNo + Mb_IconQuestion) = IdYes then
  begin
    DataIni := FormatDateTime('yyyy-mm-dd', StrToDate(mkeDataIni.Text));
    DataFim := FormatDateTime('yyyy-mm-dd', StrToDate(mkeDataFim.Text));
    Empresa := IntToStr(Sessao.Empresa.Id);
    Versao := IntToStr(ComboBoxVersaoLeiauteSped.ItemIndex);
    TipoEscrituracao := IntToStr(ComboBoxTipoEscrituracao.ItemIndex);
    Contador := CDSDetalhe.FieldByName('ID').AsString;
    try
      Arquivo := BrookHttpRequest(Sessao.URL + 'spedcontribuicoes/' + DataIni + '/' + DataFim + '/' + Versao + '/' + TipoEscrituracao + '/' + Empresa + '/' + Contador + '/');
      Application.CreateForm(TFPreview, FPreview);
      FPreview.RichEdit.Lines.Add(Arquivo.Content);
      FPreview.ShowModal;
    finally
    end;
  end;
end;
{$EndRegion Confirmação}


end.
