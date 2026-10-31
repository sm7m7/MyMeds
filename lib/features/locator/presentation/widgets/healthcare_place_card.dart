import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:my_meds/features/locator/domain/models/healthcare_place.dart';

/// Interactive card presenting a pharmacy or healthcare facility
/// with distance, open-now badge, and quick action buttons (Call & Directions).
class HealthcarePlaceCard extends StatelessWidget {
  const HealthcarePlaceCard({
    required this.place,
    this.onTap,
    this.isSelected = false,
    super.key,
  });

  final HealthcarePlace place;
  final VoidCallback? onTap;
  final bool isSelected;

  Future<void> _makePhoneCall(BuildContext context, String phone) async {
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

  Future<void> _openDirections(BuildContext context, double lat, double lon, String name) async {
    // Geo URI format supported by Google Maps, Apple Maps, and native intent handlers
    final uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lon');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not open map application')),
          );
        }
      }
    } catch (_) {}
  }

  Color _typeColor(ThemeData theme) {
    switch (place.type) {
      case HealthcarePlaceType.pharmacy:
        return Colors.green.shade700;
      case HealthcarePlaceType.hospital:
        return Colors.red.shade700;
      case HealthcarePlaceType.clinic:
        return Colors.blue.shade700;
    }
  }

  IconData _typeIcon() {
    switch (place.type) {
      case HealthcarePlaceType.pharmacy:
        return Icons.local_pharmacy_rounded;
      case HealthcarePlaceType.hospital:
        return Icons.local_hospital_rounded;
      case HealthcarePlaceType.clinic:
        return Icons.medical_services_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _typeColor(theme);

    return Card(
      elevation: isSelected ? 3 : 0,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isSelected ? color : theme.colorScheme.outlineVariant.withAlpha(120),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Type Icon, Name, and Type Badge
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withAlpha(25),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(_typeIcon(), color: color, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          place.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: color.withAlpha(20),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                place.type.displayName,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: color,
                                ),
                              ),
                            ),
                            if (place.distanceInMeters != null) ...[
                              const SizedBox(width: 8),
                              Text(
                                '•  ${place.formattedDistance}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.outline,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Address
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 16,
                    color: theme.colorScheme.outline,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      place.address,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              // Open status & Hours if available
              if (place.isOpenNow != null || place.openingHoursText != null) ...[
                const SizedBox(height: 6),
                Row(
                  children: [
                    if (place.isOpenNow != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: (place.isOpenNow! ? Colors.green : Colors.red)
                              .withAlpha(25),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          place.isOpenNow! ? 'Open Now' : 'Closed',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: place.isOpenNow! ? Colors.green.shade800 : Colors.red.shade800,
                          ),
                        ),
                      ),
                    if (place.openingHoursText != null)
                      Expanded(
                        child: Text(
                          place.openingHoursText!,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
              ],

              const Divider(height: 18),

              // Action Buttons: Call & Directions
              Row(
                children: [
                  if (place.phone != null && place.phone!.isNotEmpty)
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.phone_outlined, size: 16),
                        label: const Text('Call'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          visualDensity: VisualDensity.compact,
                        ),
                        onPressed: () => _makePhoneCall(context, place.phone!),
                      ),
                    )
                  else
                    Expanded(
                      child: Text(
                        'No phone listed',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton.icon(
                      icon: const Icon(Icons.directions_outlined, size: 16),
                      label: const Text('Directions'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        visualDensity: VisualDensity.compact,
                      ),
                      onPressed: () => _openDirections(
                        context,
                        place.latitude,
                        place.longitude,
                        place.name,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
