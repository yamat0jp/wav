program wav_proj;

{$APPTYPE CONSOLE}
{$R *.res}

uses
  System.SysUtils,
  System.Classes,
  wav in 'wav.pas',
  WriteHeader in 'WriteHeader.pas';

function effect8BitWav(fpIn, fpOut: TFileStream; sizeOfData: LongInt): integer;
var
  i, j: integer;
  s: Single;
  c: array [0 .. 1] of Byte;
  mix: Byte;
begin
  result := 0;
  i := 0;
  s := sizeOfData / SizeOf(c);
  while i < s do
  begin
    try
      fpIn.ReadBuffer(c, SizeOf(c));
      j:=(c[0]+c[1]) div 2;
      mix:=j;
      fpOut.WriteBuffer(mix, SizeOf(mix));
    except
      result := -1;
      break;
    end;
    inc(i);
  end;
end;

function effect16BitWav(fpIn, fpOut: TFileStream; sizeOfData: LongInt): integer;
var
  i, j: integer;
  s: Single;
  c: array [0 .. 1] of ShortInt;
  mix: LongInt;
begin
  result := 0;
  i := 0;
  s := sizeOfData / SizeOf(c);
  while i < s do
  begin
    try
      fpIn.ReadBuffer(c, SizeOf(c));
      j:=(c[0]+c[1]) div 2;
      mix:=j;
      fpOut.WriteBuffer(mix, SizeOf(mix));
    except
      result := -1;
      break;
    end;
    inc(i);
  end;
end;

function wavDataWrite(fpIn, fpOut: TFileStream; posOfData, sizeOfData: LongInt;
  bytesPerSingleCh: SmallInt): integer;
begin
  fpIn.Position := posOfData;
  fpOut.Position := posOfData;
  if bytesPerSingleCh = 1 then
    result := effect8BitWav(fpIn, fpOut, sizeOfData)
  else
    result := effect16BitWav(fpIn, fpOut, sizeOfData);
end;

function wavWrite(inFile, outFile: PChar; sampRate: LongWord; sampBits: Byte;
  posOfData, sizeOfData: LongInt): integer;
var
  bytesPerSingleCh: Word;
  fpIn, fpOut: TFileStream;
begin
  try
    fpIn := TFileStream.Create(inFile, fmOpenRead);
    fpOut := TFileStream.Create(outFile, fmCreate);
    bytesPerSingleCh := sampBits div 8;
    if waveHeaderWrite(fpOut, sizeOfData, bytesPerSingleCh, sampRate,
      sampBits) <> 44 then
      raise EWriteError.Create('ヘッダを書き込めません');
    if wavDataWrite(fpIn, fpOut, posOfData, sizeOfData, bytesPerSingleCh) = -1
    then
      raise EWriteError.Create('エラー発生');
  except
    on EFOpenError do
      Writeln(inFile, 'をオープンできません');
    on EFOpenError do
      fpIn.Free;
    else

    begin
      fpIn.Free;
      fpOut.Free;
    end;
    result := -1;
  end;
  result := 0;
end;

var
  sampRate: LongWord;
  sampBits: Byte;
  posOfData, sizeOfData: LongInt;

begin
  try
    { TODO -oUser -cConsole メイン : ここにコードを記述してください }
    wavHdrRead(PChar(ParamStr(1)), sampRate, sampBits, posOfData, sizeOfData);
    wavWrite(PChar(ParamStr(1)), PChar(ParamStr(2)), sampRate, sampBits,
      posOfData, sizeOfData);
    Writeln('完了');
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;

end.
