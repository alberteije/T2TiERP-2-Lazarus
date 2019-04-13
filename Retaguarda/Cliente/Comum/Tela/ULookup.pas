{ *******************************************************************************
Title: T2Ti ERP
Description: Janela de Lookup

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
           t2ti.com@gmail.com

@author Albert Eije (t2ti.com@gmail.com)
@version 2.0
******************************************************************************* }
unit ULookup;

{$MODE Delphi}

interface

uses
  LCLIntf, LCLType, LMessages, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Grids, DBGrids,  StdCtrls, ExtCtrls, Buttons, DB, BufDataset, TypInfo,
  UBase, LabeledCtrls;

type
  TFLookup = class(TFBase)
    PanelFiltroRapido: TPanel;
    Grid: TDBGrid;
    BotaoPesquisa: TSpeedButton;
    DSLookup: TDataSource;
    CDSLookup: TBufDataSet;
    Panel1: TPanel;
    BotaoImporta: TSpeedButton;
    BotaoSair: TSpeedButton;
    ComboBoxCampos: TLabeledComboBox;
    ComboBoxCoincidir: TLabeledComboBox;
    EditCriterioRapido: TLabeledMaskEdit;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormActivate(Sender: TObject);
    procedure BotaoPesquisaClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure EditCriterioRapidoKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure GridKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure BotaoImportaClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure GridDblClick(Sender: TObject);
    procedure GridKeyPress(Sender: TObject; var Key: Char);
    procedure EditCriterioRapidoEnter(Sender: TObject);
    procedure ComboBoxCamposClick(Sender: TObject);
    procedure EditCriterioRapidoExit(Sender: TObject);
    procedure BotaoSairClick(Sender: TObject);

  private
    { Private declarations }
  public
    { Public declarations }
    ObjetoVO: TObject;
    DataSetField: TField;
    IdSelecionado: String; //utilizado enquanto o participante não implementa o restante da janela
    procedure FormataEditCriterio;
  end;

var
  FLookup: TFLookup;
  PressionouEsc: Boolean;

implementation

uses Biblioteca;
{$R *.lfm}

procedure TFLookup.EditCriterioRapidoEnter(Sender: TObject);
begin
  //FormataEditCriterio;
  EditCriterioRapido.SelectAll;
end;

procedure TFLookup.EditCriterioRapidoExit(Sender: TObject);
begin
  inherited;
  if EditCriterioRapido.Text <> '' then
    BotaoPesquisa.OnClick(Sender);
end;

procedure TFLookup.EditCriterioRapidoKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = VK_RETURN then
    Grid.SetFocus;
end;

procedure TFLookup.FormActivate(Sender: TObject);
begin
  EditCriterioRapido.Clear;
  EditCriterioRapido.SetFocus;
  (*
  Exercício:

  Configurar grid de acordo com o objeto que será consultado
  *)
end;

procedure TFLookup.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  (*
  Exercício:

  Retornar objeto consultado para janela que chamou
  *)
end;

procedure TFLookup.FormDestroy(Sender: TObject);
begin
  //ObjetoVO.Free;
  inherited;
end;

procedure TFLookup.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = VK_F9 then
    BotaoPesquisa.Click;

  if Key = VK_F12 then
    BotaoImporta.Click;

  if (Key = VK_ESCAPE) or (Key = VK_F8) then
  begin
    PressionouEsc := True;
    Close;
  end;
end;

procedure TFLookup.GridDblClick(Sender: TObject);
begin
  inherited;
  if CDSLookup.RecordCount > 0 then
    BotaoImporta.OnClick(Self);
end;

procedure TFLookup.GridKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = VK_RETURN then
    EditCriterioRapido.SetFocus;
end;

procedure TFLookup.GridKeyPress(Sender: TObject; var Key: Char);
begin
  inherited;
  if Key = #13 then
    Grid.OnDblClick(Self);
end;

procedure TFLookup.BotaoImportaClick(Sender: TObject);
begin
  IdSelecionado := EditCriterioRapido.Text;
  Close;
end;

procedure TFLookup.BotaoPesquisaClick(Sender: TObject);
var
  Filtro, Operador: String;
  Pagina, idx: Integer;
begin
  (*
  Exercício: Implementar a busca pelo objeto desejado

  try
    if Trim(EditCriterioRapido.Text) = '' then
      EditCriterioRapido.Text := '*';

    Pagina := 0;
    idx := ComboBoxCampos.ItemIndex;
//    DataSetField := CDSLookup.FindField(CDSLookup.FieldList.Fields[idx].FieldName);

    if (DataSetField.DataType = ftDateTime) then
    begin
      Filtro := CDSLookup.Fields[idx].FieldName + ' IN ' + Quotedstr(FormatDateTime('yyyy-mm-dd',StrToDate(EditCriterioRapido.Text)));
    end
    else
    begin
      case ComboBoxCoincidir.ItemIndex of
        // início do campo
        0 : Filtro := CDSLookup.Fields[idx].FieldName + ' LIKE ' + Quotedstr(EditCriterioRapido.Text + '*');
        // qualquer parte
        1 : Filtro := CDSLookup.Fields[idx].FieldName + ' LIKE ' + Quotedstr('*' + EditCriterioRapido.Text + '*');
        // fim do campo
        2 : Filtro := CDSLookup.Fields[idx].FieldName + ' LIKE ' + Quotedstr('*' + EditCriterioRapido.Text);
        // valor identico
        3 : Filtro := CDSLookup.Fields[idx].FieldName + ' LIKE ' + Quotedstr(EditCriterioRapido.Text);
      end;
      BotaoImporta.Enabled := CDSLookup.State = dsBrowse;

    end;
  finally
  end;
  *)
end;

procedure TFLookup.BotaoSairClick(Sender: TObject);
begin
  inherited;
end;

procedure TFLookup.ComboBoxCamposClick(Sender: TObject);
begin
  inherited;
  //FormataEditCriterio;
end;

procedure TFLookup.FormataEditCriterio;
var
  Item: String;
  idx: Integer;
begin
  idx := ComboBoxCampos.ItemIndex;
  Item := CDSLookup.Fields[idx].FieldName;
  DataSetField := CDSLookup.FindField(Item);
  if DataSetField.DataType = ftDateTime then
  begin
    EditCriterioRapido.EditMask := '99/99/9999;1;_';
    EditCriterioRapido.Clear;
  end
  else
    EditCriterioRapido.EditMask := '';
    EditCriterioRapido.Clear;
end;


end.
