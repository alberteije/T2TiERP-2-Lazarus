{*******************************************************************************
Title: T2Ti ERP                                                                 
Description: Controller relacionado à tabela [NFCE_CONFIGURACAO] 
                                                                                
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
unit NfceConfiguracaoController;

interface

uses
  Classes, SysUtils, Windows, Forms, Controller, VO, NfceConfiguracaoVO;


type
  TNfceConfiguracaoController = class(TController)
  private
  public
    class function ConsultaObjeto(pFiltro: String): TNfceConfiguracaoVO;
  end;

implementation

uses T2TiORM,
  NfceResolucaoVO, NfceCaixaVO, EmpresaVO, NfceConfiguracaoBalancaVO,
  NfceConfiguracaoLeitorSerVO, NfcePosicaoComponentesVO, EmpresaEnderecoVO;

class function TNfceConfiguracaoController.ConsultaObjeto(pFiltro: String): TNfceConfiguracaoVO;
var
  Filtro: String;
begin
  try
    Result := TNfceConfiguracaoVO.Create;
    Result := TNfceConfiguracaoVO(TT2TiORM.ConsultarUmObjeto(Result, pFiltro, True));

    //Exercício: crie o método para popular esses objetos automaticamente no T2TiORM
    Result.NfceResolucaoVO := TNfceResolucaoVO(TT2TiORM.ConsultarUmObjeto(Result.NfceResolucaoVO, 'ID='+IntToStr(Result.IdNfceResolucao), True));
    Filtro := 'ID_NFCE_RESOLUCAO='+IntToStr(Result.NfceResolucaoVO.Id);
    Result.NfceResolucaoVO.ListaNfcePosicaoComponentesVO := TListaNfcePosicaoComponentesVO(TT2TiORM.Consultar(TNfcePosicaoComponentesVO.Create, Filtro, True));

    Result.NfceCaixaVO := TNfceCaixaVO(TT2TiORM.ConsultarUmObjeto(Result.NfceCaixaVO, 'ID='+IntToStr(Result.IdNfceCaixa), True));
    Result.EmpresaVO := TEmpresaVO(TT2TiORM.ConsultarUmObjeto(Result.EmpresaVO, 'ID='+IntToStr(Result.IdEmpresa), True));

    Filtro := 'ID_NFCE_CONFIGURACAO = ' + IntToStr(Result.Id);
    Result.NfceConfiguracaoBalancaVO := TNfceConfiguracaoBalancaVO(TT2TiORM.ConsultarUmObjeto(Result.NfceConfiguracaoBalancaVO, Filtro, True));
    if not Assigned(Result.NfceConfiguracaoBalancaVO) then
      Result.NfceConfiguracaoBalancaVO := TNfceConfiguracaoBalancaVO.Create;
    Result.NfceConfiguracaoLeitorSerVO := TNfceConfiguracaoLeitorSerVO(TT2TiORM.ConsultarUmObjeto(Result.NfceConfiguracaoLeitorSerVO, Filtro, True));
    if not Assigned(Result.NfceConfiguracaoLeitorSerVO) then
      Result.NfceConfiguracaoLeitorSerVO := TNfceConfiguracaoLeitorSerVO.Create;

    // Pega o endereço principal da empresa
    Filtro := 'PRINCIPAL=' + QuotedStr('S') + ' AND ID_EMPRESA=' + IntToStr(Result.EmpresaVO.Id);
    Result.EmpresaVO.EnderecoPrincipal := TEmpresaEnderecoVO.Create;
    Result.EmpresaVO.EnderecoPrincipal := TEmpresaEnderecoVO(TT2TiORM.ConsultarUmObjeto(Result.EmpresaVO.EnderecoPrincipal, Filtro, True));
  finally
  end;
end;


end.
