unit Profiler.ProfileTracer;

interface

uses
  Profiler.DataTypes,
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
      procedure Log(trace: ITrace);

    public
      constructor Create;
      destructor Destroy; override;
  end;

implementation

constructor TProfileTracer.Create;
begin
  FCriticalSection          := TCriticalSection.Create;
  FCallStack                := TStack<string>.Create;
  FProfileReport            := TProfileReport.Create;

  FProfileReport.ReportPath := 'profile.csv';
end;

destructor TProfileTracer.Destroy;
begin
  try
    FProfileReport.SaveToFile;
  except
    // we cannot not raise in destructor
  end;
  FProfileReport.Free;
  FCallStack.Free;
  FCriticalSection.Free;
  inherited;
end;

procedure TProfileTracer.Log(trace: ITrace);
begin
  FCriticalSection.Acquire;
  try
    FTrace := trace;
    try
      HandleTrace;
    finally
      FTrace := nil; // don't keep a reference here
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
  Assert(FCallStack.Count > 0);
  Assert(FCallStack.Peek = FTrace.EventName);
  FProfileReport.Add(FCallStack.Pop, FTrace.ElapsedTicks);
end;

initialization

GlobalTracer := TProfileTracer.Create;

end.
