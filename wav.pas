unit wav;

interface

uses
  System.Classes, System.SysUtils, spWav;

function readFmtChank(fp: TFileStream; out waveFmtPcm: tWaveFormatPcm): integer;
function wavHdrRead(wavefile: PChar; var sp: SpParam): integer;

implementation

uses Unit2;

function readFmtChank(fp: TFileStream; out waveFmtPcm: tWaveFormatPcm): integer;
begin
  result := 0;
  try
    fp.ReadBuffer(waveFmtPcm, SizeOf(tWaveFormatPcm));
    with Form2.ListBox1.Items do
    begin
      Add('データ形式：' + waveFmtPcm.formatTag.ToString);
      Add('チャンネル数：' + waveFmtPcm.channels.ToString);
      Add('サンプリング周波数：' + waveFmtPcm.sampleParSec.ToString);
      Add('バイト数　/　秒：' + waveFmtPcm.bytesPerSec.ToString);
      Add('バイト数 Ｘ チャンネル数：' + waveFmtPcm.blockAlign.ToString);
      Add('ビット数　/　サンプル：' + waveFmtPcm.bitsPerSample.ToString);
    end;
    with waveFmtPcm do
    begin
      if channels <> 2 then
      begin
        Form2.ListBox1.Items.Add('ステレオファイルを対象としています');
        Form2.ListBox1.Items.Add('チャンネル数は' + channels.ToString);
        // result := -1;
      end;
      if formatTag <> 1 then
      begin
        Form2.ListBox1.Items.Add('無圧縮のPCMのみ対象');
        Form2.ListBox1.Items.Add('フォーマット形式は' + formatTag.ToString);
        result := -1;
      end;
      if bitsPerSample <> 16 then
      begin
        Form2.ListBox1.Items.Add('16ビットのみ対象');
        Form2.ListBox1.Items.Add('bit/secは' + bitsPerSample.ToString);
        result := -1;
      end;
    end;
  except
    on EReadError do
      result := -1;
  end;
end;

function wavHdrRead(wavefile: PChar; var sp: SpParam): integer;
var
  waveFileHeader: SWaveFileHeader;
  waveFmtPcm: tWaveFormatPcm;
  chank: tChank;
  fPos, len: integer;
  fp: TFileStream;
begin
  Form2.ListBox1.Items.Clear;
  try
    fp := TFileStream.Create(wavefile, fmOpenReadWrite);
    fp.ReadBuffer(waveFileHeader, SizeOf(SWaveFileHeader));
  except
    on EReadError do
    begin
      Form2.ListBox1.Items.Add('読み込み失敗');
      fp.Free;
    end;
    else
      Form2.ListBox1.Items.Add('開けません');
    result := -1;
    Exit;
  end;
  if CompareStr(waveFileHeader.hdrRiff, STR_RIFF) <> 0 then
  begin
    Form2.ListBox1.Items.Add('RIFFフォーマットでない');
    result := -1;
    fp.Free;
    Exit;
  end;
  if CompareStr(waveFileHeader.hdrWave, STR_WAVE) <> 0 then
  begin
    Form2.ListBox1.Items.Add('"WAVE"がない');
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
      Form2.ListBox1.Items.Add(Format('fmt の長さ%d[bytes]', [len]));
      fPos := fp.Position;
      if readFmtChank(fp, waveFmtPcm) <> 0 then
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
      Form2.ListBox1.Items.Add(Format('dataの長さ:%d[bytes]', [sp.sizeOfData]));
      break;
    end
    else
    begin
      len := chank.sizeOfFmtData;
      Form2.ListBox1.Items.Add(chank.hdrFmtData + 'の長さ[bytes]' + len.ToString);
      fPos := fp.Position;
      fp.Seek(len, soFromCurrent);
    end;
  end;
  fp.Free;
  result := 0;
end;

end.
