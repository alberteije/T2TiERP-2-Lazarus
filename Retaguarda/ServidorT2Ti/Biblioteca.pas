{*******************************************************************************
Title: T2TiPDV
Description: Biblioteca de funções.

The MIT License

Copyright: Copyright (C) 2014 T2Ti.COM

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
           alberteije@gmail.com

@author T2Ti.COM
@version 2.0
*******************************************************************************}
unit Biblioteca;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, Classes, Math;

function TextoParaData(pData: string): TDate;
function DataParaTexto(pData: TDate): string;
Function ArredondaTruncaValor(Operacao: String; Value: Extended; Casas: integer): Extended;

implementation

function TextoParaData(pData: string): TDate;
var
  Dia, Mes, Ano: Integer;
begin
  if (pData <> '') AND (pData <> '0000-00-00') then
  begin
    Dia := StrToInt(Copy(pData,9,2));
    Mes := StrToInt(Copy(pData,6,2));
    Ano := StrToInt(Copy(pData,1,4));
    Result := EncodeDate(Ano,Mes,Dia);
  end
  else
  begin
    Result := 0;
  end;
end;

function DataParaTexto(pData: TDate): string;
begin
  if pData > 0 then
    Result := FormatDateTime('YYYY-MM-DD',pData)
  else
    Result := '0000-00-00';
end;

Function ArredondaTruncaValor(Operacao: String; Value: Extended; Casas: integer): Extended;
Var
  sValor: String;
  nPos: integer;
begin
  if Operacao = 'A' then
    Result := SimpleRoundTo(Value, Casas * -1)
  else
  begin
    // Transforma o valor em string
    sValor := FloatToStr(Value);

    // Verifica se possui ponto decimal
    nPos := Pos(FormatSettings.DecimalSeparator, sValor);
    If (nPos > 0) Then
    begin
      sValor := Copy(sValor, 1, nPos + Casas);
    End;

    Result := StrToFloat(sValor);
  end;
end;

end.
