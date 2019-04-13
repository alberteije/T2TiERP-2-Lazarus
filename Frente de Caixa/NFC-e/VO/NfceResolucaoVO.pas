{*******************************************************************************
Title: T2Ti ERP                                                                 
Description:  VO  relacionado à tabela [NFCE_RESOLUCAO] 
                                                                                
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
unit NfceResolucaoVO;

{$mode objfpc}{$H+}

interface

uses
  VO, Classes, SysUtils, FGL, NfcePosicaoComponentesVO;

type
  TNfceResolucaoVO = class(TVO)
  private
    FID: Integer;
    FRESOLUCAO_TELA: String;
    FLARGURA: Integer;
    FALTURA: Integer;
    FIMAGEM_TELA: String;
    FIMAGEM_MENU: String;
    FIMAGEM_SUBMENU: String;

    FListaNfcePosicaoComponentesVO: TListaNfcePosicaoComponentesVO;

  published
    constructor Create; override;
    destructor Destroy; override;

    property Id: Integer  read FID write FID;
    property ResolucaoTela: String  read FRESOLUCAO_TELA write FRESOLUCAO_TELA;
    property Largura: Integer  read FLARGURA write FLARGURA;
    property Altura: Integer  read FALTURA write FALTURA;
    property ImagemTela: String  read FIMAGEM_TELA write FIMAGEM_TELA;
    property ImagemMenu: String  read FIMAGEM_MENU write FIMAGEM_MENU;
    property ImagemSubmenu: String  read FIMAGEM_SUBMENU write FIMAGEM_SUBMENU;

    property ListaNfcePosicaoComponentesVO: TListaNfcePosicaoComponentesVO read FListaNfcePosicaoComponentesVO write FListaNfcePosicaoComponentesVO;

  end;

  TListaNfceResolucaoVO = specialize TFPGObjectList<TNfceResolucaoVO>;

implementation

constructor TNfceResolucaoVO.Create;
begin
  inherited;
  FListaNfcePosicaoComponentesVO := TListaNfcePosicaoComponentesVO.Create;
end;

destructor TNfceResolucaoVO.Destroy;
begin
  FreeAndNil(FListaNfcePosicaoComponentesVO);
  inherited;
end;


initialization
  Classes.RegisterClass(TNfceResolucaoVO);

finalization
  Classes.UnRegisterClass(TNfceResolucaoVO);

end.
