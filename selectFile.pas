unit selectFile;

interface

uses System.Classes, System.SysUtils;

function readWav(const fName: string; out pMem: TMemoryStream): Boolean;

implementation

uses Unit2;

function readWav(const fName: string; out pMem: TMemoryStream): Boolean;
var
  f: TFileStream;
begin
  result := false;
  if FileExists(fName) = false then
    Exit;
  f := TFileStream.Create(fName, fmOpenRead);
  try
    pMem := TMemoryStream.Create;
    pMem.CopyFrom(f, 0);
    result := true;
  finally
    f.Free;
  end;
end;

end.
