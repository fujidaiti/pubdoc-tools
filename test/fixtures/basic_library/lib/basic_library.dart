/// A basic test library for dartdoc_md.
///
/// This library contains various Dart elements for testing
/// the Markdown documentation generator.
library basic_library;

/// A simple class with documentation.
///
/// This class demonstrates basic features like
/// constructors, methods, and properties.
class MyClass {
  /// The name of this instance.
  final String name;

  /// The count value.
  int count;

  /// Creates a new [MyClass] with the given [name].
  MyClass(this.name, {this.count = 0});

  /// Creates a [MyClass] with default values.
  MyClass.defaults() : name = 'default', count = 0;

  /// Returns a greeting message.
  String greet() {
    return 'Hello, $name!';
  }

  /// A method with a longer body that exceeds the threshold.
  ///
  /// This method does multiple things:
  /// - Validates input
  /// - Processes data
  /// - Returns result
  String processData(String input) {
    if (input.isEmpty) {
      return '';
    }
    var result = input.trim();
    result = result.toLowerCase();
    result = result.replaceAll(' ', '_');
    if (result.length > 100) {
      result = result.substring(0, 100);
    }
    return result;
  }

  @override
  String toString() => 'MyClass($name)';
}

/// A simple enumeration.
///
/// Represents different colors.
enum Color {
  /// The color red.
  red,

  /// The color green.
  green,

  /// The color blue.
  blue,
}

/// A simple top-level function.
///
/// Returns the sum of [a] and [b].
int add(int a, int b) => a + b;

/// A top-level constant.
const String defaultName = 'World';

/// A top-level variable.
int globalCounter = 0;
