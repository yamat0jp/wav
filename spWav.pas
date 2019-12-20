unit spWav;

interface

type
  SWaveFileHeader = packed record
    hdrRiff: array [0 .. 3] of AnsiChar;
    sizeOfFile: LongWord;
    hdrWave: array [0 .. 3] of AnsiChar;
  end;

  tChank = packed record
    hdrFmtData: array [0 .. 3] of AnsiChar;
    sizeOfFmtData: LongWord;
  end;

  tWaveFormatPcm = packed record
    formatTag: SmallInt;
    channels: SmallInt;
    sampleParSec: LongWord;
    bytesPerSec: LongWord;
    blockAlign: SmallInt;
    bitsPerSample: SmallInt;
  end;

  WrSWaveFileHeader = packed record
    hdrRiff: array [0..3] of AnsiChar;
    sizeOfFile: LongWord;
    hdrWave: array [0..3] of AnsiChar;
    hdrFmt: array [0..3] of AnsiChar;
    sizeOfFmt: LongWord;
    stWaveFormat: tWaveFormatPCM;
    hdrData: array [0..3] of AnsiChar;
    sizeOfData: LongWord;
  end;

  SpParam = packed record
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
