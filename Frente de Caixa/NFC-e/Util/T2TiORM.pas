{ *******************************************************************************
Title: T2Ti ERP
Description: Framework ORM da T2Ti

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
t2ti.com@gmail.com</p>

@author Albert Eije (T2Ti.COM)
@version 2.0
******************************************************************************* }
unit T2TiORM;

{$mode objfpc}{$H+}

interface

uses Classes, SysUtils, Forms, DB, TypInfo, ZDataset, ZConnection, Dialogs, DOM,
  XMLRead, XMLWrite, VO, Constantes;

type

  { TT2TiORM }

  TT2TiORM = class
  private
  public
    class procedure Conectar;

    class function Inserir(pObjeto: TVO): Integer;
    class function Alterar(pObjeto: TVO): Boolean;
    class function Excluir(pObjeto: TVO): Boolean;

    class function Consultar(pObjeto: TVO; pFiltro: String; pPagina: String): TZQuery; overload;
    class function Consultar(pObjeto: TVO; pFiltro: String; pConsultaCompleta: Boolean): TListaVO; overload;
    class function ConsultarUmObjeto(pObjeto: TVO; pFiltro: String; pConsultaCompleta: Boolean): TVO;

    class function ComandoSQL(pConsulta: String): Boolean;
    class function SelectMax(pTabela: String; pFiltro: String): Integer;
    class function SelectMin(pTabela: String; pFiltro: String): Integer;
    class function SelectCount(pTabela: String): Integer;
  end;

implementation

var
  Conexao : TZConnection;
  Banco: String;

{ TPersistencia }

{$Region 'Conexão'}
class procedure TT2TiORM.Conectar;
begin
  Banco := 'MySQL';

  if not Assigned(Conexao) then
  begin
    Conexao := TZConnection.create(nil);

    if Banco = 'MySQL' then
    begin
      Conexao.Protocol := 'mysql';
      Conexao.HostName := 'localhost';
      Conexao.Database := 't2tierp';
      Conexao.User := 'root';
      Conexao.Password := 'root';
    end;
  end;
end;
{$EndRegion 'Conexão'}

{$Region 'Inserção de Dados'}
class function TT2TiORM.Inserir(pObjeto: TVO): Integer;
var
  Query: TZQuery;

  UltimoID: Integer;
  I, J, K: Integer;

  TypeData: PTypeData;
  TypeInfo: PTypeInfo;
  PropList: PPropList;
  PropInfo: PPropInfo;

  Tabela, ConsultaSQL, CamposSQL, ValoresSQL, Caminho, NomeTipo, PropriedadeXML, ColunaXML: String;

  Documento: TXMLDocument;
  Node: TDOMNode;
