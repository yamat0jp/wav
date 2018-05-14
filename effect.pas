unit effect;

interface

uses System.Classes, System.SysUtils, spWav;

function effect8BitWav(InInMem, InOutMem: TMemoryStream; sp: SpParam): integer;
function effect16BitWav(InInMem, InOutMem: TMemoryStream; sp: SpParam): integer;
procedure usage;

implementation

function effect8BitWav(InInMem, InOutMem: TMemoryStream; sp: SpParam): integer;
var
  i, j: integer;
  pInMem, pOutMem: TBytes;
begin
  i := sp.posOfData div SizeOf(Byte);
  j := sp.sizeOfData div SizeOf(Byte) - 1;
  pInMem := InInMem.Memory;
  pOutMem := InOutMem.Memory;
  while i < j do
  begin
    pOutMem[i] := pInMem[j];
    pOutMem[i + 1] := pInMem[j + 1];
    inc(i, 2);
    dec(j, 2);
  end;
end;

function effect16BitWav(InInMem, InOutMem: TMemoryStream; sp: SpParam): integer;
var
  i, j: integer;
  pInMem, pOutMem: array of SmallInt;
begin
  pInMem := InInMem.Memory;
  pOutMem := InOutMem.Memory;
  i := sp.posOfData div SizeOf(SmallInt);
  j := sp.sizeOfData div SizeOf(SmallInt) - 1;
  while i < j do
  begin
    pOutMem[i] := pInMem[j];
    pOutMem[i + 1] := pInMem[j + 1];
    inc(i, 2);
    dec(j, 2);
  end;
end;

procedure usage;
begin
  Writeln('‚Ì‚±‚¬‚è”g');
  Writeln('—áFeffect.wav 100 2000');
end;

end.
