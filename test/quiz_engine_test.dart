import 'package:flutter_test/flutter_test.dart';

import 'package:departments_blitz/game/models.dart';
import 'package:departments_blitz/game/quiz_engine.dart';

void main() {
  test('nextQuestion produces unique options even with hash collisions', () {
    // These two strings are known to produce identical hash codes in Dart.
    expect('420'.hashCode, '2166'.hashCode);

    final departments = [
      const Department(code: '1', name: '420'),
      const Department(code: '2', name: '2166'),
      const Department(code: '3', name: 'Alpha'),
      const Department(code: '4', name: 'Beta'),
    ];

    final engine = QuizEngine(departments);
    final question = engine.nextQuestion(optionsCount: 4);

    // All options must be unique despite hash code collisions.
    expect(question.options.toSet().length, equals(4));
  });
}

