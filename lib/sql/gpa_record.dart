import 'dart:convert';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:gpa_calculator/classes/subject.dart';

class GPARecord {
  final int? id;
  final String semesterName;
  final double gpa;
  final int totalCredits;
  final double totalPoints;
  final DateTime date;
  final List<Subject> subjects;

  GPARecord({
    this.id,
    required this.semesterName,
    required this.gpa,
    required this.totalCredits,
    required this.totalPoints,
    required this.date,
    required this.subjects,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'semesterName': semesterName,
      'gpa': gpa,
      'totalCredits': totalCredits,
      'totalPoints': totalPoints,
      'date': date.toIso8601String(),
      'subjects': subjects.map((s) => s.toMap()).toList(),
    };
  }

  factory GPARecord.fromMap(Map<String, dynamic> map) {
    return GPARecord(
      id: map['id'],
      semesterName: map['semesterName'],
      gpa: map['gpa'],
      totalCredits: map['totalCredits'],
      totalPoints: map['totalPoints'],
      date: DateTime.parse(map['date']),
      subjects:
          (map['subjects'] as List).map((s) => Subject.fromMap(s)).toList(),
    );
  }
}

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('gpa_calculator.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE gpa_records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        semesterName TEXT NOT NULL,
        gpa REAL NOT NULL,
        totalCredits INTEGER NOT NULL,
        totalPoints REAL NOT NULL,
        date TEXT NOT NULL,
        subjects TEXT NOT NULL
      )
    ''');
  }

  Future<int> insertGPARecord(GPARecord record) async {
    final db = await instance.database;
    final recordMap = record.toMap();
    recordMap['subjects'] = json.encode(recordMap['subjects']);

    return await db.insert('gpa_records', recordMap);
  }

  Future<List<GPARecord>> getGPARecords() async {
    final db = await instance.database;
    final result = await db.query('gpa_records', orderBy: 'date DESC');

    return result.map((map) {
      final recordMap = Map<String, dynamic>.from(map);
      recordMap['subjects'] = json.decode(recordMap['subjects']);
      return GPARecord.fromMap(recordMap);
    }).toList();
  }

  Future<int> deleteGPARecord(int id) async {
    final db = await instance.database;
    return await db.delete('gpa_records', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> clearGPARecords() async {
    final db = await instance.database;
    await db.delete('gpa_records');
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
