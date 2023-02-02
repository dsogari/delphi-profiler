unit Profiler.ProfileInfo;

interface

type

  TProfileInfo = class
    private
      FFunctionName: string;
      FTotalCalls: Int64;
      FTotalTicks: Int64;

      function GetTotalMicroseconds: Double;
      function GetAverageMicroseconds: Double;

    public
      constructor Create(const FunctionName: string); overload;
      constructor Create(const FunctionName: string; TotalCalls, TotalTicks: Int64); overload;
      class function CommaHeader: string;
      function CommaText: string;

    public
      property TotalCalls: Int64 read FTotalCalls write FTotalCalls;
      property TotalTicks: Int64 read FTotalTicks write FTotalTicks;
      property TotalMicroseconds: Double read GetTotalMicroseconds;
      property AverageMicroseconds: Double read GetAverageMicroseconds;
  end;

implementation

uses
  System.SysUtils,
  System.Diagnostics;

constructor TProfileInfo.Create(const FunctionName: string);
begin
  FFunctionName := FunctionName;
end;

constructor TProfileInfo.Create(const FunctionName: string; TotalCalls, TotalTicks: Int64);
begin
  Create(FunctionName);
  FTotalCalls := TotalCalls;
  FTotalTicks := TotalTicks;
end;

class function TProfileInfo.CommaHeader: string;
const
  headerFormat = '"%s","%s","%s","%s"';
begin
  Result := Format(headerFormat, ['Function', 'Total Calls', 'Total Time (us)',
      'Average Time (us)']);
end;

function TProfileInfo.CommaText: string;
const
  textFormat = '"%s","%d","%.1f","%.3f"';
begin
  Result := Format(textFormat, [FFunctionName, FTotalCalls, TotalMicroseconds,
      AverageMicroseconds]);
end;

function TProfileInfo.GetTotalMicroseconds: Double;
begin
  Assert(TStopwatch.Frequency > 0);
  Result := FTotalTicks * 1000000.0 / TStopwatch.Frequency;
end;

function TProfileInfo.GetAverageMicroseconds: Double;
begin
  Assert(FTotalCalls > 0);
  Result := TotalMicroseconds / FTotalCalls;
end;

end.
