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
    procedure ProfileGridDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect; State: TGridDrawState);

    private
      FLines  : TStrings;
      FMeans  : array [0 .. 3] of Double;
      FStddevs: array [0 .. 3] of Double;

      procedure HandleCreate(Sender: TObject);

      function GetHighlightColor(value: Double; ACol: Integer): TColor;
      procedure HighlightCell(const text: string; Canvas: TCanvas; Rect: TRect; color: TColor);
      procedure LoadGridFromFile(Grid: TStringGrid; const path: string);
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
  OnCreate                 := HandleCreate;

  FLines                   := TStringList.Create;
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
  sValue        : Double;
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

function TFormProfileViewer.GetHighlightColor(value: Double; ACol: Integer): TColor;
begin
  if value > FMeans[ACol] + 3 * FStddevs[ACol] then
    Result := clWebTan
  else if value > FMeans[ACol] + 2 * FStddevs[ACol] then
    Result := clWebWheat
  else if value > FMeans[ACol] + FStddevs[ACol] then
    Result := clWebBeige
  else
    Result := clCream;
end;

procedure TFormProfileViewer.HighlightCell(const text: string; Canvas: TCanvas; Rect: TRect; color: TColor);
const
  c_nLeftOffset = 4;
var
  nTopOffset: Integer;
begin
  Canvas.Brush.color := color;
  Rect.Inflate(c_nLeftOffset, 0, 0, 0);
  Canvas.FillRect(Rect);
  nTopOffset := (Rect.Height - Canvas.TextHeight(text)) div 2;
  Canvas.TextOut(Rect.Left + c_nLeftOffset + 2, Rect.Top + nTopOffset, text);
end;

procedure TFormProfileViewer.CopySelectionToClipboard(Grid: TStringGrid);
const
  c_chTab = #9;
var
  strLine: string;
  I, K   : Integer;
begin
  try
    with Grid do
      for I             := Selection.Top to Selection.Bottom do
        begin
          strLine       := '';
          for K         := Selection.Left to Selection.Right do
            begin
              strLine   := strLine + Cells[K, I];
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

procedure TFormProfileViewer.LoadGridFromFile(Grid: TStringGrid; const path: string);
var
  I: Integer;
begin
  try
    FLines.LoadFromFile(path);
    Grid.RowCount            := FLines.Count;
    for I                    := 0 to FLines.Count - 1 do
      Grid.Rows[I].CommaText := FLines[I];
    AutoSizeGrid(Grid);
  finally
    FLines.Clear;
  end;
end;

procedure TFormProfileViewer.AutoSizeGrid(Grid: TStringGrid);
const
  c_nColWidthMin = 10;
  c_nColWidthPad = 10;
var
  C, R, W     : Integer;
  nColWidthMax: Integer;
begin
  for C                  := 0 to Grid.ColCount - 1 do
    begin
      nColWidthMax       := c_nColWidthMin;
      for R              := 0 to (Grid.RowCount - 1) do
        begin
          W              := Grid.Canvas.TextWidth(Grid.Cells[C, R]);
          if W > nColWidthMax then
            nColWidthMax := W;
        end;
      Grid.ColWidths[C]  := nColWidthMax + c_nColWidthPad;
    end;
end;

procedure TFormProfileViewer.InitializeMeansAdsStddevs;
var
  I: Integer;
begin
  for I           := 2 to 3 do
    begin
      FMeans[I]   := StrToFloat(StatsGrid.Cells[1, I]);
      FStddevs[I] := StrToFloat(StatsGrid.Cells[3, I]);
    end;
end;

end.
