           unit frmod135_f;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, ExtCtrls, Buttons, Grids,
  LCLType, LSystemTrita,  LR_Class, LR_DBSet, LR_Desgn, WDateEdit,
  Dialogs, Graphics, EditBtn, StdCtrls, Menus, WTVarie_f;
type
  { TFrMod135 }
  TFrMod135 = class(TFrame)
    EDNrMod135: TEdit;
    frDesigner1: TfrDesigner;
    frDSetDatiMod135: TfrDBDataSet;
    frRepMod135: TfrReport;
    Image1: TImage;
    Label1: TLabel;
    MenuItem1: TMenuItem;
    Panel1: TPanel;
    Panel4: TPanel;
    PopupMenu1: TPopupMenu;
    SBcancel: TSpeedButton;
    SBdel: TSpeedButton;
    SBedit: TSpeedButton;
    SBPrint: TSpeedButton;
    SBIns: TSpeedButton;
    SBok: TSpeedButton;
    SGMod135: TStringGrid;
    DataMod135: TWDateEdit;
    procedure frRepMod135GetValue(const ParName: String; var ParValue: Variant);
    procedure MenuItem1Click(Sender: TObject);
    procedure SBcancelClick(Sender: TObject);
    procedure SBdelClick(Sender: TObject);
    procedure SBeditClick(Sender: TObject);
    procedure SBInsClick(Sender: TObject);
    procedure SBokClick(Sender: TObject);
    procedure SBPrintClick(Sender: TObject);
    procedure SGMod135ButtonClick(Sender: TObject; aCol, aRow: Integer);
    procedure SGMod135ColRowInserted(Sender: TObject; IsColumn: Boolean;
      sIndex, tIndex: Integer);
    procedure SGMod135MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure SGMod135PrepareCanvas(sender: TObject; aCol, aRow: Integer;
      aState: TGridDrawState);
    procedure SGMod135ValidateEntry(sender: TObject; aCol, aRow: Integer;
      const OldValue: string; var NewValue: String);
  private
    procedure VisibleTastiConferma(button:boolean);
    procedure SalvaDati;
    function  CheckDati:boolean;
    function  CheckPostSave:Boolean; //Controlla eventuali errori prima dell'inserimento dei dati
    { private declarations }
  public
    GIdMod135:String; //contine il numero dell'id della tabella mod135
    operazione: Toperazione;
    procedure  LeggeDati;
    procedure CheckBottoni;
    Procedure Esegui(grant:integer);
    { public declarations }
  end;

implementation
{$R *.lfm}

uses  DM_f, main_f, fmMagazzino_f;

{ TFrMod135 }

procedure TFrMod135.SGMod135PrepareCanvas(sender: TObject; aCol, aRow: Integer;
  aState: TGridDrawState);
begin
    if (SGMod135.Cells[0,aRow] = 'C') then
        SGMod135.Canvas.Brush.Color := clRed; // this would highlight also column or row headers
end;


procedure TFrMod135.SBInsClick(Sender: TObject);
begin
   if not user.Inserimento then
     Begin
       ShowMessage('Militare non Abilitato');
       exit;
     end;
   Operazione:= FtInserimento;
   CheckBottoni;
   SGMod135.RowCount:= SGMod135.RowCount + 1;
   SGMod135.Cells[0,SGMod135.RowCount - 1]:= 'I';
   VisibleTastiConferma(True);
 //  DataMod135.Date:= now;
   SGMod135.Row:= SGMod135.RowCount - 1;
   SGMod135.Col:= 5;
   SGMod135.SetFocus;
   dm.TR.Commit;
end;

procedure TFrMod135.SBokClick(Sender: TObject);
begin
  SGMod135.Col:=1;
  SGMod135.SetFocus;
  SalvaDati;
end;

procedure TFrMod135.SBPrintClick(Sender: TObject);
begin
 if SGMod135.RowCount > 0 then
   begin
     dm.LoadFromDB('PrintDatiMod135',frRepMod135);
     frRepMod135.ShowReport
   end;
end;

procedure TFrMod135.SGMod135ButtonClick(Sender: TObject; aCol, aRow: Integer);
begin
   FmMagazzino.FormCall:='FmMod135';
   FmMagazzino.ShowModal;
   SGMod135.Cells[2,aRow] := FmMagazzino.SGmagazzino.Cells[11,FmMagazzino.SGmagazzino.Row]; //iddatimagazzino
   SGMod135.Cells[4,aRow] := FmMagazzino.SGmagazzino.Cells[2,FmMagazzino.SGmagazzino.Row]; //codice
   SGMod135.Cells[5,aRow] := FmMagazzino.SGmagazzino.Cells[1,FmMagazzino.SGmagazzino.Row]; //descrizione
   SGMod135.Cells[8,aRow] := FmMagazzino.SGmagazzino.Cells[3,FmMagazzino.SGmagazzino.Row]; //rimanenza
   SGMod135.col:= 6;