begin
  try
    Conectar;

    DecimalSeparator := '.';
    TypeInfo := pObjeto.ClassInfo;
    TypeData := GetTypeData(TypeInfo);

    // Lê no arquivo xml no disco
    Caminho := ExtractFilePath(Application.ExeName) + 'VO\' + TypeData^.UnitName + '.xml';
    ReadXMLFile(Documento, Caminho);

    //localiza o nome da tabela
    Node := Documento.DocumentElement.FirstChild;
    Tabela := Node.Attributes.Item[1].NodeValue;
    ConsultaSQL := 'INSERT INTO ' + Tabela + ' ';

    //preenche os nomes dos campos e valores
    GetMem(PropList, TypeData^.PropCount * SizeOf(Pointer));
    GetPropInfos(TypeInfo, PropList);
    for I := 0 to TypeData^.PropCount - 1 do
    begin
      for J := 0 to (Node.ChildNodes.Count - 1) do
      begin
        if Node.ChildNodes.Item[J].NodeName = 'property' then
        begin
          for K := 0 to 4 do
          begin
            if Node.ChildNodes.Item[J].Attributes.Item[K].NodeName = 'name' then
              PropriedadeXML := Node.ChildNodes.Item[J].Attributes.Item[K].NodeValue;
            if Node.ChildNodes.Item[J].Attributes.Item[K].NodeName = 'column' then
              ColunaXML := Node.ChildNodes.Item[J].Attributes.Item[K].NodeValue;
          end;

          if PropriedadeXML = PropList^[I]^.Name then
          begin
            CamposSQL := CamposSQL + ColunaXML + ',';
          end;
        end;
      end;

      if PropList^[I]^.Name <> 'Id' then
      begin
        PropInfo := GetPropInfo(pObjeto, PropList^[I]^.Name);
        NomeTipo := PropInfo^.PropType^.Name;
        if PropInfo^.PropType^.Kind in [tkInteger, tkInt64] then
        begin
          if ((GetInt64Prop(pObjeto, PropList^[I]^.Name) <> 0) or (((GetInt64Prop(pObjeto, PropList^[I]^.Name) = 0) and ( Copy(PropList^[I]^.Name,1,2) <> 'ID')))) then
            ValoresSQL := ValoresSQL + QuotedStr(IntToStr(GetInt64Prop(pObjeto, PropList^[I]^.Name))) + ','
          else
            ValoresSQL := ValoresSQL + 'null,';
        end
        else if PropInfo^.PropType^.Kind in [tkString, tkUString, tkAString] then
        begin
          ValoresSQL := ValoresSQL + QuotedStr(GetStrProp(pObjeto, PropList^[I]^.Name)) + ',';
        end
        else if PropInfo^.PropType^.Kind in [tkFloat] then
        begin
          if NomeTipo = 'TDateTime' then
          begin
            if GetFloatProp(pObjeto, PropList^[I]^.Name) > 0 then
              ValoresSQL := ValoresSQL + QuotedStr(FormatDateTime('yyyy-mm-dd', GetFloatProp(pObjeto, PropList^[I]^.Name))) + ','
            else
              ValoresSQL := ValoresSQL + 'null,';
          end
          else
          begin
            ValoresSQL := ValoresSQL + QuotedStr(FormatFloat('0.000000', GetFloatProp(pObjeto, PropList^[I]^.Name))) + ',';
          end;
        end;
      end
      else
      begin
        if GetInt64Prop(pObjeto, PropList^[I]^.Name) > 0 then
        begin
          CamposSQL := CamposSQL + 'ID,';
          ValoresSQL := ValoresSQL + QuotedStr(IntToStr(GetInt64Prop(pObjeto, PropList^[I]^.Name))) + ',';
        end;
      end;
    end;

    //retirando as vírgulas que sobraram no final
    Delete(CamposSQL, Length(CamposSQL), 1);
    Delete(ValoresSQL, Length(ValoresSQL), 1);

    ConsultaSQL := ConsultaSQL + '(' + CamposSQL + ') VALUES (' + ValoresSQL + ')';

    if Banco = 'Firebird' then
    begin
      ConsultaSQL := ConsultaSQL + ' RETURNING ID ';
    end;

    Query := TZQuery.Create(nil);
    try
      Query.Connection := Conexao;
      Query.sql.Text := ConsultaSQL;

      UltimoID := 0;
      if Banco = 'MySQL' then
      begin
        Query.ExecSQL();
        Query.sql.Text := 'select LAST_INSERT_ID() as id';
        Query.Open();
        UltimoID := Query.FieldByName('id').AsInteger;
      end
      else if Banco = 'Firebird' then
      begin
        Query.Open;
        UltimoID := Query.Fields[0].AsInteger;
      end
      else if Banco = 'Postgres' then
      begin
        Query.ExecSQL();
        Query.sql.Text := 'select Max(id) as id from ' + Tabela;
        Query.Open();
        UltimoID := Query.FieldByName('id').AsInteger;
      end
      else if Banco = 'MSSQL' then
      begin
        Query.ExecSQL();
        Query.sql.Text := 'select Max(id) as id from ' + Tabela;
        Query.Open();
        UltimoID := Query.FieldByName('id').AsInteger;
      end;
    finally
      Query.Close;
      Query.Free;
    end;

    Result := UltimoID;
  finally
    DecimalSeparator := ',';
    FreeMem(PropList);
  end;
end;
{$EndRegion}

{$Region 'Alteração de Dados'}
class function TT2TiORM.Alterar(pObjeto: TVO): Boolean;
var
  Query: TZQuery;

  I, J, K: Integer;
  TypeData: PTypeData;
  TypeInfo: PTypeInfo;
  PropList: PPropList;
  PropInfo: PPropInfo;

  ConsultaSQL, CamposSQL, FiltroSQL, Caminho, NomeTipo, PropriedadeXML, ColunaXML: String;

  Documento: TXMLDocument;
  Node: TDOMNode;
