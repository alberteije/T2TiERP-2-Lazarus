{*******************************************************************************
Title: T2TiPDV
Description: Controle de importações

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
           alberteije@gmail.com

@author T2Ti.COM
@version 2.0
*******************************************************************************}
unit ImportaController;

{$mode objfpc}{$H+}

interface
uses
  Classes, Dialogs, SysUtils, DB, LCLIntf, LCLType, LMessages, Forms, FileUtil,
  ZDataSet, Biblioteca, FPJSON;
type
  TImportaController = class
  private
  protected
  public
    class function ImportarDadosDoPDV(pPathLocal: String): Boolean;
    class procedure GravarIntegracaoPDV(Identificador: String);
  end;


implementation

uses
  T2TiORM,
  IntegracaoPdvVO, NotaFiscalCabecalhoVO, NotaFiscalDetalheVO, R06VO, R07VO,
  EcfVendaCabecalhoVO, EcfVendaDetalheVO, EcfTotalTipoPagamentoVO, EcfMovimentoVO,
  EcfSuprimentoVO, EcfSangriaVO, EcfFechamentoVO, R02VO, R03VO, Sintegra60mVO,
  Sintegra60aVO,
  LogImportacaoController, ControleEstoqueController;

{ TImportaController }

{
  Procedimento que faz o controle de importação dos registros que estão no arquivo
}
class function TImportaController.ImportarDadosDoPDV(pPathLocal: String): Boolean;
var
  ObjetoIntegracaoPdvVO: TIntegracaoPdvVO;
  ObjetoNotaFiscalCabecalhoVO: TNotaFiscalCabecalhoVO;
  ObjetoEcfVendaCabecalhoVO: TEcfVendaCabecalhoVO;
  ObjetoR02VO: TR02VO;
  ObjetoR06VO: TR06VO;
  ObjetoEcfMovimentoVO: TEcfMovimentoVO;
  ObjetoSintegra60MVO: TSintegra60mVO;

  Filtro, Identificador, Objeto, NomeCaixa, Tupla: String;

  ArquivoTexto: TextFile;
  ListaParametros: TStringList;

  I, Contador: Integer;
