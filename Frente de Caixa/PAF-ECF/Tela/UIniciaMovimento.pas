{*******************************************************************************
Title: T2TiPDV
Description: Janela utilizada para iniciar um novo movimento.

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
unit UIniciaMovimento;

{$mode objfpc}{$H+}

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Grids, DBGrids, StdCtrls, Buttons, ExtCtrls, DB, FMTBcd,
  ZAbstractRODataset, ZAbstractDataset, ZDataset, ACBrBase, dateutils,
  ACBrEnterTab, CurrEdit, UBase, Tipos;

type

  { TFIniciaMovimento }

  TFIniciaMovimento = class(TFBase)
    ACBrEnterTab1: TACBrEnterTab;
    Image1: TImage;
    GroupBox2: TGroupBox;
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
    procedure Confirma;
    procedure FormActivate(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure GridTurnoKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure botaoConfirmaClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormCreate(Sender: TObject);
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
  EcfOperadorVO, EcfMovimentoVO, EcfTurnoVO, EcfSuprimentoVO, EcfFuncionarioController,
  EcfTurnoController, PAFUtil, ECFUtil, EcfMovimentoController, EcfSuprimentoController;

{$R *.lfm}

{$REGION 'Infra'}
procedure TFIniciaMovimento.FormCreate(Sender: TObject);
var
  Filtro: String;
begin
  Filtro := 'ID>0';
  QTurno := TEcfTurnoController.Consulta(Filtro, '-1');
  QTurno.Active := True;
  DSTurno.DataSet := QTurno;
end;

procedure TFIniciaMovimento.FormActivate(Sender: TObject);
begin
  Color := StringToColor(Sessao.Configuracao.CorJanelasInternas);
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
  Gerente: TEcfOperadorVO;
  Suprimento: TEcfSuprimentoVO;
begin
  try
    try
      // verifica se senha e o nível do operador estão corretos
      Sessao.AutenticaUsuario(editLoginOperador.Text, editSenhaOperador.Text);
      if Assigned(Sessao.Usuario) then
      begin
        // verifica se senha do gerente esta correta
        Gerente := TEcfFuncionarioController.Usuario(editLoginGerente.Text, editSenhaGerente.Text);
        if Assigned(Gerente) then
        begin
          // verifica nivel de acesso do gerente/supervisor
          if (Gerente.EcfFuncionarioVO.NivelAutorizacao = 'G') or (Gerente.EcfFuncionarioVO.NivelAutorizacao = 'S') then
          begin
            if TECFUtil.ImpressoraOK(2) then
            begin
              // insere movimento
              Sessao.Movimento := TEcfMovimentoVO.Create;

              Sessao.Movimento.IdEcfTurno := QTurno.FieldByName('ID').AsInteger;
              Sessao.Movimento.IdEcfImpressora := Sessao.Configuracao.IdEcfImpressora;
              Sessao.Movimento.idEcfEmpresa := Sessao.Configuracao.idEcfEmpresa;
              Sessao.Movimento.IdECfOperador := Sessao.Usuario.Id;
              Sessao.Movimento.IdECfCaixa := Sessao.Configuracao.IdECfCaixa;
              Sessao.Movimento.IdGerenteSupervisor := Gerente.Id;
              Sessao.Movimento.DataAbertura := EncodeDate(YearOf(FDataModule.ACBrECF.DataHora), MonthOf(FDataModule.ACBrECF.DataHora), DayOf(FDataModule.ACBrECF.DataHora));
              Sessao.Movimento.HoraAbertura := FormatDateTime('hh:nn:ss', FDataModule.ACBrECF.DataHora);
              Sessao.Movimento.TotalSuprimento := editValorSuprimento.Value;
              Sessao.Movimento.StatusMovimento := 'A';

              Sessao.Movimento := TEcfMovimentoController.IniciaMovimento(Sessao.Movimento);
            end
            else
            begin
              Application.MessageBox('Não foi possível abrir o movimento!.', 'Informação do Sistema', MB_OK + MB_ICONINFORMATION);
              Sessao.StatusCaixa := scSomenteConsulta;
              Close;
            end; // if UECF.ImpressoraOK(2) then

            // insere suprimento
            if editValorSuprimento.Value > 0 then
            begin
              try
                TECFUtil.Suprimento(editValorSuprimento.Value, Sessao.Configuracao.DescricaoSuprimento);

                Suprimento := TEcfSuprimentoVO.Create;
                Suprimento.IdEcfMovimento := Sessao.Movimento.Id;
                Suprimento.DataSuprimento := EncodeDate(YearOf(FDataModule.ACBrECF.DataHora), MonthOf(FDataModule.ACBrECF.DataHora), DayOf(FDataModule.ACBrECF.DataHora));
                Suprimento.Valor := editValorSuprimento.Value;
                TEcfSuprimentoController.Insere(Suprimento);
                Sessao.Movimento.TotalSuprimento := Sessao.Movimento.TotalSuprimento + Suprimento.Valor;
                TEcfMovimentoController.Altera(Sessao.Movimento);
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
  FDataModule.ACBrECF.AbreRelatorioGerencial(Sessao.Configuracao.EcfRelatorioGerencialVO.X);
  FDataModule.ACBrECF.LinhaRelatorioGerencial(StringOfChar('=', 48));
  FDataModule.ACBrECF.LinhaRelatorioGerencial(' ABERTURA DE CAIXA ');
  FDataModule.ACBrECF.PulaLinhas(1);
  FDataModule.ACBrECF.LinhaRelatorioGerencial('DATA DE ABERTURA  : ' + FormatDateTime('dd/mm/yyyy', Sessao.Movimento.DataAbertura));
  FDataModule.ACBrECF.LinhaRelatorioGerencial('HORA DE ABERTURA  : ' + Sessao.Movimento.HoraAbertura);
  FDataModule.ACBrECF.LinhaRelatorioGerencial(Sessao.Movimento.EcfCaixaVO.Nome + '  OPERADOR: ' + Sessao.Movimento.EcfOperadorVO.Login);
  FDataModule.ACBrECF.LinhaRelatorioGerencial('MOVIMENTO: ' + IntToStr(Sessao.Movimento.Id));
  FDataModule.ACBrECF.LinhaRelatorioGerencial(StringOfChar('=', 48));
  FDataModule.ACBrECF.PulaLinhas(1);
  FDataModule.ACBrECF.LinhaRelatorioGerencial('SUPRIMENTO...: ' + formatfloat('##,###,##0.00', EditValorSuprimento.Value));
  FDataModule.ACBrECF.PulaLinhas(3);
  FDataModule.ACBrECF.LinhaRelatorioGerencial(' ________________________________________ ');
  FDataModule.ACBrECF.LinhaRelatorioGerencial(' VISTO DO CAIXA ');
  FDataModule.ACBrECF.PulaLinhas(3);
  FDataModule.ACBrECF.LinhaRelatorioGerencial(' ________________________________________ ');
  FDataModule.ACBrECF.LinhaRelatorioGerencial(' VISTO DO SUPERVISOR ');

  FDataModule.ACBrECF.FechaRelatorio;
  TPAFUtil.GravarR06('RG');
end;

end.
