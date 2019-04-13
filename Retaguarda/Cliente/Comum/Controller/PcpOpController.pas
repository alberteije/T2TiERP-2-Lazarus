{*******************************************************************************
Title: T2Ti ERP
Description: Controller do lado Cliente relacionado às tabelas
  [PCP_OP_CABECALHO] e [PCP_OP_DETALHE]

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
unit PcpOpController;

interface

uses
  Classes, Dialogs, SysUtils, DB, LCLIntf, LCLType, LMessages, Forms, Controller,
  VO, ZDataset, PcpOpCabecalhoVO, PcpOpDetalheVO, PcpInstrucaoOpVO,
  PcpServicoVO, PcpServicoColaboradorVO, PcpServicoEquipamentoVO;

type
  TPcpOpController = class(TController)
  private
  public
    class function Consulta(pFiltro: string; pPagina: string): TZQuery;
    class function ConsultaLista(pFiltro: string): TListaPcpOpCabecalhoVO;
    class function ConsultaObjeto(pFiltro: string): TPcpOpCabecalhoVO;

    class procedure Insere(pObjeto: TPcpOpCabecalhoVO);
    class function Altera(pObjeto: TPcpOpCabecalhoVO): boolean;

    class function Exclui(pId: integer): boolean;
    class function ExcluiInstrucao(pId: integer): boolean;
    class function ExcluiItem(pId: integer): boolean;
    class function ExcluiServico(pId: integer): boolean;
    class function ExcluiColaborador(pId: integer): boolean;
    class function ExcluiEquipamento(pId: integer): boolean;


  end;

implementation

uses
  UDataModule, T2TiORM;

var
  ObjetoLocal: TPcpOpCabecalhoVO;

class function TPcpOpController.Consulta(pFiltro: string; pPagina: string): TZQuery;
begin
  try
    ObjetoLocal := TPcpOpCabecalhoVO.Create;
    Result := TT2TiORM.Consultar(ObjetoLocal, pFiltro, pPagina);
  finally
    ObjetoLocal.Free;
  end;
end;

class function TPcpOpController.ConsultaLista(pFiltro: string): TListaPcpOpCabecalhoVO;
begin
  try
    ObjetoLocal := TPcpOpCabecalhoVO.Create;
    Result := TListaPcpOpCabecalhoVO(TT2TiORM.Consultar(ObjetoLocal, pFiltro, True));
  finally
    ObjetoLocal.Free;
  end;
end;

class function TPcpOpController.ConsultaObjeto(pFiltro: string): TPcpOpCabecalhoVO;
begin
  try
    Result := TPcpOpCabecalhoVO.Create;
    Result := TPcpOpCabecalhoVO(TT2TiORM.ConsultarUmObjeto(Result, pFiltro, True));
  finally
  end;
end;

class procedure TPcpOpController.Insere(pObjeto: TPcpOpCabecalhoVO);
var
  UltimoID, IDDetalhe, IDServico: integer;
  I, J, K: integer;
begin
  try
    UltimoID := TT2TiORM.Inserir(pObjeto);
    // Instrucoes
    try
      for I := 0 to pObjeto.ListaPcpInstrucaoOpVO.Count - 1 do ;
      begin
        pObjeto.ListaPcpInstrucaoOpVO[I].IdPcpOpCabecalho := UltimoID;
        TT2TiORM.Inserir(pObjeto.ListaPcpInstrucaoOpVO[I]);
      end;
    finally
    end;

    // Detalhe
    try
      for I := 0 to pObjeto.ListaPcpOpDetalheVO.Count -1 do
      begin
        pObjeto.ListaPcpOpDetalheVO[I].IdPcpOpCabecalho := UltimoID;
        IDDetalhe := TT2TiORM.Inserir(pObjeto.ListaPcpOpDetalheVO[I]);

        for J := 0 to TPcpOpDetalheVO(pObjeto.ListaPcpOpDetalheVO[I]).ListaPcpServicoVO.Count -1 do
        begin
          TPcpOpDetalheVO(pObjeto.ListaPcpOpDetalheVO[I]).ListaPcpServicoVO[J].IdPcpOpDetalhe:= IDDetalhe;
          IDServico := TT2TiORM.Inserir(TPcpOpDetalheVO(pObjeto.ListaPcpOpDetalheVO[I]).ListaPcpServicoVO[J]);

          for K := 0 to TPcpServicoVO(pObjeto.ListaPcpOpDetalheVO[I].ListaPcpServicoVO[J]).ListaPcpColabradorVO.Count -1 do
          begin
            TPcpServicoVO(pObjeto.ListaPcpOpDetalheVO[I].ListaPcpServicoVO[J]).ListaPcpColabradorVO[K].IdPcpServico := IDServico;
            TT2TiORM.Inserir(TPcpServicoVO(pObjeto.ListaPcpOpDetalheVO[I].ListaPcpServicoVO[J]).ListaPcpColabradorVO[K]);
          end;

          for K := 0 to TPcpServicoVO(pObjeto.ListaPcpOpDetalheVO[I].ListaPcpServicoVO[J]).ListaPcpServicoEquipamentoVO.Count -1 do
          begin
            TPcpServicoVO(pObjeto.ListaPcpOpDetalheVO[I].ListaPcpServicoVO[J]).ListaPcpServicoEquipamentoVO[K].IdPcpServico := IDServico;
            TT2TiORM.Inserir(TPcpServicoVO(pObjeto.ListaPcpOpDetalheVO[I].ListaPcpServicoVO[J]).ListaPcpServicoEquipamentoVO[K]);
          end;
        end;
      end;
    finally
    end;
    Consulta('ID = ' + IntToStr(UltimoID), '0');
  finally
  end;
end;

class function TPcpOpController.Altera(pObjeto: TPcpOpCabecalhoVO): boolean;
begin
  try
    Result := TT2TiORM.Alterar(pObjeto);
  finally
  end;
end;

class function TPcpOpController.Exclui(pId: integer): boolean;
var
  ObjetoLocal: TPcpOpCabecalhoVO;
begin
  try
    ObjetoLocal := TPcpOpCabecalhoVO.Create;
    ObjetoLocal.Id := pId;
    Result := TT2TiORM.Excluir(ObjetoLocal);
  finally
    FreeAndNil(ObjetoLocal)
  end;
end;

class function TPcpOpController.ExcluiColaborador(pId: integer): boolean;
var
  ObjetoLocal: TPcpServicoColaboradorVO;
begin
  try
    ObjetoLocal := TPcpServicoColaboradorVO.Create;
    ObjetoLocal.Id := pId;
    Result := TT2TiORM.Excluir(ObjetoLocal);
  finally
    FreeAndNil(ObjetoLocal)
  end;
end;

class function TPcpOpController.ExcluiEquipamento(pId: integer): boolean;
var
  ObjetoLocal: TPcpServicoEquipamentoVO;
begin
  try
    ObjetoLocal := TPcpServicoEquipamentoVO.Create;
    ObjetoLocal.Id := pId;
    Result := TT2TiORM.Excluir(ObjetoLocal);
  finally
    FreeAndNil(ObjetoLocal)
  end;

end;

class function TPcpOpController.ExcluiInstrucao(pId: integer): boolean;
var
  ObjetoLocal: TPcpInstrucaoOpVO;
begin
  try
    ObjetoLocal := TPcpInstrucaoOpVO.Create;
    ObjetoLocal.Id := pId;
    Result := TT2TiORM.Excluir(ObjetoLocal);
  finally
    FreeAndNil(ObjetoLocal)
  end;
end;

class function TPcpOpController.ExcluiItem(pId: integer): boolean;
var
  ObjetoLocal: TPcpOpDetalheVO;
begin
  try
    ObjetoLocal := TPcpOpDetalheVO.Create;
    ObjetoLocal.Id := pId;
    Result := TT2TiORM.Excluir(ObjetoLocal);
  finally
    FreeAndNil(ObjetoLocal)
  end;
end;

class function TPcpOpController.ExcluiServico(pId: integer): boolean;
var
  ObjetoLocal: TPcpServicoVO;
begin
  try
    ObjetoLocal := TPcpServicoVO.Create;
    ObjetoLocal.Id := pId;
    Result := TT2TiORM.Excluir(ObjetoLocal);
  finally
    FreeAndNil(ObjetoLocal)
  end;
end;

initialization
  Classes.RegisterClass(TPcpOpController);

finalization
  Classes.UnRegisterClass(TPcpOpController);

end.
