
type
  SWaveFileHeader = record
    hdrRiff: array [0 .. 3] of AnsiChar;
    sizeOfFile: Cardinal;
    hdrWave: array [0 .. 3] of AnsiChar;
  end;

  tChank = record
    hdrFmtData: array [0 .. 3] of AnsiChar;
    sizeOfFmtData: Cardinal;
  end;

  tWaveFormatPcm = record
    formatTag: Word;
    channels: Word;
    sampleParSec: Cardinal;
    bytesPerSec: Cardinal;
    blockAlign: Word;
    bitsPerSample: Word;
  end;

  WrSWaveFileHeader = record
    hdrRiff: array [0..3] of AnsiChar;
    sizeOfFile: Cardinal;
    stWaveFormat: tWaveFormatPCM;
    hdrWave: array [0..3] of AnsiChar;
    hdrFmt: array [0..3] of AnsiChar;
    sizeOfFmt: Cardinal;
    hdrData: array [0..3] of AnsiChar;
    sizeOfData: Cardinal;
  end;

const
  STR_RIFF = 'RIFF';
  STR_WAVE = 'WAVE';
  STR_fmt = 'fmt ';
  STR_DATA = 'data';
  _MAX_PATH = 255;