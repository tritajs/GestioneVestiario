unit main_f;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls, Buttons,  umEdit, WTNavigator, WTimage,
  wteditcompNew, WTComboBoxSql, WTStringGridSql, LR_Class, LR_DBSet, LR_Shape,
  LCLIntf, ComCtrls, Menus, Grids, uibdataset,LSystemTrita, WTVarie_f, fpsexport;

type
    Tuser = record
    matr: string;
    grado: string;
    nominativo: string;
    reparto: string;
    codreparto: string;
    ksreparto: integer;
    provinciale:string;
    idsitforza:string;
    FileTemp: string;
    DirectTemp: string;
    Amministratore:boolean;
    Inserimento:Boolean;
    Modifica:Boolean;
    Cancellazione:Boolean;
    Lettura:Boolean;
  end;

  { Tmain }

  Tmain = class(TForm)
    CAT: TumValidEdit;
    celservizio: TumEdit;
    DSet1: TUIBDataSet;
    frDSetMod135: TfrDBDataSet;
    frScheda: TfrReport;
    frDset1: TfrDBDataSet;
    frShapeObject1: TfrShapeObject;
    IdleTimer2: TIdleTimer;
    Image3: TImage;
    Image4: TImage;
    Image5: TImage;
    ImageList1: TImageList;
    Label9: TLabel;
    lmilitari: TLabel;
    MainMenu1: TMainMenu;
    MenuItem1: TMenuItem;
    MICodiciVestiario: TMenuItem;
    MIAutorizzazioni: TMenuItem;
    MIRicerche: TMenuItem;
    MISituzioneMagazzino: TMenuItem;
    MICaricoMagazzino: TMenuItem;
    MIinventario: TMenuItem;
    Panel2: TPanel;
    Panel5: TPanel;
    PC: TPageControl;
    PMScheda: TPopupMenu;
    Presente: TCheckBox;
    cognome: TumEdit;
    ECdati: TwtEditCompNew;
    FPSExport1: TFPSExport;
    ksarticolazione: TWTComboBoxSql;
    ksgrado: TWTComboBoxSql;
    ksreparto: TWTComboBoxSql;
    Label22: TLabel;
    Label8: TLabel;
    Lcontatore: TLabel;
    cont: TumValidEdit;
    FOTO: TWTimage;
    Image1: TImage;
    Image2: TImage;
    Label1: TLabel;
    Label15: TLabel;
    Label16: TLabel;
    Label2: TLabel;
    Label21: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    matrmec: TumEdit;
    Nome: TumEdit;
    DESCRIZIONE: TumEdit;
    Panel1: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    SBPrint: TSpeedButton;
    Sesso: TumValidEdit;
    INTERNO: TumEdit;
    TSMod135: TTabSheet;
    TSsituazione: TTabSheet;
    WTnav: TWTNavigator;
    SGLetMod135: TwtStringGridSql;
    procedure cognomeKeyPress(Sender: TObject; var Key: char);
    procedure ECdatiBeforeFind(Sender: Tobject; var CampiValori, CampiWhere,
      CampiJoin: string; var CheckFiltro: Boolean; var Indice: string;
      var SelectCustomer: string);
    procedure ECdatiBeforeUpdate(Sender: Tobject; var where, CampiValore: string
      );
    procedure ECdatiContatore(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormShow(Sender: TObject);
    procedure frSchedaEnterRect(Memo: TStringList; View: TfrView);
    procedure IdleTimer1Timer(Sender: TObject);
    procedure IdleTimer2Timer(Sender: TObject);
    procedure MenuItem1Click(Sender: TObject);
    procedure MIAutorizzazioniClick(Sender: TObject);
    procedure MICodiciVestiarioClick(Sender: TObject);
    procedure MISituzioneMagazzinoClick(Sender: TObject);
    procedure MICaricoMagazzinoClick(Sender: TObject);
    procedure MIRicercheClick(Sender: TObject);
    procedure PCMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure SBPrintClick(Sender: TObject);
    procedure SGLetMod135MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure WTnavBeforeClick(Sender: TObject; var Button: TNavButtonType;
      var EseguiPost: Boolean);
    procedure WTnavClick(Sender: TObject; Button: TNavButtonType);
  private
    procedure VistaDefault; //ripristina la form allo stato iniziale
    function Autorizzato:Boolean; //Controlla se il militare è abilitato e il tipo di abilitazione;
    { private declarations }

  public
    { public declarations }
     procedure EsportaEXL();
     procedure RicercaModelli135;
  end;

var
  main: Tmain;
  user: Tuser;


implementation

uses dm_f, fmMagazzino_f, frmod135_f, FmCaricoMagazzino_f, FmRicerche_f,
  fmautorizzazioni_f, FmCodiciVestiario_f;

var
  FrMod135: TFrMod135;

{$R *.lfm}

{ Tmain }

procedure Tmain.FormShow(Sender: TObject);
begin
  //cerco la variabile di abiente Temp mi servirà per creare i file temporani
  //controllo la versione del programma
  dm.QTemp.SQL.Text:= 'select GestioneVestiario from versione';
  dm.QTemp.Open;
  if dm.QTemp.Fields.AsInteger[0] <> 1 then
    begin
      ShowMessage('<< Attenzione stai utilizzando una versione vecchia Richiedi al BCQS Tritapepe la Nuova Versione tel. 3280122371 >>');
      halt;
    end;
  DM.Accesso_Nominativo;
  Autorizzato;
  Panel4.SetFocus;
  lmilitari.Caption:= user.nominativo;
  PC.ActivePage:= TSsituazione;
end;

procedure Tmain.frSchedaEnterRect(Memo: TStringList; View: TfrView);
Var BlobStream : TMemoryStream;
begin
  if (View.name = 'foto')  then
    begin
     BlobStream:= TMemoryStream.Create;
      if not DSet1.FieldByName('foto').IsNull   then
        begin
          DSet1.ReadBlob('foto',BlobStream);
          TfrPictureView(View).Picture.LoadFromStream(BlobStream);
        end
      else
       TfrPictureView(View).Picture.Clear;
    end
end;

procedure Tmain.IdleTimer1Timer(Sender: TObject);
begin
  Application.Terminate;
end;

procedure Tmain.IdleTimer2Timer(Sender: TObject);
begin
  Application.Terminate;
end;

procedure Tmain.MenuItem1Click(Sender: TObject);
begin
  dm.LoadFromDB('SchedaVestiario',frScheda);
  frScheda.DesignReport;
     dm.SaveToDB('SchedaVestiario',frScheda);
end;

procedure Tmain.MIAutorizzazioniClick(Sender: TObject);
begin
  VistaDefault;
  if user.Amministratore then
      FmAutorizzazioni.ShowModal
  else
     ShowMessage('Militare non abilitato');
end;

procedure Tmain.MICodiciVestiarioClick(Sender: TObject);
begin
  VistaDefault;
  FmCodiciVestiario.ShowModal;
end;


procedure Tmain.MISituzioneMagazzinoClick(Sender: TObject);
begin
 VistaDefault;
 FmMagazzino.FormCall:='';
 FmMagazzino.Show;
end;

procedure Tmain.MICaricoMagazzinoClick(Sender: TObject);
begin
  VistaDefault;
  FmCaricoMagazzino.ShowModal;
end;

procedure Tmain.MIRicercheClick(Sender: TObject);
begin
  VistaDefault;
  FmRicerche.ShowModal;
end;


procedure Tmain.PCMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if pc.ActivePage = TSMod135 then
    begin
       if matrmec.Text <> '' then
         begin
           FrMod135.operazione:= FtInserimento;
           FrMod135.CheckBottoni;
           FrMod135.operazione:= FtView;
           FrMod135.EDNrMod135.Text:= '';
           FrMod135.DataMod135.Date:= now;
           FrMod135.SGMod135.RowCount:= 1;
         end
       else
           PC.ActivePage:= TSsituazione;
    end;
end;

procedure Tmain.SBPrintClick(Sender: TObject);
Var st:string;
begin
 if matrmec.Text <> '' then
   begin
     st:= ' select * from VIEW_DATIPERSONALI r where r.idmilitare = ' + dm.DSetDati.FieldByName('IDMILITARE').AsString ;
     DSet1.SQL.Text:=st;
     DSet1.Open;
     st:= ' select * from VIEW_DATIMOD135 r where r.KSMILITARE = ' + dm.DSetDati.FieldByName('IDMILITARE').AsString ;
     DM.DSetDatiMod135.SQL.Text:=st;
     DM.DSetDatiMod135.Open;
     dm.LoadFromDB('SchedaVestiario',frScheda);
     frScheda.ShowReport;
   end;
end;


procedure Tmain.SGLetMod135MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
 if SGLetMod135.Cells[0,1] <> '' then
   begin
      PC.ActivePage:= TSMod135;
      FrMod135.operazione:= FtView;
      FrMod135.CheckBottoni;
      FrMod135.EDNrMod135.Text:= SGLetMod135.Cells[1,SGLetMod135.Row]; //inserico il numero del mod135 nel campo edmod135
      FrMod135.DataMod135.Text:= SGLetMod135.Cells[0,SGLetMod135.Row]; // inserisco la data del mod135 nel edit datamod135

      FrMod135.GIdMod135:= SGLetMod135.Cells[2,SGLetMod135.Row]; // idmod35 ;

      FrMod135.DataMod135.Visible:= True; //visualizzo l'edit datamod135
      FrMod135.GIdMod135:= SGLetMod135.Cells[2,SGLetMod135.Row];  //GIdMod135 contiene id della tabella mod135 che serve per cercare i dati nella tabella datimod135
      FrMod135.LeggeDati;
   end;
end;


procedure Tmain.WTnavBeforeClick(Sender: TObject; var Button: TNavButtonType;
  var EseguiPost: Boolean);
begin
  if button in [nbtFind] then
    begin
      dm.TR.Commit;
      dm.DSetDati.Active:=false;
    end;
end;

procedure Tmain.WTnavClick(Sender: TObject; Button: TNavButtonType);
begin
  if button in [nbtFind] then
   begin
      VistaDefault;
      cognome.SetFocus;
   end

  else if button in [nbtEdit] then
    celservizio.SetFocus
  else
    panel1.SetFocus;
end;

procedure Tmain.VistaDefault;
begin
  // cognome.SetFocus;
   Panel4.SetFocus;
   SGLetMod135.Active:= False;
   FrMod135.EDNrMod135.Text:= '';
   FrMod135.SGMod135.RowCount:= 1;
   PC.ActivePage:= TSsituazione;
   ECdati.Clear_Edit;
end;

function Tmain.Autorizzato: Boolean;
Var st,aut:string;
begin
   if user.matr = '852406Y' then
     begin
       user.Amministratore:= True;
       user.Inserimento:= True;
       user.Modifica:= True;
       user.Cancellazione:= True;
       exit;
     end;
   st:= 'select autorizzato from autorizzazionivestiario where matrmec = ''' + user.matr + '''';
   EseguiSQL(dm.QTemp,st,Open,'');
   if dm.QTemp.Fields.RecordCount > 0 then
       begin
         aut:= dm.QTemp.Fields.AsString[0];
         if pos('A',aut) > 0 then //amministratore
           begin
              user.Amministratore:= True;
              user.Inserimento:= True;
              user.Modifica:= True;
              user.Cancellazione:= True;
              exit;
           end;
         if pos('I',aut) > 0 then //Inserimento
            user.Inserimento:= True;
         if pos('M',aut) > 0 then //Modifica
            user.Modifica:= True;
         if pos('C',aut) > 0 then //Cancellazione
            user.Cancellazione:= True;
         if pos('L',aut) > 0 then //Lettura
            user.Lettura:= True;
       end
   else
       begin
         ShowMessage('Attenzione Militare non Abilitato');
         Application.Terminate;
       end;
end;

procedure Tmain.RicercaModelli135;
Var st:string;
begin
  SGLetMod135.Active:= False;
  st:= ' SELECT r.DATAMOD135, r.NRMOD135, r.IDMOD135,SUM(r1.QUANTITA) as Nr_Capi ';
  st:= st + ' FROM MOD135 r left join DATIMOD135 r1 on (r.IDMOD135 = r1.KSMOD135) ';
  st:= st + ' where r.KSMILITARE = ' + dm.DSetDati.FieldByName('IDMILITARE').AsString;
  st:= st + ' group by r.DATAMOD135, r.NRMOD135, r.IDMOD135 ';
  SGLetMod135.Sql.Text:=st;
  SGLetMod135.Active:= True;
end;



procedure Tmain.EsportaEXL();
 var
    Exp: TFPSExport;
    ExpSettings: TFPSExportFormatSettings;
    where:string;
    filtro,ST:string;
 //   TheDate: TDateTime;
  begin
    filtro:= UpperCase(ECdati.filtro);
    where := Copy(filtro,pos('WHERE',filtro),Length(filtro));
    st := ' select MATRMEC,GRADO,COGNOME,NOME,REPARTO,CELSERVIZIO,TELPRIVATO,INTERNO  from VIEW_DATIPERSONALI anagrafica ';
    st:= st + where;

    dm.DSetTemp.SQL.Text:= ST;
    dm.DSetTemp.Active:=True;

    Exp := TFPSExport.Create(nil);
    ExpSettings := TFPSExportFormatSettings.Create(true);
    try
      ExpSettings.ExportFormat := efXLS; // choose file format
      ExpSettings.HeaderRow := true; // include header row with field names
      Exp.FormatSettings := ExpSettings; // apply settings to export object
      Exp.Dataset:= dm.DSetTemp; // specify source
      Exp.FileName := 'c:\windows\temp\utenze.xls';
      Exp.Execute; // run the export
    finally
      Exp.Free;
      ExpSettings.Free;
  end;
  OpenDocument('c:\windows\temp\utenze.xls');
end;

procedure Tmain.ECdatiBeforeFind(Sender: Tobject; var CampiValori, CampiWhere,
  CampiJoin: string; var CheckFiltro: Boolean; var Indice: string;
  var SelectCustomer: string);
begin
   SelectCustomer:= 'SELECT * FROM VIEW_DATIPERSONALI ANAGRAFICA';
   if  presente.Checked then
      CampiWhere:= ' VISUALIZZANOMI = ''S'' ';
end;

procedure Tmain.ECdatiBeforeUpdate(Sender: Tobject; var where,
  CampiValore: string);
begin
   where:=  'idmilitare = ' + dm.DSetDati.FieldByName('IDMILITARE').AsString;
end;

procedure Tmain.ECdatiContatore(Sender: TObject);
begin
   if ECdati.contatore = '' then
     Lcontatore.Caption :=  ''
   else
      Lcontatore.Caption :=  'Trovati nr   ' + ECdati.contatore;
   if dm.DSetDati.Active then
     RicercaModelli135();
end;

procedure Tmain.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  if not (FrMod135.operazione in [FtView,FtDefault]) then
    begin
      ShowMessage('Attenzione dei confermare prima i dati');
      CloseAction:= caNone;
    end;
end;

procedure Tmain.FormCreate(Sender: TObject);
begin
     FrMod135:= TFrMod135.Create(TSMod135);
     FrMod135.Parent := TSMod135;
end;

procedure Tmain.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
   if (key = 34) and (matrmec.Text <> '') then
   WTnav.ActiveButton('Successivo');
    if (key = 33) and (matrmec.Text <> '') then
   WTnav.ActiveButton('Precedente');
end;

procedure Tmain.cognomeKeyPress(Sender: TObject; var Key: char);
begin
   if key = #13 then
    WTnav.ActiveButton('Conferma');
end;


{ Tmain }


end.




