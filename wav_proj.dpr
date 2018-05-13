program wav_proj;

{$APPTYPE CONSOLE}
{$R *.res}

uses
  System.SysUtils,
  System.Classes,
  wav in 'wav.pas',
  WriteHeader in 'WriteHeader.pas',
  spWav in 'spWav.pas';

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
var
  Buffer: array of ShortInt;
begin
  result := 0;
  fpIn.Position := sp.posOfData;
  try
    GetMem(Pointer(Buffer), sp.sizeOfData);
  except
    Writeln('メモリが確保できません');
    result := -1;
  end;
  if fpIn.Read(Pointer(Buffer)^, sp.sizeOfData) = -1 then
  begin
    Writeln('読み込みに失敗');
    result := -1;
  end;
  if fpOut.Write(Pointer(Buffer)^, sp.sizeOfData) = -1 then
  begin
    Writeln('書き込みに失敗');
    result := -1;
  end;
  FreeMem(Pointer(Buffer));
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

procedure usage;
begin
  Writeln('引数<入力ファイル名><出力ファイル名><速度倍率>');
end;

var
  sp: SpParam;

begin
  try
    { TODO -oUser -cConsole メイン : ここにコードを記述してください }
    if ParamCount <> 3 then
    begin
      usage;
      Exit;
    end;
    if wavHdrRead(PChar(ParamStr(1)), sp) = -1 then
      Exit;
    sp.samplePerSec := StrToInt(ParamStr(3)) * sp.samplePerSec;
    if wavWrite(PChar(ParamStr(1)), PChar(ParamStr(2)), sp) = -1 then
      Exit;
    Writeln('完了');
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;

end.
