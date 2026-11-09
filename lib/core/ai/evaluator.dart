library;

import 'dart:math';
import 'dart:typed_data';

import '../engine/position.dart';
import 'ai_config.dart';

abstract class Evaluator {
  int get maxBatch;

  Float32List get input;

  void run(int batch);

  Float32List get policyLogits;

  Float32List get values;

  void dispose();
}

double wdlToValue(double win, double draw, double loss) {
  final mx = max(win, max(draw, loss));
  final e0 = exp(win - mx);
  final e1 = exp(draw - mx);
  final e2 = exp(loss - mx);
  return (e0 - e2) / (e0 + e1 + e2);
}

class UniformEvaluator implements Evaluator {
  UniformEvaluator({this.maxBatch = AiConfig.leafBatch})
      : input = Float32List(maxBatch * inputSize),
        policyLogits = Float32List(maxBatch * actionSize),
        values = Float32List(maxBatch);

  @override
  final int maxBatch;

  @override
  final Float32List input;

  @override
  final Float32List policyLogits;

  @override
  final Float32List values;

  int evaluations = 0;

  @override
  void run(int batch) {
    evaluations += batch;
    policyLogits.fillRange(0, batch * actionSize, 0);
    values.fillRange(0, batch, 0);
  }

  @override
  void dispose() {}
}
