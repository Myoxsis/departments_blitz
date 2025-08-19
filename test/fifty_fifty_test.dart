import 'dart:math';

import 'package:departments_blitz/game/game_page.dart';
import 'package:departments_blitz/game/models.dart';
import 'package:test/test.dart';

void main() {
  test('50/50 retains varying wrong options', () {
    final question = QuizQuestion(
      target: const Department(code: 'CS', name: 'Computer Science'),
      options: const ['Correct', 'Wrong1', 'Wrong2'],
      correctIndex: 0,
    );
    final keptWrong = <String>{};
    for (int i = 0; i < 100; i++) {
      final result = applyFiftyFiftyToQuestion(question, Random(i));
      final wrong =
          result.options.firstWhere((opt) => opt != 'Correct');
      keptWrong.add(wrong);
    }
    expect(keptWrong.length, greaterThan(1));
  });
}

