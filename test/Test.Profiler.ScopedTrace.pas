unit Test.Profiler.ScopedTrace;

interface

uses
  DUnitX.TestFramework,
  Delphi.Mocks,
  Profiler.Types;

type

  [TestFixture]
  TScopedTraceTest = class(TObject)
    private
      FTracer: TMock<ITracer>;

      function Trace(const ScopeName: string; IsLongLived: Boolean): IInterface;
      class function CheckTrace(Info: TTraceInfo): Boolean;

    public
      [Setup]
      procedure Setup;
      [TearDown]
      procedure TearDown;

      [Test]
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

function TScopedTraceTest.Trace(const ScopeName: string; IsLongLived: Boolean): IInterface;
begin
  Result := TScopedTrace.Create(FTracer, ScopeName, IsLongLived);
end;

class function TScopedTraceTest.CheckTrace(Info: TTraceInfo): Boolean;
begin
  Result := (Info.FTraceID > 0) and (Info.FScopeName = 'Test') and
    ((Info.FEventType = TTraceType.Enter) or (Info.FElapsedTicks < 10));
end;

procedure TScopedTraceTest.TestTrace(Times: Integer; IsLongLived: Boolean);
var
  I: Integer;
begin
  FTracer.Setup.Expect.Exactly(2 * Times).When.Log(It0.Matches<TTraceInfo>(CheckTrace));

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
