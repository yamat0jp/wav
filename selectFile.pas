unit selectFile;

interface

uses System.Classes, System.SysUtils;

function readWav(const fName: string; out pMem: TMemoryStream): Boolean;

implementation

function readWav(const fName: string; out pMem: TMemoryStream): Boolean;
begin
  result := false;
  if FileExists(fName) = false then
    Exit;
  pMem := TMemoryStream.Create;
  pMem.LoadFromFile(fName);
  result := true;
end;

end.
