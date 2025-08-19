import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../ad_helper.dart';
import 'results_args.dart';

class ResultsPage extends StatefulWidget {
  final ResultsArgs args;
  const ResultsPage({super.key, required this.args});

  @override
  State<ResultsPage> createState() => _ResultsPageState();
}

class _ResultsPageState extends State<ResultsPage> {
  InterstitialAd? _interstitial;

  @override
  void initState() {
    super.initState();
    _loadInterstitial();
  }

  void _loadInterstitial() {
    InterstitialAd.load(
      adUnitId: AdHelper.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) => _interstitial = ad,
        onAdFailedToLoad: (err) => _interstitial = null,
      ),
    );
  }

  Future<void> _showInterstitialThen(VoidCallback next) async {
    final ad = _interstitial;
    if (ad == null) {
      next();
      return;
    }
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _interstitial = null;
        next();
      },
      onAdFailedToShowFullScreenContent: (ad, err) {
        ad.dispose();
        _interstitial = null;
        next();
      },
    );
    ad.show();
  }

  @override
  void dispose() {
    _interstitial?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final acc = widget.args.total == 0
        ? 0
        : ((widget.args.score / (widget.args.total * 10)) * 100).round();
    return Scaffold(
      appBar: AppBar(title: const Text('Results')),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF7C3AED), Color(0xFF4F46E5)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Score', style: Theme.of(context).textTheme.titleLarge),
              Text(
                '${widget.args.score}',
                style: Theme.of(context).textTheme.displayMedium,
              ),
              const SizedBox(height: 8),
              Text('Questions answered: ${widget.args.total}'),
              Text('Accuracy: $acc%'),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => _showInterstitialThen(
                  () => Navigator.of(context).pushReplacementNamed('/game'),
                ),
                child: const Text('Play again'),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => _showInterstitialThen(
                  () => Navigator.of(context).pushReplacementNamed('/'),
                ),
                child: const Text('Back to Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
