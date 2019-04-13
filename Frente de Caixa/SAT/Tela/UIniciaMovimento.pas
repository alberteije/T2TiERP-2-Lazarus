{*******************************************************************************
Title: T2TiPDV
Description: Janela utilizada para iniciar um novo movimento.

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
unit UIniciaMovimento;

{$mode objfpc}{$H+}

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Grids, DBGrids, StdCtrls, Buttons, ExtCtrls, DB, FMTBcd,
  ZAbstractRODataset, ZAbstractDataset, ZDataset, ACBrBase, dateutils,
  ACBrEnterTab, CurrEdit, UBase, Tipos, Printers;

type

  { TFIniciaMovimento }

  TFIniciaMovimento = class(TFBase)
    ACBrEnterTab1: TACBrEnterTab;
    Image1: TImage;
    GroupBox2: TGroupBox;
    Image2: TImage;
    Label3: TLabel;
    GroupBox3: TGroupBox;
    GridTurno: TDBGrid;
    GroupBox1: TGroupBox;
    editLoginGerente: TLabeledEdit;
    editSenhaGerente: TLabeledEdit;
    botaoConfirma: TBitBtn;
    botaoCancela: TBitBtn;
    GroupBox4: TGroupBox;
    editLoginOperador: TLabeledEdit;
    editSenhaOperador: TLabeledEdit;
    DSTurno: TDataSource;
    editValorSuprimento: TCurrencyEdit;
    Memo1: TMemo;
    procedure Confirma;
    procedure FormActivate(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure GridTurnoKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure botaoConfirmaClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure ImprimeAbertura;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FIniciaMovimento: TFIniciaMovimento;
  QTurno: TZQuery;

implementation

uses
  UDataModule,
  NfceOperadorVO, NfceMovimentoVO, NfceTurnoVO, NfceSuprimentoVO, NfceOperadorController,
  NfceTurnoController, NfceMovimentoController, NfceSuprimentoController;

{$R *.lfm}

{$REGION 'Infra'}
procedure PrintTStrings(Lst : TStrings) ;
var
  I,
  Line : Integer;
begin
  I := 0;
  Line := 0 ;
  Printer.BeginDoc ;
  Printer.Canvas.Font.Name := 'Courier New';
  Printer.Canvas.Font.Size := 10;
  Printer.Canvas.Font.Color := clBlack;
  for I := 0 to Lst.Count - 1 do begin
    Printer.Canvas.TextOut(0, Line, Lst[I]);
    {Font.Height is calculated as -Font.Size * 72 / Font.PixelsPerInch which returns
     a negative number. So Abs() is applied to the Height to make it a non-negative
     value}
    Line := Line + Abs(Printer.Canvas.TextHeight('I'));
    if (Line >= Printer.PageHeight) then
      Printer.NewPage;
  end;
  Printer.EndDoc;
end;


procedure TFIniciaMovimento.FormActivate(Sender: TObject);
var
  Filtro: String;
begin
  Color := StringToColor(Sessao.Configuracao.CorJanelasInternas);

  Filtro := 'ID>0';
  QTurno := TNfceTurnoController.Consulta(Filtro, '-1');
  QTurno.Active := True;
  DSTurno.DataSet := QTurno;

  GridTurno.SetFocus;
end;

procedure TFIniciaMovimento.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  CloseAction := caFree;
  Release;
end;

procedure TFIniciaMovimento.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = VK_F12 then
    Confirma;
  if Key = VK_ESCAPE then
    botaoCancela.Click;
end;

procedure TFIniciaMovimento.GridTurnoKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = VK_RETURN then
    editValorSuprimento.SetFocus;
end;
{$ENDREGION 'Infra'}

{$Region 'Confirmação e Início do Movimento'}
procedure TFIniciaMovimento.botaoConfirmaClick(Sender: TObject);
begin
  Confirma;
end;

procedure TFIniciaMovimento.Confirma;
var
  Gerente: TNfceOperadorVO;
  Suprimento: TNfceSuprimentoVO;
begin
  try
    try
      // verifica se senha e o nível do operador estão corretos
      Sessao.AutenticaUsuario(editLoginOperador.Text, editSenhaOperador.Text);
      if Assigned(Sessao.Usuario) then
      begin
        // verifica se senha do gerente esta correta
        Gerente := TNfceOperadorController.Usuario(editLoginGerente.Text, editSenhaGerente.Text);
        if Assigned(Gerente) then
        begin
          // verifica nivel de acesso do gerente/supervisor
          if (Gerente.NivelAutorizacao = 'G') or (Gerente.NivelAutorizacao = 'S') then
          begin
            // insere movimento
            Sessao.Movimento := TNfceMovimentoVO.Create;

            Sessao.Movimento.IdNfceTurno := QTurno.FieldByName('ID').AsInteger;
            Sessao.Movimento.IdEmpresa := Sessao.Configuracao.IdEmpresa;
            Sessao.Movimento.IdNfceOperador := Sessao.Usuario.Id;
            Sessao.Movimento.IdNfceCaixa := Sessao.Configuracao.IdNfceCaixa;
            Sessao.Movimento.IdGerenteSupervisor := Gerente.Id;
            Sessao.Movimento.DataAbertura := Date;
            Sessao.Movimento.HoraAbertura := FormatDateTime('hh:nn:ss', Now);
            Sessao.Movimento.TotalSuprimento := editValorSuprimento.Value;
            Sessao.Movimento.StatusMovimento := 'A';

            Sessao.Movimento := TNfceMovimentoController.IniciaMovimento(Sessao.Movimento);

            // insere suprimento
            if editValorSuprimento.Value > 0 then
            begin
              try
                Suprimento := TNfceSuprimentoVO.Create;
                Suprimento.IdNfceMovimento := Sessao.Movimento.Id;
                Suprimento.DataSuprimento := Date;
                Suprimento.Observacao := 'Abertura do Caixa';
                Suprimento.Valor := editValorSuprimento.Value;
                TNfceSuprimentoController.Insere(Suprimento);
              finally
                FreeAndNil(Suprimento);
              end;
            end; // if StrToFloat(editValorSuprimento.Text) <> 0 then

            if Assigned(Sessao.Movimento) then
            begin
              Application.MessageBox('Movimento aberto com sucesso.', 'Informação do Sistema', MB_OK + MB_ICONINFORMATION);
              Sessao.StatusCaixa := scAberto;
              ImprimeAbertura;
            end;
            Close;
          end
          else
          begin
            Application.MessageBox('Gerente ou Supervisor: nível de acesso incorreto.', 'Informação do Sistema', MB_OK + MB_ICONINFORMATION);
            editLoginGerente.SetFocus;
          end; // if (Gerente.Nivel = 'G') or (Gerente.Nivel = 'S') then
        end
        else
        begin
          Application.MessageBox('Gerente ou Supervisor: dados incorretos.', 'Informação do Sistema', MB_OK + MB_ICONINFORMATION);
          editLoginGerente.SetFocus;
        end; // if Gerente.Id <> 0 then
      end
      else
      begin
        Application.MessageBox('Operador: dados incorretos.', 'Informação do Sistema', MB_OK + MB_ICONINFORMATION);
        editSenhaOperador.SetFocus;
      end; // if Operador.Id <> 0 then
    except
    end;
  finally
    FreeAndNil(Gerente);
  end;
end;
{$EndRegion 'Confirmação e Início do Movimento'}

{$Region 'Impressão da Abertura'}
procedure TFIniciaMovimento.ImprimeAbertura;
begin
  // Exercício: implemente o relatório no seu gerenciador preferido
  Memo1.Clear;

  Memo1.Lines.Add(StringOfChar('=', 48));
  Memo1.Lines.Add('               ABERTURA DE CAIXA ');
  Memo1.Lines.Add('');
  Memo1.Lines.Add('DATA DE ABERTURA  : ' + FormatDateTime('dd/mm/yyyy', Sessao.Movimento.DataAbertura));
  Memo1.Lines.Add('HORA DE ABERTURA  : ' + Sessao.Movimento.HoraAbertura);
  Memo1.Lines.Add(Sessao.Movimento.NfceCaixaVO.Nome + '  OPERADOR: ' + Sessao.Movimento.NfceOperadorVO.Login);
  Memo1.Lines.Add('MOVIMENTO: ' + IntToStr(Sessao.Movimento.Id));
  Memo1.Lines.Add(StringOfChar('=', 48));
  Memo1.Lines.Add('');
  Memo1.Lines.Add('SUPRIMENTO...: ' + formatfloat('##,###,##0.00', EditValorSuprimento.Value));
  Memo1.Lines.Add('');
  Memo1.Lines.Add('');
  Memo1.Lines.Add('');
  Memo1.Lines.Add(' ________________________________________ ');
  Memo1.Lines.Add(' VISTO DO CAIXA ');
  Memo1.Lines.Add('');
  Memo1.Lines.Add('');
  Memo1.Lines.Add('');
  Memo1.Lines.Add('');
  Memo1.Lines.Add(' ________________________________________ ');
  Memo1.Lines.Add(' VISTO DO SUPERVISOR ');

  PrintTStrings(Memo1.Lines);
end;

end.
