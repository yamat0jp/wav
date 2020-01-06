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
procedure resample(const filename: string);
procedure readFs(data: tWaveFormatPcm; var pcm: TMONO_PCM);
procedure mono_stereo(obj: TMemoryStream);

implementation

uses WriteHeader, wav;

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
  str: string;
  sp: SpParam;
  data: array [0..1] of UInt16;
  fmt: tWaveFormatPcm;
  x: Boolean;
begin
  makeSp(sp, filename);
  pcm.fs := sp.samplePerSec;
  pcm.bits := sp.bitsPerSample;
  s := TMemoryStream.Create;
  try
    s.LoadFromFile(filename);
    if sp.channels = 2 then
    begin
      sp.channels := 1;
      sp.sizeOfData := (s.Size - 44) div 2;
      waveHeaderWrite(s, sp);
      x:=true;
    end;
    pcm.length := sp.sizeOfData div 2;
    SetLength(pcm.s, pcm.length);
    for i := 0 to pcm.length - 1 do
    begin
      if x = true then
        s.ReadBuffer(data, 4)
      else
        s.ReadBuffer(data, 2);
      pcm.s[i] := data[0] / 32768.0;
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
  makeSp(sp, filename);
  sp.samplePerSec := pcm.fs;
  sp.bitsPerSample := pcm.bits;
  sp.sizeOfData := pcm.length * 2;
  sp.channels := 1;
  s := TMemoryStream.Create;
  try
    waveHeaderWrite(s, sp);
    s.Position := sp.posOfData;
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
  s: TMemoryStream;
  pcm: TMONO_PCM;
  header: WrSWaveFileHeader;
  i, j, k: integer;
  m: UInt16;
  n: Extended;
begin
  mono_wave_read(pcm, filename);
  s := TMemoryStream.Create;
  try
    s.LoadFromFile(filename);
    s.ReadBuffer(header, SizeOf(WrSWaveFileHeader));
    readFs(header.stWaveFormat, pcm);
    cut_num := Round(cut_wid * pcm.fs);
    cross_num := Round(cross_wid * pcm.fs);
    i := 0;
    k := header.sizeOfData div 2;
    while i < k do
    begin
      for j := i to i + pcm.fs do
      begin
        if j > k then
          break;
        n := pcm.s[j] / 2.0 * 65530.0;
        if n > 65530.0 then
          m := 65535
        else if n < 0.0 then
          m := 0
        else
          m := Round(n);
        s.WriteBuffer(m, SizeOf(UInt16));
      end;
      inc(i, pcm.fs);
    end;
    s.Position := 0;
    s.ReadBuffer(header, SizeOf(WrSWaveFileHeader));
    header.sizeOfData := s.Size - s.Position;
    s.Position := 0;
    s.WriteBuffer(header, SizeOf(WrSWaveFileHeader));
    s.SaveToFile('myfile.wav');
  finally
    s.Free;
    Finalize(pcm.s);
  end;
end;

procedure readFs(data: tWaveFormatPcm; var pcm: TMONO_PCM);
var
  ma: Single;
  a, b, p, pmax, pmin: integer;
  temp: Extended;
begin
  ma := 0.0;
  pcm.length := trunc(data.samplePerSec *
    data.bitsPerSample div data.channels * 0.01);
  pmin := trunc(data.samplePerSec * data.bitsPerSample * data.channels * 0.005);
  pmax := trunc(data.samplePerSec * data.bitsPerSample * data.channels * 0.02);
  p := pmin;
  for b := 0 to pmax - pmin - 1 do
  begin
    temp := 0.0;
    for a := 0 to pcm.length div 2 - 1 do
      temp := temp + pcm.s[a] * pcm.s[a + b];
    if (b > 0) and (temp > ma) then
    begin
      ma := temp;
      p := b;
    end;
  end;
  pcm.fs := p;
end;

procedure resample(const filename: string);
var
  pcm: TMONO_PCM;
  pitch: Single;
  header: WrSWaveFileHeader;
begin
  pitch := 4 / 3;
  mono_wave_read(pcm, filename);
  pcm.fs := Round(pcm.fs * pitch);
  pcm.length := Round(pcm.length / pitch);
  mono_wave_write(pcm, filename);
  Finalize(pcm.s);
end;

procedure mono_stereo(obj: TMemoryStream);
var
  s: TMemoryStream;
  data: packed array [0..1] of UInt16;
  i: Integer;
begin
  s := TMemoryStream.Create;
  try
    s.CopyFrom(obj, 0);
    s.Position := 0;
    obj.Clear;
    obj.CopyFrom(s, 44);
    for i := 0 to (s.Size-44) div 4 -1 do
    begin
      s.ReadBuffer(data,4);
      obj.WriteBuffer(data[0],2);
    end;
  finally
    s.Free;
  end;
end;

end.
