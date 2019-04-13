{ *******************************************************************************
Title: T2Ti ERP
Description: Janela de Conciliação Bancária

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

@author Albert Eije
@version 2.0
******************************************************************************* }
unit UFinExtratoContaBanco;

{$MODE Delphi}

interface

uses
  BrookHTTPClient, BrookFCLHTTPClientBroker, BrookHTTPUtils, BrookUtils, FPJson, ZDataset,
  LCLIntf, LCLType, LMessages, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UTelaCadastro, Menus, StdCtrls, ExtCtrls, Buttons, Grids, DBGrids,
  ComCtrls, LabeledCtrls, rxdbgrid, rxtoolbar, DBCtrls, StrUtils,
  Math, Constantes, CheckLst, ActnList, ToolWin, db, BufDataset, Biblioteca,
  ULookup, VO, YMOFXReader, YMOFCReader, ContaCaixaVO,
  ContaCaixaController;

  type

  { TFFinExtratoContaBanco }

  TFFinExtratoContaBanco = class(TFTelaCadastro)
    BevelEdits: TBevel;
    CDSExtratoConta: TBufDataset;
    PanelEditsInterno: TPanel;
    DSExtratoConta: TDataSource;
    EditIdContaCaixa: TLabeledCalcEdit;
    EditContaCaixa: TLabeledEdit;
    PanelGridInterna: TPanel;
    GridPagamentos: TRxDbGrid;
    PanelTotais: TPanel;
    ActionManager1: TActionList;
    ActionImportarArquivo: TAction;
    ActionToolBar1: TToolPanel;
    ActionConciliarCheques: TAction;
    ActionConciliarLancamentos: TAction;
    EditMesAno: TLabeledMaskEdit;
    ActionCarregarExtrato: TAction;
    procedure FormCreate(Sender: TObject);
    procedure CalcularTotais;
    procedure ActionImportarArquivoExecute(Sender: TObject);
    procedure ActionCarregarExtratoExecute(Sender: TObject);
    procedure ActionConciliarChequesExecute(Sender: TObject);
    procedure ActionConciliarLancamentosExecute(Sender: TObject);
    procedure BotaoConsultarClick(Sender: TObject);
    procedure BotaoSalvarClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure GridParaEdits; override;
    procedure LimparCampos; override;

    // Controles CRUD
    function DoEditar: Boolean; override;
    function DoSalvar: Boolean; override;
  end;

var
  FFinExtratoContaBanco: TFFinExtratoContaBanco;
  Creditos, Debitos, Saldo: Extended;

implementation

uses
  UTela, UDataModule, ViewFinChequeNaoCompensadoVO, ViewFinChequeNaoCompensadoController,
  FinExtratoContaBancoVO, FinExtratoContaBancoController, ChequeVO, ChequeController,
  ViewFinChequeEmitidoVO, ViewFinChequeEmitidoController, FinParcelaPagamentoVO,
  FinParcelaRecebimentoVO, FinParcelaPagamentoController, FinParcelaRecebimentoController;

{$R *.lfm}

{$REGION 'Infra'}
procedure TFFinExtratoContaBanco.BotaoConsultarClick(Sender: TObject);
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
    RetornoConsulta := TContaCaixaController.Consulta(Filtro, IntToStr(Pagina));
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

procedure TFFinExtratoContaBanco.BotaoSalvarClick(Sender: TObject);
begin
  inherited;
  BotaoConsultarClick(Sender);
end;

procedure TFFinExtratoContaBanco.FormCreate(Sender: TObject);
begin
  ClasseObjetoGridVO := TContaCaixaVO;
  ObjetoController := TContaCaixaController.Create;

  inherited;
  ConfiguraCDSFromVO(CDSExtratoConta, TFinExtratoContaBancoVO);

  BotaoImprimir.Visible := False;
  BotaoInserir.Visible := False;
  BotaoExcluir.Visible := False;
  BotaoAlterar.Caption := 'Filtrar Conta [F3]';
  BotaoAlterar.Hint := 'Filtrar Conta [F3]';
  BotaoAlterar.Width := 120;

  MenuImprimir.Visible := False;
  MenuInserir.Visible := False;
  MenuExcluir.Visible := False;
  MenuCancelar.Visible := False;
  MenuAlterar.Caption := 'Filtrar Conta [F3]';
end;

procedure TFFinExtratoContaBanco.LimparCampos;
begin
  inherited;
  CDSExtratoConta.Close;
  CDSExtratoConta.Open;
end;
{$ENDREGION}

{$REGION 'Controles CRUD'}
function TFFinExtratoContaBanco.DoEditar: Boolean;
begin
  Result := inherited DoEditar;
  if Result then
  begin
    EditMesAno.SetFocus;
  end;
end;

