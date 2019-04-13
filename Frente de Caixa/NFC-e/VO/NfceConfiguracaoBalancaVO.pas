{*******************************************************************************
Title: T2Ti ERP                                                                 
Description:  VO  relacionado à tabela [NFCE_CONFIGURACAO_BALANCA] 
                                                                                
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
unit NfceConfiguracaoBalancaVO;

{$mode objfpc}{$H+}

interface

uses
  VO, Classes, SysUtils, FGL;

type
  TNfceConfiguracaoBalancaVO = class(TVO)
  private
    FID: Integer;
    FID_NFCE_CONFIGURACAO: Integer;
    FMODELO: Integer;
    FIDENTIFICADOR: String;
    FHAND_SHAKE: Integer;
    FPARITY: Integer;
    FSTOP_BITS: Integer;
    FDATA_BITS: Integer;
    FBAUD_RATE: Integer;
    FPORTA: String;
    FTIMEOUT: Integer;
    FTIPO_CONFIGURACAO: String;

  published 
    property Id: Integer  read FID write FID;
    property IdNfceConfiguracao: Integer  read FID_NFCE_CONFIGURACAO write FID_NFCE_CONFIGURACAO;
    property Modelo: Integer  read FMODELO write FMODELO;
    property Identificador: String  read FIDENTIFICADOR write FIDENTIFICADOR;
    property HandShake: Integer  read FHAND_SHAKE write FHAND_SHAKE;
    property Parity: Integer  read FPARITY write FPARITY;
    property StopBits: Integer  read FSTOP_BITS write FSTOP_BITS;
    property DataBits: Integer  read FDATA_BITS write FDATA_BITS;
    property BaudRate: Integer  read FBAUD_RATE write FBAUD_RATE;
    property Porta: String  read FPORTA write FPORTA;
    property Timeout: Integer  read FTIMEOUT write FTIMEOUT;
    property TipoConfiguracao: String  read FTIPO_CONFIGURACAO write FTIPO_CONFIGURACAO;

  end;

  TListaNfceConfiguracaoBalancaVO = specialize TFPGObjectList<TNfceConfiguracaoBalancaVO>;

implementation


initialization
  Classes.RegisterClass(TNfceConfiguracaoBalancaVO);

finalization
  Classes.UnRegisterClass(TNfceConfiguracaoBalancaVO);

end.
