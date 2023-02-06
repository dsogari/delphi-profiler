unit Profiler.Types;

{$SCOPEDENUMS ON}
{$M+}

interface

uses
  System.Classes;

type

  /// The type of trace event
  TTraceType = (Enter, Leave);

  /// The trace event information
  TTraceInfo = record
    /// The trace unique ID
    FTraceID: Int64;

    /// The trace scope name
    FScopeName: string;

    /// The trace event type (entering or leaving a scope)
    FEventType: TTraceType;

    /// The trace duration (in number of clock ticks)
    FElapsedTicks: Int64;

    /// True if the trace event is long-lived (instead of block-scoped)
    FIsLongLived: Boolean;
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

implementation

end.
