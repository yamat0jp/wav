
type
  SWaveFileHeader = record
    hdrRiff: array [0 .. 3] of AnsiChar;
    sizeOfFile: LongInt;
    hdrWave: array [0 .. 3] of AnsiChar;
  end;

  tChank = record
    hdrFmtData: array [0 .. 3] of AnsiChar;
    sizeOfFmtData: LongInt;
  end;

  tWaveFormatPcm = record
    formatTag: Word;
    channels: Word;
    sampleParSec: LongInt;
    bytesPerSec: LongInt;
    blockAlign: Word;
    bitsPerSample: Word;
  end;

  WrSWaveFileHeader = record
    hdrRiff: array [0..3] of AnsiChar;
    sizeOfFile: LongInt;
    stWaveFormat: tWaveFormatPCM;
    hdrWave: array [0..3] of AnsiChar;
    hdrFmt: array [0..3] of AnsiChar;
    sizeOfFmt: LongInt;
    hdrData: array [0..3] of AnsiChar;
    sizeOfData: LongInt;
  end;

const
  STR_RIFF = 'RIFF';
  STR_WAVE = 'WAVE';
  STR_fmt = 'fmt ';
  STR_DATA = 'data';
  _MAX_PATH = 255;