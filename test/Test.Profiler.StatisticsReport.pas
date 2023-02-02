unit Test.Profiler.StatisticsReport;

interface

uses
  DUnitX.TestFramework,
  System.Classes,
  Profiler.StatisticsReport,
  Profiler.ProfileInfo;

type

  [TestFixture]
  TStatisticsReportTest = class
    private
      FStatisticsReport: TStatisticsReport;
      FProfileInfo: TProfileInfo;
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
            '"Measure","Mean","Median","Standard Deviation"|' +
            '"Total Calls","NAN","NAN","NAN"|' +
            '"Total Time (us)","NAN","NAN","NAN"|' +
            '"Average Time (us)","NAN","NAN","NAN"', ';')]
      procedure TestClear(const DelimitedInfos, DelimitedExpected: string);

      [Test]
      [TestCase('Two infos', '1,2|3,4;' +
            '"Measure","Mean","Median","Standard Deviation"|' +
            '"Total Calls","2.00","2.00","1.41"|' +
            '"Total Time (us)","0.30","0.30","0.14"|' +
            '"Average Time (us)","0.17","0.17","0.05"', ';')]
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
      FProfileInfo.TotalCalls := Strings[0].ToInt64;
      FProfileInfo.TotalTicks := Strings[1].ToInt64;
      FStatisticsReport.Add(FProfileInfo);
    end;
end;

procedure TStatisticsReportTest.Setup;
begin
  FStatisticsReport := TStatisticsReport.Create;
  FProfileInfo := TProfileInfo.Create('abc');
  FStream := TStringStream.Create;
  FStrings := TStringList.Create;
  FStrings.Delimiter := '|';
  FStrings.QuoteChar := #0;
  FStrings.StrictDelimiter := True;
end;

procedure TStatisticsReportTest.TearDown;
begin
  FStatisticsReport.Free;
  FProfileInfo.Free;
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
