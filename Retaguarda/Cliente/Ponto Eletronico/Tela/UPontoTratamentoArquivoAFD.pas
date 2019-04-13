{ *******************************************************************************
Title: T2Ti ERP
Description: Janela Tratamento de Registros para o Ponto Eletrônico

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
t2ti.com@gmail.com</p>

@author Albert Eije (alberteije@gmail.com)
@version 2.0
******************************************************************************* }
unit UPontoTratamentoArquivoAFD;

{$MODE Delphi}

interface

uses
  BrookHTTPClient, BrookFCLHTTPClientBroker, BrookHTTPUtils, BrookUtils, FPJson, ZDataset,
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UTelaCadastro, Menus, StdCtrls, ExtCtrls, Buttons, Grids, DBGrids,
  ComCtrls, LabeledCtrls, rxdbgrid, rxtoolbar, DBCtrls, StrUtils,
  Math, Constantes, CheckLst, ActnList, ToolWin, ShellApi, db, BufDataset, Biblioteca,
  ULookup, VO, MaskUtils;

  type

  { TFPontoTratamentoArquivoAFD }

  TFPontoTratamentoArquivoAFD = class(TForm)
    CDSRegistro3: TBufDataSet;
    DSRegistro3: TDataSource;
    PanelCabecalho: TPanel;
    Bevel1: TBevel;
    Image1: TImage;
    Label2: TLabel;
    ActionToolBarGrid: TToolPanel;
    ActionManagerLocal: TActionList;
    ActionSalvar: TAction;
    ActionImportarArquivo: TAction;
    ActionSair: TAction;
    ActionValidarDados: TAction;
    PopupMenu: TPopupMenu;
    DesconsiderarMarcao1: TMenuItem;
    RemoverRegistroIncludo1: TMenuItem;
    PageControl1: TPageControl;
    TabSheetMarcacao: TTabSheet;
    GridMarcacao: TRxDbGrid;
    TabSheetFechamento: TTabSheet;
    CDSPontoFechamentoJornada: TBufDataSet;
    GridFechamento: TRxDbGrid;
    DSPontoFechamentoJornada: TDataSource;
    ActionProcessarFechamento: TAction;
    procedure ActionSalvarExecute(Sender: TObject);
    procedure ActionImportarArquivoExecute(Sender: TObject);
    procedure ActionSairExecute(Sender: TObject);
    procedure CDSRegistro3AfterPost(DataSet: TDataSet);
    procedure ActionValidarDadosExecute(Sender: TObject);
    procedure DesconsiderarMarcao1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure GridMarcacaoKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure RemoverRegistroIncludo1Click(Sender: TObject);
    procedure ActionProcessarFechamentoExecute(Sender: TObject);
  private
    { Private declarations }
    function ValidarDadosInformados: Boolean;
    procedure VerificarDadosNaBase;
  public
    { Public declarations }
  end;

var
  FPontoTratamentoArquivoAFD: TFPontoTratamentoArquivoAFD;

implementation

uses
  UMenu, UDataModule, PontoMarcacaoVO, PontoMarcacaoController, ViewPessoaColaboradorVO,
  ViewPessoaColaboradorController,  UPontoRegistroIncluidoAFD, PontoRelogioController,
  ViewPontoEscalaTurmaController, PontoHorarioController, PontoClassificacaoJornadaController,
  PontoParametroController, PontoFechamentoJornadaVO, PontoRelogioVO, ViewPontoEscalaTurmaVO,
  PontoClassificacaoJornadaVO, PontoParametroVO;
{$R *.lfm}


{$REGION 'Infra'}
procedure TFPontoTratamentoArquivoAFD.FormCreate(Sender: TObject);
begin
  //configura Dataset
  CDSRegistro3.Close;
  CDSRegistro3.FieldDefs.Clear;

  CDSRegistro3.FieldDefs.add('Nsr', ftString, 9);
  CDSRegistro3.FieldDefs.add('TipoRegistro', ftString, 1);
  CDSRegistro3.FieldDefs.add('DataMarcacao', ftString, 8);
  CDSRegistro3.FieldDefs.add('HoraMarcacao', ftString, 4);
  CDSRegistro3.FieldDefs.add('NumeroPis', ftString, 12);
  CDSRegistro3.FieldDefs.add('JUSTIFICATIVA', ftString, 100);
  CDSRegistro3.FieldDefs.add('NOME_COLABORADOR', ftString, 100);
  CDSRegistro3.FieldDefs.add('SITUACAO_REGISTRO', ftString, 20);
  CDSRegistro3.FieldDefs.add('TIPO_MARCACAO', ftString, 20);
  CDSRegistro3.FieldDefs.add('TIPO_REGISTRO', ftString, 20);
  CDSRegistro3.FieldDefs.add('NumeroSerieRep', ftString, 17);
  CDSRegistro3.FieldDefs.add('ID_PONTO_RELOGIO', ftInteger);
  CDSRegistro3.FieldDefs.add('ID_COLABORADOR', ftInteger);
  CDSRegistro3.FieldDefs.add('PAR_ENTRADA_SAIDA', ftString, 2);
  CDSRegistro3.FieldDefs.add('CODIGO_TURMA_PONTO', ftString, 5);
  CDSRegistro3.FieldDefs.add('CODIGO_HORARIO', ftString, 4);
  CDSRegistro3.FieldDefs.add('HORA_INICIO_JORNADA', ftString, 8);
  CDSRegistro3.FieldDefs.add('HORA_FIM_JORNADA', ftString, 8);
  CDSRegistro3.FieldDefs.add('CARGA_HORARIA', ftString, 8);

  CDSRegistro3.CreateDataset;
  CDSRegistro3.Open;

  ConfiguraCDSFromVO(CDSPontoFechamentoJornada, TPontoFechamentoJornadaVO);
end;

procedure TFPontoTratamentoArquivoAFD.ActionSairExecute(Sender: TObject);
begin
  Close;
end;
{$ENDREGION}

{$REGION 'Controles CRUD'}
procedure TFPontoTratamentoArquivoAFD.ActionSalvarExecute(Sender: TObject);
var
  PontoMarcacaoComLista: TPontoMarcacaoVO;
  PontoMarcacao: TPontoMarcacaoVO;
  PontoFechamentoJornada: TPontoFechamentoJornadaVO;
