unit WriteHeader;

interface

uses System.Classes, System.SysUtils, spWav;

function waveHeaderWrite(fp: TStream; const sp: SpParam): integer;

implementation

uses effect, hanning;

function waveHeaderWrite(fp: TStream; const sp: SpParam): integer;
var
  bytes: Byte;
  wrWavHdr: WrSWaveFileHeader;
  s: tWaveFormatPCM;
begin
  wrWavHdr.hdrRiff := STR_RIFF;
  wrWavHdr.sizeOfFile := sp.sizeOfData + SizeOf(WrSWaveFileHeader) - 8;
  wrWavHdr.hdrWave := STR_WAVE;
  wrWavHdr.hdrFmt := STR_fmt;
  wrWavHdr.sizeOfFmt := SizeOf(tWaveFormatPCM);
  s.channels:=sp.channels;
  s.sampleParSec:=sp.samplePerSec;
  s.formatTag := 1;
  bytes := sp.bitsPerSample;
  s.bytesPerSec := bytes * sp.channels * sp.samplePerSec div 8;
  s.blockAlign := bytes * sp.channels div 8;
  s.bitsPerSample := sp.bitsPerSample;
  wrWavHdr.stWaveFormat := s;
  wrWavHdr.hdrData := STR_data;
  wrWavHdr.sizeOfData := sp.sizeOfData;
  fp.Position:=0;
  fp.WriteBuffer(wrWavHdr, SizeOf(WrSWaveFileHeader));
  result := fp.Position;
end;

end.
