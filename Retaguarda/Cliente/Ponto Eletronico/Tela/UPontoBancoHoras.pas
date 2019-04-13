{ *******************************************************************************
Title: T2Ti ERP
Description: Janela Consulta do Banco de Horas para o Ponto Eletrônico

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

unit UPontoBancoHoras;

{$MODE Delphi}

interface

uses
  BrookHTTPClient, BrookFCLHTTPClientBroker, BrookHTTPUtils, BrookUtils, FPJson, ZDataset,
  LCLIntf, LCLType, LMessages, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UTelaCadastro, Menus, StdCtrls, ExtCtrls, Buttons, Grids, DBGrids,
  ComCtrls, LabeledCtrls, rxdbgrid, rxtoolbar, DBCtrls, StrUtils,
  Math, Constantes, CheckLst, ActnList, ToolWin, db, BufDataset, Biblioteca,
  ULookup, VO, PontoBancoHorasVO, PontoBancoHorasController;

  type

  { TFPontoBancoHoras }

  TFPontoBancoHoras = class(TFTelaCadastro)
    BevelEdits: TBevel;
    CDSPontoBancoHorasUtilizacao: TBufDataset;
    EditIdColaborador: TLabeledCalcEdit;
    EditColaborador: TLabeledEdit;
    EditDataTrabalho: TLabeledDateEdit;
    EditQuantidade: TLabeledMaskEdit;
    ComboboxSituacao: TLabeledComboBox;
    PageControlItens: TPageControl;
    tsItens: TTabSheet;
    PanelItens: TPanel;
    GridParcelas: TRxDbGrid;
    DSPontoBancoHorasUtilizacao: TDataSource;
    CDSPontoBancoHorasUtilizacaoID: TIntegerField;
    CDSPontoBancoHorasUtilizacaoID_PONTO_BANCO_HORAS: TIntegerField;
    CDSPontoBancoHorasUtilizacaoDATA_UTILIZACAO: TDateField;
    CDSPontoBancoHorasUtilizacaoQUANTIDADE_UTILIZADA: TStringField;
    CDSPontoBancoHorasUtilizacaoOBSERVACAO: TStringField;
    procedure FormCreate(Sender: TObject);
    procedure BotaoConsultarClick(Sender: TObject);
    procedure BotaoSalvarClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure GridParaEdits; override;

  end;

var
  FPontoBancoHoras: TFPontoBancoHoras;

implementation

uses PontoBancoHorasUtilizacaoVO;

{$R *.lfm}

{$REGION 'Infra'}
procedure TFPontoBancoHoras.BotaoConsultarClick(Sender: TObject);
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
    RetornoConsulta := TPontoBancoHorasController.Consulta(Filtro, IntToStr(Pagina));
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

procedure TFPontoBancoHoras.BotaoSalvarClick(Sender: TObject);
begin
  inherited;
  BotaoConsultarClick(Sender);
end;

procedure TFPontoBancoHoras.FormCreate(Sender: TObject);
begin
  ClasseObjetoGridVO := TPontoBancoHorasVO;
  ObjetoController := TPontoBancoHorasController.Create;

  inherited;
  BotaoInserir.Visible := False;
  BotaoAlterar.Visible := False;
  BotaoExcluir.Visible := False;
  BotaoSalvar.Visible := False;
end;
{$ENDREGION}

{$REGION 'Controle de Grid'}
procedure TFPontoBancoHoras.GridParaEdits;
var
  IdCabecalho: String;
begin
  inherited;

  if not CDSGrid.IsEmpty then
  begin
    IdCabecalho := IntToStr(IdRegistroSelecionado);
    ObjetoVO := TPontoBancoHorasController.ConsultaObjeto('ID=' + IdCabecalho);
  end;

  if Assigned(ObjetoVO) then
  begin
    EditIdColaborador.AsInteger := TPontoBancoHorasVO(ObjetoVO).IdColaborador;
    EditColaborador.Text := TPontoBancoHorasVO(ObjetoVO).ColaboradorNome;
    EditDataTrabalho.Date := TPontoBancoHorasVO(ObjetoVO).DataTrabalho;
    EditQuantidade.Text := TPontoBancoHorasVO(ObjetoVO).Quantidade;

    case AnsiIndexStr(TPontoBancoHorasVO(ObjetoVO).Situacao, ['N', 'U', 'P']) of
      0:
        ComboboxSituacao.ItemIndex := 0;
      1:
        ComboboxSituacao.ItemIndex := 1;
      2:
        ComboboxSituacao.ItemIndex := 2;
    end;

    /// EXERCICIO: carregue os detalhes

    // Serializa o objeto para consultar posteriormente se houve alterações
    FormatSettings.DecimalSeparator := '.';
    StringObjetoOld := ObjetoVO.ToJSONString;
    FormatSettings.DecimalSeparator := ',';
  end;
end;
{$ENDREGION}

end.

