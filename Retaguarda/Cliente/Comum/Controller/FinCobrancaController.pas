{*******************************************************************************
Title: T2Ti ERP                                                                 
Description: Controller do lado Cliente relacionado à tabela [FIN_COBRANCA] 
                                                                                
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
unit FinCobrancaController;

{$MODE Delphi}

interface

uses
  Classes, Dialogs, SysUtils, DB, LCLIntf, LCLType, LMessages, Forms, Controller,
  VO, ZDataset, FinCobrancaVO, FinCobrancaParcelaReceberVO;

type
  TFinCobrancaController = class(TController)
  private
  public
    class function Consulta(pFiltro: String; pPagina: String): TZQuery;
    class function ConsultaLista(pFiltro: String): TListaFinCobrancaVO;
    class function ConsultaObjeto(pFiltro: String): TFinCobrancaVO;

    class procedure Insere(pObjeto: TFinCobrancaVO);
    class function Altera(pObjeto: TFinCobrancaVO): Boolean;

    class function Exclui(pId: Integer): Boolean;

  end;

implementation

uses UDataModule, T2TiORM;

var
  ObjetoLocal: TFinCobrancaVO;

class function TFinCobrancaController.Consulta(pFiltro: String; pPagina: String): TZQuery;
begin
  try
    ObjetoLocal := TFinCobrancaVO.Create;
    Result := TT2TiORM.Consultar(ObjetoLocal, pFiltro, pPagina);
  finally
    ObjetoLocal.Free;
  end;
end;

class function TFinCobrancaController.ConsultaLista(pFiltro: String): TListaFinCobrancaVO;
begin
  try
    ObjetoLocal := TFinCobrancaVO.Create;
    Result := TListaFinCobrancaVO(TT2TiORM.Consultar(ObjetoLocal, pFiltro, True));
  finally
    ObjetoLocal.Free;
  end;
end;

class function TFinCobrancaController.ConsultaObjeto(pFiltro: String): TFinCobrancaVO;
begin
  try
    Result := TFinCobrancaVO.Create;
    Result := TFinCobrancaVO(TT2TiORM.ConsultarUmObjeto(Result, pFiltro, True));
    Result.ClienteNome := Result.ClienteVO.Nome;
  finally
  end;
end;

class procedure TFinCobrancaController.Insere(pObjeto: TFinCobrancaVO);
var
  UltimoID: Integer;
  ParcelaReceber: TFinCobrancaParcelaReceberVO;
begin
  try
    UltimoID := TT2TiORM.Inserir(pObjeto);

    (*
    /// EXERCICIO: Corrija o procedimento

    // Parcela Receber
    ParcelaReceberEnumerator := pObjeto.ListaCobrancaParcelaReceberVO.GetEnumerator;
    try
      with ParcelaReceberEnumerator do
      begin
        while MoveNext do
        begin
          ParcelaReceber := Current;
          ParcelaReceber.IdFinCobranca := UltimoID;
          TT2TiORM.Inserir(ParcelaReceber);
        end;
      end;
    finally
      ParcelaReceberEnumerator.Free;
    end;
    *)

    Consulta('ID = ' + IntToStr(UltimoID), '0');
  finally
  end;
end;

class function TFinCobrancaController.Altera(pObjeto: TFinCobrancaVO): Boolean;
begin
  try
    Result := TT2TiORM.Alterar(pObjeto);

    // Parcela Receber
    (*
    /// EXERCICIO: Corrija o procedimento

    try
      ParcelaReceberEnumerator := pObjeto.ListaCobrancaParcelaReceberVO.GetEnumerator;
      with ParcelaReceberEnumerator do
      begin
        while MoveNext do
        begin
          if Current.Id > 0 then
            Result := TT2TiORM.Alterar(Current)
          else
          begin
            Current.IdFinCobranca := pObjeto.Id;
            Result := TT2TiORM.Inserir(Current) > 0;
          end;
        end;
      end;
    finally
      FreeAndNil(ParcelaReceberEnumerator);
    end;
     *)

  finally
  end;
end;

class function TFinCobrancaController.Exclui(pId: Integer): Boolean;
var
  ObjetoLocal: TFinCobrancaVO;
begin
  try
    ObjetoLocal := TFinCobrancaVO.Create;
    ObjetoLocal.Id := pId;
    Result := TT2TiORM.Excluir(ObjetoLocal);
  finally
    FreeAndNil(ObjetoLocal)
  end;
end;

initialization
  Classes.RegisterClass(TFinCobrancaController);

finalization
  Classes.UnRegisterClass(TFinCobrancaController);

end.