begin
  if Application.MessageBox('Deseja salvar as informações no banco de dados?', 'Pergunta do Sistema', MB_YesNo + MB_IconQuestion) = IdYes then
  begin
    try
      CDSRegistro3.DisableControls;
      CDSPontoFechamentoJornada.DisableControls;

      // Verifica se existem registros para serem persistidos
      CDSRegistro3.Filtered := False;
      CDSRegistro3.Filter := 'SITUACAO_REGISTRO = ' + QuotedStr('Não Armazenado');
      CDSRegistro3.Filtered := True;
      if CDSRegistro3.RecordCount = 0 then
      begin
        Application.MessageBox('Não existem registros para serem armazenados na base de dados.', 'Informação do Sistema', MB_OK + MB_IconInformation);
        Exit;
      end;

      // Verifica existem registros pendentes nas marcações
      CDSRegistro3.Filtered := False;
      CDSRegistro3.Filter := 'SITUACAO_REGISTRO = ' + QuotedStr('Pendente');
      CDSRegistro3.Filtered := True;
      if CDSRegistro3.RecordCount > 0 then
      begin
        Application.MessageBox('Existem pendências nas marcações. Dados não podem ser persistidos.', 'Informação do Sistema', MB_OK + MB_IconInformation);
        Exit;
      end;

      ActionProcessarFechamento.Execute;

      // Verifica existem registros pendentes no fechamento
      CDSPontoFechamentoJornada.Filtered := False;
      CDSPontoFechamentoJornada.Filter := 'SITUACAO = ' + QuotedStr('Pendente');
      CDSPontoFechamentoJornada.Filtered := True;
      if CDSPontoFechamentoJornada.RecordCount > 0 then
      begin
        Application.MessageBox('Existem pendências no fechamento. Dados não podem ser persistidos.', 'Informação do Sistema', MB_OK + MB_IconInformation);
        Exit;
      end;

      if ValidarDadosInformados then
      begin
        CDSRegistro3.Filtered := False;
        CDSPontoFechamentoJornada.Filtered := False;

        // Marcações
        PontoMarcacaoComLista := TPontoMarcacaoVO.Create;
        CDSRegistro3.First;
        while not CDSRegistro3.eof do
        begin
          PontoMarcacao := TPontoMarcacaoVO.Create;
          PontoMarcacao.IdColaborador := CDSRegistro3.FieldByName('ID_COLABORADOR').AsInteger;
          PontoMarcacao.IdPontoRelogio := CDSRegistro3.FieldByName('ID_PONTO_RELOGIO').AsInteger;
          if CDSRegistro3.FieldByName('Nsr').AsString <> 'Incluido' then
            PontoMarcacao.Nsr := CDSRegistro3.FieldByName('Nsr').AsInteger;
          PontoMarcacao.DataMarcacao := StrToDate(FormatMaskText('##/##/####;0;_', CDSRegistro3.FieldByName('DataMarcacao').AsString));
          PontoMarcacao.HoraMarcacao := FormatMaskText('##:##;0;_', CDSRegistro3.FieldByName('HoraMarcacao').AsString) + ':00';
          PontoMarcacao.TipoMarcacao := Copy(CDSRegistro3.FieldByName('TIPO_MARCACAO').AsString, 1, 1);
          PontoMarcacao.TipoRegistro := Copy(CDSRegistro3.FieldByName('TIPO_REGISTRO').AsString, 1, 1);
          PontoMarcacao.Justificativa := CDSRegistro3.FieldByName('JUSTIFICATIVA').AsString;
          PontoMarcacao.ParEntradaSaida := CDSRegistro3.FieldByName('PAR_ENTRADA_SAIDA').AsString;
          //PontoMarcacaoComLista.ListaPontoMarcacao.Add(PontoMarcacao);
          CDSRegistro3.Next;
        end;
        CDSRegistro3.First;

        // Fechamento
        CDSPontoFechamentoJornada.First;
        while not CDSPontoFechamentoJornada.eof do
        begin
          PontoFechamentoJornada := TPontoFechamentoJornadaVO.Create;
          PontoFechamentoJornada.IdPontoClassificacaoJornada := CDSPontoFechamentoJornada.FieldByName('ID_PONTO_CLASSIFICACAO_JORNADA').AsInteger;
          PontoFechamentoJornada.IdColaborador := CDSPontoFechamentoJornada.FieldByName('ID_COLABORADOR').AsInteger;
          PontoFechamentoJornada.DataFechamento := CDSPontoFechamentoJornada.FieldByName('DATA_FECHAMENTO').AsDateTime;
          PontoFechamentoJornada.DiaSemana := CDSPontoFechamentoJornada.FieldByName('DIA_SEMANA').AsString;
          PontoFechamentoJornada.CodigoHorario := CDSPontoFechamentoJornada.FieldByName('CODIGO_HORARIO').AsString;
          PontoFechamentoJornada.CargaHorariaEsperada := CDSPontoFechamentoJornada.FieldByName('CARGA_HORARIA_ESPERADA').AsString;
          PontoFechamentoJornada.CargaHorariaDiurna := CDSPontoFechamentoJornada.FieldByName('CARGA_HORARIA_DIURNA').AsString;
          PontoFechamentoJornada.CargaHorariaNoturna := CDSPontoFechamentoJornada.FieldByName('CARGA_HORARIA_NOTURNA').AsString;
          PontoFechamentoJornada.CargaHorariaTotal := CDSPontoFechamentoJornada.FieldByName('CARGA_HORARIA_TOTAL').AsString;
          PontoFechamentoJornada.Entrada01 := CDSPontoFechamentoJornada.FieldByName('ENTRADA01').AsString;
          PontoFechamentoJornada.Entrada02 := CDSPontoFechamentoJornada.FieldByName('ENTRADA02').AsString;
          PontoFechamentoJornada.Entrada03 := CDSPontoFechamentoJornada.FieldByName('ENTRADA03').AsString;
          PontoFechamentoJornada.Entrada04 := CDSPontoFechamentoJornada.FieldByName('ENTRADA04').AsString;
          PontoFechamentoJornada.Entrada05 := CDSPontoFechamentoJornada.FieldByName('ENTRADA05').AsString;
          PontoFechamentoJornada.Saida01 := CDSPontoFechamentoJornada.FieldByName('SAIDA01').AsString;
          PontoFechamentoJornada.Saida02 := CDSPontoFechamentoJornada.FieldByName('SAIDA02').AsString;
          PontoFechamentoJornada.Saida03 := CDSPontoFechamentoJornada.FieldByName('SAIDA03').AsString;
          PontoFechamentoJornada.Saida04 := CDSPontoFechamentoJornada.FieldByName('SAIDA04').AsString;
          PontoFechamentoJornada.Saida05 := CDSPontoFechamentoJornada.FieldByName('SAIDA05').AsString;
          PontoFechamentoJornada.HoraInicioJornada := CDSPontoFechamentoJornada.FieldByName('HORA_INICIO_JORNADA').AsString;
          PontoFechamentoJornada.HoraFimJornada := CDSPontoFechamentoJornada.FieldByName('HORA_FIM_JORNADA').AsString;
          PontoFechamentoJornada.HoraExtra01 := CDSPontoFechamentoJornada.FieldByName('HORA_EXTRA01').AsString;
          PontoFechamentoJornada.HoraExtra02 := CDSPontoFechamentoJornada.FieldByName('HORA_EXTRA02').AsString;
          PontoFechamentoJornada.HoraExtra03 := CDSPontoFechamentoJornada.FieldByName('HORA_EXTRA03').AsString;
          PontoFechamentoJornada.HoraExtra04 := CDSPontoFechamentoJornada.FieldByName('HORA_EXTRA04').AsString;
          PontoFechamentoJornada.PercentualHoraExtra01 := CDSPontoFechamentoJornada.FieldByName('PERCENTUAL_HORA_EXTRA01').AsFloat;
          PontoFechamentoJornada.PercentualHoraExtra02 := CDSPontoFechamentoJornada.FieldByName('PERCENTUAL_HORA_EXTRA02').AsFloat;
          PontoFechamentoJornada.PercentualHoraExtra03 := CDSPontoFechamentoJornada.FieldByName('PERCENTUAL_HORA_EXTRA03').AsFloat;
          PontoFechamentoJornada.PercentualHoraExtra04 := CDSPontoFechamentoJornada.FieldByName('PERCENTUAL_HORA_EXTRA04').AsFloat;
          PontoFechamentoJornada.ModalidadeHoraExtra01 := CDSPontoFechamentoJornada.FieldByName('MODALIDADE_HORA_EXTRA01').AsString;
          PontoFechamentoJornada.ModalidadeHoraExtra02 := CDSPontoFechamentoJornada.FieldByName('MODALIDADE_HORA_EXTRA02').AsString;
          PontoFechamentoJornada.ModalidadeHoraExtra03 := CDSPontoFechamentoJornada.FieldByName('MODALIDADE_HORA_EXTRA03').AsString;
          PontoFechamentoJornada.ModalidadeHoraExtra04 := CDSPontoFechamentoJornada.FieldByName('MODALIDADE_HORA_EXTRA04').AsString;
          PontoFechamentoJornada.FaltaAtraso := CDSPontoFechamentoJornada.FieldByName('FALTA_ATRASO').AsString;
          PontoFechamentoJornada.Compensar := CDSPontoFechamentoJornada.FieldByName('COMPENSAR').AsString;
          PontoFechamentoJornada.BancoHoras := CDSPontoFechamentoJornada.FieldByName('BANCO_HORAS').AsString;
          PontoFechamentoJornada.Observacao := CDSPontoFechamentoJornada.FieldByName('OBSERVACAO').AsString;
          PontoMarcacaoComLista.ListaPontoFechamentoJornada.Add(PontoFechamentoJornada);
          CDSPontoFechamentoJornada.Next;
        end;
        CDSPontoFechamentoJornada.First;
        //
        TPontoMarcacaoController.InsereLista(PontoMarcacaoComLista);
        VerificarDadosNaBase;
        ActionValidarDados.Execute;
      end;
    finally
      CDSRegistro3.Filtered := False;
      CDSPontoFechamentoJornada.Filtered := False;
      CDSRegistro3.EnableControls;
      CDSPontoFechamentoJornada.EnableControls;
    end;
  end;
