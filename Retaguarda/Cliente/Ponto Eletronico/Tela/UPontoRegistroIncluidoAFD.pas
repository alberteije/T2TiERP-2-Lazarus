unit UPontoRegistroIncluidoAFD;

interface

uses
  BrookHTTPClient, BrookFCLHTTPClientBroker, BrookHTTPUtils, BrookUtils, FPJson, ZDataset,
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UTelaCadastro, Menus, StdCtrls, ExtCtrls, Buttons, Grids, DBGrids,
  ComCtrls, LabeledCtrls, rxdbgrid, rxtoolbar, DBCtrls, StrUtils,
  Math, Constantes, CheckLst, ActnList, ToolWin, ShellApi, db, BufDataset, Biblioteca,
  ULookup, VO;

  type

  { TFPontoRegistroIncluidoAFD }

  TFPontoRegistroIncluidoAFD = class(TForm)
    PanelRegistroIncluido: TPanel;
    EditDataMarcacao: TLabeledDateEdit;
    EditHoraMarcacao: TLabeledMaskEdit;
    EditJustificativa: TLabeledEdit;
    ActionManagerLocal: TActionList;
    ActionCancelar: TAction;
    ActionSalvar: TAction;
    ActionToolBar1: TToolPanel;
    ComboBoxTipoMarcacao: TLabeledComboBox;
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure ActionCancelarExecute(Sender: TObject);
    procedure ActionSalvarExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure BotaoConsultarClick(Sender: TObject);
    procedure BotaoSalvarClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FPontoRegistroIncluidoAFD: TFPontoRegistroIncluidoAFD;
  Confirmou: Boolean;

implementation

uses UMenu, UPontoTratamentoArquivoAFD;

{$R *.lfm}

procedure TFPontoRegistroIncluidoAFD.FormCreate(Sender: TObject);
begin
  EditDataMarcacao.Clear;
  EditHoraMarcacao.Clear;
  EditJustificativa.Clear;
  Confirmou := False;
end;

procedure TFPontoRegistroIncluidoAFD.BotaoConsultarClick(Sender: TObject);
begin

end;

procedure TFPontoRegistroIncluidoAFD.BotaoSalvarClick(Sender: TObject);
begin

end;

procedure TFPontoRegistroIncluidoAFD.ActionCancelarExecute(Sender: TObject);
begin
  Close;
end;

procedure TFPontoRegistroIncluidoAFD.ActionSalvarExecute(Sender: TObject);
begin
  ((FMenu.PageControl.ActivePage.Components[0] as TForm) as TFPontoTratamentoArquivoAFD).CDSRegistro3.Edit;
  ((FMenu.PageControl.ActivePage.Components[0] as TForm) as TFPontoTratamentoArquivoAFD).CDSRegistro3.FieldByName('DataMarcacao').AsString := EditDataMarcacao.Text;
  ((FMenu.PageControl.ActivePage.Components[0] as TForm) as TFPontoTratamentoArquivoAFD).CDSRegistro3.FieldByName('HoraMarcacao').AsString := EditHoraMarcacao.Text;
  ((FMenu.PageControl.ActivePage.Components[0] as TForm) as TFPontoTratamentoArquivoAFD).CDSRegistro3.FieldByName('JUSTIFICATIVA').AsString := EditJustificativa.Text;
  ((FMenu.PageControl.ActivePage.Components[0] as TForm) as TFPontoTratamentoArquivoAFD).CDSRegistro3.FieldByName('TIPO_MARCACAO').AsString := Copy(ComboBoxTipoMarcacao.Text, 4, Length(ComboBoxTipoMarcacao.Text) - 3);
  ((FMenu.PageControl.ActivePage.Components[0] as TForm) as TFPontoTratamentoArquivoAFD).CDSRegistro3.FieldByName('PAR_ENTRADA_SAIDA').AsString := Copy(ComboBoxTipoMarcacao.Text, 4, 1) + Copy(ComboBoxTipoMarcacao.Text, 1, 1);
  ((FMenu.PageControl.ActivePage.Components[0] as TForm) as TFPontoTratamentoArquivoAFD).CDSRegistro3.Post;
  ((FMenu.PageControl.ActivePage.Components[0] as TForm) as TFPontoTratamentoArquivoAFD).ActionValidarDados.Execute;
  Confirmou := True;
  Close;
end;

procedure TFPontoRegistroIncluidoAFD.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = VK_ESCAPE then
    Close;
end;

procedure TFPontoRegistroIncluidoAFD.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  if not Confirmou then
    ((FMenu.PageControl.ActivePage.Components[0] as TForm) as TFPontoTratamentoArquivoAFD).CDSRegistro3.Delete;
  Release;
end;

end.

