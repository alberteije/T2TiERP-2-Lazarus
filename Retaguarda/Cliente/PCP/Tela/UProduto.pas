{ *******************************************************************************
Title: T2Ti ERP
Description: Janela Cadastro de Produtos

The MIT License

Copyright: Copyright (C) 2014 T2Ti.COM

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
unit UProduto;

{$MODE Delphi}

interface

uses
  BrookHTTPClient, BrookFCLHTTPClientBroker, BrookHTTPUtils, BrookUtils,
  LCLIntf, LCLType, LMessages, Messages, SysUtils, Variants, Classes, Graphics,
  Controls, Forms, Dialogs, UTelaCadastro, ProdutoController, Menus, StdCtrls,
  ExtCtrls, Buttons, Grids, DBGrids, ComCtrls, MaskEdit, FPJson, LabeledCtrls,
  ZConnection, rxdbgrid, rxtoolbar, DBCtrls, DB, BufDataset, StrUtils, Math, VO,
  Constantes, CheckLst, ActnList, Biblioteca, ZDataSet, FichaTecnicaVO;

type

  { TFProduto }

  TFProduto = class(TFTelaCadastro)
    ActionExcluirItem: TAction;
    ActionIncluirItem: TAction;
    ActionManager: TActionList;
    ActionToolBar1: TToolPanel;
    CDSFichaTecnica: TBufDataset;
    DSFichaTecnica: TDataSource;
    GridItens: TRxDBGrid;
    Panel1: TPanel;
    ScrollBox: TScrollBox;
    BevelEdits: TBevel;
    PageControlDadosProduto: TPageControl;
    TabSheet1: TTabSheet;
    tsProdutoPrincipal: TTabSheet;
    tsDadosComplementares: TTabSheet;
    PanelDadosComplementares: TPanel;
    ImagemProduto: TImage;
    Label1: TLabel;
    ComboBoxIat: TLabeledComboBox;
    ComboBoxIppt: TLabeledComboBox;
    ComboBoxTipoItemSped: TLabeledComboBox;
    EditCodigoLst: TLabeledEdit;
    EditExTipi: TLabeledEdit;
    EditTotalizadorParcial: TLabeledEdit;
    EditCodigoBalanca: TLabeledCalcEdit;
    EditPeso: TLabeledCalcEdit;
    EditPorcentoComissao: TLabeledCalcEdit;
    EditPontoPedido: TLabeledCalcEdit;
    EditLoteEconomicoCompra: TLabeledCalcEdit;
    GroupBoxValoresPaf: TGroupBox;
    EditAliquotaIcmsPaf: TLabeledCalcEdit;
    EditAliquotaIssqnPaf: TLabeledCalcEdit;
    PanelProdutoPrincipal: TPanel;
    GroupBoxRG: TGroupBox;
    EditValorCompra: TLabeledCalcEdit;
    EditValorVenda: TLabeledCalcEdit;
    EditPrecoVendaMinimo: TLabeledCalcEdit;
    EditPrecoSugerido: TLabeledCalcEdit;
    EditCustoMedioLiquido: TLabeledCalcEdit;
    EditPrecoLucroZero: TLabeledCalcEdit;
    EditPrecoLucroMinimo: TLabeledCalcEdit;
    EditPrecoLucroMaximo: TLabeledCalcEdit;
    EditMarkup: TLabeledCalcEdit;
    EditQuantidadeEstoque: TLabeledCalcEdit;
    EditQuantidadeEstoqueAnterior: TLabeledCalcEdit;
    EditEstoqueIdeal: TLabeledCalcEdit;
    EditEstoqueMinimo: TLabeledCalcEdit;
    EditEstoqueMaximo: TLabeledCalcEdit;
    EditNome: TLabeledEdit;
    ComboBoxInativo: TLabeledComboBox;
    EditGtin: TLabeledEdit;
    EditCodigoInterno: TLabeledEdit;
    EditNcm: TLabeledEdit;
    ComboBoxClasseAbc: TLabeledComboBox;
    EditDescricaoPdv: TLabeledEdit;
    MemoDescricao: TLabeledMemo;
    PanelProdutoDadosBase: TPanel;
    EditIdSubgrupoProduto: TLabeledCalcEdit;
    EditSubGrupoProduto: TLabeledEdit;
    EditIdMarcaProduto: TLabeledCalcEdit;
    EditMarcaProduto: TLabeledEdit;
    EditUnidadeProduto: TLabeledEdit;
    EditIdUnidadeProduto: TLabeledCalcEdit;
    EditIdAlmoxarifado: TLabeledCalcEdit;
    EditAlmoxarifado: TLabeledEdit;
    EditIdTributGrupoTributario: TLabeledCalcEdit;
    EditTributGrupoTributario: TLabeledEdit;
    ComboboxIcmsCustomizado: TLabeledComboBox;
    ComboboxTipo: TLabeledComboBox;
    PopupMenu1: TPopupMenu;
    CarregarImaem1: TMenuItem;
    procedure BotaoConsultarClick(Sender: TObject);
    procedure BotaoSalvarClick(Sender: TObject);
    procedure ActionExcluirItemExecute(Sender: TObject);
    procedure ActionIncluirItemExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure GridItensAfterQuickSearch(Sender: TObject; Field: TField; var AValue: string);
    procedure ImagemProdutoClick(Sender: TObject);
    procedure ComboboxIcmsCustomizadoChange(Sender: TObject);
    procedure CarregarImaem1Click(Sender: TObject);
    procedure EditIdUnidadeProdutoKeyUp(Sender: TObject; var Key: word;
      Shift: TShiftState);
    procedure EditIdSubgrupoProdutoKeyUp(Sender: TObject; var Key: word;
      Shift: TShiftState);
    procedure EditIdMarcaProdutoKeyUp(Sender: TObject; var Key: word;
      Shift: TShiftState);
    procedure EditIdAlmoxarifadoKeyUp(Sender: TObject; var Key: word;
      Shift: TShiftState);
    procedure EditIdTributGrupoTributarioKeyUp(Sender: TObject;
      var Key: word; Shift: TShiftState);
    procedure EditNcmKeyUp(Sender: TObject; var Key: word; Shift: TShiftState);
  private
    { Private declarations }
  public
    { Public declarations }
    UsadoPorOutroModulo: boolean;

    procedure GridParaEdits; override;
    procedure LimparCampos; override;

    // Controles CRUD
    function DoInserir: boolean; override;
    function DoEditar: boolean; override;
    function DoExcluir: boolean; override;
    function DoSalvar: boolean; override;

    procedure ConfigurarLayoutTela;

  end;

var
  FProduto: TFProduto;

implementation

uses UMenu, UDataModule, ProdutoVO;

{$R *.lfm}
{ TFProduto }

{$REGION 'Infra'}
procedure TFProduto.BotaoConsultarClick(Sender: TObject);
var
  RetornoConsulta: TZQuery;
  ListaCampos: TStringList;
  i: integer;
begin
  inherited;

  if Sessao.Camadas = 2 then
  begin
    Filtro := MontaFiltro;

    CDSGrid.Close;
    CDSGrid.Open;
    ConfiguraGridFromVO(Grid, ClasseObjetoGridVO);

    ListaCampos := TStringList.Create;
    RetornoConsulta := TProdutoController.Consulta(Filtro, IntToStr(Pagina));
    RetornoConsulta.Active := True;

    RetornoConsulta.GetFieldNames(ListaCampos);

    RetornoConsulta.First;
    while not RetornoConsulta.EOF do
    begin
      CDSGrid.Append;
      for i := 0 to ListaCampos.Count - 1 do
      begin
        CDSGrid.FieldByName(ListaCampos[i]).Value := RetornoConsulta.FieldByName(ListaCampos[i]).Value;
      end;
      CDSGrid.Post;
      RetornoConsulta.Next;
    end;
  end;
end;

procedure TFProduto.BotaoSalvarClick(Sender: TObject);
begin
  inherited;
  BotaoConsultarClick(Sender);
end;

procedure TFProduto.FormCreate(Sender: TObject);
begin
  ClasseObjetoGridVO := TProdutoVO;
  inherited;

  ConfiguraCDSFromVO(CDSFichaTecnica, TFichaTecnicaVO);
end;

procedure TFProduto.GridItensAfterQuickSearch(Sender: TObject; Field: TField;
  var AValue: string);
begin

end;

procedure TFProduto.ActionIncluirItemExecute(Sender: TObject);
begin
  try
    // PopulaCamposTransientesLookup(TProdutoVO, TProdutoController);
    //if CDSTransiente.RecordCount > 0 then
    //begin
      CDSFichaTecnica.Append;
      CDSFichaTecnica.FieldByName('ID_PRODUTO_FILHO').AsInteger := 1;//CDSTransiente.FieldByName('ID').AsInteger;
      CDSFichaTecnica.FieldByName('DESCRICAO').AsString := 'PRODUTO TESTE';//CDSTransiente.FieldByName('NOME').AsString
    //end;
  finally
    CDSTransiente.Close;
  end;
end;

procedure TFProduto.ActionExcluirItemExecute(Sender: TObject);
begin
  if Application.MessageBox('Tem certeza que deseja remover o item da Ficha?',
    'Pergunta do Sistema', MB_YesNo + MB_IconQuestion) = idYes then
  begin
    if StatusTela = stInserindo then
      CDSFichaTecnica.Delete
    else if StatusTela = stEditando then
    begin
      TProdutoController.ExcluiFichaTecnica(CDSFichaTecnica.FieldByName('ID').AsInteger);
    end;
  end;

end;

procedure TFProduto.ComboboxIcmsCustomizadoChange(Sender: TObject);
begin
  if ComboboxIcmsCustomizado.ItemIndex = 1 then
    EditIdTributGrupoTributario.CalcEditLabel.Caption := 'Grupo Tributário [F1]:'
  else
    EditIdTributGrupoTributario.CalcEditLabel.Caption := 'ICMS Customizado [F1]:';
end;

procedure TFProduto.ConfigurarLayoutTela;
begin
  PageControlDadosProduto.ActivePageIndex := 0;
  PanelEdits.Enabled := True;
  if StatusTela = stNavegandoEdits then
  begin
    PanelProdutoPrincipal.Enabled := False;
    PanelDadosComplementares.Enabled := False;
    PanelProdutoDadosBase.Enabled := False;
  end
  else
  begin
    PanelProdutoPrincipal.Enabled := True;
    PanelDadosComplementares.Enabled := True;
    PanelProdutoDadosBase.Enabled := True;
  end;
end;

procedure TFProduto.LimparCampos;
begin
  inherited;
  FDataModule.ImagemPadrao.GetBitmap(0, ImagemProduto.Picture.Bitmap);
  CDSFichaTecnica.Close;
  CDSFichaTecnica.Open;
end;
{$ENDREGION}

{$REGION 'Controles CRUD'}
function TFProduto.DoInserir: boolean;
begin
  Result := inherited DoInserir;

  if Result then
  begin
    EditIdSubgrupoProduto.SetFocus;
  end;
end;

function TFProduto.DoEditar: boolean;
begin
  Result := inherited DoEditar;

  if Result then
  begin
    EditIdSubgrupoProduto.SetFocus;
  end;
end;

function TFProduto.DoExcluir: boolean;
begin
  if inherited DoExcluir then
  begin
    try
      Result := ProcessRequest(BrookHttpRequest(Sessao.URL + NomeTabelaBanco +
        '/' + IntToStr(IdRegistroSelecionado), rmDelete));
    except
      Result := False;
    end;
  end
  else
  begin
    Result := False;
  end;

  if Result then
    BotaoConsultar.Click;
end;

function TFProduto.DoSalvar: boolean;
var
  ObjetoJson: TJSONObject;
begin
  try
    DecimalSeparator := '.';

    if EditIdSubgrupoProduto.AsInteger <= 0 then
    begin
      Application.MessageBox('Selecione o subgrupo do Produto.',
        'Mensagem do Sistema', MB_OK + MB_ICONINFORMATION);
      EditIdSubgrupoProduto.SetFocus;
      Exit(False);
    end
    else if EditIdUnidadeProduto.AsInteger <= 0 then
    begin
      Application.MessageBox('Selecione a unidade do Produto.',
        'Mensagem do Sistema', MB_OK + MB_ICONINFORMATION);
      EditIdUnidadeProduto.SetFocus;
      Exit(False);
    end
    else if EditGtin.Text = '' then
    begin
      Application.MessageBox('Informe o GTIN do Produto.', 'Mensagem do Sistema',
        MB_OK + MB_ICONINFORMATION);
      EditGtin.SetFocus;
      Exit(False);
    end
    else if EditNome.Text = '' then
    begin
      Application.MessageBox('Informe o Nome do Produto.', 'Mensagem do Sistema',
        MB_OK + MB_ICONINFORMATION);
      EditNome.SetFocus;
      Exit(False);
    end;

    Result := inherited DoSalvar;

    if Result then
    begin

      try
        if not Assigned(ObjetoVO) then
          ObjetoVO := TProdutoVO.Create;

        TProdutoVO(ObjetoVO).IdAlmoxarifado := EditIdAlmoxarifado.AsInteger;

        if ComboboxIcmsCustomizado.ItemIndex = 1 then
        begin
          TProdutoVO(ObjetoVO).IdGrupoTributario :=
            EditIdTributGrupoTributario.AsInteger;
          //          TProdutoVO(ObjetoVO).IdTributIcmsCustomCab := 0;
        end
        else
        begin
          //          TProdutoVO(ObjetoVO).IdTributIcmsCustomCab := EditIdTributGrupoTributario.AsInteger;
          TProdutoVO(ObjetoVO).IdGrupoTributario := 0;
        end;

        //        TProdutoVO(ObjetoVO).IdMarcaProduto := EditIdMarcaProduto.AsInteger;
        TProdutoVO(ObjetoVO).IdSubGrupo := EditIdSubgrupoProduto.AsInteger;
        //        TProdutoVO(ObjetoVO).IdUnidadeProduto := EditIdUnidadeProduto.AsInteger;

        TProdutoVO(ObjetoVO).Gtin := EditGtin.Text;
        TProdutoVO(ObjetoVO).CodigoInterno := EditCodigoInterno.Text;
        TProdutoVO(ObjetoVO).Ncm := EditNcm.Text;
        TProdutoVO(ObjetoVO).Nome := EditNome.Text;
        TProdutoVO(ObjetoVO).Descricao := MemoDescricao.Text;
        TProdutoVO(ObjetoVO).DescricaoPdv := EditDescricaoPdv.Text;
        TProdutoVO(ObjetoVO).ValorCompra := EditValorCompra.Value;
        TProdutoVO(ObjetoVO).ValorVenda := EditValorVenda.Value;
        TProdutoVO(ObjetoVO).PrecoVendaMinimo := EditPrecoVendaMinimo.Value;
        TProdutoVO(ObjetoVO).PrecoSugerido := EditPrecoSugerido.Value;
        TProdutoVO(ObjetoVO).CustoMedioLiquido := EditCustoMedioLiquido.Value;
        TProdutoVO(ObjetoVO).PrecoLucroZero := EditPrecoLucroZero.Value;
        TProdutoVO(ObjetoVO).PrecoLucroMinimo := EditPrecoLucroMinimo.Value;
        TProdutoVO(ObjetoVO).PrecoLucroMaximo := EditPrecoLucroMaximo.Value;
        TProdutoVO(ObjetoVO).Markup := EditMarkup.Value;
        TProdutoVO(ObjetoVO).QuantidadeEstoque := EditQuantidadeEstoque.Value;
        TProdutoVO(ObjetoVO).QuantidadeEstoqueAnterior :=
          EditQuantidadeEstoqueAnterior.Value;
        TProdutoVO(ObjetoVO).EstoqueMinimo := EditEstoqueMinimo.Value;
        TProdutoVO(ObjetoVO).EstoqueMaximo := EditEstoqueMaximo.Value;
        TProdutoVO(ObjetoVO).EstoqueIdeal := EditEstoqueIdeal.Value;
        TProdutoVO(ObjetoVO).Inativo := IfThen(ComboBoxInativo.ItemIndex = 0, 'S', 'N');
        TProdutoVO(ObjetoVO).ExTipi := EditExTipi.Text;
        TProdutoVO(ObjetoVO).CodigoLst := EditCodigoLst.Text;
        TProdutoVO(ObjetoVO).ClasseAbc := Copy(ComboBoxClasseAbc.Text, 1, 1);
        TProdutoVO(ObjetoVO).Iat := Copy(ComboBoxIat.Text, 1, 1);
        TProdutoVO(ObjetoVO).Ippt := Copy(ComboBoxIppt.Text, 1, 1);
        TProdutoVO(ObjetoVO).TipoItemSped := Copy(ComboBoxTipoItemSped.Text, 1, 2);
        TProdutoVO(ObjetoVO).Peso := EditPeso.Value;
        TProdutoVO(ObjetoVO).PorcentoComissao := EditPorcentoComissao.Value;
        TProdutoVO(ObjetoVO).PontoPedido := EditPontoPedido.Value;
        TProdutoVO(ObjetoVO).LoteEconomicoCompra := EditLoteEconomicoCompra.Value;
        TProdutoVO(ObjetoVO).AliquotaIcmsPaf := EditAliquotaIcmsPaf.Value;
        TProdutoVO(ObjetoVO).AliquotaIssqnPaf := EditAliquotaIssqnPaf.Value;
        TProdutoVO(ObjetoVO).TotalizadorParcial := EditTotalizadorParcial.Text;
        TProdutoVO(ObjetoVO).CodigoBalanca := EditCodigoBalanca.AsInteger;
        TProdutoVO(ObjetoVO).Tipo := Copy(ComboboxTipo.Text, 1, 1);

        if StatusTela = stInserindo then
        begin
          TProdutoController.Insere(TProdutoVO(ObjetoVO));
        end
        else if StatusTela = stEditando then
        begin
          TProdutoController.Altera(TProdutoVO(ObjetoVO));
        end;

        if UsadoPorOutroModulo then
          Close;
      except
        Result := False;
      end;
    end;

  finally
    DecimalSeparator := ',';
  end;
end;
{$ENDREGION}

{$REGION 'Controle de Grids e ClientDataSets'}
procedure TFProduto.GridParaEdits;
var
  IdCabecalho: string;
  I: Integer;
begin
  inherited;

  if not CDSGrid.IsEmpty then
  begin
    IdCabecalho := IntToStr(IdRegistroSelecionado);
    ObjetoVO := TProdutoController.ConsultaObjeto('ID=' + IdCabecalho);
  end;

  if Assigned(ObjetoVO) then
  begin
    EditIdAlmoxarifado.AsInteger := TProdutoVO(ObjetoVO).IdAlmoxarifado;
    EditAlmoxarifado.Text := 'ALMOX 01';
    (*
    if Assigned(TProdutoVO(ObjetoVO).AlmoxarifadoVO) then
    begin
      EditAlmoxarifado.Text := TProdutoVO(ObjetoVO).AlmoxarifadoVO.Nome;
    end;
    *)

    EditIdTributGrupoTributario.AsInteger := TProdutoVO(ObjetoVO).IdGrupoTributario;
    EditTributGrupoTributario.Text := 'PRODUTO FABRICACAO PROPRIA SUJEITO AO ICMS ST';

    (*
    if TProdutoVO(ObjetoVO).IdGrupoTributario > 0 then
    begin
      EditTributGrupoTributario.Text := TProdutoVO(ObjetoVO).GrupoTributarioVO.Descricao;
    end
    else
    begin
      EditIdTributGrupoTributario.AsInteger := TProdutoVO(ObjetoVO).IdIcmsCustomizado;
      EditTributGrupoTributario.Text := TProdutoVO(ObjetoVO).TributIcmsCustomCabVO.Descricao;
    end;
    *)

    //    EditIdMarcaProduto.AsInteger := TProdutoVO(ObjetoVO).IdMarcaProduto;

    (*
    if Assigned(TProdutoVO(ObjetoVO).ProdutoMarcaVO) then
    begin
      EditMarcaProduto.Text := TProdutoVO(ObjetoVO).ProdutoMarcaVO.Nome;
    end;
    *)

    EditIdSubgrupoProduto.AsInteger := TProdutoVO(ObjetoVO).IdSubGrupo;
    EditSubGrupoProduto.Text := 'SUBGRUPO 01 DO GRUPO 01';
    //EditSubGrupoProduto.Text := TProdutoVO(ObjetoVO).ProdutoSubGrupoVO.Nome;

    //    EditIdUnidadeProduto.AsInteger := TProdutoVO(ObjetoVO).IdUnidadeProduto;
    EditUnidadeProduto.Text := 'UN';
    //EditUnidadeProduto.Text := TProdutoVO(ObjetoVO).UnidadeProdutoVO.Sigla;

    EditGtin.Text := TProdutoVO(ObjetoVO).Gtin;
    EditCodigoInterno.Text := TProdutoVO(ObjetoVO).CodigoInterno;
    EditNcm.Text := TProdutoVO(ObjetoVO).Ncm;
    EditNome.Text := TProdutoVO(ObjetoVO).Nome;
    MemoDescricao.Text := TProdutoVO(ObjetoVO).Descricao;
    EditDescricaoPdv.Text := TProdutoVO(ObjetoVO).DescricaoPdv;
    EditValorCompra.Value := TProdutoVO(ObjetoVO).ValorCompra;
    EditValorVenda.Value := TProdutoVO(ObjetoVO).ValorVenda;
    EditPrecoVendaMinimo.Value := TProdutoVO(ObjetoVO).PrecoVendaMinimo;
    EditPrecoSugerido.Value := TProdutoVO(ObjetoVO).PrecoSugerido;
    EditCustoMedioLiquido.Value := TProdutoVO(ObjetoVO).CustoMedioLiquido;
    EditPrecoLucroZero.Value := TProdutoVO(ObjetoVO).PrecoLucroZero;
    EditPrecoLucroMinimo.Value := TProdutoVO(ObjetoVO).PrecoLucroMinimo;
    EditPrecoLucroMaximo.Value := TProdutoVO(ObjetoVO).PrecoLucroMaximo;
    EditMarkup.Value := TProdutoVO(ObjetoVO).Markup;
    EditQuantidadeEstoque.Value := TProdutoVO(ObjetoVO).QuantidadeEstoque;
    EditQuantidadeEstoqueAnterior.Value := TProdutoVO(ObjetoVO).QuantidadeEstoqueAnterior;
    EditEstoqueMinimo.Value := TProdutoVO(ObjetoVO).EstoqueMinimo;
    EditEstoqueMaximo.Value := TProdutoVO(ObjetoVO).EstoqueMaximo;
    EditEstoqueIdeal.Value := TProdutoVO(ObjetoVO).EstoqueIdeal;

    ComboBoxInativo.ItemIndex := IfThen(TProdutoVO(ObjetoVO).Inativo = 'S', 0, 1);

    EditExTipi.Text := TProdutoVO(ObjetoVO).ExTipi;
    EditCodigoLst.Text := TProdutoVO(ObjetoVO).CodigoLst;

    ComboBoxClasseAbc.ItemIndex := AnsiIndexStr(TProdutoVO(ObjetoVO).ClasseAbc, ['A', 'B', 'C']);

    ComboBoxIat.ItemIndex := IfThen(TProdutoVO(ObjetoVO).Iat = 'A', 0, 1);
    ComboBoxIppt.ItemIndex := IfThen(TProdutoVO(ObjetoVO).Ippt = 'P', 0, 1);
    if TProdutoVO(ObjetoVO).TipoItemSped <> '' then
      ComboBoxTipoItemSped.ItemIndex := IfThen(TProdutoVO(ObjetoVO).TipoItemSped = '99', 11, StrToInt(TProdutoVO(ObjetoVO).TipoItemSped));

    if TProdutoVO(ObjetoVO).ListaFichaTecnicaVO.Count > 0 then
    for I := 0 to TProdutoVO(ObjetoVO).ListaFichaTecnicaVO.Count -1 do
    begin
      CDSFichaTecnica.Append;
      CDSFichaTecnica.FieldByName('ID').AsInteger:= TProdutoVO(ObjetoVO).ListaFichaTecnicaVO[I].Id;
      CDSFichaTecnica.FieldByName('ID_PRODUTO').AsInteger:= TProdutoVO(ObjetoVO).ListaFichaTecnicaVO[I].IdProduto;
      CDSFichaTecnica.FieldByName('ID_PRODUTO_FILHO').AsInteger:= TProdutoVO(ObjetoVO).ListaFichaTecnicaVO[I].IdProdutoFilho;
      CDSFichaTecnica.FieldByName('DESCRICAO').AsString:= TProdutoVO(ObjetoVO).ListaFichaTecnicaVO[I].Descricao;
      CDSFichaTecnica.FieldByName('SEQUENCIA_PRODUCAO').AsInteger:= TProdutoVO(ObjetoVO).ListaFichaTecnicaVO[I].SequenciaProducao;
      CDSFichaTecnica.FieldByName('QUANTIDADE').AsFloat:= TProdutoVO(ObjetoVO).ListaFichaTecnicaVO[I].Quantidade;
      CDSFichaTecnica.Post;
    end;


    EditPeso.Value := TProdutoVO(ObjetoVO).Peso;
    EditPorcentoComissao.Value := TProdutoVO(ObjetoVO).PorcentoComissao;
    EditPontoPedido.Value := TProdutoVO(ObjetoVO).PontoPedido;
    EditLoteEconomicoCompra.Value := TProdutoVO(ObjetoVO).LoteEconomicoCompra;
    EditAliquotaIcmsPaf.Value := TProdutoVO(ObjetoVO).AliquotaIcmsPaf;
    EditAliquotaIssqnPaf.Value := TProdutoVO(ObjetoVO).AliquotaIssqnPaf;
    EditTotalizadorParcial.Text := TProdutoVO(ObjetoVO).TotalizadorParcial;
    EditCodigoBalanca.AsInteger := TProdutoVO(ObjetoVO).CodigoBalanca;
    ComboBoxTipo.ItemIndex := AnsiIndexStr(TProdutoVO(ObjetoVO).Tipo, ['V', 'C', 'P', 'I', 'U']);

    // Serializa o objeto para consultar posteriormente se houve alterações
    FormatSettings.DecimalSeparator := '.';
    StringObjetoOld := ObjetoVO.ToJSONString;
    FormatSettings.DecimalSeparator := ',';
  end;

  ConfigurarLayoutTela;
end;
{$ENDREGION}

{$REGION 'Campos Transientes'}
procedure TFProduto.EditIdSubgrupoProdutoKeyUp(Sender: TObject;
  var Key: word; Shift: TShiftState);
var
  Filtro: string;
begin
  if Key = VK_F1 then
  begin
    if EditIdSubgrupoProduto.Value <> 0 then
      Filtro := 'ID = ' + EditIdSubgrupoProduto.Text
    else
      Filtro := 'ID = 0';
    {
    try
      EditIdSubgrupoProduto.Clear;
      EditSubGrupoProduto.Clear;
      if not PopulaCamposTransientes(Filtro, TProdutoSubGrupoVO, TProdutoSubGrupoController) then
        PopulaCamposTransientesLookup(TProdutoSubGrupoVO, TProdutoSubGrupoController);
      if CDSTransiente.RecordCount > 0 then
      begin
        EditIdSubgrupoProduto.Text := CDSTransiente.FieldByName('ID').AsString;
        EditSubGrupoProduto.Text := CDSTransiente.FieldByName('NOME').AsString;
      end
      else
      begin
        Exit;
        EditIdSubgrupoProduto.SetFocus;
      end;
    finally
      CDSTransiente.Close;
    end;
     }
  end;
end;

procedure TFProduto.EditIdUnidadeProdutoKeyUp(Sender: TObject;
  var Key: word; Shift: TShiftState);
var
  Filtro: string;
begin
  if Key = VK_F1 then
  begin
    if EditIdUnidadeProduto.Value <> 0 then
      Filtro := 'ID = ' + EditIdUnidadeProduto.Text
    else
      Filtro := 'ID=0';
    (*
    try
      EditIdUnidadeProduto.Clear;
      EditUnidadeProduto.Clear;
      if not PopulaCamposTransientes(Filtro, TUnidadeProdutoVO, TUnidadeProdutoController) then
        PopulaCamposTransientesLookup(TUnidadeProdutoVO, TUnidadeProdutoController);
      if CDSTransiente.RecordCount > 0 then
      begin
        EditIdUnidadeProduto.Text := CDSTransiente.FieldByName('ID').AsString;
        EditUnidadeProduto.Text := CDSTransiente.FieldByName('SIGLA').AsString;
      end
      else
      begin
        Exit;
        EditIdMarcaProduto.SetFocus;
      end;
    finally
      CDSTransiente.Close;
    end;
    *)
  end;
end;

procedure TFProduto.EditIdMarcaProdutoKeyUp(Sender: TObject; var Key: word;
  Shift: TShiftState);
var
  Filtro: string;
begin
  if Key = VK_F1 then
  begin
    if EditIdMarcaProduto.Value <> 0 then
      Filtro := 'ID = ' + EditIdMarcaProduto.Text
    else
      Filtro := 'ID=0';
    (*
    try
      EditIdMarcaProduto.Clear;
      EditMarcaProduto.Clear;
      if not PopulaCamposTransientes(Filtro, TProdutoMarcaVO, TProdutoMarcaController) then
        PopulaCamposTransientesLookup(TProdutoMarcaVO, TProdutoMarcaController);
      if CDSTransiente.RecordCount > 0 then
      begin
        EditIdMarcaProduto.Text := CDSTransiente.FieldByName('ID').AsString;
        EditMarcaProduto.Text := CDSTransiente.FieldByName('NOME').AsString;
      end
      else
      begin
        Exit;
        EditIdMarcaProduto.SetFocus;
      end;
    finally
      CDSTransiente.Close;
    end;
    *)
  end;
end;

procedure TFProduto.EditIdAlmoxarifadoKeyUp(Sender: TObject; var Key: word;
  Shift: TShiftState);
var
  Filtro: string;
begin
  if Key = VK_F1 then
  begin
    if EditIdAlmoxarifado.Value <> 0 then
      Filtro := 'ID = ' + EditIdAlmoxarifado.Text
    else
      Filtro := 'ID=0';
    (*
    try
      EditIdAlmoxarifado.Clear;
      EditAlmoxarifado.Clear;
      if not PopulaCamposTransientes(Filtro, TAlmoxarifadoVO, TAlmoxarifadoController) then
        PopulaCamposTransientesLookup(TAlmoxarifadoVO, TAlmoxarifadoController);
      if CDSTransiente.RecordCount > 0 then
      begin
        EditIdAlmoxarifado.Text := CDSTransiente.FieldByName('ID').AsString;
        EditAlmoxarifado.Text := CDSTransiente.FieldByName('NOME').AsString;
      end
      else
      begin
        Exit;
        EditIdAlmoxarifado.SetFocus;
      end;
    finally
      CDSTransiente.Close;
    end;
    *)
  end;
end;

procedure TFProduto.EditIdTributGrupoTributarioKeyUp(Sender: TObject;
  var Key: word; Shift: TShiftState);
var
  Filtro: string;
begin
  if Key = VK_F1 then
  begin
    if EditIdTributGrupoTributario.Value <> 0 then
      Filtro := 'ID = ' + EditIdTributGrupoTributario.Text
    else
      Filtro := 'ID=0';
    (*
    if ComboboxIcmsCustomizado.ItemIndex = 1 then
    begin

      try
        EditIdTributGrupoTributario.Clear;
        EditTributGrupoTributario.Clear;
        if not PopulaCamposTransientes(Filtro, TTributGrupoTributarioVO, TTributGrupoTributarioController) then
          PopulaCamposTransientesLookup(TTributGrupoTributarioVO, TTributGrupoTributarioController);
        if CDSTransiente.RecordCount > 0 then
        begin
          EditIdTributGrupoTributario.Text := CDSTransiente.FieldByName('ID').AsString;
          EditTributGrupoTributario.Text := CDSTransiente.FieldByName('DESCRICAO').AsString;
        end
        else
        begin
          Exit;
          EditIdTributGrupoTributario.SetFocus;
        end;
      finally
        CDSTransiente.Close;
      end;
    end
    else
    begin
      try
        EditIdTributGrupoTributario.Clear;
        EditTributGrupoTributario.Clear;
        if not PopulaCamposTransientes(Filtro, TTributIcmsCustomCabVO, TTributIcmsCustomCabController) then
          PopulaCamposTransientesLookup(TTributIcmsCustomCabVO, TTributIcmsCustomCabController);
        if CDSTransiente.RecordCount > 0 then
        begin
          EditIdTributGrupoTributario.Text := CDSTransiente.FieldByName('ID').AsString;
          EditTributGrupoTributario.Text := CDSTransiente.FieldByName('DESCRICAO').AsString;
        end
        else
        begin
          Exit;
          EditIdTributGrupoTributario.SetFocus;
        end;
      finally
        CDSTransiente.Close;
      end;
    end;
   *)
  end;
end;

procedure TFProduto.EditNcmKeyUp(Sender: TObject; var Key: word; Shift: TShiftState);
var
  Filtro: string;
begin
  if Key = VK_F1 then
  begin
    if EditNcm.Text <> '' then
      Filtro := 'CODIGO = ' + QuotedStr(EditNcm.Text)
    else
      Filtro := 'CODIGO = ""';
    (*
    try
      EditNcm.Clear;
      if not PopulaCamposTransientes(Filtro, TNcmVO, TNcmController) then
        PopulaCamposTransientesLookup(TNcmVO, TNcmController);
      if CDSTransiente.RecordCount > 0 then
      begin
        EditNcm.Text := CDSTransiente.FieldByName('CODIGO').AsString;
      end
      else
      begin
        Exit;
        EditNcm.SetFocus;
      end;
    finally
      CDSTransiente.Close;
    end;
    *)
  end;
end;
{$ENDREGION}

{$REGION 'Controle de Imagens'}
procedure TFProduto.ImagemProdutoClick(Sender: TObject);
begin
  (*
  if StatusTela = stNavegandoEdits then
    Application.MessageBox('Não é permitido selecionar nova imagem em modo de consulta.', 'Informação do sistema.', MB_OK + MB_ICONINFORMATION)
  else
  begin
    if FDataModule.OpenDialog.Execute then
    begin
      try
        try
          TProdutoVO(ObjetoVO).FotoProduto := FDataModule.OpenDialog.FileName;
        except
          Application.MessageBox('Arquivo de imagem com formato inválido.', 'Erro do sistema.', MB_OK + MB_ICONERROR);
        end;
      finally
      end;
    end;
  end;
  *)
end;

procedure TFProduto.CarregarImaem1Click(Sender: TObject);
begin
  (*
  if TProdutoVO(ObjetoVO).FotoProduto <> '' then
    ImagemProduto.Picture.LoadFromFile(TProdutoVO(ObjetoVO).FotoProduto);
    *)
end;
{$ENDREGION}

end.
