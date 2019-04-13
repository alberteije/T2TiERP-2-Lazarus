{ *******************************************************************************
Title: T2Ti ERP
Description: Janela Cadastro de Relógios para o Ponto Eletrônico

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
unit UPontoRelogio;

{$MODE Delphi}

interface

uses
  BrookHTTPClient, BrookFCLHTTPClientBroker, BrookHTTPUtils, BrookUtils, FPJson, ZDataset,
  LCLIntf, LCLType, LMessages, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UTelaCadastro, Menus, StdCtrls, ExtCtrls, Buttons, Grids, DBGrids,
  ComCtrls, LabeledCtrls, rxdbgrid, rxtoolbar, DBCtrls, StrUtils,
  Math, Constantes, CheckLst, ActnList, ToolWin, db, BufDataset, Biblioteca,
  ULookup, VO, PontoRelogioVO,
  PontoRelogioController;

  type

  TFPontoRelogio = class(TFTelaCadastro)
    BevelEdits: TBevel;
    EditLocalizacao: TLabeledEdit;
    ComboboxUtilizacao: TLabeledComboBox;
    EditMarca: TLabeledEdit;
    EditNumeroSerie: TLabeledEdit;
    EditFabricante: TLabeledEdit;
    procedure FormCreate(Sender: TObject);
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
  FPontoRelogio: TFPontoRelogio;

implementation

{$R *.lfm}

{$REGION 'Infra'}
procedure TFPontoRelogio.BotaoConsultarClick(Sender: TObject);
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
    RetornoConsulta := TPontoRelogioController.Consulta(Filtro, IntToStr(Pagina));
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

procedure TFPontoRelogio.BotaoSalvarClick(Sender: TObject);
begin
  inherited;
  BotaoConsultarClick(Sender);
end;

procedure TFPontoRelogio.FormCreate(Sender: TObject);
begin
  ClasseObjetoGridVO := TPontoRelogioVO;
  ObjetoController := TPontoRelogioController.Create;

  inherited;
end;
{$ENDREGION}

{$REGION 'Controles CRUD'}
function TFPontoRelogio.DoInserir: Boolean;
begin
  Result := inherited DoInserir;

  if Result then
  begin
    EditLocalizacao.SetFocus;
  end;
end;

function TFPontoRelogio.DoEditar: Boolean;
begin
  Result := inherited DoEditar;

  if Result then
  begin
    EditLocalizacao.SetFocus;
  end;
end;

function TFPontoRelogio.DoExcluir: Boolean;
begin
  if inherited DoExcluir then
  begin
    try
      Result := TPontoRelogioController.Exclui(IdRegistroSelecionado);
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

function TFPontoRelogio.DoSalvar: Boolean;
begin
  Result := inherited DoSalvar;

  if Result then
  begin
    try
      if not Assigned(ObjetoVO) then
        ObjetoVO := TPontoRelogioVO.Create;

      TPontoRelogioVO(ObjetoVO).IdEmpresa := Sessao.Empresa.Id;
      TPontoRelogioVO(ObjetoVO).Localizacao := EditLocalizacao.Text;
      TPontoRelogioVO(ObjetoVO).Marca := EditMarca.Text;
      TPontoRelogioVO(ObjetoVO).NumeroSerie := EditNumeroSerie.Text;
      TPontoRelogioVO(ObjetoVO).Fabricante := EditFabricante.Text;
      TPontoRelogioVO(ObjetoVO).Utilizacao := Copy(ComboboxUtilizacao.Text, 1, 1);

      if StatusTela = stInserindo then
      begin
        TPontoRelogioController.Insere(TPontoRelogioVO(ObjetoVO));
      end
      else if StatusTela = stEditando then
      begin
        if TPontoRelogioVO(ObjetoVO).ToJSONString <> StringObjetoOld then
        begin
          TPontoRelogioController.Altera(TPontoRelogioVO(ObjetoVO));
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
procedure TFPontoRelogio.GridParaEdits;
var
  IdCabecalho: String;
begin
  inherited;

  if not CDSGrid.IsEmpty then
  begin
    IdCabecalho := IntToStr(IdRegistroSelecionado);
    ObjetoVO := TPontoRelogioController.ConsultaObjeto('ID=' + IdCabecalho);
  end;

  if Assigned(ObjetoVO) then
  begin
    EditLocalizacao.Text := TPontoRelogioVO(ObjetoVO).Localizacao;
    EditMarca.Text := TPontoRelogioVO(ObjetoVO).Marca;
    EditNumeroSerie.Text := TPontoRelogioVO(ObjetoVO).NumeroSerie;
    EditFabricante.Text := TPontoRelogioVO(ObjetoVO).Fabricante;

    case AnsiIndexStr(TPontoRelogioVO(ObjetoVO).Utilizacao, ['P', 'R', 'C']) of
      0:
        ComboboxUtilizacao.ItemIndex := 0;
      1:
        ComboboxUtilizacao.ItemIndex := 1;
      2:
        ComboboxUtilizacao.ItemIndex := 2;
    end;

    // Serializa o objeto para consultar posteriormente se houve alterações
    FormatSettings.DecimalSeparator := '.';
    StringObjetoOld := ObjetoVO.ToJSONString;
    FormatSettings.DecimalSeparator := ',';
  end;
end;
{$ENDREGION}

end.

