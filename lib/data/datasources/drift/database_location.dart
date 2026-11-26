import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// File name drift_flutter used for `driftDatabase(name: 'db')`. Kept so
/// existing installs find their data.
const appDatabaseFileName = 'db.sqlite';

/// Where the app database lives. (On Windows this is still the user's
/// Documents folder; moving the Hub's database to app-support is part of M5.)
Future<File> appDatabaseFile() async {
  final dir = await getApplicationDocumentsDirectory();
  return File(p.join(dir.path, appDatabaseFileName));
}
