object FQRCodeAPIGoogle: TFQRCodeAPIGoogle
  Left = 0
  Top = 0
  Caption = 'FQRCodeAPIGoogle'
  ClientHeight = 322
  ClientWidth = 302
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 302
    Height = 322
    Align = alClient
    TabOrder = 0
    object ImageQRCode: TImage
      Left = 8
      Top = 8
      Width = 281
      Height = 273
      Center = True
      Proportional = True
      Stretch = True
    end
    object ComboBox1: TComboBox
      Left = 8
      Top = 287
      Width = 281
      Height = 21
      ItemIndex = 0
      TabOrder = 0
      Text = 'L'
      Items.Strings = (
        'L'
        'M'
        'Q'
        'H')
    end
  end
end
