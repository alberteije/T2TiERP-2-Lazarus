{*******************************************************************************
Title: T2TiPDV
Description: Tela que aparece após efetuarem todos os pagamentos.

The MIT License

Copyright: Copyright (C) 2012 T2Ti.COM

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
@version 1.0
*******************************************************************************}
unit UFechaEfetuaPagamento;

{$mode objfpc}{$H+}

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, UBase;

type
  TFFechaEfetuaPagamento = class(TFBase)
    Timer1: TTimer;
    Panel1: TPanel;
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure Timer1Timer(Sender: TObject);
    procedure FormClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FFechaEfetuaPagamento: TFFechaEfetuaPagamento;

implementation

uses UCaixa, UDataModule;

{$R *.lfm}

procedure TFFechaEfetuaPagamento.FormClick(Sender: TObject);
begin
  Close;
end;

procedure TFFechaEfetuaPagamento.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  CloseAction := caFree;
  FFechaEfetuaPagamento := nil;
end;

procedure TFFechaEfetuaPagamento.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  case Key of
    VK_RETURN:
      Close;
    VK_ESCAPE:
      Close;
  end;
end;

procedure TFFechaEfetuaPagamento.FormShow(Sender: TObject);
begin
  Panel1.Caption := 'Enter ou ESC para continuar';
  Panel1.Color := clYellow;
  Timer1.Enabled := true;
end;

procedure TFFechaEfetuaPagamento.Timer1Timer(Sender: TObject);
begin
  if Panel1.Font.Color = clBlack then
  begin
    Panel1.Color := clRed;
    Panel1.Font.Color := clWhite;
  end
  else
  begin
    Panel1.Font.Color := clBlack;
    Panel1.Color := clYellow;
  end;
end;

end.
