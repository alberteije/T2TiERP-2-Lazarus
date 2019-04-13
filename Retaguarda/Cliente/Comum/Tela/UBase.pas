{ *******************************************************************************
Title: T2Ti ERP
Description: Janela Base

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

@author Albert Eije (t2ti.com@gmail.com)
@version 2.0
******************************************************************************* }
unit UBase;

{$MODE Delphi}

interface

uses
  BrookHTTPClient, BrookFCLHTTPClientBroker, BrookHTTPUtils, BrookUtils,
  LCLIntf, LCLType, LMessages, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, SessaoUsuario, Buttons, Tipos, UDataModule, ActnList, Menus, FPJson, DB, BufDataset;

type
  TFBase = class(TForm)
  private
    function GetSessaoUsuario: TSessaoUsuario;
    function GetCustomKeyPreview: Boolean;
    procedure SetCustomKeyPreview(const Value: Boolean);
    { Private declarations }
  public
    { Public declarations }
    property Sessao: TSessaoUsuario read GetSessaoUsuario;
    property CustomKeyPreview: Boolean read GetCustomKeyPreview write SetCustomKeyPreview default False;

    procedure FechaFormulario;
    procedure AtualizaGridJsonInterna(pDadosJson: TJSONData; pDataSet: TBufDataSet);
  end;

var
  FBase: TFBase;

implementation

uses UMenu, ComCtrls;
{$R *.lfm}
{ TFBase }

procedure TFBase.FechaFormulario;
begin
  if (Self.Owner is TTabSheet) and (Assigned(FMenu)) then
    FMenu.FecharAba(TTabSheet(Self.Owner))
  else
    Self.Close;
end;

function TFBase.GetCustomKeyPreview: Boolean;
begin
  Result := Self.KeyPreview;
end;

procedure TFBase.SetCustomKeyPreview(const Value: Boolean);
begin
  Self.KeyPreview := Value;

  if (Self.Owner is TTabSheet) and (Assigned(FMenu)) then
  begin
    FMenu.KeyPreview := Value;
  end;
end;

function TFBase.GetSessaoUsuario: TSessaoUsuario;
begin
  Result := TSessaoUsuario.Instance;
end;

procedure TFBase.AtualizaGridJsonInterna(pDadosJson: TJSONData; pDataSet: TBufDataSet);
var
  VIsObject: Boolean;
  VJSONCols: TJSONObject;
  VRecord: TJSONData = nil;
  I, J: Integer;
begin
  pDataSet.Close;
  pDataSet.Open;

  if not Assigned(pDadosJson) then
  begin
    Exit;
  end;

  VJSONCols := TJSONObject(pDadosJson.Items[0]);
  VIsObject := VJSONCols.JSONType = jtObject;
  if VIsObject and (VJSONCols.Count < 1) then
  begin
    Exit;
  end;

  try
    for I := 0 to Pred(pDadosJson.Count) do
    begin
      pDataSet.Append;
      VJSONCols := TJSONObject(pDadosJson.Items[I]);
      for J := 0 to Pred(VJSONCols.Count) do
      begin
        VRecord := VJSONCols.Items[J];
        case VRecord.JSONType of
          jtNumber:
            begin
              if VRecord is TJSONFloatNumber then
                pDataSet.FieldByName(VJSONCols.Names[J]).AsFloat := VRecord.AsFloat
              else
                pDataSet.FieldByName(VJSONCols.Names[J]).AsInteger := VRecord.AsInt64;
            end;
          jtString:
            pDataSet.FieldByName(VJSONCols.Names[J]).AsString := VRecord.AsString;
          jtBoolean:
            pDataSet.FieldByName(VJSONCols.Names[J]).AsString := BoolToStr(VRecord.AsBoolean, 'TRUE', 'FALSE');
          end;
        end;
        pDataSet.Post;
    end;
  finally
  end;
end;

end.
