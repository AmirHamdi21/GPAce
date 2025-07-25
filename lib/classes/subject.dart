class Subject {
  String name;
  int creditHours;
  String grade;
  bool isValid;

  Subject({
    this.name = '',
    this.creditHours = 3,
    this.grade = '',
    this.isValid = false,
  });
  // Add these methods to your Subject class

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'creditHours': creditHours,
      'grade': grade,
    };
  }

  factory Subject.fromMap(Map<String, dynamic> map) {
    return Subject(
      name: map['name'],
      creditHours: map['creditHours'],
      grade: map['grade'],
    );
  }
}