function TFFinExtratoContaBanco.DoSalvar: Boolean;
var
  ExtratoContaBanco: TFinExtratoContaBancoVO;
  ListaExtrato: TListaFinExtratoContaBancoVO;
begin
  Result := inherited DoSalvar;

  if Result then
  begin
    try
      ListaExtrato := TListaFinExtratoContaBancoVO.Create(True);

      CDSExtratoConta.DisableControls;
      CDSExtratoConta.First;
      while not CDSExtratoConta.Eof do
      begin
        ExtratoContaBanco := TFinExtratoContaBancoVO.Create;

        ExtratoContaBanco.Id := CDSExtratoConta.FieldByName('ID').AsInteger;
        ExtratoContaBanco.IdContaCaixa := EditIdContaCaixa.AsInteger;
        ExtratoContaBanco.MesAno := CDSExtratoConta.FieldByName('MES_ANO').AsString;
        ExtratoContaBanco.Mes := CDSExtratoConta.FieldByName('MES').AsString;
        ExtratoContaBanco.Ano := CDSExtratoConta.FieldByName('ANO').AsString;
        ExtratoContaBanco.DataMovimento := CDSExtratoConta.FieldByName('DATA_MOVIMENTO').AsDateTime;
        ExtratoContaBanco.DataBalancete := CDSExtratoConta.FieldByName('DATA_BALANCETE').AsDateTime;
        ExtratoContaBanco.Historico := CDSExtratoConta.FieldByName('HISTORICO').AsString;
        ExtratoContaBanco.Documento := CDSExtratoConta.FieldByName('DOCUMENTO').AsString;
        ExtratoContaBanco.Valor := CDSExtratoConta.FieldByName('VALOR').AsFloat;
        ExtratoContaBanco.Observacao := CDSExtratoConta.FieldByName('OBSERVACAO').AsString;
        ExtratoContaBanco.Conciliado := CDSExtratoConta.FieldByName('CONCILIADO').AsString;

        ListaExtrato.Add(ExtratoContaBanco);

        CDSExtratoConta.Next;
      end;
      CDSExtratoConta.First;
      CDSExtratoConta.EnableControls;

      ObjetoVO := TContaCaixaVO.Create;
      TContaCaixaVO(ObjetoVO).ListaFinExtratoContaBancoVO := ListaExtrato;

    except
      Result := False;
    end;
  end;

end;
{$ENDREGION}

{$REGION 'Controle de Grid'}
procedure TFFinExtratoContaBanco.GridParaEdits;
var
  IdCabecalho: String;
begin
  inherited;
  EditMesAno.Text := Copy(DateTimeToStr(Date), 4, 7);

  EditIdContaCaixa.AsInteger := CDSGrid.FieldByName('ID').AsInteger;
  EditContaCaixa.Text := CDSGrid.FieldByName('NOME').AsString;
  //
  ActionCarregarExtrato.Execute;
end;
{$ENDREGION}

{$REGION 'Actions'}
procedure TFFinExtratoContaBanco.ActionCarregarExtratoExecute(Sender: TObject);
var
  FiltroLocal: String;
  RetornoConsulta: TZQuery;
  ListaCampos: TStringList;
  I: Integer;
begin
  CDSExtratoConta.Close;
  CDSExtratoConta.Open;

  FiltroLocal := 'ID_CONTA_CAIXA=' + QuotedStr(EditIdContaCaixa.Text) + ' and MES_ANO=' + QuotedStr(EditMesAno.Text);

  ListaCampos  := TStringList.Create;
  RetornoConsulta := TFinExtratoContaBancoController.Consulta(FiltroLocal, '0');
  RetornoConsulta.Active := True;

  RetornoConsulta.GetFieldNames(ListaCampos);

  RetornoConsulta.First;
  while not RetornoConsulta.EOF do begin
    CDSExtratoConta.Append;
    for i := 0 to ListaCampos.Count - 1 do
    begin
      CDSExtratoConta.FieldByName(ListaCampos[i]).Value := RetornoConsulta.FieldByName(ListaCampos[i]).Value;
    end;
    CDSExtratoConta.Post;
    RetornoConsulta.Next;
  end;

  //
  CalcularTotais;
end;

procedure TFFinExtratoContaBanco.ActionImportarArquivoExecute(Sender: TObject);
var
  YMOFXReader1: TYMOFXReader;
  YMOFCReader1: TYMOFCReader;
  i: integer;
  TipoArquivo: String;
