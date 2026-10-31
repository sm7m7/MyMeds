import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:my_meds/core/widgets/medical_disclaimer.dart';
import 'package:my_meds/features/emergency/presentation/providers/emergency_card_providers.dart';
import 'package:my_meds/features/emergency/presentation/screens/emergency_card_form_screen.dart';

/// Clean, high-contrast, emergency-first card view.
///
/// Designed to be immediately readable by first responders and paramedics:
/// - Distinct high-contrast Red emergency banner with patient identity
/// - Blood type & Allergies badges
/// - Large, one-tap "CALL PRIMARY CONTACT" button
/// - Automatic cabinet medications list
/// - Export & Share via PDF (or image print)
class EmergencyCardScreen extends ConsumerWidget {
  const EmergencyCardScreen({super.key});

  Future<void> _callContact(BuildContext context, String phone) async {
    final cleanPhone = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    final uri = Uri(scheme: 'tel', path: cleanPhone);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Cannot call $phone')),
          );
        }
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final data = ref.watch(emergencyCardFullViewProvider);
    final card = data.card;
    final medications = data.medications;
    final primaryContact = card.primaryContact;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency Medical Card'),
        actions: [
          // Export / Share PDF action
          IconButton(
            tooltip: 'Share or Print Card (PDF)',
            icon: const Icon(Icons.share_outlined),
            onPressed: () async {
              final pdfService = ref.read(emergencyCardPdfServiceProvider);
              await pdfService.shareOrPrintPdf(
                card: card,
                currentMedications: medications,
              );
            },
          ),
          // Edit Profile
          IconButton(
            tooltip: 'Edit Emergency Data',
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => EmergencyCardFormScreen(initialData: card),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const MedicalDisclaimer(),
              const SizedBox(height: 16),

              // ── HIGH-CONTRAST EMERGENCY BANNER ─────────────────────────────
              Container(
                decoration: BoxDecoration(
                  color: Colors.red.shade900,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withAlpha(50),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.medical_services_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'EMERGENCY CARD',
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: Colors.white70,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                        if (card.bloodType != null && card.bloodType!.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Blood: ${card.bloodType}',
                              style: TextStyle(
                                color: Colors.red.shade900,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Patient Name
                    Text(
                      card.fullName.isNotEmpty
                          ? card.fullName
                          : 'Name not specified (Tap Edit)',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Allergies Flag
                    if (card.allergies.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.warning_amber_rounded,
                            color: Colors.amberAccent,
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'ALLERGIES: ${card.allergies.join(", ")}',
                              style: const TextStyle(
                                color: Colors.amberAccent,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ] else
                      const Text(
                        'No known drug allergies reported',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ── ONE-TAP CALL PRIMARY CONTACT ────────────────────────────────
              if (primaryContact != null && primaryContact.phone.isNotEmpty)
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.green.shade800,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(Icons.phone_in_talk_rounded, size: 24),
                  label: Text(
                    'CALL ${primaryContact.name.toUpperCase()} (${primaryContact.relationship})',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: () => _callContact(context, primaryContact.phone),
                )
              else
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  icon: const Icon(Icons.person_add_alt_1_outlined),
                  label: const Text('Add Primary Emergency Contact'),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            EmergencyCardFormScreen(initialData: card),
                      ),
                    );
                  },
                ),
              const SizedBox(height: 20),

              // ── CHRONIC CONDITIONS & CRITICAL NOTES ─────────────────────────
              _SectionCard(
                title: 'Chronic Conditions & Medical Notes',
                icon: Icons.notes_rounded,
                child: Text(
                  card.chronicConditions.isNotEmpty
                      ? card.chronicConditions
                      : 'No chronic conditions recorded.',
                  style: theme.textTheme.bodyMedium,
                ),
              ),
              const SizedBox(height: 14),

              // ── ALL EMERGENCY CONTACTS ──────────────────────────────────────
              _SectionCard(
                title: 'All Emergency Contacts',
                icon: Icons.contact_phone_outlined,
                child: card.emergencyContacts.isEmpty
                    ? const Text('No contacts added yet.')
                    : Column(
                        children: card.emergencyContacts.map((c) {
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: CircleAvatar(
                              backgroundColor:
                                  theme.colorScheme.primaryContainer,
                              child: const Icon(Icons.person, size: 20),
                            ),
                            title: Text(
                              '${c.name} (${c.relationship})',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(c.phone),
                            trailing: IconButton(
                              icon: const Icon(Icons.phone, color: Colors.green),
                              onPressed: () => _callContact(context, c.phone),
                            ),
                          );
                        }).toList(),
                      ),
              ),
              const SizedBox(height: 14),

              // ── CURRENT MEDICATIONS (AUTOMATIC FROM CABINET) ────────────────
              _SectionCard(
                title: 'Current Medications (${medications.length})',
                icon: Icons.medication_outlined,
                child: medications.isEmpty
                    ? const Text(
                        'Cabinet is currently empty.',
                        style: TextStyle(color: Colors.grey),
                      )
                    : Column(
                        children: medications.map((m) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primaryContainer
                                        .withAlpha(100),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.medication,
                                    size: 18,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        m.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        '${m.dosage} • ${m.form.displayName}',
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          color: theme.colorScheme.outline,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
              ),
              const SizedBox(height: 24),

              // Export PDF Bottom Action
              OutlinedButton.icon(
                icon: const Icon(Icons.picture_as_pdf_outlined),
                label: const Text('Export Emergency Card as PDF'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () async {
                  final pdfService = ref.read(emergencyCardPdfServiceProvider);
                  await pdfService.shareOrPrintPdf(
                    card: card,
                    currentMedications: medications,
                  );
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}
