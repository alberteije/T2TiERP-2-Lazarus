{*******************************************************************************
Title: T2TiPDV
Description: Janela principal do sistema de integração

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
           alberteije@gmail.com

@author T2Ti.COM
@version 2.0
*******************************************************************************}
unit UIntegracaoPDV;

{$mode objfpc}{$H+}

interface

uses
  LCLIntf, LCLType, LMessages, Messages, SysUtils, Variants, Classes, Graphics,
  Controls, Forms, Dialogs, ExtCtrls, StdCtrls, Buttons, FileCtrl, Registry,
  ComCtrls, FileUtil, IniFiles, md5;

type

  { TFIntegracaoPDV }

  TFIntegracaoPDV = class(TForm)
    ListSemaforo: TFileListBox;
    TimerIntegracao: TTimer;
    ListTXT: TFileListBox;
    pBanco: TProgressBar;
    pLabel: TPanel;
    procedure FormCreate(Sender: TObject);
    procedure TimerIntegracaoTimer(Sender: TObject);
    function ImportaPDV:boolean;
  private
    Contador:integer;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FIntegracaoPDV: TFIntegracaoPDV;
  RemoteAppPath: String;

implementation

uses Biblioteca, ImportaController, LogImportacaoController;

{$R *.lfm}

{
  Procedimentos executados quando o formulário é criado
}
procedure TFIntegracaoPDV.FormCreate(Sender: TObject);
var
  ArquivoIni: TIniFile;
begin
  try
    ArquivoIni := TIniFile.Create(ExtractFilePath(Application.ExeName) + 'Conexao.ini');
    RemoteAppPath := UpperCase(ArquivoIni.ReadString('IMPORTA', 'REMOTEAPP', ''));
  finally
    FreeAndNil(ArquivoIni);
  end;

  Contador := 0;
  pLabel.Caption := '';
  TimerIntegracao.Enabled := True;
end;

{
  Timer que controla a integração
}
procedure TFIntegracaoPDV.TimerIntegracaoTimer(Sender: TObject);
begin
  if ImportaPDV then
  begin
    if pBanco.Position >= 30 then
      pBanco.Position := 1;

    pBanco.Position := pBanco.Position + 1;
    TimerIntegracao.Enabled:=true;
  end;
end;

{
  Método chamado pelo Timer que controla a integração
}
function TFIntegracaoPDV.ImportaPDV: Boolean;
var
  RemoteApp, LocalApp: String;
  i: integer;
  iContaTXT: integer;
  DataTXT: TDate;
  Filtro, tupla: String;
  ArquivoImportaPDV: TextFile;
begin
  try
    TimerIntegracao.Enabled := False;

    try
      Result := false;

      // aponta o componente ListSemaforo para o caminho remoto para verificar se algum caixa está copiando um arquivo
      ListSemaforo.Mask := '*.semaforo';
      ListSemaforo.Directory := RemoteAppPath;
      ListSemaforo.Update;

      // aponta o componente ListTXT para o caminho remoto para carregar os arquivos TXT
      ListTXT.Mask := '*.txt';
      ListTXT.Directory := RemoteAppPath;
      ListTXT.Update;

      // caso não exista o diretória, cria
      ForceDirectories(ExtractFilePath(Application.ExeName) + 'Script');

      // executa o laço pela quantidade de arquivos "TXT" que foram carregados no componente ListTXT
      for iContaTXT := 0 to ListTXT.Count - 1 do
      begin
        // seta a variável com o nome do arquivo selecionado no momento no componente ListTXT
        RemoteApp := RemoteAppPath + RemoteApp + ListTXT.Items[iContaTXT];

        // se não existir "semaforo", ou seja, não existe nenhum processo sendo realizado na pasta, continua a execução
        if ListSemaforo.Count <= 0 then
        begin

          // se existir o arquivo, continua a execução
          if FileExists(RemoteApp) then
          begin

            // recebe o caminho da aplicação + pasta 'script' + Nome do arquivo
            LocalApp := ExtractFilePath(Application.ExeName) + 'Script\' + ExtractFileName(RemoteApp);

            // copia o arquivo do caminho remoto para ao local e se der certo continua a execucao
            if CopyFile(PChar(RemoteApp), PChar(LocalApp), false) then
            begin
              // chama o método para importar os dados do PDV e se der certo remove o arquivo remoto
              if TImportaController.ImportarDadosDoPDV(LocalApp) then
              begin
                if Md5Print(MD5File(LocalApp)) = Md5Print(MD5File(RemoteApp)) then
                  DeleteFile(PChar(RemoteApp));
              end;
            end;
          end;
        end;
        RemoteApp := '';
      end;
    except
      // Se ocorrer algum erro, grava o log de importação
      on E: Exception do
        TLogImportacaoController.GravarLogImportacao(LocalApp, E.Message);
    end;
  finally
    Result := True;
  end;
end;

end.
