program ProfilerClientTest;

{$APPTYPE CONSOLE}

{$R *.res}


uses
  System.Classes,
  System.Diagnostics,
  System.TimeSpan,
  System.SysUtils,
  Profiler.Trace;

var
  I: Integer;
  InnerElapsedUs: Double;
  OutterElapsedUs: Double;

procedure Inner;
var
  Stopwatch: TStopwatch;
begin
  Trace('Inner');
  Stopwatch := TStopwatch.StartNew;
  Sleep(100);
  InnerElapsedUs := InnerElapsedUs + Stopwatch.Elapsed.TotalMilliseconds * 1000;
end;

procedure Outter;
var
  Stopwatch: TStopwatch;
begin
  Trace('Outter');
  Stopwatch := TStopwatch.StartNew;
  Sleep(100);
  Inner;
  Sleep(100);
  OutterElapsedUs := OutterElapsedUs + Stopwatch.Elapsed.TotalMilliseconds * 1000;
end;

const
  TotalCalls = 10;

begin
  try
    EnableTracing;
    for I := 1 to TotalCalls do
      Outter;
    SaveTracingProfileToFile('profile.csv');
    SaveTracingStatisticsToFile('stats.csv');
    Writeln('Outter elapsed (us): ', ((OutterElapsedUs - InnerElapsedUs) / TotalCalls).ToString);
    Writeln('Inner elapsed (us): ', (InnerElapsedUs / TotalCalls).ToString);
    ReadLn;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;

end.
