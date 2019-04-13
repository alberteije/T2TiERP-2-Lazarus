program servidorT2Ti;

{$mode objfpc}{$H+}

uses
  BrookApplication, Brokers, Produto, DavCabecalho, DavDetalhe, Contador, EstadoCivil, Pessoa, Banco, Pais, NfeConfiguracao, NfeNumero, Empresa,
  EmpresaEndereco, ViewPessoaCliente, NfeCabecalho, ViewTributacaoIcms, ViewTributacaoCofins, ViewTributacaoIpi, ViewTributacaoPis, NfeDestinatario,
  NfeDetalheImpostoCofins, NfeDetalheImpostoPis, NfeDetalheImpostoIcms, NfeDetalhe, NfeTransporte, NfeLocalRetirada, NfeLocalEntrega,
  NfeDetalheImpostoIpi, TributCofinsCodApuracao, TributConfiguraOfGt, TributGrupoTributario, TributIcmsCustomCab, TributIcmsCustomDet, TributIcmsUf,
  TributIpiDipi, TributIss, TributOperacaoFiscal, TributPisCodApuracao;

begin
  BrookApp.Run;
end.
