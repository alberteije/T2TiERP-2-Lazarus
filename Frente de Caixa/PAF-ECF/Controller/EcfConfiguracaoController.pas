{*******************************************************************************
Title: T2Ti ERP                                                                 
Description: Controller relacionado à tabela [ECF_CONFIGURACAO] 
                                                                                
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
unit EcfConfiguracaoController;

interface

uses
  Classes, SysUtils, Windows, Forms, Controller, VO, EcfConfiguracaoVO;


type
  TEcfConfiguracaoController = class(TController)
  private
  public
    class function ConsultaObjeto(pFiltro: String): TEcfConfiguracaoVO;
  end;

implementation

uses T2TiORM,
  EcfResolucaoVO, EcfImpressoraVO, EcfCaixaVO, EcfEmpresaVO, EcfConfiguracaoBalancaVO,
  EcfRelatorioGerencialVO, EcfConfiguracaoLeitorSerVO, EcfPosicaoComponentesVO;

class function TEcfConfiguracaoController.ConsultaObjeto(pFiltro: String): TEcfConfiguracaoVO;
var
  Filtro: String;
begin
  try
    Result := TEcfConfiguracaoVO.Create;
    Result := TEcfConfiguracaoVO(TT2TiORM.ConsultarUmObjeto(Result, pFiltro, True));

    //Exercício: crie o método para popular esses objetos automaticamente no T2TiORM
    Result.EcfResolucaoVO := TEcfResolucaoVO(TT2TiORM.ConsultarUmObjeto(Result.EcfResolucaoVO, 'ID='+IntToStr(Result.IdEcfResolucao), True));
    Filtro := 'ID_ECF_RESOLUCAO='+IntToStr(Result.EcfResolucaoVO.Id);
    Result.EcfResolucaoVO.ListaEcfPosicaoComponentesVO := TListaEcfPosicaoComponentesVO(TT2TiORM.Consultar(TEcfPosicaoComponentesVO.Create, Filtro, True));
    Result.EcfImpressoraVO := TEcfImpressoraVO(TT2TiORM.ConsultarUmObjeto(Result.EcfImpressoraVO, 'ID='+IntToStr(Result.IdEcfImpressora), True));
    Result.EcfCaixaVO := TEcfCaixaVO(TT2TiORM.ConsultarUmObjeto(Result.EcfCaixaVO, 'ID='+IntToStr(Result.IdEcfCaixa), True));
    Result.EcfEmpresaVO := TEcfEmpresaVO(TT2TiORM.ConsultarUmObjeto(Result.EcfEmpresaVO, 'ID='+IntToStr(Result.IdEcfEmpresa), True));

    Filtro := 'ID_ECF_CONFIGURACAO = ' + IntToStr(Result.Id);
    Result.EcfConfiguracaoBalancaVO := TEcfConfiguracaoBalancaVO(TT2TiORM.ConsultarUmObjeto(Result.EcfConfiguracaoBalancaVO, Filtro, True));
    Result.EcfRelatorioGerencialVO := TEcfRelatorioGerencialVO(TT2TiORM.ConsultarUmObjeto(Result.EcfRelatorioGerencialVO, Filtro, True));
    Result.EcfConfiguracaoLeitorSerVO := TEcfConfiguracaoLeitorSerVO(TT2TiORM.ConsultarUmObjeto(Result.EcfConfiguracaoLeitorSerVO, Filtro, True));
  finally
  end;
end;


end.
