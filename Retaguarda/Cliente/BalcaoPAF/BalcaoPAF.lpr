program BalcaoPAF;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, rxnew, printer4lazarus, EmpresaVO, UsuarioVO, VO, ProdutoVO, DavCabecalhoVO, DavDetalheVO, ContadorVO, Biblioteca, Constantes, UDataModule,
  Tipos, SessaoUsuario, UBase, UTela, UFiltro, UTelaCadastro, ULookup, umenu, uproduto, UDAV, UPreview, USpedFiscal, USintegra, USpedContribuicoes;

{$R *.res}

begin
  RequireDerivedFormResource := True;
  Application.Initialize;
  Application.CreateForm(TFMenu, FMenu);
  Application.CreateForm(TFDataModule, FDataModule);
  Application.Run;
end.

