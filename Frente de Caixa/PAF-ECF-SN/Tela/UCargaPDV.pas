{ *******************************************************************************
  Title: T2TiPDV
  Description: Controle de importação e exportação de arquivos

  The MIT License

  Copyright: Copyright (C) 2012 Albert Eije

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

  @author Albert Eije
  @version 1.0
  ******************************************************************************* }
unit UCargaPDV;

{$mode objfpc}{$H+}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, UBase,
  Controller, Dialogs, ExtCtrls, ComCtrls;

type

  { TFCargaPDV }

  TFCargaPDV = class(TFBase)
    ProgressBar1: TProgressBar;
    Timer: TTimer;

    procedure CopiarArquivoParaRetaguarda;

    procedure ExportarRegistro;

    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure TimerTimer(Sender: TObject);
  private
    { Private declarations }
  public
    Procedimento, Filtro: String;
    { Public declarations }
  end;

var
  FCargaPDV: TFCargaPDV;
  PathLocal, PathRemoto, PathSemaforo, JsonString: String;

implementation

uses
  UCaixa,

  EcfMovimentoVO, EcfVendaCabecalhoVO, R02VO, R06VO, Sintegra60MVO,
  NotaFiscalCabecalhoVO, VendaController, EcfMovimentoController;

{$R *.lfm}

{$Region 'Infra'}
procedure TFCargaPDV.FormShow(Sender: TObject);
begin
  ForceDirectories(ExtractFilePath(Application.ExeName) + 'Integracao');
  Timer.Enabled := True;
end;

procedure TFCargaPDV.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  CloseAction := caFree;
  FCargaPDV := nil;
end;

procedure TFCargaPDV.CopiarArquivoParaRetaguarda;
begin
  try
    try
      ProgressBar1.Position := 50;
      //
      if CopyFile(PChar(ExtractFilePath(Application.ExeName) + 'ArquivoAuxiliar.ini'), PChar(PathSemaforo), False) then
      begin
        if CopyFile(PChar(PathLocal), PChar(PathRemoto), False) then
        begin
          Application.ProcessMessages;
          DeleteFile(PChar(PathSemaforo));
        end;
      end;
    except
    end;
  finally
    ProgressBar1.Position := 100;
  end;
end;
{$EndRegion 'Infra'}

{$Region 'Exportacao'}
procedure TFCargaPDV.ExportarRegistro;
var
  Arquivo: TextFile;
begin
  if Sessao.Camadas = 2 then
  begin
    if Sessao.Configuracao.TipoIntegracao = 3 then // 3 = JSON
    begin
      try

        AssignFile(Arquivo, PathLocal);
        if FileExists(PathLocal) then
          Append(Arquivo)
        else
          Rewrite(Arquivo);

        Write(Arquivo, JsonString);
        Writeln(Arquivo);
      finally
        CloseFile(Arquivo);
        CopiarArquivoParaRetaguarda;
      end;
    end;
  end;
end;

procedure TFCargaPDV.TimerTimer(Sender: TObject);
var
  Movimento: TEcfMovimentoVO;
  Venda: TEcfVendaCabecalhoVO;
  R02: TR02VO;
  R06: TR06VO;
  Sintegra60M: TSintegra60mVO;
  NotaFiscal: TNotaFiscalCabecalhoVO;
