import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_meds/features/emergency/domain/models/emergency_card_data.dart';
import 'package:my_meds/features/emergency/domain/repositories/emergency_card_repository.dart';

/// Implementation of [EmergencyCardRepository] that stores data under
/// `users/{uid}/emergencyCard/profile` in Firestore and mirrors it in
/// [SharedPreferences] for instant 100% offline access.
class FirestoreEmergencyCardRepository implements EmergencyCardRepository {
  FirestoreEmergencyCardRepository({
    FirebaseFirestore? firestore,
    SharedPreferences? sharedPreferences,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _prefs = sharedPreferences;

  final FirebaseFirestore _firestore;
  SharedPreferences? _prefs;

  static const String _cachePrefix = 'mymeds_offline_emergency_card_';

  Future<SharedPreferences> _getPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  DocumentReference<Map<String, dynamic>> _docRef(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('emergencyCard')
        .doc('profile');
  }

  @override
  Future<EmergencyCardData?> getEmergencyCard(String userId) async {
    // 1. Try local cache first for instant speed & offline guarantee
    final cached = await _loadFromCache(userId);
    if (cached != null) {
      // Fire-and-forget sync in background if online
      _syncFromRemote(userId);
      return cached;
    }

    // 2. Fetch from Firestore if no local cache
    return _syncFromRemote(userId);
  }

  Future<EmergencyCardData?> _syncFromRemote(String userId) async {
    try {
      final snapshot = await _docRef(userId).get();
      if (snapshot.exists && snapshot.data() != null) {
        final data = EmergencyCardData.fromJson(snapshot.data()!);
        await _saveToCache(userId, data);
        return data;
      }
    } catch (_) {}
    return null;
  }

  @override
  Future<void> saveEmergencyCard(String userId, EmergencyCardData data) async {
    final now = DateTime.now();
    final updated = data.copyWith(updatedAt: now);

    // 1. Save to local offline cache immediately
    await _saveToCache(userId, updated);

    // 2. Persist to Firestore: users/{userId}/emergencyCard/profile
    try {
      await _docRef(userId).set(updated.toJson(), SetOptions(merge: true));
    } catch (_) {
      // Offline writes are queued by Cloud Firestore SDK automatically
    }
  }

  @override
  Stream<EmergencyCardData?> watchEmergencyCard(String userId) {
    return _docRef(userId).snapshots().map((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        final data = EmergencyCardData.fromJson(snapshot.data()!);
        _saveToCache(userId, data);
        return data;
      }
      return null;
    });
  }

  Future<EmergencyCardData?> _loadFromCache(String userId) async {
    try {
      final prefs = await _getPrefs();
      final raw = prefs.getString('$_cachePrefix$userId');
      if (raw != null && raw.isNotEmpty) {
        return EmergencyCardData.fromJson(jsonDecode(raw) as Map<String, dynamic>);
      }
    } catch (_) {}
    return null;
  }

  Future<void> _saveToCache(String userId, EmergencyCardData data) async {
    try {
      final prefs = await _getPrefs();
      await prefs.setString(
        '$_cachePrefix$userId',
        jsonEncode(data.toJson()),
      );
    } catch (_) {}
  }
}
