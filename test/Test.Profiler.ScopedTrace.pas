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

      function Trace(const ScopeName: string): ITrace;
      class function CheckEventEnter(Trace: ITrace): Boolean;
      class function CheckEventLeave(Trace: ITrace): Boolean;

    public
      [Setup]
      procedure Setup;
      [TearDown]
      procedure TearDown;

      [Test]
      [TestCase('Once', '1')]
      [TestCase('Twice', '2')]
      [TestCase('Hundred times', '100')]
      procedure TestTrace(Times: Integer);
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

function TScopedTraceTest.Trace(const ScopeName: string): ITrace;
begin
  Result := TScopedTrace.Create(ScopeName, FTracer);
end;

class function TScopedTraceTest.CheckEventEnter(Trace: ITrace): Boolean;
begin
  Result := Assigned(Trace) and (Trace.EventType = TTraceEventType.Enter);
end;

class function TScopedTraceTest.CheckEventLeave(Trace: ITrace): Boolean;
begin
  Result := Assigned(Trace) and
    (Trace.EventType = TTraceEventType.Leave) and (Trace.ElapsedTicks < 5);
end;

procedure TScopedTraceTest.TestTrace(Times: Integer);
var
  I: Integer;
begin
  with FTracer.Setup do
    begin
      Expect.Exactly(Times).When.Log(It0.Matches<ITrace>(CheckEventEnter));
      Expect.Exactly(Times).When.Log(It0.Matches<ITrace>(CheckEventLeave));
    end;

  for I := 1 to Times do
    Trace('TScopedTraceTest.TestTrace');

  Assert.WillNotRaise(
      procedure
    begin
      FTracer.VerifyAll;
    end);
end;

initialization

TDUnitX.RegisterTestFixture(TScopedTraceTest);

end.
