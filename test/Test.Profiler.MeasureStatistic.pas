unit Test.Profiler.MeasureStatistic;

interface

uses
  DUnitX.TestFramework,
  Profiler.MeasureStatistic;

type

  [TestFixture]
  TMeasureStatisticTest = class
    private
      FMeasureStatistic: TMeasureStatistic;

    public
      [Setup]
      procedure Setup;
      [TearDown]
      procedure TearDown;

      [Test]
      [TestCase('Header', '"Measure","Mean","Median","Standard Dev."', ';')]
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

{ TMeasureStatisticTest }

procedure TMeasureStatisticTest.Setup;
begin
  FMeasureStatistic := TMeasureStatistic.Create('abc');
end;

procedure TMeasureStatisticTest.TearDown;
begin
  FMeasureStatistic.Free;
end;

procedure TMeasureStatisticTest.TestCommaHeader(const Expected: string);
begin
  Assert.AreEqual(Expected, FMeasureStatistic.CommaHeader);
end;

procedure TMeasureStatisticTest.TestCommaText(const DelimitedValues, Expected: string);
var
  Values: TArray<Double>;
  Strings: TArray<string>;
  I: Integer;
begin
  Strings := DelimitedValues.Split([',']);
  SetLength(Values, Length(Strings));
  for I := Low(Strings) to High(Strings) do
    Values[I] := Strings[I].ToDouble;
  FMeasureStatistic.Values := Values;
  Assert.AreEqual(Expected, FMeasureStatistic.CommaText);
end;

end.
