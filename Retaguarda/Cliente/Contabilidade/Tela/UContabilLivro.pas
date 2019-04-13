{ *******************************************************************************
Title: T2Ti ERP
Description: Janela de Cadastro de Livros Contábeis para o módulo Contabilidade

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

@author Albert Eije (t2ti.com@gmail.com)
@version 2.0
******************************************************************************* }
unit UContabilLivro;

{$MODE Delphi}

interface

uses
  BrookHTTPClient, BrookFCLHTTPClientBroker, BrookHTTPUtils, BrookUtils, FPJson, ZDataset,
  LCLIntf, LCLType, LMessages, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UTelaCadastro, Menus, StdCtrls, ExtCtrls, Buttons, Grids, DBGrids,
  ComCtrls, LabeledCtrls, rxdbgrid, rxtoolbar, DBCtrls, StrUtils,
  Math, Constantes, CheckLst, ActnList, ToolWin, db, BufDataset, Biblioteca,
  ULookup, VO, ContabilLivroVO,
  ContabilLivroController;

  type

  { TFContabilLivro }

  TFContabilLivro = class(TFTelaCadastro)
    CDSContabilTermo: TBufDataset;
    DSContabilTermo: TDataSource;
    PanelMestre: TPanel;
    PageControlItens: TPageControl;
    tsItens: TTabSheet;
    PanelItens: TPanel;
    GridDetalhe: TRxDbGrid;
    EditDescricao: TLabeledEdit;
    EditCompetencia: TLabeledMaskEdit;
    ComboBoxFormaEscrituracao: TLabeledComboBox;
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
  FContabilLivro: TFContabilLivro;

implementation

uses UDataModule, ContabilTermoVO;
{$R *.lfm}

{$REGION 'Controles Infra'}
procedure TFContabilLivro.BotaoConsultarClick(Sender: TObject);
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
    RetornoConsulta := TContabilLivroController.Consulta(Filtro, IntToStr(Pagina));
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

procedure TFContabilLivro.BotaoSalvarClick(Sender: TObject);
begin
  inherited;
  BotaoConsultarClick(Sender);
end;

procedure TFContabilLivro.FormCreate(Sender: TObject);
begin
  ClasseObjetoGridVO := TContabilLivroVO;
  ObjetoController := TContabilLivroController.Create;

  inherited;
  BotaoImprimir.Visible := False;
  MenuImprimir.Visible := False;

  ConfiguraCDSFromVO(CDSContabilTermo, TContabilTermoVO);
  ConfiguraGridFromVO(GridDetalhe, TContabilTermoVO);
end;

procedure TFContabilLivro.LimparCampos;
begin
  inherited;
  CDSContabilTermo.Close;
  CDSContabilTermo.Open;
end;

procedure TFContabilLivro.ConfigurarLayoutTela;
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
function TFContabilLivro.DoInserir: Boolean;
begin
  Result := inherited DoInserir;

  ConfigurarLayoutTela;
  if Result then
  begin
    EditDescricao.SetFocus;
  end;
end;

function TFContabilLivro.DoEditar: Boolean;
begin
  Result := inherited DoEditar;

  ConfigurarLayoutTela;
  if Result then
  begin
    EditDescricao.SetFocus;
  end;
end;

function TFContabilLivro.DoExcluir: Boolean;
begin
  if inherited DoExcluir then
  begin
    try
      Result := TContabilLivroController.Exclui(IdRegistroSelecionado);
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

function TFContabilLivro.DoSalvar: Boolean;
var
  ContabilTermo: TContabilTermoVO;
