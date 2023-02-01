unit Profiler.ScopedTrace;

interface

uses
  Profiler.DataTypes;

type

  TScopedTrace = class(TInterfacedObject, ITrace)
    private
      FEventName: string;
      FEventType: TTraceEventType;

      class threadvar m_nElapsed: Int64;
      class threadvar m_nStartTimeStamp: Int64;

    private { ITrace }
      function GetEventName: string;
      function GetEventType: TTraceEventType;
      function GetElapsedTicks: Int64;

    public
      class function NewInstance: TObject; override;
      procedure FreeInstance; override;
      function _AddRef: Integer; stdcall;
      function _Release: Integer; stdcall;

      constructor Create(const strScopeName: ShortString);
      destructor Destroy; override;
  end;

implementation

uses
  System.Diagnostics;

class function TScopedTrace.NewInstance: TObject;
begin
  m_nElapsed := TStopwatch.GetTimeStamp - m_nStartTimeStamp;
  Result     := inherited;
end;

procedure TScopedTrace.FreeInstance;
begin
  inherited;
  m_nStartTimeStamp := TStopwatch.GetTimeStamp;
end;

function TScopedTrace._AddRef: Integer;
begin
  Result              := inherited;
  if FRefCount = 1 then
    m_nStartTimeStamp := TStopwatch.GetTimeStamp;
end;

function TScopedTrace._Release: Integer;
begin
  if FRefCount = 1 then
    m_nElapsed := TStopwatch.GetTimeStamp - m_nStartTimeStamp;
  Result       := inherited;
end;

constructor TScopedTrace.Create(const strScopeName: ShortString);
begin
  FEventName := string(strScopeName);
  FEventType := TTraceEventType.Enter;
  GlobalTracer.Log(Self);
end;

destructor TScopedTrace.Destroy;
begin
  FEventType := TTraceEventType.Leave;
  GlobalTracer.Log(Self);
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
  Result := m_nElapsed;
end;

initialization

TStopwatch.Create; // initialize the stopwatch variables

end.
