{ *******************************************************************************
Title: T2Ti ERP
Description: Janela de Cadastro dos Templates de Contrato - Módulo Gestão de Contratos

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

@author Albert Eije (alberteije@gmail.com)
@version 2.0
******************************************************************************* }
unit UContratoTemplate;

interface

uses
  BrookHTTPClient, BrookFCLHTTPClientBroker, BrookHTTPUtils, BrookUtils, FPJson, ZDataset,
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UTelaCadastro, Menus, StdCtrls, ExtCtrls, Buttons, Grids, DBGrids,
  ComCtrls, LabeledCtrls, rxdbgrid, rxtoolbar, DBCtrls, StrUtils,
  Math, Constantes, CheckLst, ActnList, ToolWin, ShellApi, db, BufDataset, Biblioteca,
  ULookup, VO, ComObj;

  type

  TFContratoTemplate = class(TFTelaCadastro)
    BevelEdits: TBevel;
    EditNome: TLabeledEdit;
    MemoDescricao: TLabeledMemo;
    ActionManager1: TActionList;
    ActionToolBar1: TToolPanel;
    ActionEditarArquivo: TAction;
    procedure FormCreate(Sender: TObject);
    procedure ActionEditarArquivoExecute(Sender: TObject);
    procedure BotaoConsultarClick(Sender: TObject);
    procedure BotaoSalvarClick(Sender: TObject);
  private
    { Private declarations }
    procedure DeletarArquivoTemporario;
    procedure UploadArquivo;
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
  FContratoTemplate: TFContratoTemplate;
  Handle: THandle;

implementation

uses ContratoTemplateController, ContratoTemplateVo,
  UDataModule;
{$R *.lfm}

{$REGION 'Infra'}
procedure TFContratoTemplate.BotaoConsultarClick(Sender: TObject);
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
    RetornoConsulta := TContratoTemplateController.Consulta(Filtro, IntToStr(Pagina));
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

procedure TFContratoTemplate.BotaoSalvarClick(Sender: TObject);
begin
  inherited;
  BotaoConsultarClick(Sender);
end;

procedure TFContratoTemplate.FormCreate(Sender: TObject);
begin
  ClasseObjetoGridVO := TContratoTemplateVO;
  ObjetoController := TContratoTemplateController.Create;
  DeletarArquivoTemporario;
  inherited;
  BotaoImprimir.Visible := False;
  MenuImprimir.Visible := False;
end;
{$ENDREGION}

{$REGION 'Controles CRUD'}
function TFContratoTemplate.DoInserir: Boolean;
begin
  Result := inherited DoInserir;

  if Result then
  begin
    DeletarArquivoTemporario;
    EditNome.SetFocus;
  end;
end;

function TFContratoTemplate.DoEditar: Boolean;
begin
  Result := inherited DoEditar;

  if Result then
  begin
    EditNome.SetFocus;
  end;
end;

function TFContratoTemplate.DoExcluir: Boolean;
begin
  if inherited DoExcluir then
  begin
    try
      Result := TContratoTemplateController.Exclui(IdRegistroSelecionado);
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

function TFContratoTemplate.DoSalvar: Boolean;
begin
  Result := inherited DoSalvar;

  if Result then
  begin
    try
      if not Assigned(ObjetoVO) then
        ObjetoVO := TContratoTemplateVO.Create;

      TContratoTemplateVO(ObjetoVO).IdEmpresa := Sessao.Empresa.Id;
      TContratoTemplateVO(ObjetoVO).Nome := EditNome.Text;
      TContratoTemplateVO(ObjetoVO).Descricao := MemoDescricao.Text;

      UploadArquivo;

      if StatusTela = stInserindo then
      begin
        TContratoTemplateController.Insere(TContratoTemplateVO(ObjetoVO));
      end
      else if StatusTela = stEditando then
      begin
          TContratoTemplateController.Altera(TContratoTemplateVO(ObjetoVO));
      end;
    except
      Result := False;
    end;
  end;
  DeletarArquivoTemporario;
end;
{$ENDREGION}

{$REGION 'Controle de Grid'}
procedure TFContratoTemplate.GridParaEdits;
var
  IdCabecalho: String;
begin
  inherited;

  if not CDSGrid.IsEmpty then
  begin
    IdCabecalho := IntToStr(IdRegistroSelecionado);
    ObjetoVO := TContratoTemplateController.ConsultaObjeto('ID=' + IdCabecalho);
  end;

  if Assigned(ObjetoVO) then
  begin
    EditNome.Text := TContratoTemplateVO(ObjetoVO).Nome;
    MemoDescricao.Text := TContratoTemplateVO(ObjetoVO).Descricao;

    // Serializa o objeto para consultar posteriormente se houve alterações
    FormatSettings.DecimalSeparator := '.';
    StringObjetoOld := ObjetoVO.ToJSONString;
    FormatSettings.DecimalSeparator := ',';
  end;
end;
{$ENDREGION}

{$REGION 'Actions'}
procedure TFContratoTemplate.ActionEditarArquivoExecute(Sender: TObject);
const
  ServerName = 'Word.Application';
var
  WordApp: Variant;
  Documento: widestring;
  Arquivo: String;
begin
  /// EXERCICIO: Tente usar o formulário FDocumentoWord em conjunto com o componente TActiveXContainer (LazActiveX)

  // Se o usuário estiver editando um Template, verifica se já existe um arquivo no servidor
  if StatusTela = stEditando then
  begin
    Filtro := IntToStr(TContratoTemplateVO(ObjetoVO).Id) + '.doc';
    Arquivo := TContratoTemplateController.BaixarArquivo(Filtro);
  end;

  // Instancia o Word
  if Assigned(InitProc) then
    TProcedure(InitProc);

  try
    WordApp := CreateOleObject(ServerName);
  except
    WriteLn('Impossível Iniciar o Word.');
    Exit;
  end;

  if FileExists(Arquivo) then
  begin
    {
    FDocumentoWord.Operacao := 'Alterar';
    FDocumentoWord.NomeArquivo := Arquivo;
    }
  end
  else
  begin
    /// EXERCICIO: Observe se existe algum problema neste procedimento. Tente criar o documento com o OLE.

    Handle := CreateFile(PChar(Arquivo), GENERIC_READ or GENERIC_WRITE, 0, nil, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, 0);
    CloseHandle(Handle);
    Handle := Unassigned;

    {
    FDocumentoWord.Operacao := 'Inserir';
    }
  end;

  // Abre o word
  Documento := UTF8Decode(Arquivo);
  WordApp.Documents.Open(Documento);
  WordApp.Visible := True;

  //FDocumentoWord.ShowModal;
  WordApp := Unassigned;
end;

procedure TFContratoTemplate.DeletarArquivoTemporario;
begin
  if FileExists(ExtractFilePath(Application.ExeName)+'temp.doc') then
    DeleteFile(ExtractFilePath(Application.ExeName)+'temp.doc');
end;

procedure TFContratoTemplate.UploadArquivo;
begin
  /// EXERCICIO: caso esteja trabalhando em três camadas, implemente o upload do arquivo para o servidor
  /// Dica: o módulo Sped faz o download do arquivo do servidor para o cliente
end;
{$ENDREGION}

end.

