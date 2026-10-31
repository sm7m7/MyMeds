import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:my_meds/core/constants/constants.dart';
import 'package:my_meds/features/cabinet/domain/models/medication.dart';
import 'package:my_meds/features/emergency/domain/models/emergency_card_data.dart';

/// Pure service to generate and export/share an official Emergency Medical Card as PDF.
class EmergencyCardPdfService {
  const EmergencyCardPdfService();

  Future<Uint8List> generatePdf({
    required EmergencyCardData card,
    required List<Medication> currentMedications,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header Banner
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: pw.BoxDecoration(
                  color: PdfColors.red800,
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'EMERGENCY MEDICAL CARD',
                      style: pw.TextStyle(
                        color: PdfColors.white,
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text(
                      'MyMeds',
                      style: pw.TextStyle(
                        color: PdfColors.white,
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 18),

              // Patient Information Section
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey400),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                          'Full Name: ${card.fullName.isNotEmpty ? card.fullName : "Not Specified"}',
                          style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
                        ),
                        if (card.bloodType != null && card.bloodType!.isNotEmpty)
                          pw.Container(
                            padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: pw.BoxDecoration(
                              color: PdfColors.red100,
                              borderRadius: pw.BorderRadius.circular(4),
                              border: pw.Border.all(color: PdfColors.red700),
                            ),
                            child: pw.Text(
                              'Blood Type: ${card.bloodType}',
                              style: pw.TextStyle(
                                color: PdfColors.red800,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    pw.SizedBox(height: 8),

                    // Allergies
                    pw.Text(
                      'Known Allergies: ${card.allergies.isNotEmpty ? card.allergies.join(", ") : "None reported"}',
                      style: pw.TextStyle(
                        fontSize: 12,
                        color: card.allergies.isNotEmpty ? PdfColors.red900 : PdfColors.black,
                        fontWeight: card.allergies.isNotEmpty ? pw.FontWeight.bold : pw.FontWeight.normal,
                      ),
                    ),
                    pw.SizedBox(height: 6),

                    // Chronic notes
                    if (card.chronicConditions.isNotEmpty)
                      pw.Text(
                        'Chronic Conditions & Notes: ${card.chronicConditions}',
                        style: const pw.TextStyle(fontSize: 11),
                      ),
                  ],
                ),
              ),
              pw.SizedBox(height: 16),

              // Emergency Contacts
              pw.Text(
                'EMERGENCY CONTACTS',
                style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.grey800),
              ),
              pw.SizedBox(height: 6),
              if (card.emergencyContacts.isEmpty)
                pw.Text('No emergency contacts listed.', style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey600))
              else
                pw.Column(
                  children: card.emergencyContacts.map((contact) {
                    return pw.Container(
                      margin: const pw.EdgeInsets.only(bottom: 6),
                      padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.grey100,
                        borderRadius: pw.BorderRadius.circular(6),
                      ),
                      child: pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text('${contact.name} (${contact.relationship})', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11)),
                          pw.Text('Tel: ${contact.phone}', style: const pw.TextStyle(fontSize: 11, color: PdfColors.blue800)),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              pw.SizedBox(height: 16),

              // Current Medications (automatically from cabinet)
              pw.Text(
                'CURRENT MEDICATIONS (FROM CABINET)',
                style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.grey800),
              ),
              pw.SizedBox(height: 6),
              if (currentMedications.isEmpty)
                pw.Text('No medications currently listed in cabinet.', style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey600))
              else
                pw.TableHelper.fromTextArray(
                  border: pw.TableBorder.all(color: PdfColors.grey300),
                  headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
                  cellStyle: const pw.TextStyle(fontSize: 9),
                  headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
                  headers: ['Medication Name', 'Dosage', 'Form', 'Storage / Notes'],
                  data: currentMedications.map((m) {
                    return [
                      m.name,
                      m.dosage,
                      m.form.displayName,
                      m.storageConditions ?? m.notes ?? '-',
                    ];
                  }).toList(),
                ),
              pw.Spacer(),

              // Medical Disclaimer Footer
              pw.Divider(color: PdfColors.grey400),
              pw.Text(
                AppConstants.medicalDisclaimer,
                style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
                textAlign: pw.TextAlign.center,
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  /// Opens the native share dialog or PDF preview.
  Future<void> shareOrPrintPdf({
    required EmergencyCardData card,
    required List<Medication> currentMedications,
  }) async {
    final bytes = await generatePdf(
      card: card,
      currentMedications: currentMedications,
    );

    await Printing.sharePdf(
      bytes: bytes,
      filename: 'MyMeds_Emergency_Card_${card.fullName.replaceAll(' ', '_')}.pdf',
    );
  }
}
