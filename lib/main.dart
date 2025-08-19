import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'game/home_page.dart';
import 'game/game_page.dart';
import 'game/results_page.dart';
import 'game/models.dart';

Future<List<Department>> loadDepartments() async {
  final jsonStr = await rootBundle.loadString('assets/departments.json');
  return parseDepartmentsJson(jsonStr);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MobileAds.instance.initialize();
  final departments = await loadDepartments();
  runApp(BlitzApp(departments: departments));
}

class BlitzApp extends StatelessWidget {
  final List<Department> departments;
  const BlitzApp({super.key, required this.departments});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Departments Blitz',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF7C3AED),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        cardTheme: CardTheme(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 4,
        ),
      ),
      routes: {
        '/': (_) => const HomePage(),
        '/game': (_) => GamePage(departments: departments),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/results') {
          final args = settings.arguments as Map<String, dynamic>?;
          final score = args?['score'] as int? ?? 0;
          final total = args?['total'] as int? ?? 0;
          return MaterialPageRoute(
            builder: (_) => ResultsPage(score: score, total: total),
          );
        }
        return null;
      },
    );
  }
}
