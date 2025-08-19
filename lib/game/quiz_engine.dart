import 'dart:math';
import 'models.dart';

class QuizEngine {
  final List<Department> all;
  final Random _rng = Random();
  List<Department> _queue = [];
  Department? _lastTarget;

  QuizEngine(this.all);

  QuizQuestion nextQuestion({int optionsCount = 4}) {
    if (all.length < optionsCount) {
      throw StateError('Not enough departments for $optionsCount options');
    }
    if (_queue.isEmpty) {
      _queue = List<Department>.from(all)..shuffle(_rng);
      if (_lastTarget != null &&
          _queue.length > 1 &&
          _queue.first == _lastTarget) {
        _queue.add(_queue.removeAt(0));
      }
    }
    final target = _queue.removeAt(0);
    _lastTarget = target;

    // pick distinct distractors
    final Set<String> used = {target.name};
    final List<String> opts = [];

    while (opts.length < optionsCount - 1) {
      final d = all[_rng.nextInt(all.length)];
      if (!used.contains(d.name)) {
        used.add(d.name);
        opts.add(d.name);
      }
    }
    // insert the correct answer at a random position
    final correctIndex = _rng.nextInt(optionsCount);
    opts.insert(correctIndex, target.name);

    return QuizQuestion(
      target: target,
      options: opts,
      correctIndex: correctIndex,
    );
  }
}
