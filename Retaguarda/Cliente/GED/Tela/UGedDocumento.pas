{ *******************************************************************************
Title: T2Ti ERP
Description: Janela para armazenar os documentos do GED

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
unit UGedDocumento;

{$MODE Delphi}

interface

uses
  BrookHTTPClient, BrookFCLHTTPClientBroker, BrookHTTPUtils, BrookUtils, FPJson, ZDataset,
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UTelaCadastro, Menus, StdCtrls, ExtCtrls, Buttons, Grids, DBGrids,
  ComCtrls, LabeledCtrls, rxdbgrid, rxtoolbar, activexcontainer, DBCtrls, StrUtils,
  Math, Constantes, CheckLst, ActnList, ToolWin, ShellApi, db, BufDataset, Biblioteca,
  ULookup, VO, CAPICOM_TLB, GedTipoDocumentoController, GedTipoDocumentoVO, DelphiTwain_VCL, md5;

  type

  { TFGedDocumento }

  TFGedDocumento = class(TFTelaCadastro)
    Ole: TActiveXContainer;
    PopupMenu: TPopupMenu;
    miTamanhoOriginal: TMenuItem;
    miReduzirparacaber: TMenuItem;
    PanelEditDocumento: TPanel;
    BevelEdits: TBevel;
    EditNome: TLabeledEdit;
    EditDescricao: TLabeledEdit;
    ScrollBoxImage: TScrollBox;
    ImagemDocumento: TImage;
    //Ole: TOleContainer;
    EditArquivoSelecionado: TLabeledEdit;
    EditDataInclusao: TLabeledDateEdit;
    ActionManager1: TActionList;
    ActionVisualizarArquivo: TAction;
    ActionAbrirArquivo: TAction;
    ActionDigitalizar: TAction;
    ActionToolBar1: TToolPanel;
    PageControlItens: TPageControl;
    tsItens: TTabSheet;
    PanelItens: TPanel;
    GridVersao: TRxDbGrid;
    DSVersaoDocumento: TDataSource;
    CDSVersaoDocumento: TBufDataSet;
    DSDetalhe: TDataSource;
    CDSDetalhe: TBufDataSet;
    tsDetalhe: TTabSheet;
    GridDetalhe: TRxDbGrid;
    ActionToolBar2: TToolPanel;
    ActionBaixarArquivo: TAction;
    ActionToolBar3: TToolPanel;
    ActionGravarDetalhe: TAction;
    ActionExcluirDetalhe: TAction;
    procedure FormCreate(Sender: TObject);
    procedure TwainTwainAcquire(Sender: TObject; const Index: Integer; Image: TBitmap; var Cancel: Boolean);
    procedure miTamanhoOriginalClick(Sender: TObject);
    procedure miReduzirparacaberClick(Sender: TObject);
    procedure ActionVisualizarArquivoExecute(Sender: TObject);
    procedure ActionAbrirArquivoExecute(Sender: TObject);
    procedure ActionDigitalizarExecute(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure GridDetalheKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure ActionBaixarArquivoExecute(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ActionGravarDetalheExecute(Sender: TObject);
    procedure ActionExcluirDetalheExecute(Sender: TObject);
    procedure BotaoConsultarClick(Sender: TObject);
    procedure BotaoSalvarClick(Sender: TObject);
    procedure CarregarDadosDetalhe;
  private
    { Private declarations }
    Twain: TDelphiTwain;
    TipoArquivo, BytesArquivo, BytesAssinatura: String;
    TamanhoArquivo: Integer;
    ArquivoStream, AssinaturaStream: TFileStream;
    Certificado: ICertificate2;

    procedure GridParaEdits; override;
    procedure LimparCampos; override;

    // Controles CRUD
    function DoInserir: Boolean; override;
    function DoEditar: Boolean; override;
    function DoExcluir: Boolean; override;
    function DoSalvar: Boolean; override;
    function DoCancelar: Boolean; override;

    procedure CarregaArquivo(pArquivo: String);
    procedure CarregaImagemPadrao;
    procedure CarregaImagemArquivo(pCaminhoArquivo: string);

    procedure SelecionarCertificado;
    procedure AssinarArquivo;
  public
    { Public declarations }
  end;

implementation

/// EXERCICIO: realize vários testes e corrija o que estiver com problemas

uses UDataModule, GedDocumentoCabecalhoController, GedDocumentoCabecalhoVO, GedVersaoDocumentoController,
GedVersaoDocumentoVO, GedDocumentoDetalheVO, GedDocumentoDetalheController, UMenu;
{$R *.lfm}

{$Region 'Infra'}
procedure TFGedDocumento.BotaoConsultarClick(Sender: TObject);
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
    RetornoConsulta := TGedDocumentoCabecalhoController.Consulta(Filtro, IntToStr(Pagina));
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

procedure TFGedDocumento.BotaoSalvarClick(Sender: TObject);
begin
  inherited;
  BotaoConsultarClick(Sender);
end;

procedure TFGedDocumento.FormCreate(Sender: TObject);
begin
  ClasseObjetoGridVO := TGedDocumentoCabecalhoVO;
  ObjetoController := TGedDocumentoCabecalhoController.Create;
  inherited;
  CarregaImagemPadrao;

  ConfiguraCDSFromVO(CDSVersaoDocumento, TGedVersaoDocumentoVO);
  ConfiguraCDSFromVO(CDSDetalhe, TGedDocumentoDetalheVO);
end;

procedure TFGedDocumento.FormDestroy(Sender: TObject);
begin
  inherited;
  Twain.Free;
end;

procedure TFGedDocumento.FormShow(Sender: TObject);
begin
  inherited;
  if not Assigned(FMenu) then
  begin
    ComboBoxCampos.ItemIndex := ComboBoxCampos.Items.IndexOf('NOME');
  end;
end;

procedure TFGedDocumento.LimparCampos;
begin
  inherited;
  CDSVersaoDocumento.Close;
  CDSDetalhe.Close;
  CDSVersaoDocumento.Open;
  CDSDetalhe.Open;
  CarregaImagemPadrao;
end;
{$EndRegion}

{$REGION 'Controles CRUD'}
function TFGedDocumento.DoInserir: Boolean;
begin
  Result := inherited DoInserir;

  if Result then
  begin
    EditNome.SetFocus;
  end;
end;

function TFGedDocumento.DoCancelar: Boolean;
begin
  Result := inherited DoCancelar;

  // se foi chamado por outra aplicação fecha o formulário
  if not Assigned(FMenu) then
  begin
    Close;
  end;
end;

function TFGedDocumento.DoEditar: Boolean;
begin
  Result := inherited DoEditar;

  if Result then
  begin
    EditNome.SetFocus;
  end;
end;

function TFGedDocumento.DoExcluir: Boolean;
begin
  if not CDSGrid.IsEmpty then
  begin
    Application.MessageBox('Documento não pode ser excluído.', 'Informação do sistema', MB_OK + MB_ICONINFORMATION);
  end;
end;

function TFGedDocumento.DoSalvar: Boolean;
begin
  Result := inherited DoSalvar;

  if Result then
  begin
    try
      if not Assigned(ObjetoVO) then
        ObjetoVO := TGedDocumentoCabecalhoVO.Create;

      TGedDocumentoCabecalhoVO(ObjetoVO).Nome := EditNome.Text;
      TGedDocumentoCabecalhoVO(ObjetoVO).Descricao := EditDescricao.Text;
      TGedDocumentoCabecalhoVO(ObjetoVO).DataInclusao := EditDataInclusao.Date;

      if StatusTela = stInserindo then
      begin
        TGedDocumentoCabecalhoController.Insere(TGedDocumentoCabecalhoVO(ObjetoVO));
      end
      else if StatusTela = stEditando then
      begin
        TGedDocumentoCabecalhoController.Altera(TGedDocumentoCabecalhoVO(ObjetoVO));
      end;
    except
      Result := False;
    end;
  end;
end;
{$ENDREGION}

{$REGION 'Controle de Grid'}
procedure TFGedDocumento.GridDetalheKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  (*
  /// EXERCICIO: Implemente a busca usando a janela FLookup

  if Key = VK_F1 then
  begin
    try
      if GridDetalhe.Columns[GridDetalhe.SelectedIndex].Field.FieldName = 'ID_GED_TIPO_DOCUMENTO' then
      begin
        if Assigned(VO) then
        begin
          CDSDetalhe.Edit;
          CDSDetalhe.FieldByName('ID_GED_TIPO_DOCUMENTO').AsInteger := CDSTransiente.FieldByName('ID').AsInteger;
          CDSDetalhe.Post;
        end;
      end;
    finally
    end;
  end;
  *)
end;

procedure TFGedDocumento.GridParaEdits;
var
  IdCabecalho: String;
  RetornoConsulta: TZQuery;
  ListaCampos: TStringList;
  I: Integer;
begin
  inherited;

  if not CDSGrid.IsEmpty then
  begin
    IdCabecalho := IntToStr(IdRegistroSelecionado);
    ObjetoVO := TGedDocumentoCabecalhoController.ConsultaObjeto('ID=' + IdCabecalho);
  end;

  if Assigned(ObjetoVO) then
  begin
    EditNome.Text := TGedDocumentoCabecalhoVO(ObjetoVO).Nome;
    EditDescricao.Text := TGedDocumentoCabecalhoVO(ObjetoVO).Descricao;
    EditDataInclusao.Date := TGedDocumentoCabecalhoVO(ObjetoVO).DataInclusao;

    CarregarDadosDetalhe;
  end;
end;

procedure TFGedDocumento.CarregarDadosDetalhe;
var
  RetornoConsulta: TZQuery;
  ListaCampos: TStringList;
  I: Integer;
begin
  /// EXERCICIO: Carregue os dados de detalhe através da lista

  // Detalhes
  CDSDetalhe.Close;
  CDSDetalhe.Open;

  Filtro := 'ID_GED_DOCUMENTO_CABECALHO=' + QuotedStr(IntToStr(TGedDocumentoCabecalhoVO(ObjetoVO).Id));
  ListaCampos  := TStringList.Create;
  RetornoConsulta := TGedDocumentoDetalheController.Consulta(Filtro, '0');
  RetornoConsulta.Active := True;

  RetornoConsulta.GetFieldNames(ListaCampos);

  RetornoConsulta.First;
  while not RetornoConsulta.EOF do begin
    CDSDetalhe.Append;
    for i := 0 to ListaCampos.Count - 1 do
    begin
      CDSDetalhe.FieldByName(ListaCampos[i]).Value := RetornoConsulta.FieldByName(ListaCampos[i]).Value;
    end;
    CDSDetalhe.Post;
    RetornoConsulta.Next;
  end;


  /// EXERCICIO
  /// Faça o mestre-detalhe entre CDSDetalhe e CDSVersaoDocumento
  CDSVersaoDocumento.Close;
  CDSVersaoDocumento.Open;

  Filtro := 'ID>0';
  ListaCampos  := TStringList.Create;
  RetornoConsulta := TGedVersaoDocumentoController.Consulta(Filtro, '0');
  RetornoConsulta.Active := True;

  RetornoConsulta.GetFieldNames(ListaCampos);

  RetornoConsulta.First;
  while not RetornoConsulta.EOF do begin
    CDSVersaoDocumento.Append;
    for i := 0 to ListaCampos.Count - 1 do
    begin
      CDSVersaoDocumento.FieldByName(ListaCampos[i]).Value := RetornoConsulta.FieldByName(ListaCampos[i]).Value;
    end;
    CDSVersaoDocumento.Post;
    RetornoConsulta.Next;
  end;
end;
{$EndRegion}

{$Region 'Imagem'}
procedure TFGedDocumento.TwainTwainAcquire(Sender: TObject; const Index: Integer; Image: TBitmap; var Cancel: Boolean);
var
  ImagemJPG: TJPEGImage;
begin
  ImagemJPG := TJPEGImage.Create;
  try
    ImagemJPG.CompressionQuality := 65; // Menor tamanho - menor qualidade
    ImagemJPG.Assign(Image);

    ImagemDocumento.Picture.Assign(ImagemJPG);
  finally
    ImagemJPG.Free;
  end;

  Cancel := True; { Only want one image }
  ImagemDocumento.Align := alNone;
  ArquivoStream := TFileStream.Create('temp.jpg', fmCreate);
  EditArquivoSelecionado.Text := '';
  ImagemDocumento.Picture.Graphic.SaveToStream(ArquivoStream);
  TipoArquivo := '.jpg';
  TamanhoArquivo := ArquivoStream.Size;
end;

procedure TFGedDocumento.miReduzirparacaberClick(Sender: TObject);
begin
  ImagemDocumento.AutoSize := False;
  ImagemDocumento.Width := 300;
  ImagemDocumento.Height := 300;
  ImagemDocumento.Stretch := True;
  ImagemDocumento.Proportional := True;
end;

procedure TFGedDocumento.miTamanhoOriginalClick(Sender: TObject);
begin
  ImagemDocumento.AutoSize := True;
  ImagemDocumento.Stretch := False;
  ImagemDocumento.Proportional := False;
end;

procedure TFGedDocumento.CarregaImagemPadrao;
begin
  FDataModule.ImagemPadrao.GetBitmap(0, ImagemDocumento.Picture.Bitmap);
  ImagemDocumento.Width := 300;
  ImagemDocumento.Height := 300;
  ImagemDocumento.AutoSize := True;
  ImagemDocumento.Stretch := False;
  ImagemDocumento.Align := alClient;
  ImagemDocumento.Repaint;
end;

procedure TFGedDocumento.CarregaImagemArquivo(pCaminhoArquivo: string);
const
  ExtImagens: array [0 .. 13] of string = ('.gif', '.cur', '.pcx', '.ani', '.gif', '.png', '.jpg', '.jpeg', '.bmp', '.tif', '.tiff', '.ico', '.emf', '.wmf');
var
  Ext: string;
  I: Integer;
begin
  CarregaImagemPadrao;

  if FileExists(pCaminhoArquivo) then
  begin
    Ext := LowerCase(ExtractFileExt(pCaminhoArquivo));
    for I := 0 to Length(ExtImagens) - 1 do
    begin
      if ExtImagens[I] = Ext then
      begin
        try
          ImagemDocumento.Picture.LoadFromFile(pCaminhoArquivo);
          miReduzirparacaberClick(nil);
        except
        end;
      end;
    end;
  end;
end;
{$EndRegion}

{$Region 'Assinatura Digital'}
procedure TFGedDocumento.SelecionarCertificado;
var
  Store: IStore3;
  Certs: ICertificates2;
  Certs2: ICertificates2;
  NumeroSerie: AnsiString;
  DataVencimento: TDateTime;
begin
  {
    Store: fornece os métodos para acessar o Certificate Store.
    O método Open estipula qual parte do Store se quer acessar:
    store pessoal ("My"), as autoridades certificadoras ("CA"), etc. }
  Store := CoStore.Create;

  // My CA Root AddressBook
  Store.Open(CAPICOM_CURRENT_USER_STORE, 'My', CAPICOM_STORE_OPEN_MAXIMUM_ALLOWED);

  Certs := Store.Certificates as ICertificates2;
  Certs2 := Certs.Select('Certificado(s) Digital(is) disponível(is)', 'Selecione o Certificado Digital para uso no aplicativo', False);

  if not(Certs2.Count = 0) then
  begin
    Certificado := IInterface(Certs2.Item[1]) as ICertificate2;
    NumeroSerie := Certificado.SerialNumber;
    DataVencimento := Certificado.ValidToDate;
  end;
end;

procedure TFGedDocumento.AssinarArquivo;
var
  lSigner: TSigner;
  lSignedData: TSignedData;
  qt: Integer;
  Mensagem, Conteudo: WideString;
begin

  { Abre o arquivo original para obter dele o conteúdo a ser assinado }
  ArquivoStream.Position:=0;
  Conteudo := ArquivoStream.ReadAnsiString;

  { Configura o objeto responsável por fazer a assinatura, informando qual é o
    certificado a ser usado e o conteúdo a ser assinado }
  lSigner := TSigner.Create(self);
  lSigner.Certificate := Certificado;
  lSignedData := TSignedData.Create(self);
  lSignedData.Content := Conteudo;

  { Efetivamente assina o conteúdo }
  Mensagem := lSignedData.Sign(lSigner.DefaultInterface, True, CAPICOM_ENCODE_BASE64);

  { Cria um novo arquivo e grava nele o resultado da assinatura }
  AssinaturaStream := TFileStream.Create('temp.assinatura', fmCreate);
  for qt := 1 to Length(Mensagem) do
    AssinaturaStream.Write(Mensagem[qt], 2);

  lSignedData.Free;
  lSigner.Free;
end;
{$EndRegion}

{$Region 'Actions'}
procedure TFGedDocumento.ActionVisualizarArquivoExecute(Sender: TObject);
var
  actx: variant;
  fn: widestring;
begin
  if Assigned(ArquivoStream) then
  begin
    actx := Ole.ComServer;
    fn := UTF8Decode('file:///'+StringReplace(FDataModule.OpenDialog.FileName, '\', '/', [rfReplaceAll]));
    actx.playlist.add(fn);
    actx.playlist.play;
  end
  else if FileExists(EditArquivoSelecionado.Text) then
  begin
    actx := Ole.ComServer;
    fn := UTF8Decode('file:///'+StringReplace(EditArquivoSelecionado.Text, '\', '/', [rfReplaceAll]));
    actx.playlist.add(fn);
    actx.playlist.play;
  end
  else
    Application.MessageBox('Não existe arquivo para ser exibido.', 'Erro', MB_OK + MB_ICONERROR);
end;

procedure TFGedDocumento.ActionAbrirArquivoExecute(Sender: TObject);
begin
  if not(StatusTela in [stInserindo, stEditando]) then
    Application.MessageBox('Não é permitido selecionar novo arquivo no modo de consulta.', 'Informação do sistema.', MB_OK + MB_ICONINFORMATION)
  else
  begin
    if FDataModule.OpenDialog.Execute then
    begin
      ArquivoStream := TFileStream.Create('', fmOpenRead or fmShareDenyNone);
      ArquivoStream.Create(FDataModule.OpenDialog.FileName, fmOpenRead or fmShareDenyNone);
//    TamanhoArquivo := FileSize(FDataModule.OpenDialog.FileName);
//    TipoArquivo := ExtractFileExt(FDataModule.OpenDialog.FileName);
      CarregaImagemPadrao;
      EditArquivoSelecionado.Text := FDataModule.OpenDialog.FileName;

      if EditNome.Text = '' then
      begin
        EditNome.Text := ExtractFileName(FDataModule.OpenDialog.FileName);
      end;

      CarregaImagemArquivo(FDataModule.OpenDialog.FileName);
    end;
  end;
end;

procedure TFGedDocumento.ActionBaixarArquivoExecute(Sender: TObject);
begin
  CarregaArquivo(CDSVersaoDocumento.FieldByName('CAMINHO').AsString);
end;

procedure TFGedDocumento.CarregaArquivo(pArquivo: String);
begin
  EditArquivoSelecionado.Text := TGedVersaoDocumentoController.BaixarArquivo(Filtro);
end;

procedure TFGedDocumento.ActionDigitalizarExecute(Sender: TObject);
var
  SelectedSource: Integer;
begin
  if not(StatusTela in [stInserindo, stEditando]) then
    Application.MessageBox('Não é permitido digitalizar imagem no modo de consulta.', 'Informação do sistema.', MB_OK + MB_ICONINFORMATION)
  else
  begin
    try
      //Create Twain
      if Twain = nil then begin
        Twain := TDelphiTwain.Create;
        Twain.OnTwainAcquire := TwainTwainAcquire;
      end;

      //Load Twain Library dynamically
      if Twain.LoadLibrary then
      begin
        //Load source manager
        Twain.SourceManagerLoaded := True;

        //Allow user to select source -> only the first time
        if not Assigned(Twain.SelectedSource) then
          Twain.SelectSource;

        if Assigned(Twain.SelectedSource) then
        begin
          //Load source, select transference method and enable (display interface)}
          Twain.SelectedSource.Loaded := TRUE;
          Twain.SelectedSource.ShowUI := TRUE;//display interface
          //Twain.Source[SelectedSource].TransferMode := ttmMemory;
          Twain.SelectedSource.Enabled := True;
        end
      end
      else
        Application.MessageBox('Twain não está instalado.', 'Erro', MB_OK + MB_ICONERROR);
    finally
      //Twain.Free;
    end;
  end;
end;

procedure TFGedDocumento.ActionExcluirDetalheExecute(Sender: TObject);
begin
  /// EXERCICIO: Implemente a exclusão. Não esqueça do versionamento.
end;

procedure TFGedDocumento.ActionGravarDetalheExecute(Sender: TObject);
var
  I: Integer;
  Detalhe: TGedDocumentoDetalheVO;
  MD5: String;
  pArquivoStream, pAssinaturaStream: TMemoryStream;
begin
  /// EXERCICIO: caso você tente inserir um detalhe sem primeiro salvar o cabeçalho, que problema vai ocorrer?
  ///  Corrija esse problema.

  if Assigned(ArquivoStream) then
  begin
    // Salva os dados do documento no banco de dados
    Detalhe := TGedDocumentoDetalheVO.Create;
    Detalhe.Id := CDSDetalhe.FieldByName('ID').AsInteger;
    Detalhe.IdGedDocumentoCabecalho := TGedDocumentoCabecalhoVO(ObjetoVO).Id;
    Detalhe.IdEmpresa := Sessao.Empresa.Id;
    /// EXERCICIO: force o usuário a escolher um tipo de documento
    Detalhe.IdGedTipoDocumento := CDSDetalhe.FieldByName('ID_GED_TIPO_DOCUMENTO').AsInteger;
    Detalhe.Nome := CDSDetalhe.FieldByName('NOME').AsString;
    Detalhe.Descricao := CDSDetalhe.FieldByName('DESCRICAO').AsString;
    Detalhe.PalavraChave := CDSDetalhe.FieldByName('PALAVRA_CHAVE').AsString;
    Detalhe.PodeExcluir := CDSDetalhe.FieldByName('PODE_EXCLUIR').AsString;
    Detalhe.PodeAlterar := CDSDetalhe.FieldByName('PODE_ALTERAR').AsString;
    Detalhe.Assinado := CDSDetalhe.FieldByName('ASSINADO').AsString;
    Detalhe.DataFimVigencia := CDSDetalhe.FieldByName('DATA_FIM_VIGENCIA').AsDateTime;
    Detalhe.DataExclusao := CDSDetalhe.FieldByName('DATA_EXCLUSAO').AsDateTime;


    if CDSDetalhe.FieldByName('ASSINADO').AsString = 'S' then
    begin
      SelecionarCertificado;
      AssinarArquivo;
    end;

    /// EXERCICIO: trabalhe dinamicamente com os nomes dos arquivos
    MD5 := MD5Print(MD5File('temp.jpg'));

    pArquivoStream := TMemoryStream.Create;
    pAssinaturaStream := TMemoryStream.Create;

    ArquivoStream.Free;
    AssinaturaStream.Free;

    pArquivoStream.LoadFromFile('temp.jpg');
    pAssinaturaStream.LoadFromFile('temp.assinatura');

    TGedDocumentoDetalheController.Altera(TGedDocumentoDetalheVO(Detalhe), pArquivoStream, pAssinaturaStream, MD5);
    CarregarDadosDetalhe;

    /// EXERCICIO
    /// Faça o mestre-detalhe entre CDSDetalhe e CDSVersaoDocumento
  end
  else
    Application.MessageBox('Não existe arquivo selecionado para ser armazenado.', 'Informação do sistema.', MB_OK + MB_ICONINFORMATION)
end;
{$EndRegion}


end.

