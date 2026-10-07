/// Represents structured medication information for display and cabinet storage.
class MedicationInfo {
  const MedicationInfo({
    required this.id,
    required this.name,
    this.genericName,
    this.brandNames = const [],
    this.purpose,
    this.indicationsAndUsage,
    this.dosageAndAdministration,
    this.storageAndHandling,
    this.warnings,
    this.boxedWarning,
    this.activeIngredients = const [],
    this.route = const [],
    this.productType,
  });

  /// Unique identifier or OpenFDA SPL ID / NDC / RxCUI.
  final String id;

  /// Primary display name (brand name or primary title).
  final String name;

  /// Generic active drug name (e.g. "Ibuprofen", "Acetaminophen").
  final String? genericName;

  /// List of brand names associated with this medication.
  final List<String> brandNames;

  /// Short purpose or clinical intent (e.g. "Pain reliever / Fever reducer").
  final String? purpose;

  /// Detailed clinical indications and usage instructions.
  final String? indicationsAndUsage;

  /// Detailed dosage, administration, and frequency guidance.
  final String? dosageAndAdministration;

  /// Storage and handling conditions (temperature, light, moisture).
  final String? storageAndHandling;

  /// Warnings, precautions, contraindications, and adverse reactions.
  final String? warnings;

  /// High-priority boxed warning (black box warning) if applicable.
  final String? boxedWarning;

  /// Active ingredients and strengths.
  final List<String> activeIngredients;

  /// Administration routes (e.g. "ORAL", "TOPICAL").
  final List<String> route;

  /// Product category / type.
  final String? productType;

  /// Creates a [MedicationInfo] instance from a JSON map (e.g. from local cache or openFDA).
  factory MedicationInfo.fromJson(Map<String, dynamic> json) {
    return MedicationInfo(
      id: json['id'] as String? ?? (json['set_id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString()),
      name: json['name'] as String? ?? (json['brand_name'] as String? ?? 'Unknown Medication'),
      genericName: json['genericName'] as String? ?? json['generic_name'] as String?,
      brandNames: (json['brandNames'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          (json['brand_name_list'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      purpose: json['purpose'] as String?,
      indicationsAndUsage: json['indicationsAndUsage'] as String? ??
          json['indications_and_usage'] as String?,
      dosageAndAdministration: json['dosageAndAdministration'] as String? ??
          json['dosage_and_administration'] as String?,
      storageAndHandling: json['storageAndHandling'] as String? ??
          json['storage_and_handling'] as String?,
      warnings: json['warnings'] as String?,
      boxedWarning: json['boxedWarning'] as String? ?? json['boxed_warning'] as String?,
      activeIngredients: (json['activeIngredients'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          (json['active_ingredient'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      route: (json['route'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      productType: json['productType'] as String? ?? json['product_type'] as String?,
    );
  }

  /// Converts this [MedicationInfo] instance into a JSON map for storage/serialization.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'genericName': genericName,
      'brandNames': brandNames,
      'purpose': purpose,
      'indicationsAndUsage': indicationsAndUsage,
      'dosageAndAdministration': dosageAndAdministration,
      'storageAndHandling': storageAndHandling,
      'warnings': warnings,
      'boxedWarning': boxedWarning,
      'activeIngredients': activeIngredients,
      'route': route,
      'productType': productType,
    };
  }

  /// Creates a copy with optionally updated fields.
  MedicationInfo copyWith({
    String? id,
    String? name,
    String? genericName,
    List<String>? brandNames,
    String? purpose,
    String? indicationsAndUsage,
    String? dosageAndAdministration,
    String? storageAndHandling,
    String? warnings,
    String? boxedWarning,
    List<String>? activeIngredients,
    List<String>? route,
    String? productType,
  }) {
    return MedicationInfo(
      id: id ?? this.id,
      name: name ?? this.name,
      genericName: genericName ?? this.genericName,
      brandNames: brandNames ?? this.brandNames,
      purpose: purpose ?? this.purpose,
      indicationsAndUsage: indicationsAndUsage ?? this.indicationsAndUsage,
      dosageAndAdministration:
          dosageAndAdministration ?? this.dosageAndAdministration,
      storageAndHandling: storageAndHandling ?? this.storageAndHandling,
      warnings: warnings ?? this.warnings,
      boxedWarning: boxedWarning ?? this.boxedWarning,
      activeIngredients: activeIngredients ?? this.activeIngredients,
      route: route ?? this.route,
      productType: productType ?? this.productType,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MedicationInfo &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name;

  @override
  int get hashCode => id.hashCode ^ name.hashCode;
}
