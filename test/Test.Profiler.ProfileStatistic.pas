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
      [TestCase('Single call', '1,2,3;"abc","2.000","2.000","1.000"', ';')]
      procedure TestCommaText(const ValuesText, Expected: string);

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

procedure TProfileStatisticTest.TestCommaText(const ValuesText, Expected: string);
var
  Values: TArray<Double>;
  Strings: TArray<string>;
  I: Integer;
begin
  Strings := ValuesText.Split([',']);
  SetLength(Values, Length(Strings));
  for I := Low(Strings) to High(Strings) do
    Values[I] := Strings[I].ToDouble;
  FProfileStatistic.Values := Values;
  Assert.AreEqual(Expected, FProfileStatistic.CommaText);
end;

end.
