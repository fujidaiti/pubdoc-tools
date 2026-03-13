import 'package:dartdoc_txt/dartdoc_txt.dart';
import 'package:test/test.dart';

import '../test_helper.dart';

void main() {
  group('anonymous library output', () {
    late DocDir docTree;

    setUpAll(() async {
      docTree = await renderFixture('anonymous_library');
    });

    test('uses clean directory name for anonymous library', () {
      // Should use displayName (e.g., "anonymous_library"), not dirName
      // (which would be "file-___Users_..._anonymous_library")
      expect(docTree.findDir('anonymous_library'), isNotNull);
    });

    test('does not create directory with file-prefix path', () {
      // Verify no directory starting with "file-" was created
      var dirs = docTree.children.whereType<DocDir>().map((d) => d.name);
      expect(dirs, everyElement(isNot(startsWith('file-'))));
    });

    test('package index links use clean path', () {
      var content = docTree.findFile('INDEX.md')!.renderContent();
      expect(content, contains('## anonymous_library library'));
      expect(content, isNot(contains('file-')));
    });
  });
}
