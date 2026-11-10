library;

import 'dart:io';

import 'package:integration_test/integration_test_driver_extended.dart';

final String _outputDir =
    Platform.environment['SHOTS_DIR'] ?? 'docs/play/graphics/screenshots';

Future<void> main() => integrationDriver(
      onScreenshot: (String name, List<int> bytes, [Map<String, Object?>? args]) async {
        final file = File('$_outputDir/$name.png');
        await file.parent.create(recursive: true);
        await file.writeAsBytes(bytes);

        print('skrinshot: ${file.path} (${bytes.length} bayt)');
        return true;
      },
    );
