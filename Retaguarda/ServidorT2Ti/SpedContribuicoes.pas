unit SpedContribuicoes;

{$mode objfpc}{$H+}

interface

uses
  BrookAction, BrookHTTPConsts, HTTPDefs, Classes, sysutils, ACBrEFDBlocos, ACBrEPCBlocos, Biblioteca, Constantes;

type
  TSpedContribuicoes = class(TBrookAction)
  private
    procedure GerarBloco0;
    procedure GerarBlocoA;
    procedure GerarBlocoC;
    procedure GerarBlocoD;
    procedure GerarBlocoF;
    procedure GerarBlocoI;
    procedure GerarBlocoM;
    procedure GerarBloco1;
    function GerarArquivoSpedContribuicoes: Boolean;
  public
    procedure Request({%H-}ARequest: TRequest; {%H-}AResponse: TResponse); override;
  end;

implementation

uses
  T2TiORM, UDataModule,
  // VOs
  EmpresaVO, EmpresaEnderecoVO, ContadorVO, UnidadeProdutoVO, ProdutoVO, EcfImpressoraVO,
  EcfNotaFiscalCabecalhoVO, ViewSpedC321VO, ViewSpedC370VO, ViewSpedC390VO, ViewSpedC425VO, ViewSpedC490VO, EcfR02VO,
  EcfR03VO, EcfVendaCabecalhoVO, EcfVendaDetalheVO, FiscalApuracaoIcmsVO, ProdutoAlteracaoItemVO,
  ViewSpedNfeEmitenteVO, ViewSpedNfeDestinatarioVO, ViewSpedNfeItemVO, UnidadeConversaoVO,
  TributOperacaoFiscalVO, NfeTransporteVO, ViewSpedNfeDetalheVO, ViewSpedC190VO,
  ViewSpedC300VO, NfeCabecalhoVO;

var
  Empresa: TEmpresaVO;
  VersaoLeiaute, TipoEscrituracao, IdEmpresa, IdContador: Integer;
  DataInicial, DataFinal, Arquivo, FiltroLocal: String;

procedure TSpedContribuicoes.Request(ARequest: TRequest; AResponse: TResponse);
var
  ArquivoStream: TFileStream;
begin
  DataInicial := Values['dataini'].AsString; //'2014-01-01';
  DataFinal := Values['datafim'].AsString; //'2014-12-31';
  VersaoLeiaute := Values['leiaute'].AsInteger; //3;
  TipoEscrituracao := Values['escrituracao'].AsInteger; //0;
  IdEmpresa := Values['empresa'].AsInteger; //1;
  IdContador := Values['contador'].AsInteger; //1;

  FDataModule := TFDataModule.Create(Nil);

  GerarArquivoSpedContribuicoes;

  FDataModule.Free;
  ArquivoStream := TFileStream.Create(Arquivo, fmOpenRead);
  AResponse.ContentStream := ArquivoStream;
end;

{$REGION 'Geração Arquivo'}

{$REGION 'BLOCO 0: ABERTURA, IDENTIFICAÇÃO E REFERÊNCIAS'}
procedure TSpedContribuicoes.GerarBloco0;
var
  Contador: TContadorVO;
  ListaProduto: TListaViewSpedNfeItemVO;
  ListaEmitente: TListaViewSpedNfeEmitenteVO;
  ListaDestinatario: TListaViewSpedNfeDestinatarioVO;
  ListaUnidade: TListaUnidadeProdutoVO;
  ListaProdutoAlterado: TListaProdutoAlteracaoItemVO;
  ListaOperacaoFiscal: TListaTributOperacaoFiscalVO;
  UnidadeConversao: TUnidadeConversaoVO;
  UnidadeProduto: TUnidadeProdutoVO;
  ListaParticipante: TStringList;
  ListaSiglaUnidade: TStringList;
  i: Integer;
