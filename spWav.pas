unit spWav;

interface

type
  SWaveFileHeader = packed record
    hdrRiff: array [0 .. 3] of AnsiChar;
    sizeOfFile: UInt32;
    hdrWave: array [0 .. 3] of AnsiChar;
  end;

  tChunk = packed record
    hdrFmtData: array [0 .. 3] of AnsiChar;
    sizeOfFmtData: UInt32;
  end;

  tWaveFormatPcm = packed record
    formatTag: UInt16;
    channels: UInt16;
    sampleParSec: UInt32;
    bytesPerSec: UInt32;
    blockAlign: UInt16;
    bitsPerSample: UInt16;
  end;

  WrSWaveFileHeader = packed record
    hdrRiff: array [0..3] of AnsiChar;
    sizeOfFile: UInt32;
    hdrWave: array [0..3] of AnsiChar;
    hdrFmt: array [0..3] of AnsiChar;
    sizeOfFmt: UInt32;
    stWaveFormat: tWaveFormatPCM;
    hdrData: array [0..3] of AnsiChar;
    sizeOfData: UInt32;
  end;

  SpParam = record
    samplePerSec: UInt32;
    bitsPerSample: Byte;
    sizeOfData: UInt32;
    channels: Byte;
    bytesPerSec: UInt32;
    posOfData: UInt32;
    startpos: UInt32;
    endpos: UInt32;
    cycleuSec: UInt32;
    pWav: Pointer;
    cyclicSec: UInt32;
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
