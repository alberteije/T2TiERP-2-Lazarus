{*******************************************************************************
Title: T2Ti ERP                                                                 
Description: Controller do lado Cliente relacionado à tabela [VIEW_TRIBUTACAO_ICMS_CUSTOM] 
                                                                                
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
           t2ti.com@gmail.com

@author Albert Eije (t2ti.com@gmail.com)
@version 2.0
*******************************************************************************}
unit ViewTributacaoIcmsCustomController;

{$MODE Delphi}

interface

uses
  Classes, Dialogs, SysUtils, DB, LCLIntf, LCLType, LMessages, Forms, Controller,
  ViewTributacaoIcmsCustomVO, Generics.Collections;


type
  TViewTributacaoIcmsCustomController = class(TController)
  private
  public
    class function Consulta(pFiltro: String; pPagina: String): TZQuery;
    class function ConsultaLista(pFiltro: String): TListaViewTributacaoIcmsCustomVO;
    class function ConsultaObjeto(pFiltro: String): TViewTributacaoIcmsCustomVO;

  end;

implementation

uses UDataModule, T2TiORM;

var
  ObjetoLocal: TViewTributacaoIcmsCustomVO;

class function TViewTributacaoIcmsCustomController.Consulta(pFiltro: String; pPagina: String): TZQuery;
begin
  try
    ObjetoLocal := TViewTributacaoIcmsCustomVO.Create;
    Result := TT2TiORM.Consultar(ObjetoLocal, pFiltro, pPagina);
  finally
    ObjetoLocal.Free;
  end;
end;

class function TViewTributacaoIcmsCustomController.ConsultaLista(pFiltro: String): TListaViewTributacaoIcmsCustomVO;
begin
  try
    ObjetoLocal := TViewTributacaoIcmsCustomVO.Create;
    Result := TListaViewTributacaoIcmsCustomVO(TT2TiORM.Consultar(ObjetoLocal, pFiltro, True));
  finally
    ObjetoLocal.Free;
  end;
end;

class function TViewTributacaoIcmsCustomController.ConsultaObjeto(pFiltro: String): TViewTributacaoIcmsCustomVO;
begin
  try
    Result := TViewTributacaoIcmsCustomVO.Create;
    Result := TViewTributacaoIcmsCustomVO(TT2TiORM.ConsultarUmObjeto(Result, pFiltro, True));
  finally
  end;
end;

initialization
  Classes.RegisterClass(TViewTributacaoIcmsCustomController);

finalization
  Classes.UnRegisterClass(TViewTributacaoIcmsCustomController);

end.

