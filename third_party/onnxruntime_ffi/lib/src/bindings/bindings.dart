import 'dart:ffi';
import 'dart:io';
import 'package:onnxruntime_ffi/src/bindings/onnxruntime_bindings_generated.dart';

final DynamicLibrary _dylib = () {
  if (Platform.isAndroid) {
    return DynamicLibrary.open('libonnxruntime.so');
  }
  throw UnsupportedError(
    'onnxruntime_ffi faqat Android uchun sozlangan '
    '(joriy platforma: ${Platform.operatingSystem}). Host testlarda '
    'ONNX baholovchi o\'rniga stub ishlatilsin.',
  );
}();

final onnxRuntimeBinding = OnnxRuntimeBindings(_dylib);
