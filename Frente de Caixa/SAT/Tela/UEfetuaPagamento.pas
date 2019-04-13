{*******************************************************************************
Title: T2TiPDV
Description: Janela para selecionar as formas de pagamento e finalizar a venda

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
           alberteije@gmail.com

@author T2Ti.COM
@version 2.0
*******************************************************************************}

unit UEfetuaPagamento;

{$mode objfpc}{$H+}

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, TypInfo,
  Dialogs, Grids, DBGrids, StdCtrls, Buttons, ExtCtrls, Biblioteca, DB, Tipos,
  BufDataset, memds, Constantes, dateutils,
  ACBrBase, ACBrEnterTab, CurrEdit, Controller, NfeFormaPagamentoVO, UBase;

type

  { TFEfetuaPagamento }

  TFEfetuaPagamento = class(TFBase)
    ACBrEnterTab1: TACBrEnterTab;
    CDSValores: TBufDataset;
    GridValores: TDBGrid;
    Image1: TImage;
    GroupBox1: TGroupBox;
    botaoConfirma: TBitBtn;
    GroupBox2: TGroupBox;
    Image2: TImage;
    labelDescricaoTotalVenda: TLabel;
    labelTotalVenda: TLabel;
    Bevel1: TBevel;
    labelDescricaoDesconto: TLabel;
    Bevel2: TBevel;
    labelDesconto: TLabel;
    labelDescricaoAcrescimo: TLabel;
    Bevel3: TBevel;
    labelAcrescimo: TLabel;
    labelTotalReceber: TLabel;
    Bevel4: TBevel;
    labelDescricaoTotalReceber: TLabel;
    labelTotalRecebido: TLabel;
    Bevel5: TBevel;
    labelDescricaoTotalRecebido: TLabel;
    labelTroco: TLabel;
    Bevel6: TBevel;
    labelDescricaoTroco: TLabel;
    PanelConfirmaValores: TPanel;
    LabelConfirmaValores: TLabel;
    botaoNao: TBitBtn;
    botaoSim: TBitBtn;
    DSValores: TDataSource;
    GroupBox3: TGroupBox;
    ComboTipoPagamento: TComboBox;
    labelDescricaoAindaFalta: TLabel;
    labelAindaFalta: TLabel;
    Bevel7: TBevel;
    Label1: TLabel;
    Label2: TLabel;
    EditValorPago: TCurrencyEdit;
    BotaoCancela: TBitBtn;
    procedure FechamentoRapido;
    procedure TelaPadrao;
    procedure FormActivate(Sender: TObject);
    procedure botaoConfirmaClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure botaoSimClick(Sender: TObject);
    procedure botaoNaoClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure EditValorPagoExit(Sender: TObject);
    procedure VerificaSaldoRestante;
    procedure FinalizaVenda;
    procedure AtualizaLabelsValores;
    procedure CancelaOperacao;
    procedure BotaoCancelaClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure GridValoresKeyDown(Sender: TObject; var Key: Word;  Shift: TShiftState);
    procedure ComboTipoPagamentoExit(Sender: TObject);
    procedure Label1Click(Sender: TObject);
    procedure Label2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FEfetuaPagamento: TFEfetuaPagamento;
  ListaTotalTipoPagamento: TListaNfeFormaPagamentoVO;
  SaldoRestante, TotalVenda, Desconto, Acrescimo, TotalReceber, TotalRecebido, ValorDinheiro, Troco: Extended;
  PodeFechar: Boolean;

implementation

uses UDataModule, UCaixa, UFechaEfetuaPagamento, UParcelamento, NfceTipoPagamentoVO,
     NfeFormaPagamentoController;

{$R *.lfm}

