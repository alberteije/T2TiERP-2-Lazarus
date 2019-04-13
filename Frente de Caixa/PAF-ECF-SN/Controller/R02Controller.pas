{*******************************************************************************
Title: T2Ti ERP                                                                 
Description: Controller relacionado à tabela [R02] 
                                                                                
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

Albert Eije (T2Ti.COM)
@version 2.0
*******************************************************************************}
unit R02Controller;

interface

uses
  Classes, SysUtils, Windows, Forms, Controller, md5,
  VO, R02VO, R03VO, Biblioteca;


type
  TR02Controller = class(TController)
  private
  public
    class function ConsultaLista(pFiltro: String): TListaR02VO;
    class function ConsultaObjeto(pFiltro: String): TR02VO;
    class procedure Insere(pObjeto: TR02VO);
    class function Altera(pObjeto: TR02VO): Boolean;
    class function Exclui(pId: Integer): Boolean;
  end;

implementation

uses T2TiORM;

var
  ObjetoLocal: TR02VO;

class function TR02Controller.ConsultaLista(pFiltro: String): TListaR02VO;
begin
  try
    ObjetoLocal := TR02VO.Create;
    Result := TListaR02VO(TT2TiORM.Consultar(ObjetoLocal, pFiltro, True));
  finally
    ObjetoLocal.Free;
  end;
end;

class function TR02Controller.ConsultaObjeto(pFiltro: String): TR02VO;
var
  Filtro: String;
begin
  try
    Result := TR02VO.Create;
    Result := TR02VO(TT2TiORM.ConsultarUmObjeto(Result, pFiltro, True));

    if Assigned(Result) then
    begin
      //Exercício: crie o método para popular esses objetos automaticamente no T2TiORM
      Filtro := 'ID_R02 = ' + IntToStr(Result.Id);
      Result.ListaR03VO := TListaR03VO(TT2TiORM.Consultar(TR03VO.Create, Filtro, True));
    end;
finally
  end;
end;

class procedure TR02Controller.Insere(pObjeto: TR02VO);
var
  I, UltimoID: Integer;
begin
  try
    FormatSettings.DecimalSeparator := '.';
    pObjeto.HashRegistro := '0';
    pObjeto.HashRegistro := MD5Print(MD5String(pObjeto.ToJSONString));
    UltimoID := TT2TiORM.Inserir(pObjeto);

    // Detalhes
    for I := 0 to pObjeto.ListaR03VO.Count - 1 do
    begin
      pObjeto.ListaR03VO[I].SerieEcf := Sessao.Configuracao.EcfImpressoraVO.Serie;
      pObjeto.ListaR03VO[I].IdR02 := UltimoID;

      pObjeto.ListaR03VO[I].HashRegistro := '0';
      pObjeto.ListaR03VO[I].HashRegistro := MD5Print(MD5String(pObjeto.ListaR03VO[I].ToJSONString));
      TT2TiORM.Inserir(pObjeto.ListaR03VO[I]);
    end;

  finally
    FormatSettings.DecimalSeparator := ',';
  end;
end;

class function TR02Controller.Altera(pObjeto: TR02VO): Boolean;
begin
  try
    Result := TT2TiORM.Alterar(pObjeto);
  finally
  end;
end;

class function TR02Controller.Exclui(pId: Integer): Boolean;
begin
  try
    ObjetoLocal := TR02VO.Create;
    ObjetoLocal.Id := pId;
    Result := TT2TiORM.Excluir(ObjetoLocal);
  finally
    FreeAndNil(ObjetoLocal);
  end;
end;

end.
