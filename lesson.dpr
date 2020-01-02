program lesson;

{$APPTYPE CONSOLE}
{$R *.res}

uses
  System.SysUtils,
  hanning in 'hanning.pas',
  spWav in 'spWav.pas',
  WriteHeader in 'WriteHeader.pas';

var
  pcm: TMONO_PCM;
  i: integer;
  s: TDFT;

begin
  try
    { TODO -oUser -cConsole メイン : ここにコードを記述してください }
    mono_wave_read(pcm, 'ex2_1.wav');
    pcm.length := 65;
    dft(pcm, s);
    for i := 0 to s.length - 1 do
      Writeln(i, '::', Round(s.sinpuku[i]), '::', s.isou[i] * pi, 'pi');
    Readln;
    Finalize(pcm.s);
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;

end.
