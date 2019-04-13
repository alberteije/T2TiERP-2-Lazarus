{*******************************************************************************
Title: T2Ti ERP                                                                 
Description: Controller do lado Cliente relacionado à tabela [VENDA_CABECALHO] 
                                                                                
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
unit VendaCabecalhoController;

{$MODE Delphi}

interface

uses
  Classes, Dialogs, SysUtils, DB, LCLIntf, LCLType, LMessages, Forms, Controller,
  VO, ZDataset, VendaCabecalhoVO;

type
  TVendaCabecalhoController = class(TController)
  private
  public
    class function Consulta(pFiltro: String; pPagina: String): TZQuery;
    class function ConsultaLista(pFiltro: String): TListaVendaCabecalhoVO;
    class function ConsultaObjeto(pFiltro: String): TVendaCabecalhoVO;

    class procedure Insere(pObjeto: TVendaCabecalhoVO);
    class function Altera(pObjeto: TVendaCabecalhoVO): Boolean;

    class function Exclui(pId: Integer): Boolean;

  end;

implementation

uses UDataModule, T2TiORM, VendaDetalheVO, VendaComissaoVO;

var
  ObjetoLocal: TVendaCabecalhoVO;

class function TVendaCabecalhoController.Consulta(pFiltro: String; pPagina: String): TZQuery;
begin
  try
    ObjetoLocal := TVendaCabecalhoVO.Create;
    Result := TT2TiORM.Consultar(ObjetoLocal, pFiltro, pPagina);
  finally
    ObjetoLocal.Free;
  end;
end;

class function TVendaCabecalhoController.ConsultaLista(pFiltro: String): TListaVendaCabecalhoVO;
begin
  try
    ObjetoLocal := TVendaCabecalhoVO.Create;
    Result := TListaVendaCabecalhoVO(TT2TiORM.Consultar(ObjetoLocal, pFiltro, True));
  finally
    ObjetoLocal.Free;
  end;
end;

class function TVendaCabecalhoController.ConsultaObjeto(pFiltro: String): TVendaCabecalhoVO;
begin
  try
    Result := TVendaCabecalhoVO.Create;
    Result := TVendaCabecalhoVO(TT2TiORM.ConsultarUmObjeto(Result, pFiltro, True));

    Filtro := 'ID_VENDA_CABECALHO = ' + IntToStr(Result.Id);

    // Objetos Vinculados

    // Listas
    Result.ListaVendaDetalheVO := TListaVendaDetalheVO(TT2TiORM.Consultar(TVendaDetalheVO.Create, Filtro, True));

  finally
  end;
end;

class procedure TVendaCabecalhoController.Insere(pObjeto: TVendaCabecalhoVO);
var
  UltimoID: Integer;
  VendaComissaoVO: TVendaComissaoVO;
  Current: TVendaDetalheVO;
  I: Integer;
begin
  try
    UltimoID := TT2TiORM.Inserir(pObjeto);

   // Comissão
    VendaComissaoVO := TVendaComissaoVO.Create;
    VendaComissaoVO.IdVendaCabecalho := UltimoID;
    VendaComissaoVO.IdVendedor := pObjeto.IdVendedor;
    VendaComissaoVO.ValorVenda := pObjeto.ValorSubtotal - pObjeto.ValorDesconto;
    VendaComissaoVO.TipoContabil := 'C';
    VendaComissaoVO.ValorComissao := pObjeto.ValorComissao;
    VendaComissaoVO.Situacao := 'A';
    VendaComissaoVO.DataLancamento := now;
    TT2TiORM.Inserir(VendaComissaoVO);

    // Lista Venda Detalhe
    for I := 0 to pObjeto.ListaVendaDetalheVO.Count - 1 do
    begin
      Current := pObjeto.ListaVendaDetalheVO[I];

      Current.IdVendaCabecalho := UltimoID;
      TT2TiORM.Inserir(Current);
    end;

    Consulta('ID = ' + IntToStr(UltimoID), '0');
  finally
  end;
end;

class function TVendaCabecalhoController.Altera(pObjeto: TVendaCabecalhoVO): Boolean;
var
  Current: TVendaDetalheVO;
  I: Integer;
begin
  try
    Result := TT2TiORM.Alterar(pObjeto);

    // Comissão
    pObjeto.VendaComissaoVO.IdVendaCabecalho := pObjeto.Id;
    pObjeto.VendaComissaoVO.IdVendedor := pObjeto.IdVendedor;
    pObjeto.VendaComissaoVO.ValorVenda := pObjeto.ValorSubtotal - pObjeto.ValorDesconto;
    pObjeto.VendaComissaoVO.TipoContabil := 'C';
    pObjeto.VendaComissaoVO.ValorComissao := pObjeto.ValorComissao;
    pObjeto.VendaComissaoVO.Situacao := 'A';
    pObjeto.VendaComissaoVO.DataLancamento := now;
    if pObjeto.VendaComissaoVO.Id > 0 then
      TT2TiORM.Alterar(pObjeto.VendaComissaoVO)
    else
      TT2TiORM.Inserir(pObjeto.VendaComissaoVO);

    // Lista Orçamento Pedido Detalhe
    for I := 0 to pObjeto.ListaVendaDetalheVO.Count - 1 do
    begin
      Current := pObjeto.ListaVendaDetalheVO[I];
      if Current.Id > 0 then
        Result := TT2TiORM.Alterar(Current)
      else
      begin
        Current.IdVendaCabecalho := pObjeto.Id;
        Result := TT2TiORM.Inserir(Current) > 0;
      end;
    end;

  finally
  end;
end;

class function TVendaCabecalhoController.Exclui(pId: Integer): Boolean;
var
  ObjetoLocal: TVendaCabecalhoVO;
begin
  try
    ObjetoLocal := TVendaCabecalhoVO.Create;
    ObjetoLocal.Id := pId;
    Result := TT2TiORM.Excluir(ObjetoLocal);
  finally
    FreeAndNil(ObjetoLocal)
  end;
end;

initialization
  Classes.RegisterClass(TVendaCabecalhoController);

finalization
  Classes.UnRegisterClass(TVendaCabecalhoController);

end.

