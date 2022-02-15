unit FmCaricoMagazzino_f;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls, Buttons, Grids, umEdit, WDateEdit, WTNavigator, wteditcompNew, LSystemTrita, db, LCLType;

type

  { TFmCaricoMagazzino }
  TCheck = record
    where:string;
    Campovuoto:string
  end;
  TFmCaricoMagazzino = class(TForm)
    Image1: TImage;
    Image2: TImage;
    Image3: TImage;
    Image4: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    LStato: TLabel;
    Lcontatore: TLabel;
    Label9: TLabel;
    protocollo: TumEdit;
    nrcontratto: TumEdit;
    Panel2: TPanel;
    Panel1: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    SBcancel: TSpeedButton;
    SBdel: TSpeedButton;
    SBedit: TSpeedButton;
    SBIns: TSpeedButton;
    SBok: TSpeedButton;
    SBPrint: TSpeedButton;
    SGMagazzino: TStringGrid;
    dataprotocollo: TWDateEdit;
    datacontratto: TWDateEdit;
    ECMagazzino: TwtEditCompNew;
    idmagazzino: TumEdit;
    SBContratti: TSpeedButton;
    WTNav: TWTNavigator;
    procedure ECMagazzinoContatore(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormShow(Sender: TObject);
    procedure SBcancelClick(Sender: TObject);
    procedure SBContrattiClick(Sender: TObject);
    procedure SBdelClick(Sender: TObject);
    procedure SBeditClick(Sender: TObject);
    procedure SBInsClick(Sender: TObject);
    procedure SBokClick(Sender: TObject);
    procedure SGMagazzinoButtonClick(Sender: TObject; aCol, aRow: Integer);
    procedure SGMagazzinoMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure SGMagazzinoPrepareCanvas(sender: TObject; aCol, aRow: Integer;
      aState: TGridDrawState);
    procedure SGMagazzinoValidateEntry(sender: TObject; aCol, aRow: Integer;
      const OldValue: string; var NewValue: String);
    procedure WTNavBeforeClick(Sender: TObject;
      var Button: TNavButtonType; var EseguiPost: Boolean);
    procedure WTNavClick(Sender: TObject; Button: TNavButtonType);
  private
    operazione: TDataSetState;
    function wheresql:TCheck; //genera il filtro sql dei dati inseriti
    function  CheckPostSave:Boolean; //Controlla eventuali errori prima dell'inserimento dei dati
    procedure VisibleTastiConferma(button:boolean);
    procedure SalvaDati;
    procedure  LeggeDati;
    procedure CheckBottoni;
  public

  end;

var
  FmCaricoMagazzino: TFmCaricoMagazzino;

implementation

uses DM_f, fmMagazzino_f, main_f, FmContratti_f, FmPopUpVestiario_f;

{$R *.lfm}

{ TFmCaricoMagazzino }

procedure TFmCaricoMagazzino.FormShow(Sender: TObject);
begin
  Panel2.SetFocus;
  operazione:= dsInactive;
  CheckBottoni;
end;

procedure TFmCaricoMagazzino.SBcancelClick(Sender: TObject);
begin
  VisibleTastiConferma(False);
  operazione:= dsBrowse;
  //ripristino la situazione precedente
  if protocollo.Text <> '' then // se edit protocollo contiene dei dati significa che stavo modificando i dati quindi rileggo
     LeggeDati;
end;

procedure TFmCaricoMagazzino.SBContrattiClick(Sender: TObject);
begin
  FmContratti.ShowModal;
end;

procedure TFmCaricoMagazzino.SBdelClick(Sender: TObject);
var
  BoxStyle: Integer;
  st:  array[0..255] of Char;
begin
  if not user.Cancellazione then
     Begin
       ShowMessage('Militare non Abilitato');
       exit;
     end;
  BoxStyle := MB_ICONQUESTION + MB_YESNO;
  if SGMagazzino.RowCount > 1 then
   begin
     StrPCopy(st,'Confermi la cancellazione della riha numero  ' +  SGMagazzino.Cells[4,SGMagazzino.row]);
     if  Application.MessageBox(st, 'MessageBoxDemo', BoxStyle) = IDYES then
      begin
        if SGMagazzino.Cells[1,SGMagazzino.Row] = ''  then   //se non è stato attribuito il numero ksdatimagazzino, sono in fase di inserimento
          begin
             SGMagazzino.DeleteRow(SGMagazzino.Row);
             operazione:= dsBrowse;
             CheckBottoni;
          end
        else if SGMagazzino.Cells[0,SGMagazzino.Row] = 'I' then  //se nel campo check c'era prima la I sono in fase di inserimento in modifica
          SGMagazzino.DeleteRow(SGMagazzino.Row)
        else   // fase di modifica
         begin
           SGMagazzino.Cells[0,SGMagazzino.Row]:= 'C';
           VisibleTastiConferma(True);
           SGMagazzino.Refresh;
         end;
      end;
   end;
end;

procedure TFmCaricoMagazzino.SBeditClick(Sender: TObject);
begin
  if not user.modifica then
     Begin
       ShowMessage('Militare non Abilitato');
       exit;
     end;
  Operazione:= dsEdit;
  CheckBottoni;
  VisibleTastiConferma(True);
end;

procedure TFmCaricoMagazzino.SBInsClick(Sender: TObject);
begin
   if not user.Inserimento then
     Begin
       ShowMessage('Militare non Abilitato');
       exit;
     end;
   Operazione:= dsInsert;
   CheckBottoni;
   SGMagazzino.RowCount:= SGMagazzino.RowCount + 1;
   SGMagazzino.Cells[0,SGMagazzino.RowCount - 1]:= 'I';
   VisibleTastiConferma(True);
   SGMagazzino.Row:= SGMagazzino.RowCount - 1;
   SGMagazzino.Cells[4,SGMagazzino.Row] := IntToStr(SGMagazzino.Row);
   SGMagazzino.Col:= 5;
   SGMagazzino.SetFocus;
   dm.TR.Commit;
end;

procedure TFmCaricoMagazzino.SBokClick(Sender: TObject);
begin
  SGMagazzino.Col:=1;
  SGMagazzino.SetFocus;
  SalvaDati;
end;

procedure TFmCaricoMagazzino.SGMagazzinoButtonClick(Sender: TObject; aCol,
  aRow: Integer);
begin
   FmMagazzino.FormCall:='FmCaricoMagazzino';
   FmMagazzino.ShowModal;
   SGMagazzino.Cells[3,aRow] := FmMagazzino.SGmagazzino.Cells[0,FmMagazzino.SGmagazzino.Row]; //idcodvest
   SGMagazzino.Cells[5,aRow] := FmMagazzino.SGmagazzino.Cells[2,FmMagazzino.SGmagazzino.Row]; //codice;
   SGMagazzino.Cells[6,aRow] := FmMagazzino.SGmagazzino.Cells[1,FmMagazzino.SGmagazzino.Row]; //descrizione
   SGMagazzino.col:= 7;
end;



procedure TFmCaricoMagazzino.SGMagazzinoMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
   if (Operazione = dsEdit) and (SGMagazzino.Cells[0,SGMagazzino.Row] = '') then
     if  (SGMagazzino.Col = 7) or (SGMagazzino.Col = 8)  then
         SGMagazzino.Cells[0,SGMagazzino.Row]:= 'M';


   if (SGmagazzino.Row > 0) and  (SGmagazzino.Col = 9)  and (Operazione = dsBrowse)  then
      begin
        FmPopUpVestiario.ksdatimagazzino:= SGmagazzino.Cells[1,SGmagazzino.Row];
        FmPopUpVestiario.ShowModal;
      end;


end;



procedure TFmCaricoMagazzino.SGMagazzinoPrepareCanvas(sender: TObject; aCol,
  aRow: Integer; aState: TGridDrawState);
begin
   if (SGMagazzino.Cells[0,aRow] = 'C') then
        SGMagazzino.Canvas.Brush.Color := clRed; // this would highlight also column or row headers

end;

procedure TFmCaricoMagazzino.SGMagazzinoValidateEntry(sender: TObject; aCol,
  aRow: Integer; const OldValue: string; var NewValue: String);
begin
  if (aCol = 7) and (operazione = dsEdit) then
   begin
     if StrToInt(NewValue) < StrToInt(SGMagazzino.Cells[9,aRow]) then
       begin
         Showmessage('La quantita non può essere minore della rimanenza precedente');
         SGMagazzino.Cells[7,aRow] :=  OldValue;
       end;
   end;
end;




procedure TFmCaricoMagazzino.WTNavBeforeClick(Sender: TObject;
  var Button: TNavButtonType; var EseguiPost: Boolean);
var dati:TCheck;
st:string;
begin
   if (Button = nbtInsert) and not user.Inserimento then
     begin
       ShowMessage('Militare non abilitato');
       EseguiPost:= False;
       exit;
     end;
  //prima dell'inserimento controllo i dati inseriti
  if (Button = nbtPost) and (ECMagazzino.stato = dsInsert) then
     begin
       dati:= wheresql; // eseguo la funzione che mi genera il filtro e controlla anche se sono stati inseriti tutti i dati nele edit
       if dati.Campovuoto <> '' then
         begin
           EseguiPost:= False;
           ShowMessage('attenzione non hai inserito ' + dati.Campovuoto);
           exit;
         end;
      // se i dati sono stati tutti inseriti nelle edit controllo se i dati sono già stati inseriti
      st:= ' select idmagazzino from magazzino where ' + dati.where;
      if EseguiSQL(dm.QTemp,st,Open,'') then
        begin
          EseguiPost:= False;
          ShowMessage('attenzione dati già inseriti');
          exit;
        end;
     end;
end;

procedure TFmCaricoMagazzino.ECMagazzinoContatore(Sender: TObject);
begin
  Lcontatore.Caption :=  'Trovati nr ' + ECMagazzino.contatore;
  if idmagazzino.Text <> '' then
     LeggeDati;
end;

procedure TFmCaricoMagazzino.FormClose(Sender: TObject;
  var CloseAction: TCloseAction);
begin
  if not (operazione in [dsBrowse,dsInactive]) then
    begin
      ShowMessage('Attenzione dei confermare prima i dati');
      CloseAction:= caNone;
    end;
end;

procedure TFmCaricoMagazzino.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (key = 34) and (protocollo.Text <> '') then
   WTnav.ActiveButton('Successivo');
    if (key = 33) and (protocollo.Text <> '') then
   WTnav.ActiveButton('Precedente');
end;



procedure TFmCaricoMagazzino.WTNavClick(Sender: TObject;
  Button: TNavButtonType);
Var st:string;
begin
  if Button in [nbtFind] then
      operazione:= dsFilter;
  if Button in [nbtInsert] then
    begin
       operazione:= dsInactive;
       SGMagazzino.RowCount:= 0;
    end;

  CheckBottoni;




  if Button in [nbtEdit,nbtFind,nbtInsert] then
    protocollo.setfocus;

  if (Button =  nbtPost) and (ECMagazzino.stato = dsInsert) then
   begin
    //dopo l'inserimento rileggo il regord per acquisire idmagazzino
      st:= ' select idmagazzino from magazzino where ' + wheresql.where;
      if EseguiSQL(dm.QTemp,st,Open,'') then
         idmagazzino.Text:= dm.QTemp.Fields.ByNameAsString['idmagazzino'];
      operazione:= dsInsert;
      CheckBottoni;
      VisibleTastiConferma(True);
   end;


end;

function TFmCaricoMagazzino.wheresql: TCheck;
Var st,tmp:string;
begin
  if protocollo.Text <> '' then
   st:= ' protocollo = ''' + protocollo.Text + ''''
  else
   Result.Campovuoto:='protocollo';

  tmp:= dataprotocollo.GetDataDB(True);
  if tmp <> 'null' then
   st:= st + ' and dataprotocollo = ' + tmp
  else
   Result.Campovuoto:='data protocollo';


  if nrcontratto.Text <> '' then
   st:= st + ' and nrcontratto = ''' + nrcontratto.Text + ''''
  else
   Result.Campovuoto:='numero contratto';


  tmp:= datacontratto.GetDataDB(True);
  if tmp <> 'null' then
   st:= st + ' and datacontratto = ' + tmp
  else
   Result.Campovuoto:='data contrattto';


  if copy(st,2,3) = 'and' then
    st:= Copy(st,5,Length(st)- 4);

  Result.where := st;

end;

function TFmCaricoMagazzino.CheckPostSave: Boolean;
Var riga,duplicata:smallint;
    codici:TStringList;
begin
 Result := True;
 // controllo s'è stato inserito il codice la descrizione e la quantita
 for riga:= 1 to SGMagazzino.RowCount -1 do
   begin
     if SGMagazzino.Cells[5,riga] = '' then  //riga 3 codice
      begin
       Showmessage('Attenzione non hai inserito il CODICE alla riga ' + SGMagazzino.Cells[4,riga]);
       Result := False;
       Exit;
      end;
     if SGMagazzino.Cells[6,riga] = '' then  //riga descrizione
      begin
       Showmessage('Attenzione non hai inserito la DESCRIZIONE alla riga ' + SGMagazzino.Cells[4,riga]);
       Result := False;
       Exit;
      end;
     if SGMagazzino.Cells[7,riga] = '' then  //riga quantita
      begin
       Showmessage('Attenzione non hai inserito la QUANTITA'' alla riga ' + SGMagazzino.Cells[4,riga]);
       Result := False;
       Exit;
      end;
   end;
 // controllo s'è stato inserito lo stesso codice più volte
 try
   codici := TStringList.Create();
   codici.Add(SGMagazzino.Cells[5,1]);
   for riga:= 2 to SGMagazzino.RowCount -1 do
     begin
       duplicata:= codici.IndexOf(SGMagazzino.Cells[5,riga]);
       codici.Add(SGMagazzino.Cells[5,riga]);
       if  duplicata > -1 then
         begin
            Showmessage('attenzione la riga  ' + IntToStr(riga) + ' ha lo stesso codice dela riga ' + IntToStr(duplicata + 1) );
            Result := False;
            Exit;
         end;
     end
 finally
    codici.Free;
 end;

end;

procedure TFmCaricoMagazzino.VisibleTastiConferma(button: boolean);
begin
  SBok.Visible:= button;
  SBcancel.Visible:= button;
  if (button)  and (operazione in [dsInsert, dsEdit]) then
    begin
      SGMagazzino.Options:= SGMagazzino.Options + [goEditing];
    end
  else
    begin
      SGMagazzino.Options:= SGMagazzino.Options - [goEditing];
    end;
end;

procedure TFmCaricoMagazzino.SalvaDati;
Var riga:integer;
    st:string;
begin
  //Inizialmente effettuo un controllo sui dati da inserire
  if not CheckPostSave then exit;
  //inserimento dati nella tabella datimod135
  for riga := 1 to SGMagazzino.RowCount - 1 do
    begin
      if SGMagazzino.Cells[0,riga] <> '' then   // s'è stata apportata una modifica NEL CAMPO CHECK eseguo la store procedure
        begin
          st:= 'select * from aggiornamento_datimagazzino(' + '''' + SGMagazzino.Cells[0,riga]  + ''','; //operazione
          if SGMagazzino.Cells[1,riga] = '' then
             st:= st +  '0,'  // ksdatimagazzino
          else
             st:= st +  SGMagazzino.Cells[1,riga] + ',';  // ksdatimagazzino
          st:= st +  idmagazzino.Text + ',';           // ksmagazzino
          st:= st +  SGMagazzino.Cells[3,riga] + ',';  // kscodvest
          st:= st +  SGMagazzino.Cells[7,riga] + ',';  // quantità

          if  SGMagazzino.Cells[8,riga] = '' then
             st:= st + 'null)'
          else
             st:= st +  SGMagazzino.Cells[8,riga] + ')';  // Numero Inventario
          dm.QTemp.SQL.Text:= st;
          dm.QTemp.Open();
        end;
    end;
    dm.TR.Commit;
    LeggeDati;
    operazione:= dsBrowse;
    CheckBottoni;
    VisibleTastiConferma(False);
end;

procedure TFmCaricoMagazzino.LeggeDati;
Var st:string;
    nr,riga:integer;
 begin
  st:= 'SELECT r.IDDATIMAGAZZINO, r.KSMAGAZZINO, r.KSCODVEST,r2.CODICE,r2.DESCRIZIONE,r.QUANTITA, r.INVENTARIO, r.RIMANENZA, ';
  st:= st + 'r1.PROTOCOLLO,r1.DATAPROTOCOLLO,r1.NRCONTRATTO,r1.DATACONTRATTO ';
  st:= st + 'FROM DATIMAGAZZINO r left join MAGAZZINO r1 on (r.KSMAGAZZINO = r1.IDMAGAZZINO) ';
  st:= st + 'left join CODICIVESTIARIO r2 on (r.KSCODVEST = r2.IDCODVEST)';
  st:= st + 'where r.ksmagazzino =   ' + idmagazzino.Text;
  SGMagazzino.RowCount:= 1;
  nr:= 0;
  if EseguiSQLDS(dm.DSetDatiMagazzino,st,Open,'') then
    begin
      while not dm.DSetDatiMagazzino.Eof do
        begin
           SGMagazzino.RowCount:= SGMagazzino.RowCount + 1;
           riga:= SGMagazzino.RowCount - 1;
           SGMagazzino.Cells[0,riga] := ''; //check
           SGMagazzino.Cells[1,riga] := dm.DSetDatiMagazzino.FieldByName('IDDATIMAGAZZINO').AsString;
           SGMagazzino.Cells[2,riga] := dm.DSetDatiMagazzino.FieldByName('KSMAGAZZINO').AsString;
           SGMagazzino.Cells[3,riga] := dm.DSetDatiMagazzino.FieldByName('KSCODVEST').AsString;
           Inc(nr);
           SGMagazzino.Cells[4,riga] := IntToStr(nr);
           SGMagazzino.Cells[5,riga] := dm.DSetDatiMagazzino.FieldByName('CODICE').AsString;
           SGMagazzino.Cells[6,riga] := dm.DSetDatiMagazzino.FieldByName('DESCRIZIONE').AsString;
           SGMagazzino.Cells[7,riga] := dm.DSetDatiMagazzino.FieldByName('QUANTITA').AsString;
           SGMagazzino.Cells[8,riga] := dm.DSetDatiMagazzino.FieldByName('INVENTARIO').AsString;
           SGMagazzino.Cells[9,riga] := dm.DSetDatiMagazzino.FieldByName('RIMANENZA').AsString;

           dm.DSetDatiMagazzino.Next;
        end;
        dm.DSetDatiMagazzino.First; // mi riposiziono sul primo record
       end;
      SGMagazzino.Row:= 1;
      dm.DSetDatiMagazzino.Close;
      operazione:= dsBrowse;
      CheckBottoni;
end;

procedure TFmCaricoMagazzino.CheckBottoni;
begin
 case operazione of
   dsInactive: begin
        SBIns.Visible:=   False;
        SBedit.Visible:=  False;
        SBdel.Visible:=   False;
        SBPrint.Visible:= False;
        LStato.Caption:= 'Stato Inattivo';
   end;
   dsInsert: begin
     SBIns.Visible:=   True;
     SBedit.Visible:=  False;
     SBdel.Visible:=   True;
     SBPrint.Visible:= False;
     LStato.Caption:= 'Inserimento';
   end;
   dsEdit: begin
     SBIns.Visible:=   True;
     SBedit.Visible:=  True;
     SBdel.Visible:=   True;
     SBPrint.Visible:= True;
     LStato.Caption:= 'Modifica';
   end;
   dsFilter: begin
     SBIns.Visible:=   False;
     SBedit.Visible:=  False;
     SBdel.Visible:=   False;
     SBPrint.Visible:= False;
     SGMagazzino.RowCount:= 1;
     LStato.Caption:= 'Ricerca';
   end;
   dsBrowse: begin
     SBIns.Visible:=   True;
     SBedit.Visible:=  True;
     SBdel.Visible:=   True;
     SBPrint.Visible:= True;
     LStato.Caption:= 'Visualizzazione';
   end;
 end;

end;

end.

