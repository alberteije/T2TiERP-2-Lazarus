{*******************************************************************************
Title: T2TiPDV
Description: Biblioteca de funções.

The MIT License

Copyright: Copyright (C) 2012 T2Ti.COM

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
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, DB,
  DBGrids, Constantes;

function CriaGuidStr: string;
function DevolveInteiro(Const Texto:String):String;
Function ValidaCNPJ(xCNPJ: String):Boolean;
Function ValidaCPF( xCPF:String ):Boolean;
Function ValidaEstado(Dado : string) : boolean;
Function Hora_Seg( Horas:string ):LongInt;
Function Seg_Hora( Seg:LongInt ):string;
Function StrZero(Num:Real ; Zeros,Deci:integer): string;
Procedure SetTaskBar(Visible: Boolean);
Function TruncaValor(Value:Extended;Casas:Integer):Extended;
function UltimoDiaMes(Mdt: TDateTime) : String;
function FormataFloat(Tipo:String; Valor: Extended): string; //Tipo => 'Q'=Quantidade | 'V'=Valor
procedure Split(const Delimiter: Char; Input: string; const Strings: TStrings);
function DevolveConteudoDelimitado(Delimidador:string;var Linha:string):string;
function VersaoExe(exe, param : string): String;  // acrescentar
procedure ArredondaComponentes(Control: TWinControl);
function StrIsInteger(const S: string): boolean;
function padR(const AString : AnsiString; const nLen : Integer; const Caracter : AnsiChar) : AnsiString ;
function TiraPontos(Str: string): string;
function TextoParaData(pData: string): TDate;
function DataParaTexto(pData: TDate): string;
function mc_ValorExtenso(Valor :Currency) :String;

{Funções auxiliares}
function mcx_Ajusta(Valor :String) :String;
function mcx_Centenas(Valor :Integer) :String;
function mcx_Dezenas(Valor :Integer) :String;
function mcx_Unidades(Valor :Integer) :String;
function Codifica(Action, Src: String): String;
Function ColocaZerosEsquerda(S:String;vT:Integer):String;
function VerificaNULL(Texto:string;Tipo:integer):string;
procedure ConfiguraAmbiente;

function Modulo11(Numero: String): String;

var
  InString : String;

implementation

function CriaGuidStr: string;
var
  Guid: TGUID;
begin
  CreateGUID(Guid);
  Result := GUIDToString(Guid);
end;

function DevolveInteiro(Const Texto:String):String;
var I: integer;
    S: string;
begin
  S := '';
  for I := 1 To Length(Texto) Do
  begin
    if Texto[I] in ['0'..'9'] then
    begin
      S := S + Copy(Texto, I, 1);
    end;
  end;
  result := S;
end;

procedure ConfiguraAmbiente;
begin
  DateSeparator     := '/';
  ShortDateFormat   := 'dd/mm/yyyy';
  ThousandSeparator := '.';
  DecimalSeparator  := ',';
end;

function VerificaNULL(Texto:string;Tipo:integer):string;
begin

  case tipo of

    0:begin
      if trim(Texto) = '' then
        Result := 'NULL'
      else
        Result := trim(Texto);
    end;
    1:begin
      if trim(Texto) = '' then
        Result := 'NULL'
      else
        Result := QuotedStr(trim(Texto));
    end;
    2:begin
      if trim(Texto) = '' then
        Result := ''
      else
        Result := (trim(Texto));
    end;

  end;
end;

{ Valida o CNPJ digitado }
function ValidaCNPJ(xCNPJ: String):Boolean;
Var
d1,d4,xx,nCount,fator,resto,digito1,digito2 : Integer;
Check : String;
begin
d1 := 0;
d4 := 0;
xx := 1;
for nCount := 1 to Length( xCNPJ )-2 do
    begin
    if Pos( Copy( xCNPJ, nCount, 1 ), '/-.' ) = 0 then
       begin
       if xx < 5 then
          begin
          fator := 6 - xx;
          end
       else
          begin
          fator := 14 - xx;
          end;
       d1 := d1 + StrToInt( Copy( xCNPJ, nCount, 1 ) ) * fator;
       if xx < 6 then
          begin
          fator := 7 - xx;
          end
       else
          begin
          fator := 15 - xx;
          end;
       d4 := d4 + StrToInt( Copy( xCNPJ, nCount, 1 ) ) * fator;
       xx := xx+1;
       end;
    end;
    resto := (d1 mod 11);
    if resto < 2 then
       begin
       digito1 := 0;
       end
   else
       begin
       digito1 := 11 - resto;
       end;
   d4 := d4 + 2 * digito1;
   resto := (d4 mod 11);
   if resto < 2 then
      begin
      digito2 := 0;
      end
   else
      begin
      digito2 := 11 - resto;
      end;
   Check := IntToStr(Digito1) + IntToStr(Digito2);
   if Check <> copy(xCNPJ,succ(length(xCNPJ)-2),2) then
      begin
      Result := False;
      end
   else
      begin
      Result := True;
      end;
end;

{ Valida o CPF digitado }
function ValidaCPF( xCPF:String ):Boolean;
Var
d1,d4,xx,nCount,resto,digito1,digito2 : Integer;
Check : String;
Begin
d1 := 0; d4 := 0; xx := 1;
for nCount := 1 to Length( xCPF )-2 do
    begin
    if Pos( Copy( xCPF, nCount, 1 ), '/-.' ) = 0 then
       begin
       d1 := d1 + ( 11 - xx ) * StrToInt( Copy( xCPF, nCount, 1 ) );
       d4 := d4 + ( 12 - xx ) * StrToInt( Copy( xCPF, nCount, 1 ) );
       xx := xx+1;
       end;
    end;
resto := (d1 mod 11);
if resto < 2 then
   begin
   digito1 := 0;
   end
else
   begin
   digito1 := 11 - resto;
   end;
d4 := d4 + 2 * digito1;
resto := (d4 mod 11);
if resto < 2 then
   begin
   digito2 := 0;
   end
else
   begin
   digito2 := 11 - resto;
   end;
Check := IntToStr(Digito1) + IntToStr(Digito2);
if Check <> copy(xCPF,succ(length(xCPF)-2),2) then
   begin
   Result := False;
   end
else
   begin
   Result := True;
   end;
end;

{ Valida a UF digitada }
function ValidaEstado(Dado : string) : boolean;
const
  Estados = 'SPMGRJRSSCPRESDFMTMSGOTOBASEALPBPEMARNCEPIPAAMAPFNACRRRO';
var
  Posicao : integer;
begin
Result := true;
if Dado <> '' then
   begin
   Posicao := Pos(UpperCase(Dado),Estados);
   if (Posicao = 0) or ((Posicao mod 2) = 0) then
      begin
      Result := false;
      end;
    end;
end;

{Converte de hora para segundos}
function Hora_Seg( Horas:string ):LongInt;
Var Hor,Min,Seg:LongInt;
begin
   Horas[Pos(':',Horas)]:= '[';
   Horas[Pos(':',Horas)]:= ']';
   Hor := StrToInt(Copy(Horas,1,Pos('[',Horas)-1));
   Min := StrToInt(Copy(Horas,Pos('[',Horas)+1,(Pos(']',Horas)-Pos('[',Horas)-1)));
   if Pos(':',Horas) > 0 then
      Seg := StrToInt(Copy(Horas,Pos(']',Horas)+1,(Pos(':',Horas)-Pos(']',Horas)-1)))
   else
      Seg := StrToInt(Copy(Horas,Pos(']',Horas)+1,2));
   Result := Seg + (Hor*3600) + (Min*60);
end;

{Converte de segundos para hora}
function Seg_Hora( Seg:LongInt ):string;
Var Hora,Min:LongInt;
    Tmp : Double;
begin
   Tmp := Seg / 3600;
   Hora := Round(Int(Tmp));
   Seg :=  Round(Seg - (Hora*3600));
   Tmp := Seg / 60;
   Min := Round(Int(Tmp));
   Seg :=  Round(Seg - (Min*60));
   Result := StrZero(Hora,2,0)+':'+StrZero(Min,2,0)+':'+StrZero(Seg,2,0);
end;

{esconde|exibe a barra do Windows}
procedure SetTaskBar(Visible: Boolean);
var
  wndHandle : THandle;
  wndClass : array[0..50] of Char;
begin
{  StrPCopy(@wndClass[0],'Shell_TrayWnd');
  wndHandle := FindWindow(@wndClass[0], nil);
  If Visible = True then
    ShowWindow(wndHandle, SW_RESTORE)
  else ShowWindow(wndHandle, SW_HIDE); }
end;

function StrZero(Num:Real ; Zeros,Deci:integer): string;
var Tam,Z:integer;
    Res,Zer:string;
begin
   Str(Num:Zeros:Deci,Res);
   Res := Trim(Res);
   Tam := Length(Res);
   Zer := '';
   for z := 01 to (Zeros-Tam) do
      Zer := Zer + '0';
   Result := Zer+Res;
end;

Function TruncaValor(Value:Extended;Casas:Integer):Extended;
Var sValor:String;
    nPos:Integer;
begin
   //Transforma o valor em string
   sValor := FloatToStr(Value);

   //Verifica se possui ponto decimal
   nPos := Pos(DecimalSeparator,sValor);
   If ( nPos > 0 ) Then begin
      sValor := Copy(sValor,1,nPos+Casas);
   End;

   Result := StrToFloat(sValor);
end;

function UltimoDiaMes(Mdt: TDateTime) : String;
var
  ano, mes, dia : word;
  mDtTemp : TDateTime;
begin
  Decodedate(mDt, ano, mes, dia);
  mDtTemp := (mDt - dia) + 33;
  Decodedate(mDtTemp, ano, mes, dia);
  mDtTemp := mDtTemp - dia;
  Decodedate(mDtTemp, ano, mes, dia);
  Result := IntToStr(dia)
end;

function FormataFloat(Tipo:String; Valor: Extended): string; //Tipo => 'Q'=Quantidade | 'V'=Valor
var
  i:integer;
  Mascara:String;
begin
  Mascara := '0.';

  if Tipo = 'Q' then
  begin
    for i := 1 to Constantes.TConstantes.DECIMAIS_QUANTIDADE do
      Mascara := Mascara + '0';
  end
  else if Tipo = 'V' then
  begin
    for i := 1 to Constantes.TConstantes.DECIMAIS_VALOR do
      Mascara := Mascara + '0';
  end;

  Result := FormatFloat(Mascara, Valor);
end;

procedure Split(const Delimiter: Char; Input: string; const Strings: TStrings);
begin
  Assert(Assigned(Strings)) ;
  Strings.Clear;
  Strings.Delimiter := Delimiter;
  Strings.DelimitedText := Input;
end;

function DevolveConteudoDelimitado(Delimidador:string;var Linha:string):string;
var
  PosBarra: integer;
begin
  PosBarra:=Pos(Delimidador,Linha);
  Result:= StringReplace((Copy(Linha,1,PosBarra-1)),'[#]','|',[rfReplaceAll]);
  Delete(Linha,1,PosBarra);
end;

function VersaoExe(exe, param : string): String;
type
   PFFI = ^vs_FixedFileInfo;
var
  F : PFFI;
  Handle : Dword;
  Len : Longint;
  Data : Pchar;
  Buffer : Pointer;
  Tamanho : Dword;
  Parquivo: Pchar;

begin

  Parquivo := StrAlloc(Length(Exe) + 1);
  StrPcopy(Parquivo, Exe);
  Len := GetFileVersionInfoSize(Parquivo, Handle);
  Result := '';
  if Len > 0 then
  begin
    Data:=StrAlloc(Len+1);
    if GetFileVersionInfo(Parquivo,Handle,Len,Data) then
    begin
      VerQueryValue(Data, '\',Buffer,Tamanho);
      F := PFFI(Buffer);
      if param = 'N' then
      begin
        Result := Format('%d%d%d%d',
        [HiWord(F^.dwFileVersionMs),
        LoWord(F^.dwFileVersionMs),
        HiWord(F^.dwFileVersionLs),
        Loword(F^.dwFileVersionLs)]);
      end else if param = 'V' then
      begin
        Result := Format('%d.%d.%d.%d',
        [HiWord(F^.dwFileVersionMs),
        LoWord(F^.dwFileVersionMs),
        HiWord(F^.dwFileVersionLs),
        Loword(F^.dwFileVersionLs)]);
      end
    end;
    StrDispose(Data);
  end;
  StrDispose(Parquivo);
end;

procedure ArredondaComponentes(Control: TWinControl);
var
  R: TRect;
  Rgn: HRGN;
begin
  with Control do
  begin
    R := ClientRect;
    rgn := CreateRoundRectRgn(R.Left, R.Top, R.Right, R.Bottom, 30,30) ;
    Perform(EM_GETRECT, 0, lParam(@r)) ;
    InflateRect(r, - 4, - 4) ;
    Perform(EM_SETRECTNP, 0, lParam(@r)) ;
    SetWindowRgn(Handle, rgn, True) ;
    Invalidate;
  end;
end;

function StrIsInteger(const S: string): boolean;
begin
  try
    StrToInt(S);
    Result := true;
  except
    Result := false;
  end;
end;

function padR(const AString : AnsiString; const nLen : Integer;
   const Caracter : AnsiChar) : AnsiString ;
var
  Tam: Integer;
begin
  Tam := Length(AString);
  if Tam < nLen then
    Result := StringOfChar(Caracter, (nLen - Tam)) + AString
  else
    Result := copy(AString,1,nLen) ;
end ;

function TiraPontos(Str: string): string;
var
  i: Integer;
  xStr : String;
begin
 xStr := '';
 for i:=1 to Length(Trim(str)) do
   if (Pos(Copy(str,i,1),'/-.)(,')=0) then xStr := xStr + str[i];

 xStr := StringReplace(xStr,' ','',[rfReplaceAll]);

 Result:=xStr;
end;

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

function mc_ValorExtenso(Valor :Currency) :String;
var
  StrValores, StrPart, StrValor, PartDec :String;
  i, Parcela, Posicao :Integer;
begin
  StrValores := 'trilhão  '+'trilhões '+'bilhão   '+'bilhões  '+
                'milhão   '+'milhões  '+'mil      '+'mil      ';

//Formata o valor corretamente...
  StrValor := CurrToStr(Valor);
  Posicao  := Pos(',',StrValor);

  if Posicao > 0 then
  begin
    PartDec := Copy(StrValor,Posicao+1,2);
    if Length(PartDec) < 2 then
    begin
      StrValor := StrValor+'0';
      PartDec  := PartDec +'0';
    end;
    StrValor := StringReplace(StrValor,',','',[rfReplaceAll]);
  end
  else
  begin
    PartDec  := '00';
    StrValor := StrValor+PartDec;
  end;

  while Length(StrValor) < 17 do StrValor := '0'+StrValor;

//Fim da formatação...
  for i := 1 to 5 do begin
    StrPart := Copy(StrValor,((i-1)*3)+1,3);
    Parcela := StrToInt(StrPart);
    if Parcela = 1 then Posicao := 1 else Posicao := 10;
    if Parcela > 0 then
    begin
      if Length(Result) > 0 then Result := Result+' e ';
      Result := Result+mcx_Centenas(Parcela);
      Result := Result+TrimRight(Copy(StrValores,((i-1)*18)+Posicao,9));
      if not i = 5 then Result := Result+' ';
    end;
  end;

  if Length(Result) > 0 then
    if Int(Valor) = 1 then
      Result := Result+'real '
    else
      Result := Result+' reais ';

  Parcela := StrToInt(PartDec);

  if Parcela > 0 then
  begin
    if Length(Result) > 0 then Result := Result+' e ';
    if Parcela = 1 then
      Result := Result+'um centavo'
    else
      Result := Result+mcx_Dezenas(Parcela)+'centavos';
    end;

  Result := mcx_Ajusta(Result);
end;

function mcx_Ajusta(Valor :String) :String;
begin
  Valor := Trim(StringReplace(Valor,'  ',' ',[rfReplaceAll]));

  if Pos('um mil ',Valor) = 1 then
    Valor := StringReplace(Valor,'um mil','mil',[rfReplaceAll]);

  if (Copy(Valor,Length(Valor)-8,9) = 'tos reais') or
     (Copy(Valor,Length(Valor)-8,9) = 'mil reais') then
  begin
    Result := Valor;
    Exit;
  end;

//Ajusta milhares
  Valor  := StringReplace(Valor,'mil e cento'       ,'mil cento'       ,[rfReplaceAll]);
  Valor  := StringReplace(Valor,'mil e duzentos'    ,'mil duzentos'    ,[rfReplaceAll]);
  Valor  := StringReplace(Valor,'mil e trezentos'   ,'mil trezentos'   ,[rfReplaceAll]);
  Valor  := StringReplace(Valor,'mil e quatrocentos','mil quatrocentos',[rfReplaceAll]);
  Valor  := StringReplace(Valor,'mil e quinhentos'  ,'mil quinhentos'  ,[rfReplaceAll]);
  Valor  := StringReplace(Valor,'mil e seiscentos'  ,'mil seiscentos'  ,[rfReplaceAll]);
  Valor  := StringReplace(Valor,'mil e setecentos'  ,'mil setecentos'  ,[rfReplaceAll]);
  Valor  := StringReplace(Valor,'mil e oitocentos'  ,'mil oitocentos'  ,[rfReplaceAll]);
  Valor  := StringReplace(Valor,'mil e novecentos'  ,'mil novecentos'  ,[rfReplaceAll]);
//Ajusta trilhões, bilhões e milhões
  Valor  := StringReplace(Valor,'ão reais' ,'ão de reais' ,[rfReplaceAll]);
  Valor  := StringReplace(Valor,'ões reais','ões de reais',[rfReplaceAll]);
//Retorna valor
  Result := Valor;
end;

function mcx_Centenas(Valor :Integer) :String;
var
  StrValor, StrDig :String;
begin
  if Valor = 100 then
    Result := 'cem '
  else
  begin
    Result   := '';
    StrDig   := '00'+IntToStr(Valor);
    StrDig   := Copy(StrDig,Length(StrDig)-2,3);
    StrValor := 'cento       '+'duzentos    '+'trezentos   '+
                'quatrocentos'+'quinhentos  '+'seiscentos  '+
                'setecentos  '+'oitocentos  '+'novecentos  ';
    if StrToInt(StrDig[1]) > 0 then
      Result := TrimRight(Copy(StrValor,((StrToInt(StrDig[1])-1)*12)+1,12))+' ';
    if StrToInt(Copy(StrDig,2,2)) > 0 then
    begin
      if Length(Result) > 0 then Result := Result+'e ';
        Result := Result+mcx_Dezenas(StrToInt(Copy(StrDig,2,2)))
    end;
  end;
end;

function mcx_Dezenas(Valor :Integer) :String;
var
  StrValor, StrDig :String;
begin
   if Valor < 20 then
     Result := mcx_Unidades(Valor)
   else
   begin
     Result   := '';
     StrDig   := '00'+IntToStr(Valor);
     StrDig   := Copy(StrDig,Length(StrDig)-1,2);
     StrValor := 'vinte    '+'trinta   '+'quarenta '+'cinquenta'+
                 'sessenta '+'setenta  '+'oitenta  '+'noventa  ';
     Result   := TrimRight(Copy(StrValor,((StrToInt(StrDig[1])-2)*9)+1,9))+' ';
     if StrToInt(StrDig[2]) > 0 then
       Result := Result+'e '+mcx_Unidades(StrToInt(StrDig[2]));
   end;
end;

function mcx_Unidades(Valor :Integer) :String;
const
  StrValor :Array[0..18] of pChar = ('um','dois','três','quatro','cinco','seis',
                                     'sete','oito','nove','dez','onze','doze',
                                     'treze','quatorze','quinze','dezesseis',
                                     'dezessete','dezoito','dezenove');
begin
  Result := StrValor[Valor-1]+' ';
end;

function Codifica(Action, Src: String): String;
Label Fim; //Função para criptografar e descriptografar string's
var
  KeyLen : Integer;
  KeyPos : Integer;
  OffSet : Integer;
  Dest, Key : String;
  SrcPos : Integer;
  SrcAsc : Integer;
  TmpSrcAsc : Integer;
  Range : Integer;
begin
try
  if (Src = '') Then
  begin
    Result:= '';
    Goto Fim;
  end;
  Key := 'YUQL23KL23DF90WI5E1JAS467NMCXXL6JAOAUWWMCL0AOMM4A4VZYW9KHJUI2347EJHJKDF3424SKL K3LAKDJSL9RTIKJ';
  Dest := '';
  KeyLen := Length(Key);
  KeyPos := 0;
  SrcPos := 0;
  SrcAsc := 0;
  Range := 256;
  if (Action = UpperCase('C')) then
  begin
    Randomize;
    OffSet := Random(Range);
    Dest := Format('%1.2x',[OffSet]);
    for SrcPos := 1 to Length(Src) do
    begin
      Application.ProcessMessages;
      SrcAsc := (Ord(Src[SrcPos]) + OffSet) Mod 255;
      if KeyPos < KeyLen then KeyPos := KeyPos + 1 else KeyPos := 1;
      SrcAsc := SrcAsc Xor Ord(Key[KeyPos]);
      Dest := Dest + Format('%1.2x',[SrcAsc]);
      OffSet := SrcAsc;
    end;
  end
  Else if (Action = UpperCase('D')) then
  begin
    OffSet := StrToInt('$'+ copy(Src,1,2));
    SrcPos := 3;
  repeat
    SrcAsc := StrToInt('$'+ copy(Src,SrcPos,2));
    if (KeyPos < KeyLen) Then KeyPos := KeyPos + 1 else KeyPos := 1;
    TmpSrcAsc := SrcAsc Xor Ord(Key[KeyPos]);
    if TmpSrcAsc <= OffSet then TmpSrcAsc := 255 + TmpSrcAsc - OffSet
    else TmpSrcAsc := TmpSrcAsc - OffSet;
    Dest := Dest + Chr(TmpSrcAsc);
    OffSet := SrcAsc;
    SrcPos := SrcPos + 2;
  until (SrcPos >= Length(Src));
  end;
  Result:= Dest;
  Fim:
except
 Src := '';
 Result:= '';
end;
end;

Function ColocaZerosEsquerda(S:String;vT:Integer):String;
Var X : Integer;
    H : String;
begin
  case vT of
    2: H := '00';
    3: H := '000';
    4: H := '0000';
    5: H := '00000';
    6: H := '000000';
    7: H := '0000000';
    8: H := '00000000';
    9: H := '000000000';
    10: H := '0000000000';
    11: H := '00000000000';
    12: H := '000000000000';
    13: H := '0000000000000';
  end;
  X := Length(S);
  Delete(H,1,X);
  Result := H + S;
end;

function Modulo11(Numero: String): String;
var
  i,j,k : Integer;
  Soma : Integer;
  Digito : Integer;
  CNPJ : Boolean;
begin
  Result := '';
  Try
    Soma := 0; k:= 2;
    for i := Length(Numero) downto 1 do
    begin
      Soma := Soma + (StrToInt(Numero[i])*k);
      inc(k);
      if k > 9 then
        k := 2;
    end;
    Digito := 11 - Soma mod 11;
    if Digito >= 10 then
      Digito := 0;
    Result := Result + Chr(Digito + Ord('0'));
  except
    Result := 'X';
  end;
end;

end.
