import 'dart:io';
import 'dart:math';

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:ncd_screening_mobile/domain/services/pin_service.dart';
import 'package:sqlite3/sqlite3.dart';

/// Random 256-bit SQLCipher key, kept in secure storage (Android Keystore,
/// Windows DPAPI). Deleting it makes the database unreadable, which is what
/// the Spoke wipe relies on.
class DatabaseKeyStore {
  static const keyName = 'db_key';
  static final _hex = RegExp(r'^[0-9a-f]{64}$');

  final SecureStore _store;
  final Random _random;

  DatabaseKeyStore(this._store, {Random? random})
      : _random = random ?? Random.secure();

  /// The stored key, or a new one (stored first) if there is none.
  Future<String> obtainKey() async {
    final existing = await _store.read(keyName);
    if (existing != null && _hex.hasMatch(existing)) return existing;
    final key = List.generate(32, (_) => _random.nextInt(256))
        .map((b) => b.toRadixString(16).padLeft(2, '0'))
        .join();
    await _store.write(keyName, key);
    return key;
  }
}

/// `PRAGMA key` for a raw 64-hex-digit key (no passphrase derivation).
String sqlCipherKeyPragma(String hexKey) {
  assert(RegExp(r'^[0-9a-f]{64}$').hasMatch(hexKey));
  return "PRAGMA key = \"x'$hexKey'\";";
}

/// True when the linked SQLite library is SQLCipher. A misconfigured build
/// (hooks user-define missing) would silently store plaintext otherwise.
bool sqlCipherAvailable() {
  final db = sqlite3.openInMemory();
  try {
    final rows = db.select('PRAGMA cipher_version');
    return rows.isNotEmpty && '${rows.first.values.first}'.isNotEmpty;
  } finally {
    db.close();
  }
}

/// A plaintext SQLite file starts with this 16-byte header; an SQLCipher
/// file starts with random salt.
bool isPlaintextSqlite(File file) {
  if (!file.existsSync() || file.lengthSync() < 16) return false;
  final raf = file.openSync();
  try {
    final header = raf.readSync(16);
    return String.fromCharCodes(header) == 'SQLite format 3\u0000';
  } finally {
    raf.closeSync();
  }
}

/// Whether [file] opens with [hexKey].
bool opensWithKey(File file, String hexKey) {
  final db = sqlite3.open(file.path);
  try {
    db.execute(sqlCipherKeyPragma(hexKey));
    db.select('SELECT count(*) FROM sqlite_master');
    return true;
  } on SqliteException {
    return false;
  } finally {
    db.close();
  }
}

File _sibling(File file, String suffix) => File('${file.path}$suffix');

void _deleteIfExists(File f) {
  if (f.existsSync()) f.deleteSync();
}

void _deleteSidecars(File db) {
  for (final s in ['-wal', '-shm', '-journal']) {
    _deleteIfExists(_sibling(db, s));
  }
}

/// Rewrites a plaintext database as an SQLCipher database with [hexKey],
/// keeping its schema version. The swap goes through `.plaintext-backup`
/// so a crash at any point leaves a readable copy behind (see
/// [_recoverInterruptedEncryption]).
void encryptPlaintextDatabase(File file, String hexKey) {
  final tmp = _sibling(file, '.encrypting');
  final backup = _sibling(file, '.plaintext-backup');
  _deleteIfExists(tmp);

  final db = sqlite3.open(file.path);
  try {
    final version = db.select('PRAGMA user_version').first.values.first as int;
    db.execute(
      "ATTACH DATABASE ? AS encrypted KEY \"x'$hexKey'\";",
      [tmp.path],
    );
    db.select("SELECT sqlcipher_export('encrypted')");
    db.execute('PRAGMA encrypted.user_version = $version;');
    db.execute('DETACH DATABASE encrypted;');
  } finally {
    db.close();
  }

  _deleteIfExists(backup);
  file.renameSync(backup.path);
  _deleteSidecars(file);
  tmp.renameSync(file.path);
  backup.deleteSync();
}

void _recoverInterruptedEncryption(File file, String hexKey) {
  final backup = _sibling(file, '.plaintext-backup');
  _deleteIfExists(_sibling(file, '.encrypting'));
  if (!backup.existsSync()) return;
  if (file.existsSync() && opensWithKey(file, hexKey) && !isPlaintextSqlite(file)) {
    backup.deleteSync(); // the swap finished; only the clean-up was missed
  } else {
    _deleteIfExists(file);
    backup.renameSync(file.path); // back to plaintext; encrypted again below
  }
}

/// Gets [file] ready to be opened with the key from [store]:
/// - a plaintext database from before M1 is encrypted in place;
/// - a database that the stored key cannot open (key lost, e.g. after a
///   restore) is moved aside as `.unreadable-<time>` and a new one is
///   started, instead of crashing on every launch.
///
/// Returns the key to open the database with.
Future<String> prepareEncryptedDatabase(File file, SecureStore store) async {
  if (!sqlCipherAvailable()) {
    throw StateError('SQLCipher is not linked; refusing to store data unencrypted');
  }
  final key = await DatabaseKeyStore(store).obtainKey();
  file.parent.createSync(recursive: true);
  _recoverInterruptedEncryption(file, key);

  if (!file.existsSync()) return key;
  if (isPlaintextSqlite(file)) {
    encryptPlaintextDatabase(file, key);
  } else if (!opensWithKey(file, key)) {
    final aside = _sibling(file, '.unreadable-${DateTime.now().millisecondsSinceEpoch}');
    debugPrint('Database cannot be opened with the stored key; moved to ${aside.path}');
    file.renameSync(aside.path);
    _deleteSidecars(file);
  }
  return key;
}

/// Drift connection to the encrypted database in [file].
QueryExecutor openEncryptedDatabase(File file, String hexKey) {
  final path = file.path;
  return driftDatabase(
    name: 'db',
    native: DriftNativeOptions(
      databasePath: () async => path,
      setup: (db) => db.execute(sqlCipherKeyPragma(hexKey)),
    ),
  );
}
