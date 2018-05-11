
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
    formatTag: Byte;
    channels: Byte;
    sampleParSec: LongWord;
    bytesPerSec: LongWord;
    blockAlign: Byte;
    bitsPerSample: Byte;
  end;

  WrSWaveFileHeader = record
    hdrRiff: array [0..3] of AnsiChar;
    sizeOfFile: LongWord;
    stWaveFormat: tWaveFormatPCM;
    hdrWave: array [0..3] of AnsiChar;
    hdrFmt: array [0..3] of AnsiChar;
    sizeOfFmt: LongWord;
    hdrData: array [0..3] of AnsiChar;
    sizeOfData: LongWord;
  end;

const
  STR_RIFF = 'RIFF';
  STR_WAVE = 'WAVE';
  STR_fmt = 'fmt ';
  STR_DATA = 'data';
  _MAX_PATH = 255;