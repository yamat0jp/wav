unit effect;

interface

uses System.Classes, System.SysUtils, Math, spWav;

function effect8BitWav(const sp: SpParam): integer;
function effect16BitWav(const sp: SpParam): integer;
function sinc(x: Single): Single;
procedure usage;
function effectwav(const sp: SpParam): integer;

implementation

function effect8BitWav(const sp: SpParam): integer;
const
  j = 24;
var
  i, a, b, pmin, pmax, temp_size, offset0, offset1, p, q: integer;
  k, m, ma, pitch, rate: Single;
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
    temp_size := trunc(sp.samplePerSec * sp.bitsPerSample * sp.channels * 0.01);
    pmin := trunc(sp.samplePerSec * sp.bitsPerSample * sp.channels * 0.005);
    pmax := trunc(sp.samplePerSec * sp.bitsPerSample * sp.channels * 0.02);
    SetLength(r, pmax - pmin);
    offset0 := sp.posOfData;
    offset1 := sp.posOfData;
    rate := 0.66;
    while offset0 + pmax * 2 < sp.sizeOfData do
    begin
      ma := 0.0;
      p := pmin;
      for b := 0 to pmax - pmin - 1 do
      begin
        r[b] := 0.0;
        for a := sp.posOfData to sp.posOfData + temp_size do
          r[b] := r[b] + pCpy[a] * pCpy[a + b];
        if r[b] > ma then
        begin
          ma := r[b];
          p := b;
        end;
      end;
      for i := 0 to p - 1 do
      begin
        pMem[offset1 + i] := pCpy[offset0 + i];
        pMem[offset1 + i + p] := trunc(pCpy[offset0 + p + i] * (p - i) / p +
          pCpy[offset0 + i] * i / p);
      end;
      q := trunc(rate * p / Abs(1.0 - rate) + 0.5);
      for i := p to q - 1 do
      begin
        if offset0 + i >= sp.sizeOfData then
          break;
        pMem[offset1 + p + i] := pCpy[offset0 + i];
      end;
      inc(offset0, q);
      inc(offset1, p + q);
    end;
    pitch := 1.5;
    for i := sp.posOfData to sp.sizeOfData do
    begin
      m := pitch * i;
      q := trunc(m);
      for a := q - j div 2 to q + j div 2 do
        if (m >= sp.posOfData) and (m < sp.sizeOfData) then
          pMem[a] := trunc(pMem[a + 0] + pCpy[a + 0] * sinc(pi * (m - a)));
    end;
  except
    result := -1;
  end;
  Finalize(r);
  s.Free;
  Finalize(pCpy);
end;

function effect16BitWav(const sp: SpParam): integer;
const
  j = 24;
var
  i, k, a, b, pmin, pmax, temp_size, offset0, offset1, p, q: integer;
  m, ma, pitch, rate: Single;
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
    temp_size := trunc(sp.samplePerSec * sp.bitsPerSample * sp.channels * 0.01);
    pmin := trunc(sp.samplePerSec * sp.bitsPerSample * sp.channels * 0.005);
    pmax := trunc(sp.samplePerSec * sp.bitsPerSample * sp.channels * 0.02);
    SetLength(r, pmax - pmin);
    offset0 := sp.posOfData;
    offset1 := sp.posOfData;
    rate := 0.66;
    k := sp.sizeOfData div sp.channels;
    while offset1 + 2 * pmax < k do
    begin
      ma := 0.0;
      p := pmin;
      for b := 0 to pmax - pmin - 1 do
      begin
        r[b] := 0.0;
        for a := sp.posOfData to sp.posOfData + temp_size do
          r[b] := r[b] + pCpy[a] * pCpy[a + b];
        if r[b] > ma then
        begin
          ma := r[b];
          p := b;
        end;
      end;
      for i := 0 to p do
      begin
        pMem[offset1 + i] := pCpy[offset0 + i];
        pMem[offset1 + i + p] := trunc(pCpy[offset0 + p + i] * (p - i) / p +
          pCpy[offset0 + i] * i / p);
      end;
      q := trunc(rate * p / (1.0 - rate) + 0.5);
      for i := p to q - 1 do
      begin
        if offset1 + i + p >= k then
          break;
        pMem[offset1 + p + i] := pCpy[offset0 + i];
      end;
      inc(offset0, q);
      inc(offset1, p + q);
    end;
    pitch := 1.5;
    for i := sp.posOfData to k - 1 do
    begin
      m := pitch * i;
      q := trunc(m);
      for a := q - j div 2 to q + j div 2 do
        if (a >= sp.posOfData) and (a < k) then
          pMem[i] := pMem[a] + pCpy[a] * trunc(sinc(pi * (m - a)));
    end;
  except
    result := -1;
  end;
  Finalize(pCpy);
  Finalize(r);
  s.Free;
end;

function sinc(x: Single): Single;
begin
  if x = 0 then
    result := 1.0
  else
    result := sin(x) / x;
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
