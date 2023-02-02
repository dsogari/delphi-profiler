unit Profiler.Trace;

{$SCOPEDENUMS ON}
{$M+}

interface

uses
  System.Classes;

type

  TTraceEventType = (Enter, Leave);

  ITrace = interface
    function GetEventName: string;
    function GetEventType: TTraceEventType;
    function GetElapsedTicks: Int64;
    property EventName: string read GetEventName;
    property EventType: TTraceEventType read GetEventType;
    property ElapsedTicks: Int64 read GetElapsedTicks;
  end;

  ITracer = interface
    procedure Log(const Trace: ITrace);
    procedure SetScopeFilter(const Pattern: string);
    procedure SaveProfileToStream(Stream: TStream);
    procedure SaveStatisticsToStream(Stream: TStream);
  end;

procedure SetTracer(Tracer: ITracer);
procedure SetTracingScopeFilter(const Pattern: string);
procedure SetTracingProfileFileName(const FileName: string);
procedure SetTracingStatsFileName(const FileName: string);

function Trace(const ScopeName: ShortString): ITrace;

implementation

uses
  System.SysUtils,
  Profiler.ScopedTrace,
  Profiler.ProfileTracer;

var
  GlobalTracer: ITracer;
  ProfileFileName: string;
  StatsFileName: string;

procedure SetTracer(Tracer: ITracer);
begin
  GlobalTracer := Tracer;
end;

procedure SetTracingScopeFilter(const Pattern: string);
begin
  if Assigned(GlobalTracer) then
    GlobalTracer.SetScopeFilter(Pattern);
end;

procedure SetTracingProfileFileName(const FileName: string);
begin
  ProfileFileName := FileName;
end;

procedure SetTracingStatsFileName(const FileName: string);
begin
  StatsFileName := FileName;
end;

function Trace(const ScopeName: ShortString): ITrace;
begin
  if Assigned(GlobalTracer) then
    Result := TScopedTrace.Create(ScopeName, GlobalTracer)
  else
    Result := nil;
end;

procedure SaveTracingProfileToFile(const FileName: string);
var
  Stream: TStream;
begin
  Stream := TFileStream.Create(FileName, fmCreate);
  try
    GlobalTracer.SaveProfileToStream(Stream);
  finally
    Stream.Free;
  end;
end;

procedure SaveTracingStatsToFile(const FileName: string);
var
  Stream: TStream;
begin
  Stream := TFileStream.Create(FileName, fmCreate);
  try
    GlobalTracer.SaveStatisticsToStream(Stream);
  finally
    Stream.Free;
  end;
end;

procedure SaveReportsToFile;
begin
  try
    SaveTracingProfileToFile(ProfileFileName);
    SaveTracingStatsToFile(StatsFileName);
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end;

initialization

SetTracer(TProfileTracer.Create);
SetTracingProfileFileName('profile.csv');
SetTracingStatsFileName('stats.csv');

finalization

SaveReportsToFile;

end.
