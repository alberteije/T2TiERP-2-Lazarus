{*******************************************************************************
Title: T2TiPDV
Description: Identifica um cliente não cadastrado para a venda. Permite chamar
a janela de pesquisa para importar um cliente cadastrado.

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
unit UIdentificaCliente;

{$mode objfpc}{$H+}

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, MaskEdit,
  Dialogs, StdCtrls, Buttons, ExtCtrls, Biblioteca, ACBrBase, ACBrEnterTab, CurrEdit, UBase;

type

  { TFIdentificaCliente }

  TFIdentificaCliente = class(TFBase)
    ACBrEnterTab1: TACBrEnterTab;
    Image1: TImage;
    Image2: TImage;
    panPeriodo: TPanel;
    editCpfCnpj: TMaskEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    editNome: TEdit;
    editEndereco: TEdit;
    botaoLocaliza: TBitBtn;
    botaoConfirma: TBitBtn;
    botaoCancela: TBitBtn;
    editIDCliente: TCurrencyEdit;
    Label4: TLabel;
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure Localiza;
    procedure LocalizaClienteNoBanco;
    procedure Confirma;
    procedure botaoLocalizaClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure editCpfCnpjExit(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure botaoConfirmaClick(Sender: TObject);
    function ValidaDados: Boolean;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FIdentificaCliente: TFIdentificaCliente;

implementation

uses UImportaCliente, ViewNfceClienteController, ViewNfceClienteVO;

var
  Cliente: TViewNfceClienteVO;

{$R *.lfm}

procedure TFIdentificaCliente.FormActivate(Sender: TObject);
begin
  Color := StringToColor(Sessao.Configuracao.CorJanelasInternas);
  Cliente := TViewNfceClienteVO.Create;
end;

procedure TFIdentificaCliente.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  FreeAndNil(Cliente);
  CloseAction := caFree;
end;

procedure TFIdentificaCliente.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = VK_F11 then
    Localiza;
  if Key = VK_F12 then
    Confirma;
  if Key = VK_ESCAPE then
    botaoCancela.Click;
end;

procedure TFIdentificaCliente.botaoLocalizaClick(Sender: TObject);
begin
  Localiza;
end;

procedure TFIdentificaCliente.localiza;
begin
  Application.CreateForm(TFImportaCliente, FImportaCliente);
  FImportaCliente.QuemChamou := 'IdentificaCliente';
  FImportaCliente.ShowModal;
end;


procedure TFIdentificaCliente.editCpfCnpjExit(Sender: TObject);
begin
  if trim(editCpfCnpj.Text) <> '' then
    LocalizaClienteNoBanco;
end;

procedure TFIdentificaCliente.localizaClienteNoBanco;
var
  Filtro: String;
begin
  Filtro := 'CPF = ' + QuotedStr(editCpfCnpj.Text);
  Cliente := TViewNfceClienteController.ConsultaObjeto(Filtro);
  if Assigned(Cliente) then
  begin
    editIDCliente.AsInteger := Cliente.Id;
    editNome.Text := Cliente.Nome;
  end
  else
    Cliente := TViewNfceClienteVO.Create;
end;

function TFIdentificaCliente.ValidaDados: Boolean;
begin
  Result := False;
  if length(editCpfCnpj.Text) = 11 then
    Result := ValidaCPF(editCpfCnpj.Text);

  if length(editCpfCnpj.Text) = 14 then
    Result := ValidaCNPJ(editCpfCnpj.Text);
end;

procedure TFIdentificaCliente.botaoConfirmaClick(Sender: TObject);
begin
  Confirma;
end;

procedure TFIdentificaCliente.confirma;
begin
  if ValidaDados then
  begin
    Sessao.VendaAtual.NfeDestinatarioVO.Nome := EditNome.Text;
    Sessao.VendaAtual.NfeDestinatarioVO.CpfCnpj := editCpfCnpj.Text;
    Close;
  end
  else
  begin
    Application.MessageBox('CPF ou CNPJ Inválido!', 'Informação do Sistema', MB_OK + MB_ICONINFORMATION);
    editCpfCnpj.SetFocus;
  end;
end;

end.