end;

procedure TFrMod135.SGMod135ColRowInserted(Sender: TObject; IsColumn: Boolean;
  sIndex, tIndex: Integer);
begin
  if (sindex > 1)  then
    begin
      if  not CheckDati then  //controllo se ci sono errori
        SGMod135.DeleteRow(sIndex)
      else
        begin
          SGMod135.Cells[3,SGMod135.RowCount - 1]:= inttostr(SGMod135.RowCount - 1);  //inserisco il numero progressivo alla riga
          SGMod135.Col:= 4;
          SGMod135.SetFocus;
        end;
    end
  else
    SGMod135.Cells[3,SGMod135.RowCount - 1]:= inttostr(SGMod135.RowCount - 1);    //inserisco il numero  progressivo alla riga
  SGMod135.Col:= 4;

end;

procedure TFrMod135.SGMod135MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if (Operazione = FtModifica) and (SGMod135.Cells[0,SGMod135.Row] = '') then
     if  (SGMod135.Col = 6) or (SGMod135.Col = 7)  then
         SGMod135.Cells[0,SGMod135.Row]:= 'M';
end;

procedure TFrMod135.SBdelClick(Sender: TObject);
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
  if SGMod135.RowCount > 1 then
   begin
     StrPCopy(st,'Confermi la cancellazione; ' +  SGMod135.Cells[3,SGMod135.row]);
     if  Application.MessageBox(st, 'MessageBoxDemo', BoxStyle) = IDYES then
      begin
        if (EDNrMod135.Text = '') or (SGMod135.Cells[0,SGMod135.Row] = 'I')  then   //se non è stato attribuito il numero del mod135, sono in fase di inserimento
         begin                                                                           //se nel campo check c'era prima la I sono in fase di inserimento in modifica
           SGMod135.DeleteRow(SGMod135.Row);
           operazione:= FtView;
           CheckBottoni;
           VisibleTastiConferma(False);
         end
        else   // fase di modifica
         begin
           SGMod135.Cells[0,SGMod135.Row]:= 'C';
           VisibleTastiConferma(True);
           SGMod135.Refresh;
           operazione:= FtCancellazione;
         end;
      end;
   end;

end;

procedure TFrMod135.SBcancelClick(Sender: TObject);
begin
  if (operazione = FtInserimento) AND (EDNrMod135.Text = '') then
    Operazione:= FtDefault
  else
   Operazione:= FtView;

  CheckBottoni;
  SGMod135.RowCount:= 1;
  VisibleTastiConferma(False);
  //ripristino la situazione precedente
  if EDNrMod135.Text <> '' then // se edit edmod135 contiene dei tati significa che stavo modificando i dati quindi rileggo
     LeggeDati;
end;


procedure TFrMod135.frRepMod135GetValue(const ParName: String;
  var ParValue: Variant);
begin
  if ParName = 'NrMod135' then
     ParValue:= EDNrMod135.Text;
  if ParName = 'Operatore' then
     ParValue:= user.grado + ' ' + user.nominativo;
end;


procedure TFrMod135.MenuItem1Click(Sender: TObject);
begin
  dm.LoadFromDB('PrintDatiMod135',frRepMod135);
  frRepMod135.DesignReport;
     dm.SaveToDB('PrintDatiMod135',frRepMod135);
end;


procedure TFrMod135.SBeditClick(Sender: TObject);
begin
  if not user.Modifica then
     Begin
       ShowMessage('Militare non Abilitato');
       exit;
     end;
  Operazione:= FtModifica;
  CheckBottoni;
  VisibleTastiConferma(True);
end;

procedure TFrMod135.SGMod135ValidateEntry(sender: TObject; aCol, aRow: Integer;
  const OldValue: string; var NewValue: String);
Var New,Old:integer;
begin
  if (NewValue <> OldValue) and (Operazione = FtModifica) and (SGMod135.Cells[0,aRow] = '') then
     SGMod135.Cells[0,aRow]:= 'M';
  //controlla in fase di modifica se i nuovi dati non sono maggiori delle rimanenze
  if (Acol =  7) and (NewValue <> OldValue) then
    begin
      if Operazione = FtModifica then
        begin
          New:= StrToInt(NewValue);
          Old:= StrToInt(OldValue);
          if (new > old) then
            if (New - Old) >  StrToInt(SGMod135.Cells[8,aRow]) then
              begin
                 ShowMessage('Attenzio la nuova quantità è superiore a quella in magazzino');
                 NewValue:= OldValue;
              end;
        end;
    end;
