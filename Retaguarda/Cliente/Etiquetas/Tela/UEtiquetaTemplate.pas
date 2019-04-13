{*******************************************************************************
Title: T2Ti ERP
Description: Janela Cadastro de Template

The MIT License

Copyright: Copyright (C) 2017 T2Ti.COM

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

@author T2Ti
@version 2.0
*******************************************************************************}
unit UEtiquetaTemplate;

{$MODE Delphi}

interface

uses
  BrookHTTPClient, BrookFCLHTTPClientBroker, BrookHTTPUtils, BrookUtils, FPJson, ZDataset,
  LCLIntf, LCLType, LMessages, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UTelaCadastro, Menus, StdCtrls, ExtCtrls, Buttons, Grids, DBGrids,
  ComCtrls, LabeledCtrls, rxdbgrid, rxtoolbar, DBCtrls, StrUtils,
  Math, Constantes, CheckLst, ActnList, ToolWin, db, BufDataset, Biblioteca,
  ULookup, VO;
{
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UTelaCadastro, DB, DBClient, Menus, StdCtrls, ExtCtrls, Buttons, Grids,
  DBGrids, JvExDBGrids, JvDBGrid, JvDBUltimGrid, ComCtrls, EtiquetaTemplateVO,
  EtiquetaTemplateController, Tipos, Atributos, Constantes, LabeledCtrls, Mask,
  JvExMask, JvToolEdit, JvBaseEdits, Controller, Biblioteca, System.Actions,
  Vcl.ActnList, Vcl.PlatformDefaultStyleActnCtrls, Vcl.ActnMan, Vcl.ToolWin,
  Vcl.ActnCtrls, frxBarcode, frxClass, frxDBSet, StrUtils;

}type

  { TFEtiquetaTemplate }

  TFEtiquetaTemplate = class(TFTelaCadastro)
    BotaoConsultar: TSpeedButton;
    BotaoExportar: TSpeedButton;
    BotaoFiltrar: TSpeedButton;
    BotaoImprimir: TSpeedButton;
    BotaoSair: TSpeedButton;
    BotaoSeparador1: TSpeedButton;
    EditCriterioRapido: TLabeledMaskEdit;
    EditLayout: TLabeledEdit;
    EditTabela: TLabeledEdit;
    EditIdLayout: TLabeledCalcEdit;
    EditQuantidadeRepeticoes: TLabeledCalcEdit;
    EditCampo: TLabeledEdit;
    EditFiltro: TLabeledEdit;
    ComboBoxFormato: TLabeledComboBox;
    frxReport: TfrxReport;
    frxTable: TfrxDBDataset;
    frxBarCodeObject1: TfrxBarCodeObject;
    ActionToolBar1: TToolPanel;
    ActionManager1: TActionList;
    ActionGerarEtiquetas: TAction;
    CDSProduto: TClientDataSet;
    Grid: TRxDbGrid;
    PageControl: TPageControl;
    PaginaEdits: TTabSheet;
    PaginaGrid: TTabSheet;
    PanelEdits: TPanel;
    PanelFiltroRapido: TPanel;
    PanelGrid: TPanel;
    PanelToolBar: TPanel;
    procedure FormCreate(Sender: TObject);
    procedure EditIdLayoutKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure ActionGerarEtiquetasExecute(Sender: TObject);
    procedure BotaoConsultarClick(Sender: TObject);
    procedure BotaoSalvarClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure GridParaEdits; override;

    // Controles CRUD
    function DoInserir: Boolean; override;
    function DoEditar: Boolean; override;
    function DoExcluir: Boolean; override;
    function DoSalvar: Boolean; override;
  end;

var
  FEtiquetaTemplate: TFEtiquetaTemplate;

implementation

uses ULookup, EtiquetaLayoutController, EtiquetaLayoutVO, UDataModule,
ProdutoController, ProdutoVO;
{$R *.lfm}

{$REGION 'Infra'}
procedure TFEtiquetaTemplate.BotaoConsultarClick(Sender: TObject);
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

    ListaCampos  := TStringList.Create;
    RetornoConsulta := TEtiquetaTemplateController.Consulta(Filtro, IntToStr(Pagina));
    RetornoConsulta.Active := True;

    RetornoConsulta.GetFieldNames(ListaCampos);

    RetornoConsulta.First;
    while not RetornoConsulta.EOF do begin
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

procedure TFEtiquetaTemplate.BotaoSalvarClick(Sender: TObject);
begin
  inherited;
  BotaoConsultarClick(Sender);
end;

procedure TFEtiquetaTemplate.FormCreate(Sender: TObject);
begin
  ClasseObjetoGridVO := TEtiquetaTemplateVO;
  ObjetoController := TEtiquetaTemplateController.Create;
  inherited;
end;
{$ENDREGION}

{$REGION 'Controles CRUD'}
function TFEtiquetaTemplate.DoInserir: Boolean;
begin
  Result := inherited DoInserir;

  if Result then
  begin
    EditIdLayout.SetFocus;
  end;
end;

function TFEtiquetaTemplate.DoEditar: Boolean;
begin
  Result := inherited DoEditar;

  if Result then
  begin
    EditIdLayout.SetFocus;
  end;
end;

function TFEtiquetaTemplate.DoExcluir: Boolean;
begin
  if inherited DoExcluir then
  begin
    try
      Result := TEtiquetaTemplateController.Exclui(IdRegistroSelecionado);
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

