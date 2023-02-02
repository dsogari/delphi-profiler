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
      FStream: TStringStream;
      FStrings: TStrings;

      procedure FillReport(const DelimitedInput: string);

    public
      [Setup]
      procedure Setup;
      [TearDown]
      procedure TearDown;

      [Test]
      [TestCase('Two inputs', 'abc,2|def,4;' +
            '"Scope","Total Calls","Total Time (us)","Avg. Time (us)"', ';')]
      procedure TestClear(const DelimitedInput, DelimitedExpected: string);

      [Test]
      [TestCase('Two inputs', 'abc,2|def,4;' +
            '"Scope","Total Calls","Total Time (us)","Avg. Time (us)"|' +
            '"def","1","0.40","0.40"|' +
            '"abc","1","0.20","0.20"', ';')]
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
      FProfileReport.Add(Strings[0], Strings[1].ToInt64, True);
    end;
end;

procedure TProfileReportTest.Setup;
begin
  FProfileReport := TProfileReport.Create;
  FStream := TStringStream.Create;
  FStrings := TStringList.Create;
  FStrings.Delimiter := '|';
  FStrings.QuoteChar := #0;
  FStrings.StrictDelimiter := True;
end;

procedure TProfileReportTest.TearDown;
begin
  FProfileReport.Free;
  FStream.Free;
  FStrings.Free;
end;

procedure TProfileReportTest.TestClear(const DelimitedInput, DelimitedExpected: string);
begin
  FillReport(DelimitedInput);
  FProfileReport.Clear;
  FStream.Clear;
  FProfileReport.SaveProfileToStream(FStream);
  FStrings.DelimitedText := DelimitedExpected;
  Assert.AreEqual(FStrings.Text, FStream.DataString);
end;

procedure TProfileReportTest.TestSaveToStream(const DelimitedInput, DelimitedExpected: string);
begin
  FillReport(DelimitedInput);
  FStream.Clear;
  FProfileReport.SaveProfileToStream(FStream);
  FStrings.DelimitedText := DelimitedExpected;
  Assert.AreEqual(FStrings.Text, FStream.DataString);
end;

end.
