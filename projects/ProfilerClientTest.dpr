program ProfilerClientTest;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.Classes,
  System.SysUtils,
  Profiler.Trace;

procedure Inner;
begin
  Trace('Inner');
  Sleep(100);
end;

procedure Outter;
begin
  Trace('Outter');
  Sleep(100);
  Inner;
  Sleep(100);
end;

var
  I: Integer;
begin
  try
    Randomize;
//    SetTracingScopeFilter('O.*');
    for I := 0 to Random(10) do
      Outter;
    SaveTracingProfileToFile('profile.csv');
    SaveTracingStatisticsToFile('stats.csv');
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
