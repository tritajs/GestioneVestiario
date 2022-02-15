unit FmPopUpVestiario_f;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls, WTStringGridSql;

type

  { TFmPopUpVestiario }

  TFmPopUpVestiario = class(TForm)
    Image1: TImage;
    Label1: TLabel;
    Panel1: TPanel;
    SGVestiario: TwtStringGridSql;
    procedure FormShow(Sender: TObject);
  private

  public
    ksdatimagazzino:string;
  end;

var
  FmPopUpVestiario: TFmPopUpVestiario;
  const Sql = ' SELECT r1.DATAMOD135,r2.MATRMEC,r2.COGNOME,r2.NOME,r.QUANTITA, r.MATRICOLA ' +
              ' FROM DATIMOD135 r  ' +
              ' inner join MOD135 r1 on (r.KSMOD135 = r1.IDMOD135) ' +
              ' inner join ANAGRAFICA r2 on (r1.KSMILITARE = r2.IDMILITARE) ';


implementation

uses DM_f;

{$R *.lfm}

{ TFmPopUpVestiario }

procedure TFmPopUpVestiario.FormShow(Sender: TObject);
begin
  SGVestiario.Sql.Text:= Sql + 'where r.KSDATIMAGAZZINO = '  + ksdatimagazzino;
  SGVestiario.Active:= True;
  if not SGVestiario.Found then
    close;
end;

end.

