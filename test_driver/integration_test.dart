/// `flutter drive` uchun standart drayver.
///
/// Profil rejimida (AOT) o'lchash uchun:
///   flutter drive --profile \
///     --driver=test_driver/integration_test.dart \
///     --target=integration_test/app_test.dart -d DEVICE_ID
library;

import 'package:integration_test/integration_test_driver.dart';

Future<void> main() => integrationDriver();
