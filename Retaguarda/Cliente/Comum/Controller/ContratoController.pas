{*******************************************************************************
Title: T2Ti ERP                                                                 
Description: Controller do lado Cliente relacionado à tabela [CONTRATO] 
                                                                                
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
unit ContratoController;

{$MODE Delphi}

interface

uses
  Classes, Dialogs, SysUtils, DB,  LCLIntf, LCLType, LMessages, Forms, FileUtil, Controller,
  VO, ZDataset, ContratoVO, Biblioteca;

type
  TContratoController = class(TController)
  private
    class function ArmazenarArquivo(pObjeto: TContratoVO): Boolean;
  public
    class function Consulta(pFiltro: String; pPagina: String): TZQuery;
    class function ConsultaLista(pFiltro: String): TListaContratoVO;
    class function ConsultaObjeto(pFiltro: String): TContratoVO;

    class procedure Insere(pObjeto: TContratoVO);
    class function Altera(pObjeto: TContratoVO): Boolean;

    class function Exclui(pId: Integer): Boolean;


    class function BaixarArquivo(pFiltro: String): String;
  end;

implementation

uses UDataModule, T2TiORM, ContratoHistFaturamentoVO, ContratoHistoricoReajusteVO,
  ContratoPrevFaturamentoVO;

var
  ObjetoLocal: TContratoVO;

class function TContratoController.Consulta(pFiltro: String; pPagina: String): TZQuery;
begin
  try
    ObjetoLocal := TContratoVO.Create;
    Result := TT2TiORM.Consultar(ObjetoLocal, pFiltro, pPagina);
  finally
    ObjetoLocal.Free;
  end;
end;

class function TContratoController.ConsultaLista(pFiltro: String): TListaContratoVO;
begin
  try
    ObjetoLocal := TContratoVO.Create;
    Result := TListaContratoVO(TT2TiORM.Consultar(ObjetoLocal, pFiltro, True));
  finally
    ObjetoLocal.Free;
  end;
end;

class function TContratoController.ConsultaObjeto(pFiltro: String): TContratoVO;
begin
  try
    Result := TContratoVO.Create;
    Result := TContratoVO(TT2TiORM.ConsultarUmObjeto(Result, pFiltro, True));

    Filtro := 'ID_CONTRATO = ' + IntToStr(Result.Id);

    // Objetos Vinculados

    // Listas
    Result.ListaContratoHistFaturamentoVO := TListaContratoHistFaturamentoVO(TT2TiORM.Consultar(TContratoHistFaturamentoVO.Create, Filtro, True));
    Result.ListaContratoHistoricoReajusteVO := TListaContratoHistoricoReajusteVO(TT2TiORM.Consultar(TContratoHistoricoReajusteVO.Create, Filtro, True));
    Result.ListaContratoPrevFaturamentoVO := TListaContratoPrevFaturamentoVO(TT2TiORM.Consultar(TContratoPrevFaturamentoVO.Create, Filtro, True));

  finally
  end;
end;

class procedure TContratoController.Insere(pObjeto: TContratoVO);
var
  UltimoID: Integer;
  HistoricoFaturamento: TContratoHistFaturamentoVO;
  HistoricoReajuste: TContratoHistoricoReajusteVO;
  PrevisaoFaturamento: TContratoPrevFaturamentoVO;
  i: Integer;
begin
  try
    UltimoID := TT2TiORM.Inserir(pObjeto);

    // Histórico Faturamento
    for i := 0 to pObjeto.ListaContratoHistFaturamentoVO.Count - 1 do
    begin
      HistoricoFaturamento := pObjeto.ListaContratoHistFaturamentoVO[i];
      HistoricoFaturamento.IdContrato := UltimoID;
      TT2TiORM.Inserir(HistoricoFaturamento);
    end;

    // Histórico Reajuste
    for i := 0 to pObjeto.ListaContratoHistoricoReajusteVO.Count - 1 do
    begin
      HistoricoReajuste := pObjeto.ListaContratoHistoricoReajusteVO[i];
      HistoricoReajuste.IdContrato := UltimoID;
      TT2TiORM.Inserir(HistoricoReajuste);
    end;

    // Previsão Faturamento
    for i := 0 to pObjeto.ListaContratoPrevFaturamentoVO.Count - 1 do
    begin
      PrevisaoFaturamento := pObjeto.ListaContratoPrevFaturamentoVO[i];
      PrevisaoFaturamento.IdContrato := UltimoID;
      TT2TiORM.Inserir(PrevisaoFaturamento);
    end;

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

class function TContratoController.Altera(pObjeto: TContratoVO): Boolean;
var
  HistoricoFaturamento: TContratoHistFaturamentoVO;
  HistoricoReajuste: TContratoHistoricoReajusteVO;
  PrevisaoFaturamento: TContratoPrevFaturamentoVO;
  i: Integer;
begin
  try
    try
      // Se subiu um documento, armazena
      if pObjeto.Arquivo <> '' then
        Result := ArmazenarArquivo(pObjeto);

      Result := TT2TiORM.Alterar(pObjeto);
    except
    end;

    // Histórico Faturamento
    for i := 0 to pObjeto.ListaContratoHistFaturamentoVO.Count - 1 do
    begin
      HistoricoFaturamento := pObjeto.ListaContratoHistFaturamentoVO[i];

      if HistoricoFaturamento.Id > 0 then
        Result := TT2TiORM.Alterar(HistoricoFaturamento)
      else
      begin
        HistoricoFaturamento.IdContrato := pObjeto.Id;
        Result := TT2TiORM.Inserir(HistoricoFaturamento) > 0;
      end;
    end;

    // Histórico Reajuste
    for i := 0 to pObjeto.ListaContratoHistoricoReajusteVO.Count - 1 do
    begin
      HistoricoReajuste := pObjeto.ListaContratoHistoricoReajusteVO[i];
      if HistoricoReajuste.Id > 0 then
        Result := TT2TiORM.Alterar(HistoricoReajuste)
      else
      begin
        HistoricoReajuste.IdContrato := pObjeto.Id;
        Result := TT2TiORM.Inserir(HistoricoReajuste) > 0;
      end;
    end;

    // Previsão Faturamento
    for i := 0 to pObjeto.ListaContratoPrevFaturamentoVO.Count - 1 do
    begin
      PrevisaoFaturamento := pObjeto.ListaContratoPrevFaturamentoVO[i];

      if PrevisaoFaturamento.Id > 0 then
        Result := TT2TiORM.Alterar(PrevisaoFaturamento)
      else
      begin
        PrevisaoFaturamento.IdContrato := pObjeto.Id;
        Result := TT2TiORM.Inserir(PrevisaoFaturamento) > 0;
      end;
    end;

  finally
  end;
end;

class function TContratoController.Exclui(pId: Integer): Boolean;
var
  ObjetoLocal: TContratoVO;
begin
  try
    ObjetoLocal := TContratoVO.Create;
    ObjetoLocal.Id := pId;
    Result := TT2TiORM.Excluir(ObjetoLocal);
  finally
    FreeAndNil(ObjetoLocal)
  end;
end;

class function TContratoController.ArmazenarArquivo(pObjeto: TContratoVO): Boolean;
begin
  /// EXERCICIO: caso esteja trabalhando em três camadas, implemente o upload do arquivo para o servidor
  /// Dica: o módulo Sped faz o download do arquivo do servidor para o cliente
end;

class function TContratoController.BaixarArquivo(pFiltro: String): String;
begin
  try
    Result := ExtractFilePath(Application.ExeName) + 'Arquivos\Contratos\' + pFiltro;
  finally
  end;
end;

initialization
  Classes.RegisterClass(TContratoController);

finalization
  Classes.UnRegisterClass(TContratoController);

end.

