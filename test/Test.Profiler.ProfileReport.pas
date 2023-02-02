unit Test.Profiler.ProfileReport;

interface

uses
  DUnitX.TestFramework,
  System.Classes,
  Profiler.ProfileReport;

type

  [TestFixture]
  TProfileReportTest = class
    private
      FProfileReport: TProfileReport;
      FReportStream: TStringStream;
      FDummyStream: TStringStream;
      FStrings: TStrings;

      procedure FillReport(const DelimitedInput: string);

    public
      [Setup]
      procedure Setup;
      [TearDown]
      procedure TearDown;

      [Test]
      [TestCase('Two inputs', 'abc,2|def,4;' +
            '"Function","Total Calls","Total Time (us)","Average Time (us)"|' +
            '"def","1","0.4","0.400"|' +
            '"abc","1","0.2","0.200"', ';')]
      procedure TestSaveToStream(const DelimitedInput, DelimitedExpected: string);

  end;

implementation

uses
  System.SysUtils;

{ TProfileReportTest }

procedure TProfileReportTest.FillReport(const DelimitedInput: string);
var
  Strings: TArray<string>;
  S: string;
begin
  for S in DelimitedInput.Split(['|']) do
    begin
      Strings := S.Split([',']);
      FProfileReport.Add(Strings[0], Strings[1].ToInt64);
    end;
end;

procedure TProfileReportTest.Setup;
begin
  FProfileReport := TProfileReport.Create;
  FReportStream := TStringStream.Create;
  FDummyStream := TStringStream.Create;
  FStrings := TStringList.Create;
  FStrings.Delimiter := '|';
  FStrings.QuoteChar := #0;
  FStrings.StrictDelimiter := True;
end;

procedure TProfileReportTest.TearDown;
begin
  FProfileReport.Free;
  FReportStream.Free;
  FDummyStream.Free;
  FStrings.Free;
end;

procedure TProfileReportTest.TestSaveToStream(const DelimitedInput, DelimitedExpected: string);
begin
  FillReport(DelimitedInput);
  FReportStream.Clear;
  FDummyStream.Clear;
  FProfileReport.SaveToStream(FReportStream, FDummyStream);
  FStrings.DelimitedText := DelimitedExpected;
  Assert.AreEqual(FStrings.Text, FReportStream.DataString);
end;

end.
