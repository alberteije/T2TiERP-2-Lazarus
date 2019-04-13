{ *******************************************************************************
  Title: T2Ti ERP
  Description: Janela para confirmar a Cotação de Compra

The MIT License

Copyright: Copyright (C) 2015 T2Ti.COM

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

@author Albert Eije
@version 2.0
******************************************************************************* }
unit UCompraConfirmaCotacao;

{$MODE Delphi}

interface

uses
  BrookHTTPClient, BrookFCLHTTPClientBroker, BrookHTTPUtils, BrookUtils, FPJson, ZDataset,
  LCLIntf, LCLType, LMessages, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UTelaCadastro, Menus, StdCtrls, ExtCtrls, Buttons, Grids, DBGrids,
  ComCtrls, LabeledCtrls, rxdbgrid, rxtoolbar, DBCtrls, StrUtils,
  Math, Constantes, CheckLst, ActnList, ToolWin, db, BufDataset, Biblioteca,
  ULookup, VO;
type

  { TFCompraConfirmaCotacao }

  TFCompraConfirmaCotacao = class(TFTelaCadastro)
    BevelEdits: TBevel;
    EditDescricao: TLabeledEdit;
    EditDataCotacao: TLabeledDateEdit;
    GroupBoxItensCotacao: TGroupBox;
    GridCompraCotacaoDetalhe: TRxDbGrid;
    GroupBoxFornecedores: TGroupBox;
    GridCompraFornecedorCotacao: TRxDbGrid;
    DSCompraFornecedorCotacao: TDataSource;
    DSCompraCotacaoDetalhe: TDataSource;
    CDSCompraFornecedorCotacao: TBufDataSet;
    CDSCompraCotacaoDetalhe: TBufDataSet;
    ActionToolBar3: TToolPanel;
    ActionManager1: TActionList;
    ActionGerarCsv: TAction;
    ActionLerCsvFornecedor: TAction;
    procedure FormCreate(Sender: TObject);
    procedure GridDblClick(Sender: TObject);
    procedure CDSCompraFornecedorCotacaoAfterPost(DataSet: TDataSet);
    procedure CDSCompraCotacaoDetalheAfterPost(DataSet: TDataSet);
    procedure ActionGerarCsvExecute(Sender: TObject);
    procedure ActionLerCsvFornecedorExecute(Sender: TObject);
    procedure BotaoConsultarClick(Sender: TObject);
    procedure BotaoSalvarClick(Sender: TObject);
  private
    { Private declarations }
    function ValidarDadosInformados: Boolean;
  public
    { Public declarations }
    procedure GridParaEdits; override;
    procedure LimparCampos; override;

    // Controles CRUD
    function DoEditar: Boolean; override;
    function DoSalvar: Boolean; override;

    procedure ConfigurarLayoutTela;
  end;

var
  FCompraConfirmaCotacao: TFCompraConfirmaCotacao;

implementation

uses UDataModule, CompraCotacaoDetalheVO, CompraFornecedorCotacaoController,
CompraCotacaoDetalheController, ViewCompraItemCotacaoVO, ViewCompraItemCotacaoController,
CompraCotacaoController, CompraCotacaoVO, CompraFornecedorCotacaoVO;

{$R *.lfm}

{$REGION 'Infra'}
procedure TFCompraConfirmaCotacao.BotaoConsultarClick(Sender: TObject);
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
    RetornoConsulta := TCompraCotacaoController.Consulta(Filtro, IntToStr(Pagina));
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

procedure TFCompraConfirmaCotacao.BotaoSalvarClick(Sender: TObject);
begin
  inherited;
  BotaoConsultarClick(Sender);
end;

procedure TFCompraConfirmaCotacao.FormCreate(Sender: TObject);
begin
  ClasseObjetoGridVO := TCompraCotacaoVO;
  ObjetoController := TCompraCotacaoController.Create;
  inherited;
  BotaoInserir.Visible := False;
  BotaoExcluir.Visible := False;

  ConfiguraCDSFromVO(CDSCompraCotacaoDetalhe, TViewCompraItemCotacaoVO);
  ConfiguraGridFromVO(GridCompraCotacaoDetalhe, TViewCompraItemCotacaoVO);

  ConfiguraCDSFromVO(CDSCompraFornecedorCotacao, TCompraFornecedorCotacaoVO);
  ConfiguraGridFromVO(GridCompraFornecedorCotacao, TCompraFornecedorCotacaoVO);
