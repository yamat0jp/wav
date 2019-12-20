unit selectFile;

interface

uses System.Classes, System.SysUtils;

function readWav(const fName: string; out pMem: TMemoryStream): Boolean;

implementation

uses Unit2;

function readWav(const fName: string; out pMem: TMemoryStream): Boolean;
var
  f: TFileStream;
  sizeOfFile: integer;
begin
  result := false;
  if FileExists(fName) = false then
    Exit;
  f := TFileStream.Create(fName, fmOpenRead);
  try
    sizeOfFile := f.Size;
//    Form2.ListBox1.Items.Add('ファイルサイズ'+ sizeOfFile.ToString);
    pMem := TMemoryStream.Create;
    pMem.CopyFrom(f, 0);
    result := true;
  except
  end;
  f.Free;
end;

end.
