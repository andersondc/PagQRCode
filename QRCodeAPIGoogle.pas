{***************************************************************************
* Desenvolvida por: Anderson D C (2021)                                    *
* Gerencia Uso da API do Google para Gerar QRCode Online                   *
***************************************************************************}
unit QRCodeAPIGoogle;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls;

type
  TFQRCodeAPIGoogle = class(TForm)
    Panel1: TPanel;
    ImageQRCode: TImage;
    ComboBox1: TComboBox;
  private
    { Private declarations }
  public
    procedure GeraQRCode(valor: string);
  end;

var
  FQRCodeAPIGoogle: TFQRCodeAPIGoogle;

implementation

{$R *.dfm}

uses
  PngImage,
  HTTPApp,
  WinInet;

{$R *.dfm}

type
  TQrImage_ErrCorrLevel = (L, M, Q, H);

const
  UrlGoogleQrCode =
    'http://chart.apis.google.com/chart?chs=%dx%d&cht=qr&chld=%s&chl=%s';
  QrImgCorrStr: array [TQrImage_ErrCorrLevel] of string = ('L', 'M', 'Q', 'H');

procedure WinInet_HttpGet(const Url: string; Stream: TStream);
const
  BuffSize = 1024 * 1024;
var
  hInter: HINTERNET;
  UrlHandle: HINTERNET;
  BytesRead: DWORD;
  Buffer: Pointer;
begin
  hInter := InternetOpen('', INTERNET_OPEN_TYPE_PRECONFIG, nil, nil, 0);
  if Assigned(hInter) then
  begin
    Stream.Seek(0, 0);
    GetMem(Buffer, BuffSize);
    try
      UrlHandle := InternetOpenUrl(hInter, PChar(Url), nil, 0,
        INTERNET_FLAG_RELOAD, 0);
      if Assigned(UrlHandle) then
      begin
        repeat
          InternetReadFile(UrlHandle, Buffer, BuffSize, BytesRead);
          if BytesRead > 0 then
            Stream.WriteBuffer(Buffer^, BytesRead);
        until BytesRead = 0;
        InternetCloseHandle(UrlHandle);
      end;
    finally
      FreeMem(Buffer);
    end;
    InternetCloseHandle(hInter);
  end
end;

procedure GetQrCode(Width, Height: Word;
  Correction_Level: TQrImage_ErrCorrLevel; const Data: string;
  StreamImage: TMemoryStream);
Var
  EncodedURL: string;
begin
  EncodedURL := Format(UrlGoogleQrCode,
    [Width, Height, QrImgCorrStr[Correction_Level], HTTPEncode(Data)]);
  WinInet_HttpGet(EncodedURL, StreamImage);
end;

procedure TFQRCodeAPIGoogle.GeraQRCode(valor: string);
var
  ImageStream: TMemoryStream;
  PngImage: TPngImage;
begin
  ImageQRCode.Picture := nil;
  ImageStream := TMemoryStream.Create;
  PngImage := TPngImage.Create;
  try
    try
      GetQrCode(300, 300, TQrImage_ErrCorrLevel(ComboBox1.ItemIndex), valor,
        ImageStream);
      if ImageStream.Size > 0 then
      begin
        ImageStream.Position := 0;
        PngImage.LoadFromStream(ImageStream);
        ImageQRCode.Picture.Assign(PngImage);
      end;
    except
      on E: exception do
        ShowMessage(E.Message);
    end;
  finally
    ImageStream.Free;
    PngImage.Free;
  end;

end;

end.
