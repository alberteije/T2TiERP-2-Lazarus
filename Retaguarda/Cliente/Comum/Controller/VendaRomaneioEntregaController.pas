{*******************************************************************************
Title: T2Ti ERP                                                                 
Description: Controller do lado Cliente relacionado à tabela [VENDA_ROMANEIO_ENTREGA] 
                                                                                
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
*******************************************************************************}
unit VendaRomaneioEntregaController;

{$MODE Delphi}

interface

uses
  Classes, Dialogs, SysUtils, DB, LCLIntf, LCLType, LMessages, Forms, Controller,
  VO, ZDataset, VendaRomaneioEntregaVO, Biblioteca;

type
  TVendaRomaneioEntregaController = class(TController)
  private
  public
    class function Consulta(pFiltro: String; pPagina: String): TZQuery;
    class function ConsultaLista(pFiltro: String): TListaVendaRomaneioEntregaVO;
    class function ConsultaObjeto(pFiltro: String): TVendaRomaneioEntregaVO;

    class procedure Insere(pObjeto: TVendaRomaneioEntregaVO);
    class function Altera(pObjeto: TVendaRomaneioEntregaVO): Boolean;

    class function Exclui(pId: Integer): Boolean;
    class function ExcluiVendaVinculada(pId: Integer): Boolean;

  end;

implementation

uses UDataModule, T2TiORM;

var
  ObjetoLocal: TVendaRomaneioEntregaVO;

class function TVendaRomaneioEntregaController.Consulta(pFiltro: String; pPagina: String): TZQuery;
begin
  try
    ObjetoLocal := TVendaRomaneioEntregaVO.Create;
    Result := TT2TiORM.Consultar(ObjetoLocal, pFiltro, pPagina);
  finally
    ObjetoLocal.Free;
  end;
end;

class function TVendaRomaneioEntregaController.ConsultaLista(pFiltro: String): TListaVendaRomaneioEntregaVO;
begin
  try
    ObjetoLocal := TVendaRomaneioEntregaVO.Create;
    Result := TListaVendaRomaneioEntregaVO(TT2TiORM.Consultar(ObjetoLocal, pFiltro, True));
  finally
    ObjetoLocal.Free;
  end;
end;

class function TVendaRomaneioEntregaController.ConsultaObjeto(pFiltro: String): TVendaRomaneioEntregaVO;
begin
  try
    Result := TVendaRomaneioEntregaVO.Create;
    Result := TVendaRomaneioEntregaVO(TT2TiORM.ConsultarUmObjeto(Result, pFiltro, True));
  finally
  end;
end;

class procedure TVendaRomaneioEntregaController.Insere(pObjeto: TVendaRomaneioEntregaVO);
var
  UltimoID: Integer;
  VendasVinculadas: TStringList;
  I: Integer;
begin
  try
    UltimoID := TT2TiORM.Inserir(pObjeto);

    // Vendas Vinculadas
    VendasVinculadas := TStringList.Create;
    Split('|', pObjeto.VendasVinculadas, VendasVinculadas);
    for I := 1 to VendasVinculadas.Count - 1 do
    begin
      TT2TiORM.ComandoSQL('update VENDA_CABECALHO set ID_VENDA_ROMANEIO_ENTREGA=' + IntToStr(UltimoID) + ' where ID= ' + VendasVinculadas[I]);
    end;

    Consulta('ID = ' + IntToStr(UltimoID), '0');
  finally
  end;
end;

class function TVendaRomaneioEntregaController.Altera(pObjeto: TVendaRomaneioEntregaVO): Boolean;
var
  VendasVinculadas: TStringList;
  I: Integer;
begin
  try
    Result := TT2TiORM.Alterar(pObjeto);

    // Vendas Vinculadas
    VendasVinculadas := TStringList.Create;
    Split('|', pObjeto.VendasVinculadas, VendasVinculadas);
    for I := 0 to VendasVinculadas.Count - 1 do
    begin
      TT2TiORM.ComandoSQL('update VENDA_CABECALHO set ID_VENDA_ROMANEIO_ENTREGA=' + IntToStr(pObjeto.Id) + ' where ID= ' + VendasVinculadas[I]);
    end;

  finally
  end;
end;

class function TVendaRomaneioEntregaController.Exclui(pId: Integer): Boolean;
var
  ObjetoLocal: TVendaRomaneioEntregaVO;
begin
  try
    ObjetoLocal := TVendaRomaneioEntregaVO.Create;
    ObjetoLocal.Id := pId;
    Result := TT2TiORM.Excluir(ObjetoLocal);
  finally
    FreeAndNil(ObjetoLocal)
  end;
end;

class function TVendaRomaneioEntregaController.ExcluiVendaVinculada(pId: Integer): Boolean;
begin
  try
    TT2TiORM.ComandoSQL('update VENDA_CABECALHO set ID_VENDA_ROMANEIO_ENTREGA=null where ID= ' + IntToStr(pId));
    Result := True;
  except
  end;
end;

initialization
  Classes.RegisterClass(TVendaRomaneioEntregaController);

finalization
  Classes.UnRegisterClass(TVendaRomaneioEntregaController);

end.

