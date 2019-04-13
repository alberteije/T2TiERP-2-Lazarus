unit UMenu;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, SpkToolbar, spkt_Tab, spkt_Pane, spkt_Buttons,
  Forms, Controls, Graphics, Dialogs, ComCtrls, Menus,
  //
  UFolhaParametros, UGuiasAcumuladas, UFolhaPlanoSaude, UFolhaEvento, UFolhaTipoAfastamento,
  UFolhaAfastamento, UFolhaFeriasColetivas, UFeriasPeriodoAquisitivo,
  UFolhaFechamento, UFolhaLancamento, UFolhaHistoricoSalarial, UFolhaValeTransporte,
  UFolhaRescisao, UFolhaInformativosGuias, UFolhaInssServico, UFolhaInss;
  {
  UUFolhaPpp,
  }


type

  { TFMenu }

  TFMenu = class(TForm)
    Image16: TImageList;
    Image32: TImageList;
    MenuItem1: TMenuItem;
    MenuItem10: TMenuItem;
    MenuItem11: TMenuItem;
    MenuItem12: TMenuItem;
    MenuItem13: TMenuItem;
    MenuItem14: TMenuItem;
    MenuItem15: TMenuItem;
    MenuItem16: TMenuItem;
    MenuItem17: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    MenuItem6: TMenuItem;
    MenuItem7: TMenuItem;
    MenuItem8: TMenuItem;
    MenuItem9: TMenuItem;
    mnuDesacoplarFormulario: TMenuItem;
    mnuFechar: TMenuItem;
    mnuFecharTodasExcetoEssa: TMenuItem;
    N2: TMenuItem;
    PageControl: TPageControl;
    PopupMenuTabelasCST: TPopupMenu;
    PopupMenuTabelasSefip: TPopupMenu;
    PopupMenuTabelasEfd: TPopupMenu;
    PopupMenuPrincipal: TPopupMenu;
    SpkLargeButton1: TSpkLargeButton;
    SpkLargeButton10: TSpkLargeButton;
    SpkLargeButton17: TSpkLargeButton;
    SpkLargeButton18: TSpkLargeButton;
    SpkLargeButton2: TSpkLargeButton;
    SpkLargeButton3: TSpkLargeButton;
    SpkLargeButton4: TSpkLargeButton;
    SpkLargeButton5: TSpkLargeButton;
    SpkLargeButton6: TSpkLargeButton;
    SpkLargeButton7: TSpkLargeButton;
    SpkLargeButton8: TSpkLargeButton;
    SpkLargeButton9: TSpkLargeButton;
    SpkPane1: TSpkPane;
    SpkPane2: TSpkPane;
    SpkPane3: TSpkPane;
    SpkPane4: TSpkPane;
    SpkPane5: TSpkPane;
    SpkSmallButton1: TSpkSmallButton;
    SpkSmallButton2: TSpkSmallButton;
    SpkSmallButton3: TSpkSmallButton;
    SpkSmallButton4: TSpkSmallButton;
    SpkSmallButton5: TSpkSmallButton;
    SpkSmallButton6: TSpkSmallButton;
    SpkTab1: TSpkTab;
    SpkToolbar1: TSpkToolbar;
    procedure FormCreate(Sender: TObject);
    procedure mnuDesacoplarFormularioClick(Sender: TObject);
    procedure mnuFecharClick(Sender: TObject);
    procedure mnuFecharTodasExcetoEssaClick(Sender: TObject);
    procedure PageControlChange(Sender: TObject);
    procedure PageControlDrawTab(Control: TCustomTabControl; TabIndex: Integer; const Rect: TRect; pActive: Boolean);
    procedure PageControlMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure SpkLargeButton10Click(Sender: TObject);
    procedure SpkLargeButton17Click(Sender: TObject);
    procedure SpkLargeButton18Click(Sender: TObject);
    procedure SpkLargeButton1Click(Sender: TObject);
    procedure SpkLargeButton2Click(Sender: TObject);
    procedure SpkLargeButton3Click(Sender: TObject);
    procedure SpkLargeButton4Click(Sender: TObject);
    procedure SpkLargeButton5Click(Sender: TObject);
    procedure SpkLargeButton6Click(Sender: TObject);

    function doLogin: Boolean;
    procedure SpkLargeButton7Click(Sender: TObject);
    procedure SpkLargeButton8Click(Sender: TObject);
    procedure SpkLargeButton9Click(Sender: TObject);
    procedure SpkSmallButton1Click(Sender: TObject);
    procedure SpkSmallButton2Click(Sender: TObject);
    procedure SpkSmallButton3Click(Sender: TObject);
    procedure SpkSmallButton4Click(Sender: TObject);
    procedure SpkSmallButton5Click(Sender: TObject);
    procedure SpkSmallButton6Click(Sender: TObject);

  private
    { private declarations }
    FCaptionAplicacao: string;

    procedure SetCaptionAplicacao(const Value: string);
    function PodeAbrirFormulario(ClasseForm: TFormClass; var TabSheet: TTabSheet): Boolean;
    function TotalFormsAbertos(ClasseForm: TFormClass): Integer;
    procedure AjustarCaptionAbas(ClasseForm: TFormClass);
  public
    { public declarations }
    procedure NovaAba(ClasseForm: TFormClass; IndiceImagem: Integer);
    procedure FecharAba(Aba: TTabSheet); overload;
    procedure FecharAba(Aba: TTabSheet; TodasExcetoEssa: Boolean); overload;
    procedure AcoplarFormulario(Aba: TTabSheet);
    procedure DesacoplarFormulario(Aba: TTabSheet);
    property CaptionAplicacao: string read FCaptionAplicacao write SetCaptionAplicacao;
  end;

