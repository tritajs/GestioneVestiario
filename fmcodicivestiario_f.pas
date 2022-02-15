unit FmCodiciVestiario_f;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  Buttons, StdCtrls, Grids, umEdit, LSystemTrita, WTVarie_f;

type

  { TFmCodiciVestiario }

  TFmCodiciVestiario = class(TForm)
    Image1: TImage;
    Image2: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Panel1: TPanel;
    Panel4: TPanel;
    Panel5: TPanel;
    SBcancel: TSpeedButton;
    SBedit: TSpeedButton;
    SBesporta: TSpeedButton;
    SBIns: TSpeedButton;
    SBok: TSpeedButton;
    SGCodici: TStringGrid;
    EdCodice: TumEdit;
    EdDescrizione: TumEdit;
    procedure EdCodiceKeyPress(Sender: TObject; var Key: char);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure SBcancelClick(Sender: TObject);
    procedure SBeditClick(Sender: TObject);
    procedure SBesportaClick(Sender: TObject);
    procedure SBInsClick(Sender: TObject);
    procedure SBokClick(Sender: TObject);
    procedure SGCodiciMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure SGCodiciPrepareCanvas(sender: TObject; aCol, aRow: Integer;
      aState: TGridDrawState);
    procedure SGCodiciValidateEntry(sender: TObject; aCol, aRow: Integer;
      const OldValue: string; var NewValue: String);

  private
     operazione: Toperazione;
     procedure VisibleTastiConferma(button:boolean);
     procedure  LeggeDati;
     procedure SalvaDati;
  public


  end;

var
  FmCodiciVestiario: TFmCodiciVestiario;

implementation

uses DM_f;

{$R *.lfm}

{ TFmCodiciVestiario }

procedure TFmCodiciVestiario.EdCodiceKeyPress(Sender: TObject; var Key: char);
begin
  if Key = #13 then
    LeggeDati;
end;

procedure TFmCodiciVestiario.FormClose(Sender: TObject;
  var CloseAction: TCloseAction);
begin
    SGCodici.RowCount:= 1;
    EdDescrizione.Text:='';
    EdCodice.Text:='';
end;



procedure TFmCodiciVestiario.SBcancelClick(Sender: TObject);
begin
   if (operazione = FtInserimento) then
    Operazione:= FtDefault
  else
   Operazione:= FtView;
  SBIns.Visible:= True;
  SBedit.Visible:= True ;
  SGCodici.RowCount:= 1;
  VisibleTastiConferma(False);
  if operazione = FtModifica then
    LeggeDati;
end;

procedure TFmCodiciVestiario.SBeditClick(Sender: TObject);
begin
  Operazione:= FtModifica;
  SBIns.Visible:=False;
  VisibleTastiConferma(True);
end;

procedure TFmCodiciVestiario.SBesportaClick(Sender: TObject);
Var st:string;
begin
  st:= dm.DSetCodici.SQL.Text;
//  st:= DeleteStr(st,'r.IDDATIMAGAZZINO,');
  if (st <> '') and (SGCodici.RowCount > 0) then
   begin
    dm.DSetTemp.SQL.Text:= st;
    dm.DSetTemp.Active:=True;
    EsportaEXL(dm.DSetTemp);
   end;
end;

procedure TFmCodiciVestiario.SBInsClick(Sender: TObject);
begin
   operazione:= FtInserimento;
   SBedit.Visible:= False;
   SGCodici.RowCount:= SGCodici.RowCount + 1;
   SGCodici.Cells[0,SGCodici.RowCount - 1]:= 'I';
   VisibleTastiConferma(True);
   SGCodici.Row:= SGCodici.RowCount - 1;
   SGCodici.Col:= 3;
   SGCodici.SetFocus;
end;

procedure TFmCodiciVestiario.SBokClick(Sender: TObject);
begin
  SGCodici.Col:=1;
  SGCodici.SetFocus;
  SBIns.Visible:= True;
  SBedit.Visible:= True ;
  SalvaDati;
end;

procedure TFmCodiciVestiario.SGCodiciMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
    if (Operazione = FtModifica) and (SGCodici.Cells[0,SGCodici.Row] = '') then
     if  (SGCodici.Col = 3) or (SGCodici.Col = 4)  then
         SGCodici.Cells[0,SGCodici.Row]:= 'M';
end;

procedure TFmCodiciVestiario.SGCodiciPrepareCanvas(sender: TObject; aCol,
  aRow: Integer; aState: TGridDrawState);
