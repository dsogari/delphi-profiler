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
function Trace(const ScopeName: ShortString): ITrace;
procedure SetTracingScopeFilter(const Pattern: string);
procedure SaveTracingProfileToFile(const FileName: string);
procedure SaveTracingStatisticsToFile(const FileName: string);

implementation

uses
  Profiler.ScopedTrace,
  Profiler.ProfileTracer;

var
  GlobalTracer: ITracer;

procedure SetTracer(Tracer: ITracer);
begin
  GlobalTracer := Tracer;
end;

function Trace(const ScopeName: ShortString): ITrace;
begin
  if Assigned(GlobalTracer) then
    Result := TScopedTrace.Create(ScopeName, GlobalTracer)
  else
    Result := nil;
end;

procedure SetTracingScopeFilter(const Pattern: string);
begin
  GlobalTracer.SetScopeFilter(Pattern);
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

procedure SaveTracingStatisticsToFile(const FileName: string);
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

initialization

SetTracer(TProfileTracer.Create);

end.
