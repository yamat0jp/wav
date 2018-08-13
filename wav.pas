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
      Add('�f�[�^�`���F' + waveFmtPcm.formatTag.ToString);
      Add('�`�����l�����F' + waveFmtPcm.channels.ToString);
      Add('�T���v�����O���g���F' + waveFmtPcm.sampleParSec.ToString);
      Add('�o�C�g���@/�@�b�F' + waveFmtPcm.bytesPerSec.ToString);
      Add('�o�C�g�� �w �`�����l�����F' + waveFmtPcm.blockAlign.ToString);
      Add('�r�b�g���@/�@�T���v���F' + waveFmtPcm.bitsPerSample.ToString);
    end;
    with waveFmtPcm do
    begin
      if channels <> 2 then
      begin
        Form2.ListBox1.Items.Add('�X�e���I�t�@�C����ΏۂƂ��Ă��܂�');
        Form2.ListBox1.Items.Add('�`�����l������' + channels.ToString);
        // result := -1;
      end;
      if formatTag <> 1 then
      begin
        Form2.ListBox1.Items.Add('�����k��PCM�̂ݑΏ�');
        Form2.ListBox1.Items.Add('�t�H�[�}�b�g�`����' + formatTag.ToString);
        result := -1;
      end;
      if bitsPerSample <> 16 then
      begin
        Form2.ListBox1.Items.Add('16�r�b�g�̂ݑΏ�');
        Form2.ListBox1.Items.Add('bit/sec��' + bitsPerSample.ToString);
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
      Form2.ListBox1.Items.Add('�ǂݍ��ݎ��s');
      fp.Free;
    end;
    else
      Form2.ListBox1.Items.Add('�J���܂���');
    result := -1;
    Exit;
  end;
  if CompareStr(waveFileHeader.hdrRiff, STR_RIFF) <> 0 then
  begin
    Form2.ListBox1.Items.Add('RIFF�t�H�[�}�b�g�łȂ�');
    result := -1;
    fp.Free;
    Exit;
  end;
  if CompareStr(waveFileHeader.hdrWave, STR_WAVE) <> 0 then
  begin
    Form2.ListBox1.Items.Add('"WAVE"���Ȃ�');
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
      Form2.ListBox1.Items.Add(Format('fmt �̒���%d[bytes]', [len]));
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
      Form2.ListBox1.Items.Add(Format('data�̒���:%d[bytes]', [sp.sizeOfData]));
      break;
    end
    else
    begin
      len := chank.sizeOfFmtData;
      Form2.ListBox1.Items.Add(chank.hdrFmtData + '�̒���[bytes]' + len.ToString);
      fPos := fp.Position;
      fp.Seek(len, soFromCurrent);
    end;
  end;
  fp.Free;
  result := 0;
end;

end.
