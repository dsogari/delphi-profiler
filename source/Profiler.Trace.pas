unit Profiler.Trace;

{$SCOPEDENUMS ON}
{$M+}

interface

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
    procedure Log(Trace: ITrace);
  end;

function Trace(const ScopeName: ShortString): ITrace; inline;

var
  GlobalTracer: ITracer;

implementation

uses
  Profiler.ScopedTrace;

function Trace(const ScopeName: ShortString): ITrace;
begin
  if Assigned(GlobalTracer) then
    Result := TScopedTrace.Create(ScopeName, GlobalTracer)
  else
    Result := nil;
end;

end.
