unit UDataModuleConexao;

{$mode delphi}

interface

uses
  Forms, Classes, SysUtils, FileUtil, ZConnection;

type

  { TFDataModuleConexao }

  TFDataModuleConexao = class(TDataModule)
    Conexao: TZConnection;
    procedure DataModuleCreate(Sender: TObject);
  private
    { private declarations }
    var Banco: String;
    procedure ConfigurarConexao(var pConexao: TZConnection; pBD: String);
  public
    { public declarations }
    procedure Conectar(BD: String);
    procedure Desconectar;
    function getConexao: TZConnection;
    function getBanco: String;
  end;

var
  FDataModuleConexao: TFDataModuleConexao;

implementation

{$R *.lfm}

{ TFDataModuleConexao }

procedure TFDataModuleConexao.DataModuleCreate(Sender: TObject);
begin
  Conectar('MySQL');
end;

procedure TFDataModuleConexao.Conectar(BD: String);
begin
  Desconectar;
  ConfigurarConexao(Conexao, BD);
  Conexao.Connected := True;
  Banco := BD;
end;

procedure TFDataModuleConexao.Desconectar;
begin
  Conexao.Connected := False;
end;

function TFDataModuleConexao.getBanco: String;
begin
  Result := Banco;
end;

function TFDataModuleConexao.getConexao: TZConnection;
begin
  Result := Conexao;
end;

procedure TFDataModuleConexao.ConfigurarConexao(var pConexao: TZConnection; pBD: String);
var
  Arquivo: String;
begin
  if pBD = 'Oracle' then
  begin
    Arquivo := ExtractFilePath(Application.ExeName) + 'Oracle_Zeos_conn.txt';

  end
  else
  if pBD = 'MSSQL' then
  begin
    Arquivo := ExtractFilePath(Application.ExeName) + 'MSSQL_Zeos_conn.txt';

  end
  else
  if pBD = 'Firebird' then
  begin
    Arquivo := ExtractFilePath(Application.ExeName) + 'Firebird_Zeos_conn.txt';

    Conexao.Protocol := 'firebird-2.5';
    Conexao.HostName := 'localhost';
    Conexao.Database := 'localhost:C\Banco\PAFECF.FDB';
    Conexao.User := 'SYSDBA';
    Conexao.Password := 'masterkey';
  end
  else
  if pBD = 'Interbase' then
  begin
    Arquivo := ExtractFilePath(Application.ExeName) + 'Interbase_Zeos_conn.txt';

  end
  else
  if pBD = 'MySQL' then
  begin
    Arquivo := ExtractFilePath(Application.ExeName) + 'MySQL_Zeos_conn.txt';

    Conexao.Protocol := 'mysql';
    Conexao.HostName := 'localhost';
    Conexao.Database := 'pafecf';
    Conexao.User := 'root';
    Conexao.Password := 'root';
  end
  else
  if pBD = 'DB2' then
  begin
    Arquivo := ExtractFilePath(Application.ExeName) + 'DB2_Zeos_conn.txt';

  end
  else
  if pBD = 'Postgres' then
  begin
    Arquivo := ExtractFilePath(Application.ExeName) + 'Postgres_DBExpress_conn.txt';

  end;

  Conexao.LoginPrompt := False;
end;

end.