end;

procedure TFrMod135.VisibleTastiConferma(button: boolean);
begin
  //se sono in fase si modifica blocco il menu principale
  EnableMenu(main.MainMenu1, not button);
  SBok.Visible:= button;
  SBcancel.Visible:= button;
  DataMod135.Visible:= button; //visualizza la data per inserire il mod135 o ricercarne uno
  if (button)  and (operazione in [FtInserimento, FtModifica]) then
    begin
      SGMod135.Options:= SGMod135.Options + [goEditing];
    end
  else
    begin
      SGMod135.Options:= SGMod135.Options - [goEditing];
    end;
end;

procedure TFrMod135.CheckBottoni;
begin
  // le colonne codice 4 e descrizione 5 vengono bloccate
  SGMod135.Columns[4].ReadOnly:= True;
  SGMod135.Columns[5].ReadOnly:= True;

  case operazione of
//  FtView, FtInserimento, FtModifica, FtCancellazione, FtFind
    FtView: begin
         SBIns.Visible:=   True;
         SBedit.Visible:=  True;
         SBdel.Visible:=   True;
         SBPrint.Visible:= True;
    end;
    FtInserimento: begin
      SBIns.Visible:=   True;
      SBedit.Visible:=  False;
      SBdel.Visible:=   True;
      SBPrint.Visible:= False;
      SGMod135.Columns[4].ReadOnly:= False;
      SGMod135.Columns[5].ReadOnly:= False;
    end;
    FtModifica: begin
      SBIns.Visible:=   False;
      SBedit.Visible:=  True;
      SBdel.Visible:=   False;
      SBPrint.Visible:= False;
    end;
    FtDefault: begin
      SBIns.Visible:=   True;
      SBedit.Visible:=  False;
      SBdel.Visible:=   False;
      SBPrint.Visible:= False;
    end;
  end;
end;

procedure TFrMod135.SalvaDati;
Var riga:integer;
    st:string;
begin
  //Inizialmente effettuo un controllo sui dati da inserire sempre se non mi trovo in fase di cancellazione
  if operazione <> FtCancellazione then
     if not CheckPostSave then exit;

  //se non è presente il numero del modello 135 lo creo
  if EDNrMod135.Text = '' then
    begin
      st:=  ' SELECT IDMOD135, NRMOD135 FROM INSERIMENTO_MOD135 (';
      st:= st + dm.DSetDati.FieldByName('IDMILITARE').AsString + ',';  // ksmilitare
      st:= st + DataMod135.GetDataDB(True) + ')';
      dm.QTemp.sql.Text:= st;
      dm.QTemp.Open;
      EDNrMod135.Text:= dm.QTemp.Fields.ByNameAsString['NRMOD135'];
      GIdMod135:= dm.QTemp.Fields.ByNameAsString['IDMOD135'];
    end;
  //inserimento dati nella tabella datimod135
  for riga := 1 to SGMod135.RowCount - 1 do
    begin
      if SGMod135.Cells[0,riga] <> '' then   // s'è stata apportata una modifica NEL CAMPO CHECK eseguo la store procedure
        begin
          st:= 'select * from aggiornamento_datimod135(' + '''' + SGMod135.Cells[0,riga]  + ''','; //operazione
          st:= st +  GIdMod135 + ',';  // ksmod135
          st:= st +  '''' + SGMod135.Cells[2,riga] + ''',';  // KSDATIMAGAZZINO

          st:= st +  '''' + SGMod135.Cells[6,riga] + ''',';  // Numero MATRICOLE
          st:= st +  SGMod135.Cells[7,riga] + ')';  // quantità
          dm.QTemp.SQL.Text:= st;
          dm.QTemp.Open();
          dm.TR.Commit;
        end;
    end;
    operazione:= FtView;
    CheckBottoni;
    //aggiorno la situazione del militare rileggendo la tabella mod135
    main.RicercaModelli135;
    //AGGIORNO IL MODELLO 135 CON LE MIMANENZE DI MAGAZZINO MODIFICATE
    LeggeDati;
    VisibleTastiConferma(False);
end;



function TFrMod135.CheckDati: boolean;
begin
 result:= True;
 if SGMod135.Cells[7,SGMod135.Row] = '' then
  begin
   Showmessage('Attenzione manca la quantità');
   result:= False;
  end;
