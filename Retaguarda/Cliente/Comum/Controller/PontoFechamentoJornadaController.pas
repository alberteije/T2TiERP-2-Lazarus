{*******************************************************************************
Title: T2Ti ERP                                                                 
Description: Controller do lado Cliente relacionado à tabela [PONTO_FECHAMENTO_JORNADA] 
                                                                                
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
unit PontoFechamentoJornadaController;

{$MODE Delphi}

interface

uses
  Classes, Dialogs, SysUtils, DB, LCLIntf, LCLType, LMessages, Forms, Controller,
  VO, ZDataset, PontoFechamentoJornadaVO;

type
  TPontoFechamentoJornadaController = class(TController)
  private
  public
    class function Consulta(pFiltro: String; pPagina: String): TZQuery;
    class function ConsultaLista(pFiltro: String): TListaPontoFechamentoJornadaVO;
    class function ConsultaObjeto(pFiltro: String): TPontoFechamentoJornadaVO;

    class procedure Insere(pObjeto: TPontoFechamentoJornadaVO);
    class function Altera(pObjeto: TPontoFechamentoJornadaVO): Boolean;

    class function Exclui(pId: Integer): Boolean;

  end;

implementation

uses UDataModule, T2TiORM;

var
  ObjetoLocal: TPontoFechamentoJornadaVO;

class function TPontoFechamentoJornadaController.Consulta(pFiltro: String; pPagina: String): TZQuery;
var
  ConsultaSQL: String;
begin
  try
    /// EXERCICIO: Crie uma view no banco de dados para substituir a consulta abaixo.
    ConsultaSQL :=
      'SELECT PFJ.*, C.PIS_NUMERO, P.NOME AS NOME_COLABORADOR, '+
      'PCJ.CODIGO AS CODIGO_CLASSIFICACAO, PCJ.NOME AS NOME_CLASSIFICACAO '+
      'FROM PONTO_FECHAMENTO_JORNADA PFJ '+
      'INNER JOIN COLABORADOR C ON (PFJ.ID_COLABORADOR = C.ID) '+
      'INNER JOIN PESSOA P ON (C.ID_PESSOA = P.ID) '+
      'INNER JOIN PONTO_CLASSIFICACAO_JORNADA PCJ ON (PFJ.ID_PONTO_CLASSIFICACAO_JORNADA = PCJ.ID)';

    ObjetoLocal := TPontoFechamentoJornadaVO.Create;
    Result := TT2TiORM.Consultar(ObjetoLocal, pFiltro, pPagina);
  finally
    ObjetoLocal.Free;
  end;
end;

class function TPontoFechamentoJornadaController.ConsultaLista(pFiltro: String): TListaPontoFechamentoJornadaVO;
begin
  try
    ObjetoLocal := TPontoFechamentoJornadaVO.Create;
    Result := TListaPontoFechamentoJornadaVO(TT2TiORM.Consultar(ObjetoLocal, pFiltro, True));
  finally
    ObjetoLocal.Free;
  end;
end;

class function TPontoFechamentoJornadaController.ConsultaObjeto(pFiltro: String): TPontoFechamentoJornadaVO;
begin
  try
    Result := TPontoFechamentoJornadaVO.Create;
    Result := TPontoFechamentoJornadaVO(TT2TiORM.ConsultarUmObjeto(Result, pFiltro, True));
  finally
  end;
end;

class procedure TPontoFechamentoJornadaController.Insere(pObjeto: TPontoFechamentoJornadaVO);
var
  UltimoID: Integer;
begin
  try
    UltimoID := TT2TiORM.Inserir(pObjeto);
    Consulta('ID = ' + IntToStr(UltimoID), '0');
  finally
  end;
end;

class function TPontoFechamentoJornadaController.Altera(pObjeto: TPontoFechamentoJornadaVO): Boolean;
begin
  try
    Result := TT2TiORM.Alterar(pObjeto);
  finally
  end;
end;

class function TPontoFechamentoJornadaController.Exclui(pId: Integer): Boolean;
var
  ObjetoLocal: TPontoFechamentoJornadaVO;
begin
  try
    ObjetoLocal := TPontoFechamentoJornadaVO.Create;
    ObjetoLocal.Id := pId;
    Result := TT2TiORM.Excluir(ObjetoLocal);
  finally
    FreeAndNil(ObjetoLocal)
  end;
end;

initialization
  Classes.RegisterClass(TPontoFechamentoJornadaController);

finalization
  Classes.UnRegisterClass(TPontoFechamentoJornadaController);

end.

