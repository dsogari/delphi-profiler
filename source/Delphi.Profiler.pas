/// This is the entrypoint unit for tracing
unit Delphi.Profiler;

interface

uses
  Profiler.ProfileThread;

type

  TProfile = Profiler.ProfileThread.TProfileThread;

/// Set a pattern to filter scope names in the default profile
procedure SetScopeFilter(const Pattern: string);

/// Generate a block-scoped trace event in the default profile
function Trace(const ScopeName: string): IInterface; overload;

/// Generate a long-lived trace event in the default profile
procedure Trace(const ScopeName: string; out Trace: IInterface); overload;

implementation

var
  DefaultProfile: TProfile;

procedure InitializeDefaultProfile;
begin
  if not Assigned(DefaultProfile) then
    DefaultProfile := TProfile.Create('default');
end;

procedure SetScopeFilter(const Pattern: string);
begin
  InitializeDefaultProfile;
  DefaultProfile.SetScopeFilter(Pattern);
end;

function Trace(const ScopeName: string): IInterface;
begin
  InitializeDefaultProfile;
  Result := DefaultProfile.Trace(ScopeName);
end;

procedure Trace(const ScopeName: string; out Trace: IInterface);
begin
  InitializeDefaultProfile;
  DefaultProfile.Trace(ScopeName, Trace);
end;

end.
