program wav_proj;

{$APPTYPE CONSOLE}
{$R *.res}

uses
  System.SysUtils,
  System.Classes,
  spWav in 'spWav.pas',
  effect in 'effect.pas',
  WriteHeader in 'WriteHeader.pas',
  wav in 'wav.pas';

var
  sp: SpParam;
  hdrHeader: WrSWaveFileHeader;

begin
  try
    { TODO -oUser -cConsole メイン : ここにコードを記述してください }
    if ParamCount <> 2 then
    begin
      usage;
      Exit;
    end;
    if wavHdrRead(PChar(ParamStr(1)), sp) = -1 then
      Exit;
    if wavWrite(PChar(ParamStr(1)), PChar(ParamStr(2)), hdrHeader, sp) = -1 then
      Exit;
    Writeln('完了');
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;

end.
