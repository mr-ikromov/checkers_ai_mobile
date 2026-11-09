/// Skrinshotlarni diskka yozadigan drayver.
///
///   `flutter drive --profile --driver=test_driver/screenshots.dart \`
///   `  --target=integration_test/screenshots_test.dart -d <device-id>`
library;

import 'dart:io';

import 'package:integration_test/integration_test_driver_extended.dart';

const String _outputDir = 'docs/play/graphics/screenshots';

Future<void> main() => integrationDriver(
      onScreenshot: (String name, List<int> bytes, [Map<String, Object?>? args]) async {
        final file = File('$_outputDir/$name.png');
        await file.parent.create(recursive: true);
        await file.writeAsBytes(bytes);
        // ignore: avoid_print
        print('skrinshot: ${file.path} (${bytes.length} bayt)');
        return true;
      },
    );