procedure TFEfetuaPagamento.FormActivate(Sender: TObject);
begin
  TotalVenda := 0;
  Desconto := 0;
  Acrescimo := 0;
  TotalReceber := 0;
  TotalRecebido := 0;
  ValorDinheiro := 0;
  Troco := 0;

  Color := StringToColor(Sessao.Configuracao.CorJanelasInternas);

  //preenche valores nas variaveis
  TotalVenda := Sessao.VendaAtual.ValorTotalProdutos;
  Acrescimo := Sessao.VendaAtual.ValorDespesasAcessorias;
  Desconto := Sessao.VendaAtual.ValorDesconto;
  TotalReceber := TruncaValor(TotalVenda + Acrescimo - Desconto, Constantes.TConstantes.DECIMAIS_VALOR);
  SaldoRestante := TotalReceber;

  PodeFechar := True;

  AtualizaLabelsValores;

  if SaldoRestante > 0 then
    EditValorPago.Text := FormatFloat('0.00',SaldoRestante)
  else
    EditValorPago.Text := FormatFloat('0.00',0);

  ComboTipoPagamento.SetFocus;

  //lista que vai acumular os meios de pagamento
  ListaTotalTipoPagamento := TListaNfeFormaPagamentoVO.Create;

  //tela padrão
  TelaPadrao;
end;

procedure TFEfetuaPagamento.AtualizaLabelsValores;
begin
  labelTotalVenda.Caption := FormatFloat('#,###,###,##0.00', TotalVenda);
  labelAcrescimo.Caption := FormatFloat('#,###,###,##0.00', Acrescimo);
  labelDesconto.Caption := FormatFloat('#,###,###,##0.00', Desconto);
  labelTotalReceber.Caption :=  FormatFloat('#,###,###,##0.00', TotalReceber);
  labelTotalRecebido.Caption :=  FormatFloat('#,###,###,##0.00', TotalRecebido);
  if SaldoRestante > 0 then
    labelAindaFalta.Caption :=  FormatFloat('#,###,###,##0.00', SaldoRestante)
  else
    labelAindaFalta.Caption :=  FormatFloat('#,###,###,##0.00', 0);
  labelTroco.Caption :=  FormatFloat('#,###,###,##0.00', Troco);
end;

procedure TFEfetuaPagamento.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  FreeAndNil(ListaTotalTipoPagamento);
  CDSValores.Close;
  CloseAction := caFree;
end;

procedure TFEfetuaPagamento.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if (PodeFechar = True) and (Sessao.StatusCaixa = scAberto) then
  begin
    Application.CreateForm(TFFechaEfetuaPagamento, FFechaEfetuaPagamento);
    FFechaEfetuaPagamento.Left := FEfetuaPagamento.Left + 3;
    FFechaEfetuaPagamento.Top := FEfetuaPagamento.Top + (FEfetuaPagamento.Height - FFechaEfetuaPagamento.Height) + 30;
    FFechaEfetuaPagamento.Width := FEfetuaPagamento.Width;
    FFechaEfetuaPagamento.ShowModal;
  end;
  CanClose := PodeFechar;
end;

procedure TFEfetuaPagamento.TelaPadrao;
var
  i: Integer;
begin
  for i := 0 to Sessao.ListaTipoPagamento.Count - 1 do
    ComboTipoPagamento.Items.Add(TNfceTipoPagamentoVO(Sessao.ListaTipoPagamento.Items[i]).Descricao);
  ComboTipoPagamento.ItemIndex := 0;

  //configura Dataset
  CDSValores.Close;
  CDSValores.FieldDefs.Clear;

  CDSValores.FieldDefs.add('DESCRICAO', ftString, 20);
  CDSValores.FieldDefs.add('VALOR', ftFloat);
  CDSValores.FieldDefs.add('ID', ftInteger);
  CDSValores.FieldDefs.add('INDICE_LISTA', ftInteger);
  CDSValores.CreateDataset;
  CDSValores.Open;

  TFloatField(CDSValores.FieldByName('VALOR')).displayFormat:='#,###,###,##0.00';

  //definimos os cabeçalhos da Grid
  GridValores.Columns[0].Title.Caption := 'Descrição';
  GridValores.Columns[0].Width := 130;
  GridValores.Columns[1].Title.Caption := 'Valor';
  //nao exibe as colunas abaixo
  GridValores.Columns.Items[2].Visible := False;
  GridValores.Columns.Items[3].Visible := False;
