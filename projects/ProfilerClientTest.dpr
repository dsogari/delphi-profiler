program ProfilerClientTest;

{$APPTYPE CONSOLE}

{$R *.res}


uses
  System.SysUtils,
  Profiler.Trace;

var
  LongLived: ITrace;

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
  try
    Outtermost;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;

end.
