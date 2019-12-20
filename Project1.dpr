program Project1;

uses
  System.StartUpCopy,
  FMX.Forms,
  Unit1 in 'Unit1.pas' {Form1},
  spWav in 'spWav.pas',
  effect in 'effect.pas',
  wav in 'wav.pas',
  selectFile in 'selectFile.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
