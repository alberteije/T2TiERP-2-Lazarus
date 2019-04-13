program ConfiguraPAFECF;

{$mode objfpc}{$H+}

uses
  Forms, Interfaces,
  UConfiguracao in 'UConfiguracao.pas' {FConfiguracao},
  UDataModule in 'UDataModule.pas' {FDataModule: TDataModule},
  UConfigConexao in 'UConfigConexao.pas' {FConfigConexao},
  Biblioteca in 'Biblioteca.pas',
  Constantes in 'Constantes.pas',
  ConfiguracaoController in 'Controller\ConfiguracaoController.pas',
  USplash in 'USplash.pas' {FSplash};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFConfiguracao, FConfiguracao);
  Application.Run;
end.
