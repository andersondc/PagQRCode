program QRCodePixPic;

uses
  Vcl.Forms,
  Principal in 'Principal.pas' {FPrincipal},
  Config in 'Config.pas' {FConfig},
  QRCodeAPIGoogle in 'QRCodeAPIGoogle.pas' {FQRCodeAPIGoogle};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFPrincipal, FPrincipal);
  Application.CreateForm(TFConfig, FConfig);
  Application.CreateForm(TFQRCodeAPIGoogle, FQRCodeAPIGoogle);
  Application.Run;
end.
