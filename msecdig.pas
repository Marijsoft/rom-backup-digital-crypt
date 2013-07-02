{
                     Rom Digital Crypt created by Team Marijsoft
                          www.marijsoftdevteam.blogspot.com
                             CodeName Version: WatchDogs Defeat
                                     Year:2013
                                  License: EUPL 1.1

}

unit msecdig;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Rtti, System.Classes,
  System.Variants, FMX.Types, FMX.Controls, FMX.Forms, FMX.Dialogs,
  FMX.StdCtrls, FMX.Objects, FMX.Edit, FMX.Effects, FMX.Filter.Effects,
  FMX.ListBox, FMX.Menus;

type
  TForm2 = class(TForm)
    Image4: TImage;
    SpeedButton1: TSpeedButton;
    Image1: TImage;
    Panel1: TPanel;
    Label1: TLabel;
    OpenDialog1: TOpenDialog;
    SaveDialog1: TSaveDialog;
    Edit1: TEdit;
    Label2: TLabel;
    CrumpleTransitionEffect1: TCrumpleTransitionEffect;
    Label3: TLabel;
    Label7: TLabel;
    ComboBox1: TComboBox;
    StyleBook1: TStyleBook;
    Label8: TLabel;
    SpeedButton2: TSpeedButton;
    Image6: TImage;
    Label9: TLabel;
    SpeedButton3: TSpeedButton;
    Image7: TImage;
    Label10: TLabel;
    SpeedButton4: TSpeedButton;
    Image2: TImage;
    Label4: TLabel;
    ListBoxItem1: TListBoxItem;
    ListBoxItem2: TListBoxItem;
    ListBoxItem3: TListBoxItem;
    ListBoxItem4: TListBoxItem;
    procedure SpeedButton1Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure CornerButton1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure MenuItem1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure aggiornachiavi;
end;

var
  Form2: TForm2;

implementation

{$R *.fmx}

uses LbCipher, LbClass, LbAsym, LbRSA, BTypes, aes_type, aes_cbc,
  {$IFDEF mswindows}Cromis.XTEA, {$ENDIF} LbProc;

type
  TEncryption = (e3DesCbc);
  TKey2048 = array [0 .. 15] of char8;

var
  Key128: TKey128;
  Key256: TKey256;

const
  pwd = '16104d6fd4cd31b1e68bba867ae84aebf67698a0';

const
  bufsize = $4000;

const
  Chiave: TKey2048 = 'ciao bello!!!';

var
  IV: TAESBlock;
  buffer: array [0 .. bufsize - 1] of byte;

procedure AESEncryptFile(var ptf, ctf: file; key: TKey2048; IV: TAESBlock);
var
  len: longint;
  err: integer;
  n: word;
  ctx: TAESContext;
begin
  len := filesize(ptf);
  err := AES_CBC_Init_Encr(key, 2048, IV, ctx);
  if err <> 0 then
  begin
    writeln('Encrypt init error: ', err);
    halt;
  end;
  blockwrite(ctf, IV, sizeof(IV));
  while len > 0 do
  begin
    if len > sizeof(buffer) then
      n := sizeof(buffer)
    else
      n := len;
    blockread(ptf, buffer, n);
    dec(len, n);
    err := AES_CBC_Encrypt(@buffer, @buffer, n, ctx);
    if err <> 0 then
    begin
      writeln('Encrypt error: ', err);
      halt;
    end;
    blockwrite(ctf, buffer, n);
  end;
  close(ptf);
  close(ctf);
end;

procedure encryptdes;
var
  ctf, ptf: file;
  i: integer;
begin
  filemode := 0;
  randomize;
  for i:=0 to 15 do IV[i] := random(256) and $FF;
  assign(ptf,'');  reset(ptf,1);
  assign(ctf,'backupdes.enc');  rewrite(ctf,1);
  AESEncryptFile(ptf, ctf, Chiave, IV);
end;

procedure AESDecryptFile(var ctf, ptf: file; key: TKey2048);
var
  len: longint;
  err: integer;
  n: word;
  ctx: TAESContext;
  IV: TAESBlock;
begin
  len := filesize(ctf) - sizeof(IV);
  blockread(ctf, IV, sizeof(IV));
  err := AES_CBC_Init_Decr(key, 2048, IV, ctx);
  if err <> 0 then
  begin
    writeln('Decrypt init error: ', err);
    halt;
  end;
  while len > 0 do
  begin
    if len > sizeof(buffer) then
      n := sizeof(buffer)
    else
      n := len;
    blockread(ctf, buffer, n);
    dec(len, n);
    err := AES_CBC_Decrypt(@buffer, @buffer, n, ctx);
    if err <> 0 then
    begin
      writeln('Decrypt error: ', err);
      halt;
    end;
    blockwrite(ptf, buffer, n);
  end;
  close(ptf);
  close(ctf);
