library;

import 'dart:typed_data';

import 'package:onnxruntime_ffi/onnxruntime_ffi.dart';

import '../engine/position.dart';
import 'ai_config.dart';
import 'evaluator.dart';

const int _wdlSize = 3;

class OnnxEvaluator implements Evaluator {
  OnnxEvaluator._(this._session, this._options, this._runner, this.maxBatch)
      : values = Float32List(maxBatch);

  static OnnxEvaluator fromBytes(
    Uint8List model, {
    int maxBatch = AiConfig.leafBatch,
    int intraOpThreads = AiConfig.intraOpThreads,
  }) {
    OrtEnv.instance.init();
    final options = OrtSessionOptions()
      ..setIntraOpNumThreads(intraOpThreads)
      ..setInterOpNumThreads(1)
      ..setSessionGraphOptimizationLevel(GraphOptimizationLevel.ortEnableAll);
    final session = OrtSession.fromBuffer(model, options);
    final runner = OrtFloatRunner(
      sessionAddress: session.address,
      inputName: 'x',
      outputNames: const ['policy_logits', 'wdl_logits'],
      maxBatch: maxBatch,
      inputRowSize: inputSize,
      outputRowSizes: const [actionSize, _wdlSize],
    );
    return OnnxEvaluator._(session, options, runner, maxBatch);
  }

  final OrtSession _session;
  final OrtSessionOptions _options;
  final OrtFloatRunner _runner;

  @override
  final int maxBatch;

  @override
  final Float32List values;

  bool _disposed = false;

  @override
  Float32List get input => _runner.input;

  @override
  Float32List get policyLogits => _runner.output(0);

  @override
  void run(int batch) {
    _runner.run(batch);
    final wdl = _runner.output(1);
    for (var i = 0; i < batch; i++) {
      final base = i * _wdlSize;
      values[i] = wdlToValue(wdl[base], wdl[base + 1], wdl[base + 2]);
    }
  }

  @override
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    _runner.release();
    _session.release();
    _options.release();
  }
}