begin
  try
    Conectar;

    DecimalSeparator := '.';
    TypeInfo := pObjeto.ClassInfo;
    TypeData := GetTypeData(TypeInfo);

    // Lê no arquivo xml no disco
    Caminho := ExtractFilePath(Application.ExeName) + 'VO\' + TypeData^.UnitName + '.xml';
    ReadXMLFile(Documento, Caminho);

    //localiza o nome da tabela
    Node := Documento.DocumentElement.FirstChild;
    ConsultaSQL := 'UPDATE ' + Node.Attributes.Item[1].NodeValue + ' SET ';

    //preenche os nomes dos campos e filtro
    GetMem(PropList, TypeData^.PropCount * SizeOf(Pointer));
    GetPropInfos(TypeInfo, PropList);
    for I := 0 to TypeData^.PropCount - 1 do
    begin
      for J := 0 to (Node.ChildNodes.Count - 1) do
      begin
        if Node.ChildNodes.Item[J].NodeName = 'property' then
        begin
          for K := 0 to 4 do
          begin
            if Node.ChildNodes.Item[J].Attributes.Item[K].NodeName = 'name' then
              PropriedadeXML := Node.ChildNodes.Item[J].Attributes.Item[K].NodeValue;
            if Node.ChildNodes.Item[J].Attributes.Item[K].NodeName = 'column' then
              ColunaXML := Node.ChildNodes.Item[J].Attributes.Item[K].NodeValue;
          end;

          if PropriedadeXML = PropList^[I]^.Name then
          begin
            PropInfo := GetPropInfo(pObjeto, PropList^[I]^.Name);
            NomeTipo := PropInfo^.PropType^.Name;
            if PropInfo^.PropType^.Kind in [tkInteger, tkInt64] then
            begin
              if ((GetInt64Prop(pObjeto, PropList^[I]^.Name) <> 0) or (((GetInt64Prop(pObjeto, PropList^[I]^.Name) = 0) and ( Copy(PropList^[I]^.Name,1,2) <> 'ID')))) then
                CamposSQL := CamposSQL + ColunaXML + ' = ' + QuotedStr(IntToStr(GetInt64Prop(pObjeto, PropList^[I]^.Name))) + ',';
            end
            else if PropInfo^.PropType^.Kind in [tkString, tkUString, tkAString] then
            begin
              if GetStrProp(pObjeto, PropList^[I]^.Name) <> '' then
              begin
                CamposSQL := CamposSQL + ColunaXML + ' = ' + QuotedStr(GetStrProp(pObjeto, PropList^[I]^.Name)) + ',';
              end;
            end
            else if PropInfo^.PropType^.Kind in [tkFloat] then
            begin
              if NomeTipo = 'TDateTime' then
              begin
                if GetFloatProp(pObjeto, PropList^[I]^.Name) > 0 then
                  CamposSQL := CamposSQL + ColunaXML + ' = ' + QuotedStr(FormatDateTime('yyyy-mm-dd', GetFloatProp(pObjeto, PropList^[I]^.Name))) + ','
                else
                  CamposSQL := CamposSQL + ColunaXML + ' = ' + 'null,';
              end
              else
              begin
                CamposSQL := CamposSQL + ColunaXML + ' = ' + QuotedStr(FormatFloat('0.000000', GetFloatProp(pObjeto, PropList^[I]^.Name))) + ',';
              end;
            end;
          end;
        end;
      end;

      if PropList^[I]^.Name = 'Id' then
      begin
        FiltroSQL := ' WHERE ID = ' + QuotedStr(IntToStr(GetInt64Prop(pObjeto, PropList^[I]^.Name)));
      end;
    end;

    //retirando as vírgulas que sobraram no final
    Delete(CamposSQL, Length(CamposSQL), 1);

    ConsultaSQL := ConsultaSQL + CamposSQL + FiltroSQL;

    Conexao := Conexao;
    Query := TZQuery.Create(nil);
    Query.Connection := Conexao;
    Query.sql.Text := ConsultaSQL;
    Query.ExecSQL();
    Result := True;

  finally
    DecimalSeparator := ',';
    FreeMem(PropList);
    FreeAndNil(Query);
  end;
