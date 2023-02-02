object FormProfileViewer: TFormProfileViewer
  Left = 0
  Top = 0
  Caption = 'Profile Viewer'
  ClientHeight = 270
  ClientWidth = 270
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object ProfileStatsSplitter: TSplitter
    Left = 0
    Top = 147
    Width = 270
    Height = 3
    Cursor = crVSplit
    Align = alBottom
    ExplicitTop = 0
    ExplicitWidth = 761
  end
  object ProfileGrid: TStringGrid
    Left = 0
    Top = 0
    Width = 270
    Height = 147
    Align = alClient
    ColCount = 4
    DrawingStyle = gdsClassic
    FixedCols = 0
    RowCount = 4
    TabOrder = 0
    OnDrawCell = ProfileGridDrawCell
    OnKeyDown = ProfileGridKeyDown
  end
  object StatsGrid: TStringGrid
    Left = 0
    Top = 150
    Width = 270
    Height = 120
    Align = alBottom
    ColCount = 4
    DrawingStyle = gdsClassic
    FixedCols = 0
    RowCount = 4
    TabOrder = 1
    OnKeyDown = StatsGridKeyDown
  end
end
