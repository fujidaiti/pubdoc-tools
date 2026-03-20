import 'package:pubdoc/src/get_command.dart';
import 'package:test/test.dart';

void main() {
  group('buildPackageConfigFor', () {
    test('returns transitive closure, excludes unrelated packages', () {
      // Graph: A -> B -> C, D is unrelated
      final packageConfig = {
        'configVersion': 2,
        'packages': [
          {'name': 'A', 'rootUri': '../a', 'packageUri': 'lib/'},
          {'name': 'B', 'rootUri': '../b', 'packageUri': 'lib/'},
          {'name': 'C', 'rootUri': '../c', 'packageUri': 'lib/'},
          {'name': 'D', 'rootUri': '../d', 'packageUri': 'lib/'},
        ],
      };
      final packageGraph = {
        'configVersion': 1,
        'packages': [
          {
            'name': 'A',
            'dependencies': ['B'],
          },
          {
            'name': 'B',
            'dependencies': ['C'],
          },
          {'name': 'C', 'dependencies': <String>[]},
          {'name': 'D', 'dependencies': <String>[]},
        ],
      };

      final result = buildPackageConfigFor(
        package: 'A',
        projectPackageConfig: packageConfig,
        projectPackageGraph: packageGraph,
      );

      final names = [
        for (final p in result['packages'] as List)
          (p as Map<String, dynamic>)['name'],
      ];
      expect(names, containsAll(['A', 'B', 'C']));
      expect(names, isNot(contains('D')));
    });

    test('root with no deps keeps only the root package', () {
      final packageConfig = {
        'configVersion': 2,
        'packages': [
          {'name': 'root', 'rootUri': '../root', 'packageUri': 'lib/'},
          {'name': 'other', 'rootUri': '../other', 'packageUri': 'lib/'},
        ],
      };
      final packageGraph = {
        'configVersion': 1,
        'packages': [
          {'name': 'root', 'dependencies': <String>[]},
          {'name': 'other', 'dependencies': <String>[]},
        ],
      };

      final result = buildPackageConfigFor(
        package: 'root',
        projectPackageConfig: packageConfig,
        projectPackageGraph: packageGraph,
      );

      final names = [
        for (final p in result['packages'] as List)
          (p as Map<String, dynamic>)['name'],
      ];
      expect(names, ['root']);
    });

    test('preserves top-level fields', () {
      final packageConfig = {
        'configVersion': 2,
        'generator': 'pub',
        'generatorVersion': '3.0.0',
        'packages': [
          {'name': 'foo', 'rootUri': '../foo', 'packageUri': 'lib/'},
        ],
      };
      final packageGraph = {
        'configVersion': 1,
        'packages': [
          {'name': 'foo', 'dependencies': <String>[]},
        ],
      };

      final result = buildPackageConfigFor(
        package: 'foo',
        projectPackageConfig: packageConfig,
        projectPackageGraph: packageGraph,
      );

      expect(result['configVersion'], 2);
      expect(result['generator'], 'pub');
      expect(result['generatorVersion'], '3.0.0');
    });

    test('does not modify the original maps', () {
      final packages = [
        {'name': 'A', 'rootUri': '../a', 'packageUri': 'lib/'},
        {'name': 'B', 'rootUri': '../b', 'packageUri': 'lib/'},
      ];
      final packageConfig = {'configVersion': 2, 'packages': packages};
      final packageGraph = {
        'configVersion': 1,
        'packages': [
          {'name': 'A', 'dependencies': <String>[]},
          {'name': 'B', 'dependencies': <String>[]},
        ],
      };

      buildPackageConfigFor(
        package: 'A',
        projectPackageConfig: packageConfig,
        projectPackageGraph: packageGraph,
      );

      // Original packages list should still have both entries.
      expect(packages.length, 2);
    });
  });
}
