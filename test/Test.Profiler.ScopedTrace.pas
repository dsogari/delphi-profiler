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

      function Trace(const ScopeName: ShortString): ITrace;

    public
      [Setup]
      procedure Setup;
      [TearDown]
      procedure TearDown;

      [Test]
      [TestCase('Once', '1')]
      [TestCase('Twice', '2')]
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

function TScopedTraceTest.Trace(const ScopeName: ShortString): ITrace;
begin
  Result := TScopedTrace.Create(ScopeName, FTracer);
end;

procedure TScopedTraceTest.TestTrace(Times: Integer);
var
  I: Integer;
begin
  FTracer.Setup.Expect.Exactly('Log', Times * 2);
  for I := 1 to Times do
    begin
      Trace('TScopedTraceTest.TestTrace');
    end;
  Assert.WillNotRaise(
      procedure
    begin
      FTracer.VerifyAll;
    end);
end;

initialization

TDUnitX.RegisterTestFixture(TScopedTraceTest);

end.
