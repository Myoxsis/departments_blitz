import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../ad_helper.dart';
import '../widgets/gradient_background.dart';
import 'models.dart';
import 'quiz_engine.dart';

class GamePage extends StatefulWidget {
  final List<Department> departments;
  const GamePage({super.key, required this.departments});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  late QuizEngine engine;
  QuizQuestion? current;
  int score = 0;
  int total = 0;
  int hints = 1; // start with 1; more via rewarded
  Timer? _timer;
  int secondsLeft = 60;
  bool _fiftyUsedOnThisQ = false;

  RewardedAd? _rewardedAd;
  bool _loadingRewarded = false;

  @override
  void initState() {
    super.initState();
    engine = QuizEngine(widget.departments);
    _nextQuestion();
    _startTimer();
    _preloadRewarded();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (secondsLeft <= 1) {
        t.cancel();
        _endRound();
      } else {
        setState(() => secondsLeft--);
      }
    });
  }

  void _endRound() async {
    // navigate to results
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(
      '/results',
      arguments: {'score': score, 'total': total},
    );
  }

  void _nextQuestion() {
    setState(() {
      current = engine.nextQuestion();
      _fiftyUsedOnThisQ = false;
    });
  }

  void _answer(int index) {
    if (current == null) return;
    setState(() {
      total++;
      if (index == current!.correctIndex) {
        score += 10; // 10 points per correct
      }
      _nextQuestion();
    });
  }

  // 50/50 hint: keep correct + one wrong
  void _applyFiftyFifty() {
    if (current == null || _fiftyUsedOnThisQ) return;
    final q = current!;
    final correctIdx = q.correctIndex;
    final List<String> newOpts = [q.options[correctIdx]];
    // pick a random wrong option to keep
    for (int i = 0; i < q.options.length; i++) {
      if (i != correctIdx) {
        newOpts.add(q.options[i]);
        break;
      }
    }
    newOpts.shuffle();
    final newCorrectIdx = newOpts.indexOf(q.options[correctIdx]);

    setState(() {
      current = QuizQuestion(
        target: q.target,
        options: newOpts,
        correctIndex: newCorrectIdx,
      );
      _fiftyUsedOnThisQ = true;
    });
  }

  void _useHint() {
    if (hints > 0) {
      setState(() {
        hints--;
      });
      _applyFiftyFifty();
    } else {
      _showGetHintDialog();
    }
  }

  void _preloadRewarded() {
    if (_loadingRewarded) return;
    _loadingRewarded = true;
    RewardedAd.load(
      adUnitId: AdHelper.rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _loadingRewarded = false;
        },
        onAdFailedToLoad: (err) {
          _rewardedAd = null;
          _loadingRewarded = false;
        },
      ),
    );
  }

  Future<void> _showGetHintDialog() async {
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Out of hints'),
        content: const Text('Watch a short video ad to get 1 hint?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('No thanks'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              _showRewarded();
            },
            child: const Text('Watch'),
          ),
        ],
      ),
    );
  }

  void _showRewarded() {
    final ad = _rewardedAd;
    if (ad == null) {
      _preloadRewarded();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ad not ready yet, try again.')),
      );
      return;
    }

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {},
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewardedAd = null;
        _preloadRewarded();
      },
      onAdFailedToShowFullScreenContent: (ad, err) {
        ad.dispose();
        _rewardedAd = null;
        _preloadRewarded();
      },
    );

    ad.show(
      onUserEarnedReward: (ad, reward) {
        setState(() {
          hints += 1;
        });
        // auto-apply the hint immediately to feel the reward
        _applyFiftyFifty();
      },
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _rewardedAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final q = current;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sprint (60s)'),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text('⏱️ $secondsLeft s'),
            ),
          ),
        ],
      ),
      body: GradientBackground(
        child: q == null
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Score: $score',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Which department matches code: ',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              q.target.code,
                              style: Theme.of(context).textTheme.displaySmall
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    for (int i = 0; i < q.options.length; i++) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6.0),
                        child: OutlinedButton(
                          onPressed: () => _answer(i),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Text(q.options[i]),
                          ),
                        ),
                      ),
                    ],
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Questions: $total'),
                        Row(
                          children: [
                            IconButton(
                              tooltip: 'Use 50/50 hint (remaining: $hints)',
                              onPressed: _useHint,
                              icon: const Icon(Icons.lightbulb_outline),
                            ),
                            Text('x$hints'),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
