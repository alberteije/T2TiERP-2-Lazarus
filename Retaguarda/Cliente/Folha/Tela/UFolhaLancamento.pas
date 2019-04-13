{ *******************************************************************************
Title: T2Ti ERP
Description: Janela de Lançamentos para a Folha de Pagamento

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
unit UFolhaLancamento;

{$MODE Delphi}

interface

uses
  BrookHTTPClient, BrookFCLHTTPClientBroker, BrookHTTPUtils, BrookUtils, FPJson, ZDataset,
  LCLIntf, LCLType, LMessages, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UTelaCadastro, Menus, StdCtrls, ExtCtrls, Buttons, Grids, DBGrids,
  ComCtrls, LabeledCtrls, rxdbgrid, rxtoolbar, DBCtrls, StrUtils,
  Math, Constantes, CheckLst, ActnList, ToolWin, db, BufDataset, Biblioteca,
  ULookup, VO, FolhaLancamentoCabecalhoVO,
  FolhaLancamentoCabecalhoController, ColaboradorVO, ColaboradorController;

  type

  { TFFolhaLancamento }

  TFFolhaLancamento = class(TFTelaCadastro)
    CDSFolhaLancamentoDetalhe: TBufDataset;
    DSFolhaLancamentoDetalhe: TDataSource;
    PanelMestre: TPanel;
    EditIdColaborador: TLabeledCalcEdit;
    EditColaborador: TLabeledEdit;
    PageControlItens: TPageControl;
    tsItens: TTabSheet;
    PanelItens: TPanel;
    GridDetalhe: TRxDbGrid;
    EditCompetencia: TLabeledMaskEdit;
    ComboBoxTipo: TLabeledComboBox;
    procedure FormCreate(Sender: TObject);
    procedure GridDblClick(Sender: TObject);
    procedure GridDetalheKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure EditIdColaboradorKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);

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
  FFolhaLancamento: TFFolhaLancamento;
  Colaborador: TColaboradorVO;

implementation

uses UDataModule, FolhaLancamentoDetalheVO,
FolhaEventoVO, FolhaEventoController, ViewPessoaColaboradorVO, ViewPessoaColaboradorController;
{$R *.lfm}

{$REGION 'Controles Infra'}
procedure TFFolhaLancamento.BotaoConsultarClick(Sender: TObject);
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
    RetornoConsulta := TFolhaLancamentoCabecalhoController.Consulta(Filtro, IntToStr(Pagina));
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

procedure TFFolhaLancamento.BotaoSalvarClick(Sender: TObject);
begin
  inherited;
  BotaoConsultarClick(Sender);
end;

procedure TFFolhaLancamento.FormCreate(Sender: TObject);
begin
  ClasseObjetoGridVO := TFolhaLancamentoCabecalhoVO;
  ObjetoController := TFolhaLancamentoCabecalhoController.Create;

  inherited;
  BotaoImprimir.Visible := False;
  MenuImprimir.Visible := False;

  {
  OBS: vamos configurar manualmente abaixo para trabalhar com os campos transientes
  Pense numa maneira de fazer isso automaticamente nos métodos ConfiguraCDSFromVO e ConfiguraGridFromVO
  }

  //configura Dataset
  CDSFolhaLancamentoDetalhe.Close;
  CDSFolhaLancamentoDetalhe.FieldDefs.Clear;

  CDSFolhaLancamentoDetalhe.FieldDefs.add('ID', ftInteger);
  CDSFolhaLancamentoDetalhe.FieldDefs.add('ID_FOLHA_EVENTO', ftInteger);
  CDSFolhaLancamentoDetalhe.FieldDefs.add('ID_FOLHA_LANCAMENTO_CABECALHO', ftInteger);
  CDSFolhaLancamentoDetalhe.FieldDefs.add('ORIGEM', ftFloat);
  CDSFolhaLancamentoDetalhe.FieldDefs.add('PROVENTO', ftFloat);
  CDSFolhaLancamentoDetalhe.FieldDefs.add('DESCONTO', ftFloat);
  CDSFolhaLancamentoDetalhe.FieldDefs.add('FOLHA_EVENTO.NOME', ftString, 100);
  CDSFolhaLancamentoDetalhe.CreateDataset;
  CDSFolhaLancamentoDetalhe.Open;
end;

procedure TFFolhaLancamento.LimparCampos;
begin
  inherited;
  CDSFolhaLancamentoDetalhe.Close;
  CDSFolhaLancamentoDetalhe.Open;
end;

procedure TFFolhaLancamento.ConfigurarLayoutTela;
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
function TFFolhaLancamento.DoInserir: Boolean;
begin
  Result := inherited DoInserir;

  ConfigurarLayoutTela;
  if Result then
  begin
    EditIdColaborador.SetFocus;
  end;
end;

function TFFolhaLancamento.DoEditar: Boolean;
begin
  Result := inherited DoEditar;

  ConfigurarLayoutTela;
  if Result then
  begin
    EditIdColaborador.SetFocus;
  end;
end;

