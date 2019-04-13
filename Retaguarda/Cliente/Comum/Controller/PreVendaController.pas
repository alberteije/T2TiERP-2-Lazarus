{ *******************************************************************************
Title: T2Ti ERP
Description: Controller relacionado às tabelas [PRE_VENDA_CABECALHO e PRE_VENDA_DETALHE]

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
t2ti.com@gmail.com</p>

@author Albert Eije (t2ti.com@gmail.com)
@version 2.0
******************************************************************************* }
unit PreVendaController;

{$MODE Delphi}

interface

uses
  Classes, Dialogs, SysUtils, DB, LCLIntf, LCLType, LMessages, Forms, Controller, Atributos,
  VO, PreVendaCabecalhoVO, PreVendaDetalheVO, Generics.Collections, Biblioteca;

type
  TPreVendaController = class(TController)
  private
  public
    class function Consulta(pFiltro: String; pPagina: String): TZQuery;
    class function ConsultaLista(pFiltro: String): TListaPreVendaCabecalhoVO;
    class function ConsultaObjeto(pFiltro: String): TPreVendaCabecalhoVO;

    class procedure Insere(pObjeto: TPreVendaCabecalhoVO);
    class function Altera(pObjeto: TPreVendaCabecalhoVO): Boolean;

    class function Exclui(pId: Integer): Boolean;

  end;

implementation

uses T2TiORM;

class function TPreVendaController.Consulta(pFiltro: String; pPagina: String): TZQuery;
begin
  try
    ObjetoLocal := TPreVendaVO.Create;
    Result := TT2TiORM.Consultar(ObjetoLocal, pFiltro, pPagina);
  finally
    ObjetoLocal.Free;
  end;
end;

class function TPreVendaController.ConsultaLista(pFiltro: String): TListaPreVendaCabecalhoVO;
begin
  try
    ObjetoLocal := TPreVendaVO.Create;
    Result := TListaPreVendaVO(TT2TiORM.Consultar(ObjetoLocal, pFiltro, True));
  finally
    ObjetoLocal.Free;
  end;
end;

class function TPreVendaController.ConsultaObjeto(pFiltro: String): TPreVendaCabecalhoVO;
begin
  try
    Result := TPreVendaVO.Create;
    Result := TPreVendaVO(TT2TiORM.ConsultarUmObjeto(Result, pFiltro, True));
  finally
  end;
end;

class procedure TPreVendaController.Insere(pObjeto: TPreVendaCabecalhoVO);
var
  UltimoID: Integer;
begin
  try
    UltimoID := TT2TiORM.Inserir(pObjeto);

    // Detalhes
    try
      PreVendaDetalheEnumerator := pObjeto.ListaPreVendaDetalheVO.GetEnumerator;
      with PreVendaDetalheEnumerator do
      begin
        while MoveNext do
        begin
          Current.IdPreVendaCabecalho := UltimoID;
          TT2TiORM.Inserir(Current);
        end;
      end;
    finally
      FreeAndNil(PreVendaDetalheEnumerator);
    end;

    Consulta('ID = ' + IntToStr(UltimoID), '0');
  finally
  end;
end;

class function TPreVendaController.Altera(pObjeto: TPreVendaCabecalhoVO): Boolean;
var
begin
  try
    Result := TT2TiORM.Alterar(pObjeto);

    // Detalhes
    try
      PreVendaDetalheEnumerator := pObjeto.ListaPreVendaDetalheVO.GetEnumerator;
      with PreVendaDetalheEnumerator do
      begin
        while MoveNext do
        begin
          if Current.Id > 0 then
            Result := TT2TiORM.Alterar(Current)
          else
          begin
            Current.IdPreVendaCabecalho := pObjeto.Id;
            Result := TT2TiORM.Inserir(Current) > 0;
          end;
        end;
      end;
    finally
      FreeAndNil(PreVendaDetalheEnumerator);
    end;

  finally
  end;
end;

class function TPreVendaController.Exclui(pId: Integer): Boolean;
begin
  try
    raise Exception.Create('Não é permitido excluir uma PreVenda.');
  finally
  end;
end;

initialization
  Classes.RegisterClass(TPreVendaController);

finalization
  Classes.UnRegisterClass(TPreVendaController);

end.

