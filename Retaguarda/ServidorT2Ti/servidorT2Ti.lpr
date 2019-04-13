program servidorT2Ti;

{$mode objfpc}{$H+}

uses
  Interfaces, BrookApplication, Brokers, Produto, DavCabecalho, DavDetalhe, Contador, Sintegra, SpedFiscal, SpedContribuicoes, Banco,
  TributCofinsCodApuracao, TributConfiguraOfGt, TributGrupoTributario, TributIcmsCustomCab, TributIcmsCustomDet, TributIcmsUf, TributIpiDipi,
  TributIss, TributOperacaoFiscal, TributPisCodApuracao;

begin
  BrookApp.Run;
end.
