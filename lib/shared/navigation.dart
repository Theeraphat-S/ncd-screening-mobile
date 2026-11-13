import 'package:flutter/widgets.dart';

/// Root navigator, reachable from widgets that live above the Navigator
/// (e.g. the idle lock overlay).
final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();
