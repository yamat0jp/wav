unit WriteHeader;

interface

uses System.Classes, System.SysUtils, spWav;

function waveHeaderWrite(fp: TStream; const sp: SpParam): integer;
procedure makeSp(var sp: SpParam; filename: string); overload;
procedure makeSp(var sp: SpParam; header: WrSWaveFileHeader); overload;

implementation

uses effect, hanning;

function waveHeaderWrite(fp: TStream; const sp: SpParam): integer;
var
  bytes: Byte;
  wrWavHdr: WrSWaveFileHeader;
  s: tWaveFormatPCM;
  m: TMemoryStream;
begin
  wrWavHdr.hdrRiff := STR_RIFF;
  wrWavHdr.sizeOfFile := sp.sizeOfData + SizeOf(WrSWaveFileHeader) - 8;
  wrWavHdr.hdrWave := STR_WAVE;
  wrWavHdr.hdrFmt := STR_fmt;
  wrWavHdr.sizeOfFmt := SizeOf(tWaveFormatPCM);
  s.channels := sp.channels;
  s.samplePerSec := sp.samplePerSec;
  s.formatTag := 1;
  bytes := sp.bitsPerSample;
  s.bytesPerSec := bytes * sp.channels * sp.samplePerSec div 8;
  s.blockAlign := bytes * sp.channels div 8;
  s.bitsPerSample := sp.bitsPerSample;
  wrWavHdr.stWaveFormat := s;
  wrWavHdr.hdrData := STR_data;
  wrWavHdr.sizeOfData := sp.sizeOfData;
  fp.Position := 0;
  fp.WriteBuffer(wrWavHdr, SizeOf(WrSWaveFileHeader));
  fp.Size := wrWavHdr.sizeOfFile;
  m := TMemoryStream.Create;
  try
    fp.Position := 0;
    m.CopyFrom(fp, fp.Size);
    if fp is TFileStream then
      m.SaveToFile((fp as TFileStream).FileName)
    else
    begin
      (fp as TMemoryStream).Clear;
      fp.CopyFrom(m,0);
    end;
  finally
    m.Free;
  end;
  result := 1;
end;

procedure makeSp(var sp: SpParam; filename: string);
var
  fp: TFileStream;
  header: WrSWaveFileHeader;
begin
  fp:=TFileStream.Create(filename,fmOpenRead);
  try
    fp.ReadBuffer(header,SizeOf(WrSWaveFileHeader));
    makeSp(sp,header);
  finally
    fp.Free;
  end;
end;

procedure makeSp(var sp: SpParam; header: WrSWaveFileHeader);
var
  s: tWaveFormatPCM;
  bytes: Byte;
begin
  sp.samplePerSec:=header.stWaveFormat.samplePerSec;
  sp.bitsPerSample:=header.stWaveFormat.bitsPerSample;
  sp.sizeOfData:=header.sizeOfData;
  sp.channels:=header.stWaveFormat.channels;
  sp.bytesPerSec:=header.stWaveFormat.bytesPerSec;
  sp.posOfData:=44;
end;

end.
