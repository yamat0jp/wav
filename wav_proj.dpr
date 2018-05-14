program wav_proj;

{$APPTYPE CONSOLE}
{$R *.res}

uses
  System.SysUtils,
  System.Classes,
  spWav in 'spWav.pas',
  WriteHeader in 'WriteHeader.pas',
  wav in 'wav.pas',
  selectFile in 'selectFile.pas';

var
  sp: SpParam;
  pMem: TFileStream;
  fileName: string;
  hdrHeader: WrSWaveFileHeader;

begin
  try
    { TODO -oUser -cConsole メイン : ここにコードを記述してください }
    fileName:=ExtractFileName(ParamStr(1));
    if wavHdrRead(PChar(ParamStr(1)), sp) = -1 then
      Exit;
    if readWav(ParamStr(1),pMem) = false then
      Exit;
    if wavHdrRead(PChar(ParamStr(1)),sp) < 0 then
    begin
      pMem.Free;
      Exit;
    end;
    Readln;
    pMem.Free;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;

end.
