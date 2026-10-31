import 'package:my_meds/features/emergency/domain/models/emergency_card_data.dart';

/// Contract for loading and persisting the user's emergency card data.
abstract class EmergencyCardRepository {
  const EmergencyCardRepository();

  /// Loads emergency card data from local offline cache or remote Firestore.
  Future<EmergencyCardData?> getEmergencyCard(String userId);

  /// Saves emergency card data to Firestore and updates local offline cache.
  Future<void> saveEmergencyCard(String userId, EmergencyCardData data);

  /// Stream of emergency card data for real-time reactive updates.
  Stream<EmergencyCardData?> watchEmergencyCard(String userId);
}
