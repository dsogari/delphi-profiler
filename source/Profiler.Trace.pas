/// This is the entrypoint unit for tracing
unit Profiler.Trace;

{$SCOPEDENUMS ON}
{$M+}

interface

uses
  System.Classes;

type

  /// The type of trace event
  TTraceEventType = (Enter, Leave);

  /// The trace event information
  TTraceInfo = record
    /// The trace unique ID
    FTraceID: Int64;

    /// The trace scope name
    FScopeName: string;

    /// The trace event type (entering or leaving a scope)
    FEventType: TTraceEventType;

    /// The trace duration (in number of clock ticks)
    FElapsedTicks: Int64;

    /// True if the trace event is long-lived (instead of block-scoped)
    FIsLongLived: Boolean;
  end;

  /// The trace event object
  ITrace = interface
    /// Returns the trace event information
    function GetInfo: TTraceInfo;

    property Info: TTraceInfo read GetInfo;
  end;

  /// The tracer object (keeps track of trace events)
  ITracer = interface
    /// Clear the trace event history
    procedure ClearHistory;

    /// Log a trace event
    procedure Log(const Info: TTraceInfo);

    /// Set a pattern for filtering scope names
    procedure SetScopeFilter(const Pattern: string);

    /// Save the profile report to an output stream
    procedure SaveProfileToStream(Stream: TStream);

    /// Save the statistics report to an output stream
    procedure SaveStatisticsToStream(Stream: TStream);
  end;

/// Set a pattern to filter scope names in the default profile
procedure SetScopeFilter(const Pattern: string);

/// Generate a block-scoped trace event in the default profile
function Trace(const ScopeName: string): ITrace; overload;

/// Generate a long-lived trace event in the default profile
procedure Trace(const ScopeName: string; out Trace: ITrace); overload;

implementation

uses
  Profiler.Profile;

var
  DefaultProfile: TProfile;

procedure InitializeDefaultProfile;
begin
  if not Assigned(DefaultProfile) then
    DefaultProfile := TProfile.Create('default');
end;

procedure SetScopeFilter(const Pattern: string);
begin
  InitializeDefaultProfile;
  DefaultProfile.SetScopeFilter(Pattern);
end;

function Trace(const ScopeName: string): ITrace;
begin
  InitializeDefaultProfile;
  Result := DefaultProfile.Trace(ScopeName);
end;

procedure Trace(const ScopeName: string; out Trace: ITrace);
begin
  InitializeDefaultProfile;
  DefaultProfile.Trace(ScopeName, Trace);
end;

end.
