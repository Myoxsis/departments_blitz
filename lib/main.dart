import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'game/home_page.dart';
import 'game/game_page.dart';
import 'game/results_page.dart';
import 'game/models.dart';
import 'game/results_args.dart';

Future<List<Department>> loadDepartments() async {
  try {
    final jsonStr = await rootBundle.loadString('assets/departments.json');
    return parseDepartmentsJson(jsonStr);
  } on FlutterError catch (e) {
    throw FlutterError('Failed to load departments asset: ${e.message}');
  } on FormatException catch (e) {
    throw FormatException('Failed to parse departments: ${e.message}');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MobileAds.instance.initialize();
  try {
    final departments = await loadDepartments();
    runApp(BlitzApp(departments: departments));
  } on FlutterError catch (e) {
    runApp(ErrorApp(message: e.message));
  } on FormatException catch (e) {
    runApp(ErrorApp(message: e.message));
  }
}

class ErrorApp extends StatelessWidget {
  final String message;
  const ErrorApp({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Departments Blitz - Error',
      home: Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(message, textAlign: TextAlign.center),
          ),
        ),
      ),
    );
  }
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
          final args = settings.arguments as ResultsArgs?;
          return MaterialPageRoute(
            builder: (_) => ResultsPage(
              args: args ?? const ResultsArgs(score: 0, total: 0),
            ),
          );
        }
        return null;
      },
    );
  }
}
