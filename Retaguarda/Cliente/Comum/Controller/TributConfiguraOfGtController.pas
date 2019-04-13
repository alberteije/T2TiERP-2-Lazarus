{*******************************************************************************
Title: T2Ti ERP                                                                 
Description: Controller do lado Cliente relacionado à tabela [tribut_configura_of_gt] 
                                                                                
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
unit TributConfiguraOfGtController;

{$MODE Delphi}

interface

uses
  Classes, Dialogs, SysUtils, DB, LCLIntf, LCLType, LMessages, Forms, Controller,
  TributConfiguraOfGtVO, ZDataset, VO;

type
  TTributConfiguraOfGtController = class(TController)
  private
  public
    class function Consulta(pFiltro: String; pPagina: String): TZQuery;
    class function ConsultaLista(pFiltro: String): TListaTributConfiguraOfGtVO;
    class function ConsultaObjeto(pFiltro: String): TTributConfiguraOfGtVO;

    class procedure Insere(pObjeto: TTributConfiguraOfGtVO);
    class function Altera(pObjeto: TTributConfiguraOfGtVO): Boolean;

    class function Exclui(pId: Integer): Boolean;
    class function ExcluiDetalhe(pId: Integer): Boolean;

  end;

implementation

uses T2TiORM,
    //
    TributPisCodApuracaoVO, TributCofinsCodApuracaoVO, TributIpiDipiVO, TributIcmsUfVO,
    TributOperacaoFiscalVO, TributGrupoTributarioVO;

var
  ObjetoLocal: TTributConfiguraOfGtVO;


class function TTributConfiguraOfGtController.Consulta(pFiltro: String; pPagina: String): TZQuery;
begin
  try
    ObjetoLocal := TTributConfiguraOfGtVO.Create;
    Result := TT2TiORM.Consultar(ObjetoLocal, pFiltro, pPagina);
  finally
    ObjetoLocal.Free;
  end;
end;

class function TTributConfiguraOfGtController.ConsultaLista(pFiltro: String): TListaTributConfiguraOfGtVO;
begin
  try
    ObjetoLocal := TTributConfiguraOfGtVO.Create;
    Result := TListaTributConfiguraOfGtVO(TT2TiORM.Consultar(ObjetoLocal, pFiltro, True));
  finally
    ObjetoLocal.Free;
  end;
end;

class function TTributConfiguraOfGtController.ConsultaObjeto(pFiltro: String): TTributConfiguraOfGtVO;
var
  Filtro: String;
begin
  try
    Result := TTributConfiguraOfGtVO.Create;
    Result := TTributConfiguraOfGtVO(TT2TiORM.ConsultarUmObjeto(Result, pFiltro, True));

    Filtro := 'ID_TRIBUT_CONFIGURA_OF_GT = ' + IntToStr(Result.Id);

    // Objetos Vinculados
    Result.TributOperacaoFiscalVO := TTributOperacaoFiscalVO(TT2TiORM.ConsultarUmObjeto(Result.TributOperacaoFiscalVO, 'ID='+IntToStr(Result.IdTributOperacaoFiscal), True));
    Result.TributGrupoTributarioVO := TTributGrupoTributarioVO(TT2TiORM.ConsultarUmObjeto(Result.TributGrupoTributarioVO, 'ID='+IntToStr(Result.IdTributGrupoTributario), True));

    Result.TributPisCodApuracaoVO := TTributPisCodApuracaoVO(TT2TiORM.ConsultarUmObjeto(Result.TributPisCodApuracaoVO, Filtro, True));
    Result.TributCofinsCodApuracaoVO := TTributCofinsCodApuracaoVO(TT2TiORM.ConsultarUmObjeto(Result.TributCofinsCodApuracaoVO, Filtro, True));
    Result.TributIpiDipiVO := TTributIpiDipiVO(TT2TiORM.ConsultarUmObjeto(Result.TributIpiDipiVO, Filtro, True));

    // Listas
    Result.ListaTributIcmsUfVO := TListaTributIcmsUfVO(TT2TiORM.Consultar(TTributIcmsUfVO.Create, Filtro, True));
  finally
  end;
end;

class procedure TTributConfiguraOfGtController.Insere(pObjeto: TTributConfiguraOfGtVO);
var
  UltimoID: Integer;
begin
  try
    UltimoID := TT2TiORM.Inserir(pObjeto);

    { Pis }
    pObjeto.TributPisCodApuracaoVO.IdTributConfiguraOfGt := UltimoID;
    TT2TiORM.Inserir(pObjeto.TributPisCodApuracaoVO);

    { Cofins }
    pObjeto.TributCofinsCodApuracaoVO.IdTributConfiguraOfGt := UltimoID;
    TT2TiORM.Inserir(pObjeto.TributCofinsCodApuracaoVO);

    { Ipi }
    pObjeto.TributIpiDipiVO.IdTributConfiguraOfGt := UltimoID;
    TT2TiORM.Inserir(pObjeto.TributIpiDipiVO);

    // Detalhes
    /// EXERCICIO: Implemente os detalhes

    Consulta('ID = ' + IntToStr(UltimoID), '0');
  finally
  end;
end;

class function TTributConfiguraOfGtController.Altera(pObjeto: TTributConfiguraOfGtVO): Boolean;
begin
  try
    Result := TT2TiORM.Alterar(pObjeto);

    { Pis }
    Result := TT2TiORM.Alterar(pObjeto.TributPisCodApuracaoVO);
    { Cofins }
    Result := TT2TiORM.Alterar(pObjeto.TributCofinsCodApuracaoVO);
    { Ipi }
    Result := TT2TiORM.Alterar(pObjeto.TributIpiDipiVO);

    // Detalhes
    /// EXERCICIO: Implemente os detalhes

  finally
  end;
end;

class function TTributConfiguraOfGtController.Exclui(pId: Integer): Boolean;
var
  ObjetoLocal: TTributConfiguraOfGtVO;
begin
  try
    ObjetoLocal := TTributConfiguraOfGtVO.Create;
    ObjetoLocal.Id := pId;
    Result := TT2TiORM.Excluir(ObjetoLocal);
  finally
    FreeAndNil(ObjetoLocal)
  end;
end;

class function TTributConfiguraOfGtController.ExcluiDetalhe(pId: Integer): Boolean;
var
  ObjetoLocal: TTributIcmsUfVO;
begin
  try
    ObjetoLocal := TTributIcmsUfVO.Create;
    ObjetoLocal.Id := pId;
    Result := TT2TiORM.Excluir(ObjetoLocal);
  finally
    FreeAndNil(ObjetoLocal)
  end;
end;

initialization
  Classes.RegisterClass(TTributConfiguraOfGtController);

finalization
  Classes.UnRegisterClass(TTributConfiguraOfGtController);

end.

