import 'package:uuid/uuid.dart';

const _uuid = Uuid();

/// Collision-free ID (UUID v4) that is safe to create offline on any device.
String generateId() => _uuid.v4();