end;
{$ENDREGION}

{$REGION 'Controle de Grid'}
procedure TFPontoTratamentoArquivoAFD.GridMarcacaoKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  (*

  /// EXERCICIO: Implemente com a janela FLookup

  if Key = VK_F1 then
  begin
    try
      Application.CreateForm(TFLookup, FLookup);
      ULookup.FLookup.ObjetoVO := TViewPessoaColaboradorVO.Create;
      ULookup.FLookup.ObjetoController := TViewPessoaColaboradorController.Create;
      FLookup.ShowModal;
      if FLookup.CDSLookup.RecordCount > 0 then
      begin
        CDSRegistro3.Append;
        CDSRegistro3.FieldByName('Nsr').AsString := 'Incluido';
        CDSRegistro3.FieldByName('SITUACAO_REGISTRO').AsString := 'Não Armazenado';
        CDSRegistro3.FieldByName('TIPO_REGISTRO').AsString := 'Incluido';
        CDSRegistro3.FieldByName('NumeroPis').AsString := FLookup.CDSLookup.FieldByName('PIS_NUMERO').AsString;
        CDSRegistro3.FieldByName('NOME_COLABORADOR').AsString := FLookup.CDSLookup.FieldByName('NOME').AsString;
        CDSRegistro3.FieldByName('CODIGO_TURMA_PONTO').AsString := FLookup.CDSLookup.FieldByName('CODIGO_TURMA_PONTO').AsString;
        CDSRegistro3ID_COLABORADOR.AsInteger := FLookup.CDSLookup.FieldByName('ID').AsInteger;
        CDSRegistro3.FieldByName('NumeroSerieRep').AsString := FMenu.vACBrPonto.Ponto_AFD.Cabecalho.Campo07;

        // Pega o ID do Relógio de Ponto
        TPontoRelogioController.SetDataSet(CDSPontoRelogio);
    BotaoConsultar.Click;
        if CDSPontoRelogio.RecordCount > 0 then
          CDSRegistro3.FieldByName('ID_PONTO_RELOGIO').AsInteger := CDSPontoRelogioID').AsInteger;

        CDSRegistro3.Post;
        //
        Application.CreateForm(TFPontoRegistroIncluidoAFD, FPontoRegistroIncluidoAFD);
        FPontoRegistroIncluidoAFD.ShowModal;
      end;
    finally
    end;
  end;
  *)
end;

procedure TFPontoTratamentoArquivoAFD.CDSRegistro3AfterPost(DataSet: TDataSet);
begin
  if CDSRegistro3.FieldByName('Nsr').AsString = '' then
    CDSRegistro3.Delete;
end;
{$ENDREGION}

