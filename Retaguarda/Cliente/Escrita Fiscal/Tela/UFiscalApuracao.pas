{ *******************************************************************************
Title: T2Ti ERP
Description: Janela Apuração para o módulo Escrita Fiscal

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
t2ti.com@gmail.com</p>

@author Albert Eije (alberteije@gmail.com)
@version 2.0
******************************************************************************* }
unit UFiscalApuracao;

{$MODE Delphi}

interface

uses
  BrookHTTPClient, BrookFCLHTTPClientBroker, BrookHTTPUtils, BrookUtils, FPJson, ZDataset,
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UTelaCadastro, Menus, StdCtrls, ExtCtrls, Buttons, Grids, DBGrids,
  ComCtrls, LabeledCtrls, rxdbgrid, rxtoolbar, DBCtrls, StrUtils,
  Math, Constantes, CheckLst, ActnList, ToolWin, ShellApi, db, BufDataset, Biblioteca,
  ULookup, VO;

  type
  TFFiscalApuracao = class(TForm)
    PanelCabecalho: TPanel;
    Bevel1: TBevel;
    Image1: TImage;
    Label2: TLabel;
    ActionToolBarPrincipal: TToolPanel;
    ActionManagerLocal: TActionList;
    ActionCancelar: TAction;
    ActionProcessaPeriodo: TAction;
    PageControlItens: TPageControl;
    tsDados: TTabSheet;
    PanelDados: TPanel;
    ActionSair: TAction;
    EditCompetencia: TLabeledMaskEdit;
    Bevel2: TBevel;
    GridDetalhe: TRxDbGrid;
    DSApuracao: TDataSource;
    CDSApuracao: TBufDataSet;
    procedure ActionCancelarExecute(Sender: TObject);
    procedure ActionSairExecute(Sender: TObject);
    procedure ActionProcessaPeriodoExecute(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FFiscalApuracao: TFFiscalApuracao;

implementation

uses
  UDataModule, FiscalApuracaoIcmsVO, FiscalApuracaoIcmsController;
{$R *.lfm}

procedure TFFiscalApuracao.ActionCancelarExecute(Sender: TObject);
begin
  Close;
end;

procedure TFFiscalApuracao.ActionSairExecute(Sender: TObject);
begin
  Close;
end;

procedure TFFiscalApuracao.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = VK_ESCAPE then
    Close;
end;

procedure TFFiscalApuracao.FormShow(Sender: TObject);
begin
  ConfiguraCDSFromVO(CDSApuracao, TFiscalApuracaoIcmsVO);
  ConfiguraGridFromVO(GridDetalhe, TFiscalApuracaoIcmsVO);

  EditCompetencia.Text := FormatDateTime('MM/YYYY', Now);
  EditCompetencia.SetFocus;
end;

procedure TFFiscalApuracao.ActionProcessaPeriodoExecute(Sender: TObject);
var
  RetornoConsulta: TZQuery;
  ListaCampos: TStringList;
  i: integer;
begin
  CDSApuracao.Close;
  CDSApuracao.Open;

  ListaCampos  := TStringList.Create;
  RetornoConsulta := TFiscalApuracaoIcmsController.FiscalApuracaoIcms(Trim(EditCompetencia.Text));
  RetornoConsulta.Active := True;

  RetornoConsulta.GetFieldNames(ListaCampos);

  RetornoConsulta.First;
  while not RetornoConsulta.EOF do begin
    CDSApuracao.Append;
    for i := 0 to ListaCampos.Count - 1 do
    begin
      CDSApuracao.FieldByName(ListaCampos[i]).Value := RetornoConsulta.FieldByName(ListaCampos[i]).Value;
    end;
    CDSApuracao.Post;
    RetornoConsulta.Next;
  end;
end;

end.

