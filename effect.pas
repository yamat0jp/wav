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
    s.ReadBuffer(sp.pWav^, sp.sizeOfData);
    pMem := sp.pWav;
    pCpy := s.Memory;
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
end;

function effect16BitWav(const sp: SpParam): integer;
const
  depth = 1.0;
  rate = 170.0;
var
  i: integer;
  k, m: Single;
  pMem, pCpy: array of SmallInt;
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
    while i < k do
    begin
      m := depth * sin(2 * rate * pi * i / sp.samplePerSec);
      pMem[i + 0] := trunc(m * pMem[i + 0]);
      pMem[i + 1] := trunc(m * pMem[i + 1]);
      inc(i, 2);
    end;
  except
    result := -1;
  end;
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
