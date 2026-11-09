import 'dart:ffi' as ffi;
import 'dart:typed_data';

import 'package:ffi/ffi.dart';
import 'package:onnxruntime_ffi/src/bindings/onnxruntime_bindings_generated.dart'
    as bg;
import 'package:onnxruntime_ffi/src/ort_env.dart';
import 'package:onnxruntime_ffi/src/ort_status.dart';

class OrtSession {
  OrtSession.fromBuffer(Uint8List modelBuffer, OrtSessionOptions options) {
    final pp = calloc<ffi.Pointer<bg.OrtSession>>();
    final size = modelBuffer.length;
    final bufferPtr = calloc<ffi.Uint8>(size);
    bufferPtr.asTypedList(size).setRange(0, size, modelBuffer);
    final statusPtr = OrtEnv.instance.ortApiPtr.ref.CreateSessionFromArray
        .asFunction<
            bg.OrtStatusPtr Function(
                ffi.Pointer<bg.OrtEnv>,
                ffi.Pointer<ffi.Void>,
                int,
                ffi.Pointer<bg.OrtSessionOptions>,
                ffi.Pointer<ffi.Pointer<bg.OrtSession>>)>()(
      OrtEnv.instance.ptr,
      bufferPtr.cast(),
      size,
      options._ptr,
      pp,
    );
    OrtStatus.checkOrtStatus(statusPtr);
    _ptr = pp.value;
    calloc.free(pp);
    calloc.free(bufferPtr);
  }

  late final ffi.Pointer<bg.OrtSession> _ptr;

  int get address => _ptr.address;

  void release() {
    OrtEnv.instance.ortApiPtr.ref.ReleaseSession
        .asFunction<void Function(ffi.Pointer<bg.OrtSession>)>()(_ptr);
  }
}

class OrtSessionOptions {
  OrtSessionOptions() {
    final pp = calloc<ffi.Pointer<bg.OrtSessionOptions>>();
    final statusPtr = OrtEnv.instance.ortApiPtr.ref.CreateSessionOptions
        .asFunction<
            bg.OrtStatusPtr Function(
                ffi.Pointer<ffi.Pointer<bg.OrtSessionOptions>>)>()(pp);
    OrtStatus.checkOrtStatus(statusPtr);
    _ptr = pp.value;
    calloc.free(pp);
  }

  late final ffi.Pointer<bg.OrtSessionOptions> _ptr;

  void setIntraOpNumThreads(int numThreads) {
    final statusPtr = OrtEnv.instance.ortApiPtr.ref.SetIntraOpNumThreads
        .asFunction<
            bg.OrtStatusPtr Function(
                ffi.Pointer<bg.OrtSessionOptions>, int)>()(_ptr, numThreads);
    OrtStatus.checkOrtStatus(statusPtr);
  }

  void setInterOpNumThreads(int numThreads) {
    final statusPtr = OrtEnv.instance.ortApiPtr.ref.SetInterOpNumThreads
        .asFunction<
            bg.OrtStatusPtr Function(
                ffi.Pointer<bg.OrtSessionOptions>, int)>()(_ptr, numThreads);
    OrtStatus.checkOrtStatus(statusPtr);
  }

  void setSessionGraphOptimizationLevel(GraphOptimizationLevel level) {
    final statusPtr = OrtEnv
        .instance.ortApiPtr.ref.SetSessionGraphOptimizationLevel
        .asFunction<
            bg.OrtStatusPtr Function(
                ffi.Pointer<bg.OrtSessionOptions>, int)>()(_ptr, level.value);
    OrtStatus.checkOrtStatus(statusPtr);
  }

  void release() {
    OrtEnv.instance.ortApiPtr.ref.ReleaseSessionOptions
        .asFunction<void Function(ffi.Pointer<bg.OrtSessionOptions>)>()(_ptr);
  }
}

class OrtRunOptions {
  OrtRunOptions() {
    final pp = calloc<ffi.Pointer<bg.OrtRunOptions>>();
    final statusPtr = OrtEnv.instance.ortApiPtr.ref.CreateRunOptions.asFunction<
        bg.OrtStatusPtr Function(
            ffi.Pointer<ffi.Pointer<bg.OrtRunOptions>>)>()(pp);
    OrtStatus.checkOrtStatus(statusPtr);
    _ptr = pp.value;
    calloc.free(pp);
  }

  late final ffi.Pointer<bg.OrtRunOptions> _ptr;

  int get address => _ptr.address;

  void release() {
    OrtEnv.instance.ortApiPtr.ref.ReleaseRunOptions
        .asFunction<void Function(ffi.Pointer<bg.OrtRunOptions>)>()(_ptr);
  }
}

enum GraphOptimizationLevel {
  ortDisableAll(bg.GraphOptimizationLevel.ORT_DISABLE_ALL),
  ortEnableBasic(bg.GraphOptimizationLevel.ORT_ENABLE_BASIC),
  ortEnableExtended(bg.GraphOptimizationLevel.ORT_ENABLE_EXTENDED),
  ortEnableAll(bg.GraphOptimizationLevel.ORT_ENABLE_ALL);

  const GraphOptimizationLevel(this.value);

  final int value;
}
