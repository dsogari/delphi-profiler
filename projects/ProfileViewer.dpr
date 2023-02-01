program ProfileViewer;

uses
  Vcl.Forms,
  Profiler.FormProfileViewer in '..\source\Profiler.FormProfileViewer.pas' {FormProfileViewer};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFormProfileViewer, FormProfileViewer);
  Application.Run;

end.
