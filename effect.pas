unit effect;

interface

uses System.Classes, System.SysUtils, Math, spWav;

function effect8BitWav(const sp: SpParam): integer;
function effect16BitWav(const sp: SpParam): integer;
procedure usage;
function effectwav(const sp: SpParam): integer;

implementation

function effect8BitWav(const sp: SpParam): integer;
const
  depth = 1.0;
  rate = 170.0;
var
  i, delayStart: integer;
  k, m: Single;
  pMem, pCpy: array of Byte;
  s: TMemoryStream;
begin
  result := 0;
  try
    s := TMemoryStream.Create;
    s.Write(sp.pWav^, sp.sizeOfData);
    s.Position := 0;
    s.Read(Pointer(pCpy)^, sp.sizeOfData);
    pMem := sp.pWav;
    i := sp.posOfData;
    k := 8 * sp.sizeOfData / sp.bitsPerSample;
    while i < k do
    begin
      m := depth * sin(2 * pi * rate / sp.samplePerSec);
      pMem[i + 0] := trunc(m * pMem[i + 0]) + 128;
      pMem[i + 1] := trunc(m * pMem[i + 1]) + 128;
      inc(i, 2);
    end;
  except
    result := -1;
  end;
  s.Free;
  Finalize(pCpy);
end;

function effect16BitWav(const sp: SpParam): integer;
const
  j = 24;
var
  i, a, b, pmin, pmax, temp_size, offset0, offset1, p, q: integer;
  k, m, max, pitch, rate: Single;
  pMem, pCpy: array of SmallInt;
  r: array of Single;
  s: TMemoryStream;
begin
  result := 0;
  s := TMemoryStream.Create;
  try
    SetLength(pCpy, sp.sizeOfData);
    s.Write(sp.pWav^, sp.sizeOfData);
    s.Position := 0;
    s.Read(Pointer(pCpy)^, sp.sizeOfData);
    pMem := sp.pWav;
    i := sp.posOfData;
    k := 8 * sp.sizeOfData / sp.bitsPerSample;
    temp_size := trunc(sp.samplePerSec * 0.01);
    pmin := trunc(sp.samplePerSec * sp.bitsPerSample * 0.005);
    pmax := trunc(sp.samplePerSec * sp.bitsPerSample * 0.02);
    SetLength(r, pmax - pmin);
    offset0 := sp.posOfData;
    offset1 := sp.posOfData;
    rate := 1.5;
    while offset0 + pmax * 2 < sp.sizeOfData do
    begin
      max := 0.0;
      p := pmin;
      for b := pmin to pmax do
      begin
        r[b] := 0.0;
        for a := sp.posOfData to sp.posOfData + temp_size do
          r[b] := r[b] + pMem[a] * pCpy[a + b];
        if r[b] > max then
        begin
          max := r[b];
          p := b;
        end;
      end;
      for i := 0 to p do
      begin
        pMem[offset1 + i] := trunc(pCpy[offset0 + i]);
        pMem[offset1 + i + p] := trunc(pCpy[offset0 + i + p] * (p - i) / p) +
          trunc(pCpy[offset0 + p + i] * i / p);
      end;
      inc(offset0, q);
      inc(offset1, p + q);
    end;
    q := trunc(p / (rate - 1) + 0.5);
    for i := p to q do
    begin
      if offset0 + p + i > sp.sizeOfData then
        break;
      pMem[offset1 + p + i] := pCpy[offset0 + i];
    end;
    pitch := 0.66;
    while i < k do
    begin
      m := pitch * i;
      q := trunc(m);
      for a := q - j div 2 to q + j div 2 do
        if (m >= sp.posOfData) and (m < sp.sizeOfData) then
        begin
          pMem[a + 0] := trunc(pMem[a + 0] + pCpy[a + 0] *
            ArcSin(pi * (m - a)));
          pMem[a + 1] := trunc(pMem[a + 1] + pCpy[a + 1] *
            ArcSin(pi * (m - a)));
        end;
      inc(i, 2);
    end;
  except
    result := -1;
  end;
  Finalize(r);
  s.Free;
  Finalize(pCpy);
end;

procedure usage;
begin
  Writeln('のこぎり波');
  Writeln('例：effect.wav 100 2000');
end;

function effectwav(const sp: SpParam): integer;
begin
  if sp.channels = 1 then
  begin
    Writeln('ステレオファイルにしてください');
    result := -1;
  end;
  if sp.bitsPerSample = 8 then
    result := effect8BitWav(sp)
  else
    result := effect16BitWav(sp);
end;

end.
