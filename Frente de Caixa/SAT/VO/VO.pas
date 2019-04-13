{ *******************************************************************************
Title: T2Ti ERP
Description: Classe VO padrão de onde herdam todas as classes de VO

The MIT License

Copyright: Copyright (C) 2010 T2Ti.COM

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
unit VO;

{$mode objfpc}{$H+}

interface

uses
  TypInfo, SysUtils, Classes, FPJSON, FGL, fpjsonrtti;

type

  { TVO }

  TVO = class(TPersistent)
  public
    constructor Create; overload; virtual;

    function ToJSON: TJSONObject; virtual;
    function ToJSONString: string;
  end;

  TListaVO = specialize TFPGObjectList<TVO>;

implementation

{$Region 'TVO'}

constructor TVO.Create;
begin
  inherited Create;
end;

function TVO.ToJSON: TJSONObject;
//var
  //Serializa: TJSONStreamer;
begin
  (*
  Serializa := TJSONMarshal.Create(TJSONConverter.Create);
  try
    Exit(Serializa.Marshal(Self));
  finally
    Serializa.Free;
  end;
  *)
end;

function TVO.ToJSONString: String;
var
  Serializa: TJSONStreamer;
begin
  Serializa := TJSONStreamer.Create(nil);
  try
    Serializa.Options := Serializa.Options + [jsoTStringsAsArray];
    Serializa.Options := Serializa.Options + [jsoComponentsInline];
    Serializa.Options := Serializa.Options + [jsoDateTimeAsString];
    Serializa.Options := Serializa.Options + [jsoStreamChildren];
    // JSON convert and output
    Result := Serializa.ObjectToJSONString(Self);
  finally
    Serializa.Free;
  end;
end;
{$EndRegion 'TVO'}

end.
