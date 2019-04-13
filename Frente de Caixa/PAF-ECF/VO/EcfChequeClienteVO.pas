{*******************************************************************************
Title: T2Ti ERP                                                                 
Description:  VO  relacionado à tabela [ECF_CHEQUE_CLIENTE] 
                                                                                
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
unit EcfChequeClienteVO;

{$mode objfpc}{$H+}

interface

uses
  VO, Classes, SysUtils, FGL;

type
  TEcfChequeClienteVO = class(TVO)
  private
    FID: Integer;
    FID_BANCO: Integer;
    FID_CLIENTE: Integer;
    FID_ECF_MOVIMENTO: Integer;
    FNUMERO_CHEQUE: Integer;
    FDATA_CHEQUE: TDateTime;
    FVALOR_CHEQUE: Extended;
    FOBSERVACOES: String;
    FAGENCIA: String;
    FCONTA: String;
    FTIPO_CHEQUE: String;

  published 
    property Id: Integer  read FID write FID;
    property IdBanco: Integer  read FID_BANCO write FID_BANCO;
    property IdCliente: Integer  read FID_CLIENTE write FID_CLIENTE;
    property IdEcfMovimento: Integer  read FID_ECF_MOVIMENTO write FID_ECF_MOVIMENTO;
    property NumeroCheque: Integer  read FNUMERO_CHEQUE write FNUMERO_CHEQUE;
    property DataCheque: TDateTime  read FDATA_CHEQUE write FDATA_CHEQUE;
    property ValorCheque: Extended  read FVALOR_CHEQUE write FVALOR_CHEQUE;
    property Observacoes: String  read FOBSERVACOES write FOBSERVACOES;
    property Agencia: String  read FAGENCIA write FAGENCIA;
    property Conta: String  read FCONTA write FCONTA;
    property TipoCheque: String  read FTIPO_CHEQUE write FTIPO_CHEQUE;

  end;

  TListaEcfChequeClienteVO = specialize TFPGObjectList<TEcfChequeClienteVO>;

implementation


initialization
  Classes.RegisterClass(TEcfChequeClienteVO);

finalization
  Classes.UnRegisterClass(TEcfChequeClienteVO);

end.
