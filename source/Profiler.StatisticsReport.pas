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
      FReportLines: TStrings;
      FReportInfo: TList<TProfileStatistic>;
      FTotalCalls: TList<Double>;
      FTotalMicroseconds: TList<Double>;
      FAverageMicroseconds: TList<Double>;

    public
      constructor Create;
      destructor Destroy; override;
      procedure Add(const Info: TProfileInfo);
      procedure Clear;
      procedure Compute;
      procedure SaveToStream(Stream: TStream);
  end;

implementation

constructor TStatisticsReport.Create;
begin
  inherited;
  FReportLines := TStringList.Create;
  FReportInfo := TObjectList<TProfileStatistic>.Create;
  FTotalCalls := TList<Double>.Create;
  FTotalMicroseconds := TList<Double>.Create;
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

procedure TStatisticsReport.Add(const Info: TProfileInfo);
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
  FReportInfo.Clear;
  FReportInfo.Add(TProfileStatistic.Create('Total Calls', FTotalCalls.ToArray));
  FReportInfo.Add(TProfileStatistic.Create('Total Time (us)', FTotalMicroseconds.ToArray));
  FReportInfo.Add(TProfileStatistic.Create('Average Time (us)', FAverageMicroseconds.ToArray));
end;

procedure TStatisticsReport.SaveToStream(Stream: TStream);
var
  statistic: TProfileStatistic;
begin
  FReportLines.Clear;
  FReportLines.Add(TProfileStatistic.CommaHeader);
  for statistic in FReportInfo do
    FReportLines.Add(statistic.CommaText);
  FReportLines.SaveToStream(Stream);
end;

end.