{$REGION 'Controle de Popup'}
procedure TFPontoTratamentoArquivoAFD.DesconsiderarMarcao1Click(Sender: TObject);
begin
  if not CDSRegistro3.IsEmpty then
  begin
    if CDSRegistro3.FieldByName('SITUACAO_REGISTRO').AsString = 'Pendente' then
      Application.MessageBox('Registros pendentes não serão armazenados.', 'Informação do Sistema', MB_OK + MB_IconInformation)
    else
    begin
      if Application.MessageBox('Deseja realmente desconsiderar o registro?', 'Pergunta do Sistema', MB_YesNo + MB_IconQuestion) = IdYes then
      begin
        CDSRegistro3.Edit;
        CDSRegistro3.FieldByName('TIPO_MARCACAO').AsString := 'Desconsiderar';
        CDSRegistro3.Post;
      end;
    end;
  end;
end;

procedure TFPontoTratamentoArquivoAFD.RemoverRegistroIncludo1Click(Sender: TObject);
begin
  if not CDSRegistro3.IsEmpty then
  begin
    if CDSRegistro3.FieldByName('Nsr').AsString <> 'Incluido' then
      Application.MessageBox('Apenas registros incluídos manualmente podem ser removidos.', 'Informação do Sistema', MB_OK + MB_IconInformation)
    else
    begin
      if Application.MessageBox('Deseja realmente excluir o registro?', 'Pergunta do Sistema', MB_YesNo + MB_IconQuestion) = IdYes then
        CDSRegistro3.Delete;
    end;
  end;
end;
{$ENDREGION}

{$REGION 'Actions'}
procedure TFPontoTratamentoArquivoAFD.ActionImportarArquivoExecute(Sender: TObject);
var
  i: Integer;
begin

  /// EXERCICIO: Migre o componente ACBrPonto do Delphi para o Lazarus e instale

  if FDataModule.OpenDialog.Execute then
  begin
    CDSRegistro3.DisableControls;
    CDSRegistro3.Close;
    CDSRegistro3.Open;

    FMenu.vACBrPonto.Ponto_AFD := FMenu.vACBrPonto.ProcessarArquivo_AFD(FDataModule.OpenDialog.FileName);

    // primeiro grava os dados que estão no arquivo AFD
    for i := 0 to FMenu.vACBrPonto.Ponto_AFD.Registro3.Count - 1 do
    begin
      CDSRegistro3.Append;
      CDSRegistro3.FieldByName('Nsr').AsString := FMenu.vACBrPonto.Ponto_AFD.Registro3.Items[i].Campo01;
      CDSRegistro3.FieldByName('TipoRegistro').AsString := FMenu.vACBrPonto.Ponto_AFD.Registro3.Items[i].Campo02;
      CDSRegistro3.FieldByName('DataMarcacao').AsString := FMenu.vACBrPonto.Ponto_AFD.Registro3.Items[i].Campo03;
      CDSRegistro3.FieldByName('HoraMarcacao').AsString := FMenu.vACBrPonto.Ponto_AFD.Registro3.Items[i].Campo04;
      CDSRegistro3.FieldByName('NumeroPis').AsString := FMenu.vACBrPonto.Ponto_AFD.Registro3.Items[i].Campo05;
      CDSRegistro3.FieldByName('NumeroSerieRep').AsString := FMenu.vACBrPonto.Ponto_AFD.Cabecalho.Campo07;
      CDSRegistro3.Post;
    end;
    CDSRegistro3.EnableControls;
  end;

  // Ordena os registros por: PIS, Data e Hora
  CDSRegistro3.IndexFieldNames := 'NumeroPis; DataMarcacao; HoraMarcacao';

  // Verifica se os dados já estão no banco de dados
  VerificarDadosNaBase;

  // Valida os dados apresentados na Grid
  ActionValidarDados.Execute;

  GridMarcacao.SetFocus;
end;

procedure TFPontoTratamentoArquivoAFD.VerificarDadosNaBase;
var
  Filtro: String;
  Colaborador: TViewPessoaColaboradorVO;
  Relogio: TPontoRelogioVO;
  PontoMarcacao: TPontoMarcacaoVO;
begin
  CDSRegistro3.DisableControls;
  CDSRegistro3.First;
  while not CDSRegistro3.eof do
  begin
    // Pega o nome do colaborador
    /// EXERCICIO: O que existe de errado na consulta abaixo? Corrija.
    Colaborador := TViewPessoaColaboradorController.ConsultaObjeto('PIS_NUMERO = ' + QuotedStr(CDSRegistro3.FieldByName('NumeroPis').AsString));

    CDSRegistro3.Edit;
    if Assigned(Colaborador) then
    begin
      if Colaborador.CodigoTurmaPonto = '' then
      begin
        CDSRegistro3.FieldByName('NOME_COLABORADOR').AsString := 'Colaborador está sem o código da turma cadastrada';
        CDSRegistro3.FieldByName('SITUACAO_REGISTRO').AsString := 'Pendente';
      end
      else
      begin
        // Pega os dados do relógio de ponto
        Relogio := TPontoRelogioController.ConsultaObjeto('NUMERO_SERIE = ' + QuotedStr(CDSRegistro3.FieldByName('NumeroSerieRep').AsString));

        if Assigned(Relogio) then
        begin
          CDSRegistro3.FieldByName('ID_PONTO_RELOGIO').AsInteger := Relogio.Id;
          CDSRegistro3.FieldByName('ID_COLABORADOR').AsInteger := Colaborador.Id;
          CDSRegistro3.FieldByName('NOME_COLABORADOR').AsString := Colaborador.Nome;
          CDSRegistro3.FieldByName('CODIGO_TURMA_PONTO').AsString := Colaborador.CodigoTurmaPonto;

          // Verifica se o registro já foi armazenado no banco de dados
          Filtro := 'NSR = ' + QuotedStr(CDSRegistro3.FieldByName('Nsr').AsString) + ' and ID_PONTO_RELOGIO = ' + QuotedStr(IntToStr(Relogio.Id));
          PontoMarcacao := TPontoMarcacaoController.ConsultaObjeto(Filtro);

          if Assigned(PontoMarcacao) then
          begin
            CDSRegistro3.FieldByName('SITUACAO_REGISTRO').AsString := 'Já Armazenado';
            CDSRegistro3.FieldByName('TIPO_MARCACAO').AsString := PontoMarcacao.TipoMarcacao;
            CDSRegistro3.FieldByName('TIPO_REGISTRO').AsString := PontoMarcacao.TipoRegistro;
            CDSRegistro3.FieldByName('JUSTIFICATIVA').AsString := PontoMarcacao.Justificativa;
            CDSRegistro3.FieldByName('PAR_ENTRADA_SAIDA').AsString := PontoMarcacao.ParEntradaSaida;
          end
          else
          begin
            if CDSRegistro3.FieldByName('Nsr').AsString = 'Incluido' then
              CDSRegistro3.FieldByName('SITUACAO_REGISTRO').AsString := 'Já Armazenado'
            else
              CDSRegistro3.FieldByName('SITUACAO_REGISTRO').AsString := 'Não Armazenado';
          end;
        end
        else
        begin
          CDSRegistro3.FieldByName('NOME_COLABORADOR').AsString := 'Número de série do REP não encontrado na base de dados';
          CDSRegistro3.FieldByName('SITUACAO_REGISTRO').AsString := 'Pendente';
        end;
      end;
    end
    else
    begin
      CDSRegistro3.FieldByName('NOME_COLABORADOR').AsString := 'Número do PIS não encontrado na base de dados';
      CDSRegistro3.FieldByName('SITUACAO_REGISTRO').AsString := 'Pendente';
    end;
    CDSRegistro3.Post;
    CDSRegistro3.Next;
  end;
  CDSRegistro3.First;
  CDSRegistro3.EnableControls;
