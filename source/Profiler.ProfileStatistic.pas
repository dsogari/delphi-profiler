unit Profiler.ProfileStatistic;

interface

uses
  System.Generics.Collections;

type

  TProfileStatistic = class
    private
      FMeasureName: string;
      FMean: Double;
      FMedian: Double;
      FStddev: Double;

      class function GetMedian(values: TArray<Double>): Double;

    public
      constructor Create(const MeasureName: string; values: TArray<Double>);
      class function CommaHeader: string;
      function CommaText: string;
  end;

implementation

uses
  System.SysUtils,
  System.Math;

constructor TProfileStatistic.Create(const MeasureName: string; values: TArray<Double>);
begin
  FMeasureName := MeasureName;
  if Length(values) > 0 then
    begin
      MeanAndStdDev(values, FMean, FStddev);
      FMedian := GetMedian(values);
    end;
end;

class function TProfileStatistic.GetMedian(values: TArray<Double>): Double;
var
  len: Integer;
begin
  len := Length(values);
  Assert(len > 0);
  TArray.Sort<Double>(values);
  if (len mod 2) = 0 then
    Result := (values[(len div 2) - 1] + values[len div 2]) / 2
  else
    Result := values[len div 2];
end;

class function TProfileStatistic.CommaHeader: string;
const
  headerFormat = '"%s","%s","%s","%s"';
begin
  Result := Format(headerFormat, ['Measure', 'Mean', 'Median', 'Standard Deviation']);
end;

function TProfileStatistic.CommaText: string;
const
  textFormat = '"%s","%.3f","%.3f","%.3f"';
begin
  Result := Format(textFormat, [FMeasureName, FMean, FMedian, FStddev]);
end;

end.
