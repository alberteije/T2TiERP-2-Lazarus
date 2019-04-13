{*******************************************************************************
Title: T2Ti ERP                                                                 
Description:  VO  relacionado à tabela [IBPT] 
                                                                                
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
unit IbptVO;

{$mode objfpc}{$H+}

interface

uses
  VO, Classes, SysUtils, FGL;

type
  TIbptVO = class(TVO)
  private
    FID: Integer;
    FNCM: String;
    FEX: String;
    FTIPO: String;
    FDESCRICAO: String;
    FNACIONAL_FEDERAL: Extended;
    FIMPORTADOS_FEDERAL: Extended;
    FESTADUAL: Extended;
    FMUNICIPAL: Extended;
    FVIGENCIA_INICIO: TDateTime;
    FVIGENCIA_FIM: TDateTime;
    FCHAVE: String;
    FVERSAO: String;
    FFONTE: String;

  published 
    property Id: Integer  read FID write FID;
    property Ncm: String  read FNCM write FNCM;
    property Ex: String  read FEX write FEX;
    property Tipo: String  read FTIPO write FTIPO;
    property Descricao: String  read FDESCRICAO write FDESCRICAO;
    property NacionalFederal: Extended  read FNACIONAL_FEDERAL write FNACIONAL_FEDERAL;
    property ImportadosFederal: Extended  read FIMPORTADOS_FEDERAL write FIMPORTADOS_FEDERAL;
    property Estadual: Extended  read FESTADUAL write FESTADUAL;
    property Municipal: Extended  read FMUNICIPAL write FMUNICIPAL;
    property VigenciaInicio: TDateTime  read FVIGENCIA_INICIO write FVIGENCIA_INICIO;
    property VigenciaFim: TDateTime  read FVIGENCIA_FIM write FVIGENCIA_FIM;
    property Chave: String  read FCHAVE write FCHAVE;
    property Versao: String  read FVERSAO write FVERSAO;
    property Fonte: String  read FFONTE write FFONTE;

  end;

  TListaIbptVO = specialize TFPGObjectList<TIbptVO>;

implementation


initialization
  Classes.RegisterClass(TIbptVO);

finalization
  Classes.UnRegisterClass(TIbptVO);

end.