begin
  try
    FormatSettings.DecimalSeparator := '.';

    Application.ProcessMessages;

    // Para contar o número de linhas
    Contador := 0;

    // Prepara o arquivo para ser utilizado
    AssignFile(ArquivoTexto, pPathLocal);
    Reset(ArquivoTexto);

    // Enquanto não chegar no final do arquivo que está sendo importado...
    while not Eof(ArquivoTexto) do
    begin
      try
        // Le uma linha do arquivo e armazena na variável Tupla
        Read(ArquivoTexto, Tupla);
        Inc(Contador);

        // Se houver dados na linha
        if Trim(Tupla) <> '' then
        begin

          // Identificador : Nome do Arquivo + Número da Linha
          Identificador := ExtractFileName(pPathLocal) + '_' + IntToStr(Contador);

          // Carrega os detalhes que vem no nome do arquivo numa lista para utilização
          ListaParametros := TStringList.Create;
          ExtractStrings(['_'],[], PChar(Identificador), ListaParametros);
          Objeto := ListaParametros[0];
          NomeCaixa := ListaParametros[1];

          // Consulta se o registro já foi inserido
          Filtro := 'IDENTIFICA = ' + QuotedStr(Identificador);
          ObjetoIntegracaoPdvVO := TIntegracaoPdvVO.Create;
          ObjetoIntegracaoPdvVO := TIntegracaoPdvVO(TT2TiORM.ConsultarUmObjeto(ObjetoIntegracaoPdvVO, Filtro, True));

          // Só continua se o identificador não foi processado, ou seja, se a linha não foi gravada ainda na retaguarda
          if not Assigned(ObjetoIntegracaoPdvVO) then
          begin

            {$Region 'NF'}
            if Objeto = 'NF' then
            begin
              ObjetoNotaFiscalCabecalhoVO := TNotaFiscalCabecalhoVO(ObjetoNotaFiscalCabecalhoVO.ToObject(Tupla));

              ObjetoNotaFiscalCabecalhoVO.IdGeradoCaixa := ObjetoNotaFiscalCabecalhoVO.Id;
              ObjetoNotaFiscalCabecalhoVO.NomeCaixa := NomeCaixa;
              ObjetoNotaFiscalCabecalhoVO.DataSincronizacao := Date;
              ObjetoNotaFiscalCabecalhoVO.HoraSincronizacao := TimeToStr(Now);
              ObjetoNotaFiscalCabecalhoVO.Id := 0;

              TT2TiORM.Inserir(ObjetoNotaFiscalCabecalhoVO);

              // Detalhes
              for I := 0 to Pred(ObjetoNotaFiscalCabecalhoVO.ListaNotaFiscalDetalheVO.Count) do
              begin
                ObjetoNotaFiscalCabecalhoVO.ListaNotaFiscalDetalheVO[I].IdGeradoCaixa := ObjetoNotaFiscalCabecalhoVO.ListaNotaFiscalDetalheVO[I].Id;
                ObjetoNotaFiscalCabecalhoVO.ListaNotaFiscalDetalheVO[I].NomeCaixa := NomeCaixa;
                ObjetoNotaFiscalCabecalhoVO.ListaNotaFiscalDetalheVO[I].DataSincronizacao := Date;
                ObjetoNotaFiscalCabecalhoVO.ListaNotaFiscalDetalheVO[I].HoraSincronizacao := TimeToStr(Now);
                ObjetoNotaFiscalCabecalhoVO.ListaNotaFiscalDetalheVO[I].Id := 0;

                TT2TiORM.Inserir(ObjetoNotaFiscalCabecalhoVO.ListaNotaFiscalDetalheVO[I]);

                if ObjetoNotaFiscalCabecalhoVO.ListaNotaFiscalDetalheVO[I].MovimentaEstoque = 'S' then
                  TControleEstoqueController.AtualizarEstoque(ObjetoNotaFiscalCabecalhoVO.ListaNotaFiscalDetalheVO[I].Quantidade, ObjetoNotaFiscalCabecalhoVO.ListaNotaFiscalDetalheVO[I].IdProduto);
              end;

              GravarIntegracaoPDV(Identificador);
            end
            {$EndRegion 'NF'}

            {$Region 'VENDA'}
            else if Objeto = 'VENDA' then
            begin
              ObjetoEcfVendaCabecalhoVO := TEcfVendaCabecalhoVO(ObjetoEcfVendaCabecalhoVO.ToObject(Tupla));

              ObjetoEcfVendaCabecalhoVO.IdGeradoCaixa := ObjetoEcfVendaCabecalhoVO.Id;
              ObjetoEcfVendaCabecalhoVO.NomeCaixa := NomeCaixa;
              ObjetoEcfVendaCabecalhoVO.DataSincronizacao := Date;
              ObjetoEcfVendaCabecalhoVO.HoraSincronizacao := TimeToStr(Now);
              ObjetoEcfVendaCabecalhoVO.Id := 0;

              TT2TiORM.Inserir(ObjetoEcfVendaCabecalhoVO);

              for I := 0 to Pred(ObjetoEcfVendaCabecalhoVO.ListaEcfVendaDetalheVO.Count) do
              begin
                ObjetoEcfVendaCabecalhoVO.ListaEcfVendaDetalheVO[I].IdGeradoCaixa := ObjetoEcfVendaCabecalhoVO.ListaEcfVendaDetalheVO[I].Id;
                ObjetoEcfVendaCabecalhoVO.ListaEcfVendaDetalheVO[I].NomeCaixa := NomeCaixa;
                ObjetoEcfVendaCabecalhoVO.ListaEcfVendaDetalheVO[I].DataSincronizacao := Date;
                ObjetoEcfVendaCabecalhoVO.ListaEcfVendaDetalheVO[I].HoraSincronizacao := TimeToStr(Now);
                ObjetoEcfVendaCabecalhoVO.ListaEcfVendaDetalheVO[I].Id := 0;

                TT2TiORM.Inserir(ObjetoEcfVendaCabecalhoVO.ListaEcfVendaDetalheVO[I]);

                if ObjetoEcfVendaCabecalhoVO.ListaEcfVendaDetalheVO[I].MovimentaEstoque = 'S' then
                  TControleEstoqueController.AtualizarEstoque(ObjetoEcfVendaCabecalhoVO.ListaEcfVendaDetalheVO[I].Quantidade, ObjetoEcfVendaCabecalhoVO.ListaEcfVendaDetalheVO[I].IdEcfProduto);
              end;

              // TotalTipoPagamento
              for I := 0 to Pred(ObjetoEcfVendaCabecalhoVO.ListaEcfTotalTipoPagamentoVO.Count) do
              begin
                ObjetoEcfVendaCabecalhoVO.ListaEcfTotalTipoPagamentoVO[I].IdGeradoCaixa := ObjetoEcfVendaCabecalhoVO.ListaEcfTotalTipoPagamentoVO[I].Id;
                ObjetoEcfVendaCabecalhoVO.ListaEcfTotalTipoPagamentoVO[I].NomeCaixa := NomeCaixa;
                ObjetoEcfVendaCabecalhoVO.ListaEcfTotalTipoPagamentoVO[I].DataSincronizacao := Date;
                ObjetoEcfVendaCabecalhoVO.ListaEcfTotalTipoPagamentoVO[I].HoraSincronizacao := TimeToStr(Now);
                ObjetoEcfVendaCabecalhoVO.ListaEcfTotalTipoPagamentoVO[I].Id := 0;

                TT2TiORM.Inserir(ObjetoEcfVendaCabecalhoVO.ListaEcfTotalTipoPagamentoVO[I]);
              end;

              GravarIntegracaoPDV(Identificador);
            end
            {$EndRegion 'VENDA'}

            {$Region 'MOVIMENTO'}
            else if Objeto = 'MOVIMENTO' then
            begin
              ObjetoEcfMovimentoVO := TEcfMovimentoVO.Create;
              ObjetoEcfMovimentoVO := TEcfMovimentoVO(ObjetoEcfMovimentoVO.ToObject(Tupla));

              ObjetoEcfMovimentoVO.IdGeradoCaixa := ObjetoEcfMovimentoVO.Id;
              ObjetoEcfMovimentoVO.NomeCaixa := NomeCaixa;
              ObjetoEcfMovimentoVO.DataSincronizacao := Date;
              ObjetoEcfMovimentoVO.HoraSincronizacao := TimeToStr(Now);
              ObjetoEcfMovimentoVO.Id := 0;

              TT2TiORM.Inserir(ObjetoEcfMovimentoVO);

              // Suprimento
              for I := 0 to Pred(ObjetoEcfMovimentoVO.ListaEcfSuprimentoVO.Count) do
              begin
                ObjetoEcfMovimentoVO.ListaEcfSuprimentoVO[I].IdGeradoCaixa := ObjetoEcfMovimentoVO.ListaEcfSuprimentoVO[I].Id;
                ObjetoEcfMovimentoVO.ListaEcfSuprimentoVO[I].NomeCaixa := NomeCaixa;
                ObjetoEcfMovimentoVO.ListaEcfSuprimentoVO[I].DataSincronizacao := Date;
                ObjetoEcfMovimentoVO.ListaEcfSuprimentoVO[I].HoraSincronizacao := TimeToStr(Now);
                ObjetoEcfMovimentoVO.ListaEcfSuprimentoVO[I].Id := 0;

                TT2TiORM.Inserir(ObjetoEcfMovimentoVO.ListaEcfSuprimentoVO[I]);
              end;

              // Sangria
              for I := 0 to Pred(ObjetoEcfMovimentoVO.ListaEcfSangriaVO.Count) do
              begin
                ObjetoEcfMovimentoVO.ListaEcfSangriaVO[I].IdGeradoCaixa := ObjetoEcfMovimentoVO.ListaEcfSangriaVO[I].Id;
                ObjetoEcfMovimentoVO.ListaEcfSangriaVO[I].NomeCaixa := NomeCaixa;
                ObjetoEcfMovimentoVO.ListaEcfSangriaVO[I].DataSincronizacao := Date;
                ObjetoEcfMovimentoVO.ListaEcfSangriaVO[I].HoraSincronizacao := TimeToStr(Now);
                ObjetoEcfMovimentoVO.ListaEcfSangriaVO[I].Id := 0;

                TT2TiORM.Inserir(ObjetoEcfMovimentoVO.ListaEcfSangriaVO[I]);
              end;

              // Fechamento
              for I := 0 to Pred(ObjetoEcfMovimentoVO.ListaEcfFechamentoVO.Count) do
              begin
                ObjetoEcfMovimentoVO.ListaEcfFechamentoVO[I].IdGeradoCaixa := ObjetoEcfMovimentoVO.ListaEcfFechamentoVO[I].Id;
                ObjetoEcfMovimentoVO.ListaEcfFechamentoVO[I].NomeCaixa := NomeCaixa;
                ObjetoEcfMovimentoVO.ListaEcfFechamentoVO[I].DataSincronizacao := Date;
                ObjetoEcfMovimentoVO.ListaEcfFechamentoVO[I].HoraSincronizacao := TimeToStr(Now);
                ObjetoEcfMovimentoVO.ListaEcfFechamentoVO[I].Id := 0;

                TT2TiORM.Inserir(ObjetoEcfMovimentoVO.ListaEcfFechamentoVO[I]);
              end;

              GravarIntegracaoPDV(Identificador);
            end
            {$EndRegion 'MOVIMENTO'}

            {$Region 'R02'}
            else if Objeto = 'R02' then
            begin
              ObjetoR02VO := TR02VO(ObjetoR02VO.ToObject(Tupla));

              ObjetoR02VO.IdGeradoCaixa := ObjetoR02VO.Id;
              ObjetoR02VO.NomeCaixa := NomeCaixa;
              ObjetoR02VO.DataSincronizacao := Date;
              ObjetoR02VO.HoraSincronizacao := TimeToStr(Now);
              ObjetoR02VO.Id := 0;

              TT2TiORM.Inserir(ObjetoR02VO);

              // Detalhes
              for I := 0 to Pred(ObjetoR02VO.ListaR03VO.Count) do
              begin
                ObjetoR02VO.ListaR03VO[I].IdGeradoCaixa := ObjetoR02VO.ListaR03VO[I].Id;
                ObjetoR02VO.ListaR03VO[I].NomeCaixa := NomeCaixa;
                ObjetoR02VO.ListaR03VO[I].DataSincronizacao := Date;
                ObjetoR02VO.ListaR03VO[I].HoraSincronizacao := TimeToStr(Now);
                ObjetoR02VO.ListaR03VO[I].Id := 0;

                TT2TiORM.Inserir(ObjetoR02VO.ListaR03VO[I]);
              end;

              GravarIntegracaoPDV(Identificador);
            end
            {$EndRegion 'R02'}

            {$Region 'R06'}
            else if Objeto = 'R06' then
            begin
              ObjetoR06VO := TR06VO(ObjetoR06VO.ToObject(Tupla));

              ObjetoR06VO.IdGeradoCaixa := ObjetoR06VO.Id;
              ObjetoR06VO.NomeCaixa := NomeCaixa;
              ObjetoR06VO.DataSincronizacao := Date;
              ObjetoR06VO.HoraSincronizacao := TimeToStr(Now);
              ObjetoR06VO.Id := 0;

              TT2TiORM.Inserir(ObjetoR06VO);

              GravarIntegracaoPDV(Identificador);
            end
            {$EndRegion 'R06'}

            {$Region 'SINTEGRA60M'}
            else if Objeto = 'SINTEGRA60M' then
            begin
              ObjetoSintegra60MVO := TSintegra60MVO(ObjetoSintegra60MVO.ToObject(Tupla));

              ObjetoSintegra60MVO.IdGeradoCaixa := ObjetoSintegra60MVO.Id;
              ObjetoSintegra60MVO.NomeCaixa := NomeCaixa;
              ObjetoSintegra60MVO.DataSincronizacao := Date;
              ObjetoSintegra60MVO.HoraSincronizacao := TimeToStr(Now);
              ObjetoSintegra60MVO.Id := 0;

              TT2TiORM.Inserir(ObjetoSintegra60MVO);

              // Detalhes
              for I := 0 to Pred(ObjetoSintegra60MVO.ListaSintegra60AVO.Count) do
              begin
                ObjetoSintegra60MVO.ListaSintegra60AVO[I].IdGeradoCaixa := ObjetoSintegra60MVO.ListaSintegra60AVO[I].Id;
                ObjetoSintegra60MVO.ListaSintegra60AVO[I].NomeCaixa := NomeCaixa;
                ObjetoSintegra60MVO.ListaSintegra60AVO[I].DataSincronizacao := Date;
                ObjetoSintegra60MVO.ListaSintegra60AVO[I].HoraSincronizacao := TimeToStr(Now);
                ObjetoSintegra60MVO.ListaSintegra60AVO[I].Id := 0;

                TT2TiORM.Inserir(ObjetoSintegra60MVO.ListaSintegra60AVO[I]);
              end;

              GravarIntegracaoPDV(Identificador);
            end;
            {$EndRegion 'SINTEGRA60M'}

          end;
        end;

      except
        // Se ocorrer algum erro, grava o log de importação
        on E: Exception do
          TLogImportacaoController.GravarLogImportacao(Tupla, E.Message);
      end;
      Readln(ArquivoTexto);
    end;
  finally
    FormatSettings.DecimalSeparator := ',';
    ListaParametros := nil;
    ObjetoIntegracaoPdvVO := nil;
    ObjetoNotaFiscalCabecalhoVO := nil;
    ObjetoEcfVendaCabecalhoVO := nil;
    ObjetoEcfMovimentoVO := nil;
    ObjetoR02VO := nil;
    ObjetoR06VO := nil;
    CloseFile(ArquivoTexto);
    Result:=true;
  end;
end;

{
  Grava os dados do registro na tabela integracao_pdv
}
class procedure TImportaController.GravarIntegracaoPDV(Identificador: String);
var
  ObjetoIntegracaoPdvVO: TIntegracaoPdvVO;
begin
  try
    ObjetoIntegracaoPdvVO := TIntegracaoPdvVO.Create;
    ObjetoIntegracaoPdvVO.Identifica := Identificador;
    ObjetoIntegracaoPdvVO.DataIntegracao := Date;
    ObjetoIntegracaoPdvVO.HoraIntegracao := TimeToStr(Now);

    TT2TiORM.Inserir(ObjetoIntegracaoPdvVO);
  finally
    FreeAndNil(ObjetoIntegracaoPdvVO);
  end;
end;


end.
