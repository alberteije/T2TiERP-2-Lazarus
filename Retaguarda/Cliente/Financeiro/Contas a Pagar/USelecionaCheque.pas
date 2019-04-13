{ *******************************************************************************
Title: T2Ti ERP
Description: Janela para selecionar o cheque para pagamento

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
unit USelecionaCheque;

{$MODE Delphi}

interface

uses
  BrookHTTPClient, BrookFCLHTTPClientBroker, BrookHTTPUtils, BrookUtils, FPJson, ZDataset,
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UTelaCadastro, Menus, StdCtrls, ExtCtrls, Buttons, Grids, DBGrids,
  ComCtrls, LabeledCtrls, rxdbgrid, rxtoolbar, DBCtrls, StrUtils,
  Math, Constantes, CheckLst, ActnList, ToolWin, ShellApi, db, BufDataset, Biblioteca,
  ULookup, VO, UFinParcelaPagamento;

  type
  TFSelecionaCheque = class(TForm)
    PanelCabecalho: TPanel;
    Bevel1: TBevel;
    Image1: TImage;
    Label2: TLabel;
    ActionToolBarPrincipal: TToolPanel;
    ActionManagerLocal: TActionList;
    ActionCancelar: TAction;
    PageControlItens: TPageControl;
    tsDados: TTabSheet;
    PanelDados: TPanel;
    CDSChequesEmSer: TBufDataSet;
    DSChequesEmSer: TDataSource;
    GridCheques: TRxDbGrid;
    CDSChequesEmSerID_CONTA_CAIXA: TIntegerField;
    CDSChequesEmSerNOME_CONTA_CAIXA: TStringField;
    CDSChequesEmSerTALAO: TStringField;
    CDSChequesEmSerNUMERO_TALAO: TIntegerField;
    CDSChequesEmSerNUMERO_CHEQUE: TIntegerField;
    CDSChequesEmSerID_TALAO: TIntegerField;
    CDSChequesEmSerID_CHEQUE: TIntegerField;
    EditBomPara: TLabeledDateEdit;
    EditValorCheque: TLabeledCalcEdit;
    MemoHistorico: TLabeledMemo;
    Bevel2: TBevel;
    EditNominalA: TLabeledEdit;
    ActionConfirmar: TAction;
    procedure ActionCancelarExecute(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ActionConfirmarExecute(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    Confirmou: Boolean;
  end;

var
  FSelecionaCheque: TFSelecionaCheque;

implementation

uses
  UMenu, ViewFinChequesEmSerController;
{$R *.lfm}

procedure TFSelecionaCheque.ActionCancelarExecute(Sender: TObject);
begin
  Close;
end;

procedure TFSelecionaCheque.ActionConfirmarExecute(Sender: TObject);
begin
  if Trim(RetiraMascara(EditBomPara.Text)) = '' then
  begin
    Application.MessageBox('É necessário informar a data do cheque.', 'Mensagem do Sistema', MB_OK + MB_ICONINFORMATION);
    EditBomPara.SetFocus;
    Exit;
  end;
  if EditValorCheque.Value <= 0 then
  begin
    Application.MessageBox('É necessário informar o valor do cheque.', 'Mensagem do Sistema', MB_OK + MB_ICONINFORMATION);
    EditValorCheque.SetFocus;
    Exit;
  end;
  Confirmou := True;
  Close;
end;

procedure TFSelecionaCheque.FormShow(Sender: TObject);
var
  Filtro: String;
  RetornoConsulta: TZQuery;
  ListaCampos: TStringList;
  I: Integer;
begin
  Confirmou := False;

  if ((FMenu.PageControl.ActivePage.Components[0] as TForm) as TFFinParcelaPagamento).EditIdContaCaixa.Value > 0 then
  begin
    Filtro := 'ID_CONTA_CAIXA=' + QuotedStr(((FMenu.PageControl.ActivePage.Components[0] as TForm) as TFFinParcelaPagamento).EditIdContaCaixa.Text);
  end
  else
  begin
    Filtro := 'ID_CONTA_CAIXA > 0';
  end;

  CDSChequesEmSer.Close;
  CDSChequesEmSer.Open;

  ListaCampos  := TStringList.Create;
  RetornoConsulta := TViewFinChequesEmSerController.Consulta(Filtro, '0');
  RetornoConsulta.Active := True;

  RetornoConsulta.GetFieldNames(ListaCampos);

  RetornoConsulta.First;
  while not RetornoConsulta.EOF do begin
    CDSChequesEmSer.Append;
    for i := 0 to ListaCampos.Count - 1 do
    begin
      CDSChequesEmSer.FieldByName(ListaCampos[i]).Value := RetornoConsulta.FieldByName(ListaCampos[i]).Value;
    end;
    CDSChequesEmSer.Post;
    RetornoConsulta.Next;
  end;

  EditNominalA.SetFocus;
end;

end.

