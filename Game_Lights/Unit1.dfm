object Form1: TForm1
  Left = 257
  Top = 124
  BorderStyle = bsDialog
  Caption = 'Lights - 1.3'
  ClientHeight = 458
  ClientWidth = 320
  Color = clBlack
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -14
  Font.Name = 'Trebuchet MS'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 120
  TextHeight = 18
  object PanelBas: TPanel
    Left = 0
    Top = 387
    Width = 320
    Height = 71
    Align = alBottom
    BevelOuter = bvNone
    Color = clMedGray
    TabOrder = 0
    DesignSize = (
      320
      71)
    object Bevel2: TBevel
      Left = 9
      Top = 6
      Width = 112
      Height = 28
      Style = bsRaised
    end
    object Shape: TShape
      Left = 257
      Top = 29
      Width = 38
      Height = 37
      Anchors = [akTop, akRight]
      Brush.Color = clLime
    end
    object btRandom: TSpeedButton
      Left = 9
      Top = 6
      Width = 112
      Height = 28
      Caption = 'New game'
      Flat = True
      OnClick = btRandomClick
    end
    object lNiveaux: TLabel
      Left = 135
      Top = 27
      Width = 55
      Height = 18
      Alignment = taCenter
      Anchors = [akTop]
      AutoSize = False
      Caption = '99/99'
    end
    object Label2: TLabel
      Left = 136
      Top = 9
      Width = 49
      Height = 18
      Anchors = [akTop]
      AutoSize = False
      Caption = 'New:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Trebuchet MS'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object Label3: TLabel
      Left = 248
      Top = 9
      Width = 62
      Height = 18
      Alignment = taCenter
      Anchors = [akTop, akRight]
      Caption = 'Resultat:'
    end
    object lTime: TStaticText
      Left = 9
      Top = 43
      Width = 112
      Height = 22
      Alignment = taCenter
      AutoSize = False
      BorderStyle = sbsSunken
      Caption = '0 sec.'
      TabOrder = 0
    end
    object UpDown: TUpDown
      Left = 135
      Top = 45
      Width = 55
      Height = 19
      Anchors = [akTop]
      ArrowKeys = False
      Min = 1
      Max = 99
      Orientation = udHorizontal
      Position = 1
      TabOrder = 1
      Thousands = False
      OnClick = UpDownClick
    end
  end
  object Timer: TTimer
    Enabled = False
    Interval = 999
    OnTimer = TimerTimer
    Left = 56
    Top = 280
  end
  object TimerGagne: TTimer
    Enabled = False
    Interval = 100
    OnTimer = TimerGagneTimer
    Left = 24
    Top = 280
  end
  object OpenDialog: TOpenDialog
    DefaultExt = '.lgh'
    Filter = 'Fichiers Lights 1.3 (*.lgh)|*.lgh'
    Title = 'Ouvrir un fichier de jeu'
    Left = 88
    Top = 280
  end
end
