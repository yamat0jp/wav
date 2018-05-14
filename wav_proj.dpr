program wav_proj;

{$APPTYPE CONSOLE}
{$R *.res}

uses
  System.SysUtils,
  System.Classes,
  MMSystem,
  spWav in 'spWav.pas',
  wav in 'wav.pas',
  selectFile in 'selectFile.pas';

var
  sp: SpParam;
  pMem: TMemoryStream;
  fileName: string;
  hdrHeader: WrSWaveFileHeader;

begin
  try
    { TODO -oUser -cConsole メイン : ここにコードを記述してください }
    fileName := ExtractFileName(ParamStr(1));
    if wavHdrRead(PChar(ParamStr(1)), sp) < 0 then
      Exit;
    if readWav(ParamStr(1), pMem) = false then
      Exit;
    PlaySound(pMem.Memory, 0, SND_ASYNC or SND_NODEFAULT or SND_MEMORY);
    Readln;
    PlaySound(nil, 0, SND_PURGE);
    pMem.Free;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;

end.
