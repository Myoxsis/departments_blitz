import 'dart:convert';

class Department {
  final String code;
  final String name;
  const Department({required this.code, required this.name});

  factory Department.fromJson(Map<String, dynamic> m) =>
      Department(code: m['code'] as String, name: m['name'] as String);
}

class QuizQuestion {
  final Department target;
  final List<String> options; // department names (includes correct)
  final int correctIndex;
  QuizQuestion({
    required this.target,
    required this.options,
    required this.correctIndex,
  });
}

List<Department> parseDepartmentsJson(String jsonStr) {
  try {
    final List<dynamic> arr = json.decode(jsonStr) as List<dynamic>;
    return arr
        .map((e) => Department.fromJson(e as Map<String, dynamic>))
        .toList();
  } catch (e) {
    throw FormatException('Failed to parse departments JSON: $e');
  }
}