begin
  try
    Empresa := TEmpresaVO.Create;
	Empresa := TEmpresaVO(TT2TiORM.ConsultarUmObjeto(Empresa, 'ID=' + IntToStr(IdEmpresa), True));
    Empresa.EnderecoPrincipal := TEmpresaEnderecoVO.Create;
    Empresa.EnderecoPrincipal := TEmpresaEnderecoVO(TT2TiORM.ConsultarUmObjeto(Empresa.EnderecoPrincipal, 'PRINCIPAL=' + QuotedStr('S'), True));
    Contador := TContadorVO.Create;
    Contador := TContadorVO(TT2TiORM.ConsultarUmObjeto(Contador, 'ID=' + IntToStr(IdContador), True));
    ListaEmitente := TListaViewSpedNfeEmitenteVO(TT2TiORM.Consultar(TViewSpedNfeEmitenteVO.Create, 'ID in (select ID_FORNECEDOR from NFE_CABECALHO where DATA_HORA_EMISSAO BETWEEN ' + QuotedStr(DataInicial) + ' and ' + QuotedStr(DataFinal) + ')', False));
    ListaDestinatario := TListaViewSpedNfeDestinatarioVO(TT2TiORM.Consultar(TViewSpedNfeDestinatarioVO.Create, 'ID in (select ID_CLIENTE from NFE_CABECALHO where DATA_HORA_EMISSAO BETWEEN ' + QuotedStr(DataInicial) + ' and ' + QuotedStr(DataFinal) + ')', False));
    ListaProduto := TListaViewSpedNfeItemVO(TT2TiORM.Consultar(TViewSpedNfeItemVO.Create, 'ID in (select ID_PRODUTO from NFE_DETALHE JOIN NFE_CABECALHO ON NFE_DETALHE.ID_NFE_CABECALHO = NFE_CABECALHO.ID' +
                                                           ' where NFE_CABECALHO.DATA_HORA_EMISSAO BETWEEN ' + QuotedStr(DataInicial) + ' and ' + QuotedStr(DataFinal) + ')', False));
    ListaProdutoAlterado := TListaProdutoAlteracaoItemVO(TT2TiORM.Consultar(TProdutoAlteracaoItemVO.Create, 'DATA_INICIAL BETWEEN ' + QuotedStr(DataInicial) + ' and ' + QuotedStr(DataFinal), False));
    ListaOperacaoFiscal := TListaTributOperacaoFiscalVO(TT2TiORM.Consultar(TTributOperacaoFiscalVO.Create, 'ID>0', False));

    with FDataModule.ACBrSpedContribuicoes.Bloco_0 do
    begin
      // REGISTRO 0000: ABERTURA DO ARQUIVO DIGITAL E IDENTIFICAÇÃO DA PESSOA JURÍDICA
      with Registro0000New do
      begin
        COD_VER := TACBrVersaoLeiaute(VersaoLeiaute);
        TIPO_ESCRIT := TACBrTipoEscrit(TipoEscrituracao);
        //IND_SIT_ESP := indSitAbertura;
        NUM_REC_ANTERIOR := ''; //Número do Recibo da Escrituração anterior a ser retificada, utilizado quando TIPO_ESCRIT for igual a 1
        NOME := Empresa.RazaoSocial;
        CNPJ := Empresa.CNPJ;
        UF := Empresa.EnderecoPrincipal.UF;
        COD_MUN := Empresa.CodigoIbgeCidade;
        //SUFRAMA := Empresa.SUFRAMA;
        IND_NAT_PJ := indNatPJSocEmpresariaGeral;
        IND_ATIV := indAtivComercio;
      end;

      // REGISTRO 0001: ABERTURA DO BLOCO 0
      with Registro0001New do
      begin
        IND_MOV := imComDados;

        // REGISTRO 0035: IDENTIFICAÇÃO DE SOCIEDADE EM CONTA DE PARTICIPAÇÃO – SCP
        { Não Implementado }

        // REGISTRO 0100: DADOS DO CONTABILISTA
        with Registro0100New do
        begin
          NOME := Contador.NOME;
          CPF := Contador.CPF;
          CRC := Contador.InscricaoCrc;
          CNPJ := Contador.CNPJ;
          CEP := Contador.CEP;
          ENDERECO := Contador.Logradouro;
          NUM := Contador.Numero;
          COMPL := Contador.Complemento;
          BAIRRO := Contador.BAIRRO;
          FONE := Contador.FONE;
          FAX := Contador.FAX;
          EMAIL := Contador.EMAIL;
          COD_MUN := Contador.MunicipioIbge;
        end; // with Registro0100New do

        // REGISTRO  0110:  REGIMES  DE  APURAÇÃO  DA  CONTRIBUIÇÃO  SOCIAL  E  DE APROPRIAÇÃO DE CRÉDITO
        with Registro0110New do
        begin
          COD_INC_TRIB  := codEscrOpIncNaoCumulativo;
          IND_APRO_CRED := indMetodoApropriacaoDireta;
          COD_TIPO_CONT := codIndTipoConExclAliqBasica;
        end;

        // REGISTRO  0111:  TABELA  DE  RECEITA  BRUTA  MENSAL  PARA  FINS  DE  RATEIO  DE CRÉDITOS COMUNS
        // REGISTRO  0120:  IDENTIFICAÇÃO  DE  PERÍODOS  DISPENSADOS  DA  ESCRITURAÇÃO FISCAL DIGITAL DAS CONTRIBUIÇÕES – EFD-CONTRIBUIÇÕES
        { Não Implementados }

        // REGISTRO 0140: TABELA DE CADASTRO DE ESTABELECIMENTO
        with Registro0140New do
        begin
          COD_EST := 'MATRIZ';
          NOME := Empresa.RazaoSocial;;
          CNPJ := Empresa.CNPJ;
          UF := Empresa.EnderecoPrincipal.UF;
          IE := Empresa.InscricaoEstadual;
          COD_MUN := Empresa.CodigoIbgeCidade;
          IM := Empresa.InscricaoMunicipal;
          //SUFRAMA := Empresa.SUFRAMA;

          // REGISTRO 0145: REGIME DE APURAÇÃO DA CONTRIBUIÇÃO PREVIDENCIÁRIA SOBRE A RECEITA BRUTA
          { Não Implementado }

          // REGISTRO 0150: TABELA DE CADASTRO DO PARTICIPANTE
          ListaParticipante := TStringList.Create;
          if assigned(ListaEmitente) then
          begin
            for i := 0 to ListaEmitente.Count - 1 do
            begin
              with Registro0150New do
              begin
                COD_PART := 'F' + IntToStr(TViewSpedNfeEmitenteVO(ListaEmitente.Items[i]).Id);
                NOME := TViewSpedNfeEmitenteVO(ListaEmitente.Items[i]).NOME;
                COD_PAIS := '01058';
                if Length(TViewSpedNfeEmitenteVO(ListaEmitente.Items[i]).CpfCnpj) = 11 then
                  CPF := TViewSpedNfeEmitenteVO(ListaEmitente.Items[i]).CpfCnpj
                else
                  CNPJ := TViewSpedNfeEmitenteVO(ListaEmitente.Items[i]).CpfCnpj;
                IE := TViewSpedNfeEmitenteVO(ListaEmitente.Items[i]).InscricaoEstadual;
                COD_MUN := TViewSpedNfeEmitenteVO(ListaEmitente.Items[i]).CodigoMunicipio;
                //SUFRAMA := TViewSpedNfeEmitenteVO(ListaEmitente.Items[i]).SUFRAMA.ToString;
                ENDERECO := TViewSpedNfeEmitenteVO(ListaEmitente.Items[i]).Logradouro;
                NUM := TViewSpedNfeEmitenteVO(ListaEmitente.Items[i]).Numero;
                COMPL := TViewSpedNfeEmitenteVO(ListaEmitente.Items[i]).Complemento;
                BAIRRO := TViewSpedNfeEmitenteVO(ListaEmitente.Items[i]).BAIRRO;
                //
                ListaParticipante.Add(COD_PART);
              end; // with Registro0150New do
            end; // for I := 0 to ListaEmitente.Count - 1 do
          end; // if assigned(ListaEmitente) then

          if assigned(ListaDestinatario) then
          begin
            for i := 0 to ListaDestinatario.Count - 1 do
            begin
              if ListaParticipante.IndexOf(TViewSpedNfeEmitenteVO(ListaDestinatario.Items[i]).CpfCnpj) = -1 then
              begin
                with Registro0150New do
                begin
                  COD_PART := 'C' + IntToStr(TViewSpedNfeEmitenteVO(ListaDestinatario.Items[i]).Id);
                  NOME := TViewSpedNfeDestinatarioVO(ListaDestinatario.Items[i]).NOME;
                  COD_PAIS := '01058';
                  if Length(TViewSpedNfeDestinatarioVO(ListaDestinatario.Items[i]).CpfCnpj) = 11 then
                    CPF := TViewSpedNfeDestinatarioVO(ListaDestinatario.Items[i]).CpfCnpj
                  else
                    CNPJ := TViewSpedNfeDestinatarioVO(ListaDestinatario.Items[i]).CpfCnpj;
                  IE := TViewSpedNfeDestinatarioVO(ListaDestinatario.Items[i]).InscricaoEstadual;
                  COD_MUN := TViewSpedNfeDestinatarioVO(ListaDestinatario.Items[i]).CodigoMunicipio;
                  //SUFRAMA := TViewSpedNfeDestinatarioVO(ListaDestinatario.Items[i]).SUFRAMA.ToString;
                  ENDERECO := TViewSpedNfeDestinatarioVO(ListaDestinatario.Items[i]).Logradouro;
                  NUM := TViewSpedNfeDestinatarioVO(ListaDestinatario.Items[i]).Numero;
                  COMPL := TViewSpedNfeDestinatarioVO(ListaDestinatario.Items[i]).Complemento;
                  BAIRRO := TViewSpedNfeDestinatarioVO(ListaDestinatario.Items[i]).BAIRRO;
                end; // with Registro0150New do
              end;
            end; // for I := 0 to ListaDestinatario.Count - 1 do
          end; // if assigned(ListaDestinatario) then

          // REGISTRO 0200: TABELA DE IDENTIFICAÇÃO DO ITEM (PRODUTO E SERVIÇOS)
          ListaSiglaUnidade := TStringList.Create;
          ListaUnidade := TListaUnidadeProdutoVO.Create;
          for i := 0 to ListaProduto.Count - 1 do
          begin
            with Registro0200New do
            begin
              COD_ITEM := IntToStr(TViewSpedNfeItemVO(ListaProduto.Items[i]).Id);
              DESCR_ITEM := TViewSpedNfeItemVO(ListaProduto.Items[i]).NOME;
              COD_BARRA := TViewSpedNfeItemVO(ListaProduto.Items[i]).GTIN;
              (* TEM QUE PREENCHER PARA INFORMAR NO 0205 *)
              COD_ANT_ITEM := '';
              UNID_INV := IntToStr(TViewSpedNfeItemVO(ListaProduto.Items[i]).IdUnidadeProduto);
              TIPO_ITEM := TACBrTipoItem(StrToInt(TViewSpedNfeItemVO(ListaProduto.Items[i]).TipoItemSped));
              COD_NCM := TViewSpedNfeItemVO(ListaProduto.Items[i]).NCM;
              EX_IPI := TViewSpedNfeItemVO(ListaProduto.Items[i]).ExTipi;
              COD_GEN := Copy(TViewSpedNfeItemVO(ListaProduto.Items[i]).NCM, 1, 2);
              COD_LST := TViewSpedNfeItemVO(ListaProduto.Items[i]).CodigoLst;
              ALIQ_ICMS := TViewSpedNfeItemVO(ListaProduto.Items[i]).AliquotaIcmsPaf;

              if ListaSiglaUnidade.IndexOf(IntToStr(TViewSpedNfeItemVO(ListaProduto.Items[i]).IdUnidadeProduto)) = -1 then
              begin
                ListaSiglaUnidade.Add(IntToStr(TViewSpedNfeItemVO(ListaProduto.Items[i]).IdUnidadeProduto));
                UnidadeProduto := TUnidadeProdutoVO.Create;
                UnidadeProduto.Id := TViewSpedNfeItemVO(ListaProduto.Items[i]).IdUnidadeProduto;
                UnidadeProduto.Sigla := TViewSpedNfeItemVO(ListaProduto.Items[i]).Sigla;
                ListaUnidade.Add(UnidadeProduto);
              end; // if ListaSiglaUnidade.IndexOf(IntToStr(TViewSpedNfeItemVO(ListaProduto.Items[i]).IdUnidadeProduto)) = -1 then
            end; // with Registro0200New do
          end; // for i := 0 to ListaProduto.Count - 1 do

          // REGISTRO 0190: IDENTIFICAÇÃO DAS UNIDADES DE MEDIDA
          for i := 0 to ListaUnidade.Count - 1 do
          begin
            with Registro0190New do
            begin
              UNID := IntToStr(TUnidadeProdutoVO(ListaUnidade.Items[i]).Id);
              DESCR := TUnidadeProdutoVO(ListaUnidade.Items[i]).Sigla;
            end;
          end;

          // REGISTRO 0205: ALTERAÇÃO DO ITEM
          for i := 0 to ListaProdutoAlterado.Count - 1 do
          begin
            with Registro0205New do
            begin
              DESCR_ANT_ITEM := TProdutoAlteracaoItemVO(ListaProdutoAlterado.Items[i]).NOME;
              DT_INI := TProdutoAlteracaoItemVO(ListaProdutoAlterado.Items[i]).DataInicial;
              DT_FIN := TProdutoAlteracaoItemVO(ListaProdutoAlterado.Items[i]).DataFinal;
              COD_ANT_ITEM := TProdutoAlteracaoItemVO(ListaProdutoAlterado.Items[i]).Codigo;
            end; // with Registro0205New do
          end; // for i := 0 to ListaProdutoAlterado.Count - 1 do
        end;

        // REGISTRO 0206: CÓDIGO DE PRODUTO CONFORME TABELA PUBLICADA PELA ANP (COMBUSTÍVEIS)
        { Não Implementado }

        // REGISTRO 0208: CÓDIGO DE GRUPOS POR MARCA COMERCIAL– REFRI (BEBIDAS FRIAS).
        { Não Implementado }

        // REGISTRO 0400: TABELA DE NATUREZA DA OPERAÇÃO/PRESTAÇÃO
        for i := 0 to ListaOperacaoFiscal.Count - 1 do
        begin
          with Registro0400New do
          begin
            COD_NAT := IntToStr(TTributOperacaoFiscalVO(ListaOperacaoFiscal.Items[i]).Id);
            DESCR_NAT := TTributOperacaoFiscalVO(ListaOperacaoFiscal.Items[i]).DescricaoNaNf;
          end; // with Registro0400New do
        end; // for i := 0 to ListaOperacaoFiscal.Count - 1 do

        // REGISTRO 0450: TABELA DE INFORMAÇÃO COMPLEMENTAR DO DOCUMENTO FISCAL
        { Não Implementado }

        // REGISTRO 0500: PLANO DE CONTAS CONTÁBEIS
        { Não Implementado }

        // REGISTRO 0600: CENTRO DE CUSTOS
        { Não Implementado }

      end; // with Registro0001New do
    end;
  finally
    Contador := Nil;
    ListaProduto := Nil;
    ListaEmitente := Nil;
    ListaDestinatario := Nil;
    ListaUnidade := Nil;
    ListaProdutoAlterado := Nil;
    ListaOperacaoFiscal := Nil;
    ListaParticipante := Nil;
    ListaSiglaUnidade := Nil;
  end;
