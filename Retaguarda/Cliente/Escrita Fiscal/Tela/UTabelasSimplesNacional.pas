{ *******************************************************************************
Title: T2Ti ERP
Description: Janela de Cadastro das Tabelas do Simples Nacional

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
unit UTabelasSimplesNacional;

{$MODE Delphi}

interface

uses
  BrookHTTPClient, BrookFCLHTTPClientBroker, BrookHTTPUtils, BrookUtils, FPJson, ZDataset,
  LCLIntf, LCLType, LMessages, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UTelaCadastro, Menus, StdCtrls, ExtCtrls, Buttons, Grids, DBGrids,
  ComCtrls, LabeledCtrls, rxdbgrid, rxtoolbar, DBCtrls, StrUtils,
  Math, Constantes, CheckLst, ActnList, ToolWin, db, BufDataset, Biblioteca,
  ULookup, VO, SimplesNacionalCabecalhoVO,
  SimplesNacionalCabecalhoController;

  type

  { TFTabelasSimplesNacional }

  TFTabelasSimplesNacional = class(TFTelaCadastro)
    CDSTabelasSimplesNacionalDetalhe: TBufDataset;
    DSTabelasSimplesNacionalDetalhe: TDataSource;
    PanelMestre: TPanel;
    PageControlItens: TPageControl;
    tsItens: TTabSheet;
    PanelItens: TPanel;
    GridDetalhe: TRxDbGrid;
    ComboBoxAnexo: TLabeledComboBox;
    EditVigenciaInicial: TLabeledDateEdit;
    EditVigenciaFinal: TLabeledDateEdit;
    ComboboxTabela: TLabeledComboBox;
    CDSTabelasSimplesNacionalDetalheID: TIntegerField;
    CDSTabelasSimplesNacionalDetalheID_SIMPLES_NACIONAL_CABECALHO: TIntegerField;
    CDSTabelasSimplesNacionalDetalheFAIXA: TIntegerField;
    CDSTabelasSimplesNacionalDetalheVALOR_INICIAL: TFMTBCDField;
    CDSTabelasSimplesNacionalDetalheVALOR_FINAL: TFMTBCDField;
    CDSTabelasSimplesNacionalDetalheALIQUOTA: TFMTBCDField;
    CDSTabelasSimplesNacionalDetalheIRPJ: TFMTBCDField;
    CDSTabelasSimplesNacionalDetalheCSLL: TFMTBCDField;
    CDSTabelasSimplesNacionalDetalheCOFINS: TFMTBCDField;
    CDSTabelasSimplesNacionalDetalhePIS_PASEP: TFMTBCDField;
    CDSTabelasSimplesNacionalDetalheCPP: TFMTBCDField;
    CDSTabelasSimplesNacionalDetalheICMS: TFMTBCDField;
    CDSTabelasSimplesNacionalDetalheIPI: TFMTBCDField;
    CDSTabelasSimplesNacionalDetalheISS: TFMTBCDField;
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
  FTabelasSimplesNacional: TFTabelasSimplesNacional;

implementation

uses UDataModule, SimplesNacionalDetalheVO;
{$R *.lfm}

{$REGION 'Controles Infra'}
procedure TFTabelasSimplesNacional.BotaoConsultarClick(Sender: TObject);
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
    RetornoConsulta := TSimplesNacionalCabecalhoController.Consulta(Filtro, IntToStr(Pagina));
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

procedure TFTabelasSimplesNacional.BotaoSalvarClick(Sender: TObject);
begin
  inherited;
  BotaoConsultarClick(Sender);
end;

procedure TFTabelasSimplesNacional.FormCreate(Sender: TObject);
begin
  ClasseObjetoGridVO := TSimplesNacionalCabecalhoVO;
  ObjetoController := TSimplesNacionalCabecalhoController.Create;

  inherited;
  BotaoImprimir.Visible := False;

  ConfiguraCDSFromVO(CDSTabelasSimplesNacionalDetalhe, TSimplesNacionalDetalheVO);
  ConfiguraGridFromVO(GridDetalhe, TSimplesNacionalDetalheVO);
end;

procedure TFTabelasSimplesNacional.LimparCampos;
begin
  inherited;
  CDSTabelasSimplesNacionalDetalhe.Close;
  CDSTabelasSimplesNacionalDetalhe.Open;
end;

procedure TFTabelasSimplesNacional.ConfigurarLayoutTela;
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
function TFTabelasSimplesNacional.DoInserir: Boolean;
begin
  Result := inherited DoInserir;

  ConfigurarLayoutTela;
  if Result then
  begin
    EditVigenciaInicial.SetFocus;
  end;
end;

function TFTabelasSimplesNacional.DoEditar: Boolean;
begin
  Result := inherited DoEditar;

  ConfigurarLayoutTela;
  if Result then
  begin
    EditVigenciaFinal.SetFocus;
  end;
end;

function TFTabelasSimplesNacional.DoExcluir: Boolean;
begin
  if inherited DoExcluir then
  begin
    try
      Result := TSimplesNacionalCabecalhoController.Exclui(IdRegistroSelecionado);
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

function TFTabelasSimplesNacional.DoSalvar: Boolean;
var
  TabelasSimplesNacionalDetalhe: TSimplesNacionalDetalheVO;
begin
  Result := inherited DoSalvar;

  if Result then
  begin
    try
      if not Assigned(ObjetoVO) then
        ObjetoVO := TSimplesNacionalCabecalhoVO.Create;

      TSimplesNacionalCabecalhoVO(ObjetoVO).VigenciaInicial := EditVigenciaInicial.Date;
      TSimplesNacionalCabecalhoVO(ObjetoVO).VigenciaFinal := EditVigenciaFinal.Date;
      TSimplesNacionalCabecalhoVO(ObjetoVO).Anexo := ComboBoxAnexo.Text;
      TSimplesNacionalCabecalhoVO(ObjetoVO).Tabela := ComboboxTabela.Text;

      // Detalhes
      CDSTabelasSimplesNacionalDetalhe.DisableControls;
      CDSTabelasSimplesNacionalDetalhe.First;
      while not CDSTabelasSimplesNacionalDetalhe.Eof do
      begin
        TabelasSimplesNacionalDetalhe := TSimplesNacionalDetalheVO.Create;
        TabelasSimplesNacionalDetalhe.Id := CDSTabelasSimplesNacionalDetalhe.FieldByName('ID').AsInteger;
        TabelasSimplesNacionalDetalhe.IdSimplesNacionalCabecalho := TSimplesNacionalCabecalhoVO(ObjetoVO).Id;
        TabelasSimplesNacionalDetalhe.Faixa := CDSTabelasSimplesNacionalDetalhe.FieldByName('FAIXA').AsInteger;
        TabelasSimplesNacionalDetalhe.ValorInicial := CDSTabelasSimplesNacionalDetalhe.FieldByName('VALOR_INICIAL').AsFloat;
        TabelasSimplesNacionalDetalhe.ValorFinal := CDSTabelasSimplesNacionalDetalhe.FieldByName('VALOR_FINAL').AsFloat;
        TabelasSimplesNacionalDetalhe.Aliquota := CDSTabelasSimplesNacionalDetalhe.FieldByName('ALIQUOTA').AsFloat;
        TabelasSimplesNacionalDetalhe.Irpj := CDSTabelasSimplesNacionalDetalhe.FieldByName('IRPJ').AsFloat;
        TabelasSimplesNacionalDetalhe.Csll := CDSTabelasSimplesNacionalDetalhe.FieldByName('CSLL').AsFloat;
        TabelasSimplesNacionalDetalhe.Cofins := CDSTabelasSimplesNacionalDetalhe.FieldByName('COFINS').AsFloat;
        TabelasSimplesNacionalDetalhe.PisPasep := CDSTabelasSimplesNacionalDetalhe.FieldByName('PIS_PASEP').AsFloat;
        TabelasSimplesNacionalDetalhe.Cpp := CDSTabelasSimplesNacionalDetalhe.FieldByName('CPP').AsFloat;
        TabelasSimplesNacionalDetalhe.Icms := CDSTabelasSimplesNacionalDetalhe.FieldByName('ICMS').AsFloat;
        TabelasSimplesNacionalDetalhe.Ipi := CDSTabelasSimplesNacionalDetalhe.FieldByName('IPI').AsFloat;
        TabelasSimplesNacionalDetalhe.Iss := CDSTabelasSimplesNacionalDetalhe.FieldByName('ISS').AsFloat;

        TSimplesNacionalCabecalhoVO(ObjetoVO).ListaSimplesNacionalDetalheVO.Add(TabelasSimplesNacionalDetalhe);

        CDSTabelasSimplesNacionalDetalhe.Next;
      end;
      CDSTabelasSimplesNacionalDetalhe.EnableControls;

      if StatusTela = stInserindo then
      begin
        TSimplesNacionalCabecalhoController.Insere(TSimplesNacionalCabecalhoVO(ObjetoVO));
      end
      else if StatusTela = stEditando then
      begin
        /// EXERCICIO: Verifique se tem como serializar as listas junto com o objeto para realizar a comparação
        //if TSimplesNacionalCabecalhoVO(ObjetoVO).ToJSONString <> StringObjetoOld then
        //begin
          TSimplesNacionalCabecalhoController.Altera(TSimplesNacionalCabecalhoVO(ObjetoVO));
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
procedure TFTabelasSimplesNacional.GridDblClick(Sender: TObject);
begin
  inherited;
  ConfigurarLayoutTela;
end;

procedure TFTabelasSimplesNacional.GridParaEdits;
var
  IdCabecalho: String;
  Current: TSimplesNacionalDetalheVO;
  i: integer;
begin
  inherited;

  if not CDSGrid.IsEmpty then
  begin
    IdCabecalho := IntToStr(IdRegistroSelecionado);
    ObjetoVO := TSimplesNacionalCabecalhoController.ConsultaObjeto('ID=' + IdCabecalho);
  end;

  if Assigned(ObjetoVO) then
  begin
    EditVigenciaInicial.Date := TSimplesNacionalCabecalhoVO(ObjetoVO).VigenciaInicial;
    EditVigenciaFinal.Date := TSimplesNacionalCabecalhoVO(ObjetoVO).VigenciaFinal;
    ComboBoxAnexo.Text := TSimplesNacionalCabecalhoVO(ObjetoVO).Anexo;
    ComboboxTabela.Text := TSimplesNacionalCabecalhoVO(ObjetoVO).Tabela;

    // Detalhes
    for i := 0 to TSimplesNacionalCabecalhoVO(ObjetoVO).ListaSimplesNacionalDetalheVO.Count - 1 do
    begin
      Current := TSimplesNacionalCabecalhoVO(ObjetoVO).ListaSimplesNacionalDetalheVO[i];

      CDSTabelasSimplesNacionalDetalhe.Append;
      CDSTabelasSimplesNacionalDetalhe.FieldByName('ID').AsInteger := Current.Id;
      CDSTabelasSimplesNacionalDetalhe.FieldByName('ID_SIMPLES_NACIONAL_CABECALHO').AsInteger := Current.IdSimplesNacionalCabecalho;
      CDSTabelasSimplesNacionalDetalhe.FieldByName('FAIXA').AsInteger := Current.Faixa;
      CDSTabelasSimplesNacionalDetalhe.FieldByName('VALOR_INICIAL').AsFloat := Current.ValorInicial;
      CDSTabelasSimplesNacionalDetalhe.FieldByName('VALOR_FINAL').AsFloat := Current.ValorFinal;
      CDSTabelasSimplesNacionalDetalhe.FieldByName('ALIQUOTA').AsFloat := Current.Aliquota;
      CDSTabelasSimplesNacionalDetalhe.FieldByName('IRPJ').AsFloat := Current.Irpj;
      CDSTabelasSimplesNacionalDetalhe.FieldByName('CSLL').AsFloat := Current.Csll;
      CDSTabelasSimplesNacionalDetalhe.FieldByName('COFINS').AsFloat := Current.Cofins;
      CDSTabelasSimplesNacionalDetalhe.FieldByName('PIS_PASEP').AsFloat := Current.PisPasep;
      CDSTabelasSimplesNacionalDetalhe.FieldByName('CPP').AsFloat := Current.Cpp;
      CDSTabelasSimplesNacionalDetalhe.FieldByName('ICMS').AsFloat := Current.Icms;
      CDSTabelasSimplesNacionalDetalhe.FieldByName('IPI').AsFloat := Current.Ipi;
      CDSTabelasSimplesNacionalDetalhe.FieldByName('ISS').AsFloat := Current.Iss;
      CDSTabelasSimplesNacionalDetalhe.Post;
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