end;
{$EndRegion}

{$Region 'Exclusão de Dados'}
class function TT2TiORM.Excluir(pObjeto: TVO): Boolean;
var
  Query: TZQuery;

  I: Integer;
  TypeData: PTypeData;
  TypeInfo: PTypeInfo;
  PropList: PPropList;

  ConsultaSQL, FiltroSQL, Caminho: String;

  Documento: TXMLDocument;
  Node: TDOMNode;
begin
  try
    Conectar;

    TypeInfo := pObjeto.ClassInfo;
    TypeData := GetTypeData(TypeInfo);

    // Lê no arquivo xml no disco
    Caminho := ExtractFilePath(Application.ExeName) + 'VO\' + TypeData^.UnitName + '.xml';
    ReadXMLFile(Documento, Caminho);

    //localiza o nome da tabela
    Node := Documento.DocumentElement.FirstChild;
    ConsultaSQL := 'DELETE FROM ' + Node.Attributes.Item[1].NodeValue + ' ';

    //preenche os nomes dos campos e filtro
    GetMem(PropList, TypeData^.PropCount * SizeOf(Pointer));
    GetPropInfos(TypeInfo, PropList);
    for I := 0 to TypeData^.PropCount - 1 do
    begin
      if PropList^[I]^.Name = 'Id' then
      begin
        FiltroSQL := ' WHERE ID = ' + QuotedStr(IntToStr(GetInt64Prop(pObjeto, PropList^[I]^.Name)));
      end;
    end;

    ConsultaSQL := ConsultaSQL + FiltroSQL;

    Conexao := Conexao;
    Query := TZQuery.Create(nil);
    Query.Connection := Conexao;
    Query.sql.Text := ConsultaSQL;
    Query.ExecSQL();
    Result := True;

  finally
    FreeAndNil(Query);
  end;
end;
{$EndRegion}

{$Region 'Consultas'}
class function TT2TiORM.Consultar(pObjeto: TVO; pFiltro: String; pPagina: String): TZQuery;
var
  Query: TZQuery;

  TypeData: PTypeData;
  TypeInfo: PTypeInfo;

  Tabela, ConsultaSQL, FiltroSQL, Caminho: String;

  Documento: TXMLDocument;
  Node: TDOMNode;
begin
  try
    Conectar;

    TypeInfo := pObjeto.ClassInfo;
    TypeData := GetTypeData(TypeInfo);

    // Lê no arquivo xml no disco
    Caminho := ExtractFilePath(Application.ExeName) + 'VO\' + TypeData^.UnitName + '.xml';
    ReadXMLFile(Documento, Caminho);

    //localiza o nome da tabela
    Node := Documento.DocumentElement.FirstChild;
    Tabela := Node.Attributes.Item[1].NodeValue;

    if (Banco = 'Firebird') and (StrToInt(pPagina) >= 0) then
    begin
      ConsultaSQL := 'SELECT first ' + IntToStr(TConstantes.QUANTIDADE_POR_PAGINA) + ' skip ' + pPagina + ' * FROM ' + Tabela + ' ';
    end
    else
    begin
      ConsultaSQL := 'SELECT * FROM ' + Tabela + ' ';
    end;

    if pFiltro <> '' then
    begin
      FiltroSQL := ' WHERE ' + pFiltro;
    end;

    ConsultaSQL := ConsultaSQL + FiltroSQL;

    if ((Banco = 'MySQL') or (Banco = 'Postgres')) and (StrToInt(pPagina) >= 0) then
    begin
      ConsultaSQL := ConsultaSQL + ' limit ' + IntToStr(TConstantes.QUANTIDADE_POR_PAGINA) + ' offset ' + pPagina;
    end;

    Conexao := Conexao;
    Query := TZQuery.Create(nil);
    Query.Connection := Conexao;
    Query.sql.Text := ConsultaSQL;
    Query.ExecSQL();
    Result := Query;

  finally
  end;
end;

