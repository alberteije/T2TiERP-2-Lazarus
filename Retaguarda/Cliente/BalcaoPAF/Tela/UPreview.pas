unit UPreview;

{$MODE Delphi}

interface

uses
  LCLIntf, LCLType, LMessages, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Buttons, StdCtrls, ExtCtrls, ComCtrls, ActnList, ToolWin, PrintersDlgs;

type

  { TFPreview }

  TFPreview = class(TForm)
    Panel1: TPanel;
    PrinterSetupDialog1: TPrinterSetupDialog;
    RichEdit: TMemo;
    SaveDialog1: TSaveDialog;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    SpeedButton3: TSpeedButton;
    SpeedButton4: TSpeedButton;
    procedure SpeedButton1Click(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
    procedure SpeedButton3Click(Sender: TObject);
    procedure SpeedButton4Click(Sender: TObject);
  private
  public
  published
  end;

var
  FPreview: TFPreview;

implementation

uses UDataModule;

var
  F: TextFile;
{$R *.lfm}

procedure TFPreview.SpeedButton1Click(Sender: TObject);
begin
  PrinterSetupDialog1.execute;
end;

procedure TFPreview.SpeedButton2Click(Sender: TObject);
begin
  { Exercício : Implemente essa funcionalidade }
end;

procedure TFPreview.SpeedButton3Click(Sender: TObject);
begin
  SaveDialog1.InitialDir := ExtractFilePath(Application.ExeName);
  if SaveDialog1.execute then
  begin
    RichEdit.Lines.SaveToFile(SaveDialog1.FileName);
  end;
end;

procedure TFPreview.SpeedButton4Click(Sender: TObject);
begin
  close;
end;

end.
