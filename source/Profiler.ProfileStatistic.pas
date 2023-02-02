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

      class function GetMedian(var Values: TArray<Double>): Double;
      procedure SetValues(Values: TArray<Double>);

    public
      constructor Create(const MeasureName: string); overload;
      constructor Create(const MeasureName: string; const Values: TArray<Double>); overload;
      class function CommaHeader: string;
      function CommaText: string;

    public
      property Values: TArray<Double> write SetValues;
  end;

implementation

uses
  System.SysUtils,
  System.Math;

constructor TProfileStatistic.Create(const MeasureName: string);
begin
  FMeasureName := MeasureName;
end;

constructor TProfileStatistic.Create(const MeasureName: string; const Values: TArray<Double>);
begin
  Create(MeasureName);
  SetValues(Values);
end;

class function TProfileStatistic.GetMedian(var Values: TArray<Double>): Double;
var
  len: Integer;
begin
  len := Length(Values);
  Assert(len > 0);
  TArray.Sort<Double>(Values);
  if (len mod 2) = 0 then
    Result := (Values[(len div 2) - 1] + Values[len div 2]) / 2
  else
    Result := Values[len div 2];
end;

procedure TProfileStatistic.SetValues(Values: TArray<Double>);
begin
  if Length(Values) > 0 then
    begin
      MeanAndStdDev(Values, FMean, FStddev);
      FMedian := GetMedian(Values);
    end
  else
    begin
      FMean := NaN;
      FStddev := NaN;
      FMedian := NaN;
    end;
end;

class function TProfileStatistic.CommaHeader: string;
const
  headerFormat = '"%s","%s","%s","%s"';
begin
  Result := Format(headerFormat, ['Measure', 'Mean', 'Median', 'Standard Dev.']);
end;

function TProfileStatistic.CommaText: string;
const
  textFormat = '"%s","%.2f","%.2f","%.2f"';
begin
  Result := Format(textFormat, [FMeasureName, FMean, FMedian, FStddev]);
end;

end.
