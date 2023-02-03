unit Profiler.FormProfileViewer;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.Grids,
  Vcl.ExtCtrls;

type

  TFormProfileViewer = class(TForm)
    ProfileGrid: TStringGrid;
    ProfileStatsSplitter: TSplitter;
    StatsGrid: TStringGrid;
    procedure ProfileGridKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure StatsGridKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure ProfileGridDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect;
      State: TGridDrawState);

    private
      FLines: TStrings;
      FMeans: array [0 .. 3] of Double;
      FStddevs: array [0 .. 3] of Double;

      procedure HandleCreate(Sender: TObject);

      function GetHighlightColor(Value: Double; Col: Integer): TColor;
      procedure HighlightCell(const text: string; Canvas: TCanvas; Rect: TRect; Color: TColor);
      procedure LoadGridFromFile(Grid: TStringGrid; const Path: string);
      procedure AutoSizeGrid(Grid: TStringGrid);
      procedure InitializeMeansAdsStddevs;
      procedure CopySelectionToClipboard(Grid: TStringGrid);

    public
      constructor Create(AOwner: TComponent); override;
      destructor Destroy; override;
  end;

var
  FormProfileViewer: TFormProfileViewer;

implementation

{$R *.dfm}


uses
  Vcl.Clipbrd;

constructor TFormProfileViewer.Create(AOwner: TComponent);
begin
  inherited;
  OnCreate := HandleCreate;

  FLines := TStringList.Create;
  FLines.TrailingLineBreak := false;
end;

destructor TFormProfileViewer.Destroy;
begin
  FLines.Free;
  inherited;
end;

procedure TFormProfileViewer.ProfileGridDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect;
  State: TGridDrawState);
var
  sValue: Double;
  highlightColor: TColor;
begin
  if (ACol > 1) and (ARow > 0) then
    with Sender as TStringGrid do
      begin
        sValue := StrToFloat(Cells[ACol, ARow]);
        if sValue > FMeans[ACol] then
          begin
            highlightColor := GetHighlightColor(sValue, ACol);
            HighlightCell(Cells[ACol, ARow], Canvas, Rect, highlightColor);
          end;
      end;
end;

procedure TFormProfileViewer.ProfileGridKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if (ssCtrl in Shift) and (Key = Ord('C')) then
    CopySelectionToClipboard(ProfileGrid);
end;

procedure TFormProfileViewer.StatsGridKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if (ssCtrl in Shift) and (Key = Ord('C')) then
    CopySelectionToClipboard(StatsGrid);
end;

function TFormProfileViewer.GetHighlightColor(Value: Double; Col: Integer): TColor;
begin
  if Value > FMeans[Col] + 3 * FStddevs[Col] then
    Result := clWebTan
  else if Value > FMeans[Col] + 2 * FStddevs[Col] then
    Result := clWebWheat
  else if Value > FMeans[Col] + FStddevs[Col] then
    Result := clWebBeige
  else
    Result := clCream;
end;

procedure TFormProfileViewer.HighlightCell(const text: string; Canvas: TCanvas; Rect: TRect;
  Color: TColor);
const
  LeftOffset = 6;
var
  TopOffset: Integer;
begin
  Canvas.Brush.Color := Color;
  Canvas.FillRect(Rect);
  TopOffset := (Rect.Height - Canvas.TextHeight(text)) div 2;
  Canvas.TextOut(Rect.Left + LeftOffset, Rect.Top + TopOffset, text);
end;

procedure TFormProfileViewer.CopySelectionToClipboard(Grid: TStringGrid);
const
  c_chTab = #9;
var
  strLine: string;
  I, K: Integer;
begin
  try
    with Grid do
      for I := Selection.Top to Selection.Bottom do
        begin
          strLine := '';
          for K := Selection.Left to Selection.Right do
            begin
              strLine := strLine + Cells[K, I];
              if K <> Selection.Right then
                strLine := strLine + c_chTab;
            end;
          FLines.Add(strLine);
        end;
    Clipboard.AsText := FLines.text;
  finally
    FLines.Clear;
  end;
end;

procedure TFormProfileViewer.HandleCreate(Sender: TObject);
begin
  LoadGridFromFile(ProfileGrid, 'profile.csv');
  LoadGridFromFile(StatsGrid, 'stats.csv');
  InitializeMeansAdsStddevs;
end;

procedure TFormProfileViewer.LoadGridFromFile(Grid: TStringGrid; const Path: string);
var
  I: Integer;
begin
  try
    FLines.LoadFromFile(Path);
    Grid.RowCount := FLines.Count;
    for I := 0 to FLines.Count - 1 do
      Grid.Rows[I].CommaText := FLines[I];
    AutoSizeGrid(Grid);
  finally
    FLines.Clear;
  end;
end;

procedure TFormProfileViewer.AutoSizeGrid(Grid: TStringGrid);
const
  ColWidthMin  = 10;
  ColWidthPad  = 10;
  GridWidthPad = 25;
var
  Col, Row, TextWidth, ColWidthMax, GridWidth: Integer;
begin
  GridWidth := 0;
  for Col := 0 to Grid.ColCount - 1 do
    begin
      ColWidthMax := ColWidthMin;
      for Row := 0 to (Grid.RowCount - 1) do
        begin
          TextWidth := Grid.Canvas.TextWidth(Grid.Cells[Col, Row]);
          if TextWidth > ColWidthMax then
            ColWidthMax := TextWidth;
        end;
      Grid.ColWidths[Col] := ColWidthMax + ColWidthPad;
      Inc(GridWidth, Grid.ColWidths[Col]);
    end;
  if ClientWidth < GridWidth + GridWidthPad then
    ClientWidth := GridWidth + GridWidthPad;
end;

procedure TFormProfileViewer.InitializeMeansAdsStddevs;
var
  I: Integer;
begin
  for I := 2 to 3 do
    begin
      FMeans[I] := StrToFloat(StatsGrid.Cells[1, I]);
      FStddevs[I] := StrToFloat(StatsGrid.Cells[3, I]);
    end;
end;

end.
