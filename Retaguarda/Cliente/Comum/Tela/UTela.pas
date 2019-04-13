{ *******************************************************************************
Title: T2Ti ERP
Description: Janela Padrão

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
unit UTela;

{$MODE Delphi}

interface

uses LCLIntf, LCLType, LMessages, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UBase, StdCtrls, Buttons, Grids, VO, ToolWin, ExtCtrls, ComCtrls, DB, BufDataset,
  Menus, Tipos, TypInfo, UFiltro, LabeledCtrls, rxdbgrid, XMLRead, XMLWrite, DOM, Controller, ZDataset;

type
  TClasseObjetoGridVO = class of TVO;

  TItemComboBox = class
  private
    FDescricao: string;
    FCampo: string;
  public
    property Campo: string read FCampo write FCampo;
    property Descricao: string read FDescricao write FDescricao;
  end;

  { TFTela }

  TFTela = class(TFBase)
    PanelGrid: TPanel;
    PanelFiltroRapido: TPanel;
    PageControl: TPageControl;
    PaginaGrid: TTabSheet;
    PopupMenuExportar: TPopupMenu;
    menuParaWord: TMenuItem;
    menuParaExcel: TMenuItem;
    menuParaXML: TMenuItem;
    menuParaCSV: TMenuItem;
    menuParaHTML: TMenuItem;
    PanelToolBar: TPanel;
    BotaoSair: TSpeedButton;
    PanelNavegacao: TPanel;
    BotaoPaginaAnterior: TSpeedButton;
    BotaoPrimeiroRegistro: TSpeedButton;
    BotaoRegistroAnterior: TSpeedButton;
    BotaoProximoRegistro: TSpeedButton;
    BotaoUltimoRegistro: TSpeedButton;
    BotaoProximaPagina: TSpeedButton;
    BotaoExportar: TSpeedButton;
    BotaoImprimir: TSpeedButton;
    BotaoSeparador1: TSpeedButton;
    PopupMenuAtalhosBotoesTela: TPopupMenu;
    menuSair: TMenuItem;
    menuImprimir: TMenuItem;
    menuExportar: TMenuItem;
    Grid: TRxDBGrid;
    procedure menuParaWordClick(Sender: TObject);
    procedure menuParaExcelClick(Sender: TObject);
    procedure menuParaXMLClick(Sender: TObject);
    procedure menuParaCSVClick(Sender: TObject);
    procedure menuParaHTMLClick(Sender: TObject);
    procedure BotaoPaginaAnteriorClick(Sender: TObject);
    procedure BotaoProximaPaginaClick(Sender: TObject);
    procedure BotaoPrimeiroRegistroClick(Sender: TObject);
    procedure BotaoProximoRegistroClick(Sender: TObject);
    procedure BotaoRegistroAnteriorClick(Sender: TObject);
    procedure BotaoUltimoRegistroClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure BotaoSairClick(Sender: TObject);
    procedure BotaoExportarClick(Sender: TObject);
    procedure BotaoImprimirClick(Sender: TObject);
  private
    { Private declarations }

  public
    { Public declarations }
    NomeTabelaBanco: String;
    StringObjetoOld: String;
    Filtro, FiltroComplementar: String;
    Pagina: Integer;
    ClasseObjetoGridVO: TClasseObjetoGridVO;
    ObjetoVO: TVO;
    ObjetoController: TController;
    PanelVisivel: TPanelExibir;
    CDSConsultaGenerica: TZQuery;

    // Grid e Edits
    procedure ExibePanel(pPanelExibir: TPanelExibir); virtual;
    procedure ConfiguraGrid; virtual;
    procedure LimparCampos; virtual;
    procedure GridParaEdits; virtual;
    function IdRegistroSelecionado: Integer;

    function MontaFiltro: string; virtual;
    procedure PopulaComboBoxComVO(pComboBox: TCustomComboBox; pObjeto: TVO);
  published
    CDSGrid: TBufDataSet;
    CDSTransiente: TBufDataSet;
    DSGrid: TDataSource;
  end;

var
  FTela: TFTela;

implementation

uses Constantes, UDataModule, Biblioteca;
{$R *.lfm}
{ TFCadastro }

{$REGION 'Infra'}
procedure TFTela.FormCreate(Sender: TObject);
begin
  inherited;

  // Gria DataSet e DataSource
  CDSGrid := TBufDataSet.Create(Self);
  CDSTransiente := TBufDataSet.Create(Self);
  DSGrid := TDataSource.Create(Self);
  DSGrid.DataSet := CDSGrid;
  Grid.DataSource := DSGrid;

  ExibePanel(peGrid);

  ConfiguraGrid;

  Pagina := 0;
end;

procedure TFTela.FormDestroy(Sender: TObject);
begin
  ObjetoVO.Free;
  ObjetoController.Free;

  inherited;
end;

function TFTela.MontaFiltro: string;
begin
  Result := '';
end;

procedure TFTela.PopulaComboBoxComVO(pComboBox: TCustomComboBox; pObjeto: TVO);
var
  J, K: Integer;

  TypeData: PTypeData;
  TypeInfo: PTypeInfo;
  PropList: PPropList;
  PropInfo: PPropInfo;

  Caminho: String;

  Documento: TXMLDocument;
  Node: TDOMNode;

  Item: TItemComboBox;
begin
  try
    TypeInfo := pObjeto.ClassInfo;
    TypeData := GetTypeData(TypeInfo);

    // Lê no arquivo xml no disco
    Caminho := 'C:\Projetos\T2Ti ERP 2.0\Lazarus\Retaguarda\Comum\VO\' + TypeData^.UnitName + '.xml';
    ReadXMLFile(Documento, Caminho);
    Node := Documento.DocumentElement.FirstChild;
    NomeTabelaBanco := Node.Attributes.Item[1].NodeValue;

    while pComboBox.Items.Count > 0 do
    begin
      Item := TItemComboBox(pComboBox.Items.Objects[0]);
      Item.Free;
      pComboBox.Items.Delete(0);
    end;

    //Insere o ID
    Item := TItemComboBox.Create;
    Item.Campo := 'ID';
    Item.Descricao := 'ID';
    pComboBox.AddItem(Item.Descricao, Item);

    //Insere os demais campos
    GetMem(PropList, TypeData^.PropCount * SizeOf(Pointer));
    GetPropInfos(TypeInfo, PropList);
    for J := 0 to (Node.ChildNodes.Count - 1) do
    begin
      if Node.ChildNodes.Item[J].NodeName = 'property' then
      begin
        Item := TItemComboBox.Create;
        for K := 0 to 4 do
        begin
          if Node.ChildNodes.Item[J].Attributes.Item[K].NodeName = 'column' then
            Item.Campo := Node.ChildNodes.Item[J].Attributes.Item[K].NodeValue;
          if Node.ChildNodes.Item[J].Attributes.Item[K].NodeName = 'caption' then
            Item.Descricao := Node.ChildNodes.Item[J].Attributes.Item[K].NodeValue;
        end;
        pComboBox.AddItem(Item.Descricao, Item);
      end;
    end;
  finally
    FreeMem(PropList);
  end;
end;

procedure TFTela.ConfiguraGrid;
begin
  ConfiguraCDSFromVO(CDSGrid, ClasseObjetoGridVO);
  ConfiguraGridFromVO(Grid, ClasseObjetoGridVO);
end;

procedure TFTela.FormShow(Sender: TObject);
begin
  inherited;
end;
{$ENDREGION}

{$REGION 'Botões - Clique'}
procedure TFTela.BotaoExportarClick(Sender: TObject);
begin
  PopupMenuExportar.Popup(Mouse.CursorPos.X, Mouse.CursorPos.Y);
end;

procedure TFTela.BotaoImprimirClick(Sender: TObject);
begin
  (*
  Exercício

  Desenvolva os relatórios com sua suíte favorita.
  *)
end;
{$ENDREGION 'Botões - Clique'}

{$REGION 'Grid e Edits'}
procedure TFTela.ExibePanel(pPanelExibir: TPanelExibir);
begin
//
end;

procedure TFTela.GridParaEdits;
begin
  LimparCampos;
  // Deve ser implementado nos formulários filhos
end;

function TFTela.IdRegistroSelecionado: Integer;
begin
  if CDSGrid.IsEmpty then
    Result := 0
  else
    Result := CDSGrid.FieldByName('ID').AsInteger;
end;

procedure TFTela.LimparCampos;
var
  I: Integer;
begin
  ObjetoVO := Nil;

  for I := 0 to ComponentCount - 1 do
  begin
    if (Components[I] is TLabeledEdit) then
      (Components[I] as TLabeledEdit).Text := '';
    if (Components[I] is TMemo) then
      (Components[I] as TMemo).Lines.Clear;
    if (Components[I] is TLabeledCalcEdit) then
      (Components[I] as TLabeledCalcEdit).Value := 0;
    if (Components[I] is TLabeledMaskEdit) then
      if ((Components[I] as TLabeledMaskEdit).Name <> 'EditCriterioRapido') then
        (Components[I] as TLabeledMaskEdit).Text := '';
    if (Components[I] is TLabeledDateEdit) then
      (Components[I] as TLabeledDateEdit).Clear;
  end;
end;
{$ENDREGION}

{$REGION 'Exportações'}
procedure TFTela.menuParaCSVClick(Sender: TObject);
begin
  (*
  Exercício

  Implemente a exportação da grid para o formato definido.
  *)
end;

procedure TFTela.menuParaExcelClick(Sender: TObject);
begin
  (*
  Exercício

  Implemente a exportação da grid para o formato definido.
  *)
end;

procedure TFTela.menuParaHTMLClick(Sender: TObject);
begin
  (*
  Exercício

  Implemente a exportação da grid para o formato definido.
  *)
end;

procedure TFTela.menuParaWordClick(Sender: TObject);
begin
  (*
  Exercício

  Implemente a exportação da grid para o formato definido.
  *)
end;

procedure TFTela.menuParaXMLClick(Sender: TObject);
begin
  (*
  Exercício

  Implemente a exportação da grid para o formato definido.
  *)
end;
{$ENDREGION}

{$REGION 'Paginação e Navegação'}
procedure TFTela.BotaoPaginaAnteriorClick(Sender: TObject);
begin
  //
end;

procedure TFTela.BotaoProximaPaginaClick(Sender: TObject);
begin
  //
end;

procedure TFTela.BotaoPrimeiroRegistroClick(Sender: TObject);
begin
  CDSGrid.First;
end;

procedure TFTela.BotaoProximoRegistroClick(Sender: TObject);
begin
  CDSGrid.Next;
end;

procedure TFTela.BotaoRegistroAnteriorClick(Sender: TObject);
begin
  CDSGrid.Prior;
end;

procedure TFTela.BotaoUltimoRegistroClick(Sender: TObject);
begin
  CDSGrid.Last;
end;

procedure TFTela.BotaoSairClick(Sender: TObject);
begin
  FechaFormulario;
end;
{$ENDREGION}

end.
