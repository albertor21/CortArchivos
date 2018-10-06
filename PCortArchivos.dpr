program PCortArchivos;

uses
  Forms,
  UFrmMain in 'UFrmMain.pas' {FrmMain};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TFrmMain, FrmMain);
  Application.Run;
end.

