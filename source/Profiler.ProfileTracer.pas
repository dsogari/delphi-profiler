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
      FCallStack: TStack<string>;
      FProfileReport: TProfileReport;
      FCriticalSection: TCriticalSection;
      FScopeFilter: TRegEx;

      procedure HandleTraceEnter(const Trace: ITrace);
      procedure HandleTraceLeave(const Trace: ITrace);

    private { ITracer }
      procedure Log(const Trace: ITrace);
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

procedure TProfileTracer.Log(const Trace: ITrace);
begin
  Assert(Assigned(Trace));
  FCriticalSection.Acquire;
  try
    if FScopeFilter.Match(Trace.ScopeName).Success then
      begin
        if Trace.EventType = TTraceEventType.Enter then
          HandleTraceEnter(Trace)
        else
          HandleTraceLeave(Trace);
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

procedure TProfileTracer.HandleTraceEnter(const Trace: ITrace);
begin
  if not Trace.IsLongLived then
    begin
      if FCallStack.Count > 0 then
        FProfileReport.Add(FCallStack.Peek, Trace.ElapsedTicks, False);
      FCallStack.Push(Trace.ScopeName);
    end;
end;

procedure TProfileTracer.HandleTraceLeave(const Trace: ITrace);
begin
  if Trace.IsLongLived then
    FProfileReport.Add(Trace.ScopeName, Trace.ElapsedTicks, True)
  else
    begin
      Assert(FCallStack.Count > 0, 'The call stack must not be empty');
      Assert(FCallStack.Peek = Trace.ScopeName,
        'Trying to leave the wrong scope. Maybe this should be a long-lived trace event?');
      FProfileReport.Add(FCallStack.Pop, Trace.ElapsedTicks, True);
    end;
end;

end.