class function TT2TiORM.Consultar(pObjeto: TVO; pFiltro: String; pConsultaCompleta: Boolean): TListaVO;
var
  Query: TZQuery;
  I, J, K: Integer;
  ObjetoLocal: TVO;
  Campo, Propriedade, Classe, Caminho, PropriedadeXML, ColunaXML: String;
  ClassRef: TPersistentClass;

  Documento: TXMLDocument;
  Node: TDOMNode;
begin
  try
    // Lê no arquivo xml no disco
    Caminho := ExtractFilePath(Application.ExeName) + 'VO\' + pObjeto.UnitName + '.xml';
    ReadXMLFile(Documento, Caminho);
    Node := Documento.DocumentElement.FirstChild;

    Result := Nil;

    Query := Consultar(pObjeto, pFiltro, '-1');
    Query.Active := True;

    Result := TListaVO.Create;
    if not Query.IsEmpty then
    begin
      while not Query.EOF do
      begin
        Classe := pObjeto.ClassName;
        ClassRef := GetClass(Classe);
        ObjetoLocal := TVO(ClassRef.Create);
        for I := 0 to Query.FieldCount - 1 do
        begin
          Campo := Query.Fields[I].DisplayName;

          // Encontra o nome da propriedade no arquivo XML mapeado
          for J := 0 to (Node.ChildNodes.Count - 1) do
          begin
            if Node.ChildNodes.Item[J].NodeName = 'property' then
            begin
              for K := 0 to 4 do
              begin
                if Node.ChildNodes.Item[J].Attributes.Item[K].NodeName = 'name' then
                  PropriedadeXML := Node.ChildNodes.Item[J].Attributes.Item[K].NodeValue;
                if Node.ChildNodes.Item[J].Attributes.Item[K].NodeName = 'column' then
                  ColunaXML := Node.ChildNodes.Item[J].Attributes.Item[K].NodeValue;
              end;

              if ColunaXML = Campo then
              begin
                Propriedade := PropriedadeXML;
              end;
            end
            else if Node.ChildNodes.Item[J].NodeName = 'id' then
            begin
              Propriedade := 'Id';
            end;
          end;

          if Query.Fields[I].DataType in [ftFloat, ftDate, ftDateTime] then
          begin
            SetFloatProp(ObjetoLocal, Propriedade, Query.Fields[I].AsFloat);
          end
          else if Query.Fields[I].DataType in [ftInteger, ftSmallint, ftLargeint] then
          begin
            SetInt64Prop(ObjetoLocal, Propriedade, Query.Fields[I].AsInteger);
          end
          else if Query.Fields[I].DataType in [ftString, ftMemo, ftFixedChar] then
          begin
            SetStrProp(ObjetoLocal, Propriedade, Query.Fields[I].AsString);
          end;
        end;
        Result.Add(ObjetoLocal);
        Query.Next;
      end;
    end;

  finally
  end;
end;

class function TT2TiORM.ConsultarUmObjeto(pObjeto: TVO; pFiltro: String; pConsultaCompleta: Boolean): TVO;
var
  Query: TZQuery;
  I, J, K: Integer;
  ObjetoLocal: TVO;
  Campo, Propriedade, Caminho, PropriedadeXML, ColunaXML: String;

  Documento: TXMLDocument;
  Node: TDOMNode;
