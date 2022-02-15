unit fmautorizzazioni_f;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls, Buttons, PairSplitter, DM_f, WTComboBoxSql,
  WTStringGridSql, umEdit, LSystemTrita, Grids, LCLType,xlsbiff8, WTVarie_f;

type

  { TFmAutorizzazioni }

  TFmAutorizzazioni = class(TForm)
    CGtabelle: TCheckGroup;
    Image1: TImage;
    Image2: TImage;
    Label1: TLabel;
    Label2: TLabel;
    LabelTitolo: TLabel;
    LabelTitolo1: TLabel;
    Panel1: TPanel;
    Panel2: TPanel;
    CBLmilitari: TWTComboBoxSql;
    Panel3: TPanel;
    Panel5: TPanel;
    SBcancel: TSpeedButton;
    SBdel: TSpeedButton;
    SBExcel: TSpeedButton;
    SBok: TSpeedButton;
    SGabilitati: TwtStringGridSql;
    procedure CBLmilitariChange(Sender: TObject);
    procedure CBLmilitariEnter(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure SBcancelClick(Sender: TObject);
    procedure SBdelClick(Sender: TObject);
    procedure SBExcelClick(Sender: TObject);
    procedure SBokClick(Sender: TObject);
    procedure SGabilitatiMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  private
    { private declarations }
     function FindAutorizzazione(matr:string):boolean;
     procedure VistadiDefault; // riporta la videata allo stato di quando è stata aperta per la prima volta
     procedure CleanTabelle; // pulisce le autorizzazioni per la vista parziale  delle tabelle
     function  ChechName:Boolean; //controlla se il nome è già presente nella tabella delle autorizzazioni
  public
    { public declarations }
  end;

var
  FmAutorizzazioni: TFmAutorizzazioni;


implementation

uses main_f;

{$R *.lfm}

{ TFmAutorizzazioni }


procedure TFmAutorizzazioni.CBLmilitariChange(Sender: TObject);
begin
  if CBLmilitari.ValueLookField <> '' then
    begin
      if ChechName then
        begin
          ShowMessage('<<<< Nominativo già inserito  >>>>');
          CBLmilitari.Text:= '';
        end
      else
        begin
          SBok.Visible:=True;
          SBcancel.Visible:=True;
        end;
    end;
end;

procedure TFmAutorizzazioni.CBLmilitariEnter(Sender: TObject);
begin
   if SBcancel.Visible then  VistadiDefault;   // se sono ancora abilitati i botton li disabilito
end;



procedure TFmAutorizzazioni.FormShow(Sender: TObject);
begin
  SGabilitati.Active:=False;
  SGabilitati.Active:=True;
  VistadiDefault;
end;




procedure TFmAutorizzazioni.SBcancelClick(Sender: TObject);
begin
  VistadiDefault;
end;

procedure TFmAutorizzazioni.SBdelClick(Sender: TObject);
Var
 Reply, BoxStyle: Integer;
 st:  array[0..255] of Char;
begin
    BoxStyle := MB_ICONQUESTION + MB_YESNO;
    StrPCopy(st,'Confermi la cancellazione; ' +  SGabilitati.Cells[2,SGabilitati.Row]);
    if  Application.MessageBox(st, 'MessageBoxDemo', BoxStyle) = IDYES then
      begin
         st:= 'delete from autorizzazionivestiario where matrmec = ''' + SGabilitati.Cells[0,SGabilitati.Row] + '''';
         EseguiSQL(dm.QTemp,st,Execute,'');
         SGabilitati.Active:=False;
         SGabilitati.Active:=True;
         VistadiDefault;
      end;

end;

procedure TFmAutorizzazioni.SBExcelClick(Sender: TObject);
Var
  st:string;
begin

 st:= ' SELECT distinct a.MATRMEC,a2.GRADO, a1.COGNOME,a1.NOME,a3.REPARTO,a1.celservizio FROM AUTORIZZAZIONIVESTIARIO a ';
 st:= st + ' inner join ANAGRAFICA a1 on (a.MATRMEC = a1.MATRMEC) ';
 st:= st + ' inner join GRADI a2 on (a1.KSGRADO = a2.IDGRADI) ';
 st:= st + ' inner join REPARTI a3 on (a1.KSREPARTO = a3.IDREPARTO) ';
 st:= st + ' order by a3.reparto,a1.cognome,a1.nome ';
 DM.DSetTemp.SQL.Text:= st;
 DM.DSetTemp.Open;
 if DM.DSetTemp.RecordCount > 0 then;
    EsportaEXL(dm.DSetTemp);
end;

procedure TFmAutorizzazioni.SBokClick(Sender: TObject);
  Var st,matr,temp,aut,car:string;
    x:Smallint;
begin
   aut:= '';
   for x:= 0 to CGtabelle.Items.Count - 1   do
     begin
        if CGtabelle.Checked[x] then
          begin
            car := copy(CGtabelle.Items[x],1,1);
            case car of
              'A': begin
                      aut := 'A'; //amministratore
                      break;
                   end;
              'I': aut :=  aut + 'I'; //inserimento
              'M': aut :=  aut + 'M'; //Modifica
              'C': aut :=  aut + 'C'; //Cancellazione
              'L': aut :=  aut + 'L'; //Lettura
            end;
          end;
     end;
  if CBLmilitari.Text <> '' then  // se il militare non è presente lo inserisco nella tabella delle autorizzazioni
     begin
         matr:= CBLmilitari.ValueLookField;
         //inserisco le nuove autorizzazionitiri
         st:= ' insert into autorizzazionivestiario (matrmec,autorizzato) values (';
         st:= st + '''' + matr + ''',''' + aut + ''')';
         EseguiSQL(dm.QTemp,st,Execute,'');
     end
  else
    begin //se il militare è già presente modifico i dati dell'autorizzazione
        matr:= SGabilitati.Cells[0,SGabilitati.Row];
        st:= ' update autorizzazionivestiario set autorizzato = ''' +  aut + ''' where ';
        st:= st + ' matrmec = ''' + matr + '''';
        EseguiSQL(dm.QTemp,st,Execute,'');
    end;
   dm.TR.Commit;
   SGabilitati.Active:=False;
   SGabilitati.Active:=True;
  // dm.LoadAutorizzazioni;
   VistadiDefault;
end;


procedure TFmAutorizzazioni.SGabilitatiMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
   FindAutorizzazione(SGabilitati.Cells[0,SGabilitati.Row]);
   SBok.Visible:=True;
   SBcancel.Visible:=True;
   SBdel.Visible:=True;
end;

function TFmAutorizzazioni.FindAutorizzazione(matr: string):boolean;
 Var st,aut:string;
     indice:integer;
begin
   Result:= False;
   //pulisco il cgtabelle
   CleanTabelle;
   st:= 'select autorizzato from autorizzazionivestiario where matrmec = ''' + matr + '''';
   EseguiSQL(dm.QTemp,st,Open,'');
   if dm.QTemp.Fields.RecordCount > 0 then
       begin
         aut:= dm.QTemp.Fields.AsString[0];
         if pos('A',aut) > 0 then //amministratore
           begin
              CGtabelle.Checked[0]:= True;
              exit;
           end;
         if pos('I',aut) > 0 then //Inserimento
            CGtabelle.Checked[1]:= True;
         if pos('M',aut) > 0 then //Modifica
            CGtabelle.Checked[2]:= True;
         if pos('C',aut) > 0 then //Cancellazione
            CGtabelle.Checked[3]:= True;
         if pos('L',aut) > 0 then //Lettura
            CGtabelle.Checked[4]:= True;
       end;
end;

procedure TFmAutorizzazioni.VistadiDefault;
begin
 CBLmilitari.Text:= '';
 CBLmilitari.ValueLookField:= '';
 SBok.Visible:=False;
 SBcancel.Visible:=False;
 SBdel.Visible:=False;
 CleanTabelle;
end;

procedure TFmAutorizzazioni.CleanTabelle;
 Var x:integer;
begin
 for x:= 0 to CGtabelle.Items.Count - 1   do
   CGtabelle.Checked[x] := False;
end;


function TFmAutorizzazioni.ChechName: Boolean;
Var riga:integer;
begin
 result:= False;
 for riga := 1 to SGabilitati.RowCount -1 do
    if SGabilitati.Cells[0,riga] = CBLmilitari.ValueLookField then
      Result := True;
end;


end.

