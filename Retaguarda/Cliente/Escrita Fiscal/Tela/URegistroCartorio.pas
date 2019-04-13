{ *******************************************************************************
Title: T2Ti ERP
Description: Janela Registro Cartório para o módulo Escrita Fiscal

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
unit URegistroCartorio;

interface

uses
  BrookHTTPClient, BrookFCLHTTPClientBroker, BrookHTTPUtils, BrookUtils, FPJson, ZDataset,
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UTelaCadastro, Menus, StdCtrls, ExtCtrls, Buttons, Grids, DBGrids,
  ComCtrls, LabeledCtrls, rxdbgrid, rxtoolbar, DBCtrls, StrUtils,
  Math, Constantes, CheckLst, ActnList, ToolWin, ShellApi, db, BufDataset, Biblioteca,
  ULookup, VO, RegistroCartorioController, RegistroCartorioVO;

  type

  TFRegistroCartorio = class(TFTelaCadastro)
    BevelEdits: TBevel;
    EditNomeCartorio: TLabeledEdit;
    EditDataRegistro: TLabeledDateEdit;
    EditNumero: TLabeledCalcEdit;
    EditFolha: TLabeledCalcEdit;
    EditLivro: TLabeledCalcEdit;
    EditNire: TLabeledEdit;
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
  FRegistroCartorio: TFRegistroCartorio;

implementation

{$R *.lfm}

{$REGION 'Controles Infra'}
procedure TFRegistroCartorio.BotaoConsultarClick(Sender: TObject);
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
    RetornoConsulta := TRegistroCartorioController.Consulta(Filtro, IntToStr(Pagina));
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

procedure TFRegistroCartorio.BotaoSalvarClick(Sender: TObject);
begin
  inherited;
  BotaoConsultarClick(Sender);
end;

procedure TFRegistroCartorio.FormCreate(Sender: TObject);
begin
  ClasseObjetoGridVO := TRegistroCartorioVO;
  ObjetoController := TRegistroCartorioController.Create;

  inherited;
end;
{$ENDREGION}

{$REGION 'Controles CRUD'}
function TFRegistroCartorio.DoInserir: Boolean;
begin
  Result := inherited DoInserir;

  if Result then
  begin
    EditNomeCartorio.SetFocus;
  end;
end;

function TFRegistroCartorio.DoEditar: Boolean;
begin
  Result := inherited DoEditar;

  if Result then
  begin
    EditNomeCartorio.SetFocus;
  end;
end;

function TFRegistroCartorio.DoExcluir: Boolean;
begin
  if inherited DoExcluir then
  begin
    try
      Result := TRegistroCartorioController.Exclui(IdRegistroSelecionado);
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

function TFRegistroCartorio.DoSalvar: Boolean;
begin
  Result := inherited DoSalvar;

  if Result then
  begin
    try
      if not Assigned(ObjetoVO) then
        ObjetoVO := TRegistroCartorioVO.Create;

      TRegistroCartorioVO(ObjetoVO).IdEmpresa := Sessao.Empresa.Id;
      TRegistroCartorioVO(ObjetoVO).NomeCartorio := EditNomeCartorio.Text;
      TRegistroCartorioVO(ObjetoVO).DataRegistro := EditDataRegistro.Date;
      TRegistroCartorioVO(ObjetoVO).Numero := EditNumero.AsInteger;
      TRegistroCartorioVO(ObjetoVO).Folha := EditFolha.AsInteger;
      TRegistroCartorioVO(ObjetoVO).Livro := EditLivro.AsInteger;
      TRegistroCartorioVO(ObjetoVO).Nire := EditNire.Text;

      if StatusTela = stInserindo then
      begin
        TRegistroCartorioController.Insere(TRegistroCartorioVO(ObjetoVO));
      end
      else if StatusTela = stEditando then
      begin
        if TRegistroCartorioVO(ObjetoVO).ToJSONString <> StringObjetoOld then
        begin
          TRegistroCartorioController.Altera(TRegistroCartorioVO(ObjetoVO));
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
procedure TFRegistroCartorio.GridParaEdits;
var
  IdCabecalho: String;
begin
  inherited;

  if not CDSGrid.IsEmpty then
  begin
    IdCabecalho := IntToStr(IdRegistroSelecionado);
    ObjetoVO := TRegistroCartorioController.ConsultaObjeto('ID=' + IdCabecalho);
  end;

  if Assigned(ObjetoVO) then
  begin
    EditNomeCartorio.Text := TRegistroCartorioVO(ObjetoVO).NomeCartorio;
    EditDataRegistro.Date := TRegistroCartorioVO(ObjetoVO).DataRegistro;
    EditNumero.AsInteger := TRegistroCartorioVO(ObjetoVO).Numero;
    EditFolha.AsInteger := TRegistroCartorioVO(ObjetoVO).Folha;
    EditLivro.AsInteger := TRegistroCartorioVO(ObjetoVO).Livro;
    EditNire.Text := TRegistroCartorioVO(ObjetoVO).Nire;

    // Serializa o objeto para consultar posteriormente se houve alterações
    FormatSettings.DecimalSeparator := '.';
    StringObjetoOld := ObjetoVO.ToJSONString;
    FormatSettings.DecimalSeparator := ',';
  end;
end;
{$ENDREGION}

end.

