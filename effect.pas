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
begin
end;

function effect16BitWav(const sp: SpParam): integer;
const
  j = 24;
var
  i, k, a, b, pmin, pmax, temp_size, offset0, offset1, p, q: integer;
  m, ma, pitch, rate: Single;
  pMem, pCpy: array of SmallInt;
  r: array of Single;
begin
  result := 0;
  try
    pMem := sp.pWav;
    temp_size := trunc(sp.samplePerSec * sp.bitsPerSample * sp.channels * 0.01);
    pmin := trunc(sp.samplePerSec * sp.bitsPerSample * sp.channels * 0.005);
    pmax := trunc(sp.samplePerSec * sp.bitsPerSample * sp.channels * 0.02);
    SetLength(r, pmax - pmin);
    offset0 := sp.posOfData;
    offset1 := sp.posOfData;
    rate := 0.66;
    SetLength(pCpy, sp.sizeOfData);
    k := (sp.sizeOfData - sp.posOfData) div sp.channels;
    for b := 0 to pmax - pmin - 1 do
    begin
      r[b] := 0.0;
      for a := sp.posOfData to sp.posOfData + temp_size do
        r[b] := r[b] + pMem[a] * pMem[a + b];
      if r[b] > ma then
      begin
        ma := r[b];
        p := b;
      end;
    end;
    while offset1 + 2 * pmax < k do
    begin
      ma := 0.0;
      p := pmin;
      for i := 0 to p do
      begin
        pCpy[offset1 + i] := pMem[offset0 + i];
        pCpy[offset1 + i + p] := trunc(pMem[offset0 + p + i] * (p - i) / p +
          pMem[offset0 + i] * i / p);
      end;
      q := trunc(rate * p / (1.0 - rate) + 0.5);
      for i := p to q - 1 do
      begin
        if offset1 + i + p >= k then
          break;
        pCpy[offset1 + p + i] := pMem[offset0 + i];
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
          pMem[i] := pCpy[a] + pMem[a] * trunc(sinc(pi * (m - a)))
        else
          pMem[i] := 0;
    end;
  except
    result := -1;
  end;
  Finalize(pCpy);
  Finalize(r);
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
    // result := -1;
  end;
  if sp.bitsPerSample = 8 then
    result := effect8BitWav(sp)
  else
    result := effect16BitWav(sp);
end;

end.
