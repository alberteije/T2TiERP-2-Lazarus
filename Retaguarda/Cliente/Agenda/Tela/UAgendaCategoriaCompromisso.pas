{*******************************************************************************
Title: T2Ti ERP
Description: Janela Cadastro de Categorias de Compromisso

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

t2ti.com@gmail.com
@author Albert Eije (T2Ti.COM)
@version 2.0
*******************************************************************************}
unit UAgendaCategoriaCompromisso;

{$MODE Delphi}

interface

uses
  BrookHTTPClient, BrookFCLHTTPClientBroker, BrookHTTPUtils, BrookUtils, FPJson, ZDataset,
  LCLIntf, LCLType, LMessages, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UTelaCadastro, Menus, StdCtrls, ExtCtrls, Buttons, Grids, DBGrids,
  ComCtrls, LabeledCtrls, rxdbgrid, rxtoolbar, DBCtrls, StrUtils,
  Math, Constantes, CheckLst, ActnList, ToolWin, db, BufDataset, Biblioteca,
  ULookup, VO;
{
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UTelaCadastro, DB, DBClient, Menus, StdCtrls, ExtCtrls, Buttons, Grids,
  DBGrids, JvExDBGrids, JvDBGrid, JvDBUltimGrid, ComCtrls, AgendaCategoriaCompromissoVO,
  AgendaCategoriaCompromissoController, Tipos, Atributos, Constantes, LabeledCtrls,
  Controller;

}type

  { TFAgendaCategoriaCompromisso }

  TFAgendaCategoriaCompromisso = class(TFTelaCadastro)
    BevelEdits: TBevel;
    BotaoConsultar: TSpeedButton;
    BotaoExportar: TSpeedButton;
    BotaoFiltrar: TSpeedButton;
    BotaoImprimir: TSpeedButton;
    BotaoSair: TSpeedButton;
    BotaoSeparador1: TSpeedButton;
    EditCriterioRapido: TLabeledMaskEdit;
    EditDescricao: TLabeledEdit;
    EditCor: TLabeledEdit;
    Grid: TRxDbGrid;
    PageControl: TPageControl;
    PaginaEdits: TTabSheet;
    PaginaGrid: TTabSheet;
    PanelEdits: TPanel;
    PanelFiltroRapido: TPanel;
    PanelGrid: TPanel;
    PanelToolBar: TPanel;
    procedure FormCreate(Sender: TObject);
    procedure BotaoConsultarClick(Sender: TObject);
    procedure BotaoSalvarClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure GridParaEdits; override;

    //Controles CRUD
    function DoInserir: Boolean; override;
    function DoEditar: Boolean; override;
    function DoExcluir: Boolean; override;
    function DoSalvar: Boolean; override;
  end;

var
  FAgendaCategoriaCompromisso: TFAgendaCategoriaCompromisso;

implementation

{$R *.lfm}

{$REGION 'Infra'}
procedure TFAgendaCategoriaCompromisso.BotaoConsultarClick(Sender: TObject);
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
    RetornoConsulta := TAgendaCategoriaCompromissoController.Consulta(Filtro, IntToStr(Pagina));
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

procedure TFAgendaCategoriaCompromisso.BotaoSalvarClick(Sender: TObject);
begin
  inherited;
  BotaoConsultarClick(Sender);
end;

procedure TFAgendaCategoriaCompromisso.FormCreate(Sender: TObject);
begin
  ClasseObjetoGridVO := TAgendaCategoriaCompromissoVO;
  ObjetoController := TAgendaCategoriaCompromissoController.Create;

  inherited;
end;
{$ENDREGION}

{$REGION 'Controles CRUD'}
function TFAgendaCategoriaCompromisso.DoInserir: Boolean;
begin
  Result := inherited DoInserir;

  if Result then
  begin
    EditCor.SetFocus;
  end;
end;

function TFAgendaCategoriaCompromisso.DoEditar: Boolean;
begin
  Result := inherited DoEditar;

  if Result then
  begin
    EditCor.SetFocus;
  end;
end;

function TFAgendaCategoriaCompromisso.DoExcluir: Boolean;
begin
  if inherited DoExcluir then
  begin
    try
      Result := TAgendaCategoriaCompromissoController.Exclui(IdRegistroSelecionado);
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

function TFAgendaCategoriaCompromisso.DoSalvar: Boolean;
begin
  Result := inherited DoSalvar;

  if Result then
  begin
    try
      if not Assigned(ObjetoVO) then
        ObjetoVO := TAgendaCategoriaCompromissoVO.Create;

      TAgendaCategoriaCompromissoVO(ObjetoVO).Cor := EditCor.Text;
      TAgendaCategoriaCompromissoVO(ObjetoVO).Nome := EditDescricao.Text;

      if StatusTela = stInserindo then
      begin
        TAgendaCategoriaCompromissoController.Insere(TAgendaCategoriaCompromissoVO(ObjetoVO));
      end
      else if StatusTela = stEditando then
      begin
        if TAgendaCategoriaCompromissoVO(ObjetoVO).ToJSONString <> StringObjetoOld then
        begin
          TAgendaCategoriaCompromissoController.Altera(TAgendaCategoriaCompromissoVO(ObjetoVO));
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
procedure TFAgendaCategoriaCompromisso.GridParaEdits;
var
  IdCabecalho: String;
begin
  inherited;

  if not CDSGrid.IsEmpty then
  begin
    IdCabecalho := IntToStr(IdRegistroSelecionado);
    ObjetoVO := TAgendaCategoriaCompromissoController.ConsultaObjeto('ID=' + IdCabecalho);
  end;

  if Assigned(ObjetoVO) then
  begin
    EditCor.Text := TAgendaCategoriaCompromissoVO(ObjetoVO).Cor;
    EditDescricao.Text := TAgendaCategoriaCompromissoVO(ObjetoVO).Nome;

    // Serializa o objeto para consultar posteriormente se houve alterações
    FormatSettings.DecimalSeparator := '.';
    StringObjetoOld := ObjetoVO.ToJSONString;
    FormatSettings.DecimalSeparator := ',';
  end;
end;
{$ENDREGION}

end.