end;
{$ENDREGION}

{$REGION 'BLOCO A: DOCUMENTOS FISCAIS - SERVIÇOS (NÃO SUJEITOS AO ICMS)'}
procedure TSpedContribuicoes.GerarBlocoA;
begin
  try
    with FDataModule.ACBrSpedContribuicoes.Bloco_A do
    begin
      // REGISTRO A001: ABERTURA DO BLOCO A
      with RegistroA001New do
      begin
        IND_MOV := imSemDados;
      end; // with RegistroA100New do
    end;
  finally
  end;
end;
{$ENDREGION 'BLOCO A: DOCUMENTOS FISCAIS - SERVIÇOS (NÃO SUJEITOS AO ICMS)'}

{$REGION 'BLOCO C: DOCUMENTOS FISCAIS I - MERCADORIAS (ICMS/IPI)'}
procedure TSpedContribuicoes.GerarBlocoC;
var
  ListaImpressora: TListaEcfImpressoraVO;
  ListaNF2Cabecalho: TListaEcfNotaFiscalCabecalhoVO;
  ListaNF2CabecalhoCanceladas: TListaEcfNotaFiscalCabecalhoVO;
  ListaNFeCabecalho: TListaNfeCabecalhoVO;
  ListaNFeDetalhe: TListaViewSpedNfeDetalheVO;
  ListaNFeAnalitico: TListaViewSpedC190VO;
  ListaC300: TListaViewSpedC300VO;
  ListaC321: TListaViewSpedC321VO;
  ListaC370: TListaViewSpedC370VO;
  ListaC390: TListaViewSpedC390VO;
  ListaC425: TListaViewSpedC425VO;
  ListaC490: TListaViewSpedC490VO;
  ListaR02: TListaEcfR02VO;
  ListaR03: TListaEcfR03VO;
  ListaR04: TListaEcfVendaCabecalhoVO;
  ListaR05: TListaEcfVendaDetalheVO;
  i, j, k, l, m, g: Integer;
  //
  NfeTransporte: TNfeTransporteVO;
  EcfNotaFiscalCabecalho: TEcfNotaFiscalCabecalhoVO;
  Produto: TProdutoVO;
