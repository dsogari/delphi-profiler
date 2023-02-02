unit Profiler.ProfileTracer;

interface

uses
  Profiler.Trace,
  Profiler.ProfileReport,
  System.Classes,
  System.SyncObjs,
  System.Generics.Collections;

type

  TProfileTracer = class(TInterfacedObject, ITracer)
    private
      FTrace: ITrace;
      FCallStack: TStack<string>;
      FProfileReport: TProfileReport;
      FCriticalSection: TCriticalSection;

      procedure HandleTrace;
      procedure HandleTraceEnter;
      procedure HandleTraceLeave;

    private { ITracer }
      procedure Log(Trace: ITrace);

    public
      constructor Create;
      destructor Destroy; override;

      property Report: TProfileReport read FProfileReport;
  end;

implementation

constructor TProfileTracer.Create;
begin
  FCriticalSection := TCriticalSection.Create;
  FCallStack := TStack<string>.Create;
  FProfileReport := TProfileReport.Create;
end;

destructor TProfileTracer.Destroy;
begin
  FProfileReport.Free;
  FCallStack.Free;
  FCriticalSection.Free;
  inherited;
end;

procedure TProfileTracer.Log(Trace: ITrace);
begin
  FCriticalSection.Acquire;
  try
    FTrace := Trace;
    try
      HandleTrace;
    finally
      FTrace := nil; // do not keep a reference here
    end;
  finally
    FCriticalSection.Release;
  end;
end;

procedure TProfileTracer.HandleTrace;
begin
  if FTrace.EventType = TTraceEventType.Enter then
    HandleTraceEnter
  else
    HandleTraceLeave;
end;

procedure TProfileTracer.HandleTraceEnter;
begin
  if FCallStack.Count > 0 then
    FProfileReport.Add(FCallStack.Peek, FTrace.ElapsedTicks);
  FCallStack.Push(FTrace.EventName);
end;

procedure TProfileTracer.HandleTraceLeave;
begin
  Assert(FCallStack.Count > 0, 'The call stack must not be empty');
  Assert(FCallStack.Peek = FTrace.EventName, 'Trying to leave the wrong function');
  FProfileReport.Add(FCallStack.Pop, FTrace.ElapsedTicks);
end;

initialization

GlobalTracer := TProfileTracer.Create;

end.