begin
  if Application.MessageBox('Deseja importar o arquivo de extrato?', 'Pergunta do Sistema', MB_YesNo + MB_IconQuestion) = IdYes then
  begin
    CDSExtratoConta.Close;
    CDSExtratoConta.Open;

    CDSExtratoConta.DisableControls;

    FDataModule.OpenDialog.Filter := 'OFX|*.ofx|OFC|*.ofc';

    if FDataModule.OpenDialog.Execute then
    begin

      TipoArquivo := ExtractFileExt(FDataModule.OpenDialog.FileName);

      // Verifica se o arquivo e ofx ou ofc
      if TipoArquivo = '.ofx' then
      begin
        // abre o arquivo
        YMOFXReader1 := TYMOFXReader.Create(self);
        YMOFXReader1.OFXFile := FDataModule.OpenDialog.FileName;
        YMOFXReader1.Process;
        // processa a leitura do arquivo
        for i := 0 to YMOFXReader1.Count - 1 do
        begin

          CDSExtratoConta.Append;
          CDSExtratoConta.FieldByName('ID_CONTA_CAIXA').AsInteger := EditIdContaCaixa.AsInteger;
          CDSExtratoConta.FieldByName('MES_ANO').AsString := EditMesAno.Text;
          CDSExtratoConta.FieldByName('MES').AsString := Copy(EditMesAno.Text, 1, 2);
          CDSExtratoConta.FieldByName('ANO').AsString := Copy(EditMesAno.Text, 4, 4);
          CDSExtratoConta.FieldByName('DATA_MOVIMENTO').AsString := DateToStr(YMOFXReader1.Get(i).MovDate);
          CDSExtratoConta.FieldByName('DATA_BALANCETE').AsString := DateToStr(YMOFXReader1.Get(i).MovDate);
          CDSExtratoConta.FieldByName('HISTORICO').AsString := YMOFXReader1.Get(i).Desc;
          CDSExtratoConta.FieldByName('DOCUMENTO').AsString := YMOFXReader1.Get(i).CheckNum;
          CDSExtratoConta.FieldByName('VALOR').AsFloat := YMOFXReader1.Get(i).Value;
          CDSExtratoConta.Post;

          if YMOFXReader1.Get(i).Value > 0 then
            Creditos := Creditos + YMOFXReader1.Get(i).Value
          else
            Debitos := Debitos + YMOFXReader1.Get(i).Value;
        end;
      end
      else if TipoArquivo = '.ofc' then
      begin
        // abre o arquivo
        YMOFCReader1 := TYMOFCReader.Create(self);
        YMOFCReader1.OFCFile := FDataModule.OpenDialog.FileName;
        YMOFCReader1.Process;
        // processa a leitura do arquivo
        for i := 0 to YMOFCReader1.Count - 1 do
        begin

          CDSExtratoConta.Append;
          CDSExtratoConta.FieldByName('ID_CONTA_CAIXA').AsInteger := EditIdContaCaixa.AsInteger;
          CDSExtratoConta.FieldByName('MES_ANO').AsString := EditMesAno.Text;
          CDSExtratoConta.FieldByName('MES').AsString := Copy(EditMesAno.Text, 1, 2);
          CDSExtratoConta.FieldByName('ANO').AsString := Copy(EditMesAno.Text, 4, 4);
          CDSExtratoConta.FieldByName('DATA_MOVIMENTO').AsString := DateToStr(YMOFCReader1.Get(i).MovDate);
          CDSExtratoConta.FieldByName('DATA_BALANCETE').AsString := DateToStr(YMOFCReader1.Get(i).MovDate);
          CDSExtratoConta.FieldByName('HISTORICO').AsString := YMOFCReader1.Get(i).Desc;
          CDSExtratoConta.FieldByName('DOCUMENTO').AsString := YMOFCReader1.Get(i).Document;
          CDSExtratoConta.FieldByName('VALOR').AsFloat := YMOFCReader1.Get(i).Value;
          CDSExtratoConta.Post;
        end;
      end;

    end;
    FDataModule.OpenDialog.Filter := '';

    CDSExtratoConta.First;
    CDSExtratoConta.EnableControls;
    CalcularTotais;
  end;
end;

procedure TFFinExtratoContaBanco.CalcularTotais;
begin
  Creditos := 0;
  Debitos := 0;
  Saldo := 0;
  //
  CDSExtratoConta.DisableControls;
  CDSExtratoConta.First;
  while not CDSExtratoConta.Eof do
  begin
    if CDSExtratoConta.FieldByName('VALOR').AsFloat < 0 then
      Debitos := Debitos + CDSExtratoConta.FieldByName('VALOR').AsFloat
    else
      Creditos := Creditos + CDSExtratoConta.FieldByName('VALOR').AsFloat;
    CDSExtratoConta.Next;
  end;
  CDSExtratoConta.First;
  CDSExtratoConta.EnableControls;

  PanelTotais.Caption := '|      Créditos: ' + FloatToStrF(Creditos, ffCurrency, 15, 2) +
  '      |      Débitos: ' + FloatToStrF(Debitos, ffCurrency, 15, 2) +
  '      |      Saldo: ' + FloatToStrF(Creditos + Debitos, ffCurrency, 15, 2) +
  '      |';
