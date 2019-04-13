{ *******************************************************************************
Title: T2Ti ERP
Description: Janela Padrão de Cadastro

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

Albert Eije (T2Ti.COM)
@version 2.0
******************************************************************************* }
unit UTelaCadastro;

{$MODE Delphi}

interface

uses
  BrookHTTPClient, BrookFCLHTTPClientBroker, BrookHTTPUtils, BrookUtils,
  LCLIntf, LCLType, LMessages, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UTela, DB, BufDataset, Menus, StdCtrls, ExtCtrls, Buttons, Grids, VO, ComCtrls, Tipos,
  TypInfo, UFiltro, LabeledCtrls, UDataModule, FPJson, XMLRead, XMLWrite, DOM, ZDataset;

type
  TStatusTela = (stNavegandoGrid, stInserindo, stEditando, stNavegandoEdits);

  { TFTelaCadastro }

  TFTelaCadastro = class(TFTela)
    BotaoExportar: TSpeedButton;
    BotaoImprimir: TSpeedButton;
    BotaoSair: TSpeedButton;
    BotaoSeparador1: TSpeedButton;
    PageControl: TPageControl;
    PaginaEdits: TTabSheet;
    PaginaGrid: TTabSheet;
    PanelEdits: TPanel;
    BotaoSeparador3: TSpeedButton;
    BotaoInserir: TSpeedButton;
    BotaoAlterar: TSpeedButton;
    BotaoExcluir: TSpeedButton;
    BotaoCancelar: TSpeedButton;
    BotaoSalvar: TSpeedButton;
    BotaoFiltrar: TSpeedButton;
    BotaoConsultar: TSpeedButton;
    LabelCampoFiltro: TLabel;
    ComboBoxCampos: TComboBox;
    PanelFiltroRapido: TPanel;
    PanelGrid: TPanel;
    PanelNavegacao: TPanel;
    PanelToolBar: TPanel;
    PopupMenuAtalhosBotoesTelaCadastro: TPopupMenu;
    menuInserir: TMenuItem;
    menuAlterar: TMenuItem;
    menuExcluir: TMenuItem;
    menuFiltrar: TMenuItem;
    menuConsultar: TMenuItem;
    menuCancelar: TMenuItem;
    menuSalvar: TMenuItem;
    menuExportarCompleto: TMenuItem;
    menuImprimirCompleto: TMenuItem;
    menuSairCompleto: TMenuItem;
    EditCriterioRapido: TLabeledMaskEdit;
    procedure BotaoInserirClick(Sender: TObject);
    procedure BotaoAlterarClick(Sender: TObject);
    procedure BotaoExcluirClick(Sender: TObject);
    procedure BotaoSalvarClick(Sender: TObject);
    procedure BotaoCancelarClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure GridDblClick(Sender: TObject);
    procedure BotaoFiltrarClick(Sender: TObject);
    procedure BotaoConsultarClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure EditCriterioRapidoEnter(Sender: TObject);
    procedure EditCriterioRapidoExit(Sender: TObject);
    procedure EditCriterioRapidoKeyPress(Sender: TObject; var Key: Char);
    procedure FormDestroy(Sender: TObject);
    procedure EditCriterioRapidoKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure GridKeyPress(Sender: TObject; var Key: Char);

  private
    { Private declarations }
    FStatusTela: TStatusTela;
    procedure SetStatusTela(const Value: TStatusTela);
    procedure AtualizaGridJson(pDadosJson: TJSONData);
  public
    { Public declarations }
    procedure ExibePanel(pPanelExibir: TPanelExibir); override;

    // Controles CRUD
    function DoInserir: Boolean; virtual;
    function DoEditar: Boolean; virtual;
    function DoExcluir: Boolean; virtual;
    function DoCancelar: Boolean; virtual;
    function DoSalvar: Boolean; virtual;

    function MontaFiltro: string; override;

    property StatusTela: TStatusTela read FStatusTela write SetStatusTela;
  end;

