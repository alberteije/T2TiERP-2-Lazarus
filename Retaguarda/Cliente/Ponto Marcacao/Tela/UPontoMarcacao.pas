{ *******************************************************************************
Title: T2Ti ERP
Description: Tela de Marcação de Ponto - Registros de Entradas e Saídas.

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

@author Albert Eije
@version 2.0
******************************************************************************* }
unit UPontoMarcacao;

{$MODE Delphi}

interface

uses
  BrookHTTPClient, BrookFCLHTTPClientBroker, BrookHTTPUtils, BrookUtils, FPJson, ZDataset,
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UTelaCadastro, Menus, StdCtrls, ExtCtrls, Buttons, Grids, DBGrids,
  ComCtrls, LabeledCtrls, rxdbgrid, rxtoolbar, rxclock, DBCtrls, StrUtils,
  Math, Constantes, CheckLst, ActnList, ToolWin, ACBrEnterTab, ShellApi, db, BufDataset, Biblioteca,
  ULookup, VO, PontoMarcacaoVO, PontoMarcacaoController, SessaoUsuario;

type

  { TFPontoMarcacao }

  TFPontoMarcacao = class(TForm)
    ACBrEnterTab1: TACBrEnterTab;
    Label1: TLabel;
    Label2: TLabel;
    Image1: TImage;
    EditLogin: TEdit;
    EditSenha: TEdit;
    JvClock: TRxClock;
    ActionManagerLocal: TActionList;
    ActionCancelar: TAction;
    ActionConfirmar: TAction;
    ActionToolBarGrid: TToolPanel;
    Label3: TLabel;
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure ActionCancelarExecute(Sender: TObject);
    procedure ActionConfirmarExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    function DoLogin: Boolean;
  public
    { Public declarations }
  end;

var
  FPontoMarcacao: TFPontoMarcacao;
  Sessao: TSessaoUsuario;
  CDSPontoMarcacao: TZQuery;

implementation

{$R *.lfm}
{ TFPontoMarcacao }

{$Region 'Infra'}
procedure TFPontoMarcacao.FormCreate(Sender: TObject);
begin
  Sessao := TSessaoUsuario.Instance;
  Label3.Caption := DateToStr(Now);
end;

procedure TFPontoMarcacao.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = VK_F11 then
    ActionCancelar.Execute;
  if Key = VK_F12 then
    ActionConfirmar.Execute;
  if Key = VK_ESCAPE then
    ActionCancelar.Execute;
end;
{$EndRegion}

{$Region 'Actions'}
procedure TFPontoMarcacao.ActionCancelarExecute(Sender: TObject);
begin
  Close;
end;

procedure TFPontoMarcacao.ActionConfirmarExecute(Sender: TObject);
var
  PontoMarcacao: TPontoMarcacaoVO;
  UltimaMarcacao, MarcacaoAtual, Filtro: String;
begin
  if DoLogin then
  begin
    PontoMarcacao := TPontoMarcacaoVO.Create;
    PontoMarcacao.IdColaborador := Sessao.Usuario.IdColaborador;
    PontoMarcacao.DataMarcacao := Date;
    PontoMarcacao.HoraMarcacao := TimeToStr(Time);
    PontoMarcacao.TipoRegistro := 'O';

    Filtro := 'ID_COLABORADOR = ' + IntToStr(Sessao.Usuario.IdColaborador) + ' and DATA_MARCACAO = ' + QuotedStr(DataParaTexto(Now));
    CDSPontoMarcacao := TPontoMarcacaoController.Consulta(Filtro, '0');
    CDSPontoMarcacao.Open;
    CDSPontoMarcacao.Last;

    if CDSPontoMarcacao.RecordCount mod 2 = 0 then
    begin
      PontoMarcacao.TipoMarcacao := 'E';
      CDSPontoMarcacao.Filtered := False;
      CDSPontoMarcacao.Filter := 'TIPO_MARCACAO = ' + QuotedStr('E');
      CDSPontoMarcacao.Filtered := True;
      PontoMarcacao.ParEntradaSaida := 'E' + IntToStr(CDSPontoMarcacao.RecordCount + 1);
    end
    else
    begin
      PontoMarcacao.TipoMarcacao := 'S';
      CDSPontoMarcacao.Filtered := False;
      CDSPontoMarcacao.Filter := 'TIPO_MARCACAO = ' + QuotedStr('S');
      CDSPontoMarcacao.Filtered := True;
      PontoMarcacao.ParEntradaSaida := 'S' + IntToStr(CDSPontoMarcacao.RecordCount + 1);
    end;

    CDSPontoMarcacao.Filtered := False;
    CDSPontoMarcacao.Last;

    UltimaMarcacao := ifthen(PontoMarcacao.TipoMarcacao = 'S', 'Entrada', 'Saída');
    MarcacaoAtual := ifthen(PontoMarcacao.TipoMarcacao = 'E', 'Entrada', 'Saída');

    if CDSPontoMarcacao.RecordCount = 0 then
    begin
      TPontoMarcacaoController.Insere(PontoMarcacao);
      Application.MessageBox(PChar(MarcacaoAtual + ' registrada com sucesso.'), 'Aviso do Sistema', MB_OK + MB_ICONINFORMATION);
      Close;
    end
    else
    begin
      if Hora_Seg(TimeToStr(Time)) - Hora_Seg(CDSPontoMarcacao.FieldByName('HORA_MARCACAO').AsString) <= 3600 then
      begin
        if Application.MessageBox(PChar('Você registrou uma ' + UltimaMarcacao + ' na última hora, às ' + CDSPontoMarcacao.FieldByName('HORA_MARCACAO').AsString + '. Deseja registrar uma ' + MarcacaoAtual + '?'), 'Pergunta do Sistema', MB_YesNo + MB_IconQuestion) = IdYes then
        begin
          TPontoMarcacaoController.Insere(PontoMarcacao);
          Application.MessageBox(PChar(MarcacaoAtual + ' registrada com sucesso.'), 'Aviso do Sistema', MB_OK + MB_ICONINFORMATION);
          Close;
        end
        else
        begin
          Application.MessageBox('Transação não realizada.', 'Aviso do Sistema', MB_OK + MB_ICONINFORMATION);
          Close;
        end;
      end
      else
      begin
        TPontoMarcacaoController.Insere(PontoMarcacao);
        Application.MessageBox(PChar(MarcacaoAtual + ' registrada com sucesso.'), 'Aviso do Sistema', MB_OK + MB_ICONINFORMATION);
        Close;
      end;
    end;
  end;
end;

function TFPontoMarcacao.DoLogin: Boolean;
begin
  try
    Result := Sessao.AutenticaUsuario(EditLogin.Text, EditSenha.Text);
  except
    Result := False;
  end;
end;
{$EndRegion}

end.

