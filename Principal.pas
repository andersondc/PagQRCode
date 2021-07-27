unit Principal;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls, Config, ACBrPicpay,
  Vcl.Imaging.pngimage, ACBrBase, ACBrSocket, QRCodeAPIGoogle, StrUtils, Vcl.Clipbrd;

type
  TFPrincipal = class(TForm)
    Panel2: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    Label1: TLabel;
    vValor: TEdit;
    Imagem: TImage;
    Image2: TImage;
    imPic: TImage;
    imPix: TImage;
    ACBrPicPay1: TACBrPicPay;
    Pic1: TImage;
    Pix1: TImage;
    Pic2: TImage;
    Pix2: TImage;
    iInicial: TImage;
    PCodigoPIX: TPanel;
    Label2: TLabel;
    CodigoPIX: TEdit;
    Button1: TButton;
    procedure Image2Click(Sender: TObject);
    procedure imPicClick(Sender: TObject);
    procedure imPixClick(Sender: TObject);
    procedure vValorKeyPress(Sender: TObject; var Key: Char);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    function GeraPicPay: string;
    function GeraCPF(const Ponto: Boolean): string;
    procedure RecuperaImagensOriginais;
    procedure GeraPix;
    function CalculaCRC16(valor: string): string;
    function Crc16(texto: string; Polynom: WORD = $1021; Seed: WORD = $FFFF): WORD;
  end;

var
  FPrincipal: TFPrincipal;

implementation

{$R *.dfm}

procedure TFPrincipal.Image2Click(Sender: TObject);
begin
  RecuperaImagensOriginais;
  Config.FConfig.ShowModal;
end;

procedure TFPrincipal.imPicClick(Sender: TObject);
begin
  RecuperaImagensOriginais;
  imPic.Picture:=Pic2.Picture;
  imPic.Repaint;
  Imagem.Repaint;

  GeraPicPay;
end;

procedure TFPrincipal.imPixClick(Sender: TObject);
begin
  RecuperaImagensOriginais;
  imPix.Picture:=Pix2.Picture;
  imPix.Repaint;
  Imagem.Repaint;

  GeraPix;
end;

procedure TFPrincipal.RecuperaImagensOriginais;
begin
  imPic.Picture:=Pic1.Picture;
  imPix.Picture:=Pix1.Picture;
  Imagem.Picture:=iInicial.Picture;

  PCodigoPIX.Visible:=false;
end;

procedure TFPrincipal.vValorKeyPress(Sender: TObject; var Key: Char);
var
   Texto, Texto2: string;
   i: byte;
begin
  if (Key in ['0'..'9',chr(vk_back)]) then
  begin
     // limito a 23 caracteres senão haverá um erro na função StrToInt64()
     if (key in ['0'..'9']) and (Length(Trim(TEdit(Sender).Text))>23) then
        key := #0;
      // pego somente os caracteres de 0 a 9, ignorando a pontuação
     Texto2 := '0';
     Texto := Trim(TEdit(Sender).Text)+Key;
     for i := 1 to Length(Texto) do
        if Texto[i] in ['0'..'9'] then
           Texto2 := Texto2 + Texto[i];
     // se foi pressionado BACKSPACE (única tecla válida, fora os números)
     // apago o último caractere da string
     if key = chr(vk_back) then
        Delete(Texto2,Length(Texto2),1);
     // formato o texto que depois será colocado no Edit
     Texto2 := FormatFloat('#,0.00',StrToInt64(Texto2)/100);

     // preencho os espaços à esquerda, de modo a deixar o texto
     // alinhado à direita (gambiarra)
     repeat
        Texto2 := ' '+Texto2
     until Canvas.TextWidth(Texto2) >= TEdit(Sender).Width;
     // atribuo a string à propriedade Text do Edit
     TEdit(Sender).Text := Texto2;

     // posiciono o cursor no fim do texto
     TEdit(Sender).SelStart := Length(Texto2);
  end;
  Key := #0;

end;

// Gera Venda do "PIC PAY" pelo componente ACBr e Cria QRCode
function TFPrincipal.GeraPicPay: string;
var
  i: integer;
  auxStr: string;
begin
  application.ProcessMessages;

  try
    ACBrPicPay1.Lojista.URLCallBack:='https://webcontrolempresas.com.br/webcontrol/';
    ACBrPicPay1.Lojista.URLReturn:='https://webcontrolempresas.com.br/webcontrol/';
    ACBrPicPay1.Lojista.PicpayToken:=Config.FConfig.vTokenPicPay.Text;
    ACBrPicPay1.Lojista.SellerToken:=Config.FConfig.vTokenSeller.Text;

    ACBrPicPay1.Comprador.Nome:='Anderson Domanoski de';
    ACBrPicPay1.Comprador.SobreNome:='Camargo';
    ACBrPicPay1.Comprador.Documento:=GeraCPF(true);
    ACBrPicPay1.Comprador.Email:='andersondomcamargo@gmail.com';
    ACBrPicPay1.Comprador.Telefone:='+55 41995335373';

    ACBrPicPay1.ReferenceId:=FormatDateTime('yyyymmddhhmmss', now);
    ACBrPicPay1.Produto:='Venda via PICPAY';
    ACBrPicPay1.Valor:=StrToFLoat(vValor.Text);

    try
      ACBrPicPay1.Enviar;
    finally
      Imagem.Picture.LoadFromStream(ACBrPicPay1.QRCode);
    end;

    application.ProcessMessages;

  finally

  end;
end;

// Gera CPF randomico para usar no formulario "PIC PAY" obrigatório
function TFPrincipal.GeraCPF(const Ponto: Boolean): string;
var
  n1, n2, n3, n4, n5, n6, n7, n8, n9, d1, d2: LongInt;
