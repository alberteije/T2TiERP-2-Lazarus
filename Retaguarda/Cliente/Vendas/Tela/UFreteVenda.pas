{ *******************************************************************************
Title: T2Ti ERP
Description: Janela de Cadastro do Frete da Venda

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
t2ti.com@gmail.com

@author Albert Eije
@version 2.0
******************************************************************************* }
unit UFreteVenda;

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

  TFFreteVenda = class(TFTelaCadastro)
    EditPlaca: TLabeledEdit;
    EditMarcaVolume: TLabeledEdit;
    BevelEdits: TBevel;
    EditUfPlaca: TLabeledEdit;
    EditConhecimento: TLabeledCalcEdit;
    ComboBoxResponsavel: TLabeledComboBox;
    EditSeloFiscal: TLabeledCalcEdit;
    EditQuantidadeVolumes: TLabeledCalcEdit;
    EditEspecieVolume: TLabeledEdit;
    EditPesoBruto: TLabeledCalcEdit;
    EditPesoLiquido: TLabeledCalcEdit;
    EditIdVendaCabecalho: TLabeledCalcEdit;
    EditIdTransportadora: TLabeledCalcEdit;
    EditTransportadora: TLabeledEdit;
    EditVendaCabecalho: TLabeledCalcEdit;
    procedure FormCreate(Sender: TObject);
    procedure EditIdVendaCabecalhoKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure EditIdTransportadoraKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);

    procedure BotaoConsultarClick(Sender: TObject);
    procedure BotaoSalvarClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure GridParaEdits; override;

    // Controles CRUD
    function DoInserir: Boolean; override;
    function DoEditar: Boolean; override;
    function DoExcluir: Boolean; override;
    function DoSalvar: Boolean; override;
  end;

var
  FFreteVenda: TFFreteVenda;

implementation

uses VendaFreteController, VendaFreteVO,
  VendaCabecalhoVO, VendaCabecalhoController, ViewPessoaTransportadoraVO,
  ViewPessoaTransportadoraController;
{$R *.lfm}

{$REGION 'Infra'}
procedure TFFreteVenda.BotaoConsultarClick(Sender: TObject);
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
    RetornoConsulta := TVendaFreteController.Consulta(Filtro, IntToStr(Pagina));
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

procedure TFFreteVenda.BotaoSalvarClick(Sender: TObject);
begin
  inherited;
  BotaoConsultarClick(Sender);
end;

procedure TFFreteVenda.FormCreate(Sender: TObject);
begin
  ClasseObjetoGridVO := TVendaFreteVO;
  ObjetoController := TVendaFreteController.Create;

  inherited;
  BotaoImprimir.Visible := False;
  MenuImprimir.Visible := False;
end;
{$ENDREGION}

{$REGION 'Controles CRUD'}
function TFFreteVenda.DoInserir: Boolean;
begin
  Result := inherited DoInserir;

  if Result then
  begin
    EditIdVendaCabecalho.SetFocus;
  end;
end;

function TFFreteVenda.DoEditar: Boolean;
begin
  Result := inherited DoEditar;

  if Result then
  begin
    EditIdVendaCabecalho.SetFocus;
  end;
end;

function TFFreteVenda.DoExcluir: Boolean;
begin
  if inherited DoExcluir then
  begin
    try
      Result := TVendaFreteController.Exclui(IdRegistroSelecionado);
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

function TFFreteVenda.DoSalvar: Boolean;
begin
  Result := inherited DoSalvar;

  if Result then
  begin
    try
      if not Assigned(ObjetoVO) then
        ObjetoVO := TVendaFreteVO.Create;

      TVendaFreteVO(ObjetoVO).IdVendaCabecalho := EditIdVendaCabecalho.AsInteger;
      TVendaFreteVO(ObjetoVO).IdTransportadora := EditIdTransportadora.AsInteger;
      TVendaFreteVO(ObjetoVO).Conhecimento := EditConhecimento.AsInteger;
      TVendaFreteVO(ObjetoVO).Responsavel := IntToStr(ComboBoxResponsavel.ItemIndex + 1);
      TVendaFreteVO(ObjetoVO).Placa := EditPlaca.Text;
      TVendaFreteVO(ObjetoVO).UfPlaca := EditUfPlaca.Text;
      TVendaFreteVO(ObjetoVO).SeloFiscal := EditSeloFiscal.AsInteger;
      TVendaFreteVO(ObjetoVO).QuantidadeVolume := EditQuantidadeVolumes.Value;
      TVendaFreteVO(ObjetoVO).MarcaVolume := EditMarcaVolume.Text;
      TVendaFreteVO(ObjetoVO).EspecieVolume := EditEspecieVolume.Text;
      TVendaFreteVO(ObjetoVO).PesoBruto := EditPesoBruto.Value;
      TVendaFreteVO(ObjetoVO).PesoLiquido := EditPesoLiquido.Value;

      if StatusTela = stInserindo then
      begin
        TVendaFreteController.Insere(TVendaFreteVO(ObjetoVO));
      end
      else if StatusTela = stEditando then
      begin
        if TVendaFreteVO(ObjetoVO).ToJSONString <> StringObjetoOld then
        begin
          TVendaFreteController.Altera(TVendaFreteVO(ObjetoVO));
        end
        else
          Application.MessageBox('Nenhum dado foi alterado.', 'Mensagem do Sistema', MB_OK + MB_ICONINFORMATION);
      end;
    except
      Result := False;
    end;
  end;
