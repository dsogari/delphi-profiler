unit Profiler.Profile;

interface

uses
  System.Classes,
  System.Generics.Collections,
  System.SyncObjs,
  Profiler.Trace,
  Profiler.ProfileTracer,
  Winapi.Messages;

type

  TProfile = class(TThread)
    private
      FProfileTracer: ITracer;
      FTracerCreated: TEvent;
      FProfileFileName: string;
      FStatisticsFileName: string;
      FScopeFilterPattern: string;

      procedure SaveTracingProfileToFile;
      procedure SaveTracingStatisticsToFile;
      procedure Stop;

      class var FRegisteredProfiles: TList<TProfile>;
      class constructor Create;
      class destructor Destroy;

    protected
      procedure Execute; override;

    public
      constructor Create(const ProfileName: string; const DirectoryPath: string = '.');
      destructor Destroy; override;
      procedure SetScopeFilter(const Pattern: string);
      function Trace(const ScopeName: string): ITrace; overload;
      procedure Trace(const ScopeName: string; out Trace: ITrace); overload;
  end;

  THWndProfileTracer = class(TProfileTracer)
    private
      FWndHandle: THandle;
      FTraceQueue: TQueue<TTraceInfo>;

      procedure HandleMessage(var Message: TMessage);
      procedure HandleProcessQueue;

    protected
      procedure Log(const Info: TTraceInfo); override;

    public
      constructor Create;
      destructor Destroy; override;
  end;

implementation

uses
  System.SysUtils,
  Profiler.ScopedTrace,
  Winapi.Windows;

{ TProfile }

class constructor TProfile.Create;
begin
  FRegisteredProfiles := TObjectList<TProfile>.Create;
end;

class destructor TProfile.Destroy;
begin
  FRegisteredProfiles.Free;
end;

constructor TProfile.Create(const ProfileName, DirectoryPath: string);
begin
  FTracerCreated := TEvent.Create;
  FProfileFileName := IncludeTrailingPathDelimiter(DirectoryPath) + ProfileName + '-profile.csv';
  FStatisticsFileName := IncludeTrailingPathDelimiter(DirectoryPath) + ProfileName + '-stats.csv';
  FRegisteredProfiles.Add(Self);
  inherited Create(False);
end;

destructor TProfile.Destroy;
begin
  Stop;
  inherited;
  FTracerCreated.Free;
end;

procedure TProfile.Execute;
var
  Msg: TMsg;
begin
  FProfileTracer := THWndProfileTracer.Create;
  FTracerCreated.SetEvent;
  if not FScopeFilterPattern.IsEmpty then
    FProfileTracer.SetScopeFilter(FScopeFilterPattern);

  while GetMessage(Msg, 0, 0, 0) do
    begin
      TranslateMessage(Msg);
      DispatchMessage(Msg);
    end;

  SaveTracingProfileToFile;
  SaveTracingStatisticsToFile;
end;

procedure TProfile.Stop;
begin
  if not Terminated then
    begin
      PostThreadMessage(ThreadID, WM_QUIT, 0, 0);
      WaitFor;
    end;
end;

procedure TProfile.SaveTracingProfileToFile;
var
  Stream: TStream;
begin
  Stream := TFileStream.Create(FProfileFileName, fmCreate);
  try
    FProfileTracer.SaveProfileToStream(Stream);
  finally
    Stream.Free;
  end;
end;

procedure TProfile.SaveTracingStatisticsToFile;
var
  Stream: TStream;
begin
  Stream := TFileStream.Create(FStatisticsFileName, fmCreate);
  try
    FProfileTracer.SaveStatisticsToStream(Stream);
  finally
    Stream.Free;
  end;
end;

procedure TProfile.SetScopeFilter(const Pattern: string);
begin
  FTracerCreated.WaitFor;
  FProfileTracer.SetScopeFilter(Pattern);
end;

procedure TProfile.Trace(const ScopeName: string; out Trace: ITrace);
begin
  FTracerCreated.WaitFor;
  Trace := TScopedTrace.Create(FProfileTracer, ScopeName, True);
end;

function TProfile.Trace(const ScopeName: string): ITrace;
begin
  FTracerCreated.WaitFor;
  Result := TScopedTrace.Create(FProfileTracer, ScopeName, False);
end;

{ THWndProfileTracer }

constructor THWndProfileTracer.Create;
begin
  inherited;
  FWndHandle := AllocateHWnd(HandleMessage);
  FTraceQueue := TQueue<TTraceInfo>.Create;
end;

destructor THWndProfileTracer.Destroy;
begin
  DeallocateHWnd(FWndHandle);
  FTraceQueue.Free;
  inherited;
end;

procedure THWndProfileTracer.HandleMessage(var Message: TMessage);
begin
  if Message.Msg = WM_USER then
    HandleProcessQueue
  else
    DefaultHandler(Message);
end;

procedure THWndProfileTracer.HandleProcessQueue;
begin
  FCriticalSection.Acquire;
  try
    while FTraceQueue.Count > 0 do
      inherited Log(FTraceQueue.Dequeue);
  finally
    FCriticalSection.Release;
  end;
end;

procedure THWndProfileTracer.Log(const Info: TTraceInfo);
begin
  FCriticalSection.Acquire;
  try
    FTraceQueue.Enqueue(Info);
    if FTraceQueue.Count = 1 then
      PostMessage(FWndHandle, WM_USER, 0, 0);
  finally
    FCriticalSection.Release;
  end;
end;

end.