end;

procedure TFFinExtratoContaBanco.ActionConciliarChequesExecute(Sender: TObject);
var
  ChequeVO: TChequeVO;
  ChequeEmitidoVO: TViewFinChequeEmitidoVO;
  FiltroLocal: String;
begin
  CDSExtratoConta.DisableControls;
  CDSExtratoConta.First;
  while not CDSExtratoConta.Eof do
  begin
    if Copy(CDSExtratoConta.FieldByName('HISTORICO').AsString,1,6) = 'Cheque' then
    begin
      FiltroLocal := 'NUMERO_CHEQUE=' + QuotedStr(CDSExtratoConta.FieldByName('DOCUMENTO').AsString) + ' and ' + 'ID_CONTA_CAIXA=' + QuotedStr(EditIdContaCaixa.Text);
      ChequeEmitidoVO := TViewFinChequeEmitidoController.ConsultaObjeto(FiltroLocal);
      if Assigned(ChequeEmitidoVO) then
      begin
        if ChequeEmitidoVO.Valor <> CDSExtratoConta.FieldByName('VALOR').AsFloat*-1 then
        begin
          CDSExtratoConta.Edit;
          CDSExtratoConta.FieldByName('OBSERVACAO').AsString := 'VALOR DO CHEQUE NO EXTRATO DIFERE DO VALOR ARMAZENADO NO BANCO DE DADOS - CHEQUE NAO CONCILIADO';
          CDSExtratoConta.Post;
        end
        else
        begin
          CDSExtratoConta.Edit;
          CDSExtratoConta.FieldByName('CONCILIADO').AsString := 'S';
          CDSExtratoConta.Post;
          //
          ChequeVO := TChequeVO.Create;
          ChequeVO.Id := ChequeEmitidoVO.IdCheque;
          ChequeVO.StatusCheque := 'C';
          ChequeVO.DataStatus := now;

          TFinExtratoContaBancoController.Altera(TFinExtratoContaBancoVO(ObjetoVO));
        end;
      end;
    end;

    CDSExtratoConta.Next;
  end;
  CDSExtratoConta.First;
  CDSExtratoConta.EnableControls;
end;

procedure TFFinExtratoContaBanco.ActionConciliarLancamentosExecute(Sender: TObject);
var
  FinParcelaPagamentoVO: TFinParcelaPagamentoVO;
  FinParcelaRecebimentoVO: TFinParcelaRecebimentoVO;
  FiltroLocal: String;
  ValorFiltro: Extended;
begin
  CDSExtratoConta.DisableControls;
  CDSExtratoConta.First;
  while not CDSExtratoConta.Eof do
  begin
    if Copy(CDSExtratoConta.FieldByName('HISTORICO').AsString,1,6) <> 'Cheque' then
    begin
      if CDSExtratoConta.FieldByName('VALOR').AsFloat < 0 then
      begin
        ValorFiltro := CDSExtratoConta.FieldByName('VALOR').AsFloat * -1;
        FiltroLocal := 'DATA_PAGAMENTO=' + QuotedStr(DataParaTexto(CDSExtratoConta.FieldByName('DATA_MOVIMENTO').AsDateTime)) + ' and ' + 'VALOR_PAGO=' + QuotedStr(FloatToStr(ValorFiltro));
        TFinParcelaPagamentoController.ConsultaObjeto(FiltroLocal);
        if Assigned(FinParcelaPagamentoVO) then
        begin
          CDSExtratoConta.Edit;
          CDSExtratoConta.FieldByName('CONCILIADO').AsString := 'S';
          CDSExtratoConta.Post;
        end;
      end
      else if CDSExtratoConta.FieldByName('VALOR').AsFloat > 0 then
      begin
        FiltroLocal := 'DATA_RECEBIMENTO=' + QuotedStr(DataParaTexto(CDSExtratoConta.FieldByName('DATA_MOVIMENTO').AsDateTime)) + ' and ' + 'VALOR_RECEBIDO=' + QuotedStr(CDSExtratoConta.FieldByName('VALOR').AsString);
        FinParcelaRecebimentoVO := TFinParcelaRecebimentoController.ConsultaObjeto(FiltroLocal);
        if Assigned(FinParcelaRecebimentoVO) then
        begin
          CDSExtratoConta.Edit;
          CDSExtratoConta.FieldByName('CONCILIADO').AsString := 'S';
          CDSExtratoConta.Post;
        end;
      end;
    end;
    CDSExtratoConta.Next;
  end;
  CDSExtratoConta.First;
  CDSExtratoConta.EnableControls;
end;
{$ENDREGION}

end.

