unit Profiler.ScopedTrace;

interface

uses
  Profiler.Trace;

type

  TScopedTrace = class(TInterfacedObject, ITrace)
    private
      FEventName: string;
      FEventType: TTraceEventType;
      FTracer: ITracer;

      class threadvar FElapsed: Int64;
      class threadvar FStartTimeStamp: Int64;

    private { ITrace }
      function GetEventName: string;
      function GetEventType: TTraceEventType;
      function GetElapsedTicks: Int64;

    public
      class function NewInstance: TObject; override;
      procedure FreeInstance; override;
      function _AddRef: Integer; stdcall;
      function _Release: Integer; stdcall;

      constructor Create(const ScopeName: ShortString; Tracer: ITracer);
  end;

implementation

uses
  System.Diagnostics;

class function TScopedTrace.NewInstance: TObject;
begin
  FElapsed := TStopwatch.GetTimeStamp - FStartTimeStamp;
  Result := inherited;
end;

procedure TScopedTrace.FreeInstance;
begin
  inherited;
  FStartTimeStamp := TStopwatch.GetTimeStamp;
end;

function TScopedTrace._AddRef: Integer;
begin
  Result := inherited;
  if FRefCount = 1 then
    begin
      FEventType := TTraceEventType.Enter;
      FTracer.Log(Self); // refcount = 2
      FStartTimeStamp := TStopwatch.GetTimeStamp;
    end;
end;

function TScopedTrace._Release: Integer;
begin
  if FRefCount = 1 then
    begin
      FElapsed := TStopwatch.GetTimeStamp - FStartTimeStamp;
      FEventType := TTraceEventType.Leave;
      FTracer.Log(Self); // refcount = 2
    end;
  Result := inherited;
end;

constructor TScopedTrace.Create(const ScopeName: ShortString; Tracer: ITracer);
begin
  FEventName := string(ScopeName);
  FTracer := Tracer;
end;

function TScopedTrace.GetEventName: string;
begin
  Result := FEventName;
end;

function TScopedTrace.GetEventType: TTraceEventType;
begin
  Result := FEventType;
end;

function TScopedTrace.GetElapsedTicks: Int64;
begin
  Result := FElapsed;
end;

initialization

TStopwatch.Create; // initialize the stopwatch variables

end.
