/// This is the entrypoint unit for tracing
unit Profiler.Trace;

{$SCOPEDENUMS ON}
{$M+}

interface

uses
  System.Classes;

type

  /// The type of trace event
  TTraceEventType = (Enter, Leave);

  /// The trace event object
  ITrace = interface
    /// Returns the trace scope name
    function GetScopeName: string;

    /// Returns the trace event type (entering or leaving a scope)
    function GetEventType: TTraceEventType;

    /// Returns the trace duration (in number of clock ticks)
    function GetElapsedTicks: Int64;

    /// Returns true if the trace event is long-lived (instead of block-scoped)
    function IsLongLived: Boolean;

    property ScopeName: string read GetScopeName;
    property EventType: TTraceEventType read GetEventType;
    property ElapsedTicks: Int64 read GetElapsedTicks;
  end;

  /// The tracer object (keeps track of trace events)
  ITracer = interface
    /// Log a trace event
    procedure Log(const Trace: ITrace);

    /// Set a pattern for filtering scope names
    procedure SetScopeFilter(const Pattern: string);

    /// Save the profile report to an output stream
    procedure SaveProfileToStream(Stream: TStream);

    /// Save the statistics report to an output stream
    procedure SaveStatisticsToStream(Stream: TStream);
  end;

/// Set the global tracer object
procedure SetTracer(Tracer: ITracer);

/// Set the filter of the global tracer
procedure SetTracingScopeFilter(const Pattern: string);

/// Set the filename for writing the profile report
procedure SetTracingProfileFileName(const FileName: string);

/// Set the filename for writing the statistics report
procedure SetTracingStatsFileName(const FileName: string);

/// Generate a block-scoped trace event
function Trace(const ScopeName: string): ITrace; overload;

/// Generate a long-lived trace event
procedure Trace(const ScopeName: string; out Trace: ITrace); overload;

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

function Trace(const ScopeName: string): ITrace;
begin
  if Assigned(GlobalTracer) then
    Result := TScopedTrace.Create(GlobalTracer, ScopeName, False)
  else
    Result := nil;
end;

procedure Trace(const ScopeName: string; out Trace: ITrace);
begin
  if Assigned(GlobalTracer) then
    Trace := TScopedTrace.Create(GlobalTracer, ScopeName, True)
  else
    Trace := nil;
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
