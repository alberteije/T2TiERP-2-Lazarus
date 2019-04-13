{ *******************************************************************************
Title: T2Ti ERP
Description: Janela Cadastro de Tributação - ICMS Customizado

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
unit UTributIcmsCustomizado;

{$MODE Delphi}

interface

uses
  BrookHTTPClient, BrookFCLHTTPClientBroker, BrookHTTPUtils, BrookUtils, FPJson, ZDataset,
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UTelaCadastro, Menus, StdCtrls, ExtCtrls, Buttons, Grids, DBGrids,
  ComCtrls, LabeledCtrls, rxdbgrid, rxtoolbar, DBCtrls, StrUtils,
  Math, Constantes, CheckLst, ActnList, ToolWin, StdActns, ShellApi, db, BufDataset, Biblioteca,
  ULookup, VO;

type

  { TFTributIcmsCustomizado }

  TFTributIcmsCustomizado = class(TFTelaCadastro)
    CDSIcms: TBufDataset;
    ScrollBox: TScrollBox;
    PageControlDadosTributIcmsCustomizado: TPageControl;
    ToolPanel1: TToolPanel;
    tsIcms: TTabSheet;
    PanelIcms: TPanel;
    GridIcms: TRxDbGrid;
    DSIcms: TDataSource;
    ActionManager1: TActionList;
    ActionUf: TAction;
    ActionExcluirItem: TAction;
    EditDescricao: TLabeledEdit;
    BevelEdits: TBevel;
    ComboboxOrigemMercadoria: TLabeledComboBox;
    procedure FormCreate(Sender: TObject);
    procedure GridIcmsKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure ActionUfExecute(Sender: TObject);
    procedure ActionExcluirItemExecute(Sender: TObject);
    procedure BotaoConsultarClick(Sender: TObject);
    procedure BotaoSalvarClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure GridParaEdits; override;
    procedure LimparCampos; override;

    // Controles CRUD
    function DoInserir: Boolean; override;
    function DoEditar: Boolean; override;
    function DoExcluir: Boolean; override;
    function DoSalvar: Boolean; override;

    procedure ConfigurarLayoutTela;
  end;

var
  FTributIcmsCustomizado: TFTributIcmsCustomizado;

implementation

uses
    TributIcmsCustomCabVO, TributIcmsCustomDetVO, UfVO, CfopVO, CsosnBVO, CstIcmsBVO,
    TributIcmsCustomCabController, UfController, CfopController, CsosnBController, CstIcmsBController;

{$R *.lfm}

{$REGION 'Infra'}
procedure TFTributIcmsCustomizado.BotaoConsultarClick(Sender: TObject);
var
  RetornoConsulta: TZQuery;
  ListaCampos: TStringList;
  i: integer;
begin
  inherited;

  if Sessao.Camadas = 2 then
  begin
    Filtro := MontaFiltro;

    CDSGrid.Close;
    CDSGrid.Open;
    ConfiguraGridFromVO(Grid, ClasseObjetoGridVO);

    ListaCampos  := TStringList.Create;
    RetornoConsulta := TTributIcmsCustomCabController.Consulta(Filtro, IntToStr(Pagina));
    RetornoConsulta.Active := True;

    RetornoConsulta.GetFieldNames(ListaCampos);

    RetornoConsulta.First;
    while not RetornoConsulta.EOF do begin
      CDSGrid.Append;
      for i := 0 to ListaCampos.Count - 1 do
      begin
        CDSGrid.FieldByName(ListaCampos[i]).Value := RetornoConsulta.FieldByName(ListaCampos[i]).Value;
      end;
      CDSGrid.Post;
      RetornoConsulta.Next;
    end;
  end;
end;

procedure TFTributIcmsCustomizado.BotaoSalvarClick(Sender: TObject);
begin
  inherited;
  BotaoConsultarClick(Sender);
end;

procedure TFTributIcmsCustomizado.FormCreate(Sender: TObject);
begin
  ClasseObjetoGridVO := TTributIcmsCustomCabVO;
  ObjetoController := TTributIcmsCustomCabController.Create;

  inherited;

  ConfiguraCDSFromVO(CDSIcms, TTributIcmsCustomDetVO);
  ConfiguraGridFromVO(GridIcms, TTributIcmsCustomDetVO);
end;

procedure TFTributIcmsCustomizado.LimparCampos;
begin
  inherited;
  CDSIcms.Close;
  CDSIcms.Open;
end;

procedure TFTributIcmsCustomizado.ConfigurarLayoutTela;
begin
  PanelEdits.Enabled := True;
  PageControlDadosTributIcmsCustomizado.ActivePageIndex := 0;

  if StatusTela = stNavegandoEdits then
  begin
    GridIcms.ReadOnly := True;
  end
  else
  begin
    GridIcms.ReadOnly := False;
  end;
end;
{$ENDREGION}

{$REGION 'Controles CRUD'}
function TFTributIcmsCustomizado.DoInserir: Boolean;
begin
  Result := inherited DoInserir;

  if Result then
  begin
    ConfigurarLayoutTela;
    EditDescricao.SetFocus;
  end;
end;

function TFTributIcmsCustomizado.DoEditar: Boolean;
begin
  Result := inherited DoEditar;

  if Result then
  begin
    ConfigurarLayoutTela;
    EditDescricao.SetFocus;
  end;
end;

function TFTributIcmsCustomizado.DoExcluir: Boolean;
begin
  if inherited DoExcluir then
  begin
    try
      Result := TTributIcmsCustomCabController.Exclui(IdRegistroSelecionado);
    except
      Result := False;
    end;
  end
  else
  begin
    Result := False;
  end;

  if Result then
  	BotaoConsultar.Click;
end;

function TFTributIcmsCustomizado.DoSalvar: Boolean;
var
  TributIcmsCustomDet: TTributIcmsCustomDetVO;
begin
  if Trim(EditDescricao.Text) = '' then
  begin
    Application.MessageBox('Descrição não podem ficar em branco.', 'Mensagem do Sistema', MB_OK + MB_ICONINFORMATION);
    EditDescricao.SetFocus;
    Exit(False);
  end;

  Result := inherited DoSalvar;

  if Result then
  begin
    try
      if not Assigned(ObjetoVO) then
        ObjetoVO := TTributIcmsCustomCabVO.Create;

      { Cabeçalho }
      TTributIcmsCustomCabVO(ObjetoVO).Descricao := EditDescricao.Text;
      TTributIcmsCustomCabVO(ObjetoVO).IdEmpresa := Sessao.Empresa.Id;
      TTributIcmsCustomCabVO(ObjetoVO).OrigemMercadoria := Copy(ComboboxOrigemMercadoria.Text, 1, 1);

      { Detalhe }
      CDSIcms.DisableControls;
      CDSIcms.First;
      while not CDSIcms.Eof do
      begin
        TributIcmsCustomDet := TTributIcmsCustomDetVO.Create;

        TributIcmsCustomDet.Id := CDSIcms.FieldByName('ID').AsInteger;
        TributIcmsCustomDet.IdTributIcmsCustomCab := TTributIcmsCustomCabVO(ObjetoVO).Id;
        TributIcmsCustomDet.UfDestino := CDSIcms.FieldByName('UF_DESTINO').AsString;
        TributIcmsCustomDet.Cfop := CDSIcms.FieldByName('CFOP').AsInteger;
        TributIcmsCustomDet.CsosnB := CDSIcms.FieldByName('CSOSN_B').AsString;
        TributIcmsCustomDet.CstB := CDSIcms.FieldByName('CST_B').AsString;
        TributIcmsCustomDet.ModalidadeBc := CDSIcms.FieldByName('MODALIDADE_BC').AsString;
        TributIcmsCustomDet.Aliquota := CDSIcms.FieldByName('ALIQUOTA').AsFloat;
        TributIcmsCustomDet.ValorPauta := CDSIcms.FieldByName('VALOR_PAUTA').AsFloat;
        TributIcmsCustomDet.ValorPrecoMaximo := CDSIcms.FieldByName('VALOR_PRECO_MAXIMO').AsFloat;
        TributIcmsCustomDet.Mva := CDSIcms.FieldByName('MVA').AsFloat;
        TributIcmsCustomDet.PorcentoBc := CDSIcms.FieldByName('PORCENTO_BC').AsFloat;
        TributIcmsCustomDet.ModalidadeBcSt := CDSIcms.FieldByName('MODALIDADE_BC_ST').AsString;
        TributIcmsCustomDet.AliquotaInternaSt := CDSIcms.FieldByName('ALIQUOTA_INTERNA_ST').AsFloat;
        TributIcmsCustomDet.AliquotaInterestadualSt := CDSIcms.FieldByName('ALIQUOTA_INTERESTADUAL_ST').AsFloat;
        TributIcmsCustomDet.PorcentoBcSt := CDSIcms.FieldByName('PORCENTO_BC_ST').AsFloat;
        TributIcmsCustomDet.AliquotaIcmsSt := CDSIcms.FieldByName('ALIQUOTA_ICMS_ST').AsFloat;
        TributIcmsCustomDet.ValorPautaSt := CDSIcms.FieldByName('VALOR_PAUTA_ST').AsFloat;
        TributIcmsCustomDet.ValorPrecoMaximoSt := CDSIcms.FieldByName('VALOR_PRECO_MAXIMO_ST').AsFloat;

        TTributIcmsCustomCabVO(ObjetoVO).ListaTributIcmsCustomDetVO.Add(TributIcmsCustomDet);

        CDSIcms.Next;
      end;
      CDSIcms.First;
      CDSIcms.EnableControls;

      if StatusTela = stInserindo then
      begin
        TTributIcmsCustomCabController.Insere(TTributIcmsCustomCabVO(ObjetoVO));
      end
      else if StatusTela = stEditando then
      begin
        /// EXERCICIO: Verifique se tem como serializar as listas junto com o objeto para realizar a comparação
        //if TTributIcmsCustomCabVO(ObjetoVO).ToJSONString <> StringObjetoOld then
        //begin
          TTributIcmsCustomCabController.Altera(TTributIcmsCustomCabVO(ObjetoVO));
        //end
        //else
        //  Application.MessageBox('Nenhum dado foi alterado.', 'Mensagem do Sistema', MB_OK + MB_ICONINFORMATION);
      end;

    except
      Result := False;
    end;
  end;
end;
{$ENDREGION}

{$REGION 'Controle de Grid'}
procedure TFTributIcmsCustomizado.GridParaEdits;
var
  IdCabecalho: String;
  I: Integer;
  Current: TTributIcmsCustomDetVO;
begin
  inherited;

  if not CDSGrid.IsEmpty then
  begin
    IdCabecalho := IntToStr(IdRegistroSelecionado);
    ObjetoVO := TTributIcmsCustomCabController.ConsultaObjeto('ID=' + IdCabecalho);
 end;

  if Assigned(ObjetoVO) then
  begin
    { Cabeçalho }
    EditDescricao.Text := TTributIcmsCustomCabVO(ObjetoVO).Descricao;
    ComboboxOrigemMercadoria.ItemIndex := AnsiIndexStr(TTributIcmsCustomCabVO(ObjetoVO).OrigemMercadoria, ['0', '1', '2']);

    { Detalhe }
    for I := 0 to TTributIcmsCustomCabVO(ObjetoVO).ListaTributIcmsCustomDetVO.Count - 1 do
    begin
      Current := TTributIcmsCustomCabVO(ObjetoVO).ListaTributIcmsCustomDetVO[I];

      CDSIcms.Append;

      CDSIcms.FieldByName('ID').AsInteger := Current.Id;
      CDSIcms.FieldByName('ID_TRIBUT_ICMS_CUSTOM_CAB').AsInteger := Current.IdTributIcmsCustomCab;
      CDSIcms.FieldByName('UF_DESTINO').AsString := Current.UfDestino;
      CDSIcms.FieldByName('CFOP').AsInteger := Current.Cfop;
      CDSIcms.FieldByName('CSOSN_B').AsString := Current.CsosnB;
      CDSIcms.FieldByName('CST_B').AsString := Current.CstB;
      CDSIcms.FieldByName('MODALIDADE_BC').AsString := Current.ModalidadeBc;
      CDSIcms.FieldByName('ALIQUOTA').AsFloat := Current.Aliquota;
      CDSIcms.FieldByName('VALOR_PAUTA').AsFloat := Current.ValorPauta;
      CDSIcms.FieldByName('VALOR_PRECO_MAXIMO').AsFloat := Current.ValorPrecoMaximo;
      CDSIcms.FieldByName('MVA').AsFloat := Current.Mva;
      CDSIcms.FieldByName('PORCENTO_BC').AsFloat := Current.PorcentoBc;
      CDSIcms.FieldByName('MODALIDADE_BC_ST').AsString := Current.ModalidadeBcSt;
      CDSIcms.FieldByName('ALIQUOTA_INTERNA_ST').AsFloat := Current.AliquotaInternaSt;
      CDSIcms.FieldByName('ALIQUOTA_INTERESTADUAL_ST').AsFloat := Current.AliquotaInterestadualSt;
      CDSIcms.FieldByName('PORCENTO_BC_ST').AsFloat := Current.PorcentoBcSt;
      CDSIcms.FieldByName('ALIQUOTA_ICMS_ST').AsFloat := Current.AliquotaIcmsSt;
      CDSIcms.FieldByName('VALOR_PAUTA_ST').AsFloat := Current.ValorPautaSt;
      CDSIcms.FieldByName('VALOR_PRECO_MAXIMO_ST').AsFloat := Current.ValorPrecoMaximoSt;

      CDSIcms.Post;
    end;

    // Limpa as listas para comparar posteriormente se houve inclusões/alterações e subir apenas o necessário para o servidor
    TTributIcmsCustomCabVO(ObjetoVO).ListaTributIcmsCustomDetVO.Clear;

    // Serializa o objeto para consultar posteriormente se houve alterações
    FormatSettings.DecimalSeparator := '.';
    StringObjetoOld := ObjetoVO.ToJSONString;
    FormatSettings.DecimalSeparator := ',';
  end;
end;

procedure TFTributIcmsCustomizado.GridIcmsKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  UfVO: TUfVO;
  CfopVO: TCfopVO;
  CsosnBVO: TCsosnBVO;
  CstIcmsBVO: TCstIcmsBVO;
begin
  (*

  /// EXERCICIO: Implemente a busca usando a janela FLookup

  if Key = VK_F1 then
  begin
    if CDSIcms.IsEmpty then
    begin
      CDSIcms.Append;
      CDSIcms.Post;
    end;

    { UF }
    if GridIcms.SelectedIndex = 0 then
    begin
      try
        FLookup.ShowModal;

        UfVO := TUfVO.Create;
        ConsultarVO(FLookup.IdSelecionado, TVO(UfVO));

        if UfVO.Id > 0 then
        begin
          CDSIcms.Edit;
          CDSIcms.FieldByName('UF_DESTINO').AsString := UfVO.Sigla;
          CDSIcms.Post;
        end;
      finally
        CDSTransiente.Close;
      end;
    end;

    { CFOP }
    if GridIcms.SelectedIndex = 1 then
    begin
      try
        FLookup.ShowModal;

        CfopVO := TCfopVO.Create;
        ConsultarVO(FLookup.IdSelecionado, TVO(CfopVO));

        if CfopVO.Id > 0 then
        begin
          CDSIcms.Edit;
          CDSIcms.FieldByName('CFOP').AsInteger := CfopVO.Cfop;
          CDSIcms.Post;
        end;
      finally
        CDSTransiente.Close;
      end;
    end;

    { CSOSN }
    if GridIcms.SelectedIndex = 2 then
    begin
      try
        FLookup.ShowModal;

        CsosnBVO := TCsosnBVO.Create;
        ConsultarVO(FLookup.IdSelecionado, TVO(CsosnBVO));

        if CsosnBVO.Id > 0 then
        begin
          CDSIcms.Edit;
          CDSIcms.FieldByName('CSOSN_B').AsString := CsosnBVO.Codigo;
          CDSIcms.Post;
        end;
      finally
        CDSTransiente.Close;
      end;
    end;

    { CST }
    if GridIcms.SelectedIndex = 3 then
    begin
      try
        FLookup.ShowModal;

        CstIcmsBVO := TCstIcmsBVO.Create;
        ConsultarVO(FLookup.IdSelecionado, TVO(CstIcmsBVO));

        if CstIcmsBVO.Id > 0 then
        begin
          CDSIcms.Edit;
          CDSIcms.FieldByName('CST_B').AsString := CstIcmsBVO.Codigo;
          CDSIcms.Post;
        end;
      finally
        CDSTransiente.Close;
      end;
    end;

  end;

  *)

  //
  If Key = VK_RETURN then
    GridIcms.SelectedIndex := GridIcms.SelectedIndex + 1;
end;
{$ENDREGION}

{$REGION 'Actions'}
procedure TFTributIcmsCustomizado.ActionUfExecute(Sender: TObject);
var
  Filtro: String;
  RetornoConsulta: TZQuery;
begin
  if Application.MessageBox('Deseja Importar as UFs? [os dados atuais serão excluídos]', 'Pergunta do Sistema', MB_YesNo + MB_IconQuestion) = IdYes then
  begin
    CDSIcms.DisableControls;
    CDSIcms.Close;
    CDSIcms.Open;

    Filtro := 'ID > 0';
    RetornoConsulta := TUfController.Consulta(Filtro, IntToStr(Pagina));
    RetornoConsulta.Active := True;
    RetornoConsulta.First;

    while not RetornoConsulta.eof do
    begin
      CDSIcms.Append;
      CDSIcms.FieldByName('UF_DESTINO').AsString := RetornoConsulta.FieldByName('SIGLA').AsString;
      CDSIcms.Post;
      RetornoConsulta.Next;
    end;
    CDSIcms.First;
    CDSIcms.EnableControls;
  end;
end;

procedure TFTributIcmsCustomizado.ActionExcluirItemExecute(Sender: TObject);
begin
  if not CDSIcms.IsEmpty then
  begin
    if Application.MessageBox('Tem certeza que deseja excluir o registro selecionado?', 'Pergunta do Sistema', MB_YesNo + MB_IconQuestion) = IdYes then
    begin
      if StatusTela = stInserindo then
        CDSIcms.Delete
      else if StatusTela = stEditando then
      begin
        /// EXERCICIO: exclua o registro no banco de dados também
        CDSIcms.Delete;
      end;
    end;
  end
  else
    Application.MessageBox('Não existem dados para serem excluídos.', 'Mensagem do Sistema', MB_OK + MB_ICONINFORMATION);
end;

{$ENDREGION}

end.
