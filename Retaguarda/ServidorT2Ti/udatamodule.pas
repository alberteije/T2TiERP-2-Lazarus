unit UDataModule;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, ACBrSpedFiscal, ACBrSpedPisCofins, ACBrSintegra;

type

  { TFDataModule }

  TFDataModule = class(TDataModule)
    ACBrSintegra: TACBrSintegra;
    ACBrSPEDFiscal: TACBrSPEDFiscal;
    ACBrSPEDContribuicoes: TACBrSPEDPisCofins;
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  FDataModule: TFDataModule;

implementation

{$R *.lfm}

end.