begin
  n1 := Trunc(Random(10));
  n2 := Trunc(Random(10));
  n3 := Trunc(Random(10));
  n4 := Trunc(Random(10));
  n5 := Trunc(Random(10));
  n6 := Trunc(Random(10));
  n7 := Trunc(Random(10));
  n8 := Trunc(Random(10));
  n9 := Trunc(Random(10));

  d1 := (n9 * 2) + (n8 * 3) + (n7 * 4) + (n6 *  5) + (n5 * 6) +
        (n4 * 7) + (n3 * 8) + (n2 * 9) + (n1 * 10);

  d1 := 11 - (d1 mod 11);

  if (d1 >= 10) then d1 := 0;

  d2 := (d1 * 2) + (n9 * 3) + (n8 * 4) + (n7 *  5) + (n6 *  6) +
        (n5 * 7) + (n4 * 8) + (n3 * 9) + (n2 * 10) + (n1 * 11);
  d2 := 11 - (d2 mod 11);

  if (d2>=10) then d2 := 0;

  Result := IntToStr(n1) + IntToStr(n2) + IntToStr(n3) + IntToStr(n4) + IntToStr(n5) + IntToStr(n6) +
            IntToStr(n7) + IntToStr(n8) + IntToStr(n9) + IntToStr(d1) + IntToStr(d2);
  if Ponto then
     Result := Copy(Result, 1, 3) + '.' + Copy(Result, 4, 3) + '.' + Copy(Result, 7, 3) + '-' + Copy(Result, 10, 2);
end;

 // Gera Venda e QRCode "PIX"
procedure TFPrincipal.GeraPix;
var
  v00: string;
  v26: string;
  v52: string;
  v53: string;
  v54: string;
  v58: string;
  v59: string;
  v60: string;
  v62: string;
  v63: string;

  auxTel: string;

  chavePIX: string;

  FGoogleQRCode: TFQRCodeAPIGoogle;
begin
  Application.ProcessMessages;

  try
    // TratandoCampos
    // 00 - Payload Format
    v00:='000201';

    // 26 - Merchant Acount (contem a chave)
    if Config.FConfig.vTel.Checked=true then     // Trata se For telefone
      v26:='+55'+trim(Config.FConfig.vPix.Text)
    else
      v26:=trim(Config.FConfig.vPix.Text);

    v26:='01'+IntTOStr(length(trim(v26)))+v26;  // Chave

    v26:='0014BR.GOV.BCB.PIX'+v26;
    v26:='26'+IntTOStr(Length(v26))+v26;

    // 52 - Merchant Category Code
    v52:='52040000';

    // 53 - Transaction Currency (Moeda Local)
    v53:='5303986';   // Codigo do REAL R$

    // 54 - Valor
    v54:=FormatFloat( '#,##0.00; (#,##0.00)' , StrToFloat(vValor.Text));
    v54:=StringReplace(v54, '.', '@', [rfReplaceAll, rfIgnoreCase]);
    v54:=StringReplace(v54, ',', '.', [rfReplaceAll, rfIgnoreCase]);
    v54:=StringReplace(v54, '@', ',', [rfReplaceAll, rfIgnoreCase]);

    v54:='540'+IntToStr(Length(v54))+v54;

    // 58 - Country
    v58:='5802BR';     // Brasil

    // 59 - Merchant Name
    v59:='59'+IntTOStr(Length(trim(leftStr('Anderson Domanoski de Camargo',25))))+
              trim(leftStr('Anderson Domanoski de Camargo',25));

    // 60 - City
    v60:='600'+IntTOStr(Length(trim('CURITIBA')))+trim('CURITIBA');

    // 62 - Additional Data Field Template
    v62:='62070503***';

    // 63 - CRC16
    v63:='6304';

    // Preenche Campo com todos os dados Pix para Gerar o CRC16
    chavePIX:=v00+v26+v52+v53+v54+v58+v59+v60+v62+v63;
    chavePIX:=CalculaCRC16(chavePIX);

    // Pix tem q ser gerado QRCode com API do Google, a local ignora os "0 - Zeros"
    // e Gera Codigo Errado.
    try
      Application.ProcessMessages;

      FGoogleQRCode:=TFQRCodeAPIGoogle.Create(nil);
      FGoogleQRCode.GeraQRCode(chavePIX);
    finally
      Application.ProcessMessages;

      Imagem.Picture:=FGoogleQRCode.ImageQRCode.Picture;
      FGoogleQRCode.Free;

      Application.ProcessMessages;

      PCodigoPIX.Visible:=true;
      CodigoPIx.Clear;
      CodigoPIX.Text:=chavePIX;
    end;

  finally

  end;

end;

procedure TFPrincipal.Button1Click(Sender: TObject);
begin
  Clipboard.AsText:=CodigoPix.Text;
end;

function TFPrincipal.CalculaCRC16(valor: string): string;
var
  valorHex: string;
  auxCRC: string;
begin
  valorHex:=IntTOHex(Crc16(valor, $1021, $FFFF));

  auxCRC:=valorHex;
  result:=trim(valor)+auxCRC;
end;

// Função usada para Validar e Construir Informações de QRCode Usada no "PIX"
function TFPrincipal.Crc16(texto: string; Polynom: WORD = $1021; Seed: WORD = $FFFF): WORD;
var
  i, j: Integer;
begin
  Result := Seed;
  for i := 1 to length(texto) do
  begin
    Result := Result xor (ord(texto[i]) shl 8);
    for j := 0 to 7 do
    begin
      if (Result and $8000) <> 0 then
        Result := (Result shl 1) xor Polynom
      else
        Result := Result shl 1;
    end;
  end;
  Result := Result and $FFFF;
end;

end.
