{*******************************************************************************
Title: T2Ti ERP                                                                 
Description: Controller relacionado à tabela [ECF_MOVIMENTO] 
                                                                                
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
unit EcfMovimentoController;

interface

uses
  Classes, SysUtils, Windows, Forms, Controller,
  VO, EcfMovimentoVO;


type
  TEcfMovimentoController = class(TController)
  private
  public
    class function ConsultaObjeto(pFiltro: String): TEcfMovimentoVO;
    class function Altera(pObjeto: TEcfMovimentoVO): Boolean;
    class function Exclui(pId: Integer): Boolean;
    class function IniciaMovimento(pObjeto: TEcfMovimentoVO): TEcfMovimentoVO;
  end;

implementation

uses T2TiORM,
  EcfImpressoraVO, EcfCaixaVO, EcfEmpresaVO, EcfTurnoVO, EcfOperadorVO,
  EcfFechamentoVO, EcfSuprimentoVO, EcfSangriaVO, EcfDocumentosEmitidosVO,
  EcfRecebimentoNaoFiscalVO;

var
  ObjetoLocal: TEcfMovimentoVO;

class function TEcfMovimentoController.ConsultaObjeto(pFiltro: String): TEcfMovimentoVO;
var
  Filtro: String;
begin
  try
    Result := TEcfMovimentoVO.Create;
    Result := TEcfMovimentoVO(TT2TiORM.ConsultarUmObjeto(Result, pFiltro, True));

    //Exercício: crie o método para popular esses objetos automaticamente no T2TiORM
    Result.EcfImpressoraVO := TEcfImpressoraVO(TT2TiORM.ConsultarUmObjeto(Result.EcfImpressoraVO, 'ID='+IntToStr(Result.IdEcfImpressora), True));
    Result.EcfCaixaVO := TEcfCaixaVO(TT2TiORM.ConsultarUmObjeto(Result.EcfCaixaVO, 'ID='+IntToStr(Result.IdEcfCaixa), True));
    Result.EcfEmpresaVO := TEcfEmpresaVO(TT2TiORM.ConsultarUmObjeto(Result.EcfEmpresaVO, 'ID='+IntToStr(Result.IdEcfEmpresa), True));
    Result.EcfTurnoVO := TEcfTurnoVO(TT2TiORM.ConsultarUmObjeto(Result.EcfTurnoVO, 'ID='+IntToStr(Result.IdEcfTurno), True));
    Result.EcfOperadorVO := TEcfOperadorVO(TT2TiORM.ConsultarUmObjeto(Result.EcfOperadorVO, 'ID='+IntToStr(Result.IdEcfOperador), True));
    Result.EcfGerenteVO := TEcfOperadorVO(TT2TiORM.ConsultarUmObjeto(Result.EcfOperadorVO, 'ID='+IntToStr(Result.IdGerenteSupervisor), True));

    Filtro := 'ID_ECF_MOVIMENTO = ' + IntToStr(Result.Id);
    Result.ListaEcfFechamentoVO := TListaEcfFechamentoVO(TT2TiORM.Consultar(TEcfFechamentoVO.Create, Filtro, True));
    Result.ListaEcfSuprimentoVO := TListaEcfSuprimentoVO(TT2TiORM.Consultar(TEcfSuprimentoVO.Create, Filtro, True));
    Result.ListaEcfSangriaVO := TListaEcfSangriaVO(TT2TiORM.Consultar(TEcfSangriaVO.Create, Filtro, True));
    Result.ListaEcfDocumentosEmitidosVO := TListaEcfDocumentosEmitidosVO(TT2TiORM.Consultar(TEcfDocumentosEmitidosVO.Create, Filtro, True));
    Result.ListaEcfRecebimentoNaoFiscalVO := TListaEcfRecebimentoNaoFiscalVO(TT2TiORM.Consultar(TEcfRecebimentoNaoFiscalVO.Create, Filtro, True));
  finally
  end;
end;

class function TEcfMovimentoController.Altera(pObjeto: TEcfMovimentoVO): Boolean;
begin
  try
    Result := TT2TiORM.Alterar(pObjeto);
  finally
  end;
end;

class function TEcfMovimentoController.Exclui(pId: Integer): Boolean;
begin
  try
    ObjetoLocal := TEcfMovimentoVO.Create;
    ObjetoLocal.Id := pId;
    Result := TT2TiORM.Excluir(ObjetoLocal);
  finally
    FreeAndNil(ObjetoLocal);
  end;
end;

class function TEcfMovimentoController.IniciaMovimento(pObjeto: TEcfMovimentoVO): TEcfMovimentoVO;
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
