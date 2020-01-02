unit hanning;

interface

uses System.Classes, System.SysUtils, spWav;

type
  TMONO_PCM = record
    fs: integer;
    bits: integer;
    length: integer;
    s: array of Single;
  end;

  TDFT = record
    length: integer;
    sinpuku, isou: array of Single;
  end;

procedure hanning_window(out pcm: TMONO_PCM; n: integer);
procedure mono_wave_read(out pcm: TMONO_PCM; filename: string);
procedure mono_wave_write(pcm: TMONO_PCM; filename: string);
procedure dft(const pcm: TMONO_PCM; out dft: TDFT);
procedure timeStretch(const filename: string; const cut_wid: Single = 0.06;
  const cross_wid: Single = 0.03);
procedure readFs(data: tWaveFormatPcm; var pcm: TMONO_PCM);

implementation

uses WriteHeader;

procedure hanning_window(out pcm: TMONO_PCM; n: integer);
var
  i: integer;
begin
  SetLength(pcm.s, n);
  if n div 2 = 0 then
    for i := 0 to n do
      pcm.s[i] := 0.5 - 0.5 * cos(2.0 * pi * i / n)
  else
    for i := 0 to n do
      pcm.s[i] := 0.5 - 0.5 * cos(2.0 * pi * (i + 0.5) / n);
end;

procedure mono_wave_read(out pcm: TMONO_PCM; filename: string);
var
  s: TMemoryStream;
  i: integer;
  data: UInt16;
begin
  s := TMemoryStream.Create;
  try
    s.LoadFromFile(filename);
    s.Position := 24;
    s.ReadBuffer(pcm.fs, 4);
    s.Position := s.Position + 6;
    s.ReadBuffer(data, 2);
    pcm.bits := data;
    s.Position := s.Position + 4;
    s.ReadBuffer(pcm.length, 4);
    pcm.length := pcm.length div 2;
    SetLength(pcm.s, pcm.length);
    for i := 0 to pcm.length div 2 - 1 do
    begin
      s.ReadBuffer(data, 2);
      pcm.s[i] := data / 32768.0;
    end;
  finally
    s.Free;
  end;
end;

procedure mono_wave_write(pcm: TMONO_PCM; filename: string);
var
  s: TMemoryStream;
  i: integer;
  data: Single;
  m: UInt16;
  sp: SpParam;
begin
  sp.channels := 1;
  sp.samplePerSec := pcm.fs;
  sp.bitsPerSample := pcm.bits;
  sp.sizeOfData := pcm.length * 2;
  s := TMemoryStream.Create;
  try
    waveHeaderWrite(s, sp);
    for i := 0 to pcm.length - 1 do
    begin
      data := pcm.s[i] / 2.0 * 65536.0;
      if data > 65535.0 then
        data := 65535.0
      else if data < 0.0 then
        data := 0.0;
      m := Round(data);
      s.WriteBuffer(m, 2);
    end;
    s.SaveToFile(filename);
  finally
    s.Free;
  end;
end;

procedure dft(const pcm: TMONO_PCM; out dft: TDFT);
var
  i, j: integer;
  x_real, x_image: array of Single;
  real, image: Single;
  han: TMONO_PCM;
begin
  dft.length := pcm.length div 2;
  hanning_window(han, pcm.length);
  SetLength(x_real, pcm.length);
  SetLength(x_image, pcm.length);
  SetLength(dft.sinpuku, dft.length);
  SetLength(dft.isou, dft.length);
  for i := 0 to pcm.length - 1 do
  begin
    x_real[i] := pcm.s[i] * han.s[i];
    x_image[i] := 0;
  end;
  for i := 0 to dft.length - 1 do
  begin
    for j := 0 to pcm.length - 1 do
    begin
      real := cos(2.0 * pi * i * j / pcm.length);
      image := -sin(2.0 * pi * i * j / pcm.length);
      dft.sinpuku[i] := dft.sinpuku[i] + x_real[j] * real - x_image[j] * image;
      dft.isou[i] := dft.isou[i] + x_real[j] * image + x_image[j] * real;
    end;
    dft.sinpuku[i] := Sqrt(dft.sinpuku[i] * dft.sinpuku[i] + dft.isou[i] *
      dft.isou[i]);
    dft.isou[i] := arctan(dft.isou[i] / dft.sinpuku[i]);
  end;
  Finalize(han.s);
  Finalize(x_real);
  Finalize(x_image);
end;

procedure timeStretch(const filename: string; const cut_wid: Single = 0.06;
  const cross_wid: Single = 0.03);
var
  cut_num, cross_num: integer;
  s, s1: TMemoryStream;
  pcm: TMONO_PCM;
  header: WrSWaveFileHeader;
  p: PByte;
  buffer: array of Byte;
  i: integer;
begin
  s := TMemoryStream.Create;
  s1 := TMemoryStream.Create;
  try
    s.LoadFromFile(filename);
    s.ReadBuffer(header, SizeOf(WrSWaveFileHeader));
    p := s.Memory;
    pcm.s := Pointer(p + s.Position);
    pcm.length := header.sizeOfData div 2;
    readFs(header.stWaveFormat, pcm);
    SetLength(buffer, pcm.fs div 2);
    cut_num := Round(cut_wid * pcm.fs);
    cross_num := Round(cross_wid * pcm.fs);
    s1.CopyFrom(s, s.Size - s.Position);
    s.Position:=SizeOf(WrSWaveFileHeader);
    s1.Position := 0;
    for i := 0 to pcm.length * 2 div pcm.fs do
    begin
      s1.ReadBuffer(Pointer(buffer)^, length(buffer));
      s1.Position := s1.Position - length(buffer) div 2;
      s.WriteBuffer(Pointer(buffer)^, length(buffer));
    end;
    s.SaveToFile('myfile.wav');
  finally
    s.Free;
    s1.Free;
    Finalize(pcm.s);
    Finalize(buffer);
  end;
end;

procedure readFs(data: tWaveFormatPcm; var pcm: TMONO_PCM);
var
  ma: Single;
  i, a, b, p, pmax, pmin: integer;
  temp: Extended;
begin
  ma := 0.0;
  i := trunc(data.bitsPerSample * data.bitsPerSample * data.channels * 0.01);
  pmin := trunc(data.samplePerSec * data.bitsPerSample * data.channels * 0.005);
  pmax := trunc(data.samplePerSec * data.bitsPerSample * data.channels * 0.02);
  p := pmin;
  for b := 0 to pmax - pmin - 1 do
  begin
    temp := 0.0;
    for a := 0 to i - 1 do
      temp := temp + pcm.s[a] * pcm.s[a + b];
    if temp > ma then
    begin
      ma := temp;
      p := b;
    end;
  end;
  pcm.fs := p;
end;

end.
