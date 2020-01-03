unit effect;

interface

uses System.Classes, System.SysUtils, Math, spWav;

function effect16BitWav(const sp: SpParam): integer;
function sinc(x: Single): Single;

implementation

uses Unit2;

function effect16BitWav(const sp: SpParam): integer;
const
  j = 24;
var
  i, a, b, pmin, pmax: integer;
  len, temp_size, offset0, offset1, p, q: integer;
  m, ma, pitch, rate: Single;
  pMem, pCpy, pRes: array of Int16;
  s: TMemoryStream;
  r: array of Single;
begin
  result := 0;
  try
    temp_size := trunc(sp.samplePerSec * sp.bitsPerSample * sp.channels * 0.01);
    pmin := trunc(sp.samplePerSec * sp.bitsPerSample * sp.channels * 0.005);
    pmax := trunc(sp.samplePerSec * sp.bitsPerSample * sp.channels * 0.02);
    SetLength(r, pmax - pmin);
    offset0 := 0;
    offset1 := 0;
    rate := 0.66;
    len := trunc(sp.sizeOfData - sp.posOfData / (rate * sp.channels));
    SetLength(pCpy, len);
    SetLength(pRes, len);
    SetLength(pMem, len);
    s := TMemoryStream.Create;
    s.Write(sp.pWav^, sp.sizeOfData);
    s.Position := sp.posOfData;
    s.Read(Pointer(pRes)^, s.Size);
    s.Position := sp.posOfData;
    s.Read(Pointer(pCpy)^, s.Size);
    s.Free;
    ma := 0.0;
    p := pmin;
    for b := 0 to pmax - pmin - 1 do
    begin
      r[b] := 0.0;
      for a := 0 to temp_size do
        r[b] := r[b] + pRes[a] * pRes[a + b];
      if r[b] > ma then
      begin
        ma := r[b];
        p := b;
      end;
    end;
    while offset1 + 2 * pmax < len do
    begin
      for i := 1 to p do
      begin
        pCpy[offset1 + i] := pRes[offset0 + i];
        pCpy[offset1 + i + p] :=
          trunc((pRes[offset0 + p + i] * (p - i) + pRes[offset0 + i] * i) / p);
      end;
      q := Math.Ceil(rate * p / (1.0 - rate) + 0.5);
      for i := p to q - 1 do
      begin
        if offset1 + p + i >= len then
          break;
        pCpy[offset1 + p + i] := pRes[offset0 + i];
      end;
      inc(offset0, q);
      inc(offset1, p + q);
    end;
    pitch := 1.5;
    temp_size:=trunc(len / pitch);
    for i := 0 to temp_size - 1 do
    begin
      m := pitch * i;
      q := trunc(m);
      for a := q - j div 2 to q + j div 2 do
        if (a >= 0) and (a < temp_size) then
          pMem[i] := pCpy[a] + pRes[a] * trunc(sinc(pi * (m - a)))
        else
          pMem[i] := 0;
    end;
  except
    result := -1;
  end;
  s := TMemoryStream.Create;
  try
    s.WriteBuffer(sp.pWav^, sp.posOfData);
    s.WriteBuffer(Pointer(pMem)^, len);
    s.Position := 0;
    s.ReadBuffer(sp.pWav^, s.Size);
  finally
    s.Free;
  end;
  Finalize(pRes);
  Finalize(pCpy);
  Finalize(pMem);
  Finalize(r);
end;

function sinc(x: Single): Single;
begin
  if x = 0 then
    result := 1.0
  else
    result := sin(x) / x;
end;

end.
