unit WriteHeader;

interface

uses System.Classes, System.SysUtils, spWav;

function waveHeaderWrite(fp: TFileStream; const sp: SpParam): integer;
function wavWrite(inFile, outFile: PChar; const wHdr: WrSWaveFileHeader;
  var sp: SpParam): integer;

implementation

uses effect;

function waveHeaderWrite(fp: TFileStream; const sp: SpParam): integer;
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
  s.formatTag := 1;
  s.channels := sp.channels;
  s.sampleParSec := sp.samplePerSec;
  bytes := sp.bitsPerSample div 8;
  s.bytesPerSec := bytes * sp.channels * sp.samplePerSec;
  s.blockAlign := bytes * sp.channels;
  s.bitsPerSample := sp.bitsPerSample;
  wrWavHdr.stWaveFormat := s;
  wrWavHdr.hdrData := STR_data;
  wrWavHdr.sizeOfData := sp.sizeOfData;
  fp.WriteBuffer(wrWavHdr, SizeOf(WrSWaveFileHeader));
  result := fp.Position;
end;

function wavDataWrite(fpIn, fpOut: TFileStream; const sp: SpParam): integer;
var
  pInMem, pOutMem: TMemoryStream;
begin
  result := 0;
  fpIn.Position := sp.sizeOfData;
  pInMem := TMemoryStream.Create;
  pOutMem := TMemoryStream.Create;
  try
    pInMem.CopyFrom(fpIn, 0);
    pOutMem.CopyFrom(fpIn, 0);
    if sp.bitsPerSample = 8 then
      result := effect8BitWav(pInMem, pOutMem, sp)
    else
      result := effect16BitWav(pInMem, pOutMem, sp);
    fpOut.CopyFrom(pOutMem, 0);
  except
    on EReadError do
      result := -1;
    on EWriteError do
      result := -1;
  end;
  pInMem.Free;
  pOutMem.Free;
end;

function wavWrite(inFile, outFile: PChar; const wHdr: WrSWaveFileHeader;
  var sp: SpParam): integer;
var
  fpIn, fpOut: TFileStream;
begin
  result := 0;
  try
    fpIn := TFileStream.Create(inFile, fmOpenRead);
    fpOut := TFileStream.Create(outFile, fmCreate);
    if wavDataWrite(fpIn, fpOut, sp) = -1 then
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
  fpIn.Free;
  fpOut.Free;
end;

end.