end;
{$ENDREGION}

{$REGION 'Controle de Grid'}
procedure TFFreteVenda.GridParaEdits;
var
  IdCabecalho: String;
begin
  inherited;

  if not CDSGrid.IsEmpty then
  begin
    IdCabecalho := IntToStr(IdRegistroSelecionado);
    ObjetoVO := TVendaFreteController.ConsultaObjeto('ID=' + IdCabecalho);
  end;

  if Assigned(ObjetoVO) then
  begin
    EditIdVendaCabecalho.AsInteger := TVendaFreteVO(ObjetoVO).IdVendaCabecalho;
    EditVendaCabecalho.AsInteger := TVendaFreteVO(ObjetoVO).VendaCabecalhoNumeroFatura;
    EditIdTransportadora.AsInteger := TVendaFreteVO(ObjetoVO).IdTransportadora;
    EditTransportadora.Text := TVendaFreteVO(ObjetoVO).TransportadoraNome;
    EditConhecimento.AsInteger := TVendaFreteVO(ObjetoVO).Conhecimento;
    ComboBoxResponsavel.ItemIndex := StrToInt(TVendaFreteVO(ObjetoVO).Responsavel) + 1;
    EditPlaca.Text := TVendaFreteVO(ObjetoVO).Placa;
    EditUfPlaca.Text := TVendaFreteVO(ObjetoVO).UfPlaca;
    EditSeloFiscal.AsInteger := TVendaFreteVO(ObjetoVO).SeloFiscal;
    EditQuantidadeVolumes.Value := TVendaFreteVO(ObjetoVO).QuantidadeVolume;
    EditMarcaVolume.Text := TVendaFreteVO(ObjetoVO).MarcaVolume;
    EditEspecieVolume.Text := TVendaFreteVO(ObjetoVO).EspecieVolume;
    EditPesoBruto.Value := TVendaFreteVO(ObjetoVO).PesoBruto;
    EditPesoLiquido.Value := TVendaFreteVO(ObjetoVO).PesoLiquido;

    // Serializa o objeto para consultar posteriormente se houve alterações
    FormatSettings.DecimalSeparator := '.';
    StringObjetoOld := ObjetoVO.ToJSONString;
    FormatSettings.DecimalSeparator := ',';
  end;
end;
{$ENDREGION}

{$REGION 'Campos Transientes'}
// Venda
procedure TFFreteVenda.EditIdVendaCabecalhoKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  Filtro: String;
  VendaCabecalhoVO :TVendaCabecalhoVO ;
begin
  if Key = VK_F1 then
  begin
    if EditIdVendaCabecalho.Value <> 0 then
      Filtro := 'ID = ' + EditIdVendaCabecalho.Text
    else
      Filtro := 'ID=0';

    try
      EditVendaCabecalho.Clear;

        VendaCabecalhoVO := TVendaCabecalhoController.ConsultaObjeto(Filtro);
        if Assigned(VendaCabecalhoVO) then
      begin
        EditVendaCabecalho.AsInteger := VendaCabecalhoVO.NumeroFatura;
        // Transportadora
        EditIdTransportadora.AsInteger := VendaCabecalhoVO.IdTransportadora;
        EditTransportadora.Text := VendaCabecalhoVO.TransportadoraNome;
      end
      else
      begin
        Exit;
      end;
    finally
      EditIdTransportadora.SetFocus;
    end;
  end;
end;

// Transportadora
procedure TFFreteVenda.EditIdTransportadoraKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  Filtro: String;
  ViewPessoaTransportadoraVO :TViewPessoaTransportadoraVO ;
begin
  if Key = VK_F1 then
  begin
    if EditIdTransportadora.Value <> 0 then
      Filtro := 'ID = ' + EditIdTransportadora.Text
    else
      Filtro := 'ID=0';

    try
      EditTransportadora.Clear;

        ViewPessoaTransportadoraVO := TViewPessoaTransportadoraController.ConsultaObjeto(Filtro);
        if Assigned(ViewPessoaTransportadoraVO) then
      begin
        EditTransportadora.Text := ViewPessoaTransportadoraVO.Nome;
      end
      else
      begin
        Exit;
      end;
    finally
      EditConhecimento.SetFocus;
    end;
  end;
end;
{$ENDREGION}

end.