end;

procedure TFCompraConfirmaCotacao.LimparCampos;
begin
  inherited;
  CDSCompraFornecedorCotacao.Close;
  CDSCompraCotacaoDetalhe.Close;
  CDSCompraFornecedorCotacao.Open;
  CDSCompraCotacaoDetalhe.Open;
end;

procedure TFCompraConfirmaCotacao.ConfigurarLayoutTela;
begin
  if TCompraCotacaoVO(ObjetoVO).Situacao = 'F' then
  begin
    Application.MessageBox('Cotação já fechada. Os dados serão exibidos apenas para consulta.', 'Mensagem do Sistema', MB_OK + MB_ICONINFORMATION);
    GridCompraFornecedorCotacao.ReadOnly := True;
    GridCompraCotacaoDetalhe.ReadOnly := True;
  end;
  EditDataCotacao.ReadOnly := True;
  EditDescricao.ReadOnly := True;
  PanelEdits.Enabled := True;
end;
{$ENDREGION}

{$REGION 'Controles CRUD'}
function TFCompraConfirmaCotacao.DoEditar: Boolean;
begin
  Result := inherited DoEditar;

  ConfigurarLayoutTela;
  if Result then
  begin
    EditDataCotacao.SetFocus;
  end;
end;

function TFCompraConfirmaCotacao.DoSalvar: Boolean;
var
  CompraFornecedorCotacao: TCompraFornecedorCotacaoVO;
  CompraCotacaoDetalhe: TCompraCotacaoDetalheVO;
  DadosAlterados: Boolean;
