unit wav;

interface

uses
  System.Classes, System.SysUtils, spWav;

function readFmtChunk(fp: TFileStream; out waveFmtPcm: tWaveFormatPcm;
  out mes: string): integer;
function wavHdrRead(wavefile: PChar; var sp: SpParam; out mes: string): integer;

implementation

function readFmtChunk(fp: TFileStream; out waveFmtPcm: tWaveFormatPcm;
  out mes: string): integer;
var
  s: TStringList;
begin
  try
    fp.Position:=20*8;
    fp.ReadBuffer(waveFmtPcm, SizeOf(tWaveFormatPcm));
    s := TStringList.Create;
    s.Add('�f�[�^�`���F' + waveFmtPcm.formatTag.ToString);
    s.Add('�`�����l�����F' + waveFmtPcm.channels.ToString);
    s.Add('�T���v�����O���g���F' + waveFmtPcm.sampleParSec.ToString);
    s.Add('�o�C�g���@/�@�b�F' + waveFmtPcm.bytesPerSec.ToString);
    s.Add('�o�C�g�� �w �`�����l�����F' + waveFmtPcm.blockAlign.ToString);
    s.Add('�r�b�g���@/�@�T���v���F' + waveFmtPcm.bitsPerSample.ToString);
    with waveFmtPcm do
    begin
      if channels <> 2 then
      begin
        s.Add('�X�e���I�t�@�C����ΏۂƂ��Ă��܂�');
        s.Add('�`�����l������' + channels.ToString);
        result := -1;
      end;
      if formatTag <> 1 then
      begin
        s.Add('�����k��PCM�̂ݑΏ�');
        s.Add('�t�H�[�}�b�g�`����' + formatTag.ToString);
        result := -1;
      end;
      if bitsPerSample <> 16 then
      begin
        s.Add('16�r�b�g�̂ݑΏ�');
        s.Add('bit/sec��' + bitsPerSample.ToString);
        result := -1;
      end;
    end;
    mes := s.Text;
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
  Chunk: tChunk;
  fPos, len: integer;
  fp: TFileStream;
  i: integer;
  s: string;
begin
  try
    fp := TFileStream.Create(wavefile, fmOpenRead);
    fp.ReadBuffer(waveFileHeader, SizeOf(SWaveFileHeader));
  except
    on EReadError do
    begin
      mes := '�ǂݍ��ݎ��s';
      fp.Free;
    end;
    else
      mes := '�J���܂���';
    result := -1;
    Exit;
  end;
  if CompareStr(waveFileHeader.hdrRiff, STR_RIFF) <> 0 then
  begin
    mes := 'RIFF�t�H�[�}�b�g�łȂ�';
    result := -1;
    fp.Free;
    Exit;
  end;
  if CompareStr(waveFileHeader.hdrWave, STR_WAVE) <> 0 then
  begin
    mes := '"WAVE"���Ȃ�';
    result := -1;
    fp.Free;
    Exit;
  end;
  fPos := 0;
  len := waveFileHeader.sizeOfFile;
  while True do
  begin
    try
      fp.ReadBuffer(Chunk, SizeOf(tChunk));
    except
      on EReadError do
      begin
        result := 0;
        fp.Free;
        break;
      end;
    end;
    if CompareStr(Chunk.hdrFmtData, STR_fmt) = 0 then
    begin
      len := Chunk.sizeOfFmtData;
      mes := mes + Format('fmt �̒���%d[bytes]', [len]);
      fPos := fp.Position;
      i := readFmtChunk(fp, waveFmtPcm, s);
      mes := mes + s;
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
    else if CompareStr(Chunk.hdrFmtData, STR_data) = 0 then
    begin
      if Chunk.sizeOfFmtData = 0 then
      begin
        sp.sizeOfData := fp.Size - fp.Position;
        fp.Position := fPos + len;
        Chunk.sizeOfFmtData := sp.sizeOfData;
        fp.WriteBuffer(Chunk, SizeOf(tChunk));
      end
      else
        sp.sizeOfData := Chunk.sizeOfFmtData;
      sp.posOfData := fp.Position;
      mes := mes + Format('data�̒���:%d[bytes]', [sp.sizeOfData]);
      break;
    end
    else
    begin
      len := Chunk.sizeOfFmtData;
      mes := mes + Chunk.hdrFmtData + '�̒���[bytes]' + len.ToString;
      fPos := fp.Position;
      fp.Seek(len, soFromCurrent);
    end;
  end;
  fp.Free;
  result := 0;
end;

end.
