unit UPenDrive;

{$mode objfpc}{$H+}

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, FileCtrl, ExtCtrls, UBase;

type

  { TFPenDrive }

  TFPenDrive = class(TFBase)
    ListTXT: TFileListBox;
    GroupBox1: TGroupBox;
    editPath: TEdit;
    SpeedButton1: TSpeedButton;
    Image1: TImage;
    botaoCancela: TBitBtn;
    OpenDialog: TOpenDialog;
    procedure botaoCancelaClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure SpeedButton1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure FormActivate(Sender: TObject);
  private
    { Private declarations }
  public
    Rotina :string;
    { Public declarations }
  end;

var
  FPenDrive: TFPenDrive;

implementation

uses UCargaPDV, UCaixa;

{$R *.lfm}

procedure TFPenDrive.FormActivate(Sender: TObject);
begin
  Color := StringToColor(Sessao.Configuracao.CorJanelasInternas);
end;

procedure TFPenDrive.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  CloseAction := caFree;
  FPenDrive := nil;
end;

procedure TFPenDrive.FormShow(Sender: TObject);
begin
  if Rotina = 'IMPORTA' then
    Caption := 'Rotina de importação de dados do Pen-Drive'
  else if Rotina = 'EXPORTA' then
    Caption := 'Rotina de exportação de dados para Pen-Drive';

  editPath.Text := '';
end;

procedure TFPenDrive.SpeedButton1Click(Sender: TObject);
var
  iContaTXT: Integer;
  LocalApp, RemoteApp: String;
begin
  if OpenDialog.Execute then
  begin
    editPath.Text:= trim(OpenDialog.InitialDir);
    if Rotina = 'IMPORTA' then
    begin
      if FileExists(editPath.Text+'\carga.txt') then
      begin
        if FCargaPDV = nil then
          Application.CreateForm(TFCargaPDV, FCargaPDV);
//        FCargaPDV.Tipo := 4;
        FCargaPDV.ShowModal;
        Application.ProcessMessages;
      end;//if FileExists(editPath.Text+'\carga.txt') then
    end
    else
    if Rotina = 'EXPORTA' then
    begin
      if DirectoryExists(editPath.Text) then
      begin
        ListTXT.Mask      := 'C*.txt';
        ListTXT.Directory := ExtractFilePath(Application.ExeName)+'Script\';
        ListTXT.Update;
        Application.ProcessMessages;
        for iContaTXT := 0 to ListTXT.Count -1 do
        begin
          LocalApp :=  ExtractFilePath(Application.ExeName)+'Script\'+ListTXT.Items[iContaTXT];
          RemoteApp := editPath.Text+'\'+ListTXT.Items[iContaTXT];
          if (FileExists(LocalApp)) and (LocalApp <> ExtractFilePath(Application.ExeName)+'Script\carga.txt') then
             if CopyFile(PChar(LocalApp), PChar(RemoteApp), False) then
                Application.ProcessMessages;
          LocalApp := '';
        end;//for iContaTXT := 0 to ListTXT.Count -1 do
        ShowMessage('Arquivos copiados para o Pen-Drive');
      end;//if DirectoryExists(editPath.Text) then
    end;//if Rotina = 'IMPORTA' then
  end;//if FolderDialog.Execute then
end;

procedure TFPenDrive.botaoCancelaClick(Sender: TObject);
begin
  Close;
end;

procedure TFPenDrive.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = VK_ESCAPE then
    botaoCancela.Click;
end;

end.
