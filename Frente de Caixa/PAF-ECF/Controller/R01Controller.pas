{*******************************************************************************
Title: T2Ti ERP                                                                 
Description: Controller relacionado à tabela [R01] 
                                                                                
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
{*******************************************************************************
Observações importantes

Registro tipo R01 - Identificação do ECF, do Usuário, do PAF-ECF e da Empresa Desenvolvedora;
Registro tipo R02 - Relação de Reduções Z;
Registro tipo R03 - Detalhe da Redução Z;
Registro tipo R04 - Cupom Fiscal, Nota Fiscal de Venda a Consumidor ou Bilhete de Passagem;
Registro tipo R05 - Detalhe do Cupom Fiscal, da Nota Fiscal de Venda a Consumidor ou Bilhete de Passagem;
Registro tipo R06 - Demais documentos emitidos pelo ECF;
Registro tipo R07 - Detalhe do Cupom Fiscal e do Documento Não Fiscal - Meio de Pagamento;
Registro EAD - Assinatura digital.

Numa venda com cartão teremos:
-Um R04 referente ao Cupom Fiscal (já gravamos no venda_cabecalho)
-Um R05 para cada item vendido  (já gravamos no venda_detalhe)
-Um R06 para o Comprovante de Crédito ou Débito (o CCD se encaixa como "outros documentos emitidos");
-Um R07 referente à forma de pagamento utilizada no Cupom Fiscal, no caso, Cartão.
*******************************************************************************}
unit R01Controller;

interface

uses
  Classes, SysUtils, Windows, Forms, Controller,
  VO, R01VO;


type
  TR01Controller = class(TController)
  private
  public
    class function ConsultaObjeto(pFiltro: String): TR01VO;
  end;

implementation

uses UDataModule, T2TiORM;

class function TR01Controller.ConsultaObjeto(pFiltro: String): TR01VO;
begin
  try
    Result := TR01VO.Create;
    Result := TR01VO(TT2TiORM.ConsultarUmObjeto(Result, pFiltro, True));
  finally
  end;
end;


end.