end;

function TFrMod135.CheckPostSave: Boolean;
Var riga,duplicata:smallint;
    codici:TStringList;
begin
 Result := True;
 // controllo s'è stato inserito il codice la descrizione e la quantita
 for riga:= 1 to SGMod135.RowCount -1 do
   begin
     if SGMod135.Cells[4,riga] = '' then  //riga 4 codice
      begin
       Showmessage('Attenzione non hai inserito il << CODICE >> alla riga ' + SGMod135.Cells[3,riga]);
       Result := False;
       Exit;
      end;
     if SGMod135.Cells[5,riga] = '' then  //riga descrizione
      begin
       Showmessage('Attenzione non hai inserito la << DESCRIZIONE >> alla riga ' + SGMod135.Cells[3,riga]);
       Result := False;
       Exit;
      end;
     if SGMod135.Cells[6,riga] = '' then  //riga MATRICOLA
      begin
       Showmessage('Attenzione non hai inserito la << MATRICOLA >> alla riga ' + SGMod135.Cells[3,riga]);
       Result := False;
       Exit;
      end;
     if SGMod135.Cells[7,riga] = '' then  //riga quantita
      begin
       Showmessage('Attenzione non hai inserito la << QUANTITA'' >> alla riga ' + SGMod135.Cells[3,riga]);
       Result := False;
       Exit;
      end;
   end;
 //controllo se la rimanenza di magazzino è maggiore o guale della quantità richiesta
   if (StrToInt(SGMod135.Cells[7,riga]) > StrToInt(SGMod135.Cells[8,riga])) and (operazione = FtInserimento) then
     begin
       Showmessage('Attenzione la QUANTITA'' è maggiore della RIMANENZA di Magazzino');
       Result := False;
       Exit;
     end;
 // controllo s'è stato inserito lo stesso codice più volte
 try
   codici := TStringList.Create();
   codici.Add(SGMod135.Cells[4,1]);
   for riga:= 2 to SGMod135.RowCount -1 do
     begin
       duplicata:= codici.IndexOf(SGMod135.Cells[4,riga]);
       codici.Add(SGMod135.Cells[4,riga]);
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

procedure TFrMod135.LeggeDati;
 Var riga,nr: integer;

     st:string;
 begin
  st:= ' select * from VIEW_DATIMOD135 r  ';
  st:= st + ' where r.ksmod135 = ' + GIdMod135;
  // SGMod135.Clear;
  SGMod135.RowCount:= 1;
  nr:= 0;
  if  EseguiSQLDS(dm.DSetDatiMod135,st,Open,'') then
    begin
      while not dm.DSetDatiMod135.Eof do
        begin
           if dm.DSetDatiMod135.FieldByName('CODICE').AsString <> '' then //se ci sono dati nel campo codice creo la riga
             begin
               SGMod135.RowCount:= SGMod135.RowCount + 1;
               riga:= SGMod135.RowCount - 1;
               SGMod135.Cells[0,riga] := ''; //check
               SGMod135.Cells[1,riga] := dm.DSetDatiMod135.FieldByName('KSMOD135').AsString;
               SGMod135.Cells[2,riga] := dm.DSetDatiMod135.FieldByName('KSDATIMAGAZZINO').AsString;
               Inc(nr);
               SGMod135.Cells[3,riga] := IntToStr(nr);
               SGMod135.Cells[4,riga] := dm.DSetDatiMod135.FieldByName('CODICE').AsString;
               SGMod135.Cells[5,riga] := dm.DSetDatiMod135.FieldByName('DESCRIZIONE').AsString;
               SGMod135.Cells[6,riga] := dm.DSetDatiMod135.FieldByName('MATRICOLA').AsString;
               SGMod135.Cells[7,riga] := dm.DSetDatiMod135.FieldByName('QUANTITA').AsString;
               SGMod135.Cells[8,riga] := dm.DSetDatiMod135.FieldByName('RIMANENZA').AsString;
             end;
           dm.DSetDatiMod135.Next;
       end;
      dm.DSetDatiMod135.First; // mi riposiziono sul primo record
      SGMod135.Row:= 1;
      dm.DSetDatiMod135.Close;
    end;
end;

procedure TFrMod135.Esegui(grant: integer);
begin
 // LeggeDati;
  if Grant = 4 then //Solo Lettura
    begin
      SBdel.Visible:= False;
      SBIns.Visible:= False;
      SBedit.Visible:=False;
    end;
end;

end.


