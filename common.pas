unit common;

interface

uses spWav, System.Classes, System.SysUtils;

type
  TMyWave = class(TFileStream)
  private
    Fsp: SpParam;
  protected
    property sp: SpParam read Fsp write Fsp;
  public
    function main(argc: integer; argv: string): integer; virtual;
  end;

  TSpWave = class(TMyWave)
  public
    function main(argc: integer; argv: string): integer; override;
    function WriteWaveData: integer;
  end;

implementation

uses WriteHeader;

{ TSpWave }

function TSpWave.main(argc: integer; argv: string): integer;
begin
  inherited;
  result := waveHeaderWrite(Self, sp);
  if result = -1 then
    Exit;
  result := WriteWaveData;
end;

function TSpWave.WriteWaveData: integer;
var
  tempSamplePeriod: Single;
  curSampling, samplePerPriod, deltaPriod: integer;
  outdata: array [0 .. 1] of Int16;
  i: integer;
begin
  result := -1;
  tempSamplePeriod := sp.samplePerSec * sp.cycleuSec;
  tempSamplePeriod := tempSamplePeriod / 1000000.0 * 2.0;
  samplePerPriod := Trunc(tempSamplePeriod);
  if samplePerPriod <= 0 then
    Exit;
  curSampling := 0;
  deltaPriod := 1;
  for i := 0 to sp.sizeOfData div SizeOf(outdata) do
  begin
    if curSampling = 0 then
      deltaPriod := 1;
    if curSampling = samplePerPriod then
      deltaPriod := -1;
    if deltaPriod = -1 then
    begin
      outdata[0] := 32767;
      outdata[1] := 32767;
    end
    else
    begin
      outdata[0] := -32768;
      outdata[1] := -32768;
    end;
    WriteBuffer(outdata, SizeOf(outdata));
    inc(curSampling, deltaPriod);
  end;
  result := 0;
end;

{ TMyWave }

function TMyWave.main(argc: integer; argv: string): integer;
var
  totalLength: integer;
  s: SpParam;
  t: TStringList;
begin
  result := -1;
  t := TStringList.Create;
  try
    t.StrictDelimiter := false;
    t.DelimitedText := argv;
//    if argc <> t.Count then
  //    Exit;
    totalLength := StrToInt(t[0]);
    s.cycleuSec := StrToInt(t[1]);
  finally
    t.Free;
  end;
  with s do
  begin
    channels := 2;
    samplePerSec := 44100;
    bitsPerSample := 16;
    sizeOfData := (bitsPerSample div 8) * channels * samplePerSec * totalLength;
  end;
  sp := s;
  result := 1;
end;

end.
