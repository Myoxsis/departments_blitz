import 'package:departments_blitz/game/models.dart';
import 'package:departments_blitz/game/quiz_engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final departments = [
    Department(code: 'A', name: 'Alpha'),
    Department(code: 'B', name: 'Bravo'),
    Department(code: 'C', name: 'Charlie'),
    Department(code: 'D', name: 'Delta'),
  ];

  test('cycles through all departments before repeating', () {
    final engine = QuizEngine(departments);
    final seen = <String>{};
    for (var i = 0; i < departments.length; i++) {
      final q = engine.nextQuestion();
      seen.add(q.target.code);
    }
    expect(seen, departments.map((d) => d.code).toSet());
  });

  test('consecutive questions use different departments', () {
    final engine = QuizEngine(departments);
    Department? prev;
    for (var i = 0; i < departments.length * 3; i++) {
      final q = engine.nextQuestion();
      if (prev != null) {
        expect(q.target.code, isNot(prev.code));
      }
      prev = q.target;
    }
  });
}