begin
  try
    with FDataModule.ACBrSpedContribuicoes.Bloco_C do
    begin
      // REGISTRO C001: ABERTURA DO BLOCO C
      with RegistroC001New do
      begin
        IND_MOV := imComDados;

        ListaNF2Cabecalho := TListaEcfNotaFiscalCabecalhoVO(TT2TiORM.Consultar(TEcfNotaFiscalCabecalhoVO.Create, 'DATA_EMISSAO BETWEEN ' + QuotedStr(DataInicial) + ' and ' + QuotedStr(DataFinal), False));
        ListaNF2CabecalhoCanceladas := TListaEcfNotaFiscalCabecalhoVO(TT2TiORM.Consultar(TEcfNotaFiscalCabecalhoVO.Create, 'CANCELADA = ' + QuotedStr('S') + ' and DATA_EMISSAO BETWEEN ' + QuotedStr(DataInicial) + ' and ' + QuotedStr(DataFinal), False));
        ListaNFeCabecalho := TListaNfeCabecalhoVO(TT2TiORM.Consultar(TNfeCabecalhoVO.Create, 'DATA_HORA_EMISSAO BETWEEN ' + QuotedStr(DataInicial) + ' and ' + QuotedStr(DataFinal), False));

        // REGISTRO C010: IDENTIFICAÇÃO DO ESTABELECIMENTO
        with RegistroC010New do
        begin
          CNPJ := Empresa.Cnpj;
          IND_ESCRI := IndEscriIndividualizado;     // 1 – Apuração com base nos registros de consolidaçãodas operações por NF-e (C180 e C190) e por ECF (C490);
                                                    // 2 – Apuração com base no registro individualizado de NF-e (C100 e C170) e de ECF (C400)

          if assigned(ListaNFeCabecalho) then
          begin
            for i := 0 to ListaNFeCabecalho.Count - 1 do
            begin
              // REGISTRO C100: NOTA FISCAL (CÓDIGO 01), NOTA FISCAL AVULSA (CÓDIGO 1B), NOTA FISCAL DE PRODUTOR (CÓDIGO 04), NF-e (CÓDIGO 55) e NFC-e (CÓDIGO 65)
              with RegistroC100New do
              begin
                IND_OPER := TACBrTipoOperacao(TNfeCabecalhoVO(ListaNFeCabecalho.Items[i]).TipoOperacao);
                IND_EMIT := edEmissaoPropria;
                if TNfeCabecalhoVO(ListaNFeCabecalho.Items[i]).IdCliente > 0 then
                  COD_PART := 'C' + IntToStr(TNfeCabecalhoVO(ListaNFeCabecalho.Items[i]).IdCliente)
                else
                  COD_PART := 'F' + IntToStr(TNfeCabecalhoVO(ListaNFeCabecalho.Items[i]).IdFornecedor);
                COD_MOD := TNfeCabecalhoVO(ListaNFeCabecalho.Items[i]).CodigoModelo;

                (*
                  4.1.2- Tabela Situação do Documento
                  Código Descrição
                  00 Documento regular
                  01 Documento regular extemporâneo
                  02 Documento cancelado
                  03 Documento cancelado extemporâneo
                  04 NFe denegada
                  05 Nfe – Numeração inutilizada
                  06 Documento Fiscal Complementar
                  07 Documento Fiscal Complementar extemporâneo.
                  08 Documento Fiscal emitido com base em Regime Especial ou Norma Específica
                *)
                if TNfeCabecalhoVO(ListaNFeCabecalho.Items[i]).StatusNota = 0 then
                  COD_SIT := sdRegular
                else
                  COD_SIT := sdCancelado;
                SER := TNfeCabecalhoVO(ListaNFeCabecalho.Items[i]).Serie;
                NUM_DOC := TNfeCabecalhoVO(ListaNFeCabecalho.Items[i]).Numero;
                CHV_NFE := TNfeCabecalhoVO(ListaNFeCabecalho.Items[i]).ChaveAcesso;
                DT_DOC := TNfeCabecalhoVO(ListaNFeCabecalho.Items[i]).DataHoraEmissao;
                DT_E_S := TNfeCabecalhoVO(ListaNFeCabecalho.Items[i]).DataHoraEntradaSaida;
                VL_DOC := TNfeCabecalhoVO(ListaNFeCabecalho.Items[i]).ValorTotal;
                IND_PGTO := TACBrTipoPagamento(TNfeCabecalhoVO(ListaNFeCabecalho.Items[i]).IndicadorFormaPagamento);
                VL_DESC := TNfeCabecalhoVO(ListaNFeCabecalho.Items[i]).ValorDesconto;
                VL_ABAT_NT := 0;
                VL_MERC := TNfeCabecalhoVO(ListaNFeCabecalho.Items[i]).ValorTotalProdutos;
                //
                NfeTransporte := TNfeTransporteVO.Create;
                NfeTransporte := TNfeTransporteVO(TT2TiORM.ConsultarUmObjeto(NfeTransporte, 'ID_NFE_CABECALHO=' + IntToStr(TNfeCabecalhoVO(ListaNFeCabecalho.Items[i]).Id), False));

                if Assigned(NfeTransporte) then
                begin
                  IND_FRT := TACBrTipoFrete(NfeTransporte.ModalidadeFrete);
                  NfeTransporte := Nil;
                end;

                VL_FRT := TNfeCabecalhoVO(ListaNFeCabecalho.Items[i]).ValorFrete;
                VL_SEG := TNfeCabecalhoVO(ListaNFeCabecalho.Items[i]).ValorSeguro;
                VL_OUT_DA := TNfeCabecalhoVO(ListaNFeCabecalho.Items[i]).ValorDespesasAcessorias;
                VL_BC_ICMS := TNfeCabecalhoVO(ListaNFeCabecalho.Items[i]).BaseCalculoIcms;
                VL_ICMS := TNfeCabecalhoVO(ListaNFeCabecalho.Items[i]).ValorIcms;
                VL_BC_ICMS_ST := TNfeCabecalhoVO(ListaNFeCabecalho.Items[i]).BaseCalculoIcmsSt;
                VL_ICMS_ST := TNfeCabecalhoVO(ListaNFeCabecalho.Items[i]).ValorIcmsSt;
                VL_IPI := TNfeCabecalhoVO(ListaNFeCabecalho.Items[i]).ValorIpi;
                VL_PIS := TNfeCabecalhoVO(ListaNFeCabecalho.Items[i]).ValorPis;
                VL_COFINS := TNfeCabecalhoVO(ListaNFeCabecalho.Items[i]).ValorCofins;
                VL_PIS_ST := 0;
                VL_COFINS_ST := 0;

                // REGISTRO C110: COMPLEMENTO  DO  DOCUMENTO  -  INFORMAÇÃO  COMPLEMENTAR  DA NOTA FISCAL (CÓDIGOS 01, 1B, 04 e 55)
                { Não Implementado }

                // REGISTRO C111: PROCESSO REFERENCIADO
                { Não Implementado }

                // REGISTRO  C120:  COMPLEMENTO  DO  DOCUMENTO  -  OPERAÇÕES DE  IMPORTAÇÃO (CÓDIGO 01)
                { Não Implementado }

                try
                  // REGISTRO  C170:  COMPLEMENTO  DO  DOCUMENTO  -  ITENS  DO  DOCUMENTO (CÓDIGOS 01, 1B, 04 e 55)
                  ListaNFeDetalhe := TListaViewSpedNfeDetalheVO(TT2TiORM.Consultar(TViewSpedNfeDetalheVO.Create, 'ID_NFE_CABECALHO=' + IntToStr(TNfeCabecalhoVO(ListaNFeCabecalho.Items[i]).Id), False));
                  if assigned(ListaNFeDetalhe) then
                  begin
                    for j := 0 to ListaNFeDetalhe.Count - 1 do
                    begin
                      with RegistroC170New do
                      begin
                        NUM_ITEM := IntToStr(TViewSpedNfeDetalheVO(ListaNFeDetalhe.Items[j]).NumeroItem);
                        COD_ITEM := TViewSpedNfeDetalheVO(ListaNFeDetalhe.Items[j]).GTIN;
                        DESCR_COMPL := TViewSpedNfeDetalheVO(ListaNFeDetalhe.Items[j]).NomeProduto;
                        QTD := TViewSpedNfeDetalheVO(ListaNFeDetalhe.Items[j]).QuantidadeComercial;
                        UNID := IntToStr(TViewSpedNfeDetalheVO(ListaNFeDetalhe.Items[j]).IdUnidadeProduto);
                        VL_ITEM := TViewSpedNfeDetalheVO(ListaNFeDetalhe.Items[j]).ValorTotal;
                        VL_DESC := TViewSpedNfeDetalheVO(ListaNFeDetalhe.Items[j]).ValorDesconto;
                        IND_MOV := mfSim;
                        //CST_ICMS := TViewSpedNfeDetalheVO(ListaNFeDetalhe.Items[j]).CstIcms;
                        CFOP := IntToStr(TViewSpedNfeDetalheVO(ListaNFeDetalhe.Items[j]).CFOP);
                        COD_NAT := IntToStr(TViewSpedNfeDetalheVO(ListaNFeDetalhe.Items[j]).IdTributOperacaoFiscal);
                        VL_BC_ICMS := TViewSpedNfeDetalheVO(ListaNFeDetalhe.Items[j]).BaseCalculoIcms;
                        ALIQ_ICMS := TViewSpedNfeDetalheVO(ListaNFeDetalhe.Items[j]).AliquotaIcms;
                        VL_ICMS := TViewSpedNfeDetalheVO(ListaNFeDetalhe.Items[j]).ValorIcms;
                        VL_BC_ICMS_ST := TViewSpedNfeDetalheVO(ListaNFeDetalhe.Items[j]).ValorBaseCalculoIcmsSt;
                        ALIQ_ST := TViewSpedNfeDetalheVO(ListaNFeDetalhe.Items[j]).AliquotaIcmsSt;
                        VL_ICMS_ST := TViewSpedNfeDetalheVO(ListaNFeDetalhe.Items[j]).ValorIcmsSt;
                        IND_APUR := iaMensal;
                        //CST_IPI := TViewSpedNfeDetalheVO(ListaNFeDetalhe.Items[j]).CstIpi;
                        COD_ENQ := TViewSpedNfeDetalheVO(ListaNFeDetalhe.Items[j]).EnquadramentoIpi;
                        VL_BC_IPI := TViewSpedNfeDetalheVO(ListaNFeDetalhe.Items[j]).ValorBaseCalculoIpi;
                        ALIQ_IPI := TViewSpedNfeDetalheVO(ListaNFeDetalhe.Items[j]).AliquotaIpi;
                        VL_IPI := TViewSpedNfeDetalheVO(ListaNFeDetalhe.Items[j]).ValorIpi;
                        //CST_PIS := TViewSpedNfeDetalheVO(ListaNFeDetalhe.Items[j]).CstPis;
                        VL_BC_PIS := TViewSpedNfeDetalheVO(ListaNFeDetalhe.Items[j]).ValorBaseCalculoPis;
                        ALIQ_PIS_PERC := TViewSpedNfeDetalheVO(ListaNFeDetalhe.Items[j]).AliquotaPisPercentual;
                        QUANT_BC_PIS := TViewSpedNfeDetalheVO(ListaNFeDetalhe.Items[j]).QuantidadeVendidaPis;
                        ALIQ_PIS_R := TViewSpedNfeDetalheVO(ListaNFeDetalhe.Items[j]).AliquotaPisReais;
                        VL_PIS := TViewSpedNfeDetalheVO(ListaNFeDetalhe.Items[j]).ValorPis;
                        //CST_COFINS := TViewSpedNfeDetalheVO(ListaNFeDetalhe.Items[j]).CstCofins;
                        VL_BC_COFINS := TViewSpedNfeDetalheVO(ListaNFeDetalhe.Items[j]).BaseCalculoCofins;
                        ALIQ_COFINS_PERC := TViewSpedNfeDetalheVO(ListaNFeDetalhe.Items[j]).AliquotaCofinsPercentual;
                        QUANT_BC_COFINS := TViewSpedNfeDetalheVO(ListaNFeDetalhe.Items[j]).QuantidadeVendidaCofins;
                        ALIQ_COFINS_R := TViewSpedNfeDetalheVO(ListaNFeDetalhe.Items[j]).AliquotaCofinsReais;
                        VL_COFINS := TViewSpedNfeDetalheVO(ListaNFeDetalhe.Items[j]).ValorCofins;
                        COD_CTA := '';
                      end; // with RegistroC170New do
                    end; // for j := 0 to ListaNFeDetalhe.Count - 1 do
                  end; // if Assigned(ListaNFeDetalhe) then
                finally
                  ListaNFeDetalhe := Nil;
                end;

                // REGISTRO C175: REGISTRO ANALÍTICO DO DOCUMENTO (CÓDIGO 65)
                { Será analisado após a implementação da NFC-e }

                // REGISTRO C180: CONSOLIDAÇÃO  DE  NOTAS  FISCAIS  ELETRÔNICAS  EMITIDAS PELA PESSOA JURÍDICA (CÓDIGOS 55 e 65) – OPERAÇÕES DE VENDAS
                // REGISTRO C181: DETALHAMENTO DA CONSOLIDAÇÃO – OPERAÇÕES DE VENDAS – PIS/PASEP
                // REGISTRO C185: DETALHAMENTO DA CONSOLIDAÇÃO – OPERAÇÕES DE VENDAS – COFINS
                // REGISTRO C188: PROCESSO REFERENCIADO
                { Não Implementados }

                // REGISTRO C190: CONSOLIDAÇÃO DE NOTAS FISCAIS ELETRÔNICAS (CÓDIGO 55) – OPERAÇÕES  DE  AQUISIÇÃO  COM  DIREITO  A  CRÉDITO,  E  OPERAÇÕES  DE DEVOLUÇÃO DE COMPRAS E VENDAS.
                // REGISTRO C191:  DETALHAMENTO  DA  CONSOLIDAÇÃO  –  OPERAÇÕES  DE AQUISIÇÃO  COM  DIREITO  A  CRÉDITO,  E  OPERAÇÕES  DE  DEVOLUÇÃO  DE COMPRAS E VENDAS – PIS/PASEP
                // REGISTRO C195:  DETALHAMENTO  DA  CONSOLIDAÇÃO  -  OPERAÇÕES  DE AQUISIÇÃO  COM  DIREITO  A  CRÉDITO,  E  OPERAÇÕES  DE  DEVOLUÇÃO  DE COMPRAS E VENDAS – COFINS
                // REGISTRO C198: PROCESSO REFERENCIADO
                // REGISTRO C199: COMPLEMENTO DO DOCUMENTO - OPERAÇÕESDE IMPORTAÇÃO (CÓDIGO 55)
                { Não Implementados }

              end; // with RegistroC100New do
            end; // for i := 0 to ListaNFeCabecalho.Count - 1 do
          end; // if Assigned(ListaNFeCabecalho) then


          // REGISTRO  C380:  NOTA  FISCAL  DE  VENDA  A  CONSUMIDOR  (CÓDIGO  02)  - CONSOLIDAÇÃO DE DOCUMENTOS EMITIDOS.
          ListaC300 := TListaViewSpedC300VO(TT2TiORM.Consultar(TViewSpedC300VO.Create, 'DATA_EMISSAO BETWEEN ' + QuotedStr(DataInicial) + ' and ' + QuotedStr(DataFinal), False));
          if assigned(ListaC300) then
          begin
            for i := 0 to ListaC300.Count - 1 do
            begin
              with RegistroC380New do
              begin
                COD_MOD := '2';

                FiltroLocal := '(DATA_EMISSAO BETWEEN ' + QuotedStr(DataInicial) + ' and ' + QuotedStr(DataFinal) + ')';

                EcfNotaFiscalCabecalho := TEcfNotaFiscalCabecalhoVO.Create;
                EcfNotaFiscalCabecalho := TEcfNotaFiscalCabecalhoVO(TT2TiORM.ConsultarUmObjeto(EcfNotaFiscalCabecalho, 'ID=' + IntToStr(TT2TiORM.SelectMin('ECF_NOTA_FISCAL_CABECALHO', FiltroLocal)), False));
                if assigned(EcfNotaFiscalCabecalho) then
                begin
                  NUM_DOC_INI := StrToInt(EcfNotaFiscalCabecalho.Numero);
                  DT_DOC_INI := EcfNotaFiscalCabecalho.DataEmissao;
                  FreeAndNil(EcfNotaFiscalCabecalho);
                end;

                EcfNotaFiscalCabecalho := TEcfNotaFiscalCabecalhoVO.Create;
                EcfNotaFiscalCabecalho := TEcfNotaFiscalCabecalhoVO(TT2TiORM.ConsultarUmObjeto(EcfNotaFiscalCabecalho, 'ID=' + IntToStr(TT2TiORM.SelectMax('ECF_NOTA_FISCAL_CABECALHO', FiltroLocal)), False));
                if assigned(EcfNotaFiscalCabecalho) then
                begin
                  NUM_DOC_FIN := StrToInt(EcfNotaFiscalCabecalho.Numero);
                  DT_DOC_FIN := EcfNotaFiscalCabecalho.DataEmissao;
                  FreeAndNil(EcfNotaFiscalCabecalho);
                end;

                VL_DOC := TViewSpedC300VO(ListaC300.Items[i]).SomaTotalNf;
                VL_DOC_CANC := 0; // Como pegar os valores cancelados?

                // REGISTRO C381: DETALHAMENTO DA CONSOLIDAÇÃO – PIS/P ASEP
                // REGISTRO C385: DETALHAMENTO DA CONSOLIDAÇÃO – COFINS
                { Exercício: implementar }

                // REGISTRO C395: NOTAS FISCAIS DE VENDA A CONSUMIDOR(CÓDIGOS 02, 2D, 2E e 59) – AQUISIÇÕES/ENTRADAS COM CRÉDITO.
                // REGISTRO  C396:  ITENS  DO  DOCUMENTO  (CÓDIGOS  02,  2D,  2E  e  59)  – AQUISIÇÕES/ENTRADAS COM CRÉDITO
                { Não Implementados }

              end; // with RegistroC380New do
            end; // for i := 0 to ListaC380.Count - 1 do
          end; // if assigned(ListaC380) then


		  ListaImpressora := TListaEcfImpressoraVO(TT2TiORM.Consultar(TEcfImpressoraVO.Create, 'ID>0', False));
          if assigned(ListaImpressora) then
          begin
            for i := 0 to ListaImpressora.Count - 1 do
            begin
              // REGISTRO C400: EQUIPAMENTO ECF (CÓDIGOS 02 e 2D)
              with RegistroC400New do
              begin
                COD_MOD := TEcfImpressoraVO(ListaImpressora.Items[i]).ModeloDocumentoFiscal;
                ECF_MOD := TEcfImpressoraVO(ListaImpressora.Items[i]).Modelo;
                ECF_FAB := TEcfImpressoraVO(ListaImpressora.Items[i]).Serie;
                ECF_CX := TEcfImpressoraVO(ListaImpressora.Items[i]).Numero;

                try
                  // verifica se existe movimento no periodo para aquele ECF
                  FiltroLocal := 'ID_IMPRESSORA=' + IntToStr(TEcfImpressoraVO(ListaImpressora.Items[i]).Id) + ' and (DATA_EMISSAO BETWEEN ' + QuotedStr(DataInicial) + ' and ' + QuotedStr(DataFinal) + ')';
                  ListaR02 := TListaEcfR02VO(TT2TiORM.Consultar(TEcfR02VO.Create, FiltroLocal ,  False));
                  if assigned(ListaR02) then
                  begin
                    for j := 0 to ListaR02.Count - 1 do
                    begin
                      // REGISTRO C405: REDUÇÃO Z (CÓDIGOS 02 e 2D)
                      with RegistroC405New do
                      begin
                        DT_DOC := TEcfR02VO(ListaR02.Items[j]).DataMovimento;
                        CRO := TEcfR02VO(ListaR02.Items[j]).CRO;
                        CRZ := TEcfR02VO(ListaR02.Items[j]).CRZ;
                        NUM_COO_FIN := TEcfR02VO(ListaR02.Items[j]).Coo;
                        GT_FIN := TEcfR02VO(ListaR02.Items[j]).GrandeTotal;
                        VL_BRT := TEcfR02VO(ListaR02.Items[j]).VendaBruta;

                        try
                          // REGISTRO C481: RESUMO DIÁRIO DE DOCUMENTOS EMITIDOSPOR ECF – PIS/PASEP (CÓDIGOS 02 e 2D).
                          // REGISTRO C485: RESUMO DIÁRIO DE DOCUMENTOS EMITIDOSPOR ECF – COFINS (CÓDIGOS 02 e 2D)
                          FiltroLocal := 'TOTALIZADOR_PARCIAL not like ' + QuotedStr('%CAN%') + 'and TOTALIZADOR_PARCIAL not like ' + QuotedStr('%S%') + ' and (DATA_VENDA BETWEEN ' + QuotedStr(DataInicial) + ' and ' + QuotedStr(DataFinal) + ')';
                          ListaC425 := TListaViewSpedC425VO(TT2TiORM.Consultar(TViewSpedC425VO.Create, FiltroLocal, False));
                          if assigned(ListaC425) then
                          begin
                            for l := 0 to ListaC425.Count - 1 do
                            begin
                              with RegistroC481New do
                              begin
                                //CST_PIS := ''; // De onde pegar?
                                VL_ITEM := TViewSpedC425VO(ListaC425.Items[l]).SomaItem;
                                VL_BC_PIS := 0; // De onde pegar?
                                ALIQ_PIS := 0; // De onde pegar?
                                QUANT_BC_PIS := 0; // De onde pegar?
                                ALIQ_PIS_QUANT := 0; // De onde pegar?
                                VL_PIS := TViewSpedC425VO(ListaC425.Items[l]).SomaPis;
                                COD_ITEM := IntToStr(TViewSpedC425VO(ListaC425.Items[l]).IdEcfProduto);
                              end; // with RegistroC481New do

                              with RegistroC485New do
                              begin
                                //CST_COFINS := ''; // De onde pegar?
                                VL_ITEM := TViewSpedC425VO(ListaC425.Items[l]).SomaItem;
                                VL_BC_COFINS := 0; // De onde pegar?
                                ALIQ_COFINS := 0; // De onde pegar?
                                QUANT_BC_COFINS := 0; // De onde pegar?
                                ALIQ_COFINS_QUANT := 0; // De onde pegar?
                                VL_COFINS := TViewSpedC425VO(ListaC425.Items[l]).SomaPis;
                                COD_ITEM := IntToStr(TViewSpedC425VO(ListaC425.Items[l]).IdEcfProduto);
                              end; // with RegistroC485New do

                            end; // for l := 0 to ListaC425.Count - 1 do
                          end; // if Assigned(ListaC425) then
                        finally
                          ListaC425 := Nil;
                        end;

                        // REGISTRO C489: PROCESSO REFERENCIADO
                        { Não Implementado }

                        // REGISTRO C490: CONSOLIDAÇÃO DE DOCUMENTOS EMITIDOS  POR ECF (CÓDIGOS 02, 2D, 59 e 60)
                        // REGISTRO C491:  DETALHAMENTO  DA CONSOLIDAÇÃO DE DOCUMENTOS EMITIDOS POR ECF (CÓDIGOS 02, 2D e 59) – PIS/PASEP
                        // REGISTRO C495:  DETALHAMENTO  DA CONSOLIDAÇÃO DE DOCUMENTOS EMITIDOS POR ECF (CÓDIGOS 02, 2D e 59) – COFINS
                        // REGISTRO C499: PROCESSO REFERENCIADO
                        { Não Implementados }

                      end; // with RegistroC405New do
                    end; // for j := 0 to ListaR02.Count - 1 do
                  end; // if Assigned(ListaR02) then

                finally
                  ListaR02 := Nil;
                end;

              end; // with RegistroC400New do
            end; // for i := 0 to ListaImpressora.Count - 1 do
          end; // if Assigned(ListaImpressora) then

          // REGISTRO C500:  NOTA  FISCAL/CONTA  DE  ENERGIA  ELÉTRICA  (CÓDIGO  06),  NOTA FISCAL/CONTA  DE  FORNECIMENTO  D'ÁGUA  CANALIZADA  (CÓDIGO  29)  E  NOTA  FISCAL CONSUMO  FORNECIMENTO  DE  GÁS  (CÓDIGO  28)  E  NF-e  (CÓDIGO  55)–  DOCUMENTOS  DE ENTRADA/AQUISIÇÃO COM CRÉDITO
          // REGISTRO C501: COMPLEMENTO DA OPERAÇÃO (CÓDIGOS 06,28 e 29) – PIS/PASEP
          // REGISTRO C505: COMPLEMENTO DA OPERAÇÃO (CÓDIGOS 06,28 e 29) – COFINS
          // REGISTRO C509: PROCESSO REFERENCIADO
          // REGISTRO C600:  CONSOLIDAÇÃO  DIÁRIA  DE  NOTAS  FISCAIS/CONTAS  EMITIDAS  DE ENERGIA  ELÉTRICA  (CÓDIGO  06),  NOTA  FISCAL/CONTA  DE  FORNECIMENTO  D'ÁGUA CANALIZADA (CÓDIGO 29) E NOTA FISCAL/CONTA DE FORNECIMENTO DE GÁS (CÓDIGO 28) (EMPRESAS OBRIGADAS OU NÃO OBRIGADAS AO CONVENIO ICMS 115/03) – DOCUMENTOS DE SAÍDA
          // REGISTRO C601: COMPLEMENTO DA CONSOLIDAÇÃO DIÁRIA (CÓDIGOS 06, 28 e 29) – DOCUMENTOS DE SAÍDAS - PIS/PASEP
          // REGISTRO C605: COMPLEMENTO DA CONSOLIDAÇÃO DIÁRIA (CÓDIGOS 06, 28 e 29) – DOCUMENTOS DE SAÍDAS – COFINS
          // REGISTRO C609: PROCESSO REFERENCIADO
          { Não Implementados }

          // REGISTRO C800: CUPOM FISCAL ELETRÔNICO (CÓDIGO 59)
          // REGISTRO C810:  DETALHAMENTO  DO  CUPOM  FISCAL  ELETRÔNICO  (CÓDIGO  59)  – PIS/PASEP E COFINS
          // REGISTRO C820:  DETALHAMENTO  DO  CUPOM  FISCAL  ELETRÔNICO  (CÓDIGO  59)  – PIS/PASEP E COFINS APURADO POR UNIDADE DE MEDIDA DEPRODUTO
          // REGISTRO C830: PROCESSO RERENCIADO
          // REGISTRO C860: IDENTIFICAÇÃO DO EQUIPAMENTO SAT-CF-E
          // REGISTRO C870:  RESUMO  DIÁRIO  DE  DOCUMENTOS  EMITIDOS POR  EQUIPAMENTO SAT-CF-E (CÓDIGO 59) – PIS/PASEP E COFINS
          // REGISTRO C880:  RESUMO  DIÁRIO  DE  DOCUMENTOS  EMITIDOS POR  EQUIPAMENTO SAT-CF-E (CÓDIGO 59) – PIS/PASEP E COFINS APURADO POR UNIDADE DE MEDIDA DE PRODUTO
          // REGISTRO C890: PROCESSO REFERENCIADO
          (* Serão analisados após implementação do SAT *)

        end;
      end; // with RegistroC001New do
    end; // with FDataModule.ACBrSpedContribuicoes.Bloco_C do
  finally
    ListaImpressora := Nil;
    ListaNF2Cabecalho := Nil;
    ListaNF2CabecalhoCanceladas := Nil;
    ListaNFeCabecalho := Nil;
    ListaC300 := Nil;
    ListaC321 := Nil;
    ListaC390 := Nil;
  end;
