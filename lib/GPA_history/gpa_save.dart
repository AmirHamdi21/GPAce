import 'package:flutter/material.dart';
import 'package:gpa_calculator/Home/homepage.dart';
import 'package:gpa_calculator/sql/gpa_record.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:gpa_calculator/provider/theme_provider.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class GPAHistoryPage extends StatefulWidget {
  const GPAHistoryPage({super.key});

  @override
  State<GPAHistoryPage> createState() => _GPAHistoryPageState();
}

class _GPAHistoryPageState extends State<GPAHistoryPage>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  List<GPARecord> _gpaRecords = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
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

    _loadGPAHistory();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _loadGPAHistory() async {
    try {
      final records = await DatabaseHelper.instance.getGPARecords();
      setState(() {
        _gpaRecords = records;
        _isLoading = false;
      });
      _fadeController.forward();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _fadeController.forward();
    }
  }

  // double get _averageGPA {
  //   if (_gpaRecords.isEmpty) return 0.0;
  //   return _gpaRecords.map((r) => r.gpa).reduce((a, b) => a + b) /
  //       _gpaRecords.length;
  // }
  double get _averageGPA {
    if (_gpaRecords.isEmpty) return 0.0;

    // Calculate CGPA: sum of (GPA × credit hours) / total credit hours
    double totalWeightedPoints = 0.0;
    int totalCreditHours = 0;

    for (GPARecord record in _gpaRecords) {
      totalWeightedPoints += record.gpa * record.totalCredits;
      totalCreditHours += record.totalCredits;
    }

    return totalCreditHours > 0 ? totalWeightedPoints / totalCreditHours : 0.0;
  }

  double get _highestGPA {
    if (_gpaRecords.isEmpty) return 0.0;
    return _gpaRecords.map((r) => r.gpa).reduce((a, b) => a > b ? a : b);
  }

  Future<void> _exportHistory(BuildContext context) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/gpa_history.json');

      final data = _gpaRecords
          .map((record) => {
                'semesterName': record.semesterName,
                'gpa': record.gpa,
                'totalCredits': record.totalCredits,
                'totalPoints': record.totalPoints,
                'date': record.date.toIso8601String(),
                'subjects': record.subjects
                    .map((subject) => {
                          'name': subject.name,
                          'creditHours': subject.creditHours,
                          'grade': subject.grade,
                        })
                    .toList(),
              })
          .toList();

      await file.writeAsString(json.encode(data));

      await Share.shareXFiles([XFile(file.path)], text: 'GPA History Export');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('History exported successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to export history'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _clearHistory(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear History'),
        content: const Text(
            'Are you sure you want to clear all GPA history? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await DatabaseHelper.instance.clearGPARecords();
              setState(() {
                _gpaRecords.clear();
              });
              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('History cleared successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: const Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _exportHistoryAsPDF(BuildContext context) async {
    try {
      // Create a PDF document
      final pdf = pw.Document();

      // Add pages to the PDF
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (pw.Context context) {
            return [
              // Header
              pw.Header(
                level: 0,
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'GPA History Report',
                          style: pw.TextStyle(
                            fontSize: 24,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.SizedBox(height: 8),
                        pw.Text(
                          'Generated on ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}',
                          style: const pw.TextStyle(
                              fontSize: 12, color: PdfColors.grey700),
                        ),
                      ],
                    ),
                    pw.Container(
                      width: 60,
                      height: 60,
                      decoration: pw.BoxDecoration(
                        color: PdfColors.blue,
                        borderRadius: pw.BorderRadius.circular(8),
                      ),
                      child: pw.Center(
                        child: pw.Text(
                          'GPA',
                          style: pw.TextStyle(
                            color: PdfColors.white,
                            fontSize: 16,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 20),

              // Statistics Summary
              pw.Container(
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey100,
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Academic Summary',
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 12),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                      children: [
                        _buildPDFStatItem(
                            'Total Semesters', _gpaRecords.length.toString()),
                        _buildPDFStatItem(
                            'Average GPA', _averageGPA.toStringAsFixed(2)),
                        _buildPDFStatItem(
                            'Highest GPA', _highestGPA.toStringAsFixed(2)),
                      ],
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 30),

              // Semester Records Table
              pw.Text(
                'Semester Records',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),

              pw.SizedBox(height: 16),

              // Table Header
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300),
                columnWidths: {
                  0: const pw.FlexColumnWidth(2),
                  1: const pw.FlexColumnWidth(1),
                  2: const pw.FlexColumnWidth(1),
                  3: const pw.FlexColumnWidth(1),
                  4: const pw.FlexColumnWidth(1.5),
                },
                children: [
                  // Header row
                  pw.TableRow(
                    decoration:
                        const pw.BoxDecoration(color: PdfColors.grey200),
                    children: [
                      _buildTableCell('Semester', isHeader: true),
                      _buildTableCell('GPA', isHeader: true),
                      _buildTableCell('Credits', isHeader: true),
                      _buildTableCell('Subjects', isHeader: true),
                      _buildTableCell('Date', isHeader: true),
                    ],
                  ),
                  // Data rows
                  ..._gpaRecords.map((record) => pw.TableRow(
                        children: [
                          _buildTableCell(record.semesterName),
                          _buildTableCell(record.gpa.toStringAsFixed(2)),
                          _buildTableCell(record.totalCredits.toString()),
                          _buildTableCell(record.subjects.length.toString()),
                          _buildTableCell(
                              DateFormat('dd/MM/yyyy').format(record.date)),
                        ],
                      )),
                ],
              ),

              pw.SizedBox(height: 30),

              // Detailed Subject Information
              pw.Text(
                'Detailed Subject Information',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),

              pw.SizedBox(height: 16),

              // Subject details for each semester
              ..._gpaRecords.map((record) => pw.Container(
                    margin: const pw.EdgeInsets.only(bottom: 20),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          '${record.semesterName} - GPA: ${record.gpa.toStringAsFixed(2)}',
                          style: pw.TextStyle(
                            fontSize: 14,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.SizedBox(height: 8),
                        pw.Table(
                          border: pw.TableBorder.all(color: PdfColors.grey300),
                          columnWidths: {
                            0: const pw.FlexColumnWidth(3),
                            1: const pw.FlexColumnWidth(1),
                            2: const pw.FlexColumnWidth(1),
                            3: const pw.FlexColumnWidth(1),
                          },
                          children: [
                            // Subject header
                            pw.TableRow(
                              decoration: const pw.BoxDecoration(
                                  color: PdfColors.grey100),
                              children: [
                                _buildTableCell('Subject Name', isHeader: true),
                                _buildTableCell('Credits', isHeader: true),
                                _buildTableCell('Grade', isHeader: true),
                                _buildTableCell('Points', isHeader: true),
                              ],
                            ),
                            // Subject data
                            ...record.subjects.map((subject) => pw.TableRow(
                                  children: [
                                    _buildTableCell(subject.name),
                                    _buildTableCell(
                                        subject.creditHours.toString()),
                                    _buildTableCell(subject.grade),
                                    _buildTableCell(
                                        _getGradePoints(subject.grade)
                                            .toStringAsFixed(1)),
                                  ],
                                )),
                          ],
                        ),
                      ],
                    ),
                  )),
            ];
          },
        ),
      );

      // Save and share the PDF
      await Printing.sharePdf(
        bytes: await pdf.save(),
        filename:
            'gpa_history_${DateFormat('yyyy-MM-dd').format(DateTime.now())}.pdf',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PDF exported successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to export PDF: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

// Helper function to build PDF stat items
  pw.Widget _buildPDFStatItem(String label, String value) {
    return pw.Column(
      children: [
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          label,
          style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
        ),
      ],
    );
  }

// Helper function to build table cells
  pw.Widget _buildTableCell(String text, {bool isHeader = false}) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: isHeader ? 12 : 10,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    final isTablet = MediaQuery.of(context).size.width > 600;
    final screenWidth = MediaQuery.of(context).size.width;

    return Theme(
      data: isDarkMode ? ThemeData.dark() : ThemeData.light(),
      child: Scaffold(
        backgroundColor: isDarkMode ? const Color(0xFF1a1a1a) : Colors.white,
        body: CustomScrollView(
          slivers: [
            // App Bar
            SliverAppBar(
              automaticallyImplyLeading: false,
              leading: null,
              toolbarHeight: 70.0,
              backgroundColor:
                  isDarkMode ? const Color(0xFF2d3748) : Colors.white,
              elevation: 0,
              pinned: true,
              expandedHeight: 0,
              flexibleSpace: Container(
                decoration: BoxDecoration(
                  color: isDarkMode ? const Color(0xFF2d3748) : Colors.white,
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
                                color: isDarkMode ? Colors.white : Colors.black,
                              ),
                            ),
                          ],
                        ),
                        // Navigation
                        if (isTablet)
                          Row(
                            children: [
                              _buildNavItem('Home', false, context),
                              _buildNavItem('Input', false, context),
                              _buildNavItem('Result', false, context),
                              _buildNavItem('History', true, context),
                              const SizedBox(width: 20),
                              _buildThemeToggle(context),
                            ],
                          )
                        else
                          Row(
                            children: [
                              ElevatedButton(
                                style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                        Color(0xFF4299e1))),
                                onPressed: () {
                                  Navigator.of(context).pushAndRemoveUntil(
                                    MaterialPageRoute(
                                      builder: (context) => const HomePage(),
                                    ),
                                    (route) => false,
                                  );
                                },
                                child: Text(
                                  "Home Page",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 15),
                              _buildThemeToggle(context),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // Main Content
            SliverToBoxAdapter(
              child: _isLoading
                  ? SizedBox(
                      height: MediaQuery.of(context).size.height - 70,
                      child: const Center(
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Color(0xFF4299e1)),
                        ),
                      ),
                    )
                  : FadeTransition(
                      opacity: _fadeAnimation,
                      child: Container(
                        constraints: BoxConstraints(
                          minHeight: MediaQuery.of(context).size.height - 70,
                        ),
                        color: isDarkMode
                            ? const Color(0xFF1a1a1a)
                            : Colors.grey[50],
                        child: Center(
                          child: Container(
                            constraints: BoxConstraints(
                              maxWidth: isTablet ? 1200 : screenWidth,
                            ),
                            margin: EdgeInsets.symmetric(
                              horizontal: isTablet ? 40 : 20,
                              vertical: 10,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Header
                                // Replace the Row at line 284 with this fixed version:
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.26,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Use Expanded to give the left column flexible space
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                            child: Text(
                                              'GPA History',
                                              style: TextStyle(
                                                fontSize: isTablet ? 32 : 24,
                                                fontWeight: FontWeight.bold,
                                                color: isDarkMode
                                                    ? Colors.white
                                                    : Colors.black,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Track your academic progress over time',
                                            style: TextStyle(
                                              fontSize: isTablet ? 16 : 14,
                                              color: isDarkMode
                                                  ? Colors.white70
                                                  : Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                      // Add some spacing
                                      // const SizedBox(width: 16),
                                      // Buttons section - wrap in Flexible to prevent overflow
                                      if (_gpaRecords.isNotEmpty)
                                        Flexible(
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              // Stack buttons vertically on small screens
                                              if (MediaQuery.of(context)
                                                      .size
                                                      .width <
                                                  500)
                                                Column(
                                                  children: [
                                                    SizedBox(
                                                      width: double.infinity,
                                                      child:
                                                          ElevatedButton.icon(
                                                        onPressed: () =>
                                                            _exportHistory(
                                                                context), // JSON export
                                                        icon: const Icon(
                                                            Icons.code,
                                                            size: 16),
                                                        label: const Text(
                                                            'Export JSON'),
                                                        style: ElevatedButton
                                                            .styleFrom(
                                                          backgroundColor:
                                                              Colors.green,
                                                          foregroundColor:
                                                              Colors.white,
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(height: 8),
                                                    SizedBox(
                                                      width: double.infinity,
                                                      child:
                                                          ElevatedButton.icon(
                                                        onPressed: () =>
                                                            _exportHistoryAsPDF(
                                                                context), // Changed this line
                                                        icon: const Icon(
                                                            Icons
                                                                .picture_as_pdf,
                                                            size: 16),
                                                        label: const Text(
                                                            'Export PDF'),
                                                        style: ElevatedButton
                                                            .styleFrom(
                                                          backgroundColor:
                                                              Colors.blue,
                                                          foregroundColor:
                                                              Colors.white,
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal:
                                                                      12,
                                                                  vertical: 8),
                                                          minimumSize:
                                                              const Size(0, 32),
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(height: 8),
                                                    SizedBox(
                                                      width: double.infinity,
                                                      child:
                                                          ElevatedButton.icon(
                                                        onPressed: () =>
                                                            _clearHistory(
                                                                context),
                                                        icon: const Icon(
                                                            Icons.clear_all,
                                                            size: 16),
                                                        label:
                                                            const Text('Clear'),
                                                        style: ElevatedButton
                                                            .styleFrom(
                                                          backgroundColor:
                                                              Colors.red,
                                                          foregroundColor:
                                                              Colors.white,
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal:
                                                                      12,
                                                                  vertical: 8),
                                                          minimumSize:
                                                              const Size(0, 32),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                )
                                              else
                                                // Keep buttons side by side on larger screens
                                                Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    ElevatedButton.icon(
                                                      onPressed: () =>
                                                          _exportHistory(
                                                              context),
                                                      icon: const Icon(
                                                          Icons.download,
                                                          size: 16),
                                                      label:
                                                          const Text('Export'),
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                        backgroundColor:
                                                            Colors.green,
                                                        foregroundColor:
                                                            Colors.white,
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                horizontal: 12,
                                                                vertical: 8),
                                                        minimumSize:
                                                            const Size(0, 32),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    ElevatedButton.icon(
                                                      onPressed: () =>
                                                          _clearHistory(
                                                              context),
                                                      icon: const Icon(
                                                          Icons.clear_all,
                                                          size: 16),
                                                      label:
                                                          const Text('Clear'),
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                        backgroundColor:
                                                            Colors.red,
                                                        foregroundColor:
                                                            Colors.white,
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                horizontal: 12,
                                                                vertical: 8),
                                                        minimumSize:
                                                            const Size(0, 32),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 40),

                                if (_gpaRecords.isEmpty)
                                  _buildEmptyState(isTablet, context)
                                else ...[
                                  // Statistics Cards
                                  _buildStatisticsCards(isTablet, context),
                                  const SizedBox(height: 32),

                                  // Charts
                                  _buildChartsSection(isTablet, context),
                                  const SizedBox(height: 32),

                                  // Semester Records
                                  _buildSemesterRecords(isTablet, context),
                                ],
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

  Widget _buildNavItem(String title, bool isActive, BuildContext context) {
    final isDarkMode =
        Provider.of<ThemeProvider>(context, listen: false).isDarkMode;

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
              : (isDarkMode ? Colors.white70 : Colors.black54),
          fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildThemeToggle(BuildContext context) {
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

  Widget _buildEmptyState(bool isTablet, BuildContext context) {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;

    return Container(
      padding: EdgeInsets.all(isTablet ? 80 : 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.school_outlined,
            size: isTablet ? 120 : 80,
            color: isDarkMode ? Colors.white30 : Colors.grey[300],
          ),
          const SizedBox(height: 24),
          Text(
            'No GPA Records Yet',
            style: TextStyle(
              fontSize: isTablet ? 24 : 18,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white70 : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Start calculating your GPA to see your academic progress here',
            style: TextStyle(
              fontSize: isTablet ? 16 : 14,
              color: isDarkMode ? Colors.white70 : Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsCards(bool isTablet, BuildContext context) {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;

    return GridView.count(
      crossAxisCount: isTablet ? 3 : 1,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: isTablet ? 2.5 : 3.5,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      children: [
        _buildStatCard(
          'Total Semesters',
          _gpaRecords.length.toString(),
          Icons.calendar_today,
          const Color(0xFF4299e1),
          isTablet,
          context,
        ),
        _buildStatCard(
          'Cumulative GPA',
          _averageGPA.toStringAsFixed(2),
          Icons.trending_up,
          Colors.green,
          isTablet,
          context,
        ),
        _buildStatCard(
          'Highest GPA',
          _highestGPA.toStringAsFixed(2),
          Icons.star,
          Colors.amber,
          isTablet,
          context,
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color,
      bool isTablet, BuildContext context) {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;

    return Container(
      padding: EdgeInsets.all(isTablet ? 24 : 20),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF2d3748) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: isTablet ? 24 : 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: isTablet ? 24 : 20,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: isTablet ? 14 : 12,
                    color: isDarkMode ? Colors.white70 : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartsSection(bool isTablet, BuildContext context) {
    return GridView.count(
      crossAxisCount: isTablet ? 2 : 1,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: isTablet ? 1.5 : 1.2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      children: [
        _buildTrendChart(isTablet, context),
        _buildComparisonChart(isTablet, context),
      ],
    );
  }

  Widget _buildTrendChart(bool isTablet, BuildContext context) {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;

    return Container(
      padding: EdgeInsets.all(isTablet ? 24 : 20),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF2d3748) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'GPA Trend Over Time',
            style: TextStyle(
              fontSize: isTablet ? 18 : 16,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 0.5,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: isDarkMode ? Colors.white10 : Colors.grey[200]!,
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 0.5,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) => Text(
                        value.toStringAsFixed(1),
                        style: TextStyle(
                          color: isDarkMode ? Colors.white70 : Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 60,
                      interval:
                          1, // Add this line to show titles only at integer intervals
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < _gpaRecords.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8, left: 36),
                            child: Transform.rotate(
                              angle: -1.5708, // -90 degrees in radians
                              child: Text(
                                _gpaRecords[index].semesterName,
                                style: TextStyle(
                                  color: isDarkMode
                                      ? Colors.white70
                                      : Colors.grey[600],
                                  fontSize: 10,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: _gpaRecords.length.toDouble() - 1,
                minY: 0,
                maxY: 4,
                lineBarsData: [
                  LineChartBarData(
                    spots: _gpaRecords.asMap().entries.map((entry) {
                      return FlSpot(entry.key.toDouble(), entry.value.gpa);
                    }).toList(),
                    isCurved: true,
                    color: const Color(0xFF4299e1),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) =>
                          FlDotCirclePainter(
                        radius: 4,
                        color: const Color(0xFF4299e1),
                        strokeWidth: 2,
                        strokeColor: Colors.white,
                      ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: const Color(0xFF4299e1).withOpacity(0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonChart(bool isTablet, BuildContext context) {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;

    return Container(
      padding: EdgeInsets.all(isTablet ? 24 : 20),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF2d3748) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'GPA Comparison Across Semesters',
            style: TextStyle(
              fontSize: isTablet ? 18 : 16,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 4,
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 0.5,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) => Text(
                        value.toStringAsFixed(1),
                        style: TextStyle(
                          color: isDarkMode ? Colors.white70 : Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 60,
                      interval:
                          1, // Add this line to show titles only at integer intervals
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < _gpaRecords.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8, left: 36),
                            child: Transform.rotate(
                              angle: -1.5708, // -90 degrees in radians
                              child: Text(
                                _gpaRecords[index].semesterName,
                                style: TextStyle(
                                  color: isDarkMode
                                      ? Colors.white70
                                      : Colors.grey[600],
                                  fontSize: 10,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 0.5,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: isDarkMode ? Colors.white10 : Colors.grey[200]!,
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: _gpaRecords.asMap().entries.map((entry) {
                  final gpa = entry.value.gpa;
                  Color barColor = Colors.amber;
                  if (gpa >= 3.5)
                    barColor = Colors.green;
                  else if (gpa >= 3.0)
                    barColor = Colors.amber;
                  else if (gpa >= 2.5)
                    barColor = Colors.orange;
                  else
                    barColor = Colors.red;

                  return BarChartGroupData(
                    x: entry.key,
                    barRods: [
                      BarChartRodData(
                        toY: gpa,
                        color: barColor,
                        width: 16,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(8),
                          topRight: Radius.circular(8),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSemesterRecords(bool isTablet, BuildContext context) {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;

    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF2d3748) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(isTablet ? 24 : 20),
            child: Text(
              'Semester Records',
              style: TextStyle(
                fontSize: isTablet ? 18 : 16,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
          ),
          ...(_gpaRecords.reversed.toList().asMap().entries.map((entry) {
            final index = entry.key;
            final record = entry.value;
            return _buildSemesterRecordItem(record, index, isTablet, context);
          }).toList()),
        ],
      ),
    );
  }

  Widget _buildSemesterRecordItem(
      GPARecord record, int index, bool isTablet, BuildContext context) {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;

    return ExpansionTile(
      tilePadding: EdgeInsets.symmetric(
        horizontal: isTablet ? 24 : 20,
        vertical: 8,
      ),
      childrenPadding: EdgeInsets.symmetric(
        horizontal: isTablet ? 24 : 20,
        vertical: 16,
      ),
      title: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.semesterName,
                  style: TextStyle(
                    fontSize: isTablet ? 16 : 14,
                    fontWeight: FontWeight.w600,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${record.subjects.length} subjects • ${record.totalCredits} credit hours • ${DateFormat('dd/MM/yyyy').format(record.date)}',
                  style: TextStyle(
                    fontSize: isTablet ? 12 : 10,
                    color: isDarkMode ? Colors.white70 : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _getGPAColor(record.gpa).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'GPA: ${record.gpa.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: isTablet ? 12 : 10,
                fontWeight: FontWeight.w600,
                color: _getGPAColor(record.gpa),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.visibility, size: 20),
                color: const Color(0xFF4299e1),
                onPressed: () => _viewSemesterDetails(record, context),
              ),
              IconButton(
                icon: const Icon(Icons.delete, size: 20),
                color: Colors.red,
                onPressed: () => _deleteSemesterRecord(record, context),
              ),
            ],
          ),
        ],
      ),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color:
                isDarkMode ? Colors.white.withOpacity(0.05) : Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Subject Breakdown',
                style: TextStyle(
                  fontSize: isTablet ? 14 : 12,
                  fontWeight: FontWeight.w600,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 12),
              ...record.subjects.map((subject) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Text(
                            subject.name,
                            style: TextStyle(
                              fontSize: isTablet ? 12 : 11,
                              color: isDarkMode
                                  ? Colors.white70
                                  : Colors.grey[700],
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Text(
                            '${subject.creditHours} CR',
                            style: TextStyle(
                              fontSize: isTablet ? 12 : 11,
                              color: isDarkMode
                                  ? Colors.white70
                                  : Colors.grey[700],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color:
                                  _getGPAColor(_getGradePoints(subject.grade))
                                      .withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              subject.grade,
                              style: TextStyle(
                                fontSize: isTablet ? 12 : 11,
                                fontWeight: FontWeight.w600,
                                color: _getGPAColor(
                                    _getGradePoints(subject.grade)),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
          ),
        ),
      ],
    );
  }

  Color _getGPAColor(double gpa) {
    if (gpa >= 3.5) return Colors.green;
    if (gpa >= 3.0) return Colors.amber;
    if (gpa >= 2.5) return Colors.orange;
    return Colors.red;
  }

  void _viewSemesterDetails(GPARecord record, BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(record.semesterName),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('GPA: ${record.gpa.toStringAsFixed(2)}'),
              Text('Total Credits: ${record.totalCredits}'),
              Text('Date: ${DateFormat('dd/MM/yyyy').format(record.date)}'),
              const SizedBox(height: 16),
              const Text('Subjects:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              ...record.subjects.map((subject) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: Text(subject.name)),
                        Text('${subject.creditHours} credits'),
                        Text(subject.grade),
                      ],
                    ),
                  )),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _deleteSemesterRecord(GPARecord record, BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Record'),
        content:
            Text('Are you sure you want to delete ${record.semesterName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (record.id != null) {
                await DatabaseHelper.instance.deleteGPARecord(record.id!);
                setState(() {
                  _gpaRecords.removeWhere((r) => r.id == record.id);
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Record deleted successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  double _getGradePoints(String grade) {
    switch (grade) {
      case 'A+':
      case 'A':
        return 4.0;
      case 'A-':
        return 3.7;
      case 'B+':
        return 3.3;
      case 'B':
        return 3.0;
      case 'B-':
        return 2.7;
      case 'C+':
        return 2.3;
      case 'C':
        return 2.0;
      case 'C-':
        return 1.7;
      case 'D+':
        return 1.3;
      case 'D':
        return 1.0;
      case 'F':
        return 0.0;
      default:
        return 0.0;
    }
  }
}