end;

procedure TFPontoTratamentoArquivoAFD.ActionValidarDadosExecute(Sender: TObject);
var
  i, SegundosHoraMarcada, SegundosHoraHorario, DiferencaSegundosAnterior, DiferencaSegundos: Integer;
  Filtro, CampoAtual, CampoSelecionado: String;
  PontoEscalaTurma: TViewPontoEscalaTurmaVO;
  CDSPontoHorario: TZQuery;
begin
  if CDSRegistro3.IsEmpty then
    Application.MessageBox('Não existem dados para validação.', 'Informação do Sistema', MB_OK + MB_IconInformation)
  else
  begin
    CDSRegistro3.DisableControls;
    CDSRegistro3.First;
    while not CDSRegistro3.eof do
    begin
      if CDSRegistro3.FieldByName('SITUACAO_REGISTRO').AsString = 'Já Armazenado' then
      begin
        CDSRegistro3.Edit;
        case AnsiIndexStr(CDSRegistro3.FieldByName('TIPO_MARCACAO').AsString, ['E', 'S', 'D']) of
          0:
            CDSRegistro3.FieldByName('TIPO_MARCACAO').AsString := 'Entrada';
          1:
            CDSRegistro3.FieldByName('TIPO_MARCACAO').AsString := 'Saida';
          2:
            CDSRegistro3.FieldByName('TIPO_MARCACAO').AsString := 'Desconsiderar';
        end;
        //
        case AnsiIndexStr(CDSRegistro3.FieldByName('TIPO_REGISTRO').AsString, ['O', 'I', 'P']) of
          0:
            CDSRegistro3.FieldByName('TIPO_REGISTRO').AsString := 'Original';
          1:
            CDSRegistro3.FieldByName('TIPO_REGISTRO').AsString := 'Incluido';
          2:
            CDSRegistro3.FieldByName('TIPO_REGISTRO').AsString := 'Pre-Assinalado';
        end;
        CDSRegistro3.Post;
      end
      else
      begin
        if (CDSRegistro3.FieldByName('SITUACAO_REGISTRO').AsString <> 'Pendente') and (CDSRegistro3.FieldByName('TIPO_MARCACAO').AsString <> 'Desconsiderar') then
        begin

          // Pega os dados da escala e turma do colaborador selecionado
          Filtro := 'CODIGO_TURMA = ' + QuotedStr(CDSRegistro3.FieldByName('CODIGO_TURMA_PONTO').AsString);
          PontoEscalaTurma := TViewPontoEscalaTurmaController.ConsultaObjeto(Filtro);

          CDSPontoHorario.Close;
          CDSPontoHorario.Open;

          // Pega os dados do horário do dia selecionado
          case DayOfWeek(StrToDate(FormatMaskText('##/##/####;0;_', CDSRegistro3.FieldByName('DataMarcacao').AsString))) of
            1:
              CDSPontoHorario := TPontoHorarioController.Consulta('CODIGO = ' + QuotedStr(PontoEscalaTurma.CodigoHorarioDomingo), '0');
            2:
              CDSPontoHorario := TPontoHorarioController.Consulta('CODIGO = ' + QuotedStr(PontoEscalaTurma.CodigoHorarioSegunda), '0');
            3:
              CDSPontoHorario := TPontoHorarioController.Consulta('CODIGO = ' + QuotedStr(PontoEscalaTurma.CodigoHorarioTerca), '0');
            4:
              CDSPontoHorario := TPontoHorarioController.Consulta('CODIGO = ' + QuotedStr(PontoEscalaTurma.CodigoHorarioQuarta), '0');
            5:
              CDSPontoHorario := TPontoHorarioController.Consulta('CODIGO = ' + QuotedStr(PontoEscalaTurma.CodigoHorarioQuinta), '0');
            6:
              CDSPontoHorario := TPontoHorarioController.Consulta('CODIGO = ' + QuotedStr(PontoEscalaTurma.CodigoHorarioSexta), '0');
            7:
              CDSPontoHorario := TPontoHorarioController.Consulta('CODIGO = ' + QuotedStr(PontoEscalaTurma.CodigoHorarioSabado), '0');
          end;

          if CDSPontoHorario.RecordCount = 0 then
          begin
            CDSRegistro3.Edit;
            CDSRegistro3.FieldByName('NOME_COLABORADOR').AsString := 'Código do horário cadastrado na escala não corresponde a um horário armazenado';
            CDSRegistro3.FieldByName('SITUACAO_REGISTRO').AsString := 'Pendente';
            CDSRegistro3.Post;
          end
          else
          begin
            if CDSRegistro3.FieldByName('TIPO_REGISTRO').AsString <> 'Incluido' then
            begin
              // Compara o horário marcado no arquivo com cada horário armazenado na base. O horário será alocado naquele que tiver menor diferença em segundos
              DiferencaSegundosAnterior := 0; // Guarda a diferença em segundos da comparaçao feita anteriormente entre o horário marcado e o horário da escala que está na base
              for i := 0 to CDSPontoHorario.FieldCount - 1 do
              begin
                if (Copy(CDSPontoHorario.Fields[i].FieldName, 1, 5) = 'ENTRA') or (Copy(CDSPontoHorario.Fields[i].FieldName, 1, 5) = 'SAIDA') then
                begin
                  CampoAtual := CDSPontoHorario.Fields[i].FieldName;

                  if Length(Trim(CDSPontoHorario.FieldByName(CampoAtual).AsString)) = 8 then
                  begin
                    SegundosHoraMarcada := Hora_Seg(FormatMaskText('##:##;0;_', CDSRegistro3.FieldByName('HoraMarcacao').AsString) + ':00');
                    SegundosHoraHorario := Hora_Seg(CDSPontoHorario.FieldByName(CampoAtual).AsString);
                    DiferencaSegundos := Abs(SegundosHoraMarcada - SegundosHoraHorario);
                    if DiferencaSegundosAnterior = 0 then
                      DiferencaSegundosAnterior := DiferencaSegundos;

                    // Caso a diferença de segundos atual seja menor, guarda o campo atual
                    if DiferencaSegundos <= DiferencaSegundosAnterior then
                    begin
                      DiferencaSegundosAnterior := DiferencaSegundos;
                      CampoSelecionado := CampoAtual;
                    end;
                  end;
                end;
              end;
            end;

            CDSRegistro3.Edit;
            CDSRegistro3.FieldByName('CARGA_HORARIA').AsString := CDSPontoHorario.FieldByName('CARGA_HORARIA').AsString;
            CDSRegistro3.FieldByName('CODIGO_HORARIO').AsString := CDSPontoHorario.FieldByName('CODIGO').AsString;
            CDSRegistro3.FieldByName('HORA_INICIO_JORNADA').AsString := CDSPontoHorario.FieldByName('HORA_INICIO_JORNADA').AsString;
            CDSRegistro3.FieldByName('HORA_FIM_JORNADA').AsString := CDSPontoHorario.FieldByName('HORA_FIM_JORNADA').AsString;
            if CDSRegistro3.FieldByName('TIPO_REGISTRO').AsString <> 'Incluido' then
            begin
              CDSRegistro3.FieldByName('TIPO_MARCACAO').AsString := IfThen(Copy(CampoSelecionado, 1, 1) = 'E', 'Entrada', 'Saida');
              CDSRegistro3.FieldByName('PAR_ENTRADA_SAIDA').AsString := Copy(CampoSelecionado, 1, 1) + Copy(CampoSelecionado, Length(CampoSelecionado), 1);
            end;
            if CDSRegistro3.FieldByName('TIPO_REGISTRO').AsString = '' then
              CDSRegistro3.FieldByName('TIPO_REGISTRO').AsString := 'Original';
            CDSRegistro3.Post;
          end;
        end;
      end;
      CDSRegistro3.Next;
    end;
    CDSRegistro3.First;
    CDSRegistro3.EnableControls;
  end;