function TFFolhaLancamento.DoExcluir: Boolean;
begin
  if inherited DoExcluir then
  begin
    try
      Result := TFolhaLancamentoCabecalhoController.Exclui(IdRegistroSelecionado);
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

function TFFolhaLancamento.DoSalvar: Boolean;
var
  FolhaLancamentoDetalhe: TFolhaLancamentoDetalheVO;
begin
  Result := inherited DoSalvar;

  if Result then
  begin
    try
      if not Assigned(ObjetoVO) then
        ObjetoVO := TFolhaLancamentoCabecalhoVO.Create;

      TFolhaLancamentoCabecalhoVO(ObjetoVO).IdColaborador := EditIdColaborador.AsInteger;
      TFolhaLancamentoCabecalhoVO(ObjetoVO).ColaboradorNome := EditColaborador.Text;
      TFolhaLancamentoCabecalhoVO(ObjetoVO).Competencia := EditCompetencia.Text;
      TFolhaLancamentoCabecalhoVO(ObjetoVO).Tipo := Copy(ComboBoxTipo.Text, 1, 1);

      // Detalhes
      CDSFolhaLancamentoDetalhe.DisableControls;
      CDSFolhaLancamentoDetalhe.First;
      while not CDSFolhaLancamentoDetalhe.Eof do
      begin
          FolhaLancamentoDetalhe := TFolhaLancamentoDetalheVO.Create;
          FolhaLancamentoDetalhe.Id := CDSFolhaLancamentoDetalhe.FieldByName('ID').AsInteger;
          FolhaLancamentoDetalhe.IdFolhaLancamentoCabecalho := TFolhaLancamentoCabecalhoVO(ObjetoVO).Id;
          FolhaLancamentoDetalhe.IdFolhaEvento := CDSFolhaLancamentoDetalhe.FieldByName('ID_FOLHA_EVENTO').AsInteger;
          FolhaLancamentoDetalhe.Origem := CDSFolhaLancamentoDetalhe.FieldByName('ORIGEM').AsFloat;
          FolhaLancamentoDetalhe.Provento := CDSFolhaLancamentoDetalhe.FieldByName('PROVENTO').AsFloat;
          FolhaLancamentoDetalhe.Desconto := CDSFolhaLancamentoDetalhe.FieldByName('DESCONTO').AsFloat;
          TFolhaLancamentoCabecalhoVO(ObjetoVO).ListaFolhaLancamentoDetalheVO.Add(FolhaLancamentoDetalhe);

        CDSFolhaLancamentoDetalhe.Next;
      end;
      CDSFolhaLancamentoDetalhe.EnableControls;


      if StatusTela = stInserindo then
      begin
        TFolhaLancamentoCabecalhoController.Insere(TFolhaLancamentoCabecalhoVO(ObjetoVO));
      end
      else if StatusTela = stEditando then
      begin
        /// EXERCICIO: Verifique se tem como serializar as listas junto com o objeto para realizar a comparação
        //if TFolhaLancamentoCabecalhoVO(ObjetoVO).ToJSONString <> StringObjetoOld then
        //begin
          TFolhaLancamentoCabecalhoController.Altera(TFolhaLancamentoCabecalhoVO(ObjetoVO));
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
procedure TFFolhaLancamento.GridDblClick(Sender: TObject);
begin
  inherited;
  ConfigurarLayoutTela;
end;

procedure TFFolhaLancamento.GridDetalheKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  Evento: TFolhaEventoVO;
begin
  /// EXERCICIO: Utilize a janela FLookup para inserir itens
  if Key = VK_F1 then
  begin
    try
      FLookup.ShowModal;

      Evento := TFolhaEventoController.ConsultaObjeto('ID='+FLookup.IdSelecionado);

      if Assigned(Evento) then
      begin
        CDSFolhaLancamentoDetalhe.Append;

        CDSFolhaLancamentoDetalhe.FieldByName('ID_FOLHA_EVENTO').AsInteger := Evento.Id;//CDSTransiente.FieldByName('ID').AsInteger;
        CDSFolhaLancamentoDetalhe.FieldByName('FOLHA_EVENTO.NOME').AsString := Evento.Nome;//CDSTransiente.FieldByName('NOME').AsString;
        { Campo BASE_CALCULO da tabela FOLHA_EVENTO
          01=Salário contratual: define que a base de cálculo deve ser calculada sobre o valor do salário contratual;
          02=Salário mínimo: define que a base de cálculo deve ser calculada sobre o valor do salário mínimo;
          03=Piso Salarial: define que a base de cálculo deve ser calculada sobre o valor do piso salarial definido no cadastro de sindicatos;
          04=Líquido: define que a base de cálculo deve ser calculada sobre o líquido da folha;
        }
        { Os demais casos devem ser implementados a critério do Participante do T2Ti ERP }
        if Evento.BaseCalculo = '01' then
        begin
          CDSFolhaLancamentoDetalhe.FieldByName('ORIGEM').AsFloat := Colaborador.CargoVO.Salario;
        end;

        // Provento ou Desconto
        if Evento.Tipo = 'P' then
        begin
          CDSFolhaLancamentoDetalhe.FieldByName('PROVENTO').AsFloat := ArredondaTruncaValor('A', CDSFolhaLancamentoDetalhe.FieldByName('ORIGEM').AsFloat * Evento.Taxa / 100, 2);
          CDSFolhaLancamentoDetalhe.FieldByName('DESCONTO').AsFloat := 0;
        end
        else
        begin
          CDSFolhaLancamentoDetalhe.FieldByName('PROVENTO').AsFloat := 0;
          CDSFolhaLancamentoDetalhe.FieldByName('DESCONTO').AsFloat := ArredondaTruncaValor('A', CDSFolhaLancamentoDetalhe.FieldByName('ORIGEM').AsFloat * Evento.Taxa / 100, 2);
        end;
        CDSFolhaLancamentoDetalhe.Post;
      end;

      /// EXERCICIO: Verifique se o cálculo acima está correto. Proceda com as devida correçõe.
      /// EXERCICIO: Implemente o cálculo de forma coletiva
      /// EXERCICIO: Crie Actions para inclusão e exclusão dos detalhes
    finally
    end;
  end;
  If Key = VK_RETURN then
    EditIdColaborador.SetFocus;
