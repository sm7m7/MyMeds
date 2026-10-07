import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_meds/features/cabinet/domain/models/medication.dart';
import 'package:my_meds/features/cabinet/domain/models/medication_form.dart';
import 'package:my_meds/features/cabinet/presentation/widgets/medication_status_badge.dart';

/// Interactive card tile representing a medication in the user's cabinet list.
class CabinetMedicationTile extends StatelessWidget {
  const CabinetMedicationTile({
    required this.medication,
    required this.onTap,
    super.key,
  });

  final Medication medication;
  final VoidCallback onTap;

  IconData _getFormIcon(MedicationForm form) {
    switch (form) {
      case MedicationForm.tablet:
      case MedicationForm.capsule:
        return Icons.medication_rounded;
      case MedicationForm.syrup:
      case MedicationForm.drops:
        return Icons.water_drop_outlined;
      case MedicationForm.injection:
        return Icons.vaccines_outlined;
      case MedicationForm.other:
        return Icons.healing_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryStatus = medication.getPrimaryStatus();
    final allStatuses = medication.getAllStatuses();
    final dateFormat = DateFormat.yMMMd();
    final daysRemaining = medication.daysUntilExpiration();

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Form icon container
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: primaryStatus.backgroundColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: primaryStatus.color.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Icon(
                      _getFormIcon(medication.form),
                      color: primaryStatus.color,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Medication Name & Dosage
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          medication.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${medication.dosage} • ${medication.form.displayName}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Primary Status Badge
                  MedicationStatusBadge(status: primaryStatus, compact: true),
                ],
              ),
              const Divider(height: 20),

              // Bottom row: Quantity and Expiration date
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Quantity
                  Row(
                    children: [
                      Icon(
                        Icons.inventory_2_outlined,
                        size: 16,
                        color: medication.isLowStock
                            ? theme.colorScheme.error
                            : theme.colorScheme.outline,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${medication.quantity} left',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: medication.isLowStock
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: medication.isLowStock
                              ? theme.colorScheme.error
                              : theme.colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),

                  // Expiration
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 16,
                        color: medication.isExpired()
                            ? theme.colorScheme.error
                            : (medication.isExpiringSoon()
                                ? Colors.orange[800]
                                : theme.colorScheme.outline),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        medication.isExpired()
                            ? 'Expired ${dateFormat.format(medication.expirationDate)}'
                            : (medication.isExpiringSoon()
                                ? 'Exp: ${dateFormat.format(medication.expirationDate)} (${daysRemaining}d)'
                                : 'Exp: ${dateFormat.format(medication.expirationDate)}'),
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: (medication.isExpired() ||
                                  medication.isExpiringSoon())
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: medication.isExpired()
                              ? theme.colorScheme.error
                              : (medication.isExpiringSoon()
                                  ? Colors.orange[800]
                                  : theme.colorScheme.outline),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              if (allStatuses.length > 1) ...[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  children: allStatuses.map((st) {
                    return MedicationStatusBadge(status: st, compact: true);
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
