{*******************************************************************************
Title: T2Ti ERP                                                                 
Description: Controller do lado Cliente relacionado à tabela [CONTRATO_TEMPLATE] 
                                                                                
The MIT License                                                                 
                                                                                
Copyright: Copyright (C) 2016 T2Ti.COM                                          
                                                                                
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
unit ContratoTemplateController;

{$MODE Delphi}

interface

uses
  Classes, Dialogs, SysUtils, DB,  LCLIntf, LCLType, LMessages, Forms, FileUtil, Controller,
  VO, ZDataset, ContratoTemplateVO, Biblioteca;

type
  TContratoTemplateController = class(TController)
  private
    class function ArmazenarArquivo(pObjeto: TContratoTemplateVO): Boolean;
  public
    class function Consulta(pFiltro: String; pPagina: String): TZQuery;
    class function ConsultaLista(pFiltro: String): TListaContratoTemplateVO;
    class function ConsultaObjeto(pFiltro: String): TContratoTemplateVO;

    class procedure Insere(pObjeto: TContratoTemplateVO);
    class function Altera(pObjeto: TContratoTemplateVO): Boolean;

    class function Exclui(pId: Integer): Boolean;


    class function BaixarArquivo(pFiltro: String): String;
  end;

implementation

uses UDataModule, T2TiORM;

var
  ObjetoLocal: TContratoTemplateVO;

class function TContratoTemplateController.Consulta(pFiltro: String; pPagina: String): TZQuery;
begin
  try
    ObjetoLocal := TContratoTemplateVO.Create;
    Result := TT2TiORM.Consultar(ObjetoLocal, pFiltro, pPagina);
  finally
    ObjetoLocal.Free;
  end;
end;

class function TContratoTemplateController.ConsultaLista(pFiltro: String): TListaContratoTemplateVO;
begin
  try
    ObjetoLocal := TContratoTemplateVO.Create;
    Result := TListaContratoTemplateVO(TT2TiORM.Consultar(ObjetoLocal, pFiltro, True));
  finally
    ObjetoLocal.Free;
  end;
end;

class function TContratoTemplateController.ConsultaObjeto(pFiltro: String): TContratoTemplateVO;
begin
  try
    Result := TContratoTemplateVO.Create;
    Result := TContratoTemplateVO(TT2TiORM.ConsultarUmObjeto(Result, pFiltro, True));
  finally
  end;
end;

class procedure TContratoTemplateController.Insere(pObjeto: TContratoTemplateVO);
var
  UltimoID: Integer;
begin
  try
    UltimoID := TT2TiORM.Inserir(pObjeto);

    // Se subiu um documento, armazena
    if pObjeto.Arquivo <> '' then
    begin
      pObjeto.Id := UltimoID;
      ArmazenarArquivo(pObjeto);
    end;

    Consulta('ID = ' + IntToStr(UltimoID), '0');
  finally
  end;
end;

class function TContratoTemplateController.Altera(pObjeto: TContratoTemplateVO): Boolean;
begin
  try
    // Se subiu um documento, armazena
    if pObjeto.Arquivo <> '' then
      Result := ArmazenarArquivo(pObjeto);

    Result := TT2TiORM.Alterar(pObjeto);
  finally
  end;
end;

class function TContratoTemplateController.Exclui(pId: Integer): Boolean;
var
  ObjetoLocal: TContratoTemplateVO;
begin
  try
    ObjetoLocal := TContratoTemplateVO.Create;
    ObjetoLocal.Id := pId;
    Result := TT2TiORM.Excluir(ObjetoLocal);
  finally
    FreeAndNil(ObjetoLocal)
  end;
end;

class function TContratoTemplateController.ArmazenarArquivo(pObjeto: TContratoTemplateVO): Boolean;
begin
  /// EXERCICIO: caso esteja trabalhando em três camadas, implemente o upload do arquivo para o servidor
  /// Dica: o módulo Sped faz o download do arquivo do servidor para o cliente
end;

class function TContratoTemplateController.BaixarArquivo(pFiltro: String): String;
begin
  try
    Result := ExtractFilePath(Application.ExeName) + 'Arquivos\Contratos\Templates\' + pFiltro;
  finally
  end;
end;


initialization
  Classes.RegisterClass(TContratoTemplateController);

finalization
  Classes.UnRegisterClass(TContratoTemplateController);

end.

