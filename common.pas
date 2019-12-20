unit common;

interface

uses spWav, System.Classes, System.SysUtils;

type
  TMyWave = class
  private
    Ffp: TFileStream;
    Fsp: SpParam;
  protected
    property fp: TFileStream read Ffp write Ffp;
    property sp: SpParam read Fsp write Fsp;
  public
    constructor Create;
    destructor Destroy; override;
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
  result := waveHeaderWrite(fp, sp);
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
  // tempSamplePeriod:=tempSamplePeriod/1000000.0f*2.0f;
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
    fp.WriteBuffer(outdata,SizeOf(outdata));
    inc(curSampling, deltaPriod);
  end;
  result := 0;
end;

{ TMyWave }

constructor TMyWave.Create;
begin
  Ffp := TFileStream.Create('sample.wav', fmCreate);
end;

destructor TMyWave.Destroy;
begin
  Ffp.Free;
  inherited;
end;

function TMyWave.main(argc: integer; argv: string): integer;
var
  totalLength: integer;
  s: SpParam;
  t: TStringList;
begin
  t:=TStringList.Create;
  try
    t.StrictDelimiter:=false;
    t.DelimitedText:=argv;
    if argc <> t.Count then
      Exit;
    totalLength:=StrToInt(t[1]);
    s.cycleuSec:=StrToInt(t[2]);
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
  result:=1;
end;

end.
