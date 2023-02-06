unit Test.Profiler.StatisticsReport;

interface

uses
  DUnitX.TestFramework,
  System.Classes,
  Profiler.StatisticsReport,
  Profiler.ScopeInfo;

type

  [TestFixture]
  TStatisticsReportTest = class
    private
      FStatisticsReport: TStatisticsReport;
      FScopeInfo: TScopeInfo;
      FStream: TStringStream;
      FStrings: TStrings;

      procedure FillReport(const DelimitedInfos: string);

    public
      [Setup]
      procedure Setup;
      [TearDown]
      procedure TearDown;

      [Test]
      [TestCase('Two infos', '1,2|3,4;' +
            '"Measure","Mean","Median","Standard Dev."|' +
            '"Total Calls","NAN","NAN","NAN"|' +
            '"Total Time (us)","NAN","NAN","NAN"|' +
            '"Avg. Time (us)","NAN","NAN","NAN"', ';')]
      procedure TestClear(const DelimitedInfos, DelimitedExpected: string);

      [Test]
      [TestCase('Two infos', '1,2|3,4;' +
            '"Measure","Mean","Median","Standard Dev."|' +
            '"Total Calls","2.00","2.00","1.41"|' +
            '"Total Time (us)","0.30","0.30","0.14"|' +
            '"Avg. Time (us)","0.17","0.17","0.05"', ';')]
      procedure TestSaveToStream(const DelimitedInfos, DelimitedExpected: string);

  end;

implementation

uses
  System.SysUtils;

{ TStatisticsReportTest }

procedure TStatisticsReportTest.FillReport(const DelimitedInfos: string);
var
  Strings: TArray<string>;
  S: string;
begin
  for S in DelimitedInfos.Split(['|']) do
    begin
      Strings := S.Split([',']);
      FScopeInfo.TotalCalls := Strings[0].ToInt64;
      FScopeInfo.TotalTicks := Strings[1].ToInt64;
      FStatisticsReport.Add(FScopeInfo);
    end;
end;

procedure TStatisticsReportTest.Setup;
begin
  FStatisticsReport := TStatisticsReport.Create;
  FScopeInfo := TScopeInfo.Create('abc');
  FStream := TStringStream.Create;
  FStrings := TStringList.Create;
  FStrings.Delimiter := '|';
  FStrings.QuoteChar := #0;
  FStrings.StrictDelimiter := True;
end;

procedure TStatisticsReportTest.TearDown;
begin
  FStatisticsReport.Free;
  FScopeInfo.Free;
  FStream.Free;
  FStrings.Free;
end;

procedure TStatisticsReportTest.TestClear(const DelimitedInfos, DelimitedExpected: string);
begin
  FillReport(DelimitedInfos);
  FStatisticsReport.Clear;
  FStatisticsReport.Compute;
  FStream.Clear;
  FStatisticsReport.SaveToStream(FStream);
  FStrings.DelimitedText := DelimitedExpected;
  Assert.AreEqual(FStrings.Text, FStream.DataString);
end;

procedure TStatisticsReportTest.TestSaveToStream(const DelimitedInfos, DelimitedExpected: string);
begin
  FillReport(DelimitedInfos);
  FStatisticsReport.Compute;
  FStream.Clear;
  FStatisticsReport.SaveToStream(FStream);
  FStrings.DelimitedText := DelimitedExpected;
  Assert.AreEqual(FStrings.Text, FStream.DataString);
end;

end.
