unit FmRicerche_f;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls, Buttons, umEdit, WTStringGridSql,LSystemTrita, uibdataset,WTVarie_f ;

type

  { TFmRicerche }

  TFmRicerche = class(TForm)
    codice: TumEdit;
    Protocollo: TumEdit;
    descrizione: TumEdit;
    NrContratto: TumEdit;
    Matricola: TumEdit;
    inventario: TumEdit;
    Image1: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label9: TLabel;
    Panel1: TPanel;
    Panel4: TPanel;
    SBesporta: TSpeedButton;
    SBricerca: TSpeedButton;
    SGmagazzino: TwtStringGridSql;
    procedure descrizioneChange(Sender: TObject);
    procedure descrizioneKeyPress(Sender: TObject; var Key: char);
    procedure FormShow(Sender: TObject);
    procedure SBesportaClick(Sender: TObject);
    procedure SBricercaClick(Sender: TObject);
  private
    procedure Ricerca;
  public

  end;

var
  FmRicerche: TFmRicerche;
  const Sql = ' SELECT r5.CODICE,r5.DESCRIZIONE,r.MATRICOLA, r.QUANTITA,r1.DATAMOD135 as ASSEGNATA,r2.MATRMEC, '+
              ' r2.COGNOME,r2.NOME,r3.INVENTARIO, r4.NRCONTRATTO,r4.DATACONTRATTO, r4.PROTOCOLLO, r4.DATAPROTOCOLLO ' +
              ' FROM DATIMOD135 r ' +
              ' inner join MOD135 r1 on (r.KSMOD135 = r1.IDMOD135) inner join ANAGRAFICA r2 on (r1.KSMILITARE = r2.IDMILITARE) '+
              ' inner join DATIMAGAZZINO r3 on (r.KSDATIMAGAZZINO = r3.IDDATIMAGAZZINO) ' +
              ' inner join MAGAZZINO r4 on (r3.KSMAGAZZINO  = r4.IDMAGAZZINO) ' +
              ' inner join CODICIVESTIARIO r5 on (r3.KSCODVEST = r5.IDCODVEST) ';

implementation

uses DM_f, main_f;

{$R *.lfm}

{ TFmRicerche }

procedure TFmRicerche.descrizioneChange(Sender: TObject);
begin

end;

procedure TFmRicerche.descrizioneKeyPress(Sender: TObject; var Key: char);
begin
  if key = #13 then
    Ricerca;
end;

procedure TFmRicerche.FormShow(Sender: TObject);
begin
  sbricerca.Caption := 'Nuova Ricerca';
  SBricercaClick(self);
end;

procedure TFmRicerche.SBesportaClick(Sender: TObject);
Var st:string;
begin
   st:= SGmagazzino.Sql.Text;
  if (st <> '') and (SGmagazzino.Found) then
   begin
    dm.DSetTemp.SQL.Text:= st;
    dm.DSetTemp.Active:=True;
    EsportaEXL(dm.DSetTemp);
   end;
end;



procedure TFmRicerche.SBricercaClick(Sender: TObject);
Var x:integer;
begin
  if sbricerca.Caption = 'Ricerca' then
    begin
       Ricerca;
       sbricerca.Caption := 'Nuova Ricerca';
    end
  else
     begin
        for x:=  1 to ComponentCount - 1 do
          if Components[x].ClassName = 'TumEdit' then
            TumEdit(Components[x]).Text := '';
        sbricerca.Caption := 'Ricerca';
        SGmagazzino.Active:=False;
        descrizione.SetFocus;
     end;
end;





procedure TFmRicerche.Ricerca;
Var filtro:string;
    x:integer;
begin
  filtro := '';
  for x:=  1 to ComponentCount - 1 do
    begin
      if Components[x].ClassName = 'TumEdit' then
        if TumEdit(Components[x]).Text <> '' then
          begin
             filtro := filtro +  Components[x].Name;
             filtro := filtro + '  ' +   TumEdit(Components[x]).TypeFind + ' ';
             filtro := filtro + '''' +  Ch_apostrofo(TumEdit(Components[x]).Text) + ''' and  ';
          end;
    end;
    if filtro <> '' then
      begin
         // levo l'ultimo and del filtro
         filtro:= copy(filtro,1,Length(filtro)-5);
         SGmagazzino.Sql.Text:= Sql + ' where '  + filtro + '  ORDER BY r5.DESCRIZIONE ';
         SGmagazzino.Active:= False;
         SGmagazzino.Active:= True;
         if not SGmagazzino.Found then
             ShowMessage('Nessuna Corrispondenza Trovata');
      end;


end;


end.

