unit Profiler.ScopedTrace;

interface

uses
  Profiler.Trace;

type

  TScopedTrace = class(TInterfacedObject, ITrace)
    private
      FTracer: ITracer;
      FScopeName: string;
      FEventType: TTraceEventType;
      FClockTicks: Int64;
      FIsLongLived: Boolean;

      class threadvar FPreviousClock, FCurrentClock: Int64;
      class constructor Create;

    private { ITrace }
      function GetScopeName: string;
      function GetEventType: TTraceEventType;
      function GetElapsedTicks: Int64;
      function IsLongLived: Boolean;

    public
      class function NewInstance: TObject; override;
      procedure FreeInstance; override;
      function _AddRef: Integer; stdcall;
      function _Release: Integer; stdcall;

      constructor Create(const Tracer: ITracer; const ScopeName: string; IsLongLived: Boolean);
  end;

implementation

uses
  System.Diagnostics;

class constructor TScopedTrace.Create;
begin
  TStopwatch.Create; // initialize the stopwatch variables
end;

class function TScopedTrace.NewInstance: TObject;
begin
  FPreviousClock := FCurrentClock;
  FCurrentClock := TStopwatch.GetTimeStamp;
  Result := inherited;
end;

procedure TScopedTrace.FreeInstance;
var
  IsLongLived: Boolean;
begin
  IsLongLived := FIsLongLived;
  inherited;
  if not IsLongLived then
    FCurrentClock := TStopwatch.GetTimeStamp;
end;

function TScopedTrace._AddRef: Integer;
begin
  Result := inherited;
  if FRefCount = 1 then
    begin
      if (FPreviousClock > 0) and not FIsLongLived then
        FClockTicks := FCurrentClock - FPreviousClock;
      FEventType := TTraceEventType.Enter;
      FTracer.Log(Self); // refcount will be 2

      FClockTicks := TStopwatch.GetTimeStamp;
      if FIsLongLived then
        FCurrentClock := FPreviousClock // restore normal execution flow
      else
        FCurrentClock := FClockTicks;
    end;
end;

function TScopedTrace._Release: Integer;
begin
  if FRefCount = 1 then
    begin
      if FIsLongLived then
        FClockTicks := TStopwatch.GetTimeStamp - FClockTicks
      else
        FClockTicks := TStopwatch.GetTimeStamp - FCurrentClock;
      FEventType := TTraceEventType.Leave;
      FTracer.Log(Self); // refcount will be 2
    end;
  Result := inherited;
end;

constructor TScopedTrace.Create(const Tracer: ITracer; const ScopeName: string;
  IsLongLived: Boolean);
begin
  FTracer := Tracer;
  FScopeName := ScopeName;
  FIsLongLived := IsLongLived;
end;

function TScopedTrace.GetScopeName: string;
begin
  Result := FScopeName;
end;

function TScopedTrace.GetEventType: TTraceEventType;
begin
  Result := FEventType;
end;

function TScopedTrace.GetElapsedTicks: Int64;
begin
  Result := FClockTicks;
end;

function TScopedTrace.IsLongLived: Boolean;
begin
  Result := FIsLongLived;
end;

end.