end;

procedure TFEfetuaPagamento.FormKeyDown(Sender: TObject; var Key: Word;  Shift: TShiftState);
begin
  if Key = VK_F2 then
  begin
    if CDSValores.RecordCount = 0 then
    begin
      if Application.MessageBox('Confirma valores e encerra venda por fechamento rápido?', 'Finalizar venda', Mb_YesNo + Mb_IconQuestion) = IdYes then
      begin
        FechamentoRapido;
      end;
    end
    else
    begin
      Application.MessageBox('Já existem valores informados. Impossível utilizar Fechamento Rápido.', 'Informação do Sistema', MB_OK + MB_ICONINFORMATION);
      ComboTipoPagamento.SetFocus;
    end;
  end;

  if Key = VK_F12 then
    botaoConfirma.Click;

  if Key = VK_ESCAPE then
    BotaoCancela.Click;

  if Key = VK_F5 then
  begin
    if CDSValores.RecordCount > 0 then
      GridValores.SetFocus
    else
    begin
      Application.MessageBox('Não existem valores informados para serem removidos.', 'Informação do Sistema', MB_OK + MB_ICONINFORMATION);
      ComboTipoPagamento.SetFocus;
    end;
  end;
end;

procedure TFEfetuaPagamento.FechamentoRapido;
begin
  botaoSim.Click;
end;

//controle das teclas digitadas na Grid
procedure TFEfetuaPagamento.GridValoresKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if key = VK_DELETE then
  begin
    if Application.MessageBox('Deseja remover o valor selecionado?', 'Remover ', Mb_YesNo + Mb_IconQuestion) = IdYes then
    begin
      TotalRecebido := TruncaValor(TotalRecebido - CDSValores.FieldByName('VALOR').AsFloat,Constantes.TConstantes.DECIMAIS_VALOR);
      Troco := TruncaValor(TotalRecebido - TotalReceber,Constantes.TConstantes.DECIMAIS_VALOR);
      if Troco < 0 then
        Troco := 0;

      ListaTotalTipoPagamento.Delete(CDSValores.FieldByName('INDICE_LISTA').AsInteger);

      CDSValores.Delete;
      VerificaSaldoRestante;
      if SaldoRestante > 0 then
        EditValorPago.Text := FormatFloat('0.00',SaldoRestante)
      else
        EditValorPago.Text := FormatFloat('0.00',0);
    end;
    ComboTipoPagamento.SetFocus;
  end;
  if Key = VK_RETURN then
    ComboTipoPagamento.SetFocus;
end;

procedure TFEfetuaPagamento.Label1Click(Sender: TObject);
begin
  keybd_event(VK_F2, 0, 0, 0);
end;

procedure TFEfetuaPagamento.Label2Click(Sender: TObject);
begin
  keybd_event(VK_F5, 0, 0, 0);
end;

procedure TFEfetuaPagamento.BotaoCancelaClick(Sender: TObject);
begin
  CancelaOperacao;
end;

procedure TFEfetuaPagamento.botaoConfirmaClick(Sender: TObject);
begin
  VerificaSaldoRestante;

  if SaldoRestante <= 0 then
  begin
    if Application.MessageBox('Deseja finalizar a venda?', 'Finalizar venda', Mb_YesNo + Mb_IconQuestion) = IdYes then
    begin
      FinalizaVenda;
    end;
  end
  else
  begin
    Application.MessageBox('Valores informados não são suficientes para finalizar a venda.', 'Informação do Sistema', MB_OK + MB_ICONINFORMATION);
    ComboTipoPagamento.SetFocus;
  end;
end;

