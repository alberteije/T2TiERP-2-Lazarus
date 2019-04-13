{*******************************************************************************
Title: T2Ti ERP                                                                 
Description: Controller do lado Cliente relacionado à tabela [GED_DOCUMENTO_DETALHE] 
                                                                                
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
unit GedDocumentoDetalheController;

{$MODE Delphi}

interface

uses
  Classes, Dialogs, SysUtils, DB,  LCLIntf, LCLType, LMessages, Forms, FileUtil, Controller,
  VO, ZDataset, GedDocumentoDetalheVO, GedVersaoDocumentoVO, FPJson,
  Biblioteca;

type
  TGedDocumentoDetalheController = class(TController)
  private
  public
    class function Consulta(pFiltro: String; pPagina: String): TZQuery;
    class function ConsultaLista(pFiltro: String): TListaGedDocumentoDetalheVO;
    class function ConsultaObjeto(pFiltro: String): TGedDocumentoDetalheVO;

    class procedure Insere(pObjeto: TGedDocumentoDetalheVO);
    class function Altera(pObjeto: TGedDocumentoDetalheVO; pArquivoStream, pAssinaturaStream: TMemoryStream; pMD5:String): Boolean;

    class function Exclui(pId: Integer): Boolean;


    class function ArmazenarArquivo(pArquivoStream, pAssinaturaStream: TMemoryStream; pOperacao: String; pIdPai: Integer; pMD5:String): Boolean;

  end;

implementation

uses UDataModule, T2TiORM;

var
  ObjetoLocal: TGedDocumentoDetalheVO;

class function TGedDocumentoDetalheController.Consulta(pFiltro: String; pPagina: String): TZQuery;
begin
  try
    ObjetoLocal := TGedDocumentoDetalheVO.Create;
    Result := TT2TiORM.Consultar(ObjetoLocal, pFiltro, pPagina);
  finally
    ObjetoLocal.Free;
  end;
end;

class function TGedDocumentoDetalheController.ConsultaLista(pFiltro: String): TListaGedDocumentoDetalheVO;
begin
  try
    ObjetoLocal := TGedDocumentoDetalheVO.Create;
    Result := TListaGedDocumentoDetalheVO(TT2TiORM.Consultar(ObjetoLocal, pFiltro, True));
  finally
    ObjetoLocal.Free;
  end;
end;

class function TGedDocumentoDetalheController.ConsultaObjeto(pFiltro: String): TGedDocumentoDetalheVO;
begin
  try
    Result := TGedDocumentoDetalheVO.Create;
    Result := TGedDocumentoDetalheVO(TT2TiORM.ConsultarUmObjeto(Result, pFiltro, True));
  finally
  end;
end;

class procedure TGedDocumentoDetalheController.Insere(pObjeto: TGedDocumentoDetalheVO);
var
  UltimoID: Integer;
begin
  try
    UltimoID := TT2TiORM.Inserir(pObjeto);
    Consulta('ID = ' + IntToStr(UltimoID), '0');
  finally
  end;
end;

class function TGedDocumentoDetalheController.Altera(pObjeto: TGedDocumentoDetalheVO; pArquivoStream, pAssinaturaStream: TMemoryStream; pMD5:String): Boolean;
var
  UltimoID: Integer;
  VersaoDocumento: TGedVersaoDocumentoVO;
begin
  try
    if pObjeto.Id > 0 then
    begin
      Result := TT2TiORM.Alterar(pObjeto);
      ArmazenarArquivo(pArquivoStream, pAssinaturaStream, 'A', pObjeto.Id, pMD5);
    end
    else
    begin
      UltimoID := TT2TiORM.Inserir(pObjeto);
      ArmazenarArquivo(pArquivoStream, pAssinaturaStream, 'I', UltimoID, pMD5);
      Result := True;
    end;
  finally
  end;
end;

class function TGedDocumentoDetalheController.Exclui(pId: Integer): Boolean;
var
  ObjetoLocal: TGedDocumentoDetalheVO;
begin
  try
    ObjetoLocal := TGedDocumentoDetalheVO.Create;
    ObjetoLocal.Id := pId;
    Result := TT2TiORM.Excluir(ObjetoLocal);
  finally
    FreeAndNil(ObjetoLocal)
  end;
end;

class function TGedDocumentoDetalheController.ArmazenarArquivo(pArquivoStream, pAssinaturaStream: TMemoryStream; pOperacao: String; pIdPai: Integer; pMD5:String): Boolean;
var
  VersaoDocumento: TGedVersaoDocumentoVO;
  UltimoIdVersao: Integer;
begin
  if not DirectoryExistsUTF8(ExtractFilePath(Application.ExeName) + '\Arquivos\GED\') then
    ForceDirectoriesUTF8(ExtractFilePath(Application.ExeName) + '\Arquivos\GED\');

  try
    try

      //salva o arquivo de assinatura em disco
      if Assigned(pAssinaturaStream) then
      begin
        pAssinaturaStream.SaveToFile(ExtractFilePath(Application.ExeName) + '\Arquivos\GED\' + pMD5 + '.assinatura');
      end;

      //salva o arquivo enviado em disco
      /// EXERCICIO: identifique o tipo de arquivo para salvar esse dado de modo dinâmico
      if Assigned(pAssinaturaStream) then
      begin
        pArquivoStream.SaveToFile(ExtractFilePath(Application.ExeName) + '\Arquivos\GED\' + pMD5 + '.jpg');
      end;

      //devemos inserir um registro de versionamento informando a inclusão/alteração do documento
      if pOperacao = 'I' then
      begin
        VersaoDocumento := TGedVersaoDocumentoVO.Create;
        VersaoDocumento.Versao := 1;
        VersaoDocumento.Acao := 'I';
      end
      else if pOperacao = 'A' then
      begin
        UltimoIdVersao := TT2TiORM.SelectMax('GED_VERSAO_DOCUMENTO', 'ID_GED_DOCUMENTO=' + QuotedStr(IntToStr(pIdPai)));
        if UltimoIdVersao = 0 then
        begin
          VersaoDocumento := TGedVersaoDocumentoVO.Create;
          VersaoDocumento.Versao := 1;
        end
        else
        begin
          Filtro := 'ID=' + QuotedStr(IntToStr(UltimoIdVersao));
          VersaoDocumento := TGedVersaoDocumentoVO(TT2TiORM.ConsultarUmObjeto(VersaoDocumento, Filtro, True));
          VersaoDocumento.Versao := VersaoDocumento.Versao + 1;
        end;
        VersaoDocumento.Acao := 'A';
      end;

      VersaoDocumento.IdColaborador := 1;//Sessao.Usuario.Id;
      VersaoDocumento.IdGedDocumento := pIdPai;
      VersaoDocumento.DataHora := Now;
      VersaoDocumento.HashArquivo := pMD5;
      VersaoDocumento.Caminho := ExtractFilePath(Application.ExeName) + '\Arquivos\GED\' + pMD5; //+ tipoarquivo;
      VersaoDocumento.Caminho := StringReplace(VersaoDocumento.Caminho,'\','/',[rfReplaceAll]);

      TT2TiORM.Inserir(VersaoDocumento);

      Result := True;
    except
      Result := False;
    end;
  finally

  end;
end;

initialization
  Classes.RegisterClass(TGedDocumentoDetalheController);

finalization
  Classes.UnRegisterClass(TGedDocumentoDetalheController);

end.

