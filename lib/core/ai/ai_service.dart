library;

import 'dart:async';
import 'dart:isolate';
import 'dart:typed_data';

import '../engine/position.dart';
import 'ai_config.dart';
import 'evaluator.dart';
import 'mcts.dart';
import 'model_loader.dart';
import 'onnx_evaluator.dart';

const int _cmdSearch = 1;
const int _cmdShutdown = 2;

const int _msgReady = 10;
const int _msgResult = 11;
const int _msgError = 12;

class AiException implements Exception {
  const AiException(this.message);

  final String message;

  @override
  String toString() => 'AiException: $message';
}

class AiService {
  AiService._(this._isolate, this._commands, this._responses);

  final Isolate _isolate;
  final SendPort _commands;
  final ReceivePort _responses;

  final Map<int, Completer<SearchResult>> _pending = {};
  int _nextId = 1;
  bool _disposed = false;

  static Future<AiService> start(Uint8List packedModel) async {
    final responses = ReceivePort();
    final isolate = await Isolate.spawn(
      _isolateMain,
      [
        responses.sendPort,
        TransferableTypedData.fromList([packedModel]),
        AiConfig.intraOpThreads,
      ],
      debugName: 'shashka-ai',
      errorsAreFatal: true,
    );
    final stream = responses.asBroadcastStream();
    final first = await stream.first as List<Object?>;
    if (first[0] == _msgError) {
      isolate.kill(priority: Isolate.immediate);
      responses.close();
      throw AiException(first[1] as String);
    }
    final service = AiService._(isolate, first[1] as SendPort, responses);
    stream.listen(service._onMessage);
    return service;
  }

  void _onMessage(dynamic raw) {
    final message = raw as List<Object?>;
    final id = message[1] as int;
    switch (message[0]) {
      case _msgResult:
        _pending.remove(id)?.complete(
              SearchResult(
                action: message[2] as int,
                confidence: message[3] as double,
                value: message[4] as double,
                sims: message[5] as int,
                elapsedMicros: message[6] as int,
              ),
            );
      case _msgError:
        _pending.remove(id)?.completeError(AiException(message[2] as String));
    }
  }

  Future<SearchResult> search(Position position, {int sims = AiConfig.sims}) {
    if (_disposed) {
      throw StateError('AiService yopilgan');
    }
    final id = _nextId++;
    final completer = Completer<SearchResult>();
    _pending[id] = completer;
    _commands.send([_cmdSearch, id, position.toSnapshot(), sims]);
    return completer.future;
  }

  void dispose() {
    if (_disposed) return;
    _disposed = true;
    _commands.send([_cmdShutdown, 0]);
    for (final completer in _pending.values) {
      if (!completer.isCompleted) {
        completer.completeError(const AiException('AI to\'xtatildi'));
      }
    }
    _pending.clear();
    _responses.close();
    _isolate.kill(priority: Isolate.beforeNextEvent);
  }
}

void _isolateMain(List<Object?> boot) {
  final responses = boot[0] as SendPort;
  final transfer = boot[1] as TransferableTypedData;
  final threads = boot[2] as int;

  late final Evaluator evaluator;
  try {
    final model = decryptModel(transfer.materialize().asUint8List());
    evaluator = OnnxEvaluator.fromBytes(
      model,
      maxBatch: AiConfig.leafBatch,
      intraOpThreads: threads,
    );
  } catch (e) {
    responses.send([_msgError, 0, 'Modelni yuklab bo\'lmadi: $e']);
    return;
  }

  final mcts = Mcts(evaluator);
  final commands = ReceivePort();
  responses.send([_msgReady, commands.sendPort]);

  commands.listen((dynamic raw) {
    final message = raw as List<Object?>;
    switch (message[0]) {
      case _cmdSearch:
        final id = message[1] as int;
        try {
          final position = Position.fromSnapshot(message[2] as Int64List);
          final result = mcts.search(position, sims: message[3] as int);
          responses.send([
            _msgResult,
            id,
            result.action,
            result.confidence,
            result.value,
            result.sims,
            result.elapsedMicros,
          ]);
        } catch (e) {
          responses.send([_msgError, id, 'Qidiruv xatosi: $e']);
        }
      case _cmdShutdown:
        evaluator.dispose();
        commands.close();
    }
  });
}