procedure TFEfetuaPagamento.EditValorPagoExit(Sender: TObject);
begin
  if EditValorPago.Value > 0 then
  begin
    VerificaSaldoRestante;
    if SaldoRestante > 0 then
    begin
      PanelConfirmaValores.Visible := True;
      PanelConfirmaValores.BringToFront;
      LabelConfirmaValores.Caption := 'Confirma forma de pagamento e valor?';
      BotaoSim.SetFocus;
    end
    else
      Application.MessageBox('Todos os valores já foram recebidos. Finalize a venda.', 'Informação do Sistema', MB_OK + MB_ICONINFORMATION);
  end
  else
  begin
    Application.MessageBox('Valor não pode ser menor ou igual a zero.', 'Informação do Sistema', MB_OK + MB_ICONINFORMATION);
    EditValorPago.Clear;
    ComboTipoPagamento.SetFocus;
  end;
end;

procedure TFEfetuaPagamento.VerificaSaldoRestante;
var
  RecebidoAteAgora: Extended;
begin
  RecebidoAteAgora := 0;

  CDSValores.DisableControls;
  CDSValores.First;
  while Not CDSValores.Eof do
  begin
    RecebidoAteAgora := TruncaValor(RecebidoAteAgora + CDSValores.FieldByName('VALOR').AsFloat, Constantes.TConstantes.DECIMAIS_VALOR);
    CDSValores.Next;
  end;
  CDSValores.EnableControls;

  SaldoRestante := TruncaValor(TotalReceber - RecebidoAteAgora, Constantes.TConstantes.DECIMAIS_VALOR);

  AtualizaLabelsValores;
end;

procedure TFEfetuaPagamento.botaoNaoClick(Sender: TObject);
begin
  PanelConfirmaValores.Visible := False;
  ComboTipoPagamento.SetFocus;
end;

procedure TFEfetuaPagamento.botaoSimClick(Sender: TObject);
var
  TipoPagamento: TNfceTipoPagamentoVO;
  TotalTipoPagamento: TNfeFormaPagamentoVO;
  ValorInformado: Extended;
begin
  TipoPagamento := TNfceTipoPagamentoVO.Create;
  TipoPagamento.Id := Sessao.ListaTipoPagamento.Items[ComboTipoPagamento.ItemIndex].Id;
  TipoPagamento.Codigo := Sessao.ListaTipoPagamento.Items[ComboTipoPagamento.ItemIndex].Codigo;
  TipoPagamento.Descricao := Sessao.ListaTipoPagamento.Items[ComboTipoPagamento.ItemIndex].Descricao;
  TipoPagamento.PermiteTroco := Sessao.ListaTipoPagamento.Items[ComboTipoPagamento.ItemIndex].PermiteTroco;
  TipoPagamento.GeraParcelas := Sessao.ListaTipoPagamento.Items[ComboTipoPagamento.ItemIndex].GeraParcelas;
  ValorInformado := TruncaValor(EditValorPago.Value, Constantes.TConstantes.DECIMAIS_VALOR);

  TotalTipoPagamento := TNfeFormaPagamentoVO.Create;

  GroupBox3.Enabled := False;

  CDSValores.Append;
  CDSValores.FieldByName('DESCRICAO').AsString := ComboTipoPagamento.Text;
  CDSValores.FieldByName('VALOR').AsFloat := EditValorPago.Value;
  CDSValores.Post;

  TotalRecebido := TruncaValor(TotalRecebido + EditValorPago.Value, Constantes.TConstantes.DECIMAIS_VALOR);
  Troco := TruncaValor(TotalRecebido - TotalReceber, Constantes.TConstantes.DECIMAIS_VALOR);
  if Troco < 0 then
    Troco := 0;

  VerificaSaldoRestante;

  TotalTipoPagamento.IdNfeCabecalho := Sessao.VendaAtual.Id;
  TotalTipoPagamento.IdNfceTipoPagamento := TipoPagamento.Id;
  TotalTipoPagamento.Valor := TruncaValor(EditValorPago.Value, Constantes.TConstantes.DECIMAIS_VALOR);
  TotalTipoPagamento.Forma := TipoPagamento.Codigo;
  TotalTipoPagamento.Estorno := 'N';
  TotalTipoPagamento.NfceTipoPagamentoVO := TipoPagamento;

  if TipoPagamento.GeraParcelas = 'N' then
    Sessao.VendaAtual.IndicadorFormaPagamento := 0  //a vista
  else
    Sessao.VendaAtual.IndicadorFormaPagamento := 1; //a prazo

  ListaTotalTipoPagamento.Add(TotalTipoPagamento);

  // guarda o índice da lista
  CDSValores.Edit;
  CDSValores.FieldByName('INDICE_LISTA').AsInteger := ListaTotalTipoPagamento.Count - 1;
  CDSValores.Post;

  PanelConfirmaValores.Visible := False;
  PanelConfirmaValores.SendToBack;
  if SaldoRestante > 0 then
    EditValorPago.Text := FormatFloat('0.00', SaldoRestante)
  else
    EditValorPago.Text := FormatFloat('0.00', 0);

  GroupBox3.Enabled := True;
  ComboTipoPagamento.SetFocus;

  VerificaSaldoRestante;
  if SaldoRestante <= 0 then
    FinalizaVenda;
