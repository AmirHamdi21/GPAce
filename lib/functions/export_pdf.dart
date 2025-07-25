
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:pdf/pdf.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:printing/printing.dart';

// // Add this function to your _GPAHistoryPageState class:
// Future<void> _exportHistoryAsPDF(BuildContext context) async {
//   try {
//     // Create a PDF document
//     final pdf = pw.Document();

//     // Add pages to the PDF
//     pdf.addPage(
//       pw.MultiPage(
//         pageFormat: PdfPageFormat.a4,
//         margin: const pw.EdgeInsets.all(32),
//         build: (pw.Context context) {
//           return [
//             // Header
//             pw.Header(
//               level: 0,
//               child: pw.Row(
//                 mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//                 children: [
//                   pw.Column(
//                     crossAxisAlignment: pw.CrossAxisAlignment.start,
//                     children: [
//                       pw.Text(
//                         'GPA History Report',
//                         style: pw.TextStyle(
//                           fontSize: 24,
//                           fontWeight: pw.FontWeight.bold,
//                         ),
//                       ),
//                       pw.SizedBox(height: 8),
//                       pw.Text(
//                         'Generated on ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}',
//                         style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
//                       ),
//                     ],
//                   ),
//                   pw.Container(
//                     width: 60,
//                     height: 60,
//                     decoration: pw.BoxDecoration(
//                       color: PdfColors.blue,
//                       borderRadius: pw.BorderRadius.circular(8),
//                     ),
//                     child: pw.Center(
//                       child: pw.Text(
//                         'GPA',
//                         style: pw.TextStyle(
//                           color: PdfColors.white,
//                           fontSize: 16,
//                           fontWeight: pw.FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
            
//             pw.SizedBox(height: 20),
            
//             // Statistics Summary
//             pw.Container(
//               padding: const pw.EdgeInsets.all(16),
//               decoration: pw.BoxDecoration(
//                 color: PdfColors.grey100,
//                 borderRadius: pw.BorderRadius.circular(8),
//               ),
//               child: pw.Column(
//                 crossAxisAlignment: pw.CrossAxisAlignment.start,
//                 children: [
//                   pw.Text(
//                     'Academic Summary',
//                     style: pw.TextStyle(
//                       fontSize: 16,
//                       fontWeight: pw.FontWeight.bold,
//                     ),
//                   ),
//                   pw.SizedBox(height: 12),
//                   pw.Row(
//                     mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
//                     children: [
//                       _buildPDFStatItem('Total Semesters', _gpaRecords.length.toString()),
//                       _buildPDFStatItem('Average GPA', _averageGPA.toStringAsFixed(2)),
//                       _buildPDFStatItem('Highest GPA', _highestGPA.toStringAsFixed(2)),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
            
//             pw.SizedBox(height: 30),
            
//             // Semester Records Table
//             pw.Text(
//               'Semester Records',
//               style: pw.TextStyle(
//                 fontSize: 18,
//                 fontWeight: pw.FontWeight.bold,
//               ),
//             ),
            
//             pw.SizedBox(height: 16),
            
//             // Table Header
//             pw.Table(
//               border: pw.TableBorder.all(color: PdfColors.grey300),
//               columnWidths: {
//                 0: const pw.FlexColumnWidth(2),
//                 1: const pw.FlexColumnWidth(1),
//                 2: const pw.FlexColumnWidth(1),
//                 3: const pw.FlexColumnWidth(1),
//                 4: const pw.FlexColumnWidth(1.5),
//               },
//               children: [
//                 // Header row
//                 pw.TableRow(
//                   decoration: const pw.BoxDecoration(color: PdfColors.grey200),
//                   children: [
//                     _buildTableCell('Semester', isHeader: true),
//                     _buildTableCell('GPA', isHeader: true),
//                     _buildTableCell('Credits', isHeader: true),
//                     _buildTableCell('Subjects', isHeader: true),
//                     _buildTableCell('Date', isHeader: true),
//                   ],
//                 ),
//                 // Data rows
//                 ..._gpaRecords.map((record) => pw.TableRow(
//                   children: [
//                     _buildTableCell(record.semesterName),
//                     _buildTableCell(record.gpa.toStringAsFixed(2)),
//                     _buildTableCell(record.totalCredits.toString()),
//                     _buildTableCell(record.subjects.length.toString()),
//                     _buildTableCell(DateFormat('dd/MM/yyyy').format(record.date)),
//                   ],
//                 )),
//               ],
//             ),
            