end;
{$ENDREGION}

{$REGION 'BLOCO D: DOCUMENTOS FISCAIS II - SERVIÇOS (ICMS)'}
procedure TSpedContribuicoes.GerarBlocoD;
begin
  try
    with FDataModule.ACBrSpedContribuicoes.Bloco_D do
    begin
      // REGISTRO D001: ABERTURA DO BLOCO F
      with RegistroD001New do
      begin
        IND_MOV := imSemDados
      end; // with RegistroD001New do
    end;
  finally
  end;
end;
{$ENDREGION}

{$REGION 'BLOCO F: DEMAIS DOCUMENTOS E OPERAÇÕES'}
procedure TSpedContribuicoes.GerarBlocoF;
begin
  try
    with FDataModule.ACBrSpedContribuicoes.Bloco_F do
    begin
      // REGISTRO F001: ABERTURA DO BLOCO F
      with RegistroF001New do
      begin
        IND_MOV := imSemDados
      end; // with RegistroF001New do
    end;
  finally
  end;
end;
{$ENDREGION}

{$REGION 'BLOCO I: BLOCO I: OPERAÇÕES DAS INSTITUIÇÕES FINANCEIRAS, SEGURADORAS, ENTIDADES DE  PREVIDENCIA  PRIVADA,  OPERADORAS  DE  PLANOS  DE  ASSISTÊNCIA  À SAÚDE E DEMAIS PESSOAS JURÍDICAS REFERIDAS NOS §§ 6º, 8ºE 9ºDO ART. 3ºDA LEI nº9.718/98'}
procedure TSpedContribuicoes.GerarBlocoI;
begin
  try
    with FDataModule.ACBrSpedContribuicoes.Bloco_I do
    begin
      // REGISTRO I001: ABERTURA DO BLOCO I
      with RegistroI001New do
      begin
        IND_MOV := imSemDados
      end; // with RegistroI001New do
    end;
  finally
  end;
