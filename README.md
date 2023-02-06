# delphi-profiler

![Profile Viewer Screen](/docs/images/profile_viewer.png "Profile at the top, statistics at the bottom")

A tracing profiler for Delphi.

## Example

```delphi
program ProfilerClientTest;

uses
  System.SysUtils,
  Delphi.Profiler;

var
  LongLived: IInterface;

procedure Innermost;
begin
  Trace('Innermost');
  Sleep(50);
  LongLived := nil;
  Sleep(100);
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
  Trace('LongLived', LongLived);
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
    "Innermost","8","1358899.90","169862.49"
    "Inner","4","746657.20","186664.30"
    "Outter","2","363359.80","181679.90"
    "Outtermost","1","183030.00","183030.00"
    "LongLived","1","179745.10","179745.10"

Output file `stats.csv`:

    "Measure","Mean","Median","Standard Dev."
    "Total Calls","3.20","2.00","2.95"
    "Total Time (us)","566338.40","363359.80","499561.96"
    "Avg. Time (us)","180196.36","181679.90","6305.89"
