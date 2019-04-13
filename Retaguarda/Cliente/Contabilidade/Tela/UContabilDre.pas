{ *******************************************************************************
Title: T2Ti ERP
Description: Janela de DRE para o módulo Contabilidade

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
unit UContabilDre;

{$MODE Delphi}

interface

uses
  BrookHTTPClient, BrookFCLHTTPClientBroker, BrookHTTPUtils, BrookUtils, FPJson, ZDataset,
  LCLIntf, LCLType, LMessages, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UTelaCadastro, Menus, StdCtrls, ExtCtrls, Buttons, Grids, DBGrids,
  ComCtrls, LabeledCtrls, rxdbgrid, rxtoolbar, DBCtrls, StrUtils,
  Math, Constantes, CheckLst, ActnList, ToolWin, db, BufDataset, Biblioteca,
  ULookup, VO, ContabilDreCabecalhoVO,
  ContabilDreCabecalhoController;

  type

  { TFContabilDre }

  TFContabilDre = class(TFTelaCadastro)
    CDSContabilDreDetalhe: TBufDataset;
    DSContabilDreDetalhe: TDataSource;
    PanelMestre: TPanel;
    PageControlItens: TPageControl;
    tsItens: TTabSheet;
    PanelItens: TPanel;
    GridDetalhe: TRxDbGrid;
    ComboBoxPadrao: TLabeledComboBox;
    EditDescricao: TLabeledEdit;
    EditPeriodoInicial: TLabeledMaskEdit;
    EditPeriodoFinal: TLabeledMaskEdit;
    procedure FormCreate(Sender: TObject);
    procedure GridDblClick(Sender: TObject);

    procedure BotaoConsultarClick(Sender: TObject);
    procedure BotaoSalvarClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure GridParaEdits; override;
    procedure LimparCampos; override;

    // Controles CRUD
    function DoInserir: Boolean; override;
    function DoEditar: Boolean; override;
    function DoExcluir: Boolean; override;
    function DoSalvar: Boolean; override;

    procedure ConfigurarLayoutTela;
  end;

var
  FContabilDre: TFContabilDre;

implementation

uses UDataModule, ContabilDreDetalheVO, ContabilLoteVO,
ContabilLoteController;
{$R *.lfm}

{$REGION 'Controles Infra'}
procedure TFContabilDre.BotaoConsultarClick(Sender: TObject);
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
    RetornoConsulta := TContabilDreCabecalhoController.Consulta(Filtro, IntToStr(Pagina));
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

procedure TFContabilDre.BotaoSalvarClick(Sender: TObject);
begin
  inherited;
  BotaoConsultarClick(Sender);
end;

procedure TFContabilDre.FormCreate(Sender: TObject);
begin
  ClasseObjetoGridVO := TContabilDreCabecalhoVO;
  ObjetoController := TContabilDreCabecalhoController.Create;

  inherited;
  BotaoImprimir.Visible := False;
  MenuImprimir.Visible := False;

  ConfiguraCDSFromVO(CDSContabilDreDetalhe, TContabilDreDetalheVO);
  ConfiguraGridFromVO(GridDetalhe, TContabilDreDetalheVO);
end;

procedure TFContabilDre.LimparCampos;
begin
  inherited;
  CDSContabilDreDetalhe.Close;
  CDSContabilDreDetalhe.Open;
end;

procedure TFContabilDre.ConfigurarLayoutTela;
begin
  PanelEdits.Enabled := True;

  if StatusTela = stNavegandoEdits then
  begin
    PanelMestre.Enabled := False;
    PanelItens.Enabled := False;
  end
  else
  begin
    PanelMestre.Enabled := True;
    PanelItens.Enabled := True;
  end;
end;
{$ENDREGION}

{$REGION 'Controles CRUD'}
function TFContabilDre.DoInserir: Boolean;
begin
  Result := inherited DoInserir;

  ConfigurarLayoutTela;
  if Result then
  begin
    EditDescricao.SetFocus;
  end;
end;

function TFContabilDre.DoEditar: Boolean;
begin
  Result := inherited DoEditar;

  ConfigurarLayoutTela;
  if Result then
  begin
    EditDescricao.SetFocus;
  end;
end;

function TFContabilDre.DoExcluir: Boolean;
begin
  if inherited DoExcluir then
  begin
    try
      Result := TContabilDreCabecalhoController.Exclui(IdRegistroSelecionado);
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

function TFContabilDre.DoSalvar: Boolean;
var
  ContabilDreDetalhe: TContabilDreDetalheVO;
begin
  Result := inherited DoSalvar;

  if Result then
  begin
    try
      if not Assigned(ObjetoVO) then
        ObjetoVO := TContabilDreCabecalhoVO.Create;

      TContabilDreCabecalhoVO(ObjetoVO).IdEmpresa := Sessao.Empresa.Id;
      TContabilDreCabecalhoVO(ObjetoVO).Descricao := EditDescricao.Text;
      TContabilDreCabecalhoVO(ObjetoVO).Padrao := IfThen(ComboBoxPadrao.ItemIndex = 0, 'S', 'N');
      TContabilDreCabecalhoVO(ObjetoVO).PeriodoInicial := EditPeriodoInicial.Text;
      TContabilDreCabecalhoVO(ObjetoVO).PeriodoFinal := EditPeriodoFinal.Text;

      // Detalhes
      CDSContabilDreDetalhe.DisableControls;
      CDSContabilDreDetalhe.First;
      while not CDSContabilDreDetalhe.Eof do
      begin
        ContabilDreDetalhe := TContabilDreDetalheVO.Create;
        ContabilDreDetalhe.Id := CDSContabilDreDetalhe.FieldByName('ID').AsInteger;
        ContabilDreDetalhe.IdContabilDreCabecalho := TContabilDreCabecalhoVO(ObjetoVO).Id;
        ContabilDreDetalhe.Classificacao := CDSContabilDreDetalhe.FieldByName('CLASSIFICACAO').AsString;
        ContabilDreDetalhe.Descricao := CDSContabilDreDetalhe.FieldByName('DESCRICAO').AsString;
        ContabilDreDetalhe.FormaCalculo := CDSContabilDreDetalhe.FieldByName('FORMA_CALCULO').AsString;
        ContabilDreDetalhe.Sinal := CDSContabilDreDetalhe.FieldByName('SINAL').AsString;
        ContabilDreDetalhe.Natureza := CDSContabilDreDetalhe.FieldByName('NATUREZA').AsString;
        ContabilDreDetalhe.Valor := CDSContabilDreDetalhe.FieldByName('VALOR').AsFloat;
        TContabilDreCabecalhoVO(ObjetoVO).ListaContabilDreDetalheVO.Add(ContabilDreDetalhe);
        CDSContabilDreDetalhe.Next;
      end;
      CDSContabilDreDetalhe.EnableControls;

      if StatusTela = stInserindo then
      begin
        TContabilDreCabecalhoController.Insere(TContabilDreCabecalhoVO(ObjetoVO));
      end
      else if StatusTela = stEditando then
      begin
        /// EXERCICIO: Verifique se tem como serializar as listas junto com o objeto para realizar a comparação
        //if TContabilDreCabecalhoVO(ObjetoVO).ToJSONString <> StringObjetoOld then
        //begin
          TContabilDreCabecalhoController.Altera(TContabilDreCabecalhoVO(ObjetoVO));
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

{$REGION 'Controle de Grid'}
procedure TFContabilDre.GridDblClick(Sender: TObject);
begin
  inherited;
  ConfigurarLayoutTela;
end;

procedure TFContabilDre.GridParaEdits;
var
  IdCabecalho: String;
  Current: TContabilDreDetalheVO;
  i:integer;
begin
  inherited;

  if not CDSGrid.IsEmpty then
  begin
    IdCabecalho := IntToStr(IdRegistroSelecionado);
    ObjetoVO := TContabilDreCabecalhoController.ConsultaObjeto('ID=' + IdCabecalho);
  end;

  if Assigned(ObjetoVO) then
  begin
    EditDescricao.Text := TContabilDreCabecalhoVO(ObjetoVO).Descricao;
    ComboBoxPadrao.ItemIndex := IfThen(TContabilDreCabecalhoVO(ObjetoVO).Padrao = 'S', 0, 1);
    EditPeriodoInicial.Text := TContabilDreCabecalhoVO(ObjetoVO).PeriodoInicial;
    EditPeriodoFinal.Text := TContabilDreCabecalhoVO(ObjetoVO).PeriodoFinal;

    // Detalhes
    for I := 0 to TContabilDreCabecalhoVO(ObjetoVO).ListaContabilDreDetalheVO.Count - 1 do
    begin
      Current := TContabilDreCabecalhoVO(ObjetoVO).ListaContabilDreDetalheVO[I];

      CDSContabilDreDetalhe.Append;
      CDSContabilDreDetalhe.FieldByName('ID').AsInteger := Current.id;
      CDSContabilDreDetalhe.FieldByName('ID_CONTABIL_DRE_CABECALHO').AsInteger := Current.IdContabilDreCabecalho;
      CDSContabilDreDetalhe.FieldByName('CLASSIFICACAO').AsString := Current.Classificacao;
      CDSContabilDreDetalhe.FieldByName('DESCRICAO').AsString := Current.Descricao;
      CDSContabilDreDetalhe.FieldByName('FORMA_CALCULO').AsString := Current.FormaCalculo;
      CDSContabilDreDetalhe.FieldByName('SINAL').AsString := Current.Sinal;
      CDSContabilDreDetalhe.FieldByName('NATUREZA').AsString := Current.Natureza;
      CDSContabilDreDetalhe.FieldByName('VALOR').AsFloat := Current.Valor;
      CDSContabilDreDetalhe.Post;
    end;

    // Serializa o objeto para consultar posteriormente se houve alterações
    FormatSettings.DecimalSeparator := '.';
    StringObjetoOld := ObjetoVO.ToJSONString;
    FormatSettings.DecimalSeparator := ',';
  end;

  ConfigurarLayoutTela;
end;
{$ENDREGION}

/// EXERCICIO
///  Implemente as rotinas automáticas no sistema

end.

