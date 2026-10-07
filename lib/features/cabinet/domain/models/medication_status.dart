import 'package:flutter/material.dart';

/// Clinical and inventory status for a medication in the user's cabinet.
enum MedicationStatus {
  ok,
  expiringSoon,
  expired,
  lowStock;

  String get displayName {
    switch (this) {
      case MedicationStatus.ok:
        return 'OK';
      case MedicationStatus.expiringSoon:
        return 'Expiring Soon';
      case MedicationStatus.expired:
        return 'Expired';
      case MedicationStatus.lowStock:
        return 'Low Stock';
    }
  }

  Color get color {
    switch (this) {
      case MedicationStatus.ok:
        return const Color(0xFF2E7D32); // Forest Green
      case MedicationStatus.expiringSoon:
        return const Color(0xFFED6C02); // Amber/Orange
      case MedicationStatus.expired:
        return const Color(0xFFD32F2F); // Red
      case MedicationStatus.lowStock:
        return const Color(0xFF0288D1); // Light Blue / Purple
    }
  }

  Color get backgroundColor {
    switch (this) {
      case MedicationStatus.ok:
        return const Color(0xFFE8F5E9);
      case MedicationStatus.expiringSoon:
        return const Color(0xFFFFF3E0);
      case MedicationStatus.expired:
        return const Color(0xFFFFEBEE);
      case MedicationStatus.lowStock:
        return const Color(0xFFE1F5FE);
    }
  }

  IconData get icon {
    switch (this) {
      case MedicationStatus.ok:
        return Icons.check_circle_outline_rounded;
      case MedicationStatus.expiringSoon:
        return Icons.access_time_rounded;
      case MedicationStatus.expired:
        return Icons.cancel_outlined;
      case MedicationStatus.lowStock:
        return Icons.inventory_2_outlined;
    }
  }
}
