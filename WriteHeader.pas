unit WriteHeader;

interface

uses System.Classes;

{$INCLUDE spWav}
function waveHeaderWrite(fp: TFileStream; sizeOfData: LongInt; ch: Byte;
  sampRate: LongWord; sampBits: Byte): integer;

implementation

function waveHeaderWrite(fp: TFileStream; sizeOfData: LongInt; ch: Byte;
  sampRate: LongWord; sampBits: Byte): integer;
var
  bytes: Byte;
  wrWavHdr: WrSWaveFileHeader;
  s: tWaveFormatPCM;
begin
  wrWavHdr.hdrRiff := STR_RIFF;
  wrWavHdr.sizeOfFile := sizeOfData + SizeOf(WrSWaveFileHeader) - 8;
  wrWavHdr.hdrWave := STR_WAVE;
  wrWavHdr.hdrFmt := STR_fmt;
  wrWavHdr.sizeOfFmt := SizeOf(tWaveFormatPCM);
  s.formatTag := 1;
  s.channels := ch;
  s.sampleParSec := sampRate;
  bytes := sampBits div 8;
  s.bytesPerSec := bytes * ch * sampRate;
  s.blockAlign := bytes * ch;
  s.bitsPerSample := sampBits;
  wrWavHdr.stWaveFormat := s;
  wrWavHdr.hdrData := STR_data;
  wrWavHdr.sizeOfData := sizeOfData;
  fp.WriteBuffer(wrWavHdr, SizeOf(WrSWaveFileHeader));
  result := fp.Position;
end;

end.
