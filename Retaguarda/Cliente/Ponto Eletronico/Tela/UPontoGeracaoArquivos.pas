{ *******************************************************************************
Title: T2Ti ERP
Description: Janela de geração de arquivos para o Ponto Eletrônico

The MIT License

Copyright: Copyright (C) 2016 T2Ti.COM

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

@author Albert Eije (alberteije@gmail.com)
@version 2.0
******************************************************************************* }
unit UPontoGeracaoArquivos;

{$MODE Delphi}

interface

uses
  BrookHTTPClient, BrookFCLHTTPClientBroker, BrookHTTPUtils, BrookUtils, FPJson, ZDataset,
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UTelaCadastro, Menus, StdCtrls, ExtCtrls, Buttons, Grids, DBGrids,
  ComCtrls, LabeledCtrls, rxdbgrid, rxtoolbar, DBCtrls, StrUtils,
  Math, Constantes, CheckLst, ActnList, ToolWin, ShellApi, db, BufDataset, Biblioteca,
  ULookup, VO, ACBrPonto, SessaoUsuario;

  type

  { TFPontoGeracaoArquivos }

  TFPontoGeracaoArquivos = class(TForm)
    CDSViewPontoMarcacao: TBufDataSet;
    DSViewPontoMarcacao: TDataSource;
    PanelCabecalho: TPanel;
    Bevel1: TBevel;
    Image1: TImage;
    Label2: TLabel;
    ActionToolBarGrid: TToolPanel;
    ActionManagerLocal: TActionList;
    ActionSair: TAction;
    ActionConsultarDados: TAction;
    ActionGerarAFDT: TAction;
    ActionGerarACJEF: TAction;
    Bevel2: TBevel;
    EditDataInicial: TLabeledDateEdit;
    EditDataFinal: TLabeledDateEdit;
    PageControlDados: TPageControl;
    TabSheetPontoMarcacao: TTabSheet;
    Grid: TRxDbGrid;
    TabSheetFechamento: TTabSheet;
    CDSPontoFechamentoJornada: TBufDataSet;
    DSPontoFechamentoJornada: TDataSource;
    GridFechamento: TRxDbGrid;
    procedure ActionSairExecute(Sender: TObject);
    procedure ActionConsultarDadosExecute(Sender: TObject);
    procedure ActionGerarAFDTExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ActionGerarACJEFExecute(Sender: TObject);
    class function Sessao: TSessaoUsuario;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FPontoGeracaoArquivos: TFPontoGeracaoArquivos;

implementation

uses
  UMenu, UDataModule, PontoMarcacaoVO, PontoMarcacaoController, ViewPontoMarcacaoVO,
  ViewPontoMarcacaoController, PontoHorarioController, PontoFechamentoJornadaController,
  PontoFechamentoJornadaVO;
{$R *.lfm}

{$REGION 'Infra'}
procedure TFPontoGeracaoArquivos.FormCreate(Sender: TObject);
begin
  ConfiguraCDSFromVO(CDSPontoFechamentoJornada, TPontoFechamentoJornadaVO);
  ConfiguraCDSFromVO(CDSViewPontoMarcacao, TViewPontoMarcacaoVO);
end;

class function TFPontoGeracaoArquivos.Sessao: TSessaoUsuario;
begin
  Result := TSessaoUsuario.Instance;
end;

procedure TFPontoGeracaoArquivos.ActionSairExecute(Sender: TObject);
begin
  Close;
end;

procedure TFPontoGeracaoArquivos.FormShow(Sender: TObject);
begin
  inherited;
  EditDataInicial.Date := StrToDate('01' + Copy(DateToStr(Date), 3, 8));
  EditDataFinal.Date := StrToDate(UltimoDiaMes(Date) + Copy(DateToStr(Date), 3, 8));
  EditDataInicial.SetFocus;
end;
{$ENDREGION}

{$REGION 'Actions'}
procedure TFPontoGeracaoArquivos.ActionConsultarDadosExecute(Sender: TObject);
var
  Filtro: String;
  RetornoConsulta: TZQuery;
  ListaCampos: TStringList;
  I: Integer;
