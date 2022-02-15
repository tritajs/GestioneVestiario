unit fmMagazzino_f;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls, Buttons, umEdit, WTStringGridSql, uibdataset, Grids, Menus,
  WTVarie_f;

type

  { TFmMagazzino }

  TFmMagazzino = class(TForm)
    Image1: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Label9: TLabel;
    Panel1: TPanel;
    Panel4: TPanel;
    SBesporta: TSpeedButton;
    SBricerca: TSpeedButton;
    Edescrizione: TumEdit;
    Ecodice: TumEdit;
    SGmagazzino: TwtStringGridSql;
    SBInventario: TSpeedButton;
    procedure EdescrizioneKeyPress(Sender: TObject; var Key: char);
    procedure FormShow(Sender: TObject);
    procedure SBesportaClick(Sender: TObject);
    procedure SBricercaClick(Sender: TObject);
    procedure SBInventarioClick(Sender: TObject);
    procedure SGmagazzinoMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  private
     Sql:string;
     SqlFiltro:string;
     procedure Ricerca;
  public
    FormCall:string;  // contiene il nome della Form che richiama fmMagazzino
  end;

var
  FmMagazzino: TFmMagazzino;

implementation

uses main_f, DM_f, FmPopUpVestiario_f;

const SqlRicMagazzino = ' SELECT * FROM VIEW_DATIMAGAZZINO r ';

{$R *.lfm}

{ TFmMagazzino }

procedure TFmMagazzino.SBricercaClick(Sender: TObject);
begin
  Ricerca;
end;


procedure TFmMagazzino.SBInventarioClick(Sender: TObject);
Var st:string;
begin
  st:= ' SELECT r.IDDATIMAGAZZINO,r2.CODICE, r2.DESCRIZIONE,  r.RIMANENZA, r.QUANTITA, ';
  st:= st + ' r.QUANTITA - r.RIMANENZA as ASSEGNATA, ';
  st:= st + ' r.INVENTARIO ,r1.NRCONTRATTO, r1.DATACONTRATTO, r1.PROTOCOLLO, r1.DATAPROTOCOLLO ';
  st:= st + ' FROM DATIMAGAZZINO r ';
  st:= st + ' left join MAGAZZINO r1 on (r.KSMAGAZZINO = r1.IDMAGAZZINO) ' ;
  st:= st + ' left join CODICIVESTIARIO r2 on (r.KSCODVEST = r2.IDCODVEST) ';
  st:= st +  ' where r.rimanenza > 0';
  SGmagazzino.Sql.Text:=  st;
  SGmagazzino.Active:= True;
end;

procedure TFmMagazzino.SGmagazzinoMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
 if (SGmagazzino.Row > 0) and (FormCall <> '')  then
      Close
 else
   begin
     FmPopUpVestiario.ksdatimagazzino:= SGmagazzino.Cells[11,SGmagazzino.Row];
     FmPopUpVestiario.Show;
   end;
end;


procedure TFmMagazzino.EdescrizioneKeyPress(Sender: TObject; var Key: char);
begin
  if Key = #13 then
     Ricerca;
end;

procedure TFmMagazzino.FormShow(Sender: TObject);
Var x:integer;
begin
  SGmagazzino.Active:=false;
  Edescrizione.Text:='';
  Ecodice.Text:='';
  SqlFiltro:='';
  SBInventario.Visible:= False;
  Height:=316;
  Width:=1098;
  WindowState:= wsNormal;
  for x:= 4 to 11 do // non visualizzo  colonne non utili
    SGmagazzino.Columns[x].Visible:= False;

  if FormCall = 'FmMod135' then
     begin
       SGmagazzino.Columns[7].Visible:= True;
       SGmagazzino.Columns[8].Visible:= True;
       Sql:= SqlRicMagazzino;
       SqlFiltro := ' r.RIMANENZA > 0 and';
     end
  else if FormCall = 'FmCaricoMagazzino' then
      Sql:= 'select idcodvest,descrizione,codice from codicivestiario '
  else    //la Form viene chiamata dal main
    begin
     for x:= 4 to  11 do
       SGmagazzino.Columns[x].Visible:= True;
     Sql:= SqlRicMagazzino;
     SBInventario.Visible:= True;
     WindowState:= wsMaximized;
    end;
end;


procedure TFmMagazzino.Ricerca;
Var filtro:string;
begin
  filtro:= '';
  if Edescrizione.Text <> '' then
      filtro:= ' descrizione containing ''' + Edescrizione.Text + ''' ';
  if Ecodice.Text <> '' then
    if filtro = '' then
      filtro:=  filtro + ' CODICE containing ''' + Ecodice.Text + ''''
    else
      filtro:=  filtro + ' and  CODICE containing ''' + Ecodice.Text + '''';
  if filtro <> '' then
   begin
    SGmagazzino.Sql.Text:= Sql +  ' where ' + SqlFiltro  + filtro + ' order by descrizione';
    SGmagazzino.Active:= False;
    SGmagazzino.Active:= True;
    if not SGmagazzino.Found then
       Showmessage('Non Disponibile in Magazzino');
   end;
end;



procedure TFmMagazzino.SBesportaClick(Sender: TObject);
Var st:string;
begin
  st:= SGmagazzino.Sql.Text;
  st:= DeleteStr(st,'r.IDDATIMAGAZZINO,');
  if (st <> '') and (SGmagazzino.Found) then
   begin
    dm.DSetTemp.SQL.Text:= st;
    dm.DSetTemp.Active:=True;
    EsportaEXL(dm.DSetTemp);
   end;
end;

end.

