import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/health_measurement.dart';

class HealthReportPdfService {
  static Future<Uint8List> generateReport({
    required List<HealthMeasurement> measurements,
  }) async {
    final pdf = pw.Document();

    final latest =
    measurements.isNotEmpty ? measurements.first : null;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),

        build: (context) {
          return [
            _buildHeader(),

            pw.SizedBox(height: 24),

            if (latest != null)
              _buildLatestMeasurement(latest),

            pw.SizedBox(height: 24),

            _buildMeasurementHistory(measurements),
          ];
        },
      ),
    );

    return pdf.save();
  }

  // ============================================================
  // HEADER
  // ============================================================

  static pw.Widget _buildHeader() {
    return pw.Column(
      crossAxisAlignment:
      pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'SMART HEALTH TRACKER',
          style: pw.TextStyle(
            fontSize: 20,
            fontWeight: pw.FontWeight.bold,
          ),
        ),

        pw.SizedBox(height: 6),

        pw.Text(
          'Health Report',
          style: const pw.TextStyle(
            fontSize: 14,
          ),
        ),

        pw.SizedBox(height: 8),

        pw.Divider(),
      ],
    );
  }

  // ============================================================
  // LATEST MEASUREMENT
  // ============================================================

  static pw.Widget _buildLatestMeasurement(
      HealthMeasurement measurement,
      ) {
    return pw.Column(
      crossAxisAlignment:
      pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Latest Measurement',
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
          ),
        ),

        pw.SizedBox(height: 12),

        pw.Table(
          border: pw.TableBorder.all(
            color: PdfColors.grey300,
          ),
          children: [
            _buildTableRow(
              'Blood Pressure',
              '${measurement.systolic.toStringAsFixed(0)} / '
                  '${measurement.diastolic.toStringAsFixed(0)} mmHg',
            ),

            _buildTableRow(
              'Heart Rate',
              '${measurement.heartRate.toStringAsFixed(0)} bpm',
            ),

            _buildTableRow(
              'Blood Glucose',
              '${measurement.bloodGlucose.toStringAsFixed(1)} mmol/L',
            ),

            _buildTableRow(
              'Measured At',
              _formatDateTime(
                measurement.measuredAt,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ============================================================
  // HISTORY
  // ============================================================

  static pw.Widget _buildMeasurementHistory(
      List<HealthMeasurement> measurements,
      ) {
    return pw.Column(
      crossAxisAlignment:
      pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Measurement History',
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
          ),
        ),

        pw.SizedBox(height: 12),

        pw.Table(
          border: pw.TableBorder.all(
            color: PdfColors.grey300,
          ),

          children: [
            pw.TableRow(
              children: [
                _buildHeaderCell('Date'),
                _buildHeaderCell('Blood Pressure'),
                _buildHeaderCell('Heart Rate'),
                _buildHeaderCell('Glucose'),
              ],
            ),

            ...measurements.map(
                  (measurement) {
                return pw.TableRow(
                  children: [
                    _buildCell(
                      _formatDateTime(
                        measurement.measuredAt,
                      ),
                    ),

                    _buildCell(
                      '${measurement.systolic.toStringAsFixed(0)} / '
                          '${measurement.diastolic.toStringAsFixed(0)}',
                    ),

                    _buildCell(
                      '${measurement.heartRate.toStringAsFixed(0)} bpm',
                    ),

                    _buildCell(
                      '${measurement.bloodGlucose.toStringAsFixed(1)}',
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  // ============================================================
  // TABLE HELPERS
  // ============================================================

  static pw.TableRow _buildTableRow(
      String label,
      String value,
      ) {
    return pw.TableRow(
      children: [
        _buildHeaderCell(label),
        _buildCell(value),
      ],
    );
  }

  static pw.Widget _buildHeaderCell(
      String text,
      ) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontWeight: pw.FontWeight.bold,
          fontSize: 9,
        ),
      ),
    );
  }

  static pw.Widget _buildCell(
      String text,
      ) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: const pw.TextStyle(
          fontSize: 9,
        ),
      ),
    );
  }

  // ============================================================
  // DATE FORMAT
  // ============================================================

  static String _formatDateTime(
      DateTime dateTime,
      ) {
    final day =
    dateTime.day.toString().padLeft(2, '0');

    final month =
    dateTime.month.toString().padLeft(2, '0');

    final year =
    dateTime.year.toString();

    final hour =
    dateTime.hour.toString().padLeft(2, '0');

    final minute =
    dateTime.minute.toString().padLeft(2, '0');

    return '$day/$month/$year $hour:$minute';
  }
}