end;
{$ENDREGION}

{$REGION 'BLOCO M: APURAÇÃO  DA  CONTRIBUIÇÃO  E  CRÉDITO  DO  PIS/PASEP  E DA COFINS'}
procedure TSpedContribuicoes.GerarBlocoM;
begin
  try
    with FDataModule.ACBrSpedContribuicoes.Bloco_M do
    begin
      // REGISTRO M001: ABERTURA DO BLOCO M
      with RegistroM001New do
      begin
        IND_MOV := imSemDados
      end; // with RegistroM001New do
    end;
  finally
  end;
end;
{$ENDREGION}

{$REGION 'BLOCO 1: COMPLEMENTO DA ESCRITURAÇÃO – CONTROLE DE  SALDOS DE  CRÉDITOS  E  DE  RETENÇÕES,  OPERAÇÕES  EXTEMPORÂNEAS E OUTRAS INFORMAÇÕES'}
procedure TSpedContribuicoes.GerarBloco1;
var
  i: Integer;
begin
  try
    with FDataModule.ACBrSpedContribuicoes.Bloco_1 do
    begin
      // REGISTRO 1001: ABERTURA DO BLOCO 1
      with Registro1001New do
      begin
        IND_MOV := imSemDados;
      end; // with Registro1001New do
    end;
  finally
  end;
