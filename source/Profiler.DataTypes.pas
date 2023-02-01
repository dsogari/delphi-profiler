unit Profiler.DataTypes;

{$SCOPEDENUMS ON}

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
    procedure Log(trace: ITrace);
  end;

function trace(const strScopeName: ShortString): ITrace;

var
  GlobalTracer: ITracer;

implementation

uses
  Profiler.ScopedTrace;

function trace(const strScopeName: ShortString): ITrace;
begin
  if Assigned(GlobalTracer) then
    Result := TScopedTrace.Create(strScopeName);
end;

end.
