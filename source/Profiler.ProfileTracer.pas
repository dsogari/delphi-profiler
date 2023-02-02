unit Profiler.ProfileTracer;

interface

uses
  Profiler.Trace,
  Profiler.ProfileReport,
  System.Classes,
  System.SyncObjs,
  System.Generics.Collections,
  System.RegularExpressions;

type

  TProfileTracer = class(TInterfacedObject, ITracer)
    private
      FTrace: ITrace;
      FCallStack: TStack<string>;
      FProfileReport: TProfileReport;
      FCriticalSection: TCriticalSection;
      FScopeFilter: TRegEx;

      procedure HandleTrace;
      procedure HandleTraceEnter;
      procedure HandleTraceLeave;

    private { ITracer }
      procedure Log(Trace: ITrace);
      procedure SetScopeFilter(const Pattern: string);
      procedure SaveProfileToStream(Stream: TStream);
      procedure SaveStatisticsToStream(Stream: TStream);

    public
      constructor Create;
      destructor Destroy; override;
  end;

implementation

constructor TProfileTracer.Create;
begin
  FCriticalSection := TCriticalSection.Create;
  FCallStack := TStack<string>.Create;
  FProfileReport := TProfileReport.Create;
  FScopeFilter := TRegEx.Create('.*');
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
  Assert(Assigned(Trace));
  FCriticalSection.Acquire;
  if FScopeFilter.Match(Trace.EventName).Success then
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

procedure TProfileTracer.SaveProfileToStream(Stream: TStream);
begin
  FProfileReport.SaveProfileToStream(Stream);
end;

procedure TProfileTracer.SaveStatisticsToStream(Stream: TStream);
begin
  FProfileReport.SaveStatisticsToStream(Stream);
end;

procedure TProfileTracer.SetScopeFilter(const Pattern: string);
begin
  FScopeFilter := TRegEx.Create(Pattern);
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
    FProfileReport.Add(FCallStack.Peek, FTrace.ElapsedTicks, False);
  FCallStack.Push(FTrace.EventName);
end;

procedure TProfileTracer.HandleTraceLeave;
begin
  Assert(FCallStack.Count > 0, 'The call stack must not be empty');
  Assert(FCallStack.Peek = FTrace.EventName, 'Trying to leave the wrong function');
  FProfileReport.Add(FCallStack.Pop, FTrace.ElapsedTicks, True);
end;

initialization

GlobalTracer := TProfileTracer.Create;

end.
