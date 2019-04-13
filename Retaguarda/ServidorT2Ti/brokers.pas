unit Brokers;

{$mode objfpc}{$H+}

interface

uses
  BrookFCLCGIBroker, BrookSQLdbBroker, BrookUtils, BrookHTTPConsts, SQLite3Conn, mysql51conn;

implementation

initialization
  BrookSettings.Configuration := 'db.cfg';
  BrookSettings.ContentType := BROOK_HTTP_CONTENT_TYPE_APP_JSON;
  BrookSettings.AcceptsJSONContent := True;
  BrookSettings.Page404 := '{ "error": "Not found." }';
  BrookSettings.Page500 := '{ "error": "@error" }';

end.
