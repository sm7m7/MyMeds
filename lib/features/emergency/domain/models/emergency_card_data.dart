import 'package:flutter/foundation.dart';

/// An emergency contact person with name, phone number, and relationship.
@immutable
class EmergencyContact {
  const EmergencyContact({
    required this.name,
    required this.phone,
    required this.relationship,
  });

  final String name;
  final String phone;
  final String relationship;

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone': phone,
      'relationship': relationship,
    };
  }

  factory EmergencyContact.fromJson(Map<String, dynamic> json) {
    return EmergencyContact(
      name: json['name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      relationship: json['relationship'] as String? ?? '',
    );
  }

  EmergencyContact copyWith({
    String? name,
    String? phone,
    String? relationship,
  }) {
    return EmergencyContact(
      name: name ?? this.name,
      phone: phone ?? this.phone,
      relationship: relationship ?? this.relationship,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EmergencyContact &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          phone == other.phone &&
          relationship == other.relationship;

  @override
  int get hashCode => name.hashCode ^ phone.hashCode ^ relationship.hashCode;
}

/// The user's emergency card profile stored at users/{uid}/emergencyCard/profile.
@immutable
class EmergencyCardData {
  const EmergencyCardData({
    required this.fullName,
    this.bloodType,
    this.allergies = const [],
    this.chronicConditions = '',
    this.emergencyContacts = const [],
    this.updatedAt,
  });

  final String fullName;
  final String? bloodType;
  final List<String> allergies;
  final String chronicConditions;
  final List<EmergencyContact> emergencyContacts;
  final DateTime? updatedAt;

  /// Primary emergency contact (first in the list).
  EmergencyContact? get primaryContact =>
      emergencyContacts.isNotEmpty ? emergencyContacts.first : null;

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'bloodType': bloodType,
      'allergies': allergies,
      'chronicConditions': chronicConditions,
      'emergencyContacts': emergencyContacts.map((c) => c.toJson()).toList(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory EmergencyCardData.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic val) {
      if (val is DateTime) return val;
      if (val is String) return DateTime.tryParse(val);
      try {
        return (val as dynamic).toDate() as DateTime;
      } catch (_) {
        return null;
      }
    }

    final rawAllergies = json['allergies'];
    List<String> parsedAllergies = [];
    if (rawAllergies is List) {
      parsedAllergies = rawAllergies.map((e) => e.toString()).toList();
    } else if (rawAllergies is String && rawAllergies.trim().isNotEmpty) {
      parsedAllergies = rawAllergies.split(',').map((e) => e.trim()).toList();
    }

    final rawContacts = json['emergencyContacts'] as List<dynamic>? ?? [];
    final parsedContacts = rawContacts
        .map((c) => EmergencyContact.fromJson(c as Map<String, dynamic>))
        .toList();

    return EmergencyCardData(
      fullName: json['fullName'] as String? ?? '',
      bloodType: json['bloodType'] as String?,
      allergies: parsedAllergies,
      chronicConditions: json['chronicConditions'] as String? ?? '',
      emergencyContacts: parsedContacts,
      updatedAt: parseDate(json['updatedAt']),
    );
  }

  EmergencyCardData copyWith({
    String? fullName,
    String? bloodType,
    List<String>? allergies,
    String? chronicConditions,
    List<EmergencyContact>? emergencyContacts,
    DateTime? updatedAt,
  }) {
    return EmergencyCardData(
      fullName: fullName ?? this.fullName,
      bloodType: bloodType ?? this.bloodType,
      allergies: allergies ?? this.allergies,
      chronicConditions: chronicConditions ?? this.chronicConditions,
      emergencyContacts: emergencyContacts ?? this.emergencyContacts,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EmergencyCardData &&
          runtimeType == other.runtimeType &&
          fullName == other.fullName &&
          bloodType == other.bloodType &&
          chronicConditions == other.chronicConditions;

  @override
  int get hashCode =>
      fullName.hashCode ^ bloodType.hashCode ^ chronicConditions.hashCode;
}
