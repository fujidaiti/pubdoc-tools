import 'package:dartdoc_txt/dartdoc_txt.dart';
import 'package:test/test.dart';

import '../test_helper.dart';

void main() {
  late DocDir docTree;

  setUpAll(() async {
    docTree = await renderFixture('categories');
  });

  group('topics directory structure', () {
    test('creates topics/ directory', () {
      expect(docTree.findDir('topics'), isNotNull);
    });

    test('creates getting-started.md from doc/ subdirectory', () {
      expect(docTree.findFile('topics/getting-started.md'), isNotNull);
    });

    test('creates utilities.md', () {
      expect(docTree.findFile('topics/utilities.md'), isNotNull);
    });
  });

  group('package index topics section', () {
    test('contains Topics heading', () {
      var content = docTree.findFile('INDEX.md')!.renderContent();
      expect(content, contains('## Topics'));
    });

    test('links to Getting Started topic file', () {
      var content = docTree.findFile('INDEX.md')!.renderContent();
      expect(content, contains('[Getting Started](topics/getting-started.md)'));
    });

    test('links to Utilities topic file', () {
      var content = docTree.findFile('INDEX.md')!.renderContent();
      expect(content, contains('[Utilities](topics/utilities.md)'));
    });
  });

  group('topic file content — Getting Started', () {
    late String content;

    setUp(() {
      content = docTree.findFile('topics/getting-started.md')!.renderContent();
    });

    test('contains documentation text', () {
      expect(content, contains('Welcome to the categories package.'));
    });

    test('contains elements heading', () {
      expect(content, contains('## Elements in this category'));
    });

    test('contains Classes section with Greeter', () {
      expect(content, contains('### Classes'));
      expect(content, contains('[Greeter](categories/Greeter/Greeter.md)'));
    });

    test('contains Enums section with BasicColor', () {
      expect(content, contains('### Enums'));
      expect(
        content,
        contains('[BasicColor](categories/BasicColor/BasicColor.md)'),
      );
    });

    test('does not contain elements from other categories', () {
      expect(content, isNot(contains('StringHelper')));
      expect(content, isNot(contains('capitalize')));
    });
  });

  group('topic file content — Utilities', () {
    late String content;

    setUp(() {
      content = docTree.findFile('topics/utilities.md')!.renderContent();
    });

    test('contains documentation text', () {
      expect(content, contains('Utility classes and functions.'));
    });

    test('contains Classes section with StringHelper', () {
      expect(content, contains('### Classes'));
      expect(
        content,
        contains('[StringHelper](categories/StringHelper/StringHelper.md)'),
      );
    });

    test('contains Functions section with capitalize as plain text', () {
      expect(content, contains('### Functions'));
      expect(content, contains('- capitalize'));
    });

    test('does not contain elements from other categories', () {
      expect(content, isNot(contains('Greeter')));
      expect(content, isNot(contains('BasicColor')));
    });
  });
}
