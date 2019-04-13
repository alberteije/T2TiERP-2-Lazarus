{*******************************************************************************
  Title: T2TiPDV
  Description: DataModule

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
unit UDataModule;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, ACBrTEFDClass, Forms, ACBrDevice, ACBrBase, ACBrECF, FMTBcd,
  DB, Classes, StdCtrls, Controls, LCLIntf, LCLType, LMessages, ACBrUtil, dateutils,
  strutils, Dialogs, Inifiles, ACBrECFClass, ZConnection;

type

  { TFDataModule }

  TFDataModule = class(TDataModule)
    ACBrECF: TACBrECF;
    Conexao: TZConnection;
    OpenDialog: TOpenDialog;
    procedure DataModuleCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    RemoteAppPath: string;
  end;

var
  FDataModule: TFDataModule;

implementation

uses UConfigConexao, Biblioteca, USplash;
{$R *.lfm}

procedure TFDataModule.DataModuleCreate(Sender: TObject);
var
  ini: TIniFile;
  BancoPAF: String;
begin
  (*
  FSplash.lbMensagem.Caption := 'Conectando a Base de Dados...';
  FSplash.lbMensagem.Refresh;

  Conexao.Connected := False;

  try
    ini := TIniFile.Create(ExtractFilePath(Application.ExeName) + 'Conexao.ini');
    BancoPAF := UpperCase(ini.ReadString('SGBD', 'BD', ''));
    RemoteAppPath := UpperCase(ini.ReadString('IMPORTA', 'REMOTEAPP', ''));

    if BancoPAF = 'MYSQL' then
      Conexao.Protocol := 'mysql'
    else if BancoPAF = 'FIREBIRD' then
      Conexao.Protocol := 'firebird-2.5';

    Conexao.HostName := ini.ReadString('SGBD', 'BDHostName', '');
    Conexao.Database := ini.ReadString('SGBD', 'BDDatabase', '');
    Conexao.User := ini.ReadString('SGBD', 'BDUser', '');
    Conexao.Password := ini.ReadString('SGBD', 'BDPassword', '');

  finally
    FreeAndNil(ini);
  end;

  try
    FSplash.Repaint;
    Conexao.Connected := True;
    FSplash.lbMensagem.Caption := 'Conectando a Base de Dados local...';
    FSplash.lbMensagem.Refresh;
    FSplash.imgBanco.Visible := True;
    // SetTaskBar(false); //descomente se quiser que a barra do windows desapareça

  except
    FSplash.lbMensagem.Caption := 'Falha ao tentar conectar a Base de Dados';
    FSplash.lbMensagem.Refresh;

    Application.CreateForm(TFConfigConexao, FConfigConexao);
    if FConfigConexao.ShowModal <> mrOK then
    begin
      SetTaskBar(True);
      ACBrECF.Desativar;
      Application.ProcessMessages;
      Application.Terminate;
    end
    else
    begin
      SetTaskBar(False);
      FSplash.imgBanco.Visible := True;
    end;
  end;
  *)
end;

end.