//             pw.SizedBox(height: 30),
            
//             // Detailed Subject Information
//             pw.Text(
//               'Detailed Subject Information',
//               style: pw.TextStyle(
//                 fontSize: 18,
//                 fontWeight: pw.FontWeight.bold,
//               ),
//             ),
            
//             pw.SizedBox(height: 16),
            
//             // Subject details for each semester
//             ..._gpaRecords.map((record) => pw.Container(
//               margin: const pw.EdgeInsets.only(bottom: 20),
//               child: pw.Column(
//                 crossAxisAlignment: pw.CrossAxisAlignment.start,
//                 children: [
//                   pw.Text(
//                     '${record.semesterName} - GPA: ${record.gpa.toStringAsFixed(2)}',
//                     style: pw.TextStyle(
//                       fontSize: 14,
//                       fontWeight: pw.FontWeight.bold,
//                     ),
//                   ),
//                   pw.SizedBox(height: 8),
//                   pw.Table(
//                     border: pw.TableBorder.all(color: PdfColors.grey300),
//                     columnWidths: {
//                       0: const pw.FlexColumnWidth(3),
//                       1: const pw.FlexColumnWidth(1),
//                       2: const pw.FlexColumnWidth(1),
//                       3: const pw.FlexColumnWidth(1),
//                     },
//                     children: [
//                       // Subject header
//                       pw.TableRow(
//                         decoration: const pw.BoxDecoration(color: PdfColors.grey100),
//                         children: [
//                           _buildTableCell('Subject Name', isHeader: true),
//                           _buildTableCell('Credits', isHeader: true),
//                           _buildTableCell('Grade', isHeader: true),
//                           _buildTableCell('Points', isHeader: true),
//                         ],
//                       ),
//                       // Subject data
//                       ...record.subjects.map((subject) => pw.TableRow(
//                         children: [
//                           _buildTableCell(subject.name),
//                           _buildTableCell(subject.creditHours.toString()),
//                           _buildTableCell(subject.grade),
//                           _buildTableCell(_getGradePoints(subject.grade).toStringAsFixed(1)),
//                         ],
//                       )),
//                     ],
//                   ),
//                 ],
//               ),
//             )),
//           ];
//         },
//       ),
//     );

//     // Save and share the PDF
//     await Printing.sharePdf(
//       bytes: await pdf.save(),
//       filename: 'gpa_history_${DateFormat('yyyy-MM-dd').format(DateTime.now())}.pdf',
//     );

//     if (mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('PDF exported successfully!'),
//           backgroundColor: Colors.green,
//         ),
//       );
//     }
//   } catch (e) {
//     if (mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Failed to export PDF: ${e.toString()}'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }
// }

// // Helper function to build PDF stat items
// pw.Widget _buildPDFStatItem(String label, String value) {
//   return pw.Column(
//     children: [
//       pw.Text(
//         value,
//         style: pw.TextStyle(
//           fontSize: 16,
//           fontWeight: pw.FontWeight.bold,
//         ),
//       ),
//       pw.SizedBox(height: 4),
//       pw.Text(
//         label,
//         style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
//       ),
//     ],
//   );
// }

// // Helper function to build table cells
// pw.Widget _buildTableCell(String text, {bool isHeader = false}) {
//   return pw.Container(
//     padding: const pw.EdgeInsets.all(8),
//     child: pw.Text(
//       text,
//       style: pw.TextStyle(
//         fontSize: isHeader ? 12 : 10,
//         fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
//       ),
//       textAlign: pw.TextAlign.center,
//     ),
//   );
// }

// // Update your export button to call the PDF function
// ElevatedButton.icon(
//   onPressed: () => _exportHistoryAsPDF(context), // Changed this line
//   icon: const Icon(Icons.picture_as_pdf, size: 16),
//   label: const Text('Export PDF'),
//   style: ElevatedButton.styleFrom(
//     backgroundColor: Colors.blue,
//     foregroundColor: Colors.white,
//     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//     minimumSize: const Size(0, 32),
//   ),
// ),