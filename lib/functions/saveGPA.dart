import 'package:gpa_calculator/classes/subject.dart';
import 'package:gpa_calculator/sql/gpa_record.dart';

Future<void> saveGPARecord({
  required String semesterName,
  required double gpa,
  required int totalCredits,
  required double totalPoints,
  required List<Subject> subjects,
}) async {
  final record = GPARecord(
    semesterName: semesterName,
    gpa: gpa,
    totalCredits: totalCredits,
    totalPoints: totalPoints,
    date: DateTime.now(),
    subjects: subjects,
  );

  await DatabaseHelper.instance.insertGPARecord(record);
}