end;
{$ENDREGION}

{$REGION 'Gerar Arquivo'}
function TSpedContribuicoes.GerarArquivoSpedContribuicoes: Boolean;
begin
  Result := False;
  try
    try
      with FDataModule.ACBrSpedContribuicoes do
      begin
        DT_INI := TextoParaData(DataInicial);
        DT_FIN := TextoParaData(DataFinal);
      end;

      // BLOCO 0: ABERTURA, IDENTIFICAÇÃO E REFERÊNCIAS
      GerarBloco0;

      // BLOCO A: DOCUMENTOS FISCAIS - SERVIÇOS (NÃO SUJEITOS AO ICMS)
      {
        Será analisado após a implementação da NFS-e
        Exercício:
          Analisar como implementar com dados de um NF-e de serviço.
      }
      GerarBlocoA;

      // BLOCO C: DOCUMENTOS FISCAIS I - MERCADORIAS (ICMS/IPI
      GerarBlocoC;

      // BLOCO D: DOCUMENTOS FISCAIS II - SERVIÇOS (ICMS).
      // Estabelecimentos  que  efetivamente  tenham realizado as operações especificadas no Bloco D (prestação ou contratação), relativas a serviços de transporte de cargas e/ou de passageiros, serviços de comunicação e de telecomunicação, mediante emissão de documento fiscal definido pela legislação do ICMS e do IPI, que devam ser escrituradas no Bloco D.
      { Não Implementado }
      GerarBlocoD;

      // BLOCO F: DEMAIS DOCUMENTOS E OPERAÇÕES
      // Neste  bloco  serão  informadas  pela  pessoa  jurídica,  as  demais  operações  geradoras  de  contribuição  ou  de crédito,  não informadas nos Blocos A, C e D
      { Não Implementado }
      GerarBlocoF;

      // BLOCO I: OPERAÇÕES DAS INSTITUIÇÕES FINANCEIRAS, SEGURADORAS, ENTIDADES DE  PREVIDENCIA  PRIVADA,  OPERADORAS  DE  PLANOS  DE  ASSISTÊNCIA  À SAÚDE E DEMAIS PESSOAS JURÍDICAS REFERIDAS NOS §§ 6º, 8ºE 9ºDO ART. 3ºDA LEI nº9.718/98.
      { Não Implementado }
      GerarBlocoI;

      // BLOCO  M: APURAÇÃO  DA  CONTRIBUIÇÃO  E  CRÉDITO  DO  PIS/PASEP  E DA COFINS
      { Gerado pelo PVA }
      GerarBlocoM;

      // BLOCO P: APURAÇÃO DA CONTRIBUIÇÃO PREVIDENCIÁRIA SOBRE A RECEITA BRUTA (CPRB)
      { Não Implementado }

      // BLOCO 1: COMPLEMENTO DA ESCRITURAÇÃO – CONTROLE DE  SALDOS DE  CRÉDITOS  E  DE  RETENÇÕES,  OPERAÇÕES  EXTEMPORÂNEAS E OUTRAS INFORMAÇÕES
      { Não Implementado }
      GerarBloco1;

      Arquivo := './sped/SpedContribuicoes' + FormatDateTime('DDMMYYYYhhmmss', Now) + '.txt';

      FDataModule.ACBrSpedContribuicoes.Arquivo := Arquivo;
      FDataModule.ACBrSpedContribuicoes.SaveFileTXT;

      Result := True;
    except
      on E: Exception do
        Write('Erro=' + E.Message);
      //Result := False;
    end;
  finally
    Empresa := Nil;
  end;
end;
{$ENDREGION}

{$ENDREGION}

initialization
  TSpedContribuicoes.Register('/spedcontribuicoes/:dataini/:datafim/:leiaute/:escrituracao/:empresa/:contador/');
  //http://localhost:8090/cgi-bin/servidort2ti.cgi/spedcontribuicoes/2014-01-01/2014-12-31/3/0/1/1/

end.
