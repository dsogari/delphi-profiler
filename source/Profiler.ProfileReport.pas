unit Profiler.ProfileReport;

interface

uses
  System.Generics.Collections,
  System.Generics.Defaults,
  System.Classes,
  Profiler.ProfileInfo,
  Profiler.StatisticsReport;

type

  TReportEntry = TPair<string, TProfileInfo>;
  TEntryArray  = TArray<TReportEntry>;

  TProfileReport = class
    private
      FReportLines: TStrings;
      FReportInfo: TDictionary<string, TProfileInfo>;
      FStatistics: TStatisticsReport;

      function GetSortedEntries: TEntryArray;
      procedure SaveProfileToStream(Stream: TStream);
      procedure SaveStatisticsToStream(Stream: TStream);

    public
      constructor Create;
      destructor Destroy; override;
      procedure Add(const FunctionName: string; elapsedTicks: Int64);
      procedure SaveToStream(ReportStream, StatisticsStream: TStream);
  end;

  TTotalTicksComparer = class(TComparer<TReportEntry>)
    public
      function Compare(const Left, Right: TReportEntry): Integer; override;
  end;

implementation

function TTotalTicksComparer.Compare(const Left, Right: TReportEntry): Integer;
begin
  Result := Right.value.TotalTicks - Left.value.TotalTicks; // sort in descending order
end;

constructor TProfileReport.Create;
begin
  FReportLines := TStringList.Create;
  FReportInfo := TObjectDictionary<string, TProfileInfo>.Create([doOwnsValues]);
  FStatistics := TStatisticsReport.Create;
end;

destructor TProfileReport.Destroy;
begin
  FReportLines.Free;
  FReportInfo.Free;
  FStatistics.Free;
  inherited;
end;

procedure TProfileReport.SaveToStream(ReportStream, StatisticsStream: TStream);
begin
  SaveProfileToStream(ReportStream);
  SaveStatisticsToStream(StatisticsStream);
end;

procedure TProfileReport.SaveProfileToStream(Stream: TStream);
var
  entry: TReportEntry;
begin
  FReportLines.Clear;
  FReportLines.Add(TProfileInfo.CommaHeader);
  for entry in GetSortedEntries do
    FReportLines.Add(entry.value.CommaText);
  FReportLines.SaveToStream(Stream);
end;

function TProfileReport.GetSortedEntries: TEntryArray;
var
  comparer: IComparer<TReportEntry>;
begin
  Result := FReportInfo.ToArray;
  comparer := TTotalTicksComparer.Create;
  TArray.Sort<TReportEntry>(Result, comparer);
end;

procedure TProfileReport.SaveStatisticsToStream(Stream: TStream);
var
  entry: TReportEntry;
begin
  for entry in FReportInfo do
    FStatistics.Add(entry.value);
  FStatistics.Compute;
  FStatistics.SaveToStream(Stream);
end;

procedure TProfileReport.Add(const FunctionName: string; elapsedTicks: Int64);
begin
  if not FReportInfo.ContainsKey(FunctionName) then
    FReportInfo.Add(FunctionName, TProfileInfo.Create(FunctionName));
  with FReportInfo[FunctionName] do
    begin
      TotalTicks := TotalTicks + elapsedTicks;
      TotalCalls := TotalCalls + 1;
    end;
end;

end.
