import 'package:dartdoc_txt/dartdoc_txt.dart';
import 'package:test/test.dart';

import '../test_helper.dart';

void main() {
  late DocDir docTree;

  setUpAll(() async {
    docTree = await renderFixture('basic_library');
  });

  group('output structure', () {
    test('creates INDEX.md at root', () {
      expect(docTree.findFile('INDEX.md'), isNotNull);
    });

    test('creates library directory', () {
      expect(docTree.findDir('basic_library'), isNotNull);
    });

    test('does not create library INDEX.md', () {
      expect(docTree.findFile('basic_library/INDEX.md'), isNull);
    });

    test('creates README.md at root', () {
      expect(docTree.findFile('README.md'), isNotNull);
    });

    test('creates class file', () {
      expect(docTree.findFile('basic_library/MyClass/MyClass.md'), isNotNull);
    });

    test('creates enum file', () {
      expect(docTree.findFile('basic_library/Color/Color.md'), isNotNull);
    });

    test('creates top-level-functions.md', () {
      expect(
        docTree.findFile(
          'basic_library/top-level-functions/top-level-functions.md',
        ),
        isNotNull,
      );
    });

    test('creates top-level-properties.md', () {
      expect(
        docTree.findFile(
          'basic_library/top-level-properties/top-level-properties.md',
        ),
        isNotNull,
      );
    });

    test('creates detail subdirectory for class with large method', () {
      expect(docTree.findDir('basic_library/MyClass'), isNotNull);
    });

    test('creates detail page for method exceeding threshold', () {
      expect(
        docTree.findFile('basic_library/MyClass/MyClass-processData.md'),
        isNotNull,
      );
    });

    test('creates detail page for named constructor exceeding threshold', () {
      expect(
        docTree.findFile('basic_library/MyClass/MyClass-fromMap.md'),
        isNotNull,
      );
    });
  });

  group('src library filtering', () {
    test('does not create src/ directory in output', () {
      expect(docTree.findDir('src'), isNull);
    });

    test('INDEX.md does not reference src libraries', () {
      var content = docTree.findFile('INDEX.md')!.renderContent();
      expect(content, isNot(contains('src/')));
    });

    test('re-exported elements appear under top-level library', () {
      // MyClass is defined in lib/src/my_class.dart but exported by lib/basic_library.dart
      expect(docTree.findFile('basic_library/MyClass/MyClass.md'), isNotNull);
    });
  });

  group('package index content', () {
    test('contains package name', () {
      var content = docTree.findFile('INDEX.md')!.renderContent();
      expect(content, contains('# basic_library Index'));
    });

    test('contains version', () {
      var content = docTree.findFile('INDEX.md')!.renderContent();
      expect(content, contains('Version: 1.0.0'));
    });

    test('contains library heading', () {
      var content = docTree.findFile('INDEX.md')!.renderContent();
      expect(content, contains('## basic_library library'));
    });
  });

  group('library index content', () {
    test('contains library name', () {
      var content = docTree.findFile('INDEX.md')!.renderContent();
      expect(content, contains('## basic_library library'));
    });

    test('lists classes', () {
      var content = docTree.findFile('INDEX.md')!.renderContent();
      expect(content, contains('[MyClass](basic_library/MyClass/MyClass.md)'));
    });

    test('lists enums', () {
      var content = docTree.findFile('INDEX.md')!.renderContent();
      expect(content, contains('[Color](basic_library/Color/Color.md)'));
    });

    test('references top-level functions file', () {
      var content = docTree.findFile('INDEX.md')!.renderContent();
      expect(
        content,
        contains('basic_library/top-level-functions/top-level-functions.md'),
      );
    });

    test('"See" references include "for more details."', () {
      var content = docTree.findFile('INDEX.md')!.renderContent();
      expect(
        content,
        contains(
          'See [top-level-functions.md](basic_library/top-level-functions/top-level-functions.md) for more details.',
        ),
      );
      expect(
        content,
        contains(
          'See [top-level-properties.md](basic_library/top-level-properties/top-level-properties.md) for more details.',
        ),
      );
    });

    test('lists functions inline', () {
      var content = docTree.findFile('INDEX.md')!.renderContent();
      expect(content, contains('- add — A simple top-level function.'));
    });

    test('lists properties inline', () {
      var content = docTree.findFile('INDEX.md')!.renderContent();
      expect(content, contains('- defaultName — A top-level constant.'));
      expect(content, contains('- globalCounter — A top-level variable.'));
    });
  });

  group('class file content', () {
    test('contains class declaration', () {
      var content = docTree
          .findFile('basic_library/MyClass/MyClass.md')!
          .renderContent();
      expect(content, contains('```dart\nclass MyClass\n```'));
    });

    test('contains documentation', () {
      var content = docTree
          .findFile('basic_library/MyClass/MyClass.md')!
          .renderContent();
      expect(content, contains('A simple class with documentation.'));
    });

    test('contains constructors section', () {
      var content = docTree
          .findFile('basic_library/MyClass/MyClass.md')!
          .renderContent();
      expect(content, contains('## Constructors'));
      expect(content, contains('### MyClass.new('));
    });

    test('contains properties section', () {
      var content = docTree
          .findFile('basic_library/MyClass/MyClass.md')!
          .renderContent();
      expect(content, contains('## Properties'));
      expect(content, contains('### name → String'));
    });

    test('contains methods section', () {
      var content = docTree
          .findFile('basic_library/MyClass/MyClass.md')!
          .renderContent();
      expect(content, contains('## Methods'));
      expect(content, contains('### greet() → String'));
    });

    test('embeds small method source inline', () {
      var content = docTree
          .findFile('basic_library/MyClass/MyClass.md')!
          .renderContent();
      // greet() is small enough to be inline
      expect(content, contains("return 'Hello, \$name!';"));
    });

    test('links large method to detail page', () {
      var content = docTree
          .findFile('basic_library/MyClass/MyClass.md')!
          .renderContent();
      expect(
        content,
        contains('[full implementation](MyClass-processData.md)'),
      );
    });

    test('links large named constructor to detail page', () {
      var content = docTree
          .findFile('basic_library/MyClass/MyClass.md')!
          .renderContent();
      expect(content, contains('[full implementation](MyClass-fromMap.md)'));
    });

    test('does not include inherited Object members', () {
      var content = docTree
          .findFile('basic_library/MyClass/MyClass.md')!
          .renderContent();
      // Should NOT have hashCode, runtimeType, noSuchMethod, operator ==
      expect(content, isNot(contains('### hashCode')));
      expect(content, isNot(contains('### runtimeType')));
      expect(content, isNot(contains('### noSuchMethod')));
    });

    test('source code has no HTML entities', () {
      var content = docTree
          .findFile('basic_library/MyClass/MyClass.md')!
          .renderContent();
      expect(content, isNot(contains('&#39;')));
      expect(content, isNot(contains('&amp;')));
      expect(content, isNot(contains('&lt;')));
      expect(content, isNot(contains('&gt;')));
    });
  });

  group('detail page content', () {
    test('contains parent.member title', () {
      var content = docTree
          .findFile('basic_library/MyClass/MyClass-processData.md')!
          .renderContent();
      expect(content, contains('# MyClass.processData'));
    });

    test('contains signature', () {
      var content = docTree
          .findFile('basic_library/MyClass/MyClass-processData.md')!
          .renderContent();
      expect(content, contains('processData(String input) → String'));
    });

    test('contains full source code', () {
      var content = docTree
          .findFile('basic_library/MyClass/MyClass-processData.md')!
          .renderContent();
      expect(content, contains('## Source'));
      expect(content, contains('result = result.toLowerCase()'));
    });
  });

  group('constructor detail page content', () {
    test('contains parent.member title', () {
      var content = docTree
          .findFile('basic_library/MyClass/MyClass-fromMap.md')!
          .renderContent();
      expect(content, contains('# MyClass.fromMap'));
    });

    test('contains full source code', () {
      var content = docTree
          .findFile('basic_library/MyClass/MyClass-fromMap.md')!
          .renderContent();
      expect(content, contains('## Source'));
      expect(content, contains("throw ArgumentError('name is required')"));
    });
  });

  group('edge_cases library index', () {
    late DocDir edgeCasesTree;

    setUpAll(() async {
      edgeCasesTree = await renderFixture('edge_cases');
    });

    test('lists typedefs inline', () {
      var content = edgeCasesTree.findFile('INDEX.md')!.renderContent();
      expect(
        content,
        contains(
          '- StringCallback — A typedef for a callback that takes a [String].',
        ),
      );
    });

    test(
      'excludes hashCode, operator ==, and toString even when explicitly declared',
      () {
        var content = edgeCasesTree
            .findFile('edge_cases/Comparable2/Comparable2.md')!
            .renderContent();
        expect(content, isNot(contains('hashCode')));
        expect(content, isNot(contains('operator ==')));
        expect(content, isNot(contains('toString')));
        // But other operators should still be present
        expect(content, contains('operator +'));
      },
    );

    test('"See" reference for typedefs includes "for more details."', () {
      var content = edgeCasesTree.findFile('INDEX.md')!.renderContent();
      expect(
        content,
        contains(
          'See [typedefs.md](edge_cases/typedefs/typedefs.md) for more details.',
        ),
      );
    });
  });
}
