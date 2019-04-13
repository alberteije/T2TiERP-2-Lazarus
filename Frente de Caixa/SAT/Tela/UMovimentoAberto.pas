{*******************************************************************************
Title: T2TiPDV
Description: Detecta um movimento aberto e solicita autenticação.

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
unit UMovimentoAberto;

{$mode objfpc}{$H+}

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, ExtCtrls, DB, FMTBcd, Biblioteca, ACBrBase, Tipos,
  ACBrEnterTab, UBase, NfceMovimentoController;

type

  { TFMovimentoAberto }

  TFMovimentoAberto = class(TFBase)
    ACBrEnterTab1: TACBrEnterTab;
    Image1: TImage;
    GroupBox2: TGroupBox;
    GroupBox1: TGroupBox;
    botaoConfirma: TBitBtn;
    botaoCancela: TBitBtn;
    Image2: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Bevel1: TBevel;
    Bevel2: TBevel;
    Bevel4: TBevel;
    LabelTurno: TLabel;
    LabelTerminal: TLabel;
    editSenhaOperador: TLabeledEdit;
    Label3: TLabel;
    LabelOperador: TLabel;
    Bevel3: TBevel;
    Bevel5: TBevel;
    Bevel6: TBevel;
    Label5: TLabel;
    Label6: TLabel;
    LabelData: TLabel;
    LabelHora: TLabel;
    procedure Confirma;
    procedure FormCreate(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure botaoCancelaClick(Sender: TObject);
    procedure botaoConfirmaClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FMovimentoAberto: TFMovimentoAberto;

implementation

{$R *.lfm}

procedure TFMovimentoAberto.FormCreate(Sender: TObject);
begin
  LabelTurno.Caption := Sessao.Movimento.NfceTurnoVO.Descricao;
  LabelTerminal.Caption := Sessao.Movimento.NfceCaixaVO.Nome;
  LabelOperador.Caption := Sessao.Movimento.NfceOperadorVO.Login;
  LabelData.Caption := FormatDateTime('dd/mm/yyyy', Sessao.Movimento.DataAbertura);
  LabelHora.Caption := Sessao.Movimento.HoraAbertura;
  Self.Color := StringToColor(Sessao.Configuracao.CorJanelasInternas);
end;

procedure TFMovimentoAberto.botaoConfirmaClick(Sender: TObject);
begin
  Confirma;
end;

procedure TFMovimentoAberto.Confirma;
begin
  try
    try
      // verifica se senha do operador esta correta
      Sessao.AutenticaUsuario(LabelOperador.Caption, editSenhaOperador.Text);
      if Assigned(Sessao.Usuario) then
      begin
        Sessao.StatusCaixa := scAberto;
        Close;
        if Sessao.Movimento.StatusMovimento = 'T' then
        begin
          Sessao.Movimento.StatusMovimento := 'A';
          TNfceMovimentoController.Altera(Sessao.Movimento);
        end;
      end
      else
      begin
        Application.MessageBox('Operador: dados incorretos.', 'Informação do Sistema', MB_OK + MB_ICONINFORMATION);
        editSenhaOperador.SetFocus;
      end;
    except
    end;
  finally
  end;
end;

procedure TFMovimentoAberto.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = 123 then
    Confirma;
  if Key = 27 then
    botaoCancela.Click;
end;

procedure TFMovimentoAberto.botaoCancelaClick(Sender: TObject);
begin
  SetTaskBar(True);
  Sessao.Free;
  ExitProcess(0);
end;

procedure TFMovimentoAberto.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  CloseAction := caFree;
end;

end.