begin
  if TCompraCotacaoVO(ObjetoVO).Situacao <> 'F' then
  begin
    if ValidarDadosInformados then
    begin
      DadosAlterados := False;
      Result := inherited DoSalvar;

      if Result then
      begin
        try

          // Cotação Fornecedor e Seus Detalhes
          CDSCompraFornecedorCotacao.First;
          CDSCompraCotacaoDetalhe.DisableControls;
          while not CDSCompraFornecedorCotacao.Eof do
          begin
            
              DadosAlterados := True;

              CompraFornecedorCotacao := TCompraFornecedorCotacaoVO.Create;
              CompraFornecedorCotacao.Id := CDSCompraFornecedorCotacao.FieldByName('ID').AsInteger;
              CompraFornecedorCotacao.IdFornecedor := CDSCompraFornecedorCotacao.FieldByName('ID_FORNECEDOR').AsInteger;
              CompraFornecedorCotacao.IdCompraCotacao := TCompraCotacaoVO(ObjetoVO).Id;
              CompraFornecedorCotacao.PrazoEntrega := CDSCompraFornecedorCotacao.FieldByName('PRAZO_ENTREGA').AsString;
              CompraFornecedorCotacao.CondicoesPagamento := CDSCompraFornecedorCotacao.FieldByName('CONDICOES_PAGAMENTO').AsString;
              CompraFornecedorCotacao.ValorSubtotal := CDSCompraFornecedorCotacao.FieldByName('VALOR_SUBTOTAL').AsFloat;
              CompraFornecedorCotacao.TaxaDesconto := CDSCompraFornecedorCotacao.FieldByName('TAXA_DESCONTO').AsFloat;
              CompraFornecedorCotacao.ValorDesconto := CDSCompraFornecedorCotacao.FieldByName('VALOR_DESCONTO').AsFloat;
              CompraFornecedorCotacao.Total := CDSCompraFornecedorCotacao.FieldByName('TOTAL').AsFloat;

              //carrega os itens de cada fornecedor
              CDSCompraCotacaoDetalhe.First;
              while not CDSCompraCotacaoDetalhe.Eof do
              begin
                
                  CompraCotacaoDetalhe := TCompraCotacaoDetalheVO.Create;
                  CompraCotacaoDetalhe.Id := CDSCompraCotacaoDetalhe.FieldByName('ID').AsInteger;
                  CompraCotacaoDetalhe.IdCompraFornecedorCotacao := CompraFornecedorCotacao.Id;
                  CompraCotacaoDetalhe.IdProduto := CDSCompraCotacaoDetalhe.FieldByName('ID_PRODUTO').AsInteger;
                  CompraCotacaoDetalhe.Quantidade := CDSCompraCotacaoDetalhe.FieldByName('QUANTIDADE').AsFloat;
                  CompraCotacaoDetalhe.ValorUnitario := CDSCompraCotacaoDetalhe.FieldByName('VALOR_UNITARIO').AsFloat;
                  CompraCotacaoDetalhe.ValorSubtotal := CDSCompraCotacaoDetalhe.FieldByName('VALOR_SUBTOTAL').AsFloat;
                  CompraCotacaoDetalhe.TaxaDesconto := CDSCompraCotacaoDetalhe.FieldByName('TAXA_DESCONTO').AsFloat;
                  CompraCotacaoDetalhe.ValorDesconto := CDSCompraCotacaoDetalhe.FieldByName('VALOR_DESCONTO').AsFloat;
                  CompraCotacaoDetalhe.ValorTotal := CDSCompraCotacaoDetalhe.FieldByName('VALOR_TOTAL').AsFloat;
                  CompraFornecedorCotacao.ListaCompraCotacaoDetalhe.Add(CompraCotacaoDetalhe);
                
                CDSCompraCotacaoDetalhe.Next;
              end;
              TCompraCotacaoVO(ObjetoVO).ListaCompraFornecedorCotacao.Add(CompraFornecedorCotacao);
            
            CDSCompraFornecedorCotacao.Next;
          end;
          CDSCompraFornecedorCotacao.First;
          CDSCompraCotacaoDetalhe.First;
          CDSCompraCotacaoDetalhe.EnableControls;

          if DadosAlterados then
          begin
            TCompraCotacaoVO(ObjetoVO).Situacao := 'C';
            TCompraCotacaoController.Altera(TCompraCotacaoVO(ObjetoVO));
          end
          else
            Application.MessageBox('Nenhum dado foi alterado.', 'Mensagem do Sistema', MB_OK + MB_ICONINFORMATION);
        except
          Result := False;
        end;
      end;
    end
    else
      Exit(False);
  end;
end;
{$ENDREGION}

{$REGION 'Controle de Grid'}
procedure TFCompraConfirmaCotacao.GridParaEdits;
var
  IdCabecalho: String;
  Filtro: String;
  RetornoConsulta: TZQuery;
  ListaCampos: TStringList;
  I: Integer;
begin
  inherited;

  if not CDSGrid.IsEmpty then
  begin
    IdCabecalho := IntToStr(IdRegistroSelecionado);
    ObjetoVO := TCompraCotacaoController.ConsultaObjeto('ID=' + IdCabecalho);
  end;

  if Assigned(ObjetoVO) then
  begin
    EditDataCotacao.Date := TCompraCotacaoVO(ObjetoVO).DataCotacao;
    EditDescricao.Text := TCompraCotacaoVO(ObjetoVO).Descricao;

    // Fornecedores da Cotação
    Filtro := 'ID_COMPRA_COTACAO=' + QuotedStr(IntToStr(TCompraCotacaoVO(ObjetoVO).Id));
    ListaCampos  := TStringList.Create;
    RetornoConsulta := TCompraFornecedorCotacaoController.Consulta(Filtro, '0');
    RetornoConsulta.Active := True;

    RetornoConsulta.GetFieldNames(ListaCampos);

    RetornoConsulta.First;
    while not RetornoConsulta.EOF do begin
      CDSCompraFornecedorCotacao.Append;
      for i := 0 to ListaCampos.Count - 1 do
      begin
        CDSCompraFornecedorCotacao.FieldByName(ListaCampos[i]).Value := RetornoConsulta.FieldByName(ListaCampos[i]).Value;
      end;
      CDSCompraFornecedorCotacao.Post;
      RetornoConsulta.Next;
    end;

    // Itens da Cotação - Baixa todos e controla o mestre/detalhe local através do BufDataset
    /// EXERCICIO: Implemente o controle mestre/detalhe local
    Filtro := 'ID_COTACAO=' + QuotedStr(IntToStr(TCompraCotacaoVO(ObjetoVO).Id));

    ListaCampos  := TStringList.Create;
    RetornoConsulta := TViewCompraItemCotacaoController.Consulta(Filtro, '0');
    RetornoConsulta.Active := True;

    RetornoConsulta.GetFieldNames(ListaCampos);

    RetornoConsulta.First;
    while not RetornoConsulta.EOF do begin
      CDSCompraCotacaoDetalhe.Append;
      for i := 0 to ListaCampos.Count - 1 do
      begin
        CDSCompraCotacaoDetalhe.FieldByName(ListaCampos[i]).Value := RetornoConsulta.FieldByName(ListaCampos[i]).Value;
      end;
      CDSCompraCotacaoDetalhe.Post;
      RetornoConsulta.Next;
    end;
  end;