var
  FTelaCadastro: TFTelaCadastro;

implementation

uses Constantes, Biblioteca, ULookup;


{$R *.lfm}
{ TFTelaCadastro }

{$REGION 'Infra'}
procedure TFTelaCadastro.FormCreate(Sender: TObject);
begin
  inherited;
  StatusTela := stNavegandoGrid;
end;

procedure TFTelaCadastro.EditCriterioRapidoEnter(Sender: TObject);
begin
  CustomKeyPreview := False;
  EditCriterioRapido.SelectAll;
end;

procedure TFTelaCadastro.EditCriterioRapidoExit(Sender: TObject);
begin
  CustomKeyPreview := True;
end;

procedure TFTelaCadastro.EditCriterioRapidoKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = VK_F9 then
    BotaoConsultarClick(Sender);

  if Key = VK_RETURN then
    BotaoConsultarClick(Sender);
end;

procedure TFTelaCadastro.EditCriterioRapidoKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
    BotaoConsultarClick(Sender);
end;

procedure TFTelaCadastro.ExibePanel(pPanelExibir: TPanelExibir);
begin
  inherited;

  PanelVisivel := pPanelExibir;

  if pPanelExibir = peGrid then
  begin
    PanelGrid.Parent := Self;
    PanelGrid.Visible := True;
  end
  else
  begin
    PanelGrid.Visible := False;
  end;

  if pPanelExibir = peEdits then
  begin
    PanelEdits.Parent := Self;
    PanelEdits.Visible := True;
  end
  else
  begin
    PanelEdits.Visible := False;
  end;
end;

procedure TFTelaCadastro.FormDestroy(Sender: TObject);
var
  Item: TItemComboBox;
begin
  while ComboBoxCampos.Items.Count > 0 do
  begin
    Item := TItemComboBox(ComboBoxCampos.Items.Objects[0]);
    Item.Free;
    ComboBoxCampos.Items.Delete(0);
  end;

  inherited;
end;

procedure TFTelaCadastro.FormShow(Sender: TObject);
var
  I: Integer;
  VO: TVO;
begin
  inherited;

  VO := ClasseObjetoGridVO.Create;
  try
    PopulaComboBoxComVO(ComboBoxCampos, VO);
  finally
    VO.Free;
  end;

  ComboBoxCampos.ItemIndex := 0;
  if ComboBoxCampos.CanFocus then
    ComboBoxCampos.SetFocus;
end;

procedure TFTelaCadastro.GridKeyPress(Sender: TObject; var Key: Char);
begin
  inherited;
  if Key = #13 then
    EditCriterioRapido.SetFocus;
end;

function TFTelaCadastro.MontaFiltro: string;
var
  Item: TItemComboBox;
  Idx: Integer;
  DataSetField: TField;
  DataSet: TBufDataSet;
begin
  DataSet := CDSGrid;
  if ComboBoxCampos.ItemIndex <> -1 then
  begin
    Idx := ComboBoxCampos.ItemIndex;
    Item := TItemComboBox(ComboBoxCampos.Items.Objects[Idx]);

    if Sessao.Camadas = 3 then
      Result := '/' + Item.Campo + '/' + EditCriterioRapido.Text + '/'
    else
      Result := Item.Campo + ' LIKE ' + QuotedStr('%' + EditCriterioRapido.Text + '%');
  end
  else
  begin
    if Sessao.Camadas = 3 then
      Result := '/ID//'
    else
      Result := ' 1=1 ';
  end;
end;

