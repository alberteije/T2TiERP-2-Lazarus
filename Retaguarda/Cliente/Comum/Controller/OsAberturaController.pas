{*******************************************************************************
Title: T2Ti ERP                                                                 
Description: Controller do lado Cliente relacionado à tabela [OS_ABERTURA] 
                                                                                
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
unit OsAberturaController;

interface

uses
  Classes, Dialogs, SysUtils, DB, LCLIntf, LCLType, LMessages, Forms, Controller,
  VO, ZDataset, OsAberturaVO;

type
  TOsAberturaController = class(TController)
  private
  public
    class function Consulta(pFiltro: String; pPagina: String): TZQuery;
    class function ConsultaLista(pFiltro: String): TListaOsAberturaVO;
    class function ConsultaObjeto(pFiltro: String): TOsAberturaVO;

    class procedure Insere(pObjeto: TOsAberturaVO);
    class function Altera(pObjeto: TOsAberturaVO): Boolean;

    class function Exclui(pId: Integer): Boolean;

  end;

implementation

uses UDataModule, T2TiORM, OsProdutoServicoVO, OsAberturaEquipamentoVO, OsEvolucaoVO;

var
  ObjetoLocal: TOsAberturaVO;

class function TOsAberturaController.Consulta(pFiltro: String; pPagina: String): TZQuery;
begin
  try
    ObjetoLocal := TOsAberturaVO.Create;
    Result := TT2TiORM.Consultar(ObjetoLocal, pFiltro, pPagina);
  finally
    ObjetoLocal.Free;
  end;
end;

class function TOsAberturaController.ConsultaLista(pFiltro: String): TListaOsAberturaVO;
begin
  try
    ObjetoLocal := TOsAberturaVO.Create;
    Result := TListaOsAberturaVO(TT2TiORM.Consultar(ObjetoLocal, pFiltro, True));
  finally
    ObjetoLocal.Free;
  end;
end;

class function TOsAberturaController.ConsultaObjeto(pFiltro: String): TOsAberturaVO;
begin
  try
    Result := TOsAberturaVO.Create;
    Result := TOsAberturaVO(TT2TiORM.ConsultarUmObjeto(Result, pFiltro, True));
  finally
  end;
end;

class procedure TOsAberturaController.Insere(pObjeto: TOsAberturaVO);
var
  UltimoID: Integer;
  ProdutoServicoVO: TOsProdutoServicoVO;
  EquipamentoVO: TOsAberturaEquipamentoVO;
  EvolucaoVO: TOsEvolucaoVO;
begin
  try
    UltimoID := TT2TiORM.Inserir(pObjeto);

    // Produtos
    ProdutoServicoEnumerator := pObjeto.ListaOsProdutoServicoVO.GetEnumerator;
    try
      with ProdutoServicoEnumerator do
      begin
        while MoveNext do
        begin
          ProdutoServicoVO := Current;
          ProdutoServicoVO.IdOsAbertura := UltimoID;
          TT2TiORM.Inserir(ProdutoServicoVO);
        end;
      end;
    finally
      ProdutoServicoEnumerator.Free;
    end;

    // Equipamentos
    EquipamentoEnumerator := pObjeto.ListaOsEquipamentoVO.GetEnumerator;
    try
      with EquipamentoEnumerator do
      begin
        while MoveNext do
        begin
          EquipamentoVO := Current;
          EquipamentoVO.IdOsAbertura := UltimoID;
          TT2TiORM.Inserir(EquipamentoVO);
        end;
      end;
    finally
      EquipamentoEnumerator.Free;
    end;

    // Evoluções
    EvolucaoEnumerator := pObjeto.ListaOsEvolucaoVO.GetEnumerator;
    try
      with EvolucaoEnumerator do
      begin
        while MoveNext do
        begin
          EvolucaoVO := Current;
          EvolucaoVO.IdOsAbertura := UltimoID;
          TT2TiORM.Inserir(EvolucaoVO);
        end;
      end;
    finally
      EvolucaoEnumerator.Free;
    end;

    Consulta('ID = ' + IntToStr(UltimoID), '0');
  finally
  end;
end;

class function TOsAberturaController.Altera(pObjeto: TOsAberturaVO): Boolean;
var
begin
  try
    Result := TT2TiORM.Alterar(pObjeto);

    // Produtos
    try
      ProdutoServicoEnumerator := pObjeto.ListaOsProdutoServicoVO.GetEnumerator;
      with ProdutoServicoEnumerator do
      begin
        while MoveNext do
        begin
          if Current.Id > 0 then
            Result := TT2TiORM.Alterar(Current)
          else
          begin
            Current.IdOsAbertura := pObjeto.Id;
            Result := TT2TiORM.Inserir(Current) > 0;
          end;
        end;
      end;
    finally
      ProdutoServicoEnumerator.Free;
    end;

    // Equipamentos
    EquipamentoEnumerator := pObjeto.ListaOsEquipamentoVO.GetEnumerator;
    try
      with EquipamentoEnumerator do
      begin
        while MoveNext do
        begin
          if Current.Id > 0 then
            Result := TT2TiORM.Alterar(Current)
          else
          begin
            Current.IdOsAbertura := pObjeto.Id;
            Result := TT2TiORM.Inserir(Current) > 0;
          end;
        end;
      end;
    finally
      EquipamentoEnumerator.Free;
    end;

    // Evoluções
    EvolucaoEnumerator := pObjeto.ListaOsEvolucaoVO.GetEnumerator;
    try
      with EvolucaoEnumerator do
      begin
        while MoveNext do
        begin
          if Current.Id > 0 then
            Result := TT2TiORM.Alterar(Current)
          else
          begin
            Current.IdOsAbertura := pObjeto.Id;
            Result := TT2TiORM.Inserir(Current) > 0;
          end;
        end;
      end;
    finally
      EvolucaoEnumerator.Free;
    end;
  finally
  end;
end;

class function TOsAberturaController.Exclui(pId: Integer): Boolean;
var
  ObjetoLocal: TOsAberturaVO;
begin
  try
    ObjetoLocal := TOsAberturaVO.Create;
    ObjetoLocal.Id := pId;
    Result := TT2TiORM.Excluir(ObjetoLocal);
  finally
    FreeAndNil(ObjetoLocal)
  end;
end;

begin
  Result := FDataSet;
end;

begin
  FDataSet := pDataSet;
end;

begin
  try
  finally
    FreeAndNil(pListaObjetos);
  end;
end;

initialization
  Classes.RegisterClass(TOsAberturaController);

finalization
  Classes.UnRegisterClass(TOsAberturaController);

end.