end;

procedure TFCompraConfirmaCotacao.CDSCompraCotacaoDetalheAfterPost(DataSet: TDataSet);
begin
  if CDSCompraCotacaoDetalhe.FieldByName('ID').AsInteger = 0 then
    CDSCompraCotacaoDetalhe.Delete;
end;

procedure TFCompraConfirmaCotacao.CDSCompraFornecedorCotacaoAfterPost(DataSet: TDataSet);
begin
  if CDSCompraFornecedorCotacao.FieldByName('ID').AsInteger = 0 then
    CDSCompraFornecedorCotacao.Delete;
end;

procedure TFCompraConfirmaCotacao.GridDblClick(Sender: TObject);
begin
  inherited;
  ConfigurarLayoutTela;
end;
{$ENDREGION}

{$REGION 'Actions'}
function TFCompraConfirmaCotacao.ValidarDadosInformados: Boolean;
var
  Mensagem: String;
  TotalDetalhe: Extended;
begin
  CDSCompraCotacaoDetalhe.DisableControls;
  CDSCompraFornecedorCotacao.First;
  while not CDSCompraFornecedorCotacao.Eof do
  begin
    if (CDSCompraFornecedorCotacao.FieldByName('TAXA_DESCONTO').AsFloat = 0) and (CDSCompraFornecedorCotacao.FieldByName('VALOR_DESCONTO').AsFloat <> 0) then
      Mensagem := Mensagem + #13 + 'Taxa do desconto não corresponde ao valor do desconto. Registro cabeçalho. [Id Fornecedor = ' + CDSCompraFornecedorCotacao.FieldByName('ID_FORNECEDOR').AsString + ']';
    if (CDSCompraFornecedorCotacao.FieldByName('TAXA_DESCONTO').AsFloat <> 0) and (CDSCompraFornecedorCotacao.FieldByName('VALOR_DESCONTO').AsFloat = 0) then
      Mensagem := Mensagem + #13 + 'Taxa do desconto não corresponde ao valor do desconto. Registro cabeçalho. [Id Fornecedor = ' + CDSCompraFornecedorCotacao.FieldByName('ID_FORNECEDOR').AsString + ']';
    if (CDSCompraFornecedorCotacao.FieldByName('TAXA_DESCONTO').AsFloat <> 0) and (CDSCompraFornecedorCotacao.FieldByName('VALOR_DESCONTO').AsFloat <> 0) then
      if FloatToStrF(CDSCompraFornecedorCotacao.FieldByName('VALOR_SUBTOTAL').AsFloat * CDSCompraFornecedorCotacao.FieldByName('TAXA_DESCONTO').AsFloat / 100, ffCurrency, 18, 2) <> FloatToStrF(CDSCompraFornecedorCotacao.FieldByName('VALOR_DESCONTO').AsFloat, ffCurrency, 18, 2) then
        Mensagem := Mensagem + #13 + 'Valor do desconto calculado de forma incorreta. Registro cabeçalho. [Id Fornecedor = ' + CDSCompraFornecedorCotacao.FieldByName('ID_FORNECEDOR').AsString + ']';
    if FloatToStrF(CDSCompraFornecedorCotacao.FieldByName('VALOR_SUBTOTAL').AsFloat - CDSCompraFornecedorCotacao.FieldByName('VALOR_DESCONTO').AsFloat, ffCurrency, 18, 2) <> FloatToStrF(CDSCompraFornecedorCotacao.FieldByName('TOTAL').AsFloat, ffCurrency, 18, 2) then
      Mensagem := Mensagem + #13 + 'Valor total calculado de forma incorreta (Total = SubTotal - Desconto). Registro cabeçalho. [Id Fornecedor = ' + CDSCompraFornecedorCotacao.FieldByName('ID_FORNECEDOR').AsString + ']';
    //
    TotalDetalhe := 0;
    CDSCompraCotacaoDetalhe.First;
    while not CDSCompraCotacaoDetalhe.Eof do
    begin
      if (CDSCompraCotacaoDetalhe.FieldByName('TAXA_DESCONTO').AsFloat = 0) and (CDSCompraCotacaoDetalhe.FieldByName('VALOR_DESCONTO').AsFloat <> 0) then
        Mensagem := Mensagem + #13 + 'Taxa do desconto não corresponde ao valor do desconto. Registro detalhe. [Id Produto = ' + CDSCompraCotacaoDetalhe.FieldByName('ID_PRODUTO').AsString + '] - [Id Fornecedor = ' + CDSCompraFornecedorCotacao.FieldByName('ID_FORNECEDOR').AsString + ']';
      if (CDSCompraCotacaoDetalhe.FieldByName('TAXA_DESCONTO').AsFloat <> 0) and (CDSCompraCotacaoDetalhe.FieldByName('VALOR_DESCONTO').AsFloat = 0) then
        Mensagem := Mensagem + #13 + 'Taxa do desconto não corresponde ao valor do desconto. Registro detalhe. [Id Produto = ' + CDSCompraCotacaoDetalhe.FieldByName('ID_PRODUTO').AsString + '] - [Id Fornecedor = ' + CDSCompraFornecedorCotacao.FieldByName('ID_FORNECEDOR').AsString + ']';
      if (CDSCompraCotacaoDetalhe.FieldByName('TAXA_DESCONTO').AsFloat <> 0) and (CDSCompraCotacaoDetalhe.FieldByName('VALOR_DESCONTO').AsFloat <> 0) then
        if FloatToStrF(CDSCompraCotacaoDetalhe.FieldByName('VALOR_SUBTOTAL').AsFloat * CDSCompraCotacaoDetalhe.FieldByName('TAXA_DESCONTO').AsFloat / 100, ffCurrency, 18, 2) <> FloatToStrF(CDSCompraCotacaoDetalhe.FieldByName('VALOR_DESCONTO').AsFloat, ffCurrency, 18, 2) then
          Mensagem := Mensagem + #13 + 'Valor do desconto calculado de forma incorreta. Registro detalhe. [Id Produto = ' + CDSCompraCotacaoDetalhe.FieldByName('ID_PRODUTO').AsString + '] - [Id Fornecedor = ' + CDSCompraFornecedorCotacao.FieldByName('ID_FORNECEDOR').AsString + ']';
      if FloatToStrF(CDSCompraCotacaoDetalhe.FieldByName('QUANTIDADE').AsFloat * CDSCompraCotacaoDetalhe.FieldByName('VALOR_UNITARIO').AsFloat, ffCurrency, 18, 2) <> FloatToStrF(CDSCompraCotacaoDetalhe.FieldByName('VALOR_SUBTOTAL').AsFloat, ffCurrency, 18, 2) then
        Mensagem := Mensagem + #13 + 'Valor subtotal calculado de forma incorreta (SubTotal = Quantidade * Valor Unitário). Registro detalhe. [Id Produto = ' + CDSCompraCotacaoDetalhe.FieldByName('ID_PRODUTO').AsString + '] - [Id Fornecedor = ' + CDSCompraFornecedorCotacao.FieldByName('ID_FORNECEDOR').AsString + ']';
      if FloatToStrF(CDSCompraCotacaoDetalhe.FieldByName('VALOR_SUBTOTAL').AsFloat - CDSCompraCotacaoDetalhe.FieldByName('VALOR_DESCONTO').AsFloat, ffCurrency, 18, 2) <> FloatToStrF(CDSCompraCotacaoDetalhe.FieldByName('VALOR_TOTAL').AsFloat, ffCurrency, 18, 2) then
        Mensagem := Mensagem + #13 + 'Valor total calculado de forma incorreta (Total = SubTotal - Desconto). Registro detalhe. [Id Produto = ' + CDSCompraCotacaoDetalhe.FieldByName('ID_PRODUTO').AsString + '] - [Id Fornecedor = ' + CDSCompraFornecedorCotacao.FieldByName('ID_FORNECEDOR').AsString + ']';

      TotalDetalhe := TotalDetalhe + CDSCompraCotacaoDetalhe.FieldByName('VALOR_TOTAL').AsFloat;

      CDSCompraCotacaoDetalhe.Next;
    end;

    if FloatToStrF(TotalDetalhe, ffCurrency, 18, 2) <> FloatToStrF(CDSCompraFornecedorCotacao.FieldByName('TOTAL').AsFloat, ffCurrency, 18, 2) then
      Mensagem := Mensagem + #13 + 'Soma dos itens não bate com o valor total. Registro cabeçalho. Id Fornecedor = ' + CDSCompraFornecedorCotacao.FieldByName('ID_FORNECEDOR').AsString;

    CDSCompraFornecedorCotacao.Next;
  end;
  CDSCompraFornecedorCotacao.First;
  CDSCompraCotacaoDetalhe.First;
  CDSCompraCotacaoDetalhe.EnableControls;
  //
  if Mensagem <> '' then
  begin
    Application.MessageBox(PChar('Ocorreram erros na validação dos dados informados. Lista de erros abaixo: ' + #13 + Mensagem), 'Erro do sistema', MB_OK + MB_ICONERROR);
    Result := False;
  end
  else
    Result := True;
end;

procedure TFCompraConfirmaCotacao.ActionGerarCsvExecute(Sender: TObject);
var
  NomeArquivo: String;
begin
  try
    CDSCompraFornecedorCotacao.DisableControls;
    CDSCompraFornecedorCotacao.First;
    while not CDSCompraFornecedorCotacao.Eof do
    begin
      NomeArquivo := 'FornecedorCotacao.' + IntToStr(TCompraCotacaoVO(ObjetoVO).Id) + '.' + CDSCompraFornecedorCotacao.FieldByName('ID_FORNECEDOR').AsString + '.csv';
      /// EXERCICIO: Pesquise se existe uma  maneira de salvar os dados do BufDataSet o da Grid diretamente para CSV. Caso não tenha, crie outro laço para salvar os dados da grid
      CDSCompraCotacaoDetalhe.SaveToFile(NomeArquivo);
      CDSCompraFornecedorCotacao.Next;
    end;
    CDSCompraFornecedorCotacao.First;
    CDSCompraFornecedorCotacao.EnableControls;

    Application.MessageBox('Arquivos gerados com sucesso!', 'Informação do sistema', MB_OK + MB_ICONINFORMATION);
  except
    on E: Exception do
      Application.MessageBox(PChar('Ocorreu um erro durante a geração dos arquivos. Informe a mensagem ao Administrador do sistema.' + #13 + #13 + E.Message), 'Erro do sistema', MB_OK + MB_ICONERROR);
  end;
end;

procedure TFCompraConfirmaCotacao.ActionLerCsvFornecedorExecute(Sender: TObject);
var
  OpcoesArquivo, ConteudoArquivo: TStringList;
  Arquivo: String;
  i: Integer;
  SubTotal, TotalDesconto, TotalGeral: Extended;
begin
  if FDataModule.OpenDialog.Execute then
  begin
    try
      try
        OpcoesArquivo := TStringList.Create;
        ConteudoArquivo := TStringList.Create;
        //
        Arquivo := ExtractFileName(FDataModule.OpenDialog.FileName);
        Split('.', Arquivo, OpcoesArquivo);

        if StrToInt(OpcoesArquivo[1]) <> TCompraCotacaoVO(ObjetoVO).Id then
        begin
          Application.MessageBox('O arquivo selecionado não pertence a cotação!', 'Informação do sistema', MB_OK + MB_ICONINFORMATION);
          Exit;
        end;

        if OpcoesArquivo[2] <> CDSCompraFornecedorCotacao.FieldByName('ID_FORNECEDOR').AsString then
        begin
          Application.MessageBox('O arquivo selecionado não pertence ao fornecedor!', 'Informação do sistema', MB_OK + MB_ICONINFORMATION);
          Exit;
        end;

        ConteudoArquivo.LoadFromFile(Arquivo);

        SubTotal := 0;
        TotalDesconto := 0;
        TotalGeral := 0;
        //
        CDSCompraCotacaoDetalhe.DisableControls;
        for i := 1 to ConteudoArquivo.Count - 1 do
        begin
          OpcoesArquivo.Clear;
          ExtractStrings([';'],[], PChar(ConteudoArquivo[i]), OpcoesArquivo);

          {
            OpcoesArquivo[0] = Id Produto
            OpcoesArquivo[1] = Nome do Produto
            OpcoesArquivo[2] = Quantidade
            OpcoesArquivo[3] = Valor Unitário
            OpcoesArquivo[4] = Valor Subtotal
            OpcoesArquivo[5] = Taxa Desconto
            OpcoesArquivo[6] = Valor Desconto
            OpcoesArquivo[7] = Valor Total
          }
          CDSCompraCotacaoDetalhe.First;
          while not CDSCompraCotacaoDetalhe.Eof do
          begin
            if CDSCompraCotacaoDetalhe.FieldByName('ID_PRODUTO').AsString = OpcoesArquivo[0] then
            begin
              CDSCompraCotacaoDetalhe.Edit;
              CDSCompraCotacaoDetalhe.FieldByName('VALOR_UNITARIO').AsString := OpcoesArquivo[3];
              CDSCompraCotacaoDetalhe.FieldByName('VALOR_SUBTOTAL').AsString := OpcoesArquivo[4];
              CDSCompraCotacaoDetalhe.FieldByName('TAXA_DESCONTO').AsString := OpcoesArquivo[5];
              CDSCompraCotacaoDetalhe.FieldByName('VALOR_DESCONTO').AsString := OpcoesArquivo[6];
              CDSCompraCotacaoDetalhe.FieldByName('VALOR_TOTAL').AsString := OpcoesArquivo[7];
              CDSCompraCotacaoDetalhe.Post;
              //
              SubTotal := SubTotal + CDSCompraCotacaoDetalhe.FieldByName('VALOR_SUBTOTAL').AsFloat;
              TotalDesconto := TotalDesconto + CDSCompraCotacaoDetalhe.FieldByName('VALOR_DESCONTO').AsFloat;
              TotalGeral := TotalGeral + CDSCompraCotacaoDetalhe.FieldByName('VALOR_TOTAL').AsFloat;
            end;
            CDSCompraCotacaoDetalhe.Next;
          end;

        end;
        CDSCompraCotacaoDetalhe.EnableControls;
        CDSCompraCotacaoDetalhe.First;

        // Atualiza cabeçalho
        CDSCompraFornecedorCotacao.Edit;
        CDSCompraFornecedorCotacao.FieldByName('VALOR_SUBTOTAL').AsFloat := SubTotal;
        CDSCompraFornecedorCotacao.FieldByName('VALOR_DESCONTO').AsFloat := TotalDesconto;
        CDSCompraFornecedorCotacao.FieldByName('TOTAL').AsFloat := TotalGeral;
        CDSCompraFornecedorCotacao.FieldByName('TAXA_DESCONTO').AsFloat := RoundTo(TotalDesconto / TotalGeral, -2) * 100;
        CDSCompraFornecedorCotacao.Post;

      except
        on E: Exception do
          Application.MessageBox(PChar('Ocorreu um erro durante a importação do arquivo. Informe a mensagem ao Administrador do sistema.' + #13 + #13 + E.Message), 'Erro do sistema', MB_OK + MB_ICONERROR);
      end;
    finally
      OpcoesArquivo.Free;
      ConteudoArquivo.Free;
    end;
  end;
end;
{$ENDREGION}

end.

