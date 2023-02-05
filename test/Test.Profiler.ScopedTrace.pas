unit Test.Profiler.ScopedTrace;

interface

uses
  DUnitX.TestFramework,
  Delphi.Mocks,
  Profiler.Trace;

type

  [TestFixture]
  TScopedTraceTest = class(TObject)
    private
      FTracer: TMock<ITracer>;

      function Trace(const ScopeName: string; IsLongLived: Boolean): ITrace;
      class function CheckEventEnter(Info: TTraceInfo): Boolean;
      class function CheckEventLeave(Info: TTraceInfo): Boolean;

    public
      [Setup]
      procedure Setup;
      [TearDown]
      procedure TearDown;

      [Test(False)]
      [TestCase('Once', '1,False')]
      [TestCase('Twice', '2,False')]
      [TestCase('Hundred times', '100,False')]
      [TestCase('Once (long-lived)', '1,True')]
      [TestCase('Twice (long-lived', '2,True')]
      [TestCase('Hundred times (long-lived', '100,True')]
      procedure TestTrace(Times: Integer; IsLongLived: Boolean);
  end;

implementation

uses
  Profiler.ScopedTrace;

procedure TScopedTraceTest.Setup;
begin
  FTracer := TMock<ITracer>.Create;
end;

procedure TScopedTraceTest.TearDown;
begin
  FTracer.Free;
end;

function TScopedTraceTest.Trace(const ScopeName: string; IsLongLived: Boolean): ITrace;
begin
  Result := TScopedTrace.Create(FTracer, ScopeName, IsLongLived);
end;

class function TScopedTraceTest.CheckEventEnter(Info: TTraceInfo): Boolean;
begin
  Result := (Info.FTraceID > 0) and (Info.FScopeName = 'Test') and
    (Info.FEventType = TTraceEventType.Enter);
end;

class function TScopedTraceTest.CheckEventLeave(Info: TTraceInfo): Boolean;
begin
  Result := (Info.FTraceID > 0) and (Info.FScopeName = 'Test') and
    (Info.FEventType = TTraceEventType.Leave) and (Info.FElapsedTicks < 5);
end;

procedure TScopedTraceTest.TestTrace(Times: Integer; IsLongLived: Boolean);
var
  Info1, Info2: TTraceInfo;
  I: Integer;
begin
  with FTracer.Setup do
    begin
      Info1 := It0.Matches<TTraceInfo>(CheckEventEnter);
      Info2 := It0.Matches<TTraceInfo>(CheckEventLeave);
      Expect.Exactly(Times).When.Log(Info1);
      Expect.Exactly(Times).When.Log(Info2);
    end;

  for I := 1 to Times do
    Trace('Test', IsLongLived);

  Assert.WillNotRaise(
      procedure
    begin
      FTracer.VerifyAll;
    end);
end;

initialization

TDUnitX.RegisterTestFixture(TScopedTraceTest);

end.
