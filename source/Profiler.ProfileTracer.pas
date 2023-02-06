unit Profiler.ProfileTracer;

interface

uses
  Profiler.Types,
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
      FScopeFilter: TRegEx;

      procedure HandleTraceEnter(const Info: TTraceInfo);
      procedure HandleTraceLeave(const Info: TTraceInfo);

    protected
      FCriticalSection: TCriticalSection;

      procedure ClearHistory; virtual;
      procedure Log(const Info: TTraceInfo); virtual;
      procedure SetScopeFilter(const Pattern: string); virtual;
      procedure SaveProfileToStream(Stream: TStream); virtual;
      procedure SaveStatisticsToStream(Stream: TStream); virtual;

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

procedure TProfileTracer.ClearHistory;
begin
  FCriticalSection.Acquire;
  try
    FProfileReport.Clear;
  finally
    FCriticalSection.Release;
  end;
end;

procedure TProfileTracer.Log(const Info: TTraceInfo);
begin
  FCriticalSection.Acquire;
  try
    if FScopeFilter.Match(Info.FScopeName).Success then
      begin
        if Info.FEventType = TTraceType.Enter then
          HandleTraceEnter(Info)
        else
          HandleTraceLeave(Info);
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

procedure TProfileTracer.HandleTraceEnter(const Info: TTraceInfo);
begin
  if not Info.FIsLongLived then
    begin
      if FCallStack.Count > 0 then
        FProfileReport.Add(FCallStack.Peek, Info.FElapsedTicks, False);
      FCallStack.Push(Info.FScopeName);
    end;
end;

procedure TProfileTracer.HandleTraceLeave(const Info: TTraceInfo);
begin
  if Info.FIsLongLived then
    FProfileReport.Add(Info.FScopeName, Info.FElapsedTicks, True)
  else
    begin
      Assert(FCallStack.Count > 0, 'The call stack must not be empty');
      Assert(FCallStack.Peek = Info.FScopeName,
        'Trying to leave the wrong scope. Maybe this should be a long-lived trace event?');
      FProfileReport.Add(FCallStack.Pop, Info.FElapsedTicks, True);
    end;
end;

end.
