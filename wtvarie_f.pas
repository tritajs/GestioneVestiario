unit WTVarie_f;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils,fpSpreadsheet, fpsTypes,LCLIntf,uibdataset,LSystemTrita,Menus;

type
  Toperazione = (FtView, FtInserimento, FtModifica, FtCancellazione, FtFind, FtDefault);

  procedure EsportaEXL(DataSet: TUIBDataSet);
  function DeleteStr(st,substr:string):string;
  procedure EnableMenu(Menu:TMainMenu; Active:Boolean);

implementation

uses main_f;

procedure EsportaEXL(DataSet: TUIBDataSet);
Var
  MyWorkbook: TsWorkbook;
  MyWorksheet: TsWorksheet;
  riga,col,CharLeg:integer;
begin
  if DataSet.Active then
     begin
       DataSet.First;
       riga:= 0;
       col:= 0;
       MyWorkbook := TsWorkbook.Create;
       MyWorksheet := MyWorkbook.AddWorksheet('Foglio1');
  //   MyWorksheet.DefaultColWidth:= 23;
       for col:= 0 to DataSet.FieldCount - 1 do
        begin
           MyWorksheet.WriteText(0, col, DataSet.Fields[col].DisplayName);// C5
           CharLeg:= Length(DataSet.Fields[col].DisplayName);
           MyWorksheet.WriteColWidth(col,CharLeg + 7);
           MyWorksheet.WriteHorAlignment(0, col, haCenter);
           MyWorksheet.WriteBorders(0, col, [cbNorth, cbEast, cbSouth, cbWest]);
           MyWorksheet.WriteBackgroundColor(0, col, scYellow);
           Myworksheet.WriteFont(0, Col, 'Arial', 10, [fssBold], scBlack);
        end;
      while not DataSet.EOF do
        begin
         inc(riga);
         for col:= 0 to DataSet.FieldCount - 1 do
           begin
            MyWorksheet.WriteHorAlignment(riga, col, haCenter);
            if IsNumeric(DataSet.Fields[col].AsString) then
               MyWorksheet.WriteNumber(riga, col, DataSet.Fields[col].AsFloat)
            else
               MyWorksheet.WriteText(riga, col, DataSet.Fields[col].AsString)
            end;
         DataSet.Next;
        end;
      if FileExists(user.FileTemp) then
         DeleteFile(user.FileTemp);
      MyWorkbook.WriteToFile(user.FileTemp,sfExcel5,True);
      MyWorkbook.Free;
      OpenDocument(user.FileTemp);
    end;
end;

function DeleteStr(st,substr: string): string;
Var i,n:SmallInt;
begin
 i:= 0; n:= 0;
 i:=  pos(substr,st);
 if i > 0 then
   begin
    n:= Length(substr);
    delete(st,i,n)
   end;
  Result:= st;
end;

procedure EnableMenu(Menu: TMainMenu; Active:Boolean);
Var x:integer;
begin
  for x:= 0 to Menu.Items.Count - 1 do
    Menu.Items[x].Enabled:= Active;
end;

end.