end;

procedure TFPontoTratamentoArquivoAFD.ActionProcessarFechamentoExecute(Sender: TObject);
var
  Filtro, CampoAtual, CampoAnteriorEntrada, CampoAnteriorSaida, Pis, DataSelecionada: String;
  i, SegundosEntradasDia, SegundosSaidasDia, SegundosNoite, HoraNoturnaInicio, SegundosDiferenca: Integer;
  TemBuraco: Boolean;
  PontoClassificacao: TPontoClassificacaoJornadaVO;
  Parametro: TPontoParametroVO;
begin
  try
    CDSRegistro3.DisableControls;

    // Verifica existem registros pendentes nas marcações
    CDSRegistro3.Filtered := False;
    CDSRegistro3.Filter := 'SITUACAO_REGISTRO = ' + QuotedStr('Pendente');
    CDSRegistro3.Filtered := True;
    if CDSRegistro3.RecordCount > 0 then
    begin
      Application.MessageBox('Existem pendências nas marcações.', 'Informação do Sistema', MB_OK + MB_IconInformation);
      Exit;
    end;

    // Controla se existe uma lacuna entre o par entrada/saida
    TemBuraco := False;

    // Pega o tipo de classificação de jornada padrão para a empresa corrente
    Filtro := 'ID_EMPRESA = 1 and PADRAO = ' + QuotedStr('S');
    PontoClassificacao := TPontoClassificacaoJornadaController.ConsultaObjeto(Filtro);

    CDSPontoFechamentoJornada.DisableControls;
    CDSPontoFechamentoJornada.Close;
    CDSPontoFechamentoJornada.Open;
    CDSRegistro3.Filtered := False;
    CDSRegistro3.Filter := 'TIPO_MARCACAO <> ' + QuotedStr('Desconsiderar');
    CDSRegistro3.Filtered := True;

    // Ordena os registros por: PIS, Data e Par Entrada/Saida
    CDSRegistro3.IndexFieldNames := 'NumeroPis; DataMarcacao; PAR_ENTRADA_SAIDA';

    CDSRegistro3.First;
    while not CDSRegistro3.eof do
    begin
      if (CDSRegistro3.FieldByName('NumeroPis').AsString <> Pis) or (CDSRegistro3.FieldByName('DataMarcacao').AsString <> DataSelecionada) then
      begin
        Pis := CDSRegistro3.FieldByName('NumeroPis').AsString;
        DataSelecionada := CDSRegistro3.FieldByName('DataMarcacao').AsString;

        CDSPontoFechamentoJornada.Append;
        CDSPontoFechamentoJornada.FieldByName('ID_PONTO_CLASSIFICACAO_JORNADA').AsInteger := PontoClassificacao.Id;
        CDSPontoFechamentoJornada.FieldByName('ID_COLABORADOR').AsInteger := CDSRegistro3.FieldByName('ID_COLABORADOR').AsInteger;
        CDSPontoFechamentoJornada.FieldByName('NOME_COLABORADOR').AsString := CDSRegistro3.FieldByName('NOME_COLABORADOR').AsString;
        CDSPontoFechamentoJornada.FieldByName('DATA_FECHAMENTO').AsDateTime := StrToDate(FormatMaskText('##/##/####;0;_', CDSRegistro3.FieldByName('DataMarcacao').AsString));
        case DayOfWeek(StrToDate(FormatMaskText('##/##/####;0;_', CDSRegistro3.FieldByName('DataMarcacao').AsString))) of
          1:
            CDSPontoFechamentoJornada.FieldByName('DIA_SEMANA').AsString := 'DOMINGO';
          2:
            CDSPontoFechamentoJornada.FieldByName('DIA_SEMANA').AsString := 'SEGUNDA';
          3:
            CDSPontoFechamentoJornada.FieldByName('DIA_SEMANA').AsString := 'TERCA';
          4:
            CDSPontoFechamentoJornada.FieldByName('DIA_SEMANA').AsString := 'QUARTA';
          5:
            CDSPontoFechamentoJornada.FieldByName('DIA_SEMANA').AsString := 'QUINTA';
          6:
            CDSPontoFechamentoJornada.FieldByName('DIA_SEMANA').AsString := 'SEXTA';
          7:
            CDSPontoFechamentoJornada.FieldByName('DIA_SEMANA').AsString := 'SABADO';
        end;
        CDSPontoFechamentoJornada.FieldByName('CODIGO_HORARIO').AsString := CDSRegistro3.FieldByName('CODIGO_HORARIO').AsString;
        CDSPontoFechamentoJornada.FieldByName('CARGA_HORARIA_ESPERADA').AsString := CDSRegistro3.FieldByName('CARGA_HORARIA').AsString;
        CDSPontoFechamentoJornada.FieldByName('ENTRADA01').AsString := FormatMaskText('##:##;0;_', CDSRegistro3.FieldByName('HoraMarcacao').AsString) + ':00';
        CDSPontoFechamentoJornada.FieldByName('HORA_INICIO_JORNADA').AsString := CDSRegistro3.FieldByName('HORA_INICIO_JORNADA').AsString;
        CDSPontoFechamentoJornada.FieldByName('HORA_FIM_JORNADA').AsString := CDSRegistro3.FieldByName('HORA_FIM_JORNADA').AsString;
      end
      else
      begin
        CDSPontoFechamentoJornada.Edit;
        if Copy(CDSRegistro3.FieldByName('PAR_ENTRADA_SAIDA').AsString, 1, 1) = 'E' then
          CDSPontoFechamentoJornada.FieldByName('ENTRADA0' + Copy(CDSRegistro3.FieldByName('PAR_ENTRADA_SAIDA').AsString, 2, 1)).AsString := FormatMaskText('##:##;0;_', CDSRegistro3.FieldByName('HoraMarcacao').AsString) + ':00'
        else
          CDSPontoFechamentoJornada.FieldByName('SAIDA0' + Copy(CDSRegistro3.FieldByName('PAR_ENTRADA_SAIDA').AsString, 2, 1)).AsString := FormatMaskText('##:##;0;_', CDSRegistro3.FieldByName('HoraMarcacao').AsString) + ':00'
      end;

      CDSPontoFechamentoJornada.Post;
      CDSRegistro3.Next;
    end;

    // Realiza os cálculos necessários
    CDSPontoFechamentoJornada.First;
    while not CDSPontoFechamentoJornada.eof do
    begin
      // Pega os parâmetros do mês da data do fechamento
      Parametro := TPontoParametroController.ConsultaObjeto('MES_ANO = ' + QuotedStr(Copy(CDSPontoFechamentoJornada.FieldByName('DATA_FECHAMENTO').AsString, 4, 7)));
      if not Assigned(Parametro) then
      begin
        CDSPontoFechamentoJornada.Edit;
        CDSPontoFechamentoJornada.FieldByName('SITUACAO').AsString := 'Pendente';
        CDSPontoFechamentoJornada.FieldByName('OBSERVACAO').AsString := 'Não existe parâmetro cadastrado para o mês ' + Copy(CDSPontoFechamentoJornada.FieldByName('DATA_FECHAMENTO').AsString, 4, 7);
        CDSPontoFechamentoJornada.Post;
      end
      else
      begin
        HoraNoturnaInicio := Hora_Seg(Parametro.HoraNoturnaInicio);

        SegundosEntradasDia := 0;
        SegundosSaidasDia := 0;
        SegundosNoite := 0;
        for i := 0 to CDSPontoFechamentoJornada.FieldCount - 1 do
        begin
          if (Copy(CDSPontoFechamentoJornada.Fields[i].FieldName, 1, 5) = 'ENTRA') or (Copy(CDSPontoFechamentoJornada.Fields[i].FieldName, 1, 5) = 'SAIDA') then
          begin
          CampoAtual := CDSPontoFechamentoJornada.Fields[i].FieldName;
            if Length(Trim(CDSPontoFechamentoJornada.FieldByName(CampoAtual).AsString)) = 8 then
            begin
              if Copy(CampoAtual, 1, 1) = 'E' then
              begin
                if CampoAnteriorEntrada = '' then
                  CampoAnteriorEntrada := CampoAtual;
                if StrToInt(Copy(CampoAtual, Length(CampoAtual), 1)) - StrToInt(Copy(CampoAnteriorEntrada, Length(CampoAnteriorEntrada), 1)) > 1 then
                  TemBuraco := True;
                SegundosEntradasDia := SegundosEntradasDia + Hora_Seg(CDSPontoFechamentoJornada.FieldByName(CampoAtual).AsString);
                CampoAnteriorEntrada := CampoAtual;
              end
              else
              begin
                if CampoAnteriorSaida = '' then
                  CampoAnteriorSaida := CampoAtual;
                if StrToInt(Copy(CampoAtual, Length(CampoAtual), 1)) - StrToInt(Copy(CampoAnteriorSaida, Length(CampoAnteriorSaida), 1)) > 1 then
                  TemBuraco := True;
                if Hora_Seg(CDSPontoFechamentoJornada.FieldByName(CampoAtual).AsString) > HoraNoturnaInicio then
                begin
                  SegundosNoite := Hora_Seg(CDSPontoFechamentoJornada.FieldByName(CampoAtual).AsString) - HoraNoturnaInicio;
                  SegundosSaidasDia := SegundosSaidasDia + HoraNoturnaInicio;
                end
                else
                  SegundosSaidasDia := SegundosSaidasDia + Hora_Seg(CDSPontoFechamentoJornada.FieldByName(CampoAtual).AsString);
                CampoAnteriorSaida := CampoAtual;
              end;
            end;
          end;
        end;

        if SegundosSaidasDia - SegundosEntradasDia > 0 then
        begin
          CDSPontoFechamentoJornada.Edit;
          CDSPontoFechamentoJornada.FieldByName('CARGA_HORARIA_DIURNA').AsString := Seg_Hora(SegundosSaidasDia - SegundosEntradasDia);
          if TemBuraco then
          begin
            CDSPontoFechamentoJornada.FieldByName('SITUACAO').AsString := 'Pendente';
            CDSPontoFechamentoJornada.FieldByName('OBSERVACAO').AsString := 'Existe uma lacuna na marcação das entradas/saídas';
          end
          else
            CDSPontoFechamentoJornada.FieldByName('SITUACAO').AsString := 'OK';
          if SegundosNoite > 0 then
            CDSPontoFechamentoJornada.FieldByName('CARGA_HORARIA_NOTURNA').AsString := Seg_Hora(SegundosNoite);
          CDSPontoFechamentoJornada.FieldByName('CARGA_HORARIA_TOTAL').AsString := Seg_Hora(SegundosSaidasDia - SegundosEntradasDia + SegundosNoite);

          // Se a jornada for maior que a esperada, grava hora extra ou banco de horas - senão grava como falta
          if Hora_Seg(CDSPontoFechamentoJornada.FieldByName('CARGA_HORARIA_TOTAL').AsString) > Hora_Seg(CDSPontoFechamentoJornada.FieldByName('CARGA_HORARIA_ESPERADA').AsString) then
          begin
            SegundosDiferenca := Hora_Seg(CDSPontoFechamentoJornada.FieldByName('CARGA_HORARIA_TOTAL').AsString) - Hora_Seg(CDSPontoFechamentoJornada.FieldByName('CARGA_HORARIA_ESPERADA').AsString);
            // Hora Extra ou Banco de Horas
            if Parametro.TratamentoHoraMais = 'E' then
            begin
              CDSPontoFechamentoJornada.FieldByName('HORA_EXTRA01').AsString := Seg_Hora(SegundosDiferenca);
              if SegundosNoite > 0 then
              begin
                CDSPontoFechamentoJornada.FieldByName('PERCENTUAL_HORA_EXTRA01').AsFloat := Parametro.PercentualHeNoturna;
                CDSPontoFechamentoJornada.FieldByName('MODALIDADE_HORA_EXTRA01').AsString := 'N';
              end
              else
              begin
                CDSPontoFechamentoJornada.FieldByName('PERCENTUAL_HORA_EXTRA01').AsFloat := Parametro.PercentualHeDiurna;
                CDSPontoFechamentoJornada.FieldByName('MODALIDADE_HORA_EXTRA01').AsString := 'D';
              end;
            end
            else
            begin
              CDSPontoFechamentoJornada.FieldByName('COMPENSAR').AsString := '1';
              if SegundosNoite > 0 then
                CDSPontoFechamentoJornada.FieldByName('BANCO_HORAS').AsString := Seg_Hora(Trunc(SegundosDiferenca * 8/7))
              else
                CDSPontoFechamentoJornada.FieldByName('BANCO_HORAS').AsString := Seg_Hora(SegundosDiferenca);
            end;
          end
          else if Hora_Seg(CDSPontoFechamentoJornada.FieldByName('CARGA_HORARIA_TOTAL').AsString) < Hora_Seg(CDSPontoFechamentoJornada.FieldByName('CARGA_HORARIA_ESPERADA').AsString) then
          begin
            SegundosDiferenca := Hora_Seg(CDSPontoFechamentoJornada.FieldByName('CARGA_HORARIA_ESPERADA').AsString) - Hora_Seg(CDSPontoFechamentoJornada.FieldByName('CARGA_HORARIA_TOTAL').AsString);
            // Falta ou Banco de Horas
            if Parametro.TratamentoHoraMenos = 'F' then
            begin
              CDSPontoFechamentoJornada.FieldByName('FALTA_ATRASO').AsString := Seg_Hora(SegundosDiferenca);
            end
            else
            begin
              CDSPontoFechamentoJornada.FieldByName('COMPENSAR').AsString := '2';
              CDSPontoFechamentoJornada.FieldByName('BANCO_HORAS').AsString := Seg_Hora(SegundosDiferenca);
            end;
          end;
          CDSPontoFechamentoJornada.Post;
        end
        else
        begin
          CDSPontoFechamentoJornada.Edit;
          CDSPontoFechamentoJornada.FieldByName('SITUACAO').AsString := 'Pendente';
          CDSPontoFechamentoJornada.FieldByName('OBSERVACAO').AsString := 'Existe um problema na marcação das entradas/saídas';
          CDSPontoFechamentoJornada.Post;
        end;
      end;

      CDSPontoFechamentoJornada.Next;
    end;
  finally
    CDSRegistro3.Filtered := False;

    // Ordena os registros por: PIS, Data e Hora
    CDSRegistro3.IndexFieldNames := 'NumeroPis; DataMarcacao; HoraMarcacao';

    CDSRegistro3.First;
    CDSRegistro3.EnableControls;
    CDSPontoFechamentoJornada.First;
    CDSPontoFechamentoJornada.EnableControls;
  end;
