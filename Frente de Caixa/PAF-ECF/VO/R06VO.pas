{*******************************************************************************
Title: T2Ti ERP                                                                 
Description:  VO  relacionado à tabela [R06] 
                                                                                
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
unit R06VO;

{$mode objfpc}{$H+}

interface

uses
  VO, Classes, SysUtils, FGL, R07VO;

type
  TR06VO = class(TVO)
  private
    FID: Integer;
    FID_OPERADOR: Integer;
    FID_IMPRESSORA: Integer;
    FID_ECF_CAIXA: Integer;
    FSERIE_ECF: String;
    FCOO: Integer;
    FGNF: Integer;
    FGRG: Integer;
    FCDC: Integer;
    FDENOMINACAO: String;
    FDATA_EMISSAO: TDateTime;
    FHORA_EMISSAO: String;
    FLOGSS: String;

    FListaR07VO: TListaR07VO;

  published
    constructor Create; override;
    destructor Destroy; override;

    property Id: Integer  read FID write FID;
    property IdOperador: Integer  read FID_OPERADOR write FID_OPERADOR;
    property IdImpressora: Integer  read FID_IMPRESSORA write FID_IMPRESSORA;
    property IdEcfCaixa: Integer  read FID_ECF_CAIXA write FID_ECF_CAIXA;
    property SerieEcf: String  read FSERIE_ECF write FSERIE_ECF;
    property Coo: Integer  read FCOO write FCOO;
    property Gnf: Integer  read FGNF write FGNF;
    property Grg: Integer  read FGRG write FGRG;
    property Cdc: Integer  read FCDC write FCDC;
    property Denominacao: String  read FDENOMINACAO write FDENOMINACAO;
    property DataEmissao: TDateTime  read FDATA_EMISSAO write FDATA_EMISSAO;
    property HoraEmissao: String  read FHORA_EMISSAO write FHORA_EMISSAO;
    property HashRegistro: String  read FLOGSS write FLOGSS;

    property ListaR07VO: TListaR07VO read FListaR07VO write FListaR07VO;
  end;

  TListaR06VO = specialize TFPGObjectList<TR06VO>;

implementation

constructor TR06VO.Create;
begin
  inherited;

  FListaR07VO := TListaR07VO.Create;
end;

destructor TR06VO.Destroy;
begin
  FreeAndNil(FListaR07VO);

  inherited;
end;


initialization
  Classes.RegisterClass(TR06VO);

finalization
  Classes.UnRegisterClass(TR06VO);

end.