begin
     if (SGCodici.Cells[0,aRow] = 'C') then
        SGCodici.Canvas.Brush.Color := clRed; // this would highlight also column or row headers
end;

procedure TFmCodiciVestiario.SGCodiciValidateEntry(sender: TObject; aCol,
  aRow: Integer; const OldValue: string; var NewValue: String);
begin
   if (NewValue <> OldValue) and (Operazione = FtModifica) and (SGCodici.Cells[0,aRow] = '') then
     SGCodici.Cells[0,aRow]:= 'M';
end;



procedure TFmCodiciVestiario.VisibleTastiConferma(button: boolean);
begin
  SBok.Visible:= button;
  SBcancel.Visible:= button;
  if (button)  and (operazione in [FtInserimento, FtModifica]) then
    begin
      SGCodici.Options:= SGCodici.Options + [goEditing];
    end
  else
    begin
      SGCodici.Options:= SGCodici.Options - [goEditing];
    end;
end;

procedure TFmCodiciVestiario.LeggeDati;
Var riga,nr: integer;
    st,where:string;
begin
 st:= ' select * from codicivestiario  ';
 where:= '';
 if EdCodice.Text <> '' then
   where:= where + ' codice containing ''' + EdCodice.Text + '''';
 if EdDescrizione.Text <> '' then
   begin
     if  where= '' then
       where := ' descrizione containing ''' + EdDescrizione.Text + ''''
     else
       where :=  where + ' and  descrizione containing ''' + EdDescrizione.Text + ''''
   end;
  if where <> '' then
    st:= st + ' where ' + where;



 SGCodici.RowCount:= 1;
 nr:= 0;
 if EseguiSQLDS(dm.DSetCodici,st,Open,'') then
   begin
     while not dm.DSetCodici.Eof do
       begin
          if dm.DSetCodici.FieldByName('CODICE').AsString <> '' then //se ci sono dati nel campo codice creo la riga
            begin
              SGCodici.RowCount:= SGCodici.RowCount + 1;
              riga:= SGCodici.RowCount - 1;
              SGCodici.Cells[0,riga] := ''; //check
              SGCodici.Cells[1,riga] := dm.DSetCodici.FieldByName('IDCODVEST').AsString;
              Inc(nr);
              SGCodici.Cells[2,riga] := IntToStr(nr);
              SGCodici.Cells[3,riga] := dm.DSetCodici.FieldByName('CODICE').AsString;
              SGCodici.Cells[4,riga] := dm.DSetCodici.FieldByName('DESCRIZIONE').AsString;
            end;
          dm.DSetCodici.Next;
      end;
     dm.DSetCodici.First; // mi riposiziono sul primo record
     SGCodici.Row:= 1;
     dm.DSetCodici.Close;
   end
 else
   ShowMessage('Dati Non Trovati') ;
end;

procedure TFmCodiciVestiario.SalvaDati;
Var st:string;
    riga:integer;
begin
   for riga := 1 to SGCodici.RowCount - 1 do
    begin
      if SGCodici.Cells[0,riga] <> '' then   // s'è stata apportata una modifica NEL CAMPO CHECK eseguo la store procedure
        begin
          if  SGCodici.Cells[0,riga] = 'M' then
            begin
               st:= 'UPDATE CODICIVESTIARIO SET DESCRIZIONE = ';
               st:= st + AddValIntoSql(SGCodici.Cells[4,riga],[AsqlVirgola,AsqlApici,AsqlUpper]);
               st:= st + ' CODICE = ';
               st:= st + AddValIntoSql(SGCodici.Cells[3,riga],[AsqlApici,AsqlUpper]);
               st:= st + ' WHERE IDCODVEST = ' + SGCodici.Cells[1,riga];
            end
          else if  SGCodici.Cells[0,riga] = 'I' then
            begin
               st:= 'INSERT INTO CODICIVESTIARIO (DESCRIZIONE, CODICE) VALUES (';
               st:= st + AddValIntoSql(SGCodici.Cells[4,riga],[AsqlVirgola,AsqlApici,AsqlUpper]);
               st:= st + AddValIntoSql(SGCodici.Cells[3,riga],[AsqlApici,AsqlUpper]) + ')';
            end;
          dm.QTemp.SQL.Text:= st;
          dm.QTemp.Open();
        end;
    end;
  dm.TR.Commit;
  operazione:= FtView;
  VisibleTastiConferma(False);
end;

end.

