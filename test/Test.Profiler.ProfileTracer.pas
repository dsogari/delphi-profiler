unit Test.Profiler.ProfileTracer;

interface

uses
  DUnitX.TestFramework,
  Delphi.Mocks,
  System.Classes,
  Profiler.Trace;

type

  [TestFixture]
  TProfileTracerTest = class
    private
      FTracer: ITracer;
      FTrace: TMock<ITrace>;
      FStream: TStringStream;
      FStrings: TStrings;

      procedure SetupTrace(const DelimitedExpectedCalls: string);
      procedure FeedTracer(const DelimitedTraceEvents: string);

    public
      [Setup]
      procedure Setup;
      [TearDown]
      procedure TearDown;

      [Test]
      [TestCase('Enter', 'abc,0,1;2,1,0;' +
            '"Scope","Total Calls","Total Time (us)","Avg. Time (us)"', ';')]
      [TestCase('Enter and leave', 'abc,0,1|abc,1,1;4,2,1;' +
            '"Scope","Total Calls","Total Time (us)","Avg. Time (us)"|' +
            '"abc","1","0.10","0.10"', ';')]
      [TestCase('Enter, enter and leave, leave', 'abc,0,1|def,0,2|def,1,3|abc,1,4;8,4,3;' +
            '"Scope","Total Calls","Total Time (us)","Avg. Time (us)"|' +
            '"abc","1","0.60","0.60"|' +
            '"def","1","0.30","0.30"', ';')]
      procedure TestLog(const DelimitedTraceEvents, DelimitedExpectedCalls,
        DelimitedExpectedProfile: string);

      [Test]
      [TestCase('Select first', 'a.*;abc,0,1|def,0,2|def,1,3|abc,1,4;6,2,1;' +
            '"Scope","Total Calls","Total Time (us)","Avg. Time (us)"|' +
            '"abc","1","0.40","0.40"', ';')]
      [TestCase('Select second', '^[^a]*;abc,0,1|def,0,2|def,1,3|abc,1,4;6,2,1;' +
            '"Scope","Total Calls","Total Time (us)","Avg. Time (us)"|' +
            '"def","1","0.30","0.30"', ';')]
      procedure TestSetScopeFilter(const Pattern, DelimitedTraceEvents, DelimitedExpectedCalls,
        DelimitedExpectedProfile: string);

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
  FStream := TStringStream.Create;
  FStrings := TStringList.Create;
  FStrings.Delimiter := '|';
  FStrings.QuoteChar := #0;
  FStrings.StrictDelimiter := True;
end;

procedure TProfileTracerTest.SetupTrace(const DelimitedExpectedCalls: string);
var
  Strings: TArray<string>;
begin
  Strings := DelimitedExpectedCalls.Split([',']);
  with FTrace.Setup do
    begin
      Expect.Exactly(Strings[0].ToInteger).When.GetEventName;
      Expect.Exactly(Strings[1].ToInteger).When.GetEventType;
      Expect.Exactly(Strings[2].ToInteger).When.GetElapsedTicks;
    end;
end;

procedure TProfileTracerTest.FeedTracer(const DelimitedTraceEvents: string);
var
  TraceEvents: TArray<string>;
  Strings: TArray<string>;
  S: string;
begin
  TraceEvents := DelimitedTraceEvents.Split(['|']);
  for S in TraceEvents do
    begin
      Strings := S.Split([',']);
      with FTrace.Setup do
        begin
          WillReturn(Strings[0]).When.GetEventName;
          WillReturn(TValue.From(TTraceEventType(Strings[1].ToInteger))).When.GetEventType;
          WillReturn(Strings[2].ToInt64).When.GetElapsedTicks;
        end;
      FTracer.Log(FTrace);
    end;
end;

procedure TProfileTracerTest.TearDown;
begin
  FTracer := nil;
  FTrace.Free;
  FStream.Free;
  FStrings.Free;
end;

procedure TProfileTracerTest.TestLog(const DelimitedTraceEvents, DelimitedExpectedCalls,
  DelimitedExpectedProfile: string);
begin
  SetupTrace(DelimitedExpectedCalls);
  FeedTracer(DelimitedTraceEvents);
  FStream.Clear;
  FTracer.SaveProfileToStream(FStream);
  FStrings.DelimitedText := DelimitedExpectedProfile;
  Assert.AreEqual(FStrings.Text, FStream.DataString);
  FTrace.VerifyAll;
end;

procedure TProfileTracerTest.TestSetScopeFilter(const Pattern, DelimitedTraceEvents,
  DelimitedExpectedCalls, DelimitedExpectedProfile: string);
begin
  FTracer.SetScopeFilter(Pattern);
  SetupTrace(DelimitedExpectedCalls);
  FeedTracer(DelimitedTraceEvents);
  FStream.Clear;
  FTracer.SaveProfileToStream(FStream);
  FStrings.DelimitedText := DelimitedExpectedProfile;
  Assert.AreEqual(FStrings.Text, FStream.DataString);
  FTrace.VerifyAll;
end;

end.
