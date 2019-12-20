unit wav;

interface

uses
  System.Classes, System.SysUtils, spWav;

function readFmtChank(fp: TFileStream; out waveFmtPcm: tWaveFormatPcm; out mes: string): integer;
function wavHdrRead(wavefile: PChar; var sp: SpParam; out mes: string): integer;

implementation

uses Unit2;

function readFmtChank(fp: TFileStream; out waveFmtPcm: tWaveFormatPcm; out mes: string): integer;
var
  s: TStringList;
begin
  result := 0;
  try
    fp.ReadBuffer(waveFmtPcm, SizeOf(tWaveFormatPcm));
    s:=TStringList.Create;
    s.Add('データ形式：' + waveFmtPcm.formatTag.ToString);
    s.Add('チャンネル数：' + waveFmtPcm.channels.ToString);
    s.Add('サンプリング周波数：' + waveFmtPcm.sampleParSec.ToString);
    s.Add('バイト数　/　秒：' + waveFmtPcm.bytesPerSec.ToString);
    s.Add('バイト数 Ｘ チャンネル数：' + waveFmtPcm.blockAlign.ToString);
    s.Add('ビット数　/　サンプル：' + waveFmtPcm.bitsPerSample.ToString);
    with waveFmtPcm do
    begin
      if channels <> 2 then
      begin
        s.Add('ステレオファイルを対象としています');
        s.Add('チャンネル数は' + channels.ToString);
        result := -1;
      end;
      if formatTag <> 1 then
      begin
        s.Add('無圧縮のPCMのみ対象');
        s.Add('フォーマット形式は' + formatTag.ToString);
        result := -1;
      end;
      if bitsPerSample <> 16 then
      begin
        s.Add('16ビットのみ対象');
        s.Add('bit/secは' + bitsPerSample.ToString);
        result := -1;
      end;
    end;
    mes:=s.Text;
    s.Free;
  except
    on EReadError do
      result := -1;
  end;
end;

function wavHdrRead(wavefile: PChar; var sp: SpParam; out mes: string): integer;
var
  waveFileHeader: SWaveFileHeader;
  waveFmtPcm: tWaveFormatPcm;
  chank: tChank;
  fPos, len: integer;
  fp: TFileStream;
  i: integer;
  s: string;
begin
  try
    fp := TFileStream.Create(wavefile, fmOpenReadWrite);
    fp.ReadBuffer(waveFileHeader, SizeOf(SWaveFileHeader));
  except
    on EReadError do
    begin
      mes := '読み込み失敗';
      fp.Free;
    end;
    else
      mes := '開けません';
    result := -1;
    Exit;
  end;
  if CompareStr(waveFileHeader.hdrRiff, STR_RIFF) <> 0 then
  begin
    mes := 'RIFFフォーマットでない';
    result := -1;
    fp.Free;
    Exit;
  end;
  if CompareStr(waveFileHeader.hdrWave, STR_WAVE) <> 0 then
  begin
    mes := '"WAVE"がない';
    result := -1;
    fp.Free;
    Exit;
  end;
  fPos := 0;
  len := waveFileHeader.sizeOfFile;
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
      mes := mes + Format('fmt の長さ%d[bytes]', [len]);
      fPos := fp.Position;
      i:=readFmtChank(fp, waveFmtPcm,s);
      mes:=mes+s;
      if i <> 0 then
      begin
        result := -1;
        fp.Free;
        Exit;
      end;
      sp.samplePerSec := waveFmtPcm.sampleParSec;
      sp.bitsPerSample := waveFmtPcm.bitsPerSample;
      sp.channels := waveFmtPcm.channels;
      sp.bytesPerSec := waveFmtPcm.bytesPerSec;
      fp.Seek(fPos + len, soFromBeginning);
    end
    else if CompareStr(chank.hdrFmtData, STR_data) = 0 then
    begin
      if chank.sizeOfFmtData = 0 then
      begin
        sp.sizeOfData := fp.Size - fp.Position;
        fp.Position := fPos + len;
        chank.sizeOfFmtData := sp.sizeOfData;
        fp.WriteBuffer(chank, SizeOf(tChank));
      end
      else
        sp.sizeOfData := chank.sizeOfFmtData;
      sp.posOfData := fp.Position;
      mes := mes + Format('dataの長さ:%d[bytes]', [sp.sizeOfData]);
      break;
    end
    else
    begin
      len := chank.sizeOfFmtData;
      mes := mes + chank.hdrFmtData + 'の長さ[bytes]' + len.ToString;
      fPos := fp.Position;
      fp.Seek(len, soFromCurrent);
    end;
  end;
  fp.Free;
  result := 0;
end;

end.
