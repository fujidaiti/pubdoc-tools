import 'dart:async';
import 'dart:io';

import 'package:logging/logging.dart';

/// Package-global logger for pubdoc.
final log = Logger('pubdoc');

/// Configures the root logger for CLI usage.
///
/// Routes INFO and below to stdout, WARNING and above to stderr.
/// Returns the subscription so it can be cancelled if needed.
StreamSubscription<LogRecord> setupLogging({bool verbose = false}) {
  Logger.root.level = verbose ? Level.ALL : Level.INFO;
  return Logger.root.onRecord.listen((record) {
    if (record.level >= Level.WARNING) {
      stderr.writeln(record.message);
    } else {
      stdout.writeln(record.message);
    }
  });
}
