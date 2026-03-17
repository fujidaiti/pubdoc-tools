import 'dart:convert';

import 'package:file/file.dart';
import 'package:path/path.dart' as p;
import 'package:pub_semver/pub_semver.dart';
import 'package:yaml/yaml.dart';

import 'environment.dart';
import 'exceptions.dart';

class ProjectContext {
  final String projectRoot;
  final Environment env;

  /// The workspace root if [projectRoot] is a workspace member, or null if it
  /// is not a workspace member (including the workspace root itself).
  final String? _workspaceRoot;

  ProjectContext._(
    this.projectRoot, {
    required this.env,
    required String? workspaceRoot,
  }) : _workspaceRoot = workspaceRoot;

  /// Detects whether [projectRoot] is a pub workspace member and, if so, walks
  /// up the directory tree to find the workspace root.
  ///
  /// Throws [PubdocException] if the project declares `resolution: workspace`
  /// but no workspace root can be found within 10 parent directories.
  factory ProjectContext.from(String projectRoot, {required Environment env}) {
    final pubspecFile = env.fs.file(p.join(projectRoot, 'pubspec.yaml'));
    String? workspaceRoot;
    if (pubspecFile.existsSync()) {
      final YamlMap? pubspec;
      try {
        pubspec = loadYaml(pubspecFile.readAsStringSync()) as YamlMap?;
      } catch (_) {
        return ProjectContext._(projectRoot, env: env, workspaceRoot: null);
      }
      if (pubspec != null && pubspec['resolution'] == 'workspace') {
        // Walk up to find the workspace root (max 10 levels).
        var current = p.dirname(projectRoot);
        for (var depth = 0; depth < 10; depth++) {
          final candidate = env.fs.file(p.join(current, 'pubspec.yaml'));
          if (candidate.existsSync()) {
            try {
              final yaml = loadYaml(candidate.readAsStringSync()) as YamlMap?;
              if (yaml != null && yaml.containsKey('workspace')) {
                workspaceRoot = current;
                break;
              }
            } catch (_) {}
          }
          final parent = p.dirname(current);
          if (parent == current) break;
          current = parent;
        }
        if (workspaceRoot == null) {
          // Found `resolution: workspace` but no workspace root — invalid repository structure.
          throw PubdocException(
            'pubspec.yaml in $projectRoot declares `resolution: workspace`, '
            'but no workspace root (pubspec.yaml with `workspace:` key) was found '
            'in the parent directories.',
          );
        }
      }
    }
    return ProjectContext._(
      projectRoot,
      env: env,
      workspaceRoot: workspaceRoot,
    );
  }

  /// Resolves to the workspace root when [projectRoot] is a workspace member,
  /// or [projectRoot] itself otherwise.
  String get _effectiveRoot => _workspaceRoot ?? projectRoot;

  File get pubspecLockFile =>
      env.fs.file(p.join(_effectiveRoot, 'pubspec.lock'));

  File get packageConfigFile =>
      env.fs.file(p.join(_effectiveRoot, '.dart_tool', 'package_config.json'));

  Directory get pubdocDir =>
      env.fs.directory(p.join(_effectiveRoot, '.pubdoc'));

  /// Validates that required files exist.
  void validate() {
    if (!pubspecLockFile.existsSync()) {
      throw PubdocException(
        'pubspec.lock not found in $_effectiveRoot. '
        'Run `dart pub get` first.',
      );
    }
    if (!packageConfigFile.existsSync()) {
      throw PubdocException(
        '.dart_tool/package_config.json not found. '
        'Run `dart pub get` first.',
      );
    }
  }

  /// Parses `pubspec.lock` and returns the version for [packageName].
  ///
  /// Reads the file as a stream of lines and stops as soon as the version
  /// for [packageName] is found, avoiding loading the full file into memory.
  Future<Version> getPackageVersion(String packageName) async {
    final lines = pubspecLockFile
        .openRead()
        .transform(utf8.decoder)
        .transform(const LineSplitter());

    var inPackage = false;
    await for (final line in lines) {
      if (!inPackage) {
        if (line == '  $packageName:') {
          inPackage = true;
        }
      } else {
        if (line.startsWith('    version: ')) {
          final versionStr = line
              .substring('    version: '.length)
              .trim()
              .replaceAll('"', '');
          return Version.parse(versionStr);
        }
        // A new 2-space-indented key means we've left the package section.
        if (line.length >= 3 &&
            line[0] == ' ' &&
            line[1] == ' ' &&
            line[2] != ' ' &&
            line.trim().isNotEmpty) {
          break;
        }
      }
    }
    throw PubdocException("Package '$packageName' not found in pubspec.lock.");
  }

  /// Parses `.dart_tool/package_config.json` and returns the source directory
  /// for [packageName].
  ///
  /// Reads the file as a stream of lines and stops as soon as the entry for
  /// [packageName] is found, avoiding loading the full file into memory.
  Future<Directory> getPackageSourceDir(String packageName) async {
    final lines = packageConfigFile
        .openRead()
        .transform(utf8.decoder)
        .transform(const LineSplitter());

    var inPackage = false;
    await for (final line in lines) {
      final trimmed = line.trim();
      if (!inPackage) {
        if (trimmed == '"name": "$packageName"' ||
            trimmed == '"name": "$packageName",') {
          inPackage = true;
        }
      } else {
        if (trimmed == '}' || trimmed == '},') {
          // Left the package object without finding rootUri; keep searching.
          inPackage = false;
          continue;
        }
        if (trimmed.startsWith('"rootUri": "')) {
          final uriStr = trimmed
              .substring('"rootUri": "'.length)
              .replaceAll(RegExp(r'",?$'), '');
          final rootUri = Uri.parse(uriStr);
          // Resolve relative URIs against the package_config.json location.
          final resolved = Uri.file(
            '${packageConfigFile.parent.path}/',
          ).resolveUri(rootUri);
          return env.fs.directory(resolved.toFilePath());
        }
      }
    }
    throw PubdocException(
      "Package '$packageName' not found in package_config.json.",
    );
  }
}
