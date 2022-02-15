program GestioneVestiario;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, main_f, dm_f, uiblaz, fmMagazzino_f, frmod135_f, FmCaricoMagazzino_f,
  FmRicerche_f, FmPopUpVestiario_f, fmautorizzazioni_f, FmCodiciVestiario_f,
  FmContratti_f, WTVarie_f  { you can add units after this };

{$R *.res}

begin
  RequireDerivedFormResource:=True;
  Application.Initialize;
  Application.CreateForm(TDM, DM);
  Application.CreateForm(Tmain, main);
  Application.CreateForm(TFmMagazzino, FmMagazzino);
  Application.CreateForm(TFmCaricoMagazzino, FmCaricoMagazzino);
  Application.CreateForm(TFmRicerche, FmRicerche);
  Application.CreateForm(TFmPopUpVestiario, FmPopUpVestiario);
  Application.CreateForm(TFmAutorizzazioni, FmAutorizzazioni);
  Application.CreateForm(TFmCodiciVestiario, FmCodiciVestiario);
  Application.CreateForm(TFmContratti, FmContratti);
  Application.Run;
end.

