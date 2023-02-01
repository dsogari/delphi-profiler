unit Test.Profiler.ProfileInfo;

interface

uses
  DUnitX.TestFramework,
  Profiler.ProfileInfo;

type

  [TestFixture]
  TMyTestObject = class
    private
      FTProfileInfo: TProfileInfo;

    public
      [Setup]
      procedure Setup;
      [TearDown]
      procedure TearDown;

      [Test]
      [TestCase('Header', '"Function","Total Calls","Total Time (us)","Average Time (us)"', ';')]
      procedure TestCommaHeader(const Expected: string);

      [Test]
      [TestCase('Single call', '1;2;"abc","1","0.2","0.200"', ';')]
      procedure TestCommaText(TotalCalls, TotalTicks: Int64; const Expected: string);

      [Test]
      [TestCase('Single call', '1,2,0.2')]
      procedure TestTotalMicroseconds(TotalCalls, TotalTicks: Int64; Expected: Double);

      [Test]
      [TestCase('Single call', '1,2,0.2')]
      procedure TestAverageMicroseconds(TotalCalls, TotalTicks: Int64; Expected: Double);
  end;

implementation

{ TMyTestObject }

procedure TMyTestObject.Setup;
begin
  FTProfileInfo := TProfileInfo.Create('abc');
end;

procedure TMyTestObject.TearDown;
begin
  FTProfileInfo.Free;
end;

procedure TMyTestObject.TestAverageMicroseconds(TotalCalls, TotalTicks: Int64; Expected: Double);
begin
  FTProfileInfo.TotalCalls := TotalCalls;
  FTProfileInfo.TotalTicks := TotalTicks;
  Assert.AreEqual(Expected, FTProfileInfo.AverageMicroseconds);
end;

procedure TMyTestObject.TestCommaHeader(const Expected: string);
begin
  Assert.AreEqual(Expected, FTProfileInfo.CommaHeader);
end;

procedure TMyTestObject.TestCommaText(TotalCalls, TotalTicks: Int64; const Expected: string);
begin
  FTProfileInfo.TotalCalls := TotalCalls;
  FTProfileInfo.TotalTicks := TotalTicks;
  Assert.AreEqual(Expected, FTProfileInfo.CommaText);
end;

procedure TMyTestObject.TestTotalMicroseconds(TotalCalls, TotalTicks: Int64; Expected: Double);
begin
  FTProfileInfo.TotalCalls := TotalCalls;
  FTProfileInfo.TotalTicks := TotalTicks;
  Assert.AreEqual(Expected, FTProfileInfo.TotalMicroseconds);
end;

initialization

TDUnitX.RegisterTestFixture(TMyTestObject);

end.
