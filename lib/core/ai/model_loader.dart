library;

import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';

import 'model_cipher.dart';
import 'model_key.dart';

const String _asset = 'assets/models/model.bin';
const List<int> _magic = [0x53, 0x48, 0x4B, 0x31];
const int _headerBytes = 4 + 4 + 32;

class ModelLoadException implements Exception {
  const ModelLoadException(this.message);

  final String message;

  @override
  String toString() => 'ModelLoadException: $message';
}

Future<Uint8List> loadEncryptedModel() async {
  final data = await rootBundle.load(_asset);
  return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
}

Uint8List decryptModel(Uint8List packed) {
  if (packed.length <= _headerBytes) {
    throw const ModelLoadException('model paketi juda kichik');
  }
  for (var i = 0; i < _magic.length; i++) {
    if (packed[i] != _magic[i]) {
      throw const ModelLoadException('model paketi tanilmadi');
    }
  }

  final header = ByteData.sublistView(packed, 0, _headerBytes);
  final plainLength = header.getUint32(4, Endian.little);
  final expected = packed.sublist(8, _headerBytes);

  final payload = Uint8List.sublistView(packed, _headerBytes);
  final model = chacha20(modelKey, modelNonce, payload);
  if (model.length != plainLength) {
    throw const ModelLoadException('model hajmi mos kelmadi');
  }

  final actual = sha256.convert(model).bytes;
  for (var i = 0; i < expected.length; i++) {
    if (actual[i] != expected[i]) {
      throw const ModelLoadException('model yaxlitligi buzilgan');
    }
  }
  return model;
}