begin
  Result := inherited DoSalvar;

  if Result then
  begin
    try
      if not Assigned(ObjetoVO) then
        ObjetoVO := TContabilLivroVO.Create;

      TContabilLivroVO(ObjetoVO).IdEmpresa := Sessao.Empresa.Id;
      TContabilLivroVO(ObjetoVO).Descricao := EditDescricao.Text;
      TContabilLivroVO(ObjetoVO).Competencia := EditCompetencia.Text;
      TContabilLivroVO(ObjetoVO).FormaEscrituracao := Copy(ComboBoxFormaEscrituracao.Text, 1, 1);

      // Termos
      CDSContabilTermo.DisableControls;
      CDSContabilTermo.First;
      while not CDSContabilTermo.Eof do
      begin
        ContabilTermo := TContabilTermoVO.Create;
        ContabilTermo.Id := CDSContabilTermo.FieldByName('ID').AsInteger;
        ContabilTermo.IdContabilLivro := TContabilLivroVO(ObjetoVO).Id;
        ContabilTermo.AberturaEncerramento := CDSContabilTermo.FieldByName('ABERTURA_ENCERRAMENTO').AsString;
        ContabilTermo.Numero := CDSContabilTermo.FieldByName('NUMERO').AsInteger;
        ContabilTermo.PaginaInicial := CDSContabilTermo.FieldByName('PAGINA_INICIAL').AsInteger;
        ContabilTermo.PaginaFinal := CDSContabilTermo.FieldByName('PAGINA_FINAL').AsInteger;
        ContabilTermo.Registrado := CDSContabilTermo.FieldByName('REGISTRADO').AsString;
        ContabilTermo.NumeroRegistro := CDSContabilTermo.FieldByName('NUMERO_REGISTRO').AsString;
        ContabilTermo.DataDespacho := CDSContabilTermo.FieldByName('DATA_DESPACHO').AsDateTime;
        ContabilTermo.DataAbertura := CDSContabilTermo.FieldByName('DATA_ABERTURA').AsDateTime;
        ContabilTermo.DataEncerramento := CDSContabilTermo.FieldByName('DATA_ENCERRAMENTO').AsDateTime;
        ContabilTermo.EscrituracaoInicio := CDSContabilTermo.FieldByName('ESCRITURACAO_INICIO').AsDateTime;
        ContabilTermo.EscrituracaoFim := CDSContabilTermo.FieldByName('ESCRITURACAO_FIM').AsDateTime;
        ContabilTermo.Texto := CDSContabilTermo.FieldByName('TEXTO').AsString;
        TContabilLivroVO(ObjetoVO).ListaContabilTermoVO.Add(ContabilTermo);
        CDSContabilTermo.Next;
      end;
      CDSContabilTermo.EnableControls;

      if StatusTela = stInserindo then
      begin
        TContabilLivroController.Insere(TContabilLivroVO(ObjetoVO));
      end
      else if StatusTela = stEditando then
      begin
        /// EXERCICIO: Verifique se tem como serializar as listas junto com o objeto para realizar a comparação
        //if TContabilLivroVO(ObjetoVO).ToJSONString <> StringObjetoOld then
        //begin
          TContabilLivroController.Altera(TContabilLivroVO(ObjetoVO));
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
procedure TFContabilLivro.GridDblClick(Sender: TObject);
begin
  inherited;
  ConfigurarLayoutTela;
end;

procedure TFContabilLivro.GridParaEdits;
var
  IdCabecalho: String;
  I: Integer;
  Current: TContabilTermoVO;
begin
  inherited;

  if not CDSGrid.IsEmpty then
  begin
    IdCabecalho := IntToStr(IdRegistroSelecionado);
    ObjetoVO := TContabilLivroController.ConsultaObjeto('ID=' + IdCabecalho);
  end;

  if Assigned(ObjetoVO) then
  begin
    EditDescricao.Text := TContabilLivroVO(ObjetoVO).Descricao;
    EditCompetencia.Text := TContabilLivroVO(ObjetoVO).Competencia;
    ComboBoxFormaEscrituracao.ItemIndex := AnsiIndexStr(TContabilLivroVO(ObjetoVO).FormaEscrituracao, ['G', 'R', 'A', 'Z', 'B']);

    // Termos
    for I := 0 to TContabilLivroVO(ObjetoVO).ListaContabilTermoVO.Count - 1 do
    begin
      Current := TContabilLivroVO(ObjetoVO).ListaContabilTermoVO[I];

      CDSContabilTermo.Append;
      CDSContabilTermo.FieldByName('ID').AsInteger := Current.id;
      CDSContabilTermo.FieldByName('ID_CONTABIL_Livro').AsInteger := Current.IdContabilLivro;
      CDSContabilTermo.FieldByName('ABERTURA_ENCERRAMENTO').AsString := Current.AberturaEncerramento;
      CDSContabilTermo.FieldByName('NUMERO').AsInteger := Current.Numero;
      CDSContabilTermo.FieldByName('PAGINA_INICIAL').AsInteger := Current.PaginaInicial;
      CDSContabilTermo.FieldByName('PAGINA_FINAL').AsInteger := Current.PaginaFinal;
      CDSContabilTermo.FieldByName('REGISTRADO').AsString := Current.Registrado;
      CDSContabilTermo.FieldByName('NUMERO_REGISTRO').AsString := Current.NumeroRegistro;
      CDSContabilTermo.FieldByName('DATA_DESPACHO').AsDateTime := Current.DataDespacho;
      CDSContabilTermo.FieldByName('DATA_ABERTURA').AsDateTime := Current.DataAbertura;
      CDSContabilTermo.FieldByName('DATA_ENCERRAMENTO').AsDateTime := Current.DataEncerramento;
      CDSContabilTermo.FieldByName('ESCRITURACAO_INICIO').AsDateTime := Current.EscrituracaoInicio;
      CDSContabilTermo.FieldByName('ESCRITURACAO_FIM').AsDateTime := Current.EscrituracaoFim;
      CDSContabilTermo.FieldByName('TEXTO').AsString := Current.Texto;
      CDSContabilTermo.Post;
    end;

    // Serializa o objeto para consultar posteriormente se houve alterações
    FormatSettings.DecimalSeparator := '.';
    StringObjetoOld := ObjetoVO.ToJSONString;
    FormatSettings.DecimalSeparator := ',';
  end;

  ConfigurarLayoutTela;
end;
{$ENDREGION}

end.

