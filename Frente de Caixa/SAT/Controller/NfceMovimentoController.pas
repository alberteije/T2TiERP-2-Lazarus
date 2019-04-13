{*******************************************************************************
Title: T2Ti ERP                                                                 
Description: Controller relacionado à tabela [NFCE_MOVIMENTO] 
                                                                                
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
unit NfceMovimentoController;

interface

uses
  Classes, SysUtils, Windows, Forms, Controller,
  VO, NfceMovimentoVO;


type
  TNfceMovimentoController = class(TController)
  private
  public
    class function ConsultaObjeto(pFiltro: String): TNfceMovimentoVO;
    class function Altera(pObjeto: TNfceMovimentoVO): Boolean;
    class function Exclui(pId: Integer): Boolean;
    class function IniciaMovimento(pObjeto: TNfceMovimentoVO): TNfceMovimentoVO;
  end;

implementation

uses T2TiORM,
  NfceCaixaVO, EmpresaVO, NfceTurnoVO, NfceOperadorVO,
  NfceFechamentoVO, NfceSuprimentoVO, NfceSangriaVO;

var
  ObjetoLocal: TNfceMovimentoVO;

class function TNfceMovimentoController.ConsultaObjeto(pFiltro: String): TNfceMovimentoVO;
var
  Filtro: String;
begin
  try
    Result := TNfceMovimentoVO.Create;
    Result := TNfceMovimentoVO(TT2TiORM.ConsultarUmObjeto(Result, pFiltro, True));

    //Exercício: crie o método para popular esses objetos automaticamente no T2TiORM
    Result.NfceCaixaVO := TNfceCaixaVO(TT2TiORM.ConsultarUmObjeto(Result.NfceCaixaVO, 'ID='+IntToStr(Result.IdNfceCaixa), True));
    Result.EmpresaVO := TEmpresaVO(TT2TiORM.ConsultarUmObjeto(Result.EmpresaVO, 'ID='+IntToStr(Result.IdEmpresa), True));
    Result.NfceTurnoVO := TNfceTurnoVO(TT2TiORM.ConsultarUmObjeto(Result.NfceTurnoVO, 'ID='+IntToStr(Result.IdNfceTurno), True));
    Result.NfceOperadorVO := TNfceOperadorVO(TT2TiORM.ConsultarUmObjeto(Result.NfceOperadorVO, 'ID='+IntToStr(Result.IdNfceOperador), True));
    Result.NfceGerenteVO := TNfceOperadorVO(TT2TiORM.ConsultarUmObjeto(Result.NfceOperadorVO, 'ID='+IntToStr(Result.IdGerenteSupervisor), True));

    Filtro := 'ID_NFCE_MOVIMENTO = ' + IntToStr(Result.Id);
    Result.ListaNfceFechamentoVO := TListaNfceFechamentoVO(TT2TiORM.Consultar(TNfceFechamentoVO.Create, Filtro, True));
    Result.ListaNfceSuprimentoVO := TListaNfceSuprimentoVO(TT2TiORM.Consultar(TNfceSuprimentoVO.Create, Filtro, True));
    Result.ListaNfceSangriaVO := TListaNfceSangriaVO(TT2TiORM.Consultar(TNfceSangriaVO.Create, Filtro, True));
  finally
  end;
end;

class function TNfceMovimentoController.Altera(pObjeto: TNfceMovimentoVO): Boolean;
begin
  try
    Result := TT2TiORM.Alterar(pObjeto);
  finally
  end;
end;

class function TNfceMovimentoController.Exclui(pId: Integer): Boolean;
begin
  try
    ObjetoLocal := TNfceMovimentoVO.Create;
    ObjetoLocal.Id := pId;
    Result := TT2TiORM.Excluir(ObjetoLocal);
  finally
    FreeAndNil(ObjetoLocal);
  end;
end;

class function TNfceMovimentoController.IniciaMovimento(pObjeto: TNfceMovimentoVO): TNfceMovimentoVO;
var
  UltimoID: Integer;
begin
  try
    UltimoID := TT2TiORM.Inserir(pObjeto);
    Result := ConsultaObjeto('ID = ' + IntToStr(UltimoID));
  finally
  end;
end;

end.
