library;

import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:shashka/core/ai/model_cipher.dart';

void main() {
  test('RFC 8439 2.4.2 nazorat vektori', () {
    final key = Uint8List.fromList(List<int>.generate(32, (i) => i));
    final nonce = Uint8List.fromList(
      const [0, 0, 0, 0, 0, 0, 0, 0x4a, 0, 0, 0, 0],
    );
    final plain = Uint8List.fromList(
      utf8.encode(
        "Ladies and Gentlemen of the class of '99: If I could offer you "
        'only one tip for the future, sunscreen would be it.',
      ),
    );

    final cipher = chacha20(key, nonce, plain);

    expect(
      cipher.sublist(0, 16),
      const [
        0x6e, 0x2e, 0x35, 0x9a, 0x25, 0x68, 0xf9, 0x80,
        0x41, 0xba, 0x07, 0x28, 0xdd, 0x0d, 0x69, 0x81,
      ],
    );
    expect(cipher.length, plain.length);
    expect(chacha20(key, nonce, cipher), plain);
  });

  test('har xil uzunliklarda teskari amal aniq ishlaydi', () {
    final rng = Random(7);
    final key = Uint8List.fromList(
      List<int>.generate(32, (_) => rng.nextInt(256)),
    );
    final nonce = Uint8List.fromList(
      List<int>.generate(12, (_) => rng.nextInt(256)),
    );

    for (final length in [0, 1, 7, 63, 64, 65, 127, 128, 1000, 65537]) {
      final data = Uint8List.fromList(
        List<int>.generate(length, (_) => rng.nextInt(256)),
      );
      final cipher = chacha20(key, nonce, data);
      expect(cipher.length, length, reason: 'uzunlik $length');
      expect(chacha20(key, nonce, cipher), data, reason: 'uzunlik $length');
      if (length > 0) {
        expect(cipher, isNot(equals(data)), reason: 'uzunlik $length');
      }
    }
  });

  test('tekislanmagan ko\'rinish ustida ham to\'g\'ri ishlaydi', () {
    final rng = Random(11);
    final backing = Uint8List.fromList(
      List<int>.generate(1000, (_) => rng.nextInt(256)),
    );
    final key = Uint8List.fromList(List<int>.filled(32, 3));
    final nonce = Uint8List.fromList(List<int>.filled(12, 5));

    final view = Uint8List.sublistView(backing, 3, 503);
    final copy = Uint8List.fromList(view);

    expect(chacha20(key, nonce, view), chacha20(key, nonce, copy));
  });

  test('boshqa kalit boshqa natija beradi', () {
    final data = Uint8List.fromList(List<int>.generate(256, (i) => i));
    final nonce = Uint8List.fromList(List<int>.filled(12, 1));
    final a = chacha20(Uint8List.fromList(List<int>.filled(32, 1)), nonce, data);
    final b = chacha20(Uint8List.fromList(List<int>.filled(32, 2)), nonce, data);
    expect(a, isNot(equals(b)));
  });

  test('noto\'g\'ri kalit yoki nonce uzunligi xato beradi', () {
    final data = Uint8List(16);
    expect(
      () => chacha20(Uint8List(16), Uint8List(12), data),
      throwsArgumentError,
    );
    expect(
      () => chacha20(Uint8List(32), Uint8List(8), data),
      throwsArgumentError,
    );
  });
}
