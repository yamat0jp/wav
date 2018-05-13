program wav_proj;

{$APPTYPE CONSOLE}
{$R *.res}

uses
  System.SysUtils,
  System.Classes,
  spWav in 'spWav.pas';

function wavDataWrite(fpOut: TFileStream; const sp: SpParam): integer;
var
  i: integer;
  s, tempsamplePerCycle, deltaAdd, curLevel: Single;
  curSampling, samplePerCycle: LongInt;
  c: array [0..1] of ShortInt;
begin
  tempsamplePerCycle:=sp.samplePerSec*sp.cycleuSec div 1000000;
  samplePerCycle:=Trunc(tempsamplePerCycle);
  if samplePerCycle <= 0 then
  begin
    Writeln('周波数が高すぎ');
    result:=-1;
    Exit;
  end;
  deltaAdd:=65535/samplePerCycle;
  curLevel:=0;
  curSampling:=0;
  i:=0;
  s:=sp.sizeOfData/SizeOf(@c);
  while i < s do
  begin
    inc(i);
    c[0]:=ShortInt(Trunc(curLevel-32788));
    c[1]:=c[0];
    fpOut.WriteBuffer(c,SizeOf(@c));
    curLevel:=curLevel+deltaAdd;
    inc(curSampling);
    if curSampling > samplePerCycle then
    begin
      curLevel:=0;
      curSampling:=0;
    end;
  end;
end;

function wavWrite(outFile: PChar; const wHdr: WrSWaveFileHeader;
  var sp: SpParam): integer;
var
  fpIn, fpOut: TFileStream;
begin
  result := 0;
  try
    fpOut := TFileStream.Create(outFile, fmCreate);
    fpOut.WriteBuffer(wHdr, SizeOf(WrSWaveFileHeader));
    if wavDataWrite(fpOut, sp) = -1 then
      raise EWriteError.Create('');
  except
    on EFOpenError do
    begin
      Writeln(outFile, 'をオープンできません');
      result := -1;
    end;
    on EWriteError do
    begin
      Writeln('ヘッダを書き込めません');
      result := -1;
    end;
  end;
  fpOut.Free;
end;

procedure usage;
begin
  Writeln('のこぎり波');
  Writeln('例：effect.wav 100 2000');
end;

procedure setupHeader(var wHdr: WrSWaveFileHeader; var sp: SpParam);
var
  bytes: Byte;
begin
  wHdr.hdrRiff := STR_RIFF;
  wHdr.sizeOfFile := sp.sizeOfData + SizeOf(WrSWaveFileHeader) - 8;
  wHdr.hdrWave := STR_WAVE;
  wHdr.hdrFmt := STR_fmt;
  wHdr.sizeOfFmt := SizeOf(tWaveFormatPcm);
  wHdr.stWaveFormat.formatTag := 1;
  wHdr.stWaveFormat.channels := sp.channels;
  wHdr.stWaveFormat.sampleParSec := sp.samplePerSec;
  bytes := sp.bitsPerSample div 8;
  wHdr.stWaveFormat.bytesPerSec := bytes * sp.channels * sp.samplePerSec;
  wHdr.stWaveFormat.blockAlign := bytes * sp.channels;
  wHdr.stWaveFormat.bitsPerSample := sp.bitsPerSample;
  wHdr.hdrData := STR_data;
  wHdr.sizeOfData := sp.sizeOfData;
end;

var
  sp: SpParam;
  totalLength: integer;
  hdrHeader: WrSWaveFileHeader;

begin
  try
    { TODO -oUser -cConsole メイン : ここにコードを記述してください }
    if ParamCount <> 3 then
    begin
      usage;
      Exit;
    end;
    totalLength := StrToInt(ParamStr(2));
    sp.cycleuSec := StrToInt(ParamStr(3));
    sp.channels := WAV_STEREO;
    sp.samplePerSec := 44100;
    sp.bitsPerSample := 16;
    sp.sizeOfData := sp.bitsPerSample * sp.channels * sp.samplePerSec *
      totalLength div 8;
    setupHeader(hdrHeader, sp);
    if wavWrite(PChar(ParamStr(1)), hdrHeader, sp) = -1 then
      Exit;
    Writeln('完了');
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;

end.
