unit Test.Profiler.ScopeInfo;

interface

uses
  DUnitX.TestFramework,
  Profiler.ScopeInfo;

type

  [TestFixture]
  TScopeInfoTest = class
    private
      FTScopeInfo: TScopeInfo;

    public
      [Setup]
      procedure Setup;
      [TearDown]
      procedure TearDown;

      [Test]
      [TestCase('Header', '"Scope Name","Total Calls","Total Time (us)","Avg. Time (us)"', ';')]
      procedure TestCommaHeader(const Expected: string);

      [Test]
      [TestCase('Single call', '1;2;"abc","1","0.20","0.20"', ';')]
      [TestCase('Two calls', '2;2;"abc","2","0.20","0.10"', ';')]
      procedure TestCommaText(TotalCalls, TotalTicks: Int64; const Expected: string);

      [Test]
      [TestCase('Single call', '1,2,0.20')]
      [TestCase('Two calls', '2,2,0.20')]
      procedure TestTotalMicroseconds(TotalCalls, TotalTicks: Int64; Expected: Double);

      [Test]
      [TestCase('Single call', '1,2,0.20')]
      [TestCase('Two calls', '2,2,0.10')]
      procedure TestAverageMicroseconds(TotalCalls, TotalTicks: Int64; Expected: Double);
  end;

implementation

{ TMyTestObject }

procedure TScopeInfoTest.Setup;
begin
  FTScopeInfo := TScopeInfo.Create('abc');
end;

procedure TScopeInfoTest.TearDown;
begin
  FTScopeInfo.Free;
end;

procedure TScopeInfoTest.TestAverageMicroseconds(TotalCalls, TotalTicks: Int64; Expected: Double);
begin
  FTScopeInfo.TotalCalls := TotalCalls;
  FTScopeInfo.TotalTicks := TotalTicks;
  Assert.AreEqual(Expected, FTScopeInfo.AverageMicroseconds);
end;

procedure TScopeInfoTest.TestCommaHeader(const Expected: string);
begin
  Assert.AreEqual(Expected, FTScopeInfo.CommaHeader);
end;

procedure TScopeInfoTest.TestCommaText(TotalCalls, TotalTicks: Int64; const Expected: string);
begin
  FTScopeInfo.TotalCalls := TotalCalls;
  FTScopeInfo.TotalTicks := TotalTicks;
  Assert.AreEqual(Expected, FTScopeInfo.CommaText);
end;

procedure TScopeInfoTest.TestTotalMicroseconds(TotalCalls, TotalTicks: Int64; Expected: Double);
begin
  FTScopeInfo.TotalCalls := TotalCalls;
  FTScopeInfo.TotalTicks := TotalTicks;
  Assert.AreEqual(Expected, FTScopeInfo.TotalMicroseconds);
end;

initialization

TDUnitX.RegisterTestFixture(TScopeInfoTest);

end.