end;

function TFPontoTratamentoArquivoAFD.ValidarDadosInformados: Boolean;
var
  Mensagem: String;
  Pis, DataSelecionada: String;
begin
  try
    CDSRegistro3.DisableControls;
    CDSRegistro3.First;
    while not CDSRegistro3.eof do
    begin
      if (CDSRegistro3.FieldByName('TIPO_REGISTRO').AsString = 'Incluido') and (CDSRegistro3.FieldByName('JUSTIFICATIVA').AsString = '') then
        Mensagem := Mensagem + #13 + 'Registros incluídos necessitam de justificativa. Informe a justificativa.';
      if (CDSRegistro3.FieldByName('TIPO_REGISTRO').AsString = 'Original') and (CDSRegistro3.FieldByName('JUSTIFICATIVA').AsString <> '') and (CDSRegistro3.FieldByName('TIPO_MARCACAO').AsString <> 'Desconsiderar') then
        Mensagem := Mensagem + #13 + 'Registros originais não necessitam de justificativa. Remova a justificativa. [Sequencial = ' + CDSRegistro3.FieldByName('Nsr').AsString + ']';
      if (CDSRegistro3.FieldByName('TIPO_MARCACAO').AsString = 'Desconsiderar') and (CDSRegistro3.FieldByName('JUSTIFICATIVA').AsString = '') then
        Mensagem := Mensagem + #13 + 'Registros desconsiderados necessitam de justificativa. Informe a justificativa. [Sequencial = ' + CDSRegistro3.FieldByName('Nsr').AsString + ']';
      //
      CDSRegistro3.Next;
    end;
    CDSRegistro3.First;
    CDSRegistro3.EnableControls;
    //
    if Mensagem <> '' then
    begin
      Application.MessageBox(PChar('Ocorreram erros na validação dos dados informados. Lista de erros abaixo: ' + #13 + Mensagem), 'Erro do sistema', MB_OK + MB_ICONERROR);
      Result := False;
    end
    else
      Result := True;
  finally
  end;
end;
{$ENDREGION}

end.

