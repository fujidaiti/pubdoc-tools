import 'dart:io' show Platform;

import 'package:file/file.dart';
import 'package:file/local.dart';
import 'package:path/path.dart' as p;

/// Abstracts all I/O operations (file system, environment variables).
///
/// Implement this class to substitute the I/O layer in tests.
abstract class Environment {
  FileSystem get fs;
  String? getVariable(String name);
  String get toolVersion;

  /// Path to the Dart SDK directory, used to configure dartdoc.
  String? get sdkDir;
}

/// The default [Environment] backed by real platform I/O.
class PlatformEnvironment implements Environment {
  @override
  final FileSystem fs = const LocalFileSystem();

  @override
  String? getVariable(String name) => Platform.environment[name];

  @override
  String get toolVersion => '0.1.2';

  /// Derives the SDK directory from the running Dart executable path.
  ///
  /// The Dart binary lives at `<sdk>/bin/dart`, so the SDK root is two
  /// directories up from the resolved executable path.
  @override
  String? get sdkDir {
    final executable = Platform.resolvedExecutable;
    return p.dirname(p.dirname(executable));
  }
}
