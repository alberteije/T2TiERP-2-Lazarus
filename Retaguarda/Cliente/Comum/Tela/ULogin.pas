{ *******************************************************************************
Title: T2Ti ERP
Description: Janela de Login

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
           t2ti.com@gmail.com

@author Albert Eije (t2ti.com@gmail.com)
@version 2.0
******************************************************************************* }
unit ULogin;

{$MODE Delphi}

interface

uses
  LCLIntf, LCLType, LMessages, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UBase, StdCtrls, ExtCtrls, Buttons, DB, BufDataset, Grids,
  DBGrids, IniFiles, Biblioteca, UMenu;

type
  TFLogin = class(TFBase)
    Label1: TLabel;
    Label2: TLabel;
    Image1: TImage;
    BotaoConfirma: TBitBtn;
    EditLogin: TEdit;
    EditSenha: TEdit;
    BotaoCancela: TBitBtn;
    CDSEmpresaUsuario: TBufDataSet;
    DSEmpresaUsuario: TDataSource;
    Grid: TDBGrid;
    procedure BotaoCancelaClick(Sender: TObject);
    procedure BotaoConfirmaClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormShow(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure GridKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    { Private declarations }
    function DoLogin: Boolean;
  public
    { Public declarations }
    Logado: Boolean;
  end;

var
  FLogin: TFLogin;

implementation

{$R *.lfm}
{ TFLogin }

procedure TFLogin.BotaoCancelaClick(Sender: TObject);
begin
end;

procedure TFLogin.BotaoConfirmaClick(Sender: TObject);
begin
  try
    if DoLogin then
    begin
      Logado := True;
      Close;

      {
      TViewSessaoEmpresaController.SetDataSet(CDSEmpresaUsuario);
      TViewSessaoEmpresaController.Consulta('ID_PESSOA = ' + IntToStr(Sessao.Usuario.ColaboradorVO.IdPessoa), 0);

      if CDSEmpresaUsuario.RecordCount > 1 then
      begin
        Self.Height := 335;
        Self.Grid.SetFocus;
      end
      else
      begin
        Sessao.Empresa := TEmpresaController.EmpresaSessao('ID=' + CDSEmpresaUsuarioID_EMPRESA.AsString);
        Sessao.IdEmpresa := Sessao.Empresa.Id;
        TUsuarioController.EmpresaNaSessao;
        Close;
      end;
    end
    else
    begin
      Application.MessageBox('Não foi possível realizar o login.', 'Atenção', MB_OK + MB_ICONWARNING);
      EditLogin.SetFocus;
    end;
    }
    end;
  except
  end;
end;

function TFLogin.DoLogin: Boolean;
begin
  Result := True;
  {
  try
    if ExtractFileName(Application.ExeName) = 'T2TiAdministrativo.exe' then
      Result := Sessao.AutenticaUsuarioAdm(EditLogin.Text, EditSenha.Text)
    else
      Result := Sessao.AutenticaUsuario(EditLogin.Text, EditSenha.Text);
  except
    Result := False;
  end;
  }
end;

procedure TFLogin.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  inherited;
  CanClose := Logado;
end;

procedure TFLogin.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = VK_F11 then
    BotaoCancela.Click;
  if Key = VK_F12 then
    BotaoConfirma.Click;
end;

procedure TFLogin.FormShow(Sender: TObject);
begin
  inherited;
  Logado := False;
  EditLogin.SetFocus;
end;

procedure TFLogin.GridKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  {
  if key = VK_RETURN then
  begin
    Sessao.Empresa := TEmpresaController.EmpresaSessao('ID=' + CDSEmpresaUsuarioID_EMPRESA.AsString);
    Sessao.IdEmpresa := Sessao.Empresa.Id;
    Close;
  end;
  }
end;

end.
