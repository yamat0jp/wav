program wav_proj;

{$APPTYPE CONSOLE}
{$R *.res}

uses
  System.SysUtils,
  System.Classes,
  spWav in 'spWav.pas',
  effect in 'effect.pas',
  WriteHeader in 'WriteHeader.pas';

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
    if wavWrite(PChar(ParamStr(1)), PChar(ParamStr(2)), hdrHeader, sp) = -1 then
      Exit;
    Writeln('完了');
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;

end.
