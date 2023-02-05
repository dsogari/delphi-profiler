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

    public
      constructor Create;
      destructor Destroy; override;
      procedure Add(const ScopeName: string; ElapsedTicks: Int64; IsEndOfCall: Boolean);
      procedure Clear;
      procedure SaveProfileToStream(Stream: TStream);
      procedure SaveStatisticsToStream(Stream: TStream);
  end;

  TTotalTicksComparer = class(TComparer<TReportEntry>)
    public
      function Compare(const Left, Right: TReportEntry): Integer; override;
  end;

implementation

function TTotalTicksComparer.Compare(const Left, Right: TReportEntry): Integer;
begin
  Result := Right.Value.TotalTicks - Left.Value.TotalTicks; // sort in descending order
end;

procedure TProfileReport.Clear;
begin
  FReportInfo.Clear;
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

procedure TProfileReport.SaveProfileToStream(Stream: TStream);
var
  Entry: TReportEntry;
begin
  FReportLines.Clear;
  FReportLines.Add(TProfileInfo.CommaHeader);
  for Entry in GetSortedEntries do
    FReportLines.Add(Entry.Value.CommaText);
  FReportLines.SaveToStream(Stream);
end;

function TProfileReport.GetSortedEntries: TEntryArray;
var
  Comparer: IComparer<TReportEntry>;
begin
  Result := FReportInfo.ToArray;
  Comparer := TTotalTicksComparer.Create;
  TArray.Sort<TReportEntry>(Result, Comparer);
end;

procedure TProfileReport.SaveStatisticsToStream(Stream: TStream);
var
  Entry: TReportEntry;
begin
  FStatistics.Clear;
  for Entry in FReportInfo do
    FStatistics.Add(Entry.Value);
  FStatistics.Compute;
  FStatistics.SaveToStream(Stream);
end;

procedure TProfileReport.Add(const ScopeName: string; ElapsedTicks: Int64; IsEndOfCall: Boolean);
var
  Info: TProfileInfo;
begin
  if not FReportInfo.TryGetValue(ScopeName, Info) then
    begin
      Info := TProfileInfo.Create(ScopeName);
      FReportInfo.Add(ScopeName, Info);
    end;
  Info.Add(ElapsedTicks, IsEndOfCall);
end;

end.
