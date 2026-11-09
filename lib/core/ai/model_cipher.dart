library;

import 'dart:typed_data';

const int _blockBytes = 64;
const int _blockWords = 16;

Uint32List _words(Uint8List bytes, int count) {
  final src = bytes.offsetInBytes % 4 == 0 ? bytes : Uint8List.fromList(bytes);
  return src.buffer.asUint32List(src.offsetInBytes, count);
}

void _quarterRound(Uint32List s, int a, int b, int c, int d) {
  s[a] = (s[a] + s[b]) & 0xFFFFFFFF;
  var x = s[d] ^ s[a];
  s[d] = ((x << 16) | (x >>> 16)) & 0xFFFFFFFF;
  s[c] = (s[c] + s[d]) & 0xFFFFFFFF;
  x = s[b] ^ s[c];
  s[b] = ((x << 12) | (x >>> 20)) & 0xFFFFFFFF;
  s[a] = (s[a] + s[b]) & 0xFFFFFFFF;
  x = s[d] ^ s[a];
  s[d] = ((x << 8) | (x >>> 24)) & 0xFFFFFFFF;
  s[c] = (s[c] + s[d]) & 0xFFFFFFFF;
  x = s[b] ^ s[c];
  s[b] = ((x << 7) | (x >>> 25)) & 0xFFFFFFFF;
}

Uint8List chacha20(Uint8List key, Uint8List nonce, Uint8List data) {
  if (key.length != 32) {
    throw ArgumentError.value(key.length, 'key', 'kalit 32 bayt emas');
  }
  if (nonce.length != 12) {
    throw ArgumentError.value(nonce.length, 'nonce', 'nonce 12 bayt emas');
  }

  final keyWords = _words(key, 8);
  final nonceWords = _words(nonce, 3);

  final initial = Uint32List(_blockWords)
    ..[0] = 0x61707865
    ..[1] = 0x3320646E
    ..[2] = 0x79622D32
    ..[3] = 0x6B206574
    ..[13] = nonceWords[0]
    ..[14] = nonceWords[1]
    ..[15] = nonceWords[2];
  for (var i = 0; i < 8; i++) {
    initial[4 + i] = keyWords[i];
  }

  final input = data.offsetInBytes % 4 == 0 ? data : Uint8List.fromList(data);
  final out = Uint8List(input.length);
  final state = Uint32List(_blockWords);
  final keyStream = Uint32List(_blockWords);
  final keyStreamBytes = keyStream.buffer.asUint8List();

  final wholeWords = input.length >>> 2;
  final src32 = input.buffer.asUint32List(input.offsetInBytes, wholeWords);
  final dst32 = out.buffer.asUint32List(0, wholeWords);

  var counter = 1;
  for (var offset = 0; offset < input.length; offset += _blockBytes) {
    initial[12] = counter++;
    state.setAll(0, initial);
    for (var round = 0; round < 10; round++) {
      _quarterRound(state, 0, 4, 8, 12);
      _quarterRound(state, 1, 5, 9, 13);
      _quarterRound(state, 2, 6, 10, 14);
      _quarterRound(state, 3, 7, 11, 15);
      _quarterRound(state, 0, 5, 10, 15);
      _quarterRound(state, 1, 6, 11, 12);
      _quarterRound(state, 2, 7, 8, 13);
      _quarterRound(state, 3, 4, 9, 14);
    }
    for (var i = 0; i < _blockWords; i++) {
      keyStream[i] = (state[i] + initial[i]) & 0xFFFFFFFF;
    }

    final wordBase = offset >>> 2;
    final wordsLeft = wholeWords - wordBase;
    final wordCount = wordsLeft < _blockWords ? wordsLeft : _blockWords;
    for (var i = 0; i < wordCount; i++) {
      dst32[wordBase + i] = src32[wordBase + i] ^ keyStream[i];
    }
    final tailStart = (wordBase + wordCount) << 2;
    final tailEnd = offset + _blockBytes < input.length
        ? offset + _blockBytes
        : input.length;
    for (var i = tailStart; i < tailEnd; i++) {
      out[i] = input[i] ^ keyStreamBytes[i - offset];
    }
  }
  return out;
}
