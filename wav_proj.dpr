program wav_proj;

{$APPTYPE CONSOLE}
{$R *.res}

uses
  System.SysUtils,
  System.Classes,
  wav in 'wav.pas',
  WriteHeader in 'WriteHeader.pas',
  spWav in 'spWav.pas';

function cut(fpIn, fpOut: TFileStream; sp: SpParam): integer;
var
  Buffer: array of ShortInt;
  size: integer;
begin
  size := (sp.endpos - sp.startpos) * sp.channels * sp.samplePerSec *
    sp.bitsPerSample div 8;
  SetLength(Buffer, size);
  try
    fpIn.ReadBuffer(Pointer(Buffer)^, size);
    fpOut.WriteBuffer(Pointer(Buffer)^, size);
    Finalize(Buffer);
  except
    result := -1;
  end;
end;

function checkRange(var sp: SpParam): integer;
begin
  result := 0;
  if sp.startpos * sp.bytesPerSec > sp.sizeOfData then
  begin
    Writeln('開始位置がファイルサイズを超えています');
    result := -1;
  end
  else if (sp.endpos + 1) * sp.bytesPerSec > sp.sizeOfData then
  begin
    Writeln('終了位置がファイルサイズを超えています');
    Writeln('終了をファイルの最後に調整しました');
    sp.endpos := (sp.sizeOfData div sp.bytesPerSec) - 1;
  end;
end;

function wavDataWrite(fpIn, fpOut: TFileStream; const sp: SpParam): integer;
begin
  fpIn.Position := sp.posOfData;
  result := cut(fpIn, fpOut, sp);
end;

function wavWrite(inFile, outFile: PChar; var sp: SpParam): integer;
var
  fpIn, fpOut: TFileStream;
begin
  try
    fpIn := TFileStream.Create(inFile, fmOpenRead);
    fpOut := TFileStream.Create(outFile, fmCreate);
    sp.sizeOfData := (sp.endpos - sp.startpos + 1) * sp.bytesPerSec;
    if waveHeaderWrite(fpOut, sp) > 44 then
      raise EWriteError.Create('ヘッダを書き込めません');
    if wavDataWrite(fpIn, fpOut, sp) = -1 then
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
    Exit;
  end;
  result := 0;
end;

var
  sp: SpParam;

begin
  try
    { TODO -oUser -cConsole メイン : ここにコードを記述してください }
    sp.startpos := StrToInt(ParamStr(3));
    sp.endpos := StrToInt(ParamStr(4));
    if sp.startpos > sp.endpos then
    begin
      Writeln('開始秒は終了秒を超えてはなりません');
      Exit;
    end;
    if wavHdrRead(PChar(ParamStr(1)), sp) = -1 then
      Exit;
    if wavWrite(PChar(ParamStr(1)), PChar(ParamStr(2)), sp) = -1 then
      Exit;
    Writeln('完了');
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;

end.