begin
  try
    // Lê no arquivo xml no disco
    Caminho := ExtractFilePath(Application.ExeName) + 'VO\' + pObjeto.UnitName + '.xml';
    ReadXMLFile(Documento, Caminho);
    Node := Documento.DocumentElement.FirstChild;

    Result := Nil;

    Query := Consultar(pObjeto, pFiltro, '-1');
    Query.Active := True;

    if not Query.IsEmpty then
    begin
        Query.Next;
        ObjetoLocal := pObjeto;
        for I := 0 to Query.FieldCount - 1 do
        begin
          Campo := Query.Fields[I].DisplayName;

          // Encontra o nome da propriedade no arquivo XML mapeado
          for J := 0 to (Node.ChildNodes.Count - 1) do
          begin
            if Node.ChildNodes.Item[J].NodeName = 'property' then
            begin
              for K := 0 to 4 do
              begin
                if Node.ChildNodes.Item[J].Attributes.Item[K].NodeName = 'name' then
                  PropriedadeXML := Node.ChildNodes.Item[J].Attributes.Item[K].NodeValue;
                if Node.ChildNodes.Item[J].Attributes.Item[K].NodeName = 'column' then
                  ColunaXML := Node.ChildNodes.Item[J].Attributes.Item[K].NodeValue;
              end;

              if ColunaXML = Campo then
              begin
                Propriedade := PropriedadeXML;
              end;
            end
            else if Node.ChildNodes.Item[J].NodeName = 'id' then
            begin
              Propriedade := 'Id';
            end;
          end;

          if Query.Fields[I].DataType in [ftFloat, ftDate, ftDateTime] then
          begin
            SetFloatProp(ObjetoLocal, Propriedade, Query.Fields[I].AsFloat);
          end
          else if Query.Fields[I].DataType in [ftInteger, ftSmallint, ftLargeint] then
          begin
            SetInt64Prop(ObjetoLocal, Propriedade, Query.Fields[I].AsInteger);
          end
          else if Query.Fields[I].DataType in [ftString, ftMemo, ftFixedChar] then
          begin
            SetStrProp(ObjetoLocal, Propriedade, Query.Fields[I].AsString);
          end;
        end;
        Result := ObjetoLocal;
    end;

  finally
  end;

end;

{$EndRegion}

{$Region 'SQL Outros'}
class function TT2TiORM.ComandoSQL(pConsulta: String): Boolean;
var
  Query: TZQuery;
begin
  try
    try
      Conectar;

      Conexao := Conexao;
      Query := TZQuery.Create(nil);
      Query.Connection := Conexao;
      Query.sql.Text := pConsulta;
      Query.ExecSQL();
      Result := True;
    except
      Result := False;
    end;
  finally
    Query.Close;
    Query.Free;
  end;
end;

class function TT2TiORM.SelectMax(pTabela: String; pFiltro: String): Integer;
var
  Query: TZQuery;
  ConsultaSQL: String;
begin
  try
    ConsultaSQL := 'SELECT MAX(ID) AS MAXIMO FROM ' + pTabela;
    if pFiltro <> '' then
      ConsultaSQL := ConsultaSQL + ' WHERE ' + pFiltro;
    try
      Conectar;

      Conexao := Conexao;
      Query := TZQuery.Create(nil);
      Query.Connection := Conexao;
      Query.sql.Text := ConsultaSQL;
      Query.Open;

      if Query.RecordCount > 0 then
        Result := Query.FieldByName('MAXIMO').AsInteger
      else
        Result := -1;

    except
      Result := -1;
    end;
  finally
    Query.Close;
    Query.Free;
  end;
end;

class function TT2TiORM.SelectMin(pTabela: String; pFiltro: String): Integer;
var
  Query: TZQuery;
  ConsultaSQL: String;
begin
  try
    ConsultaSQL := 'SELECT MIN(ID) AS MINIMO FROM ' + pTabela;
    if pFiltro <> '' then
      ConsultaSQL := ConsultaSQL + ' WHERE ' + pFiltro;
    try
      Conectar;

      Conexao := Conexao;
      Query := TZQuery.Create(nil);
      Query.Connection := Conexao;
      Query.sql.Text := ConsultaSQL;
      Query.Open;

      if Query.RecordCount > 0 then
        Result := Query.FieldByName('MINIMO').AsInteger
      else
        Result := -1;

    except
      Result := -1;
    end;
  finally
    Query.Close;
    Query.Free;
  end;
end;

class function TT2TiORM.SelectCount(pTabela: String): Integer;
var
  Query: TZQuery;
  ConsultaSQL: String;
begin
  try
    ConsultaSQL := 'SELECT COUNT(*) AS TOTAL FROM ' + pTabela;
    try
      Conectar;

      Conexao := Conexao;
      Query := TZQuery.Create(nil);
      Query.Connection := Conexao;
      Query.sql.Text := ConsultaSQL;
      Query.Open;

      Result := Query.FieldByName('TOTAL').AsInteger

    except
      Result := -1;
    end;
  finally
    Query.Close;
    Query.Free;
  end;
end;
{$EndRegion}

end.