procedure TFTelaCadastro.SetStatusTela(const Value: TStatusTela);
begin
  FStatusTela := Value;

  BotaoInserir.Visible := False;
  BotaoAlterar.Visible := False;
  BotaoExcluir.Visible := False;
  BotaoSalvar.Visible := False;
  BotaoCancelar.Visible := False;
  BotaoFiltrar.Visible := False;
  BotaoImprimir.Visible := False;
  BotaoExportar.Visible := False;
  BotaoSeparador1.Visible := False;

  menuInserir.Visible := False;
  menuAlterar.Visible := False;
  menuExcluir.Visible := False;
  menuSalvar.Visible := False;
  menuCancelar.Visible := False;
  menuFiltrar.Visible := False;
  menuImprimirCompleto.Visible := False;
  menuExportarCompleto.Visible := False;

  PanelEdits.Enabled := True;

  case Value of
    stNavegandoGrid:
      begin
        BotaoExcluir.Visible := True;
        BotaoAlterar.Visible := True;
        BotaoInserir.Visible := True;
        BotaoSeparador1.Visible := True;
        BotaoImprimir.Visible := True;
        BotaoFiltrar.Visible := True;
        BotaoExportar.Visible := True;

        menuExcluir.Visible := True;
        menuAlterar.Visible := True;
        menuInserir.Visible := True;
        menuImprimirCompleto.Visible := True;
        menuFiltrar.Visible := True;
        menuExportarCompleto.Visible := True;
      end;
    stInserindo, stEditando:
      begin
        BotaoCancelar.Visible := True;
        BotaoSalvar.Visible := True;

        menuCancelar.Visible := True;
        menuSalvar.Visible := True;
      end;
    stNavegandoEdits:
      begin
        BotaoCancelar.Visible := True;
        BotaoExcluir.Visible := True;
        BotaoAlterar.Visible := True;
        BotaoInserir.Visible := True;

        menuCancelar.Visible := True;
        menuExcluir.Visible := True;
        menuAlterar.Visible := True;
        menuInserir.Visible := True;

        PanelEdits.Enabled := False;
      end;
  end;
end;
{$ENDREGION}

{$REGION 'Botões - Clique'}
procedure TFTelaCadastro.BotaoConsultarClick(Sender: TObject);
var
  VData: TJSONArray = nil;
  URLCompleta: String;
begin
  try
    if Sessao.Camadas = 3 then
    begin
      URLCompleta := Sessao.URL + NomeTabelaBanco + MontaFiltro;
      ProcessRequest(BrookHttpRequest(URLCompleta, VData));
      AtualizaGridJson(VData);
    end;
  finally
    FreeAndNil(VData);
  end;
end;

procedure TFTelaCadastro.BotaoAlterarClick(Sender: TObject);
begin
  DoEditar;
end;

procedure TFTelaCadastro.BotaoCancelarClick(Sender: TObject);
begin
  DoCancelar;
end;

procedure TFTelaCadastro.BotaoInserirClick(Sender: TObject);
begin
  DoInserir;
end;

procedure TFTelaCadastro.BotaoExcluirClick(Sender: TObject);
begin
  if DoExcluir then
  begin
    if StatusTela = stNavegandoEdits then
      GridParaEdits;
  end;
end;

procedure TFTelaCadastro.BotaoSalvarClick(Sender: TObject);
var
  LinhaAtual: TBookMark;
begin
  if StatusTela = stEditando then
  begin
    LinhaAtual := CDSGrid.GetBookmark;
  end;

  if DoSalvar then
  begin
    if StatusTela = stEditando then
    begin
      if CDSGrid.BookmarkValid(LinhaAtual) then
      begin
        CDSGrid.GotoBookmark(LinhaAtual);
        CDSGrid.FreeBookmark(LinhaAtual);
      end;
    end;

    BotaoConsultarClick(Sender);
    ExibePanel(peGrid);
    LimparCampos;
    Grid.SetFocus;

    StatusTela := stNavegandoGrid;
  end;
end;

procedure TFTelaCadastro.BotaoFiltrarClick(Sender: TObject);
var
  I: Integer;
begin
  Filtro := '';
  Application.CreateForm(TFFiltro, FFiltro);
  FFiltro.QuemChamou := Self.Name;
  FFiltro.CDSUtilizado := CDSGrid;
  FFiltro.VO := ClasseObjetoGridVO.Create;
  try
    if (FFiltro.ShowModal = MROK) then
    begin
      for I := 0 to FFiltro.MemoSQL.Lines.Count - 1 do
        Filtro := Filtro + FFiltro.MemoSQL.Lines.Strings[I];
      if Trim(Filtro) <> '' then
      begin
        (*
        Realizar consulta com base no filtro
        *)
      end;
    end;
  finally
    Pagina := 0;

    if Assigned(FFiltro) then
      FFiltro.Free;
  end;