var
  FMenu: TFMenu;

implementation

uses ULogin, Biblioteca;

{$R *.lfm}

{$Region: Infra}
function TFMenu.doLogin: Boolean;
var
  FormLogin: TFLogin;
begin
    FormLogin := TFLogin.Create(Self);
    try
      FormLogin.ShowModal;
      Result := FormLogin.Logado;
    finally
      FormLogin.Free;
    end;
end;

procedure TFMenu.FormCreate(Sender: TObject);
begin
  if not doLogin then
    Application.Terminate
  else
    CaptionAplicacao := 'T2Ti ERP';
end;

procedure TFMenu.SetCaptionAplicacao(const Value: string);
begin
  if Value <> FCaptionAplicacao then
  begin
    Caption := StringReplace(Caption, FCaptionAplicacao, Value, []);
    FCaptionAplicacao := Value;
    Application.Title := Caption;
  end;
end;

function TFMenu.PodeAbrirFormulario(ClasseForm: TFormClass; var TabSheet: TTabSheet): Boolean;
var
  I: Integer;
begin
  Result := True;
  for I := 0 to PageControl.PageCount - 1 do
    if PageControl.Pages[I].Components[0].ClassType = ClasseForm then
    begin
      TabSheet := PageControl.Pages[I];
      Result := (TabSheet.Components[0] as TForm).Tag = 0;
      Break;
    end;
end;

function TFMenu.TotalFormsAbertos(ClasseForm: TFormClass): Integer;
var
  I: Integer;
begin
  Result := 0;
  for I := 0 to PageControl.PageCount - 1 do
    if PageControl.Pages[I].Components[0].ClassType = ClasseForm then
      Inc(Result);
end;

procedure TFMenu.AjustarCaptionAbas(ClasseForm: TFormClass);
var
  I, Indice, TotalForms: Integer;
begin
  TotalForms := TotalFormsAbertos(ClasseForm);

  if TotalForms > 1 then
  begin
    Indice := 1;
    for I := 0 to PageControl.PageCount - 1 do
      with PageControl do
        if Pages[I].Components[0].ClassType = ClasseForm then
        begin
          Pages[I].Caption := (Pages[I].Components[0] as TForm).Caption + ' (' +
            IntToStr(Indice) + ')';
          Inc(Indice);
        end;
  end;
end;

procedure TFMenu.NovaAba(ClasseForm: TFormClass; IndiceImagem: Integer);
var
  TabSheet: TTabSheet;
  Form: TForm;
begin
  if not PodeAbrirFormulario(ClasseForm, TabSheet) then
  begin
    PageControl.ActivePage := TabSheet;
    Exit;
  end;

  TabSheet := TTabSheet.Create(Self);
  TabSheet.PageControl := PageControl;

  Form := ClasseForm.Create(TabSheet);
  with Form do
  begin
    Align       := alClient;
    BorderStyle := bsNone;
    Parent      := TabSheet;
  end;

  with TabSheet do
  begin
    Caption     := Form.Caption;
    ImageIndex  :=  IndiceImagem;
  end;

  AjustarCaptionAbas(ClasseForm);

  Form.Show;
  PageControl.ActivePage := TabSheet;

  PageControlChange(PageControl);
end;

procedure TFMenu.FecharAba(Aba: TTabSheet);
var
  Form: TForm;
  AbaEsquerda: TTabSheet;
begin
  AbaEsquerda := nil;
  Form := Aba.Components[0] as TForm;

  if Form.CloseQuery then
  begin
    if Aba.TabIndex > 0 then
      AbaEsquerda := PageControl.Pages[Aba.TabIndex - 1];

    Form.Close;
    Aba.Free;

    PageControl.ActivePage := AbaEsquerda;
  end;
end;

procedure TFMenu.FecharAba(Aba: TTabSheet; TodasExcetoEssa: Boolean);
var
  I: Integer;
begin
  for I := PageControl.PageCount - 1 downto 0 do
    if PageControl.Pages[I] <> Aba then
      FecharAba(PageControl.Pages[I]);
end;

procedure TFMenu.AcoplarFormulario(Aba: TTabSheet);
begin
  with Aba.Components[0] as TForm do
  begin
    // Parent deve vir antes de Align para evitar o flickering da tela
    Parent      := Aba;
    Align       := alClient;
    BorderStyle := bsNone;
  end;

  Aba.TabVisible := True;
  PageControl.ActivePage := Aba;
end;

