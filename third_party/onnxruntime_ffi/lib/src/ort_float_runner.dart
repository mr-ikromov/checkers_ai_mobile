import 'dart:ffi' as ffi;
import 'dart:typed_data';

import 'package:ffi/ffi.dart';
import 'package:onnxruntime_ffi/src/bindings/onnxruntime_bindings_generated.dart'
    as bg;
import 'package:onnxruntime_ffi/src/ort_env.dart';
import 'package:onnxruntime_ffi/src/ort_session.dart';
import 'package:onnxruntime_ffi/src/ort_status.dart';

class OrtFloatRunner {
  OrtFloatRunner({
    required int sessionAddress,
    required String inputName,
    required List<String> outputNames,
    required this.maxBatch,
    required this.inputRowSize,
    required List<int> outputRowSizes,
  })  : _outputRowSizes = List<int>.unmodifiable(outputRowSizes),
        _outputCount = outputNames.length {
    _sessionPtr = ffi.Pointer<bg.OrtSession>.fromAddress(sessionAddress);

    _inputPtr = calloc<ffi.Float>(maxBatch * inputRowSize);
    input = _inputPtr.asTypedList(maxBatch * inputRowSize);

    _shapePtr = calloc<ffi.Int64>(2);
    _shapePtr[1] = inputRowSize;

    _inputNamePtrs = calloc<ffi.Pointer<ffi.Char>>(1);
    _inputNamePtrs[0] = inputName.toNativeUtf8().cast<ffi.Char>();
    _inputValuePtrs = calloc<ffi.Pointer<bg.OrtValue>>(1);

    _outputNamePtrs = calloc<ffi.Pointer<ffi.Char>>(_outputCount);
    for (var i = 0; i < _outputCount; i++) {
      _outputNamePtrs[i] = outputNames[i].toNativeUtf8().cast<ffi.Char>();
    }
    _outputValuePtrs = calloc<ffi.Pointer<bg.OrtValue>>(_outputCount);
    _outputs = List<Float32List>.generate(
      _outputCount,
      (i) => Float32List(maxBatch * outputRowSizes[i]),
      growable: false,
    );

    final memInfoPtrPtr = calloc<ffi.Pointer<bg.OrtMemoryInfo>>();
    OrtStatus.checkOrtStatus(
      OrtEnv.instance.ortApiPtr.ref.AllocatorGetInfo.asFunction<
          bg.OrtStatusPtr Function(
              ffi.Pointer<bg.OrtAllocator>,
              ffi.Pointer<ffi.Pointer<bg.OrtMemoryInfo>>)>()(
        OrtAllocator.instance.ptr,
        memInfoPtrPtr,
      ),
    );
    _memInfoPtr = memInfoPtrPtr.value;
    calloc.free(memInfoPtrPtr);

    _runOptions = OrtRunOptions();
  }

  final int maxBatch;

  final int inputRowSize;

  late final Float32List input;

  final List<int> _outputRowSizes;
  final int _outputCount;

  late final ffi.Pointer<bg.OrtSession> _sessionPtr;
  late final ffi.Pointer<ffi.Float> _inputPtr;
  late final ffi.Pointer<ffi.Int64> _shapePtr;
  late final ffi.Pointer<ffi.Pointer<ffi.Char>> _inputNamePtrs;
  late final ffi.Pointer<ffi.Pointer<bg.OrtValue>> _inputValuePtrs;
  late final ffi.Pointer<ffi.Pointer<ffi.Char>> _outputNamePtrs;
  late final ffi.Pointer<ffi.Pointer<bg.OrtValue>> _outputValuePtrs;
  late final ffi.Pointer<bg.OrtMemoryInfo> _memInfoPtr;
  late final OrtRunOptions _runOptions;
  late final List<Float32List> _outputs;

  final Map<int, ffi.Pointer<bg.OrtValue>> _inputValueCache = {};
  int _lastBatch = 0;
  bool _released = false;

