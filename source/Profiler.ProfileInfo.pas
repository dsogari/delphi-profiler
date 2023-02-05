unit Profiler.ProfileInfo;

interface

type

  TProfileInfo = class
    private
      FScopeName: string;
      FTotalCalls: Int64;
      FTotalTicks: Int64;

      function GetTotalMicroseconds: Double;
      function GetAverageMicroseconds: Double;

    public
      constructor Create(const ScopeName: string); overload;
      constructor Create(const ScopeName: string; TotalCalls, TotalTicks: Int64); overload;
      procedure Add(ElapsedTicks: Int64; IsEndOfCall: Boolean);
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

constructor TProfileInfo.Create(const ScopeName: string);
begin
  FScopeName := ScopeName;
end;

constructor TProfileInfo.Create(const ScopeName: string; TotalCalls, TotalTicks: Int64);
begin
  Create(ScopeName);
  FTotalCalls := TotalCalls;
  FTotalTicks := TotalTicks;
end;

procedure TProfileInfo.Add(ElapsedTicks: Int64; IsEndOfCall: Boolean);
begin
  Inc(FTotalTicks, ElapsedTicks);
  if IsEndOfCall then
    Inc(FTotalCalls);
end;

class function TProfileInfo.CommaHeader: string;
const
  HeaderFormat = '"%s","%s","%s","%s"';
begin
  Result := Format(HeaderFormat, ['Scope Name', 'Total Calls', 'Total Time (us)',
      'Avg. Time (us)']);
end;

function TProfileInfo.CommaText: string;
const
  TextFormat = '"%s","%d","%.2f","%.2f"';
begin
  Result := Format(TextFormat, [FScopeName, FTotalCalls, TotalMicroseconds, AverageMicroseconds]);
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
