program Integracao;

{$mode objfpc}{$H+}

uses
  Forms,
  LCLIntf, LCLType, LMessages, Interfaces,
  UIntegracaoPDV in 'UIntegracaoPDV.pas' { FIntegracaoPDV } ,
  UDataModuleConexao in 'UDataModuleConexao.pas' {FDataModuleConexao: TDataModule},
  ImportaController in 'Controller\ImportaController.pas',
  LogImportacaoController in 'Controller\LogImportacaoController.pas',
  LogImportacaoVO in 'VO\LogImportacaoVO.pas';
{$R *.res}

var
  Instancia: THandle;

begin
    Application.Initialize;
    Application.MainFormOnTaskbar := True;
    Application.CreateForm(TFIntegracaoPDV, FIntegracaoPDV);
    Application.CreateForm(TFDataModuleConexao, FDataModuleConexao);
    Application.Run;
end.