function TFEtiquetaTemplate.DoSalvar: Boolean;
begin
  Result := inherited DoSalvar;

  if Result then
  begin
    try
      if not Assigned(ObjetoVO) then
        ObjetoVO := TEtiquetaTemplateVO.Create;

      TEtiquetaTemplateVO(ObjetoVO).IdEtiquetaLayout := EditIdLayout.AsInteger;
      TEtiquetaTemplateVO(ObjetoVO).Tabela := EditTabela.Text;
      TEtiquetaTemplateVO(ObjetoVO).Formato := ComboBoxFormato.ItemIndex;
      TEtiquetaTemplateVO(ObjetoVO).QuantidadeRepeticoes := EditQuantidadeRepeticoes.AsInteger;
      TEtiquetaTemplateVO(ObjetoVO).Campo := EditCampo.Text;
      TEtiquetaTemplateVO(ObjetoVO).Filtro := EditFiltro.Text;

      if StatusTela = stInserindo then
      begin
        TEtiquetaTemplateController.Insere(TEtiquetaTemplateVO(ObjetoVO));
      end
      else if StatusTela = stEditando then
      begin
        /// EXERCICIO: Verifique se tem como serializar as listas junto com o objeto para realizar a comparação
        //if TEtiquetaTemplateVO(ObjetoVO).ToJSONString <> StringObjetoOld then
        //begin
          TEtiquetaTemplateController.Altera(TEtiquetaTemplateVO(ObjetoVO));
        //end
        //else
        //Application.MessageBox('Nenhum dado foi alterado.', 'Mensagem do Sistema', MB_OK + MB_ICONINFORMATION);
      end;
    except
      Result := False;
    end;
  end;
end;
{$ENDREGION}

{$REGION 'Controles de Grid'}
procedure TFEtiquetaTemplate.GridParaEdits;
var
  IdCabecalho: String;
begin
  inherited;

  if not CDSGrid.IsEmpty then
  begin
    IdCabecalho := IntToStr(IdRegistroSelecionado);
    ObjetoVO := TEtiquetaTemplateController.ConsultaObjeto('ID=' + IdCabecalho);
  end;

  if Assigned(ObjetoVO) then
  begin
    EditIdLayout.AsInteger := TEtiquetaTemplateVO(ObjetoVO).IdEtiquetaLayout;
    EditTabela.Text := TEtiquetaTemplateVO(ObjetoVO).Tabela;
    ComboBoxFormato.ItemIndex := TEtiquetaTemplateVO(ObjetoVO).Formato;
    EditQuantidadeRepeticoes.AsInteger := TEtiquetaTemplateVO(ObjetoVO).QuantidadeRepeticoes;
    EditCampo.Text := TEtiquetaTemplateVO(ObjetoVO).Campo;
    EditFiltro.Text := TEtiquetaTemplateVO(ObjetoVO).Filtro;

    // Serializa o objeto para consultar posteriormente se houve alterações
    FormatSettings.DecimalSeparator := '.';
    StringObjetoOld := ObjetoVO.ToJSONString;
    FormatSettings.DecimalSeparator := ',';
  end;
end;
{$ENDREGION}

{$REGION 'Campos Transientes'}
procedure TFEtiquetaTemplate.EditIdLayoutKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  Filtro: String;
begin
  if Key = VK_F1 then
  begin
    if EditIdLayout.Value <> 0 then
      Filtro := 'ID = ' + EditIdLayout.Text
    else
      Filtro := 'ID=0';

    try
      EditIdLayout.Clear;
      EditLayout.Clear;

        EtiquetaLayoutVO := TEtiquetaLayoutController.ConsultaObjeto(Filtro);
        if Assigned(EtiquetaLayoutVO) then
      begin
        EditIdLayout.Text := CDSTransiente.FieldByName('ID').AsString;
        EditLayout.Text := CDSTransiente.FieldByName('CODIGO_FABRICANTE').AsString;
      end
      else
      begin
        Exit;
        EditTabela.SetFocus;
      end;
    finally
    end;
  end;
end;
{$ENDREGION}

{$REGION 'Actions'}
procedure TFEtiquetaTemplate.ActionGerarEtiquetasExecute(Sender: TObject);
begin
  /// EXERCICIO
  ///  Faça uso do campo TABELA para trazer dados de outas tabelas do banco de dados

  /// EXERCICIO
  ///  Faça uso do campo CAMPO para informar qual campo deseja a impressão
  ///  Será preciso inserir outros campos desse tipo na tabela Template?

  /// EXERCICIO
  ///  O relatório está configurado estaticamente para imprimir EAN
  ///  Pesquise como imprimir QRCode no FastReports e implemente a solução

  /// EXERCICIO
  ///  Implemente o campo QUANTIDADE_REPETICOES. Ele é útil quando o usuário
  ///  quer imprimir uma mesma etiqueta várias vezes
  ConfiguraCDSFromVO(CDSProduto, TProdutoVO);
  TProdutoController.SetDataSet(CDSProduto);
    BotaoConsultar.Click;

  /// EXERCICIO
  ///  Carregue o arquivo de acordo com o ID do Layout.
  ///  Pesquise uma maneira de criar o arquivo dinamicamente de acordo
  ///  com os dados cadastrados na tabela de layout.
  frxReport.LoadFromFile('1.fr3');
  frxTable.DataSet := CDSProduto.FieldByName(';
  frxReport.ShowReport;
end;
{$ENDREGION}

end.

