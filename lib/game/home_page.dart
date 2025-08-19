import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Departments Blitz')),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF7C3AED), Color(0xFF4F46E5)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  '60-second sprint. Match the code to the department name.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () => Navigator.of(context).pushNamed('/game'),
                  child: const Text('Play Sprint (60s)'),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => showAboutDialog(
                    context: context,
                    applicationName: 'Departments Blitz',
                    applicationVersion: '1.0.0',
                    children: const [
                      Text('Ads: interstitial on results; rewarded for hints.'),
                    ],
                  ),
                  child: const Text('About'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
