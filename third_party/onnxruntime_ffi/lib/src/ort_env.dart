import 'dart:ffi' as ffi;
import 'package:ffi/ffi.dart';
import 'package:onnxruntime_ffi/src/bindings/bindings.dart';
import 'package:onnxruntime_ffi/src/bindings/onnxruntime_bindings_generated.dart'
    as bg;
import 'package:onnxruntime_ffi/src/ort_status.dart';

class OrtEnv {
  static final OrtEnv _instance = OrtEnv._();

  static OrtEnv get instance => _instance;

  ffi.Pointer<bg.OrtEnv>? _ptr;

  late ffi.Pointer<bg.OrtApi> _ortApiPtr;

  static OrtApiVersion _apiVersion = OrtApiVersion.api14;

  OrtEnv._() {
    _ortApiPtr = onnxRuntimeBinding.OrtGetApiBase()
        .ref
        .GetApi
        .asFunction<ffi.Pointer<bg.OrtApi> Function(int)>()(_apiVersion.value);
  }

  static void setApiVersion(OrtApiVersion apiVersion) {
    _apiVersion = apiVersion;
  }

  void init(
      {OrtLoggingLevel level = OrtLoggingLevel.warning,
      String logId = 'DartOnnxRuntime',
      OrtThreadingOptions? options}) {
    final pp = calloc<ffi.Pointer<bg.OrtEnv>>();
    bg.OrtStatusPtr statusPtr;
    if (options == null) {
      statusPtr = _ortApiPtr.ref.CreateEnv.asFunction<
              bg.OrtStatusPtr Function(int, ffi.Pointer<ffi.Char>,
                  ffi.Pointer<ffi.Pointer<bg.OrtEnv>>)>()(
          level.value, logId.toNativeUtf8().cast<ffi.Char>(), pp);
    } else {
      statusPtr = _ortApiPtr.ref.CreateEnvWithGlobalThreadPools.asFunction<
              bg.OrtStatusPtr Function(
                  int,
                  ffi.Pointer<ffi.Char>,
                  ffi.Pointer<bg.OrtThreadingOptions>,
                  ffi.Pointer<ffi.Pointer<bg.OrtEnv>>)>()(
          level.value, logId.toNativeUtf8().cast<ffi.Char>(), options._ptr, pp);
    }
    OrtStatus.checkOrtStatus(statusPtr);
    _ptr = pp.value;
    _setLanguageProjection();
    calloc.free(pp);
  }

  void release() {
    if (_ptr == null) {
      return;
    }
    _ortApiPtr.ref.ReleaseEnv
        .asFunction<void Function(ffi.Pointer<bg.OrtEnv>)>()(_ptr!);
    _ptr = null;
  }

  static String get version => onnxRuntimeBinding.OrtGetApiBase()
      .ref
      .GetVersionString
      .asFunction<ffi.Pointer<ffi.Char> Function()>()()
      .cast<Utf8>()
      .toDartString();

  ffi.Pointer<bg.OrtApi> get ortApiPtr => _ortApiPtr;

  ffi.Pointer<bg.OrtEnv> get ptr {
    if (_ptr == null) {
      init();
    }
    return _ptr!;
  }

  void _setLanguageProjection() {
    if (_ptr == null) {
      init();
    }
    final status = _ortApiPtr.ref.SetLanguageProjection.asFunction<
            bg.OrtStatusPtr Function(ffi.Pointer<bg.OrtEnv>, int)>()(
        _ptr!, bg.OrtLanguageProjection.ORT_PROJECTION_C);
    OrtStatus.checkOrtStatus(status);
  }
}

enum OrtApiVersion {

  api1(1),

  api2(2),

  api3(3),

  api7(7),

  api8(8),

  api11(11),

  api13(13),

  api14(14),

  trainingApi1(1);

  final int value;

  const OrtApiVersion(this.value);
}

