import 'dart:math' as math;
import 'dart:typed_data';

class SoundGenerator {
  /// Generates a clean, pleasant voice-note audio tone in 16-bit PCM WAV format.
  /// Works 100% offline on Web, Windows, Android, and iOS with zero dependencies.
  static Uint8List generateVoiceNoteTone({double durationSeconds = 3.0}) {
    const int sampleRate = 44100;
    final int numSamples = (sampleRate * durationSeconds).toInt();
    final ByteData byteData = ByteData(44 + numSamples * 2);

    final int dataSize = numSamples * 2;
    final int fileSize = 36 + dataSize;

    // RIFF header
    byteData.setUint8(0, 0x52); // R
    byteData.setUint8(1, 0x49); // I
    byteData.setUint8(2, 0x46); // F
    byteData.setUint8(3, 0x46); // F
    byteData.setUint32(4, fileSize, Endian.little);

    // WAVE header
    byteData.setUint8(8, 0x57); // W
    byteData.setUint8(9, 0x41); // A
    byteData.setUint8(10, 0x56); // V
    byteData.setUint8(11, 0x45); // E

    // fmt subchunk
    byteData.setUint8(12, 0x66); // f
    byteData.setUint8(13, 0x6D); // m
    byteData.setUint8(14, 0x74); // t
    byteData.setUint8(15, 0x20); // ' '
    byteData.setUint32(16, 16, Endian.little); // Subchunk1Size (16 for PCM)
    byteData.setUint16(20, 1, Endian.little); // AudioFormat 1 = PCM
    byteData.setUint16(22, 1, Endian.little); // NumChannels = 1 (Mono)
    byteData.setUint32(24, sampleRate, Endian.little); // SampleRate
    byteData.setUint32(28, sampleRate * 2, Endian.little); // ByteRate
    byteData.setUint16(32, 2, Endian.little); // BlockAlign
    byteData.setUint16(34, 16, Endian.little); // BitsPerSample = 16

    // data subchunk
    byteData.setUint8(36, 0x64); // d
    byteData.setUint8(37, 0x61); // a
    byteData.setUint8(38, 0x74); // t
    byteData.setUint8(39, 0x61); // a
    byteData.setUint32(40, dataSize, Endian.little);

    // Generate harmonic tones with envelope (speech-like gentle frequencies)
    for (int i = 0; i < numSamples; i++) {
      final double t = i / sampleRate;

      // Gentle vocal harmonic frequencies (350Hz fundamental, 700Hz 2nd harmonic, 1050Hz 3rd harmonic)
      final double sample = 0.5 * math.sin(2 * math.pi * 350 * t) +
          0.3 * math.sin(2 * math.pi * 700 * t) +
          0.15 * math.sin(2 * math.pi * 1050 * t);

      // Envelope to prevent clipping and clicks
      final double attack = math.min(1.0, t * 12);
      final double decay = math.min(1.0, (durationSeconds - t) * 4);
      final double envelope = attack * decay;

      final int intSample =
          (sample * envelope * 30000).toInt().clamp(-32768, 32767);
      byteData.setInt16(44 + i * 2, intSample, Endian.little);
    }

    return byteData.buffer.asUint8List();
  }
}
