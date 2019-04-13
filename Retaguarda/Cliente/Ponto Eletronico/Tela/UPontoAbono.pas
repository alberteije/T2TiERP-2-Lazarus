{ *******************************************************************************
Title: T2Ti ERP
Description: Janela Cadastro de Abonos para o Ponto Eletrônico

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
unit UPontoAbono;

{$MODE Delphi}

interface

uses
  BrookHTTPClient, BrookFCLHTTPClientBroker, BrookHTTPUtils, BrookUtils, FPJson, ZDataset,
  LCLIntf, LCLType, LMessages, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UTelaCadastro, Menus, StdCtrls, ExtCtrls, Buttons, Grids, DBGrids,
  ComCtrls, LabeledCtrls, rxdbgrid, rxtoolbar, DBCtrls, StrUtils,
  Math, Constantes, CheckLst, ActnList, ToolWin, db, BufDataset, Biblioteca,
  ULookup, VO, PontoAbonoVO,
  PontoAbonoController;

  type

  { TFPontoAbono }

  TFPontoAbono = class(TFTelaCadastro)
    CDSPontoAbonoUtilizacao: TBufDataset;
    DSPontoAbonoUtilizacao: TDataSource;
    PanelMestre: TPanel;
    EditIdColaborador: TLabeledCalcEdit;
    EditColaborador: TLabeledEdit;
    EditInicioUtilizacao: TLabeledDateEdit;
    EditQuantidade: TLabeledCalcEdit;
    EditDataCadastro: TLabeledDateEdit;
    EditUtilizado: TLabeledCalcEdit;
    EditSaldo: TLabeledCalcEdit;
    MemoObservacao: TLabeledMemo;
    PageControlItens: TPageControl;
    tsItens: TTabSheet;
    PanelItens: TPanel;
    GridParcelas: TRxDbGrid;
    procedure FormCreate(Sender: TObject);
    procedure GridDblClick(Sender: TObject);
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
  FPontoAbono: TFPontoAbono;

implementation

uses UDataModule, PontoAbonoUtilizacaoVO,
ViewPessoaColaboradorVO, ViewPessoaColaboradorController;
{$R *.lfm}

{$REGION 'Infra'}
procedure TFPontoAbono.BotaoConsultarClick(Sender: TObject);
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
    RetornoConsulta := TPontoAbonoController.Consulta(Filtro, IntToStr(Pagina));
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

procedure TFPontoAbono.BotaoSalvarClick(Sender: TObject);
begin
  inherited;
  BotaoConsultarClick(Sender);
end;

procedure TFPontoAbono.FormCreate(Sender: TObject);
begin
  ClasseObjetoGridVO := TPontoAbonoVO;
  ObjetoController := TPontoAbonoController.Create;

  inherited;
end;

procedure TFPontoAbono.LimparCampos;
begin
  inherited;
  CDSPontoAbonoUtilizacao.Close;
  CDSPontoAbonoUtilizacao.Open;
end;

procedure TFPontoAbono.ConfigurarLayoutTela;
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
function TFPontoAbono.DoInserir: Boolean;
begin
  Result := inherited DoInserir;

  ConfigurarLayoutTela;
  if Result then
  begin
    EditIdColaborador.SetFocus;
  end;
end;

function TFPontoAbono.DoEditar: Boolean;
begin
  Result := inherited DoEditar;

  ConfigurarLayoutTela;
  if Result then
  begin
    EditIdColaborador.SetFocus;
  end;
end;

function TFPontoAbono.DoExcluir: Boolean;
begin
  if inherited DoExcluir then
  begin
    try
      Result := TPontoAbonoController.Exclui(IdRegistroSelecionado);
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

function TFPontoAbono.DoSalvar: Boolean;
begin
  Result := inherited DoSalvar;

  if Result then
  begin
    try
      if not Assigned(ObjetoVO) then
        ObjetoVO := TPontoAbonoVO.Create;

      TPontoAbonoVO(ObjetoVO).IdColaborador := EditIdColaborador.AsInteger;
      TPontoAbonoVO(ObjetoVO).Quantidade := EditQuantidade.AsInteger;
      TPontoAbonoVO(ObjetoVO).Utilizado := EditUtilizado.AsInteger;
      TPontoAbonoVO(ObjetoVO).Saldo := EditSaldo.AsInteger;
      TPontoAbonoVO(ObjetoVO).DataCadastro := EditDataCadastro.Date;
      TPontoAbonoVO(ObjetoVO).InicioUtilizacao := EditInicioUtilizacao.Date;
      TPontoAbonoVO(ObjetoVO).Observacao := MemoObservacao.Text;

      if StatusTela = stInserindo then
      begin
        TPontoAbonoController.Insere(TPontoAbonoVO(ObjetoVO));
      end
      else if StatusTela = stEditando then
      begin
        /// EXERCICIO: Verifique se tem como serializar as listas junto com o objeto para realizar a comparação
        //if TPontoAbonoVO(ObjetoVO).ToJSONString <> StringObjetoOld then
        //begin
          TPontoAbonoController.Altera(TPontoAbonoVO(ObjetoVO));
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

{$REGION 'Campos Transientes'}
procedure TFPontoAbono.EditIdColaboradorKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
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
      end
      else
      begin
        Exit;
      end;
    finally
      EditQuantidade.SetFocus;
    end;
  end;
end;
{$ENDREGION}

{$REGION 'Controle de Grid'}
procedure TFPontoAbono.GridDblClick(Sender: TObject);
begin
  inherited;
  ConfigurarLayoutTela;
end;

procedure TFPontoAbono.GridParaEdits;
var
  IdCabecalho: String;
begin
  inherited;

  if not CDSGrid.IsEmpty then
  begin
    IdCabecalho := IntToStr(IdRegistroSelecionado);
    ObjetoVO := TPontoAbonoController.ConsultaObjeto('ID=' + IdCabecalho);
  end;

  if Assigned(ObjetoVO) then
  begin
    EditIdColaborador.AsInteger := TPontoAbonoVO(ObjetoVO).IdColaborador;
    EditColaborador.Text := TPontoAbonoVO(ObjetoVO).ColaboradorNome;
    EditQuantidade.AsInteger := TPontoAbonoVO(ObjetoVO).Quantidade;
    EditUtilizado.AsInteger := TPontoAbonoVO(ObjetoVO).Utilizado;
    EditSaldo.AsInteger := TPontoAbonoVO(ObjetoVO).Saldo;
    EditDataCadastro.Date := TPontoAbonoVO(ObjetoVO).DataCadastro;
    EditInicioUtilizacao.Date := TPontoAbonoVO(ObjetoVO).InicioUtilizacao;
    MemoObservacao.Text := TPontoAbonoVO(ObjetoVO).Observacao;

    /// EXERCICIO: Carregue os detalhes

    // Serializa o objeto para consultar posteriormente se houve alterações
    FormatSettings.DecimalSeparator := '.';
    StringObjetoOld := ObjetoVO.ToJSONString;
    FormatSettings.DecimalSeparator := ',';
  end;
  ConfigurarLayoutTela;
end;
{$ENDREGION}

end.

