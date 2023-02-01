unit Profiler.StatisticsReport;

interface

uses
  Profiler.ProfileStatistic,
  Profiler.ProfileInfo,
  System.Generics.Collections,
  System.Classes;

type

  TStatisticsReport = class
    private
      FReportPath: string;
      FReportLines: TStrings;
      FReportInfo: TList<TProfileStatistic>;
      FTotalCalls: TList<Double>;
      FTotalMicroseconds: TList<Double>;
      FAverageMicroseconds: TList<Double>;

    public
      constructor Create;
      destructor Destroy; override;
      procedure Add(info: TProfileInfo);
      procedure Compute;
      procedure SaveToFile;

    public
      property ReportPath: string write FReportPath;
  end;

implementation

constructor TStatisticsReport.Create;
begin
  inherited;
  FReportLines         := TStringList.Create;
  FReportInfo          := TObjectList<TProfileStatistic>.Create;
  FTotalCalls          := TList<Double>.Create;
  FTotalMicroseconds   := TList<Double>.Create;
  FAverageMicroseconds := TList<Double>.Create;
end;

destructor TStatisticsReport.Destroy;
begin
  FReportLines.Free;
  FReportInfo.Free;
  FTotalCalls.Free;
  FTotalMicroseconds.Free;
  FAverageMicroseconds.Free;
  inherited;
end;

procedure TStatisticsReport.Add(info: TProfileInfo);
begin
  FTotalCalls.Add(info.TotalCalls);
  FTotalMicroseconds.Add(info.TotalMicroseconds);
  FAverageMicroseconds.Add(info.AverageMicroseconds);
end;

procedure TStatisticsReport.Compute;
begin
  FReportInfo.Add(TProfileStatistic.Create('Total Calls', FTotalCalls.ToArray));
  FReportInfo.Add(TProfileStatistic.Create('Total Time (us)', FTotalMicroseconds.ToArray));
  FReportInfo.Add(TProfileStatistic.Create('Average Time (us)', FAverageMicroseconds.ToArray));
end;

procedure TStatisticsReport.SaveToFile;
var
  statistic: TProfileStatistic;
begin
  FReportLines.Clear;
  FReportLines.Add(TProfileStatistic.CommaHeader);
  for statistic in FReportInfo do
    FReportLines.Add(statistic.CommaText);
  FReportLines.SaveToFile(FReportPath);
end;

end.
