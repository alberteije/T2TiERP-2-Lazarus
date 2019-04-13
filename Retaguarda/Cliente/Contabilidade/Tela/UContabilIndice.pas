{ *******************************************************************************
Title: T2Ti ERP
Description: Janela de Cadastro de Índices para o módulo Contabilidade

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
unit UContabilIndice;

{$MODE Delphi}

interface

uses
  BrookHTTPClient, BrookFCLHTTPClientBroker, BrookHTTPUtils, BrookUtils, FPJson, ZDataset,
  LCLIntf, LCLType, LMessages, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UTelaCadastro, Menus, StdCtrls, ExtCtrls, Buttons, Grids, DBGrids,
  ComCtrls, LabeledCtrls, rxdbgrid, rxtoolbar, DBCtrls, StrUtils,
  Math, Constantes, CheckLst, ActnList, ToolWin, db, BufDataset, Biblioteca,
  ULookup, VO, ContabilIndiceVO,
  ContabilIndiceController;

  type

  { TFContabilIndice }

  TFContabilIndice = class(TFTelaCadastro)
    CDSContabilIndiceValor: TBufDataset;
    DSContabilIndiceValor: TDataSource;
    PanelMestre: TPanel;
    PageControlItens: TPageControl;
    tsItens: TTabSheet;
    PanelItens: TPanel;
    GridDetalhe: TRxDbGrid;
    ComboBoxPeriodicidade: TLabeledComboBox;
    EditMensalMesAno: TLabeledMaskEdit;
    EditDiarioAPartirDe: TLabeledDateEdit;
    EditIdIndiceEconomico: TLabeledCalcEdit;
    EditIndiceEconomico: TLabeledEdit;
    procedure FormCreate(Sender: TObject);
    procedure GridDblClick(Sender: TObject);
    procedure EditIdIndiceEconomicoKeyUp(Sender: TObject; var Key: Word;
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
  FContabilIndice: TFContabilIndice;

implementation

uses  UDataModule, ContabilIndiceValorVO, IndiceEconomicoVO,
IndiceEconomicoController;
{$R *.lfm}

{$REGION 'Controles Infra'}
procedure TFContabilIndice.BotaoConsultarClick(Sender: TObject);
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
    RetornoConsulta := TContabilIndiceController.Consulta(Filtro, IntToStr(Pagina));
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

procedure TFContabilIndice.BotaoSalvarClick(Sender: TObject);
begin
  inherited;
  BotaoConsultarClick(Sender);
end;

procedure TFContabilIndice.FormCreate(Sender: TObject);
begin
  ClasseObjetoGridVO := TContabilIndiceVO;
  ObjetoController := TContabilIndiceController.Create;

  inherited;
  BotaoImprimir.Visible := False;
  MenuImprimir.Visible := False;

  ConfiguraCDSFromVO(CDSContabilIndiceValor, TContabilIndiceValorVO);
  ConfiguraGridFromVO(GridDetalhe, TContabilIndiceValorVO);
end;

procedure TFContabilIndice.LimparCampos;
begin
  inherited;
  CDSContabilIndiceValor.Close;
  CDSContabilIndiceValor.Open;
end;

procedure TFContabilIndice.ConfigurarLayoutTela;
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
function TFContabilIndice.DoInserir: Boolean;
begin
  Result := inherited DoInserir;

  ConfigurarLayoutTela;
  if Result then
  begin
    EditIdIndiceEconomico.SetFocus;
  end;
end;

function TFContabilIndice.DoEditar: Boolean;
begin
  Result := inherited DoEditar;

  ConfigurarLayoutTela;
  if Result then
  begin
    EditIdIndiceEconomico.SetFocus;
  end;
end;

function TFContabilIndice.DoExcluir: Boolean;
begin
  if inherited DoExcluir then
  begin
    try
      Result := TContabilIndiceController.Exclui(IdRegistroSelecionado);
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

function TFContabilIndice.DoSalvar: Boolean;
var
  ContabilIndiceValor: TContabilIndiceValorVO;
begin
  Result := inherited DoSalvar;

  if Result then
  begin
    try
      if not Assigned(ObjetoVO) then
        ObjetoVO := TContabilIndiceVO.Create;

      TContabilIndiceVO(ObjetoVO).IdEmpresa := Sessao.Empresa.Id;
      TContabilIndiceVO(ObjetoVO).IdIndiceEconomico := EditIdIndiceEconomico.AsInteger;
      TContabilIndiceVO(ObjetoVO).Periodicidade := IfThen(ComboBoxPeriodicidade.ItemIndex = 0, 'D', 'M');
      TContabilIndiceVO(ObjetoVO).MensalMesAno := EditMensalMesAno.Text;
      TContabilIndiceVO(ObjetoVO).DiarioAPartirDe := EditDiarioAPartirDe.Date;

      // Valores
      CDSContabilIndiceValor.DisableControls;
      CDSContabilIndiceValor.First;
      while not CDSContabilIndiceValor.Eof do
      begin
        ContabilIndiceValor := TContabilIndiceValorVO.Create;
        ContabilIndiceValor.Id := CDSContabilIndiceValor.FieldByName('ID').AsInteger;
        ContabilIndiceValor.IdContabilIndice := TContabilIndiceVO(ObjetoVO).Id;
        ContabilIndiceValor.DataIndice := CDSContabilIndiceValor.FieldByName('DATA_INDICE').AsDateTime;
        ContabilIndiceValor.Valor := CDSContabilIndiceValor.FieldByName('VALOR').AsFloat;
        TContabilIndiceVO(ObjetoVO).ListaContabilIndiceValorVO.Add(ContabilIndiceValor);
        CDSContabilIndiceValor.Next;
      end;
      CDSContabilIndiceValor.EnableControls;

      if StatusTela = stInserindo then
      begin
        TContabilIndiceController.Insere(TContabilIndiceVO(ObjetoVO));
      end
      else if StatusTela = stEditando then
      begin
        /// EXERCICIO: Verifique se tem como serializar as listas junto com o objeto para realizar a comparação
        //if TContabilIndiceVO(ObjetoVO).ToJSONString <> StringObjetoOld then
        //begin
          TContabilIndiceController.Altera(TContabilIndiceVO(ObjetoVO));
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
procedure TFContabilIndice.GridDblClick(Sender: TObject);
begin
  inherited;
  ConfigurarLayoutTela;
end;

procedure TFContabilIndice.GridParaEdits;
var
  IdCabecalho: String;
  I: Integer;
  Current: TContabilIndiceValorVO;
begin
  inherited;

  if not CDSGrid.IsEmpty then
  begin
    IdCabecalho := IntToStr(IdRegistroSelecionado);
    ObjetoVO := TContabilIndiceController.ConsultaObjeto('ID=' + IdCabecalho);
  end;

  if Assigned(ObjetoVO) then
  begin
    EditIdIndiceEconomico.AsInteger := TContabilIndiceVO(ObjetoVO).IdIndiceEconomico;
    EditIndiceEconomico.Text := TContabilIndiceVO(ObjetoVO).IndiceEconomicoSigla;
    ComboBoxPeriodicidade.ItemIndex := StrToInt(IfThen(TContabilIndiceVO(ObjetoVO).Periodicidade = 'D', '0', '1'));
    EditMensalMesAno.Text := TContabilIndiceVO(ObjetoVO).MensalMesAno;
    EditDiarioAPartirDe.Date := TContabilIndiceVO(ObjetoVO).DiarioAPartirDe;

    // Valores
    for I := 0 to TContabilIndiceVO(ObjetoVO).ListaContabilIndiceValorVO.Count - 1 do
    begin
      Current := TContabilIndiceVO(ObjetoVO).ListaContabilIndiceValorVO[I];

      CDSContabilIndiceValor.Append;
      CDSContabilIndiceValor.FieldByName('ID').AsInteger := Current.id;
      CDSContabilIndiceValor.FieldByName('ID_CONTABIL_INDICE').AsInteger := Current.IdContabilIndice;
      CDSContabilIndiceValor.FieldByName('DATA_INDICE').AsDateTime := Current.DataIndice;
      CDSContabilIndiceValor.FieldByName('VALOR').AsFloat := Current.Valor;
      CDSContabilIndiceValor.Post;
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
procedure TFContabilIndice.EditIdIndiceEconomicoKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  Filtro: String;
  IndiceEconomicoVO :TIndiceEconomicoVO ;
begin
  if Key = VK_F1 then
  begin
    if EditIdIndiceEconomico.Value <> 0 then
      Filtro := 'ID = ' + EditIdIndiceEconomico.Text
    else
      Filtro := 'ID=0';

    try
      EditIdIndiceEconomico.Clear;
      EditIndiceEconomico.Clear;

      IndiceEconomicoVO := TIndiceEconomicoController.ConsultaObjeto(Filtro);
      if Assigned(IndiceEconomicoVO) then
      begin
        EditIndiceEconomico.Text := IndiceEconomicoVO.Sigla;
        ComboBoxPeriodicidade.SetFocus;
      end
      else
      begin
        Exit;
      end;
    finally
    end;
  end;
end;
{$ENDREGION}

end.

