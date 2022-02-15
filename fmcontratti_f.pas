unit FmContratti_f;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls, Buttons, WTStringGridSql,WTVarie_f;

type

  { TFmContratti }

  TFmContratti = class(TForm)
    Image1: TImage;
    Label9: TLabel;
    Panel1: TPanel;
    Panel4: TPanel;
    SBesporta: TSpeedButton;
    SGContratti: TwtStringGridSql;
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure SBesportaClick(Sender: TObject);
  private

  public

  end;

var
  FmContratti: TFmContratti;

implementation

uses DM_f;

{$R *.lfm}

{ TFmContratti }

procedure TFmContratti.FormShow(Sender: TObject);
begin
  SGContratti.Active:= True;
end;

procedure TFmContratti.SBesportaClick(Sender: TObject);
  Var st:string;
begin
  st:= 'SELECT  r.PROTOCOLLO, r.DATAPROTOCOLLO, r.NRCONTRATTO,r.DATACONTRATTO FROM MAGAZZINO r';
  if (st <> '') and (SGContratti.Found) then
   begin
    dm.DSetTemp.SQL.Text:= st;
    dm.DSetTemp.Active:=True;
    EsportaEXL(dm.DSetTemp);
   end;
end;

procedure TFmContratti.FormClose(Sender: TObject; var CloseAction: TCloseAction
  );
begin
    SGContratti.Active:= False;
end;

end.