end;

procedure TFFolhaLancamento.GridParaEdits;
var
  IdCabecalho: String;
  I: Integer;
  Current: TFolhaLancamentoDetalheVO;
begin
  inherited;

  if not CDSGrid.IsEmpty then
  begin
    IdCabecalho := IntToStr(IdRegistroSelecionado);
    ObjetoVO := TFolhaLancamentoCabecalhoController.ConsultaObjeto('ID=' + IdCabecalho);
  end;

  if Assigned(ObjetoVO) then
  begin
    EditIdColaborador.AsInteger := TFolhaLancamentoCabecalhoVO(ObjetoVO).IdColaborador;
    EditColaborador.Text := TFolhaLancamentoCabecalhoVO(ObjetoVO).ColaboradorNome;
    EditCompetencia.Text := TFolhaLancamentoCabecalhoVO(ObjetoVO).Competencia;
    ComboBoxTipo.ItemIndex := StrToInt(TFolhaLancamentoCabecalhoVO(ObjetoVO).Tipo) - 1;

    Colaborador := TColaboradorController.ConsultaObjeto('ID=' + EditIdColaborador.Text);

    // Detalhes
    for I := 0 to TFolhaLancamentoCabecalhoVO(ObjetoVO).ListaFolhaLancamentoDetalheVO.Count - 1 do
    begin
      Current := TFolhaLancamentoCabecalhoVO(ObjetoVO).ListaFolhaLancamentoDetalheVO[I];
      CDSFolhaLancamentoDetalhe.Append;
      CDSFolhaLancamentoDetalhe.FieldByName('ID').AsInteger := Current.id;
      CDSFolhaLancamentoDetalhe.FieldByName('ID_FOLHA_LANCAMENTO_CABECALHO').AsInteger := Current.IdFolhaLancamentoCabecalho;
      CDSFolhaLancamentoDetalhe.FieldByName('ID_FOLHA_EVENTO').AsInteger := Current.IdFolhaEvento;
      //CDSFolhaLancamentoDetalhe.FieldByName('FOLHA_EVENTONOME.AsString := Current.FolhaEventoVO.Nome;
      CDSFolhaLancamentoDetalhe.FieldByName('ORIGEM').AsFloat := Current.Origem;
      CDSFolhaLancamentoDetalhe.FieldByName('PROVENTO').AsFloat := Current.Provento;
      CDSFolhaLancamentoDetalhe.FieldByName('DESCONTO').AsFloat := Current.Desconto;
      CDSFolhaLancamentoDetalhe.Post;
    end;

    // Serializa o objeto para consultar posteriormente se houve alterações
    FormatSettings.DecimalSeparator := '.';
    StringObjetoOld := ObjetoVO.ToJSONString;
    FormatSettings.DecimalSeparator := ',';
  end;

  ConfigurarLayoutTela;
end;
{$ENDREGION}

{$REGION 'Campos Transientes'}
procedure TFFolhaLancamento.EditIdColaboradorKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  Filtro: String;
  ViewPessoaColaboradorVO :TViewPessoaColaboradorVO ;
begin
  if Key = VK_F1 then
  begin
    if EditIdColaborador.Value <> 0 then
      Filtro := 'ID = ' + EditIdColaborador.Text
    else
      Filtro := 'ID=0';

    try
      EditColaborador.Clear;

        ViewPessoaColaboradorVO := TViewPessoaColaboradorController.ConsultaObjeto(Filtro);
        if Assigned(ViewPessoaColaboradorVO) then
      begin
        EditColaborador.Text := ViewPessoaColaboradorVO.Nome;
        Colaborador := TColaboradorController.ConsultaObjeto('ID=' + EditIdColaborador.Text);
      end
      else
      begin
        Exit;
      end;
    finally
      EditCompetencia.SetFocus;
    end;
  end;
end;
{$ENDREGION}

end.

