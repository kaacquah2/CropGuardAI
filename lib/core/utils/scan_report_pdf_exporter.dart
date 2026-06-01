import 'dart:io';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../domain/models/detection_result.dart';

class ScanReportPdfExporter {
  /// Exports a single scan result as a PDF and shares it.
  static Future<void> shareScanReport(DetectionResult scan) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('CropGuard AI - Scan Report',
                  style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 20),
              pw.Text('Disease: ${scan.displayName}'),
              pw.Text('Crop: ${scan.cropType}'),
              pw.Text('Severity: ${scan.severity}'),
              pw.Text('Confidence: ${(scan.confidence * 100).toInt()}%'),
              pw.Text('Date: ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.fromMillisecondsSinceEpoch(scan.timestamp))}'),
              pw.SizedBox(height: 30),
              pw.Text('Treatment:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              ...scan.treatments.map((t) => pw.Bullet(text: t)),
              pw.SizedBox(height: 20),
              pw.Text('Disclaimer: CropGuard AI provides guidance based on AI analysis. Always consult an expert.'),
            ],
          );
        },
      ),
    );

    final bytes = await pdf.save();
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/scan_report_${scan.id}.pdf');
    await file.writeAsBytes(bytes);

    await Share.shareXFiles([XFile(file.path)], text: 'CropGuard AI Scan Report');
  }

  /// Exports a monthly summary report.
  static Future<void> shareMonthlyReport(List<DetectionResult> detections) async {
    final pdf = pw.Document();

    final healthyCount = detections.where((d) => d.isHealthy).length;
    final diseasedCount = detections.length - healthyCount;

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('CropGuard AI - Monthly Summary',
                  style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 20),
              pw.Text('Total Scans: ${detections.length}'),
              pw.Text('Healthy: $healthyCount'),
              pw.Text('Diseased: $diseasedCount'),
              pw.SizedBox(height: 20),
              pw.Text('Breakdown by Crop:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              // Simple grouping logic for display
              ..._groupByCrop(detections).entries.map((e) => pw.Text('${e.key}: ${e.value} scans')),
            ],
          );
        },
      ),
    );

    final bytes = await pdf.save();
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/monthly_report_${DateTime.now().millisecondsSinceEpoch}.pdf');
    await file.writeAsBytes(bytes);

    await Share.shareXFiles([XFile(file.path)], text: 'CropGuard AI Monthly Report');
  }

  static Map<String, int> _groupByCrop(List<DetectionResult> detections) {
    final map = <String, int>{};
    for (var d in detections) {
      map[d.cropType] = (map[d.cropType] ?? 0) + 1;
    }
    return map;
  }
}
