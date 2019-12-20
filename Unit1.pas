unit Unit1;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  FMX.Media, FMX.Layouts, FMX.Objects, FMX.ListBox;

type
  TForm1 = class(TForm)
    MediaPlayer1: TMediaPlayer;
    ArcDial1: TArcDial;
    StartButton: TSpeedButton;
    PauseButton: TSpeedButton;
    StopButton: TSpeedButton;
    FlowLayout1: TFlowLayout;
    GridLayout1: TGridLayout;
    FlowLayout2: TFlowLayout;
    Image1: TImage;
    RecordButton: TSpeedButton;
    Image2: TImage;
    Image3: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Button1: TButton;
    ProgressBar1: TProgressBar;
    SaveDialog1: TSaveDialog;
    ListBox1: TListBox;
    procedure PauseButtonClick(Sender: TObject);
    procedure StartButtonClick(Sender: TObject);
    procedure StopButtonClick(Sender: TObject);
    procedure RecordButtonClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ArcDial1Change(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    { private êÈåæ }
  public
    { public êÈåæ }
    Mic: TAudioCaptureDevice;
  end;

var
  Form1: TForm1;

implementation

{$R *.fmx}

uses spWav, wav, effect, selectFile;

procedure TForm1.StartButtonClick(Sender: TObject);
begin
  StartButton.HitTest := false;
  if PauseButton.IsPressed = true then
    Exit;
  if (MediaPlayer1.State = TMediaState.Stopped) and (MediaPlayer1.Media <> nil)
  then
    if MediaPlayer1.State = TMediaState.Stopped then
    begin
      if Sender = nil then
        MediaPlayer1.FileName := SaveDialog1.FileName
      else
        MediaPlayer1.FileName := Mic.FileName;
      MediaPlayer1.Play;
    end;
end;

procedure TForm1.ArcDial1Change(Sender: TObject);
begin
  MediaPlayer1.Volume := ArcDial1.Value;
end;

procedure TForm1.Button1Click(Sender: TObject);
var
  sp: SpParam;
  pMem: TMemoryStream;
  s: string;
  i: integer;
begin
  if FileExists('temp.wav') = false then
    Exit;
  i:=wavHdrRead(PChar(Mic.FileName), sp, s);
  ListBox1.Items.Text := s;
  if i < 0 then
    Exit;
  if readWav(Mic.FileName, pMem) = false then
    Exit;
  sp.pWav := pMem.Memory;
  if effectWav(sp) = 0 then
  begin
    pMem.SaveToFile('effect.wav');
    SaveDialog1.Filter := Mic.FilterString;
    if SaveDialog1.Execute = true then
    begin
      pMem.SaveToFile(SaveDialog1.FileName);
      StartButtonClick(Sender);
    end;
  end;
  pMem.Free;
  Finalize(sp.pWav^);
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  Mic := TCaptureDeviceManager.Current.DefaultAudioCaptureDevice;
  Mic.FileName := 'temp.wav';
  ArcDial1.Value := MediaPlayer1.Volume;
end;

procedure TForm1.PauseButtonClick(Sender: TObject);
begin
  if StartButton.IsPressed = false then
    Exit;
  if MediaPlayer1.Media <> nil then
    if MediaPlayer1.State = TMediaState.Playing then
      MediaPlayer1.Stop
    else
      MediaPlayer1.Play;
end;

procedure TForm1.StopButtonClick(Sender: TObject);
begin
  if (Mic <> nil) and (Mic.State = TCaptureDeviceState.Capturing) then
  begin
    Mic.StopCapture;
    Image1.Opacity := 0;
  end
  else
  begin
    MediaPlayer1.Stop;
    MediaPlayer1.CurrentTime := 0;
  end;
  StartButton.IsPressed := false;
  RecordButton.IsPressed := false;
  StartButton.HitTest := true;
end;

procedure TForm1.RecordButtonClick(Sender: TObject);
begin
  if Mic <> nil then
  begin
    Mic.StartCapture;
    StartButton.IsPressed := true;
    Image1.Opacity := 1;
  end;
end;

end.
