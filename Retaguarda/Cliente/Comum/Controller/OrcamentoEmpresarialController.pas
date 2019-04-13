{*******************************************************************************
Title: T2Ti ERP                                                                 
Description: Controller do lado Cliente relacionado à tabela [ORCAMENTO_EMPRESARIAL] 
                                                                                
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
unit OrcamentoEmpresarialController;

{$MODE Delphi}

interface

uses
  Classes, Dialogs, SysUtils, DB, LCLIntf, LCLType, LMessages, Forms, Controller,
  VO, ZDataset, OrcamentoEmpresarialVO, OrcamentoDetalheVO;

type
  TOrcamentoEmpresarialController = class(TController)
  private
  public
    class function Consulta(pFiltro: String; pPagina: String): TZQuery;
    class function ConsultaLista(pFiltro: String): TListaOrcamentoEmpresarialVO;
    class function ConsultaObjeto(pFiltro: String): TOrcamentoEmpresarialVO;

    class procedure Insere(pObjeto: TOrcamentoEmpresarialVO);
    class function Altera(pObjeto: TOrcamentoEmpresarialVO): Boolean;

    class function Exclui(pId: Integer): Boolean;

  end;

implementation

uses UDataModule, T2TiORM, OrcamentoPeriodoVO;

var
  ObjetoLocal: TOrcamentoEmpresarialVO;

class function TOrcamentoEmpresarialController.Consulta(pFiltro: String; pPagina: String): TZQuery;
begin
  try
    ObjetoLocal := TOrcamentoEmpresarialVO.Create;
    Result := TT2TiORM.Consultar(ObjetoLocal, pFiltro, pPagina);
  finally
    ObjetoLocal.Free;
  end;
end;

class function TOrcamentoEmpresarialController.ConsultaLista(pFiltro: String): TListaOrcamentoEmpresarialVO;
begin
  try
    ObjetoLocal := TOrcamentoEmpresarialVO.Create;
    Result := TListaOrcamentoEmpresarialVO(TT2TiORM.Consultar(ObjetoLocal, pFiltro, True));
  finally
    ObjetoLocal.Free;
  end;
end;

class function TOrcamentoEmpresarialController.ConsultaObjeto(pFiltro: String): TOrcamentoEmpresarialVO;
var
  Filtro: String;
begin
  try
    Result := TOrcamentoEmpresarialVO.Create;
    Result := TOrcamentoEmpresarialVO(TT2TiORM.ConsultarUmObjeto(Result, pFiltro, True));

    // Objetos Vinculados
    Result.OrcamentoPeriodoVO := TOrcamentoPeriodoVO(TT2TiORM.ConsultarUmObjeto(Result.OrcamentoPeriodoVO, 'ID='+IntToStr(Result.IdOrcamentoPeriodo), True));

    Filtro := 'ID_ORCAMENTO_EMPRESARIAL = ' + IntToStr(Result.Id);
    Result.ListaOrcamentoDetalheVO := TListaOrcamentoDetalheVO(TT2TiORM.Consultar(TOrcamentoDetalheVO.Create, Filtro, True));


    Result.OrcamentoPeriodoNome := Result.OrcamentoPeriodoVO.Nome;
    Result.OrcamentoPeriodoCodigo := Result.OrcamentoPeriodoVO.Periodo;
  finally
  end;
end;

class procedure TOrcamentoEmpresarialController.Insere(pObjeto: TOrcamentoEmpresarialVO);
var
  UltimoID, i: Integer;
  Current: TOrcamentoDetalheVO;
begin
  try
    UltimoID := TT2TiORM.Inserir(pObjeto);

    // Detalhe do orçamento
    for i := 0 to pObjeto.ListaOrcamentoDetalheVO.Count -1 do
    begin
      Current := pObjeto.ListaOrcamentoDetalheVO[i];
      Current.IdOrcamentoEmpresarial := UltimoID;
      TT2TiORM.Inserir(Current);
    end;

    Consulta('ID = ' + IntToStr(UltimoID), '0');
  finally
  end;
end;

class function TOrcamentoEmpresarialController.Altera(pObjeto: TOrcamentoEmpresarialVO): Boolean;
var
  UltimoID, i: Integer;
  Current: TOrcamentoDetalheVO;
begin
  try
    Result := TT2TiORM.Alterar(pObjeto);

    // Detalhe do orçamento
    for i := 0 to pObjeto.ListaOrcamentoDetalheVO.Count -1 do
    begin
      Current := pObjeto.ListaOrcamentoDetalheVO[i];

      if Current.Id > 0 then
        Result := TT2TiORM.Alterar(Current)
      else
      begin
        Current.IdOrcamentoEmpresarial := pObjeto.Id;
        Result := TT2TiORM.Inserir(Current) > 0;
      end;
    end;
  finally
  end;
end;

class function TOrcamentoEmpresarialController.Exclui(pId: Integer): Boolean;
var
  ObjetoLocal: TOrcamentoEmpresarialVO;
begin
  try
    ObjetoLocal := TOrcamentoEmpresarialVO.Create;
    ObjetoLocal.Id := pId;
    Result := TT2TiORM.Excluir(ObjetoLocal);
  finally
    FreeAndNil(ObjetoLocal)
  end;
end;

initialization
  Classes.RegisterClass(TOrcamentoEmpresarialController);

finalization
  Classes.UnRegisterClass(TOrcamentoEmpresarialController);

end.

