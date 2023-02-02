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

    "Scope","Total Calls","Total Time (us)","Avg. Time (us)"
    "Outter","10","2185955.30","218595.53"
    "Inner","10","1083201.10","108320.11"

Output file `stats.csv`:

    "Measure","Mean","Median","Standard Dev."
    "Total Calls","10.00","10.00","0.00"
    "Total Time (us)","1634578.20","1634578.20","779764.97"
    "Avg. Time (us)","163457.82","163457.82","77976.50"
