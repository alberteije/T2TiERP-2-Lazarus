{ *******************************************************************************
Title: T2Ti ERP
Description: Janela de Cadastro de Livros Fiscais para o módulo Escrita Fiscal

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

@author Albert Eije (T2Ti.COM)
@version 2.0
******************************************************************************* }
unit UFiscalLivro;

{$MODE Delphi}

interface

uses
  BrookHTTPClient, BrookFCLHTTPClientBroker, BrookHTTPUtils, BrookUtils, FPJson, ZDataset,
  LCLIntf, LCLType, LMessages, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UTelaCadastro, Menus, StdCtrls, ExtCtrls, Buttons, Grids, DBGrids,
  ComCtrls, LabeledCtrls, rxdbgrid, rxtoolbar, DBCtrls, StrUtils,
  Math, Constantes, CheckLst, ActnList, ToolWin, db, BufDataset, Biblioteca,
  ULookup, VO, FiscalLivroVO,
  FiscalLivroController;

  type

  { TFFiscalLivro }

  TFFiscalLivro = class(TFTelaCadastro)
    CDSFiscalTermo: TBufDataset;
    DSFiscalTermo: TDataSource;
    PanelMestre: TPanel;
    PageControlItens: TPageControl;
    tsItens: TTabSheet;
    PanelItens: TPanel;
    GridDetalhe: TRxDbGrid;
    EditDescricao: TLabeledEdit;
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
  FFiscalLivro: TFFiscalLivro;

implementation

uses UDataModule, FiscalTermoVO;
{$R *.lfm}

{$REGION 'Controles Infra'}
procedure TFFiscalLivro.BotaoConsultarClick(Sender: TObject);
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
    RetornoConsulta := TFiscalLivroController.Consulta(Filtro, IntToStr(Pagina));
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

procedure TFFiscalLivro.BotaoSalvarClick(Sender: TObject);
begin
  inherited;
  BotaoConsultarClick(Sender);
end;

procedure TFFiscalLivro.FormCreate(Sender: TObject);
begin
  ClasseObjetoGridVO := TFiscalLivroVO;
  ObjetoController := TFiscalLivroController.Create;

  inherited;
  BotaoImprimir.Visible := False;

  ConfiguraCDSFromVO(CDSFiscalTermo, TFiscalTermoVO);
  ConfiguraGridFromVO(GridDetalhe, TFiscalTermoVO);

end;

procedure TFFiscalLivro.LimparCampos;
begin
  inherited;
  CDSFiscalTermo.Close;
  CDSFiscalTermo.Open;
end;

procedure TFFiscalLivro.ConfigurarLayoutTela;
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
function TFFiscalLivro.DoInserir: Boolean;
begin
  Result := inherited DoInserir;

  ConfigurarLayoutTela;
  if Result then
  begin
    EditDescricao.SetFocus;
  end;
end;

function TFFiscalLivro.DoEditar: Boolean;
begin
  Result := inherited DoEditar;

  ConfigurarLayoutTela;
  if Result then
  begin
    EditDescricao.SetFocus;
  end;
end;

function TFFiscalLivro.DoExcluir: Boolean;
begin
  if inherited DoExcluir then
  begin
    try
      Result := TFiscalLivroController.Exclui(IdRegistroSelecionado);
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

function TFFiscalLivro.DoSalvar: Boolean;
var
  FiscalTermo: TFiscalTermoVO;
