{*******************************************************************************
Title: T2Ti ERP                                                                 
Description:  VO  relacionado à tabela [LOGSS] 
                                                                                
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
unit LogssVO;

{$mode objfpc}{$H+}

interface

uses
  VO, Classes, SysUtils, FGL;

type
  TLogssVO = class(TVO)
  private
    FID: Integer;
    FTTP: Integer;
    FPRODUTO: Integer;
    FR01: Integer;
    FR02: Integer;
    FR03: Integer;
    FR04: Integer;
    FR05: Integer;
    FR06: Integer;
    FR07: Integer;

  published 
    property Id: Integer  read FID write FID;
    property Ttp: Integer  read FTTP write FTTP;
    property Produto: Integer  read FPRODUTO write FPRODUTO;
    property R01: Integer  read FR01 write FR01;
    property R02: Integer  read FR02 write FR02;
    property R03: Integer  read FR03 write FR03;
    property R04: Integer  read FR04 write FR04;
    property R05: Integer  read FR05 write FR05;
    property R06: Integer  read FR06 write FR06;
    property R07: Integer  read FR07 write FR07;

  end;

  TListaLogssVO = specialize TFPGObjectList<TLogssVO>;

implementation


initialization
  Classes.RegisterClass(TLogssVO);

finalization
  Classes.UnRegisterClass(TLogssVO);

end.