enum OrtLoggingLevel {
  verbose(bg.OrtLoggingLevel.ORT_LOGGING_LEVEL_VERBOSE),
  info(bg.OrtLoggingLevel.ORT_LOGGING_LEVEL_INFO),
  warning(bg.OrtLoggingLevel.ORT_LOGGING_LEVEL_WARNING),
  error(bg.OrtLoggingLevel.ORT_LOGGING_LEVEL_ERROR),
  fatal(bg.OrtLoggingLevel.ORT_LOGGING_LEVEL_FATAL);

  final int value;

  const OrtLoggingLevel(this.value);
}

class OrtThreadingOptions {
  late ffi.Pointer<bg.OrtThreadingOptions> _ptr;

  OrtThreadingOptions() {
    _create();
  }

  void _create() {
    final pp = calloc<ffi.Pointer<bg.OrtThreadingOptions>>();
    final statusPtr = OrtEnv.instance.ortApiPtr.ref.CreateThreadingOptions
        .asFunction<
            bg.OrtStatusPtr Function(
                ffi.Pointer<ffi.Pointer<bg.OrtThreadingOptions>>)>()(pp);
    OrtStatus.checkOrtStatus(statusPtr);
    _ptr = pp.value;
    calloc.free(pp);
  }

  void release() {
    OrtEnv.instance.ortApiPtr.ref.ReleaseThreadingOptions
        .asFunction<void Function(ffi.Pointer<bg.OrtThreadingOptions>)>()(_ptr);
  }

  void setGlobalIntraOpNumThreads(int numThreads) {
    final statusPtr = OrtEnv.instance.ortApiPtr.ref.SetGlobalIntraOpNumThreads
        .asFunction<
            bg.OrtStatusPtr Function(
                ffi.Pointer<bg.OrtThreadingOptions>, int)>()(_ptr, numThreads);
    OrtStatus.checkOrtStatus(statusPtr);
  }

  void setGlobalInterOpNumThreads(int numThreads) {
    final statusPtr = OrtEnv.instance.ortApiPtr.ref.SetGlobalInterOpNumThreads
        .asFunction<
            bg.OrtStatusPtr Function(
                ffi.Pointer<bg.OrtThreadingOptions>, int)>()(_ptr, numThreads);
    OrtStatus.checkOrtStatus(statusPtr);
  }

  void setGlobalSpinControl(bool allowSpinning) {
    final statusPtr = OrtEnv.instance.ortApiPtr.ref.SetGlobalSpinControl
        .asFunction<
            bg.OrtStatusPtr Function(ffi.Pointer<bg.OrtThreadingOptions>,
                int)>()(_ptr, allowSpinning ? 1 : 0);
    OrtStatus.checkOrtStatus(statusPtr);
  }

  void setGlobalDenormalAsZero() {
    final statusPtr = OrtEnv.instance.ortApiPtr.ref.SetGlobalDenormalAsZero
        .asFunction<
            bg.OrtStatusPtr Function(
                ffi.Pointer<bg.OrtThreadingOptions>)>()(_ptr);
    OrtStatus.checkOrtStatus(statusPtr);
  }

  void setGlobalIntraOpThreadAffinity(String affinity) {
    final statusPtr =
        OrtEnv.instance.ortApiPtr.ref.SetGlobalIntraOpThreadAffinity.asFunction<
                bg.OrtStatusPtr Function(ffi.Pointer<bg.OrtThreadingOptions>,
                    ffi.Pointer<ffi.Char>)>()(
            _ptr, affinity.toNativeUtf8().cast<ffi.Char>());
    OrtStatus.checkOrtStatus(statusPtr);
  }
}

class OrtAllocator {
  late ffi.Pointer<bg.OrtAllocator> _ptr;

  static final OrtAllocator _instance = OrtAllocator._();

  static OrtAllocator get instance => _instance;

  ffi.Pointer<bg.OrtAllocator> get ptr => _ptr;

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
}
