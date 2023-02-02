# delphi-profiler

![Profile Viewer Screen](/docs/images/profile_viewer.png "Profile at the top, statistics at the bottom")

A tracing profiler for Delphi.

## Example

```delphi
program ProfilerClientTest;

uses
  System.SysUtils,
  Profiler.Trace;

procedure Innermost;
begin
  Trace('Innermost');
  Sleep(150);
end;

procedure Inner;
begin
  Trace('Inner');
  Sleep(50);
  Innermost;
  Sleep(50);
  Innermost;
  Sleep(50);
end;

procedure Outter;
begin
  Trace('Outter');
  Sleep(50);
  Inner;
  Sleep(50);
  Inner;
  Sleep(50);
end;

procedure Outtermost;
begin
  Trace('Outtermost');
  Sleep(50);
  Outter;
  Sleep(50);
  Outter;
  Sleep(50);
end;

begin
  Outtermost;
end.
```

Output file `profile.csv` (entries are sorted in descending order of total time):

    "Scope Name","Total Calls","Total Time (us)","Avg. Time (us)"
    "Innermost","8","1239718.80","154964.85"
    "Inner","4","746702.50","186675.63"
    "Outter","2","376405.50","188202.75"
    "Outtermost","1","187056.80","187056.80"

Output file `stats.csv`:

    "Measure","Mean","Median","Standard Dev."
    "Total Calls","3.75","3.00","3.10"
    "Total Time (us)","637470.90","561554.00","463918.84"
    "Avg. Time (us)","179225.01","186866.21","16186.45"
