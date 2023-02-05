unit Profiler.ScopedTrace;

interface

uses
  Profiler.Trace;

type

  TScopedTrace = class(TInterfacedObject, ITrace)
    private
      FTracer: ITracer;
      FTraceInfo: TTraceInfo;

      class threadvar FPreviousClock, FCurrentClock: Int64;
      class var FTraceCount: Int64;
      class constructor Create;

    private { ITrace }
      function GetInfo: TTraceInfo;

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
  IsLongLived := FTraceInfo.FIsLongLived;
  inherited;
  if not IsLongLived then
    FCurrentClock := TStopwatch.GetTimeStamp;
end;

function TScopedTrace._AddRef: Integer;
begin
  Result := inherited;
  if FRefCount = 1 then
    begin
      if (FPreviousClock > 0) and not FTraceInfo.FIsLongLived then
        FTraceInfo.FElapsedTicks := FCurrentClock - FPreviousClock;
      FTraceInfo.FEventType := TTraceEventType.Enter;
      FTracer.Log(FTraceInfo);

      FTraceInfo.FElapsedTicks := TStopwatch.GetTimeStamp;
      if FTraceInfo.FIsLongLived then
        FCurrentClock := FPreviousClock // restore normal execution flow
      else
        FCurrentClock := FTraceInfo.FElapsedTicks;
    end;
end;

function TScopedTrace._Release: Integer;
begin
  if FRefCount = 1 then
    begin
      if FTraceInfo.FIsLongLived then
        FTraceInfo.FElapsedTicks := TStopwatch.GetTimeStamp - FTraceInfo.FElapsedTicks
      else
        FTraceInfo.FElapsedTicks := TStopwatch.GetTimeStamp - FCurrentClock;
      FTraceInfo.FEventType := TTraceEventType.Leave;
      FTracer.Log(FTraceInfo);
    end;
  Result := inherited;
end;

constructor TScopedTrace.Create(const Tracer: ITracer; const ScopeName: string;
  IsLongLived: Boolean);
begin
  FTracer := Tracer;
  FTraceInfo.FTraceID := AtomicIncrement(FTraceCount);
  FTraceInfo.FScopeName := ScopeName;
  FTraceInfo.FIsLongLived := IsLongLived;
end;

function TScopedTrace.GetInfo: TTraceInfo;
begin
//  FClockTicks
  Result := FTraceInfo;
end;

end.
