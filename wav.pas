unit wav;

interface

uses
  System.Classes, System.SysUtils;

{$INCLUDE spWave}
function readFmtChank(fp: TFileStream; waveFmtPcm: tWaveFormatPcm): integer;
function wavHdrRead(wavefile: PChar; var sampRate, sampBits: SmallInt;
  var posOfData, sizeOfData: Cardinal): integer;

implementation

function readFmtChank(fp: TFileStream; waveFmtPcm: tWaveFormatPcm): integer;
begin
  result := 0;
  try
    fp.ReadBuffer(waveFmtPcm, SizeOf(tWaveFormatPcm));
    Writeln('データ形式：', waveFmtPcm.formatTag);
    Writeln('チャンネル数：', waveFmtPcm.channels);
    Writeln('サンプリング周波数：', waveFmtPcm.sampleParSec);
    Writeln('バイト数　/　秒：', waveFmtPcm.bytesPerSec);
    Writeln('バイト数 Ｘチャンネル数：', waveFmtPcm.blockAlign);
    Writeln('ビット数　/　サンプル：', waveFmtPcm.bitsPerSample);
  except
    on EReadError do
      result := -1;
  end;
end;

function wavHdrRead(wavefile: PChar; var sampRate, sampBits: SmallInt;
  var posOfData, sizeOfData: Cardinal): integer;
var
  waveFileHeader: SWaveFileHeader;
  waveFmtPcm: tWaveFormatPcm;
  chank: tChank;
  len: integer;
  fp: TFileStream;
begin
  try
    fp := TFileStream.Create(wavefile, fmOpenRead);
    fp.ReadBuffer(waveFileHeader, SizeOf(SWaveFileHeader));
  except
    on EReadError do
    begin
      Writeln('読み込み失敗');
      fp.Free;
    end;
    else
      Writeln('開けません');
    result := -1;
    Exit;
  end;
  Writeln(wavefile);
  if CompareStr(waveFileHeader.hdrRiff, STR_RIFF) <> 0 then
  begin
    Writeln('RIFFフォーマットでない');
    result := -1;
    fp.Free;
    Exit;
  end;
  if CompareStr(waveFileHeader.hdrWave, STR_WAVE) <> 0 then
  begin
    Writeln('"WAVE"がない');
    result := -1;
    fp.Free;
    Exit;
  end;
  while True do
  begin
    try
      fp.ReadBuffer(chank, SizeOf(tChank));
    except
      on EReadError do
      begin
        result := 0;
        fp.Free;
        break;
      end;
    end;
    if CompareStr(chank.hdrFmtData, STR_fmt) = 0 then
    begin
      len := chank.sizeOfFmtData;
      Writeln('fmt の長さ', len, '[bytes]');
      if readFmtChank(fp, waveFmtPcm) <> 0 then
      begin
        result := -1;
        fp.Free;
        Exit;
      end;
      sampRate := waveFmtPcm.sampleParSec;
      sampBits := waveFmtPcm.bytesPerSec;
    end
    else if CompareStr(chank.hdrFmtData, STR_data) = 0 then
    begin
      sizeOfData := chank.sizeOfFmtData;
      Writeln('dataの長さ:', sizeOfData, '[bytes]');
      posOfData := fp.Position;
      fp.Seek(sizeOfData - 4, soFromCurrent);
      break;
    end
    else
    begin
      len := chank.sizeOfFmtData;
      Writeln(chank.hdrFmtData, 'の長さ[bytes]', len);
      fp.Seek(len, soFromCurrent);
    end;
  end;
  fp.Free;
  result := 0;
end;

end.