end;

procedure descrypt;
var
  ctf, ptf: file;
  i: integer;
begin
  assign(ctf,'');  reset(ctf,1);
  assign(ptf,'androidbackup.ub');  rewrite(ptf,1);
  AESDecryptFile(ctf, ptf, Chiave);
end;

procedure TForm2.aggiornachiavi;
begin
  GenerateLMDKey(Key128, sizeof(Key128), Edit1.Text + pwd);
  GenerateLMDKey(Key256, sizeof(Key256), Edit1.Text + pwd);
  GenerateRandomKey(Key128, sizeof(Key128));
  GenerateRandomKey(Key256, sizeof(Key256));
  LbRSA.TLbRSAKey.Create(aks1024);
end;

procedure TForm2.Button1Click(Sender: TObject);
begin
  Edit1.Enabled := true;
end;

procedure TForm2.Button2Click(Sender: TObject);
var
  b: TLbBlowfish;
  ctf,ptf:TFileName;
  i:integer;
  begin
  FileMode:=0;
  Randomize;
  aggiornachiavi;
  b.GenerateKey(Edit1.Text);
  case ComboBox1.ItemIndex of
    0:
      TripleDESEncryptFileCBC(OpenDialog1.FileName, SaveDialog1.FileName,
        Key128, false);
    1:
      RNG32EncryptFile(OpenDialog1.FileName, SaveDialog1.FileName,
        StrToInt(Edit1.Text)); // <-da inserire solo password numerica
{$IFDEF mswindows}
    2:
      XTeaEncryptFile(OpenDialog1.FileName, SaveDialog1.FileName,
        GetBytesFromUnicodeString(Edit1.Text));
{$ENDIF}
    3:
      RNG64EncryptFile(OpenDialog1.FileName, SaveDialog1.FileName,
        StrToInt(Edit1.Text), StrToInt(pwd));
    4:
      RDLEncryptFileCBC(OpenDialog1.FileName, SaveDialog1.FileName, Key256,
        StrToInt(Edit1.Text), false);
    5:
      RSAEncryptFile(OpenDialog1.FileName, SaveDialog1.FileName,
        TLbRSAKey(Edit1.Text), false);
    6:
      b.DecryptFile(OpenDialog1.FileName, SaveDialog1.FileName);
    7: encryptdes;
  end;
end;

procedure TForm2.CornerButton1Click(Sender: TObject);
var
  b: TLbBlowfish;
begin
  aggiornachiavi;
  b.GenerateKey(Edit1.Text);
  case ComboBox1.ItemIndex of
    0:
      TripleDESEncryptFileCBC(OpenDialog1.FileName, SaveDialog1.FileName,
        Key128, true);
    1:
      RNG32EncryptFile(OpenDialog1.FileName, SaveDialog1.FileName,
        StrToInt(Edit1.Text + pwd)); // <-da inserire solo password numerica
{$IFDEF MSWINDOWS}
    2:
      XTeaDecryptFile(OpenDialog1.FileName, SaveDialog1.FileName,
        GetBytesFromUnicodeString(Edit1.Text + pwd)); {$ENDIF}
    3:
      RNG64EncryptFile(OpenDialog1.FileName, SaveDialog1.FileName,
        StrToInt(Edit1.Text), StrToInt(pwd));
    4:
      RDLEncryptFile(OpenDialog1.FileName, SaveDialog1.FileName, Key256,
        StrToInt(Edit1.Text), true);
    5:
      RSAEncryptFile(OpenDialog1.FileName, SaveDialog1.FileName,
        TLbRSAKey(Edit1.Text), true);
    6:
      b.EncryptFile(OpenDialog1.FileName, SaveDialog1.FileName);
    7:descrypt;
  end;

  CrumpleTransitionEffect1.AnimateFloat('Progress', 100, 0.5);
end;

procedure TForm2.MenuItem1Click(Sender: TObject);
begin
  // LbRSA.GenerateRSAKeys();
  // LbRSA.GenerateRSAKeysEx();
end;

procedure TForm2.SpeedButton1Click(Sender: TObject);
begin

{$IFDEF MSWINDOWS}
  OpenDialog1.Execute;
  SaveDialog1.Execute;
{$ENDIF}
{$IFDEF MACOS}
  OpenDialog1.Execute;
  Sleep(3000);
  SaveDialog1.Execute;
{$ENDIF}
end;

end.
