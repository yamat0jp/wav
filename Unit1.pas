unit Unit1;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  FMX.Media, FMX.Layouts, FMX.Objects, FMX.ListBox, spWav;

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
    ComboBox1: TComboBox;
    Timer1: TTimer;
    procedure PauseButtonClick(Sender: TObject);
    procedure StartButtonClick(Sender: TObject);
    procedure StopButtonClick(Sender: TObject);
    procedure RecordButtonClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ArcDial1Change(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    { private êÈåæ }
  public
    { public êÈåæ }
    Mic: TAudioCaptureDevice;
    Count: integer;
    procedure repair(fp: TFileStream; sp: SpParam);
  end;

var
  Form1: TForm1;

implementation

{$R *.fmx}

uses wav, effect, selectFile, WriteHeader, common;

procedure TForm1.StartButtonClick(Sender: TObject);
begin
  StartButton.HitTest := false;
  if PauseButton.IsPressed = true then
    Exit;
  if Sender = nil then
    MediaPlayer1.FileName := SaveDialog1.FileName
  else
    MediaPlayer1.FileName := Mic.FileName;
  if (MediaPlayer1.State = TMediaState.Stopped) and (MediaPlayer1.Media <> nil)
  then
    MediaPlayer1.Play;
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
  wh: WrSWaveFileHeader;
  wf: tWaveFormatPCM;
  fp: TFileStream;
  wave: TMyWave;
begin
  case ComboBox1.ItemIndex of
    0:
      begin
        if FileExists('temp.wav') = false then
          Exit;
        i := wavHdrRead(PChar(Mic.FileName), sp, s);
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
            StartButtonClick(nil);
          end;
        end;
        pMem.Free;
        Finalize(sp.pWav^);
      end;
    1:
      begin
        fp := TFileStream.Create('temp.wav', fmOpenReadWrite);
        try
          fp.ReadBuffer(wh, SizeOf(wh));
          ListBox1.Items.Clear;
          ListBox1.Items.Add(wh.hdrRiff);
          ListBox1.Items.Add(wh.hdrWave);
          ListBox1.Items.Add(wh.hdrFmt);
          if (wh.hdrWave = 'AVI ') and
            (MessageDlg('repaire?', TMsgDlgType.mtConfirmation,
            [TMsgDlgBtn.mbOK, TMsgDlgBtn.mbCancel], 0) = mrOK) then
          begin
            sp.sizeOfData := fp.Size - 44;
            repair(fp, sp);
          end;
        finally
          fp.Free;
        end;
      end;
    2:
      begin
        fp := TFileStream.Create('temp.wav', fmOpenRead);
        try
          readFmtChunk(fp, wf, s);
        finally
          fp.Free;
        end;
        ListBox1.Items.Text := s;
      end;
    3:
    begin
      wave:=TSpWave.Create('sample.wav',fmCreate);
      try
        wave.main(3,'100 20000');
      finally
        wave.Free;
      end;
    end;
  end;
end;

procedure TForm1.FormCreate(Sender: TObject);
var
  sp: SpParam;
  s: TFileStream;
begin
  Mic := TCaptureDeviceManager.Current.DefaultAudioCaptureDevice;
  Mic.FileName := 'temp.wav';
  ArcDial1.Value := MediaPlayer1.Volume;
  if FileExists('temp.wav') = false then
  begin
    s := TFileStream.Create('temp.wav', fmCreate);
    try
      repair(s, sp);
    finally
      s.Free;
    end;
  end;
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

procedure TForm1.Timer1Timer(Sender: TObject);
var
  i: Int64;
begin
  if MediaPlayer1.State = TMediaState.Playing then
  begin
    i := MediaPlayer1.CurrentTime;
    if (i > 0) and (Count = i) then
      StopButtonClick(Sender)
    else
      Count := i;
  end;
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

procedure TForm1.repair(fp: TFileStream; sp: SpParam);
begin
  sp.channels := 2;
  sp.samplePerSec := 44100;
  sp.bytesPerSec := 176400;
  sp.bitsPerSample := 16;
  sp.posOfData := waveHeaderWrite(fp, sp);
end;

end.