  ffi.Pointer<bg.OrtValue> _inputValue(int batch) {
    final cached = _inputValueCache[batch];
    if (cached != null) return cached;
    _shapePtr[0] = batch;
    final valuePtrPtr = calloc<ffi.Pointer<bg.OrtValue>>();
    OrtStatus.checkOrtStatus(
      OrtEnv.instance.ortApiPtr.ref.CreateTensorWithDataAsOrtValue.asFunction<
          bg.OrtStatusPtr Function(
              ffi.Pointer<bg.OrtMemoryInfo>,
              ffi.Pointer<ffi.Void>,
              int,
              ffi.Pointer<ffi.Int64>,
              int,
              int,
              ffi.Pointer<ffi.Pointer<bg.OrtValue>>)>()(
        _memInfoPtr,
        _inputPtr.cast(),
        batch * inputRowSize * 4,
        _shapePtr,
        2,
        bg.ONNXTensorElementDataType.ONNX_TENSOR_ELEMENT_DATA_TYPE_FLOAT,
        valuePtrPtr,
      ),
    );
    final value = valuePtrPtr.value;
    calloc.free(valuePtrPtr);
    _inputValueCache[batch] = value;
    return value;
  }

  void run(int batch) {
    assert(!_released, 'OrtFloatRunner allaqachon bo\'shatilgan');
    assert(batch >= 1 && batch <= maxBatch, 'batch chegaradan tashqari: $batch');
    _inputValuePtrs[0] = _inputValue(batch);
    for (var i = 0; i < _outputCount; i++) {
      _outputValuePtrs[i] = ffi.nullptr;
    }
    OrtStatus.checkOrtStatus(
      OrtEnv.instance.ortApiPtr.ref.Run.asFunction<
          bg.OrtStatusPtr Function(
              ffi.Pointer<bg.OrtSession>,
              ffi.Pointer<bg.OrtRunOptions>,
              ffi.Pointer<ffi.Pointer<ffi.Char>>,
              ffi.Pointer<ffi.Pointer<bg.OrtValue>>,
              int,
              ffi.Pointer<ffi.Pointer<ffi.Char>>,
              int,
              ffi.Pointer<ffi.Pointer<bg.OrtValue>>)>()(
        _sessionPtr,
        ffi.Pointer<bg.OrtRunOptions>.fromAddress(_runOptions.address),
        _inputNamePtrs,
        _inputValuePtrs,
        1,
        _outputNamePtrs,
        _outputCount,
        _outputValuePtrs,
      ),
    );
    final getData = OrtEnv.instance.ortApiPtr.ref.GetTensorMutableData
        .asFunction<
            bg.OrtStatusPtr Function(ffi.Pointer<bg.OrtValue>,
                ffi.Pointer<ffi.Pointer<ffi.Void>>)>();
    final release = OrtEnv.instance.ortApiPtr.ref.ReleaseValue
        .asFunction<void Function(ffi.Pointer<bg.OrtValue>)>();
    final dataPtrPtr = calloc<ffi.Pointer<ffi.Void>>();
    for (var i = 0; i < _outputCount; i++) {
      final count = batch * _outputRowSizes[i];
      OrtStatus.checkOrtStatus(getData(_outputValuePtrs[i], dataPtrPtr));
      final src = dataPtrPtr.value.cast<ffi.Float>().asTypedList(count);
      _outputs[i].setRange(0, count, src);
      release(_outputValuePtrs[i]);
      _outputValuePtrs[i] = ffi.nullptr;
    }
    calloc.free(dataPtrPtr);
    _lastBatch = batch;
  }

  Float32List output(int index) => _outputs[index];

  int get lastBatch => _lastBatch;

  void release() {
    if (_released) return;
    _released = true;
    final releaseValue = OrtEnv.instance.ortApiPtr.ref.ReleaseValue
        .asFunction<void Function(ffi.Pointer<bg.OrtValue>)>();
    for (final v in _inputValueCache.values) {
      releaseValue(v);
    }
    _inputValueCache.clear();
    _runOptions.release();
    calloc.free(_inputNamePtrs[0]);
    calloc.free(_inputNamePtrs);
    calloc.free(_inputValuePtrs);
    for (var i = 0; i < _outputCount; i++) {
      calloc.free(_outputNamePtrs[i]);
    }
    calloc.free(_outputNamePtrs);
    calloc.free(_outputValuePtrs);
    calloc.free(_shapePtr);
    calloc.free(_inputPtr);
  }
}
