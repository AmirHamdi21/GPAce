import 'package:flutter/material.dart';
import 'package:gpa_calculator/Home/homepage.dart';
import 'package:gpa_calculator/Result/result_page.dart';
import 'package:gpa_calculator/classes/subject.dart';
import 'package:gpa_calculator/provider/theme_provider.dart';
import 'package:provider/provider.dart';

class SubjectInputPage extends StatefulWidget {
  const SubjectInputPage({super.key});

  @override
  State<SubjectInputPage> createState() => _SubjectInputPageState();
}

class _SubjectInputPageState extends State<SubjectInputPage>
    with TickerProviderStateMixin {
  final TextEditingController _semesterController = TextEditingController();
  List<Subject> subjects = [Subject()];
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  final List<String> grades = [
    'A+',
    'A',
    'A-',
    'B+',
    'B',
    'B-',
    'C+',
    'C',
    'C-',
    'D+',
    'D',
    'F'
  ];

  final Map<String, double> gradeValues = {
    'A+': 4.0,
    'A': 4.0,
    'A-': 3.7,
    'B+': 3.3,
    'B': 3.0,
    'B-': 2.7,
    'C+': 2.3,
    'C': 2.0,
    'C-': 1.7,
    'D+': 1.3,
    'D': 1.0,
    'F': 0.0,
  };

  @override
  void initState() {
    super.initState();
    // _semesterController.text = 'Spring 2025';
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _semesterController.dispose();
    super.dispose();
  }

  void addSubject() {
    setState(() {
      subjects.add(Subject());
    });
  }

  void removeSubject(int index) {
    if (subjects.length > 1) {
      setState(() {
        subjects.removeAt(index);
      });
    }
  }

  void calculateGPA() {
    // Check if all subjects are valid
    bool allValid = true;
    for (var subject in subjects) {
      if (subject.name.isEmpty ||
          subject.grade.isEmpty ||
          _semesterController.text.isEmpty) {
        allValid = false;
        break;
      }
    }

    if (!allValid) {
      if (_semesterController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please fill in semester details'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please fill in all subject details'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    // Calculate GPA
    double totalPoints = 0;
    int totalCredits = 0;

    for (var subject in subjects) {
      totalPoints += gradeValues[subject.grade]! * subject.creditHours;
      totalCredits += subject.creditHours;
    }

    double gpa = totalCredits > 0 ? totalPoints / totalCredits : 0;

    // Navigate to results page
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => GPAResultPage(
          semesterName: _semesterController.text,
          subjects: subjects,
          gpa: gpa,
          totalCredits: totalCredits,
          totalPoints: totalPoints,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;
    final screenWidth = MediaQuery.of(context).size.width;

    return Theme(
      data: Provider.of<ThemeProvider>(context).isDarkMode
          ? ThemeData.dark()
          : ThemeData.light(),
      child: Scaffold(
        backgroundColor: Provider.of<ThemeProvider>(context).isDarkMode
            ? const Color(0xFF1a1a1a)
            : Colors.white,
        body: CustomScrollView(
          slivers: [
            // App Bar
            SliverAppBar(
              toolbarHeight: 70.0,
              backgroundColor: Provider.of<ThemeProvider>(context).isDarkMode
                  ? const Color(0xFF2d3748)
                  : Colors.white,
              elevation: 0,
              pinned: true,
              expandedHeight: 0,
              flexibleSpace: Container(
                decoration: BoxDecoration(
                  color: Provider.of<ThemeProvider>(context).isDarkMode
                      ? const Color(0xFF2d3748)
                      : Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isTablet ? 40 : 20,
                      vertical: 16,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Logo
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => const HomePage()),
                                    (route) => false);
                              },
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF4299e1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.school,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'GPA Calculator',
                              style: TextStyle(
                                fontSize: isTablet ? 20 : 18,
                                fontWeight: FontWeight.bold,
                                color: Provider.of<ThemeProvider>(context)
                                        .isDarkMode
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ),
                          ],
                        ),
                        // Navigation
                        if (isTablet)
                          Row(
                            children: [
                              _buildNavItem('Home', false),
                              _buildNavItem('Input', true),
                              _buildNavItem('Result', false),
                              _buildNavItem('History', false),
                              const SizedBox(width: 20),
                              _buildThemeToggle(),
                            ],
                          )
                        else
                          _buildThemeToggle(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // Main Content
            SliverToBoxAdapter(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height - 70,
                  ),
                  color: Provider.of<ThemeProvider>(context).isDarkMode
                      ? const Color(0xFF1a1a1a)
                      : Colors.grey[50],
                  child: Center(
                    child: Container(
                      constraints: BoxConstraints(
                        maxWidth: isTablet ? 800 : screenWidth,
                      ),
                      margin: EdgeInsets.symmetric(
                        horizontal: isTablet ? 40 : 20,
                        vertical: 40,
                      ),
                      padding: EdgeInsets.all(isTablet ? 40 : 24),
                      decoration: BoxDecoration(
                        color: Provider.of<ThemeProvider>(context).isDarkMode
                            ? const Color(0xFF2d3748)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Header
                          Text(
                            'Enter Your Subjects',
                            style: TextStyle(
                              fontSize: isTablet ? 32 : 24,
                              fontWeight: FontWeight.bold,
                              color:
                                  Provider.of<ThemeProvider>(context).isDarkMode
                                      ? Colors.white
                                      : Colors.black,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Add your subjects and grades to calculate your GPA',
                            style: TextStyle(
                              fontSize: isTablet ? 16 : 14,
                              color:
                                  Provider.of<ThemeProvider>(context).isDarkMode
                                      ? Colors.white70
                                      : Colors.grey[600],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 40),

                          // Semester Name Input
                          Text(
                            'Semester Name',
                            style: TextStyle(
                              fontSize: isTablet ? 16 : 14,
                              fontWeight: FontWeight.w600,
                              color:
                                  Provider.of<ThemeProvider>(context).isDarkMode
                                      ? Colors.white
                                      : Colors.black,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _semesterController,
                            style: TextStyle(
                              color:
                                  Provider.of<ThemeProvider>(context).isDarkMode
                                      ? Colors.white
                                      : Colors.black,
                            ),
                            decoration: InputDecoration(
                              hintText: 'e.g., Spring 2025',
                              hintStyle: TextStyle(
                                color: Provider.of<ThemeProvider>(context)
                                        .isDarkMode
                                    ? Colors.white54
                                    : Colors.grey[400],
                              ),
                              filled: true,
                              fillColor:
                                  Provider.of<ThemeProvider>(context).isDarkMode
                                      ? const Color(0xFF4a5568)
                                      : Colors.grey[50],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Grade Scale Info
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF4299e1).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFF4299e1).withOpacity(0.3),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.info_outline,
                                      color: Color(0xFF4299e1),
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Grade Scale',
                                      style: TextStyle(
                                        fontSize: isTablet ? 16 : 14,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF4299e1),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                _buildGradeScale(isTablet),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Subjects List
                          ...subjects.asMap().entries.map((entry) {
                            int index = entry.key;
                            Subject subject = entry.value;
                            return _buildSubjectCard(subject, index, isTablet);
                          }).toList(),

                          const SizedBox(height: 24),

                          // Add Subject Button
                          ElevatedButton.icon(
                            onPressed: addSubject,
                            icon: const Icon(Icons.add),
                            label: const Text('Add Subject'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Provider.of<ThemeProvider>(context).isDarkMode
                                      ? const Color(0xFF4a5568)
                                      : Colors.grey[200],
                              foregroundColor:
                                  Provider.of<ThemeProvider>(context).isDarkMode
                                      ? Colors.white
                                      : Colors.black,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                          ),

                          const SizedBox(height: 32),

                          // Calculate GPA Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: calculateGPA,
                              icon: const Icon(Icons.calculate),
                              label: const Text('Calculate GPA'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4299e1),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 32,
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(String title, bool isActive) {
    return Container(
      margin: const EdgeInsets.only(right: 24),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF4299e1) : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        title,
        style: TextStyle(
          color: isActive
              ? Colors.white
              : (Provider.of<ThemeProvider>(context).isDarkMode
                  ? Colors.white70
                  : Colors.black54),
          fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildThemeToggle() {
    return GestureDetector(
      onTap: () async {
        // Make the toggle async since toggleTheme is now async
        await Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Provider.of<ThemeProvider>(context).isDarkMode
              ? Colors.white.withOpacity(0.1)
              : Colors.black.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          Provider.of<ThemeProvider>(context).isDarkMode
              ? Icons.light_mode
              : Icons.dark_mode,
          color: Provider.of<ThemeProvider>(context).isDarkMode
              ? Colors.white
              : Colors.black,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildGradeScale(bool isTablet) {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: [
        _buildGradeItem('A+: 4', isTablet),
        _buildGradeItem('A: 4', isTablet),
        _buildGradeItem('A-: 3.7', isTablet),
        _buildGradeItem('B+: 3.3', isTablet),
        _buildGradeItem('B: 3', isTablet),
        _buildGradeItem('B-: 2.7', isTablet),
        _buildGradeItem('C+: 2.3', isTablet),
        _buildGradeItem('C: 2', isTablet),
        _buildGradeItem('C-: 1.7', isTablet),
        _buildGradeItem('D+: 1.3', isTablet),
        _buildGradeItem('D: 1', isTablet),
        _buildGradeItem('F: 0', isTablet),
      ],
    );
  }

  Widget _buildGradeItem(String grade, bool isTablet) {
    return Text(
      grade,
      style: TextStyle(
        fontSize: isTablet ? 12 : 10,
        color: const Color(0xFF4299e1),
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildSubjectCard(Subject subject, int index, bool isTablet) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Provider.of<ThemeProvider>(context).isDarkMode
            ? const Color(0xFF4a5568)
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Provider.of<ThemeProvider>(context).isDarkMode
              ? const Color(0xFF4a5568)
              : Colors.grey[200]!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Subject ${index + 1}',
                style: TextStyle(
                  fontSize: isTablet ? 16 : 14,
                  fontWeight: FontWeight.w600,
                  color: Provider.of<ThemeProvider>(context).isDarkMode
                      ? Colors.white
                      : Colors.black,
                ),
              ),
              if (subjects.length > 1)
                IconButton(
                  onPressed: () => removeSubject(index),
                  icon: const Icon(Icons.delete_outline),
                  color: Colors.red,
                  iconSize: 20,
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (isTablet)
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: _buildSubjectNameField(subject, index),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildCreditHoursDropdown(subject, index),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildGradeDropdown(subject, index),
                ),
              ],
            )
          else
            Column(
              children: [
                _buildSubjectNameField(subject, index),
                const SizedBox(height: 16),
                _buildCreditHoursDropdown(subject, index),
                const SizedBox(height: 16),
                _buildGradeDropdown(subject, index),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildSubjectNameField(Subject subject, int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Subject Name',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Provider.of<ThemeProvider>(context).isDarkMode
                ? Colors.white70
                : Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        TextFormField(
          initialValue: subject.name,
          onChanged: (value) {
            setState(() {
              subjects[index].name = value;
            });
          },
          style: TextStyle(
            color: Provider.of<ThemeProvider>(context).isDarkMode
                ? Colors.white
                : Colors.black,
          ),
          decoration: InputDecoration(
            hintText: 'e.g., Mathematics',
            hintStyle: TextStyle(
              color: Provider.of<ThemeProvider>(context).isDarkMode
                  ? Colors.white54
                  : Colors.grey[400],
            ),
            filled: true,
            fillColor: Provider.of<ThemeProvider>(context).isDarkMode
                ? const Color(0xFF2d3748)
                : Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCreditHoursDropdown(Subject subject, int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Credit Hours',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Provider.of<ThemeProvider>(context).isDarkMode
                ? Colors.white70
                : Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            color: Provider.of<ThemeProvider>(context).isDarkMode
                ? const Color(0xFF2d3748)
                : Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonFormField<int>(
            value: subject.creditHours,
            onChanged: (value) {
              setState(() {
                subjects[index].creditHours = value!;
              });
            },
            style: TextStyle(
              color: Provider.of<ThemeProvider>(context).isDarkMode
                  ? Colors.white
                  : Colors.black,
            ),
            decoration: const InputDecoration(
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
            ),
            dropdownColor: Provider.of<ThemeProvider>(context).isDarkMode
                ? const Color(0xFF2d3748)
                : Colors.white,
            items: List.generate(6, (index) => index + 1).map((value) {
              return DropdownMenuItem<int>(
                value: value,
                child: Text(
                  value.toString(),
                  style: TextStyle(
                    color: Provider.of<ThemeProvider>(context).isDarkMode
                        ? Colors.white
                        : Colors.black,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildGradeDropdown(Subject subject, int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Grade',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Provider.of<ThemeProvider>(context).isDarkMode
                ? Colors.white70
                : Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            color: Provider.of<ThemeProvider>(context).isDarkMode
                ? const Color(0xFF2d3748)
                : Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonFormField<String>(
            value: subject.grade.isEmpty ? null : subject.grade,
            onChanged: (value) {
              setState(() {
                subjects[index].grade = value!;
              });
            },
            style: TextStyle(
              color: Provider.of<ThemeProvider>(context).isDarkMode
                  ? Colors.white
                  : Colors.black,
            ),
            decoration: const InputDecoration(
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
            ),
            dropdownColor: Provider.of<ThemeProvider>(context).isDarkMode
                ? const Color(0xFF2d3748)
                : Colors.white,
            hint: Text(
              'Select Grade',
              style: TextStyle(
                color: Provider.of<ThemeProvider>(context).isDarkMode
                    ? Colors.white54
                    : Colors.grey[400],
              ),
            ),
            items: grades.map((grade) {
              return DropdownMenuItem<String>(
                value: grade,
                child: Text(
                  grade,
                  style: TextStyle(
                    color: Provider.of<ThemeProvider>(context).isDarkMode
                        ? Colors.white
                        : Colors.black,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
