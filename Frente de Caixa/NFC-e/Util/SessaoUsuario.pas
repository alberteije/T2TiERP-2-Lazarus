unit SessaoUsuario;

{$MODE objfpc}{$H+}

interface

uses
  Classes, Biblioteca, Forms, LCLIntf, LCLType, LMessages, IniFiles, SysUtils,
  Tipos, ACBrDevice, md5,

  NfceOperadorVO, NfceConfiguracaoVO, NfceMovimentoVO, NfceTipoPagamentoVO,
  NfeCabecalhoVO;

type
  TSessaoUsuario = class
  private
    FUrl: String;
    FIdSessao: String;
    FCamadas: Integer;
    FStatusCaixa: TStatusCaixa;
    FMenuAberto: TSimNao;
    FServidor: String;
    FPorta: Integer;

    FUsuario: TNfceOperadorVO;
    FConfiguracao: TNfceConfiguracaoVO;
    FMovimento: TNfceMovimentoVO;
    FVendaAtual: TNfeCabecalhoVO;

    FListaTipoPagamento: TListaNfceTipoPagamentoVO;

    class var FInstance: TSessaoUsuario;
  public
    constructor Create;
    destructor Destroy; override;

    class function Instance: TSessaoUsuario;
    function AutenticaUsuario(pLogin, pSenha: String): Boolean;
    function Autenticado: Boolean;
    procedure PopulaObjetosPrincipais;
    procedure LiberaVendaAtual;

    property URL: String read FUrl;
    property IdSessao: String read FIdSessao;
    property Camadas: Integer read FCamadas write FCamadas;
    property StatusCaixa: TStatusCaixa read FStatusCaixa write FStatusCaixa;
    property MenuAberto: TSimNao read FMenuAberto write FMenuAberto;
    property Servidor: String read FServidor;
    property Porta: Integer read FPorta;

    property Usuario: TNfceOperadorVO read FUsuario;
    property Configuracao: TNfceConfiguracaoVO read FConfiguracao write FConfiguracao;
    property Movimento: TNfceMovimentoVO read FMovimento write FMovimento;
    property VendaAtual: TNfeCabecalhoVO read FVendaAtual write FVendaAtual;

    property ListaTipoPagamento: TListaNfceTipoPagamentoVO read FListaTipoPagamento write FListaTipoPagamento;

  end;

implementation

uses
  Controller, NfceTipoPagamentoController, NfceMovimentoController,
  NfceConfiguracaoController, NfceOperadorController;

constructor TSessaoUsuario.Create;
var
  ArquivoIni: TIniFile;
  I: Integer;
begin
  inherited Create;

  // Conexão
  ArquivoIni := TIniFile.Create(ExtractFilePath(Application.ExeName) + 'Conexao.ini');
  try
    with ArquivoIni do
    begin
      if not SectionExists('ServidorApp') then
      begin
        WriteString('ServidorApp', 'Servidor', 'localhost');
        WriteInteger('ServidorApp', 'Porta', 8080);
      end;

      FServidor := ReadString('ServidorApp', 'Servidor', 'localhost');
      FPorta := ReadInteger('ServidorApp', 'Porta', 8080);
      Camadas := ReadInteger('ServidorApp', 'Camadas', 3);
    end;
  finally
    ArquivoIni.Free;
  end;

  FUrl := 'http://' + Servidor + ':' + IntToStr(Porta) + '/cgi-bin/servidorT2Ti.cgi';
end;

destructor TSessaoUsuario.Destroy;
begin
  FreeAndNil(FUsuario);
  FreeAndNil(FMovimento);
  FreeAndNil(FConfiguracao);
  FreeAndNil(FVendaAtual);

  FreeAndNil(FListaTipoPagamento);
  inherited;
end;

procedure TSessaoUsuario.LiberaVendaAtual;
begin
  FVendaAtual := Nil;
end;

procedure TSessaoUsuario.PopulaObjetosPrincipais;
var
  Filtro: String;
  I: Integer;
begin
  Filtro := 'STATUS_MOVIMENTO=' + QuotedStr('A') + ' or STATUS_MOVIMENTO=' + QuotedStr('T');
  FMovimento := TNfceMovimentoController.ConsultaObjeto(Filtro);
  FConfiguracao := TNfceConfiguracaoController.ConsultaObjeto('ID=1');
  FListaTipoPagamento := TNfceTipoPagamentoController.ConsultaLista('ID>0');
end;

class function TSessaoUsuario.Instance: TSessaoUsuario;
begin
  if not Assigned(FInstance) then
    FInstance := TSessaoUsuario.Create;

  Result := FInstance;
end;

function TSessaoUsuario.Autenticado: Boolean;
begin
  Result := Assigned(FUsuario);
end;

function TSessaoUsuario.AutenticaUsuario(pLogin, pSenha: String): Boolean;
var
  SenhaCript: String;
begin
  FIdSessao := CriaGuidStr;
  FIdSessao := MD5Print(MD5String(FIdSessao));
  try
    // Senha é criptografada com a senha digitada + login
    SenhaCript := MD5Print(MD5String(pLogin + pSenha));

    FUsuario := TNfceOperadorController.Usuario(pLogin, pSenha);

    if Assigned(FUsuario) then
      FUsuario.Senha := pSenha;

    Result := Assigned(FUsuario);
  except
    Application.MessageBox('Erro ao autenticar usuário.', 'Erro de Login', MB_OK + MB_ICONERROR);
    raise;
  end;
end;

end.
