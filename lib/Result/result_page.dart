import 'package:flutter/material.dart';
import 'package:gpa_calculator/GPA_history/gpa_save.dart';
import 'package:gpa_calculator/Home/homepage.dart';
import 'package:gpa_calculator/SelectInput/select_input_page.dart';
import 'dart:math' as math;

import 'package:gpa_calculator/classes/subject.dart';
import 'package:gpa_calculator/functions/saveGPA.dart';
import 'package:gpa_calculator/provider/theme_provider.dart';
import 'package:provider/provider.dart';

class GPAResultPage extends StatefulWidget {
  final String semesterName;
  final List<Subject> subjects;
  final double gpa;
  final int totalCredits;
  final double totalPoints;

  const GPAResultPage({
    super.key,
    required this.semesterName,
    required this.subjects,
    required this.gpa,
    required this.totalCredits,
    required this.totalPoints,
  });

  @override
  State<GPAResultPage> createState() => _GPAResultPageState();
}

class _GPAResultPageState extends State<GPAResultPage>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _circularController;
  late AnimationController _confettiController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _circularAnimation;
  late Animation<double> _confettiAnimation;

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
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _circularController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _confettiController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _circularAnimation = Tween<double>(
      begin: 0.0,
      end: widget.gpa / 4.0,
    ).animate(CurvedAnimation(
      parent: _circularController,
      curve: Curves.easeOutCubic,
    ));

    _confettiAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _confettiController,
      curve: Curves.easeInOut,
    ));

    _fadeController.forward();
    _circularController.forward();
    if (widget.gpa >= 3.5) {
      _confettiController.forward();
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _circularController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  Color getGPAColor() {
    if (widget.gpa >= 3.5) return Colors.green;
    if (widget.gpa >= 2.5) return Colors.orange;
    return Colors.red;
  }

  String getPerformanceText() {
    if (widget.gpa >= 3.5) return 'Excellent Performance!';
    if (widget.gpa >= 3.0) return 'Good Performance!';
    if (widget.gpa >= 2.5) return 'Average Performance';
    return 'Needs Improvement';
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
              automaticallyImplyLeading: false,
              // leading: Container(),
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
                              _buildNavItem('Input', false),
                              _buildNavItem('Result', true),
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
                        maxWidth: isTablet ? 900 : screenWidth,
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
                            'GPA Calculation Result',
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
                            widget.semesterName,
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

                          // GPA Circle
                          Center(
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                SizedBox(
                                  width: isTablet ? 200 : 150,
                                  height: isTablet ? 200 : 150,
                                  child: AnimatedBuilder(
                                    animation: _circularAnimation,
                                    builder: (context, child) {
                                      return CustomPaint(
                                        painter: GPACirclePainter(
                                          progress: _circularAnimation.value,
                                          color: getGPAColor(),
                                          backgroundColor:
                                              Provider.of<ThemeProvider>(
                                                          context)
                                                      .isDarkMode
                                                  ? const Color(0xFF4a5568)
                                                  : Colors.grey[200]!,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    AnimatedBuilder(
                                      animation: _circularAnimation,
                                      builder: (context, child) {
                                        return Text(
                                          (_circularAnimation.value * 4.0)
                                              .toStringAsFixed(2),
                                          style: TextStyle(
                                            fontSize: isTablet ? 36 : 28,
                                            fontWeight: FontWeight.bold,
                                            color: getGPAColor(),
                                          ),
                                        );
                                      },
                                    ),
                                    Text(
                                      '/ 4.00',
                                      style: TextStyle(
                                        fontSize: isTablet ? 14 : 12,
                                        color:
                                            Provider.of<ThemeProvider>(context)
                                                    .isDarkMode
                                                ? Colors.white70
                                                : Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Performance Text
                          Text(
                            getPerformanceText(),
                            style: TextStyle(
                              fontSize: isTablet ? 18 : 16,
                              fontWeight: FontWeight.w600,
                              color: getGPAColor(),
                            ),
                            textAlign: TextAlign.center,
                          ),

                          const SizedBox(height: 40),

                          // Subject Details Table
                          Container(
                            decoration: BoxDecoration(
                              color:
                                  Provider.of<ThemeProvider>(context).isDarkMode
                                      ? const Color(0xFF4a5568)
                                      : Colors.grey[50],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                // Table Header
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Provider.of<ThemeProvider>(context)
                                            .isDarkMode
                                        ? const Color(0xFF2d3748)
                                        : Colors.grey[100],
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(12),
                                      topRight: Radius.circular(12),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          'Subject',
                                          style: TextStyle(
                                            fontSize: isTablet ? 14 : 12,
                                            fontWeight: FontWeight.w600,
                                            color: Provider.of<ThemeProvider>(
                                                        context)
                                                    .isDarkMode
                                                ? Colors.white70
                                                : Colors.grey[600],
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          'Credit Hours',
                                          style: TextStyle(
                                            fontSize: isTablet ? 14 : 12,
                                            fontWeight: FontWeight.w600,
                                            color: Provider.of<ThemeProvider>(
                                                        context)
                                                    .isDarkMode
                                                ? Colors.white70
                                                : Colors.grey[600],
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          'Grade',
                                          style: TextStyle(
                                            fontSize: isTablet ? 14 : 12,
                                            fontWeight: FontWeight.w600,
                                            color: Provider.of<ThemeProvider>(
                                                        context)
                                                    .isDarkMode
                                                ? Colors.white70
                                                : Colors.grey[600],
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          'Grade Points',
                                          style: TextStyle(
                                            fontSize: isTablet ? 14 : 12,
                                            fontWeight: FontWeight.w600,
                                            color: Provider.of<ThemeProvider>(
                                                        context)
                                                    .isDarkMode
                                                ? Colors.white70
                                                : Colors.grey[600],
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Table Rows
                                ...widget.subjects.map((subject) {
                                  final gradePoint =
                                      gradeValues[subject.grade]!;
                                  return Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          color: Provider.of<ThemeProvider>(
                                                      context)
                                                  .isDarkMode
                                              ? const Color(0xFF2d3748)
                                              : Colors.grey[200]!,
                                          width: 1,
                                        ),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          flex: 2,
                                          child: Text(
                                            subject.name,
                                            style: TextStyle(
                                              fontSize: isTablet ? 14 : 12,
                                              color: Provider.of<ThemeProvider>(
                                                          context)
                                                      .isDarkMode
                                                  ? Colors.white
                                                  : Colors.black,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            subject.creditHours.toString(),
                                            style: TextStyle(
                                              fontSize: isTablet ? 14 : 12,
                                              color: Provider.of<ThemeProvider>(
                                                          context)
                                                      .isDarkMode
                                                  ? Colors.white
                                                  : Colors.black,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            subject.grade,
                                            style: TextStyle(
                                              fontSize: isTablet ? 14 : 12,
                                              fontWeight: FontWeight.w600,
                                              color: getGPAColor(),
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            gradePoint.toStringAsFixed(1),
                                            style: TextStyle(
                                              fontSize: isTablet ? 14 : 12,
                                              color: Provider.of<ThemeProvider>(
                                                          context)
                                                      .isDarkMode
                                                  ? Colors.white
                                                  : Colors.black,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ],
                            ),
                          ),

                          const SizedBox(height: 32),

                          // Calculation Summary
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color:
                                  Provider.of<ThemeProvider>(context).isDarkMode
                                      ? const Color(0xFF4a5568)
                                      : Colors.grey[50],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Calculation Summary',
                                  style: TextStyle(
                                    fontSize: isTablet ? 18 : 16,
                                    fontWeight: FontWeight.bold,
                                    color: Provider.of<ThemeProvider>(context)
                                            .isDarkMode
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                SizedBox(
                                  height: 120,
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          Expanded(
                                            child: _buildSummaryItem(
                                              widget.totalCredits.toString(),
                                              'Total Credit Hours',
                                              const Color(0xFF4299e1),
                                              isTablet,
                                            ),
                                          ),
                                          Expanded(
                                            child: _buildSummaryItem(
                                              widget.totalPoints
                                                  .toStringAsFixed(1),
                                              'Total Grade Points',
                                              const Color(0xFF4299e1),
                                              isTablet,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 20),
                                      Expanded(
                                        child: _buildSummaryItem(
                                          'GPA Formula',
                                          '${widget.totalPoints.toStringAsFixed(1)} ÷ ${widget.totalCredits} = ${widget.gpa.toStringAsFixed(2)}',
                                          const Color(0xFF4299e1),
                                          isTablet,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 32),

                          // Action Buttons
                          if (isTablet)
                            Row(
                              children: [
                                Expanded(
                                  child: _buildActionButton(
                                    'Save this Semester',
                                    Icons.save,
                                    Colors.green,
                                    () {
                                      _saveSemesterAndNavigate();
                                    },
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildActionButton(
                                    'Edit Inputs',
                                    Icons.edit,
                                    const Color(0xFF4299e1),
                                    () {
                                      Navigator.pop(context);
                                    },
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildActionButton(
                                    'Start New Semester',
                                    Icons.refresh,
                                    Colors.orange,
                                    () {
                                      Navigator.pop(context);
                                    },
                                  ),
                                ),
                              ],
                            )
                          else
                            Column(
                              children: [
                                _buildActionButton(
                                  'Save this Semester',
                                  Icons.save,
                                  Colors.green,
                                  () {
                                    // ScaffoldMessenger.of(context).showSnackBar(
                                    //   const SnackBar(
                                    //     content:
                                    //         Text('Semester saved to history!'),
                                    //     backgroundColor: Colors.green,
                                    //   ),
                                    // );
                                    _saveSemesterAndNavigate();
                                  },
                                ),
                                const SizedBox(height: 12),
                                _buildActionButton(
                                  'Edit Inputs',
                                  Icons.edit,
                                  const Color(0xFF4299e1),
                                  () {
                                    Navigator.pop(context);
                                  },
                                ),
                                const SizedBox(height: 12),
                                _buildActionButton(
                                  'Start New Semester',
                                  Icons.refresh,
                                  Colors.orange,
                                  () {
                                    Navigator.of(context).pushReplacement(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const SubjectInputPage(),
                                      ),
                                    );
                                  },
                                ),
                              ],
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

  Widget _buildSummaryItem(
      String value, String label, Color color, bool isTablet) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: isTablet ? 24 : 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: isTablet ? 12 : 10,
            color: Provider.of<ThemeProvider>(context).isDarkMode
                ? Colors.white70
                : Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildActionButton(
      String text, IconData icon, Color color, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(text),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
        ),
      ),
    );
  }

  void _saveSemesterAndNavigate() async {
    // Your existing save logic here
    await saveGPARecord(
      semesterName: widget.semesterName,
      gpa: widget.gpa,
      totalCredits: widget.totalCredits,
      totalPoints: widget.totalPoints,
      subjects: widget.subjects,
    );

    // Navigate to history page
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const GPAHistoryPage()),
        (route) => false);
  }
}

class GPACirclePainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color backgroundColor;

  GPACirclePainter({
    required this.progress,
    required this.color,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const double strokeWidth = 12.0;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Background circle
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Progress circle
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    const double startAngle = -math.pi / 2;
    final double sweepAngle = 2 * math.pi * progress;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