begin
  Timer.Enabled := False;
  FormatSettings.DecimalSeparator := '.';

  try
    PathSemaforo := Sessao.PathIntegracao + 'Caixa' + IntToStr(Sessao.Configuracao.IdEcfCaixa) + '.semaforo';

    if Procedimento = 'EXPORTA_VENDA' then
    begin
      try
        Filtro := 'ID = ' + IntToStr(Sessao.VendaAtual.Id);
        Venda := TVendaController.ConsultaObjeto(Filtro);
        JsonString := Venda.ToJSONString;

        PathLocal := ExtractFilePath(Application.ExeName) + 'Integracao\' + 'VENDA_' + Sessao.Configuracao.EcfCaixaVO.Nome + '_' + FormatDateTime('yyyy-mm-dd', now) + '.txt';
        PathRemoto := Sessao.PathIntegracao + 'VENDA_' + Sessao.Configuracao.EcfCaixaVO.Nome + '_' + FormatDateTime('yyyy-mm-dd', now) + '.txt';

        ExportarRegistro;
      finally
        Venda := nil;
      end;
    end
    else if Procedimento = 'EXPORTA_MOVIMENTO' then
    begin
      try
        Filtro := 'ID = ' + IntToStr(Sessao.Movimento.Id);
        Movimento := TEcfMovimentoController.ConsultaObjeto(Filtro);
        JsonString := Movimento.ToJSONString;

        PathLocal := ExtractFilePath(Application.ExeName) + 'Integracao\' + 'MOVIMENTO_' + Sessao.Configuracao.EcfCaixaVO.Nome + '_' + FormatDateTime('yyyy-mm-dd', now) + '.txt';
        PathRemoto := Sessao.PathIntegracao + 'MOVIMENTO_' + Sessao.Configuracao.EcfCaixaVO.Nome + '_' + FormatDateTime('yyyy-mm-dd', now) + '.txt';

        ExportarRegistro;
      finally
        Movimento := nil;
      end;
    end
    else if Procedimento = 'EXPORTA_R02' then
    begin
      try
        R02 := TR02VO.Create;
        JsonString := R02.ToJSONString;

        PathLocal := ExtractFilePath(Application.ExeName) + 'Integracao\' + 'R02_' + Sessao.Configuracao.EcfCaixaVO.Nome + '_' + FormatDateTime('yyyy-mm-dd', now) + '.txt';
        PathRemoto := Sessao.PathIntegracao + 'R02_' + Sessao.Configuracao.EcfCaixaVO.Nome + '_' + FormatDateTime('yyyy-mm-dd', now) + '.txt';

        ExportarRegistro;
      finally
        R02 := nil;
      end;
    end
    else if Procedimento = 'EXPORTA_R06' then
    begin
      try
        R06 := TR06VO.Create;
        JsonString := R06.ToJSONString;

        PathLocal := ExtractFilePath(Application.ExeName) + 'Integracao\' + 'R06_' + Sessao.Configuracao.EcfCaixaVO.Nome + '_' + FormatDateTime('yyyy-mm-dd', now) + '.txt';
        PathRemoto := Sessao.PathIntegracao + 'R06_' + Sessao.Configuracao.EcfCaixaVO.Nome + '_' + FormatDateTime('yyyy-mm-dd', now) + '.txt';

        ExportarRegistro;
      finally
        R06 := nil;
      end;
    end
    else if Procedimento = 'EXPORTA_SINTEGRA60M' then
    begin
      try
        Sintegra60M := TSintegra60mVO.Create;
        JsonString := Sintegra60M.ToJSONString;

        PathLocal := ExtractFilePath(Application.ExeName) + 'Integracao\' + 'SINTEGRA60M_' + Sessao.Configuracao.EcfCaixaVO.Nome + '_' + FormatDateTime('yyyy-mm-dd', now) + '.txt';
        PathRemoto := Sessao.PathIntegracao + 'SINTEGRA60M_' + Sessao.Configuracao.EcfCaixaVO.Nome + '_' + FormatDateTime('yyyy-mm-dd', now) + '.txt';

        ExportarRegistro;
      finally
        Sintegra60M := nil;
      end;
    end
    else if Procedimento = 'EXPORTA_NF' then
    begin
      try
        NotaFiscal := TNotaFiscalCabecalhoVO.Create;
        JsonString := NotaFiscal.ToJSONString;

        PathLocal := ExtractFilePath(Application.ExeName) + 'Integracao\' + 'NF_' + Sessao.Configuracao.EcfCaixaVO.Nome + '_' + FormatDateTime('yyyy-mm-dd', now) + '.txt';
        PathRemoto := Sessao.PathIntegracao + 'NF_' + Sessao.Configuracao.EcfCaixaVO.Nome + '_' + FormatDateTime('yyyy-mm-dd', now) + '.txt';

        ExportarRegistro;
      finally
        NotaFiscal := nil;
      end;
    end;
  finally
    FormatSettings.DecimalSeparator := ',';
    FCaixa.LabelMensagens.Caption := 'CAIXA ABERTO';
    Application.ProcessMessages;
    Close;
  end;
end;
{$EndRegion 'Exportacao'}


end.
