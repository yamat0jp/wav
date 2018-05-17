program wav_proj;

{$APPTYPE CONSOLE}
{$R *.res}

uses
  System.SysUtils,
  System.Classes,
  MMSystem,
  spWav in 'spWav.pas',
  wav in 'wav.pas',
  selectFile in 'selectFile.pas',
  effect in 'effect.pas';

var
  sp: SpParam;
  pMem: TMemoryStream;
  fileName: string;

function getPara(var sp: SpParam): integer;
var
  i: integer;
begin
  sp.pWav:=pMem.Memory;
  sp.cyclicSec:=i;
  result:=0;
end;

begin
  try
    { TODO -oUser -cConsole メイン : ここにコードを記述してください }
    fileName := ExtractFileName(ParamStr(1));
    if wavHdrRead(PChar(ParamStr(1)), sp) < 0 then
      Exit;
    if readWav(ParamStr(1), pMem) = false then
      Exit;
    if getPara(sp) = -1 then
    begin
      pMem.Free;
      Exit;
    end;
    if effectWav(sp) = 0 then
    begin
      PlaySound(pMem.Memory, 0, SND_ASYNC or SND_NODEFAULT or SND_MEMORY);
      Readln;
      PlaySound(nil, 0, SND_PURGE);
    end;
    pMem.Free;
    Finalize(sp.pWav^);
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;

end.
