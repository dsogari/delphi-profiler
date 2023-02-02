unit Test.Profiler.ProfileStatistic;

interface

uses
  DUnitX.TestFramework,
  Profiler.ProfileStatistic;

type

  [TestFixture]
  TProfileStatisticTest = class
    private
      FProfileStatistic: TProfileStatistic;

    public
      [Setup]
      procedure Setup;
      [TearDown]
      procedure TearDown;

      [Test]
      [TestCase('Header', '"Measure","Mean","Median","Standard Deviation"', ';')]
      procedure TestCommaHeader(const Expected: string);

      [Test]
      [TestCase('Single element', '1;"abc","1.00","1.00","1.00"', ';')]
      [TestCase('Two elements', '1,2;"abc","1.50","1.50","0.71"', ';')]
      [TestCase('Three elements', '1,2,3;"abc","2.00","2.00","1.00"', ';')]
      procedure TestCommaText(const DelimitedValues, Expected: string);

  end;

implementation

uses
  System.SysUtils;

{ TProfileStatisticTest }

procedure TProfileStatisticTest.Setup;
begin
  FProfileStatistic := TProfileStatistic.Create('abc');
end;

procedure TProfileStatisticTest.TearDown;
begin
  FProfileStatistic.Free;
end;

procedure TProfileStatisticTest.TestCommaHeader(const Expected: string);
begin
  Assert.AreEqual(Expected, FProfileStatistic.CommaHeader);
end;

procedure TProfileStatisticTest.TestCommaText(const DelimitedValues, Expected: string);
var
  Values: TArray<Double>;
  Strings: TArray<string>;
  I: Integer;
begin
  Strings := DelimitedValues.Split([',']);
  SetLength(Values, Length(Strings));
  for I := Low(Strings) to High(Strings) do
    Values[I] := Strings[I].ToDouble;
  FProfileStatistic.Values := Values;
  Assert.AreEqual(Expected, FProfileStatistic.CommaText);
end;

end.