procedure TFMenu.DesacoplarFormulario(Aba: TTabSheet);
begin
  with Aba.Components[0] as TForm do
  begin
    Align       := alNone;
    BorderStyle := bsSizeable;
    Parent      := nil;
  end;

  Aba.TabVisible := False;

end;
{$EndRegion}

{$Region: PageControl}
procedure TFMenu.PageControlChange(Sender: TObject);
begin
  Caption := CaptionAplicacao + ' - ' + PageControl.ActivePage.Caption;
  Application.Title := Caption;

  with (PageControl.ActivePage.Components[0] as TForm) do
    if not Assigned(Parent) then Show;
end;

procedure TFMenu.PageControlDrawTab(Control: TCustomTabControl; TabIndex: Integer; const Rect: TRect; pActive: Boolean);
var
  CaptionAba, CaptionForm, CaptionContador: string;
  I: Integer;
begin
  with PageControl do
  begin
    // Separa o caption da aba e o contador de forms
    CaptionAba := Pages[TabIndex].Caption;

    CaptionForm := Trim(Copy(CaptionAba, 1, Pos('(', CaptionAba))) + ' ';

    CaptionContador := Copy(CaptionAba, Pos('(', CaptionAba), Length(CaptionAba));
    CaptionContador := Copy(CaptionContador, 1, Pos(')', CaptionContador));

    Canvas.FillRect(Rect);

    Canvas.TextOut(Rect.Left + 3, Rect.Top + 3, CaptionForm);
    I := Canvas.TextWidth(CaptionForm);

    Canvas.Font.Style := [fsBold];
    Canvas.TextOut(Rect.Left + 3 + I, Rect.Top + 3, CaptionContador);
  end;
end;

procedure TFMenu.PageControlMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbRight then
    PageControl.TabIndex := PageControl.IndexOfTabAt(X, Y);
end;
{$EndRegion}

{$Region: PopupMenu}
procedure TFMenu.mnuDesacoplarFormularioClick(Sender: TObject);
begin
  DesacoplarFormulario(PageControl.ActivePage);
end;

procedure TFMenu.mnuFecharClick(Sender: TObject);
begin
  FecharAba(PageControl.ActivePage);
end;

procedure TFMenu.mnuFecharTodasExcetoEssaClick(Sender: TObject);
begin
  FecharAba(PageControl.ActivePage, True);
end;
{$EndRegion}

{$Region: Actions}
procedure TFMenu.SpkLargeButton1Click(Sender: TObject);
begin
  NovaAba(TFGuiasAcumuladas, 59);
end;

procedure TFMenu.SpkLargeButton2Click(Sender: TObject);
begin
  NovaAba(TFFolhaPlanoSaude, 65);
end;

procedure TFMenu.SpkLargeButton3Click(Sender: TObject);
begin
  NovaAba(TFFolhaEvento, 55);
end;

procedure TFMenu.SpkLargeButton4Click(Sender: TObject);
begin
  Close;
end;

procedure TFMenu.SpkLargeButton5Click(Sender: TObject);
begin
  NovaAba(TFFolhaParametros, 64);
end;

procedure TFMenu.SpkLargeButton6Click(Sender: TObject);
begin
  NovaAba(TFFolhaTipoAfastamento, 26);
end;

procedure TFMenu.SpkLargeButton7Click(Sender: TObject);
begin
  NovaAba(TFFolhaAfastamento, 54);
end;

procedure TFMenu.SpkLargeButton8Click(Sender: TObject);
begin
  NovaAba(TFFolhaFeriasColetivas, 57);
end;

procedure TFMenu.SpkLargeButton9Click(Sender: TObject);
begin
  NovaAba(TFFeriasPeriodoAquisitivo, 58);
end;

procedure TFMenu.SpkSmallButton1Click(Sender: TObject);
begin
  NovaAba(TFFolhaLancamento, 63);
end;

procedure TFMenu.SpkSmallButton2Click(Sender: TObject);
begin
  NovaAba(TFFolhaHistoricoSalarial, 60);
end;

procedure TFMenu.SpkSmallButton3Click(Sender: TObject);
begin
  NovaAba(TFFolhaValeTransporte, 69);
end;

procedure TFMenu.SpkSmallButton4Click(Sender: TObject);
begin
  /// EXERCICIO: Adicione a janela e faça as devidas adaptações para que ela funcione devidamente
end;

procedure TFMenu.SpkSmallButton5Click(Sender: TObject);
begin
  NovaAba(TFFolhaRescisao, 67);
end;

procedure TFMenu.SpkSmallButton6Click(Sender: TObject);
begin
  Application.CreateForm(TFFolhaInformativosGuias, FFolhaInformativosGuias);
  FFolhaInformativosGuias.ShowModal;
end;

procedure TFMenu.SpkLargeButton10Click(Sender: TObject);
begin
  NovaAba(TFFolhaFechamento, 56);
end;

procedure TFMenu.SpkLargeButton17Click(Sender: TObject);
begin
  NovaAba(TFFolhaInssServico, 62);
end;

procedure TFMenu.SpkLargeButton18Click(Sender: TObject);
begin
  NovaAba(TFFolhaInss, 12);
end;

{$EndRegion}

end.

