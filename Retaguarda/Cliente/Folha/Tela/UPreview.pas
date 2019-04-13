unit UPreview;

interface

uses
  BrookHTTPClient, BrookFCLHTTPClientBroker, BrookHTTPUtils, BrookUtils, FPJson, ZDataset,
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UTelaCadastro, Menus, StdCtrls, ExtCtrls, Buttons, Grids, DBGrids,
  ComCtrls, LabeledCtrls, rxdbgrid, rxtoolbar, DBCtrls, StrUtils,
  Math, Constantes, CheckLst, ActnList, ToolWin, ShellApi, db, BufDataset, Biblioteca,
  ULookup, VO;

  type
  TFPreview = class(TForm)
    PrinterSetupDialog1: TPrinterSetupDialog;
    RichEdit: TRichEdit;
    SaveDialog1: TSaveDialog;
    RichEdit2: TRichEdit;
    ActionManager1: TActionList;
    ActionSair: TAction;
    ActionSalvar: TAction;
    ActionConfigurarImpressora: TAction;
    ActionImprimir: TAction;
    ActionToolBar1: TToolPanel;
    procedure ActionSairExecute(Sender: TObject);
    procedure ActionSalvarExecute(Sender: TObject);
    procedure ActionConfigurarImpressoraExecute(Sender: TObject);
    procedure BotaoConsultarClick(Sender: TObject);
    procedure BotaoSalvarClick(Sender: TObject);
  private
  public
  published
  end;

var
  FPreview: TFPreview;

implementation

uses UDataModule;
  BrookHTTPClient, BrookFCLHTTPClientBroker, BrookHTTPUtils, BrookUtils, FPJson, ZDataset,
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UTelaCadastro, Menus, StdCtrls, ExtCtrls, Buttons, Grids, DBGrids,
  ComCtrls, LabeledCtrls, rxdbgrid, rxtoolbar, DBCtrls, StrUtils,
  Math, Constantes, CheckLst, ActnList, ToolWin, ShellApi, db, BufDataset, Biblioteca,
  ULookup, VO;


var
  F: TextFile;
{$R *.lfm}

procedure TFPreview.ActionConfigurarImpressoraExecute(Sender: TObject);
begin
  PrinterSetupDialog1.execute;
end;

procedure TFPreview.ActionSairExecute(Sender: TObject);
begin
  close;
end;

procedure TFPreview.ActionSalvarExecute(Sender: TObject);
begin
  SaveDialog1.InitialDir := ExtractFilePath(Application.ExeName);
  if SaveDialog1.execute then
  begin
    RichEdit.Lines.SaveToFile(SaveDialog1.FileName);
  end;
end;

end.

