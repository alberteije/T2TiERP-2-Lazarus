unit UCTeDetalheAnexo;

interface

uses
  BrookHTTPClient, BrookFCLHTTPClientBroker, BrookHTTPUtils, BrookUtils, FPJson, ZDataset,
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UTelaCadastro, Menus, StdCtrls, ExtCtrls, Buttons, Grids, DBGrids,
  ComCtrls, LabeledCtrls, rxdbgrid, rxtoolbar, DBCtrls, StrUtils,
  Math, Constantes, CheckLst, ActnList, ToolWin, ShellApi, db, BufDataset, Biblioteca,
  ULookup, VO;
{
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, LabeledCtrls, ExtCtrls, Mask, JvExMask, JvToolEdit,
  JvBaseEdits, ToolWin, ActnMan, ActnCtrls, Grids, DBGrids, JvExDBGrids,
  JvDBGrid, JvDBUltimGrid, ComCtrls, DBCtrls, LabeledDBCtrls;

}type
  TFCTeDetalheAnexo = class(TForm)
    PageControlDadosTributacao: TPageControl;
    tsTransporte: TTabSheet;
    PanelDetalheArmamento: TPanel;
    GridDetalheArmamento: TRxDbGrid;
    tsCarga: TTabSheet;
    PanelDeclaracaoImportacao: TPanel;
    GridDeclaracaoImportacao: TRxDbGrid;
    PageLacres: TPageControl;
    tsLacre: TTabSheet;
    Panel1: TPanel;
    GridDeclaracaoImportacaoDetalhe: TRxDbGrid;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FCTeDetalheAnexo: TFCTeDetalheAnexo;

implementation

uses UDataModule, UDataModuleCTe;
  BrookHTTPClient, BrookFCLHTTPClientBroker, BrookHTTPUtils, BrookUtils, FPJson, ZDataset,
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UTelaCadastro, Menus, StdCtrls, ExtCtrls, Buttons, Grids, DBGrids,
  ComCtrls, LabeledCtrls, rxdbgrid, rxtoolbar, DBCtrls, StrUtils,
  Math, Constantes, CheckLst, ActnList, ToolWin, ShellApi, db, BufDataset, Biblioteca,
  ULookup, VO;
{

{$R *.dfm}

end.

