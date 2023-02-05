unit Test.Profiler.ProfileTracer;

interface

uses
  DUnitX.TestFramework,
  System.Classes,
  Profiler.Trace;

type

  [TestFixture]
  TProfileTracerTest = class
    private
      FTracer: ITracer;
      FStream: TStringStream;
      FStrings: TStrings;

      procedure FeedTracer(const DelimitedTraceEvents: string);

    public
      [Setup]
      procedure Setup;
      [TearDown]
      procedure TearDown;

      [Test]
      [TestCase('Enter',
          'abc,0,1,False;' +
            '"Scope Name","Total Calls","Total Time (us)","Avg. Time (us)"', ';')]
      [TestCase('Enter and leave',
          'abc,0,1,False|abc,1,1,False;' +
            '"Scope Name","Total Calls","Total Time (us)","Avg. Time (us)"|' +
            '"abc","1","0.10","0.10"', ';')]
      [TestCase('Enter, enter and leave, leave',
          'abc,0,1,False|def,0,2,False|def,1,3,False|abc,1,4,False;' +
            '"Scope Name","Total Calls","Total Time (us)","Avg. Time (us)"|' +
            '"abc","1","0.60","0.60"|' +
            '"def","1","0.30","0.30"', ';')]
      [TestCase('Enter, enter (long-lived), enter and leave, leave (long-lived), leave',
          'abc,0,1,False|def,0,2,True|ghi,0,3,False|' +
            'ghi,1,4,False|def,1,5,True|abc,1,6,False;' +
            '"Scope Name","Total Calls","Total Time (us)","Avg. Time (us)"|' +
            '"abc","1","0.90","0.90"|' +
            '"def","1","0.50","0.50"|' +
            '"ghi","1","0.40","0.40"', ';')]
      procedure TestLog(const DelimitedTraceEvents, DelimitedExpectedProfile: string);

      [Test]
      [TestCase('Select first',
          'a.*;abc,0,1,False|def,0,2,False|def,1,3,False|abc,1,4,False;' +
            '"Scope Name","Total Calls","Total Time (us)","Avg. Time (us)"|' +
            '"abc","1","0.40","0.40"', ';')]
      [TestCase('Select second',
          '^[^a]*;abc,0,1,False|def,0,2,False|def,1,3,False|abc,1,4,False;' +
            '"Scope Name","Total Calls","Total Time (us)","Avg. Time (us)"|' +
            '"def","1","0.30","0.30"', ';')]
      [TestCase('Enter, enter (long-lived), enter and leave, leave (long-lived), leave',
          '^[^d]*;abc,0,1,False|def,0,2,True|ghi,0,3,False|' +
            'ghi,1,4,False|def,1,5,True|abc,1,6,False;' +
            '"Scope Name","Total Calls","Total Time (us)","Avg. Time (us)"|' +
            '"abc","1","0.90","0.90"|' +
            '"ghi","1","0.40","0.40"', ';')]
      procedure TestSetScopeFilter(const Pattern, DelimitedTraceEvents,
        DelimitedExpectedProfile: string);

  end;

implementation

uses
  System.SysUtils,
  Profiler.ProfileTracer;

{ TProfileTracerTest }

procedure TProfileTracerTest.Setup;
begin
  FTracer := TProfileTracer.Create;
  FStream := TStringStream.Create;
  FStrings := TStringList.Create;
  FStrings.Delimiter := '|';
  FStrings.QuoteChar := #0;
  FStrings.StrictDelimiter := True;
end;

procedure TProfileTracerTest.FeedTracer(const DelimitedTraceEvents: string);
var
  TraceEvents: TArray<string>;
  Strings: TArray<string>;
  S: string;
  Info: TTraceInfo;
begin
  TraceEvents := DelimitedTraceEvents.Split(['|']);
  for S in TraceEvents do
    begin
      Strings := S.Split([',']);
      Info.FScopeName := Strings[0];
      Info.FEventType := TTraceEventType(Strings[1].ToInteger);
      Info.FElapsedTicks := Strings[2].ToInt64;
      Info.FIsLongLived := Strings[3].ToBoolean;
      FTracer.Log(Info);
    end;
end;

procedure TProfileTracerTest.TearDown;
begin
  FTracer := nil;
  FStream.Free;
  FStrings.Free;
end;

procedure TProfileTracerTest.TestLog(const DelimitedTraceEvents, DelimitedExpectedProfile: string);
begin
  FeedTracer(DelimitedTraceEvents);
  FStream.Clear;
  FTracer.SaveProfileToStream(FStream);
  FStrings.DelimitedText := DelimitedExpectedProfile;
  Assert.AreEqual(FStrings.Text, FStream.DataString);
end;

procedure TProfileTracerTest.TestSetScopeFilter(const Pattern, DelimitedTraceEvents,
  DelimitedExpectedProfile: string);
begin
  FTracer.SetScopeFilter(Pattern);
  FeedTracer(DelimitedTraceEvents);
  FStream.Clear;
  FTracer.SaveProfileToStream(FStream);
  FStrings.DelimitedText := DelimitedExpectedProfile;
  Assert.AreEqual(FStrings.Text, FStream.DataString);
end;

end.
