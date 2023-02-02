unit Test.Profiler.ProfileTracer;

interface

uses
  DUnitX.TestFramework,
  Delphi.Mocks,
  Profiler.Trace;

type

  [TestFixture]
  TProfileTracerTest = class
    private
      FTracer: ITracer;
      FTrace: TMock<ITrace>;

    public
      [Setup]
      procedure Setup;
      [TearDown]
      procedure TearDown;

      [Test]
      [TestCase('Enter', 'abc,0,1;1,1,0', ';')]
      [TestCase('Enter and leave', 'abc,0,1|abc,1,1;1,1,0|1,1,1', ';')]
      procedure TestLog(const DelimitedTraceEvents, DelimitedExpectedCalls: string);

  end;

implementation

uses
  System.Rtti,
  System.SysUtils,
  Profiler.ProfileTracer;

{ TProfileTracerTest }

procedure TProfileTracerTest.Setup;
begin
  FTracer := TProfileTracer.Create;
  FTrace := TMock<ITrace>.Create;
  FTrace.Setup.AllowRedefineBehaviorDefinitions := True;
end;

procedure TProfileTracerTest.TearDown;
begin
  FTracer := nil;
  FTrace.Free;
end;

procedure TProfileTracerTest.TestLog(const DelimitedTraceEvents, DelimitedExpectedCalls: string);
var
  TraceEvents, ExpectedCalls, Strings: TArray<string>;
  I: Integer;
begin
  TraceEvents := DelimitedTraceEvents.Split(['|']);
  ExpectedCalls := DelimitedExpectedCalls.Split(['|']);
  for I := Low(TraceEvents) to High(TraceEvents) do
    begin
      with FTrace.Setup do
        begin
          Strings := TraceEvents[I].Split([',']);
          WillReturn(Strings[0]).When.GetEventName;
          WillReturn(TValue.From(TTraceEventType(Strings[1].ToInteger))).When.GetEventType;
          WillReturn(Strings[2].ToInt64).When.GetElapsedTicks;

          Strings := ExpectedCalls[I].Split([',']);
          Expect.Exactly(Strings[0].ToInteger).When.GetEventName;
          Expect.Exactly(Strings[1].ToInteger).When.GetEventType;
          Expect.Exactly(Strings[2].ToInteger).When.GetElapsedTicks;
        end;

      FTracer.Log(FTrace);
    end;

  Assert.WillNotRaise(
      procedure
    begin
      FTrace.VerifyAll;
    end);
end;

end.
