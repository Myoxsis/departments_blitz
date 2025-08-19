import 'dart:math';
import 'models.dart';

class QuizEngine {
  final List<Department> all;
  final Random _rng = Random();

  QuizEngine(this.all);

  QuizQuestion nextQuestion({int optionsCount = 4}) {
    if (all.length < optionsCount) {
      throw StateError('Not enough departments for $optionsCount options');
    }
    final target = all[_rng.nextInt(all.length)];

    // pick distinct distractors
    final Set<String> used = {};
    final List<String> opts = [];

    // ensure correct answer included
    final correctName = target.name;

    while (opts.length < optionsCount - 1) {
      final d = all[_rng.nextInt(all.length)];
      if (d.name != correctName && !used.contains(d.name)) {
        used.add(d.name);
        opts.add(d.name);
      }
    }
    // insert the correct answer at a random position
    final correctIndex = _rng.nextInt(optionsCount);
    opts.insert(correctIndex, correctName);

    return QuizQuestion(
      target: target,
      options: opts,
      correctIndex: correctIndex,
    );
  }
}
