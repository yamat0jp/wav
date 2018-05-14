unit selectFile;

interface

uses System.Classes, System.SysUtils;

function readWav(const fName: string; out pMem: TMemoryStream): Boolean;

implementation

function readWav(const fName: string; out pMem: TMemoryStream): Boolean;
var
  f: TFileStream;
  sizeOfFile, length: integer;
begin
  result := false;
  if FileExists(fName) = false then
    Exit;
  f := TFileStream.Create(fName, fmOpenRead);
  try
    sizeOfFile := f.Size;
    Writeln('ファイルサイズ', sizeOfFile);
    pMem := TMemoryStream.Create;
    pMem.CopyFrom(f, 0);
    result := true;
  except
  end;
  f.Free;
end;

end.
