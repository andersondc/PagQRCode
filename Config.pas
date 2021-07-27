unit Config;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls;

type
  TFConfig = class(TForm)
    Panel1: TPanel;
    GroupBox1: TGroupBox;
    Panel2: TPanel;
    GroupBox2: TGroupBox;
    Button1: TButton;
    Label27: TLabel;
    vTokenPicPay: TEdit;
    Label46: TLabel;
    Label45: TLabel;
    vTokenSeller: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    vPix: TEdit;
    vTel: TCheckBox;
    ListConfig: TListBox;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FConfig: TFConfig;
  vCaminho: string;

implementation

{$R *.dfm}

procedure TFConfig.Button1Click(Sender: TObject);
begin
  ListConfig.Clear;

  ListConfig.Items.Add(vTokenPicPay.Text);
  ListConfig.Items.Add(vTokenSeller.Text);
  ListConfig.Items.Add(vPix.Text);

  if vTel.Checked=true then
    ListConfig.Items.Add('1')
  else
    ListConfig.Items.Add('0');

  ListConfig.Items.SaveToFile(vCaminho+'\Config.ini');

  close;
end;

procedure TFConfig.FormCreate(Sender: TObject);
begin
  vCaminho:=ExtractFileDir(GetCurrentDir);
end;

procedure TFConfig.FormShow(Sender: TObject);
begin
  if FileExists(vCaminho+'\Config.ini') then
  begin
    ListConfig.Items.LoadFromFile(vCaminho+'\Config.ini');
    vTokenPicPay.Text:=ListConfig.Items.Strings[0];
    vTokenSeller.Text:=ListConfig.Items.Strings[1];
    vPix.Text:=ListConfig.Items.Strings[2];
    if ListConfig.Items.Strings[3]='1' then
      vTel.Checked:=true
    else
      vTel.Checked:=false
  end;
end;



end.
