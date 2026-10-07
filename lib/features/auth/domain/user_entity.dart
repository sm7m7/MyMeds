/// Domain entity representing an authenticated user in MyMeds.
class AppUser {
  const AppUser({
    required this.uid,
    required this.email,
    this.displayName,
    this.photoUrl,
    this.preferredLanguage = 'en',
    this.createdAt,
  });

  final String uid;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final String preferredLanguage;
  final DateTime? createdAt;

  /// Creates an [AppUser] from Firestore document data.
  factory AppUser.fromMap(Map<String, dynamic> map, {required String uid}) {
    DateTime? createdAtDate;
    final dynamic rawCreatedAt = map['createdAt'];
    if (rawCreatedAt != null) {
      if (rawCreatedAt is DateTime) {
        createdAtDate = rawCreatedAt;
      } else if (rawCreatedAt is String) {
        createdAtDate = DateTime.tryParse(rawCreatedAt);
      } else if (rawCreatedAt is int) {
        createdAtDate = DateTime.fromMillisecondsSinceEpoch(rawCreatedAt);
      } else {
        // e.g. Timestamp from Firestore
        try {
          createdAtDate = (rawCreatedAt as dynamic).toDate();
        } catch (_) {}
      }
    }

    return AppUser(
      uid: uid,
      email: map['email'] as String? ?? '',
      displayName: map['displayName'] as String?,
      photoUrl: map['photoUrl'] as String?,
      preferredLanguage: map['preferredLanguage'] as String? ?? 'en',
      createdAt: createdAtDate,
    );
  }

  /// Converts the [AppUser] to minimal Firestore document data.
  Map<String, dynamic> toMinimalFirestoreMap() {
    return {
      'uid': uid,
      'email': email,
      'preferredLanguage': preferredLanguage,
    };
  }

  AppUser copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoUrl,
    String? preferredLanguage,
    DateTime? createdAt,
  }) {
    return AppUser(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppUser &&
          runtimeType == other.runtimeType &&
          uid == other.uid &&
          email == other.email &&
          preferredLanguage == other.preferredLanguage;

  @override
  int get hashCode => uid.hashCode ^ email.hashCode ^ preferredLanguage.hashCode;
}
