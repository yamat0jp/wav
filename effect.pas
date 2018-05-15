unit effect;

interface

uses System.Classes, System.SysUtils, Math, spWav;

function effect8BitWav(const sp: SpParam): integer;
function effect16BitWav(const sp: SpParam): integer;
procedure usage;
function effectwav(const sp: SpParam): integer;

implementation

function effect8BitWav(const sp: SpParam): integer;
var
  i, delayStart: integer;
  k: Single;
  pMem, pCpy: array of Byte;
  s: TMemoryStream;
  L, R, DuetL, DuetR: SmallInt;
begin
  result := 0;
  try
    s := TMemoryStream.Create;
    s.ReadBuffer(sp.pWav^, sp.sizeOfData);
    pMem := sp.pWav;
    pCpy := s.Memory;
    delayStart := sp.samplePerSec * sp.cycleuSec;
    i := delayStart + sp.posOfData;
    k := 8 * sp.sizeOfData / sp.bitsPerSample;
    while i < k do
    begin
      L := pMem[i + 0];
      R := pMem[i + 1];
      DuetL := pCpy[i + 0 - delayStart];
      DuetR := pCpy[i + 1 - delayStart];
      inc(L, DuetL);
      inc(R, DuetR);

      pMem[i + 0] := L;
      pMem[i + 1] := R;
      inc(i, 2);
    end;
  except
    result := -1;
  end;
end;

function effect16BitWav(const sp: SpParam): integer;
var
  i, delayStart: integer;
  k: Single;
  pMem, pCpy: array of SmallInt;
  s: TMemoryStream;
  L, R, DuetL, DuetR: SmallInt;
begin
  result := 0;
  s := TMemoryStream.Create;
  try
    SetLength(pCpy, sp.sizeOfData);
    s.Write(sp.pWav^, sp.sizeOfData);
    s.Position := 0;
    s.Read(Pointer(pCpy)^, sp.sizeOfData);
    pMem := sp.pWav;
    delayStart := sp.posOfData + sp.samplePerSec * sp.cyclicSec;
    i := delayStart + sp.posOfData;
    k := 8 * sp.sizeOfData / sp.bitsPerSample;
    while i < k do
    begin
      L := pMem[i + 0];
      R := pMem[i + 1];
      DuetL := pCpy[i + 0 - delayStart];
      DuetR := pCpy[i + 1 - delayStart];
      inc(L, DuetL);
      inc(R, DuetR);
      L := max(-32768, min(32767, L));
      R := max(-32768, min(32767, R));
      pMem[i + 0] := L;
      pMem[i + 1] := R;
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
