
type
  SWaveFileHeader = record
    hdrRiff: array [0 .. 3] of AnsiChar;
    sizeOfFile: Cardinal;
    hdrWave: array [0 .. 3] of AnsiChar;
  end;

  tChank = record
    hdrFmtData: array [0 .. 3] of AnsiChar;
    sizeOfFmtData: LongWord;
  end;

  tWaveFormatPcm = record
    formatTag: Word;
    channels: Word;
    samplePerSec: LongWord;
    bytesPerSec: LongWord;
    blockAlign: Word;
    bitsPerSample: Word;
  end;

const
  STR_RIFF = 'RIFF';
  STR_WAVE = 'WAVE';
  STR_fmt = 'fmt ';
  STR_DATA = 'data';
  _MAX_PATH = 255;