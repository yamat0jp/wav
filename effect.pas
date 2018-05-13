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
  i := sp.posOfData;
  j := sp.sizeOfData - 1;
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
  i, j, k: integer;
  pInMem, pOutMem: TBytes;
begin
  pInMem := InInMem.Memory;
  pOutMem := InOutMem.Memory;
  i := 0;
  j := sp.sizeOfData - 2;
  k := sp.sizeOfData div 2;
  while i < k do
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
