unit Profiler.ProfileThread;

interface

uses
  System.Classes,
  System.Generics.Collections,
  System.SyncObjs,
  Profiler.Types,
  Profiler.ProfileTracer,
  Winapi.Messages;

type

  TProfileThread = class(TThread)
    private
      FProfileTracer: ITracer;
      FTracerCreated: TEvent;
      FPrefixPath: string;

      procedure SaveTracingProfileToFile;
      procedure SaveTracingStatisticsToFile;
      procedure Stop;

    protected
      procedure Execute; override;

    public
      constructor Create(const PrefixPath: string);
      destructor Destroy; override;
      procedure SetScopeFilter(const Pattern: string);
      function Trace(const ScopeName: string): IInterface; overload;
      procedure Trace(const ScopeName: string; out Trace: IInterface); overload;
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

{ TProfileThread }

constructor TProfileThread.Create(const PrefixPath: string);
begin
  FTracerCreated := TEvent.Create;
  FPrefixPath := PrefixPath;
  inherited Create(False);
end;

destructor TProfileThread.Destroy;
begin
  Stop;
  inherited;
  FTracerCreated.Free;
end;

procedure TProfileThread.Execute;
var
  Msg: TMsg;
begin
  FProfileTracer := THWndProfileTracer.Create;
  FTracerCreated.SetEvent;

  while GetMessage(Msg, 0, 0, 0) do
    begin
      TranslateMessage(Msg);
      DispatchMessage(Msg);
    end;

  SaveTracingProfileToFile;
  SaveTracingStatisticsToFile;
end;

procedure TProfileThread.Stop;
begin
  if not Terminated then
    begin
      PostThreadMessage(ThreadID, WM_QUIT, 0, 0);
      WaitFor;
    end;
end;

procedure TProfileThread.SaveTracingProfileToFile;
var
  Stream: TStream;
begin
  Stream := TFileStream.Create(FPrefixPath + '-profile.csv', fmCreate);
  try
    FProfileTracer.SaveProfileToStream(Stream);
  finally
    Stream.Free;
  end;
end;

procedure TProfileThread.SaveTracingStatisticsToFile;
var
  Stream: TStream;
begin
  Stream := TFileStream.Create(FPrefixPath + '-stats.csv', fmCreate);
  try
    FProfileTracer.SaveStatisticsToStream(Stream);
  finally
    Stream.Free;
  end;
end;

procedure TProfileThread.SetScopeFilter(const Pattern: string);
begin
  FTracerCreated.WaitFor;
  FProfileTracer.SetScopeFilter(Pattern);
end;

procedure TProfileThread.Trace(const ScopeName: string; out Trace: IInterface);
begin
  FTracerCreated.WaitFor;
  Trace := TScopedTrace.Create(FProfileTracer, ScopeName, True);
end;

function TProfileThread.Trace(const ScopeName: string): IInterface;
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
