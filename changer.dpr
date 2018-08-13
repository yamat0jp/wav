program changer;

uses
  Vcl.Forms,
  Unit2 in 'Unit2.pas' {Form2},
  wav in 'wav.pas',
  spWav in 'spWav.pas',
  selectFile in 'selectFile.pas',
  effect in 'effect.pas',
  WriteHeader in 'WriteHeader.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm2, Form2);
  Application.Run;
end.