begin
  try
    try
      CDSViewPontoMarcacao.Close;
      CDSViewPontoMarcacao.Open;

      Filtro := 'DATA_MARCACAO BETWEEN ' + QuotedStr(DataParaTexto(EditDataInicial.Date)) + ' and ' + QuotedStr(DataParaTexto(EditDataFinal.Date));
      ListaCampos  := TStringList.Create;
      RetornoConsulta := TViewPontoMarcacaoController.Consulta(Filtro, '0');
      RetornoConsulta.Active := True;

      RetornoConsulta.GetFieldNames(ListaCampos);

      RetornoConsulta.First;
      while not RetornoConsulta.EOF do begin
        CDSViewPontoMarcacao.Append;
        for i := 0 to ListaCampos.Count - 1 do
        begin
          CDSViewPontoMarcacao.FieldByName(ListaCampos[i]).Value := RetornoConsulta.FieldByName(ListaCampos[i]).Value;
        end;
        CDSViewPontoMarcacao.Post;
        RetornoConsulta.Next;
      end;
      CDSViewPontoMarcacao.IndexFieldNames := 'PIS_NUMERO; DATA_MARCACAO; HORA_MARCACAO';


      CDSPontoFechamentoJornada.Close;
      CDSPontoFechamentoJornada.Open;

      Filtro := 'DATA_FECHAMENTO BETWEEN ' + QuotedStr(DataParaTexto(EditDataInicial.Date)) + ' and ' + QuotedStr(DataParaTexto(EditDataFinal.Date));
      ListaCampos  := TStringList.Create;
      RetornoConsulta := TPontoFechamentoJornadaController.Consulta(Filtro, '0');
      RetornoConsulta.Active := True;

      RetornoConsulta.GetFieldNames(ListaCampos);

      RetornoConsulta.First;
      while not RetornoConsulta.EOF do begin
        CDSPontoFechamentoJornada.Append;
        for i := 0 to ListaCampos.Count - 1 do
        begin
          CDSPontoFechamentoJornada.FieldByName(ListaCampos[i]).Value := RetornoConsulta.FieldByName(ListaCampos[i]).Value;
        end;
        CDSPontoFechamentoJornada.Post;
        RetornoConsulta.Next;
      end;
      CDSPontoFechamentoJornada.IndexFieldNames := 'ID_COLABORADOR; DATA_FECHAMENTO';
    except
      on E: Exception do
        Application.MessageBox(PChar('Ocorreu um erro na consulta. Informe a mensagem ao Administrador do sistema.' + #13 + #13 + E.Message), 'Erro do sistema', MB_OK + MB_ICONERROR);
    end;
  finally
  end;
end;

procedure TFPontoGeracaoArquivos.ActionGerarAFDTExecute(Sender: TObject);
var
  Arquivo: String;
begin
  if Application.MessageBox('Deseja gerar o arquivo AFDT?', 'Pergunta do Sistema', MB_YesNo + MB_IconQuestion) = IdYes then
  begin
    try
      try
        FMenu.vACBrPonto.Ponto_AFDT.LimpaRegistros;

        // Registro 1 - Cabecalho
        {
          Campo01: String; // Seqüencial do registro no arquivo.
          Campo02: String; // Tipo do registro, “1”.
          Campo03: String; // Tipo de identificador do empregador, “1” para CNPJ ou “2” para CPF.
          Campo04: String; // CNPJ ou CPF do empregador.
          Campo05: String; // CEI do empregador, quando existir.
          Campo06: String; // Razão social ou nome do empregador.
          Campo07: String; // Data inicial dos registros no arquivo, no formato “ddmmaaaa”.
          Campo08: String; // Data final dos registros no arquivo, no formato “ddmmaaaa”.
          Campo09: String; // Data de geração do arquivo, no formato “ddmmaaaa”.
          Campo10: String; // Horário da geração do arquivo, no formato “hhmm”.
          }
        FMenu.vACBrPonto.Ponto_AFDT.Cabecalho.Campo02 := '1';
        FMenu.vACBrPonto.Ponto_AFDT.Cabecalho.Campo03 := '1';
        FMenu.vACBrPonto.Ponto_AFDT.Cabecalho.Campo04 := Sessao.Empresa.Cnpj;
        FMenu.vACBrPonto.Ponto_AFDT.Cabecalho.Campo05 := Sessao.Empresa.Cei;
        FMenu.vACBrPonto.Ponto_AFDT.Cabecalho.Campo06 := Sessao.Empresa.RazaoSocial;
        FMenu.vACBrPonto.Ponto_AFDT.Cabecalho.Campo07 := FormatDateTime('DDMMYYYY', EditDataInicial.Date);
        FMenu.vACBrPonto.Ponto_AFDT.Cabecalho.Campo08 := FormatDateTime('DDMMYYYY', EditDataFinal.Date);
        FMenu.vACBrPonto.Ponto_AFDT.Cabecalho.Campo09 := FormatDateTime('DDMMYYYY', Now);
        FMenu.vACBrPonto.Ponto_AFDT.Cabecalho.Campo10 := FormatDateTime('hhmm', Now);

        CDSViewPontoMarcacao.DisableControls;
        CDSViewPontoMarcacao.First;
        while not CDSViewPontoMarcacao.eof do
        begin
          // Registro 2 - Detalhe
          {
            Campo01: String; // Seqüencial do registro no arquivo.
            Campo02: String; // Tipo do registro, “2”.
            Campo03: String; // Data da marcação do ponto, no formato “ddmmaaaa”.
            Campo04: String; // Horário da marcação do ponto, no formato “hhmm”.
            Campo05: String; // Número do PIS do empregado.
            Campo06: String; // Número de fabricação do REP onde foi feito o registro.
            Campo07: String; // Tipo de marcação, “E” para ENTRADA, “S” para SAÍDA ou “D” para registro a ser DESCONSIDERADO.
            Campo08: String; // Número seqüencial por empregado e jornada para o conjunto Entrada/Saída. Vide observação.
            Campo09: String; // Tipo de registro: “O” para registro eletrônico ORIGINAL, “I” para registro INCLUÍDO por digitação, “P” para intervalo PRÉ-ASSINALADO.
            Campo10: String; // Motivo: Campo a ser preenchido se o campo 7 for “D” ou se o campo 9 for “I”.
            }
          with FMenu.vACBrPonto.Ponto_AFDT.Registro2.New do
          begin
            Campo02 := '2';
            Campo03 := FormatDateTime('DDMMYYYY', CDSViewPontoMarcacao.FieldByName('DATA_MARCACAO').AsDateTime);
            Campo04 := FormatDateTime('hhmm', CDSViewPontoMarcacao.FieldByName('HORA_MARCACAO').AsDateTime);
            Campo05 := CDSViewPontoMarcacao.FieldByName('PIS_NUMERO').AsString;
            Campo06 := CDSViewPontoMarcacao.FieldByName('NUMERO_SERIE').AsString;
            Campo07 := CDSViewPontoMarcacao.FieldByName('TIPO_MARCACAO').AsString;
            Campo08 := CDSViewPontoMarcacao.FieldByName('PAR_ENTRADA_SAIDA').AsString;
            Campo09 := CDSViewPontoMarcacao.FieldByName('TIPO_REGISTRO').AsString;
            Campo10 := CDSViewPontoMarcacao.FieldByName('JUSTIFICATIVA').AsString;
          end;
          CDSViewPontoMarcacao.Next;
        end;
        CDSViewPontoMarcacao.First;
        CDSViewPontoMarcacao.EnableControls;

        // Gera arquivo
        Arquivo := 'Arquivo_AFDT_' + FormatDateTime('DDMMYYYYhhmmss', Now) + '.txt';

        FMenu.vACBrPonto.Path := ExtractFilePath(Application.ExeName);
        FMenu.vACBrPonto.SaveFileTXT_AFDT(Arquivo);

        Application.MessageBox('Arquivo gerado com sucesso!', 'Informação do sistema', MB_OK + MB_ICONINFORMATION);
      except
        on E: Exception do
          Application.MessageBox(PChar('Ocorreu um erro na geração do arquivo. Informe a mensagem ao Administrador do sistema.' + #13 + #13 + E.Message), 'Erro do sistema', MB_OK + MB_ICONERROR);
      end;
    finally
    end;
  end;
end;

procedure TFPontoGeracaoArquivos.ActionGerarACJEFExecute(Sender: TObject);
var
  Arquivo: String;
  CDSPontoHorario: TZQuery;
begin
  if Application.MessageBox('Deseja gerar o arquivo ACJEF?', 'Pergunta do Sistema', MB_YesNo + MB_IconQuestion) = IdYes then
  begin
    try
      try
        FMenu.vACBrPonto.Ponto_ACJEF.LimpaRegistros;

        // Registro 1 - Cabecalho
        {
          Campo01: String; // “000000000”.
          Campo02: String; // Tipo do registro, “1”.
          Campo03: String; // Tipo de identificador do empregador, “1” para CNPJ ou “2” para CPF.
          Campo04: String; // CNPJ ou CPF do empregador.
          Campo05: String; // CEI do empregador, quando existir.
          Campo06: String; // Razão social ou nome do empregador.
          Campo07: String; // Data inicial dos registros no arquivo, no formato “ddmmaaaa”.
          Campo08: String; // Data final dos registros no arquivo, no formato “ddmmaaaa”.
          Campo09: String; // Data de geração do arquivo, no formato “ddmmaaaa”.
          Campo10: String; // Horário da geração do arquivo, no formato “hhmm”.
          }
        FMenu.vACBrPonto.Ponto_ACJEF.Cabecalho.Campo02 := '1';
        FMenu.vACBrPonto.Ponto_ACJEF.Cabecalho.Campo03 := '1';
        FMenu.vACBrPonto.Ponto_ACJEF.Cabecalho.Campo04 := Sessao.Empresa.Cnpj;
        FMenu.vACBrPonto.Ponto_ACJEF.Cabecalho.Campo05 := Sessao.Empresa.Cei;
        FMenu.vACBrPonto.Ponto_ACJEF.Cabecalho.Campo06 := Sessao.Empresa.RazaoSocial;
        FMenu.vACBrPonto.Ponto_ACJEF.Cabecalho.Campo07 := FormatDateTime('DDMMYYYY', EditDataInicial.Date);
        FMenu.vACBrPonto.Ponto_ACJEF.Cabecalho.Campo08 := FormatDateTime('DDMMYYYY', EditDataFinal.Date);
        FMenu.vACBrPonto.Ponto_ACJEF.Cabecalho.Campo09 := FormatDateTime('DDMMYYYY', Now);
        FMenu.vACBrPonto.Ponto_ACJEF.Cabecalho.Campo10 := FormatDateTime('hhmm', Now);

        CDSPontoHorario := TPontoHorarioController.Consulta('ID_EMPRESA = 1', '0');
        CDSPontoHorario.Active := True;
        CDSPontoHorario.First;
        while not CDSPontoHorario.eof do
        begin
          // Registro 2 - Horários Contratuais
          {
            Campo01: String; // NSR.
            Campo02: String; // Tipo do registro, “2”.
            Campo03: String; // Código do Horário (CH), no formato “nnnn”.
            Campo04: String; // Entrada, no formato “hhmm”.
            Campo05: String; // Saída, no formato “hhmm”.
            Campo06: String; // Início intervalo, no formato “hhmm”.
            Campo07: String; // Fim intervalo, no formato “hhmm”.
            }
          with FMenu.vACBrPonto.Ponto_ACJEF.Registro2.New do
          begin
            Campo02 := '2';
            Campo03 := CDSPontoHorario.FieldByName('CODIGO').AsString;
            if Length(Trim(CDSPontoHorario.FieldByName('HORA_INICIO_JORNADA').AsString)) = 8 then
              Campo04 := FormatDateTime('hhmm', CDSPontoHorario.FieldByName('HORA_INICIO_JORNADA').AsDateTime);
            if Length(Trim(CDSPontoHorario.FieldByName('HORA_FIM_JORNADA').AsString)) = 8 then
              Campo05 := FormatDateTime('hhmm', CDSPontoHorario.FieldByName('HORA_FIM_JORNADA').AsDateTime);
            if Length(Trim(CDSPontoHorario.FieldByName('SAIDA01').AsString)) = 8 then
              Campo06 := FormatDateTime('hhmm', CDSPontoHorario.FieldByName('SAIDA01').AsDateTime);
            if Length(Trim(CDSPontoHorario.FieldByName('ENTRADA02').AsString)) = 8 then
              Campo07 := FormatDateTime('hhmm', CDSPontoHorario.FieldByName('ENTRADA02').AsDateTime);
          end;
          CDSPontoHorario.Next;
        end;
        CDSPontoHorario.First;
        CDSPontoHorario.EnableControls;


        CDSPontoFechamentoJornada.DisableControls;
        CDSPontoFechamentoJornada.First;
        while not CDSPontoFechamentoJornada.eof do
        begin
          // Registro 3 - Detalhe
          {
            Campo01: String; // NSR.
            Campo02: String; // tipo do registro, “3”.
            Campo03: String; // Número do PIS do empregado.
            Campo04: String; // Data de início da jornada, no formato “ddmmaaaa”.
            Campo05: String; // Primeiro horário de entrada da jornada, no formato “hhmm”.
            Campo06: String; // Código do horário (CH) previsto para a jornada, no formato “nnnn”.
            Campo07: String; // Horas diurnas não extraordinárias, no formato “hhmm”.
            Campo08: String; // Horas noturnas não extraordinárias, no formato “hhmm”.
            Campo09: String; // Horas extras 1, no formato “hhmm”.
            Campo10: String; // Percentual do adicional de horas extras 1, onde as 3 primeiras posições indicam a parte inteira e a seguinte a fração decimal.
            Campo11: String; // Modalidade da hora extra 1, assinalado com “D” se as horas extras forem diurnas e “N” se forem noturnas.
            Campo12: String; // Horas extras 2, no formato “hhmm”.
            Campo13: String; // Percentual do adicional de horas extras 2, onde as 3 primeiras posições indicam a parte inteira e a seguinte a fração decimal.
            Campo14: String; // Modalidade da hora extra 2, assinalado com “D” se as horas extras forem diurnas e “N” se forem noturnas.
            Campo15: String; // Horas extras 3, no formato “hhmm”.
            Campo16: String; // Percentual do adicional de horas extras 3, onde as 3 primeiras posições indicam a parte inteira e a seguinte a fração decimal.
            Campo17: String; // Modalidade da hora extra 3, assinalado com “D” se as horas extras forem diurnas e “N” se forem noturnas.
            Campo18: String; // Horas extras 4, no formato “hhmm”.
            Campo19: String; // Percentual do adicional de horas extras 4, onde as 3 primeiras posições indicam a parte inteira e a seguinte a fração decimal.
            Campo20: String; // Modalidade da hora extra 4, assinalado com “D” se as horas extras forem diurnas e “N” se forem noturnas.
            Campo21: String; // Horas de faltas e/ou atrasos.
            Campo22: String; // Sinal de horas para compensar. “1” se for horas a maior e “2” se for horas a menor.
            Campo23: String; // Saldo de horas para compensar no formato “hhmm”.
            }
          with FMenu.vACBrPonto.Ponto_ACJEF.Registro3.New do
          begin
            Campo02 := '3';
            Campo03 := '123456';//CDSPontoFechamentoJornada.FieldByName('PIS_NUMERO').AsString;
            Campo04 := FormatDateTime('DDMMYYYY', CDSPontoFechamentoJornada.FieldByName('DATA_FECHAMENTO').AsDateTime);
            Campo05 := FormatDateTime('hhmm', CDSPontoFechamentoJornada.FieldByName('ENTRADA01').AsDateTime);
            Campo06 := CDSPontoFechamentoJornada.FieldByName('CODIGO_HORARIO').AsString;
            if Length(Trim(CDSPontoFechamentoJornada.FieldByName('CARGA_HORARIA_DIURNA').AsString)) = 8 then
              Campo07 := FormatDateTime('hhmm', CDSPontoFechamentoJornada.FieldByName('CARGA_HORARIA_DIURNA').AsDateTime);
            if Length(Trim(CDSPontoFechamentoJornada.FieldByName('CARGA_HORARIA_NOTURNA').AsString)) = 8 then
              Campo08 := FormatDateTime('hhmm', CDSPontoFechamentoJornada.FieldByName('CARGA_HORARIA_NOTURNA').AsDateTime);
            if Length(Trim(CDSPontoFechamentoJornada.FieldByName('HORA_EXTRA01').AsString)) = 8 then
              Campo09 := FormatDateTime('hhmm', CDSPontoFechamentoJornada.FieldByName('HORA_EXTRA01').AsDateTime);
            Campo10 := FormataFloat('###', CDSPontoFechamentoJornada.FieldByName('PERCENTUAL_HORA_EXTRA01').AsFloat) + '0';
            Campo11 := CDSPontoFechamentoJornada.FieldByName('MODALIDADE_HORA_EXTRA01').AsString;
            if Length(Trim(CDSPontoFechamentoJornada.FieldByName('HORA_EXTRA02').AsString)) = 8 then
              Campo12 := FormatDateTime('hhmm', CDSPontoFechamentoJornada.FieldByName('HORA_EXTRA02').AsDateTime);
            Campo13 := FormataFloat('###', CDSPontoFechamentoJornada.FieldByName('PERCENTUAL_HORA_EXTRA02').AsFloat) + '0';
            Campo14 := CDSPontoFechamentoJornada.FieldByName('MODALIDADE_HORA_EXTRA02').AsString;
            if Length(Trim(CDSPontoFechamentoJornada.FieldByName('HORA_EXTRA03').AsString)) = 8 then
              Campo15 := FormatDateTime('hhmm', CDSPontoFechamentoJornada.FieldByName('HORA_EXTRA03').AsDateTime);
            Campo16 := FormataFloat('###', CDSPontoFechamentoJornada.FieldByName('PERCENTUAL_HORA_EXTRA03').AsFloat) + '0';
            Campo17 := CDSPontoFechamentoJornada.FieldByName('MODALIDADE_HORA_EXTRA03').AsString;
            if Length(Trim(CDSPontoFechamentoJornada.FieldByName('HORA_EXTRA04').AsString)) = 8 then
              Campo18 := FormatDateTime('hhmm', CDSPontoFechamentoJornada.FieldByName('HORA_EXTRA04').AsDateTime);
            Campo19 := FormataFloat('###', CDSPontoFechamentoJornada.FieldByName('PERCENTUAL_HORA_EXTRA04').AsFloat) + '0';
            Campo20 := CDSPontoFechamentoJornada.FieldByName('MODALIDADE_HORA_EXTRA04').AsString;
            if Length(Trim(CDSPontoFechamentoJornada.FieldByName('FALTA_ATRASO').AsString)) = 8 then
              Campo21 := FormatDateTime('hhmm', CDSPontoFechamentoJornada.FieldByName('FALTA_ATRASO').AsDateTime);
            Campo22 := CDSPontoFechamentoJornada.FieldByName('COMPENSAR').AsString;
            if Length(Trim(CDSPontoFechamentoJornada.FieldByName('BANCO_HORAS').AsString)) = 8 then
              Campo23 := FormatDateTime('hhmm', CDSPontoFechamentoJornada.FieldByName('BANCO_HORAS').AsDateTime);
          end;
          CDSPontoFechamentoJornada.Next;
        end;
        CDSPontoFechamentoJornada.First;
        CDSPontoFechamentoJornada.EnableControls;

        // Gera arquivo
        Arquivo := 'Arquivo_ACJEF_' + FormatDateTime('DDMMYYYYhhmmss', Now) + '.txt';

        FMenu.vACBrPonto.Path := ExtractFilePath(Application.ExeName);
        FMenu.vACBrPonto.SaveFileTXT_ACJEF
        (Arquivo);

        Application.MessageBox('Arquivo gerado com sucesso!', 'Informação do sistema', MB_OK + MB_ICONINFORMATION);
      except
        on E: Exception do
          Application.MessageBox(PChar('Ocorreu um erro na geração do arquivo. Informe a mensagem ao Administrador do sistema.' + #13 + #13 + E.Message), 'Erro do sistema', MB_OK + MB_ICONERROR);
      end;
    finally
    end;
  end;
end;
{$ENDREGION}

end.

