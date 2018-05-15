unit spWav;

interface

type
  SWaveFileHeader = record
    hdrRiff: array [0 .. 3] of AnsiChar;
    sizeOfFile: LongWord;
    hdrWave: array [0 .. 3] of AnsiChar;
  end;

  tChank = record
    hdrFmtData: array [0 .. 3] of AnsiChar;
    sizeOfFmtData: LongWord;
  end;

  tWaveFormatPcm = record
    formatTag: SmallInt;
    channels: SmallInt;
    sampleParSec: LongWord;
    bytesPerSec: LongWord;
    blockAlign: SmallInt;
    bitsPerSample: SmallInt;
  end;

  WrSWaveFileHeader = record
    hdrRiff: array [0..3] of AnsiChar;
    sizeOfFile: LongWord;
    hdrWave: array [0..3] of AnsiChar;
    hdrFmt: array [0..3] of AnsiChar;
    sizeOfFmt: LongWord;
    stWaveFormat: tWaveFormatPCM;
    hdrData: array [0..3] of AnsiChar;
    sizeOfData: LongWord;
  end;

  SpParam = record
    samplePerSec: LongWord;
    bitsPerSample: Byte;
    sizeOfData: LongWord;
    channels: Byte;
    bytesPerSec: LongWord;
    posOfData: LongInt;
    startpos: LongInt;
    endpos: LongInt;
    cycleuSec: LongInt;
    pWav: Pointer;
    cyclicSec: integer;
  end;

const
  STR_RIFF = 'RIFF';
  STR_WAVE = 'WAVE';
  STR_fmt = 'fmt ';
  STR_DATA = 'data';
  _MAX_PATH = 255;

  WAV_MONAURAL = 1;
  WAV_STEREO = 2;

implementation

end.