begin
  Result := inherited DoSalvar;

  if Result then
  begin
    try
      if not Assigned(ObjetoVO) then
        ObjetoVO := TFiscalLivroVO.Create;

      TFiscalLivroVO(ObjetoVO).IdEmpresa := Sessao.Empresa.Id;
      TFiscalLivroVO(ObjetoVO).Descricao := EditDescricao.Text;

      // Termos
      CDSFiscalTermo.DisableControls;
      CDSFiscalTermo.First;
      while not CDSFiscalTermo.Eof do
      begin
        FiscalTermo := TFiscalTermoVO.Create;
        FiscalTermo.Id := CDSFiscalTermo.FieldByName('ID').AsInteger;
        FiscalTermo.IdFiscalLivro := TFiscalLivroVO(ObjetoVO).Id;
        FiscalTermo.AberturaEncerramento := CDSFiscalTermo.FieldByName('ABERTURA_ENCERRAMENTO').AsString;
        FiscalTermo.Numero := CDSFiscalTermo.FieldByName('NUMERO').AsInteger;
        FiscalTermo.PaginaInicial := CDSFiscalTermo.FieldByName('PAGINA_INICIAL').AsInteger;
        FiscalTermo.PaginaFinal := CDSFiscalTermo.FieldByName('PAGINA_FINAL').AsInteger;
        FiscalTermo.Registrado := CDSFiscalTermo.FieldByName('REGISTRADO').AsString;
        FiscalTermo.NumeroRegistro := CDSFiscalTermo.FieldByName('NUMERO_REGISTRO').AsString;
        FiscalTermo.DataDespacho := CDSFiscalTermo.FieldByName('DATA_DESPACHO').AsDateTime;
        FiscalTermo.DataAbertura := CDSFiscalTermo.FieldByName('DATA_ABERTURA').AsDateTime;
        FiscalTermo.DataEncerramento := CDSFiscalTermo.FieldByName('DATA_ENCERRAMENTO').AsDateTime;
        FiscalTermo.EscrituracaoInicio := CDSFiscalTermo.FieldByName('ESCRITURACAO_INICIO').AsDateTime;
        FiscalTermo.EscrituracaoFim := CDSFiscalTermo.FieldByName('ESCRITURACAO_FIM').AsDateTime;
        FiscalTermo.Texto := CDSFiscalTermo.FieldByName('TEXTO').AsString;
        TFiscalLivroVO(ObjetoVO).ListaFiscalTermoVO.Add(FiscalTermo);
        CDSFiscalTermo.Next;
      end;
      CDSFiscalTermo.EnableControls;

      if StatusTela = stInserindo then
      begin
        TFiscalLivroController.Insere(TFiscalLivroVO(ObjetoVO));
      end
      else if StatusTela = stEditando then
      begin
        /// EXERCICIO: Verifique se tem como serializar as listas junto com o objeto para realizar a comparação
        //if TFiscalLivroVO(ObjetoVO).ToJSONString <> StringObjetoOld then
        //begin
          TFiscalLivroController.Altera(TFiscalLivroVO(ObjetoVO));
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
procedure TFFiscalLivro.GridDblClick(Sender: TObject);
begin
  inherited;
  ConfigurarLayoutTela;
end;

procedure TFFiscalLivro.GridParaEdits;
var
  IdCabecalho: String;
  I: Integer;
  Current: TFiscalTermoVO;
begin
  inherited;

  if not CDSGrid.IsEmpty then
  begin
    IdCabecalho := IntToStr(IdRegistroSelecionado);
    ObjetoVO := TFiscalLivroController.ConsultaObjeto('ID=' + IdCabecalho);
  end;

  if Assigned(ObjetoVO) then
  begin
    EditDescricao.Text := TFiscalLivroVO(ObjetoVO).Descricao;

    // Termos
    for I := 0 to TFiscalLivroVO(ObjetoVO).ListaFiscalTermoVO.Count - 1 do
    begin
      Current := TFiscalLivroVO(ObjetoVO).ListaFiscalTermoVO[I];

      CDSFiscalTermo.Append;
      CDSFiscalTermo.FieldByName('ID').AsInteger := Current.id;
      CDSFiscalTermo.FieldByName('ID_Fiscal_Livro').AsInteger := Current.IdFiscalLivro;
      CDSFiscalTermo.FieldByName('ABERTURA_ENCERRAMENTO').AsString := Current.AberturaEncerramento;
      CDSFiscalTermo.FieldByName('NUMERO').AsInteger := Current.Numero;
      CDSFiscalTermo.FieldByName('PAGINA_INICIAL').AsInteger := Current.PaginaInicial;
      CDSFiscalTermo.FieldByName('PAGINA_FINAL').AsInteger := Current.PaginaFinal;
      CDSFiscalTermo.FieldByName('REGISTRADO').AsString := Current.Registrado;
      CDSFiscalTermo.FieldByName('NUMERO_REGISTRO').AsString := Current.NumeroRegistro;
      CDSFiscalTermo.FieldByName('DATA_DESPACHO').AsDateTime := Current.DataDespacho;
      CDSFiscalTermo.FieldByName('DATA_ABERTURA').AsDateTime := Current.DataAbertura;
      CDSFiscalTermo.FieldByName('DATA_ENCERRAMENTO').AsDateTime := Current.DataEncerramento;
      CDSFiscalTermo.FieldByName('ESCRITURACAO_INICIO').AsDateTime := Current.EscrituracaoInicio;
      CDSFiscalTermo.FieldByName('ESCRITURACAO_FIM').AsDateTime := Current.EscrituracaoFim;
      CDSFiscalTermo.FieldByName('TEXTO').AsString := Current.Texto;
      CDSFiscalTermo.Post;
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

