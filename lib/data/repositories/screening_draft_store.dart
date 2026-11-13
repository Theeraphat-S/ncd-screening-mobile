import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:ncd_screening_mobile/data/datasources/drift/app_database.dart';

class ScreeningDraft {
  final String patientId;
  final String vhvId;
  final Map<String, dynamic> data;
  final DateTime updatedAt;

  const ScreeningDraft({
    required this.patientId,
    required this.vhvId,
    required this.data,
    required this.updatedAt,
  });
}

/// Auto-saved, not-yet-submitted screening form input, one per patient and
/// VHV. Drafts hold health data, so they expire after [maxAge].
class ScreeningDraftStore {
  static const maxAge = Duration(days: 7);

  final AppDatabase _db;
  final DateTime Function() _now;

  ScreeningDraftStore(this._db, {DateTime Function()? now})
      : _now = now ?? DateTime.now;

  Future<void> save(String patientId, String vhvId, Map<String, dynamic> data) {
    return _db.into(_db.screeningDraftsTable).insertOnConflictUpdate(
          ScreeningDraftsTableCompanion(
            patientId: Value(patientId),
            vhvId: Value(vhvId),
            payload: Value(jsonEncode(data)),
            updatedAt: Value(_now()),
          ),
        );
  }

  Future<ScreeningDraft?> load(String patientId, String vhvId) async {
    final row = await (_db.select(_db.screeningDraftsTable)
          ..where((t) => t.patientId.equals(patientId) & t.vhvId.equals(vhvId)))
        .getSingleOrNull();
    if (row == null) return null;

    if (_now().difference(row.updatedAt) >= maxAge) {
      await delete(patientId, vhvId);
      return null;
    }
    try {
      final decoded = jsonDecode(row.payload);
      if (decoded is! Map<String, dynamic>) throw const FormatException();
      return ScreeningDraft(
        patientId: row.patientId,
        vhvId: row.vhvId,
        data: decoded,
        updatedAt: row.updatedAt,
      );
    } on FormatException {
      await delete(patientId, vhvId);
      return null;
    }
  }

  Future<void> delete(String patientId, String vhvId) {
    return (_db.delete(_db.screeningDraftsTable)
          ..where((t) => t.patientId.equals(patientId) & t.vhvId.equals(vhvId)))
        .go();
  }

  Future<void> purgeExpired() {
    final cutoff = _now().subtract(maxAge);
    return (_db.delete(_db.screeningDraftsTable)
          ..where((t) => t.updatedAt.isSmallerOrEqualValue(cutoff)))
        .go();
  }
}