end;
{$ENDREGION 'Botões - Clique'}

{$REGION 'Controles CRUD '}
function TFTelaCadastro.DoInserir: Boolean;
begin
  LimparCampos;
  ExibePanel(peEdits);
  StatusTela := stInserindo;
  Result := True;
end;

function TFTelaCadastro.DoEditar: Boolean;
begin
  Result := False;

  if CDSGrid.IsEmpty then
    Application.MessageBox('Não existe registro selecionado.', 'Erro', MB_OK + MB_ICONERROR)
  else
  begin
    ExibePanel(peEdits);
    StatusTela := stEditando;
    GridParaEdits;
    Result := True;
  end;
end;

function TFTelaCadastro.DoExcluir: Boolean;
begin
  Result := False;

  if CDSGrid.IsEmpty then
    Application.MessageBox('Não existe registro selecionado.', 'Erro', MB_OK + MB_ICONERROR)
  else
  begin
    if Application.MessageBox('Deseja realmente excluir o registro selecionado?', 'Pergunta do sistema', MB_YESNO + MB_ICONQUESTION) = IDYES then
    begin
      Result := True;
    end;
  end;
end;

function TFTelaCadastro.DoCancelar: Boolean;
begin
  ExibePanel(peGrid);
  LimparCampos;
  Grid.SetFocus;
  StatusTela := stNavegandoGrid;

  Result := True;
end;

function TFTelaCadastro.DoSalvar: Boolean;
begin
  //
  Result := True;
end;
{$ENDREGION}

{$REGION 'Controle de Grid'}
procedure TFTelaCadastro.GridDblClick(Sender: TObject);
begin
  inherited;

  if not CDSGrid.IsEmpty then
  begin
    ExibePanel(peEdits);
    GridParaEdits;
    StatusTela := stNavegandoEdits;
  end;
end;

procedure TFTelaCadastro.AtualizaGridJson(pDadosJson: TJSONData);
var
  VIsObject: Boolean;
  VJSONCols: TJSONObject;
  VRecord: TJSONData = nil;
  I, J: Integer;
  Registros: Integer;
begin
  CDSGrid.Close;
  CDSGrid.Open;
  ConfiguraGridFromVO(Grid, ClasseObjetoGridVO);

  if not Assigned(pDadosJson) then
  begin
    Exit;
  end;

  VJSONCols := TJSONObject(pDadosJson.Items[0]);
  VIsObject := VJSONCols.JSONType = jtObject;
  if VIsObject and (VJSONCols.Count < 1) then
  begin
    Exit;
  end;

  try
    Registros := Pred(pDadosJson.Count);
    for I := 0 to Registros do
    begin
      CDSGrid.Append;
      VJSONCols := TJSONObject(pDadosJson.Items[I]);
      for J := 0 to Pred(VJSONCols.Count) do
      begin
        VRecord := VJSONCols.Items[J];
        case VRecord.JSONType of
          jtNumber:
            begin
              if VRecord is TJSONFloatNumber then
                CDSGrid.FieldByName(VJSONCols.Names[J]).AsFloat := VRecord.AsFloat
              else
                CDSGrid.FieldByName(VJSONCols.Names[J]).AsInteger := VRecord.AsInt64;
            end;
          jtString:
            CDSGrid.FieldByName(VJSONCols.Names[J]).AsString := VRecord.AsString;
          jtBoolean:
            CDSGrid.FieldByName(VJSONCols.Names[J]).AsString := BoolToStr(VRecord.AsBoolean, 'TRUE', 'FALSE');
          end;
        end;
        CDSGrid.Post;
    end;
  finally
  end;
end;


{$ENDREGION}


end.
