unit Profiler.StatisticsReport;

interface

uses
  Profiler.MeasureStatistic,
  Profiler.ScopeInfo,
  System.Generics.Collections,
  System.Classes;

type

  TStatisticsReport = class
    private
      FReportLines: TStrings;
      FStatistics: TList<TMeasureStatistic>;
      FTotalCalls: TList<Double>;
      FTotalMicroseconds: TList<Double>;
      FAverageMicroseconds: TList<Double>;

    public
      constructor Create;
      destructor Destroy; override;
      procedure Add(const Info: TScopeInfo);
      procedure Clear;
      procedure Compute;
      procedure SaveToStream(Stream: TStream);
  end;

implementation

constructor TStatisticsReport.Create;
begin
  inherited;
  FReportLines := TStringList.Create;
  FStatistics := TObjectList<TMeasureStatistic>.Create;
  FTotalCalls := TList<Double>.Create;
  FTotalMicroseconds := TList<Double>.Create;
  FAverageMicroseconds := TList<Double>.Create;
end;

destructor TStatisticsReport.Destroy;
begin
  FReportLines.Free;
  FStatistics.Free;
  FTotalCalls.Free;
  FTotalMicroseconds.Free;
  FAverageMicroseconds.Free;
  inherited;
end;

procedure TStatisticsReport.Add(const Info: TScopeInfo);
begin
  FTotalCalls.Add(Info.TotalCalls);
  FTotalMicroseconds.Add(Info.TotalMicroseconds);
  FAverageMicroseconds.Add(Info.AverageMicroseconds);
end;

procedure TStatisticsReport.Clear;
begin
  FTotalCalls.Clear;
  FTotalMicroseconds.Clear;
  FAverageMicroseconds.Clear;
end;

procedure TStatisticsReport.Compute;
begin
  FStatistics.Clear;
  FStatistics.Add(TMeasureStatistic.Create('Total Calls', FTotalCalls.ToArray));
  FStatistics.Add(TMeasureStatistic.Create('Total Time (us)', FTotalMicroseconds.ToArray));
  FStatistics.Add(TMeasureStatistic.Create('Avg. Time (us)', FAverageMicroseconds.ToArray));
end;

procedure TStatisticsReport.SaveToStream(Stream: TStream);
var
  statistic: TMeasureStatistic;
begin
  FReportLines.Clear;
  FReportLines.Add(TMeasureStatistic.CommaHeader);
  for statistic in FStatistics do
    FReportLines.Add(statistic.CommaText);
  FReportLines.SaveToStream(Stream);
end;

end.
