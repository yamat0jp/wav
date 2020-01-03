object Form2: TForm2
  Left = 0
  Top = 0
  Caption = 'Form2'
  ClientHeight = 299
  ClientWidth = 635
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  DesignSize = (
    635
    299)
  PixelsPerInch = 96
  TextHeight = 13
  object SpeedButton1: TSpeedButton
    Left = 439
    Top = 46
    Width = 42
    Height = 23
    OnClick = SpeedButton1Click
  end
  object MediaPlayer1: TMediaPlayer
    Left = 136
    Top = 120
    Width = -3
    Height = 30
    VisibleButtons = [btPlay, btPause, btStop, btRecord]
    AutoOpen = True
    DeviceType = dtWaveAudio
    DoubleBuffered = True
    ParentDoubleBuffered = False
    TabOrder = 0
    OnClick = MediaPlayer1Click
    OnMouseEnter = MediaPlayer1MouseEnter
  end
  object Edit1: TEdit
    Left = 64
    Top = 48
    Width = 369
    Height = 21
    TabOrder = 1
    Text = 'Edit1'
  end
  object Button1: TButton
    Left = 288
    Top = 176
    Width = 75
    Height = 25
    Caption = 'GO'
    TabOrder = 2
    OnClick = Button1Click
  end
  object ListBox1: TListBox
    Left = 439
    Top = 120
    Width = 170
    Height = 161
    Anchors = [akLeft, akTop, akRight]
    ItemHeight = 13
    TabOrder = 3
  end
  object OpenDialog1: TOpenDialog
    Filter = 'wav file|*.wav'
    Left = 528
    Top = 88
  end
  object SaveDialog1: TSaveDialog
    DefaultExt = 'wav'
    Filter = 'wav file|*.wav'
    Left = 528
    Top = 168
  end
end