end;

procedure TFEfetuaPagamento.FinalizaVenda;
begin
  // grava os pagamentos no banco de dados
  TNfeFormaPagamentoController.InsereLista(ListaTotalTipoPagamento);

  // conclui o encerramento da venda - grava dados de cabecalho no banco
  Sessao.VendaAtual.ValorTotal := TotalReceber;
  Sessao.VendaAtual.Troco := Troco;

  Sessao.StatusCaixa := scAberto;
  FCaixa.ConcluiEncerramentoVenda;

  PodeFechar := True;
  Close;
end;

procedure TFEfetuaPagamento.CancelaOperacao;
begin
  Close;
end;

procedure TFEfetuaPagamento.ComboTipoPagamentoExit(Sender: TObject);
var
  TipoPagamento: TNfceTipoPagamentoVO;
begin
  TipoPagamento := TNfceTipoPagamentoVO(Sessao.ListaTipoPagamento.Items[ComboTipoPagamento.ItemIndex]);

  if Assigned(TipoPagamento) then
  begin
    if TipoPagamento.GeraParcelas = 'S' then
    begin
      VerificaSaldoRestante;
      if SaldoRestante > 0 then
      begin
        try
          Application.CreateForm(TFParcelamento, FParcelamento);
          FParcelamento.editNome.Text := Sessao.VendaAtual.NfeDestinatarioVO.Nome;
          FParcelamento.editCPF.Text := Sessao.VendaAtual.NfeDestinatarioVO.CpfCnpj;
          FParcelamento.editValorVenda.Text := labelTotalVenda.Caption;
          FParcelamento.editValorRecebido.Text := labelTotalRecebido.Caption;
          FParcelamento.editValorParcelar.Value := SaldoRestante;
          FParcelamento.editVencimento.Date := Date() + 30;

          if Sessao.VendaAtual.ValorDesconto > 0 then
          begin
            FParcelamento.lblDesconto.Caption := 'Desconto';
            FParcelamento.editDesconto.Value := Sessao.VendaAtual.ValorDesconto;
          end;

          if Sessao.VendaAtual.ValorDespesasAcessorias > 0 then
          begin
            FParcelamento.lblDesconto.Caption := 'Acréscimo';
            FParcelamento.editDesconto.Value := Sessao.VendaAtual.ValorDespesasAcessorias;
          end;

          if (FParcelamento.ShowModal = MROK) then
          begin
            // Depois de chamar a tela de parcelamento, se tudo deu certo finaliza a Venda.
            EditValorPago.Value := SaldoRestante;
            botaoSimClick(Self);
          end
          else
            ComboTipoPagamento.SetFocus;

        finally
          FreeAndNil(FParcelamento);
        end;
      end;
    end;
  end;
end;


end.
