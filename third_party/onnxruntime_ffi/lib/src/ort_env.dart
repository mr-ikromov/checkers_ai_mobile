import 'dart:ffi' as ffi;
import 'package:ffi/ffi.dart';
import 'package:onnxruntime_ffi/src/bindings/bindings.dart';
import 'package:onnxruntime_ffi/src/bindings/onnxruntime_bindings_generated.dart'
    as bg;
import 'package:onnxruntime_ffi/src/ort_status.dart';

const int _apiVersion = 14;
const String _logId = 'ShashkaOnnxRuntime';

class OrtEnv {
  OrtEnv._() {
    _ortApiPtr = onnxRuntimeBinding.OrtGetApiBase()
        .ref
        .GetApi
        .asFunction<ffi.Pointer<bg.OrtApi> Function(int)>()(_apiVersion);
  }

  static final OrtEnv _instance = OrtEnv._();

  static OrtEnv get instance => _instance;

  ffi.Pointer<bg.OrtEnv>? _ptr;
  late final ffi.Pointer<bg.OrtApi> _ortApiPtr;

  ffi.Pointer<bg.OrtApi> get ortApiPtr => _ortApiPtr;

  ffi.Pointer<bg.OrtEnv> get ptr {
    if (_ptr == null) init();
    return _ptr!;
  }

  void init() {
    if (_ptr != null) return;
    final pp = calloc<ffi.Pointer<bg.OrtEnv>>();
    final statusPtr = _ortApiPtr.ref.CreateEnv.asFunction<
        bg.OrtStatusPtr Function(int, ffi.Pointer<ffi.Char>,
            ffi.Pointer<ffi.Pointer<bg.OrtEnv>>)>()(
      bg.OrtLoggingLevel.ORT_LOGGING_LEVEL_WARNING,
      _logId.toNativeUtf8().cast<ffi.Char>(),
      pp,
    );
    OrtStatus.checkOrtStatus(statusPtr);
    _ptr = pp.value;
    calloc.free(pp);

    final projection = _ortApiPtr.ref.SetLanguageProjection.asFunction<
        bg.OrtStatusPtr Function(ffi.Pointer<bg.OrtEnv>, int)>()(
      _ptr!,
      bg.OrtLanguageProjection.ORT_PROJECTION_C,
    );
    OrtStatus.checkOrtStatus(projection);
  }
}

class OrtAllocator {
  OrtAllocator._() {
    final pp = calloc<ffi.Pointer<bg.OrtAllocator>>();
    final statusPtr =
        OrtEnv.instance.ortApiPtr.ref.GetAllocatorWithDefaultOptions.asFunction<
            bg.OrtStatusPtr Function(
                ffi.Pointer<ffi.Pointer<bg.OrtAllocator>>)>()(pp);
    OrtStatus.checkOrtStatus(statusPtr);
    _ptr = pp.value;
    calloc.free(pp);
  }

  static final OrtAllocator _instance = OrtAllocator._();

  static OrtAllocator get instance => _instance;

  late final ffi.Pointer<bg.OrtAllocator> _ptr;

  ffi.Pointer<bg.OrtAllocator> get ptr => _ptr;
}
