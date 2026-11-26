import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

/// Places a call (opens the dialer with [number] filled in). Returns false
/// when this device cannot call, e.g. the Windows Hub.
typedef PhoneDialer = Future<bool> Function(String number);

/// `tel:` URI with everything but digits and a leading + removed, so
/// display formats such as `053-459034` dial correctly.
Uri telUri(String number) {
  final trimmed = number.trim();
  final digits = trimmed.replaceAll(RegExp(r'[^0-9]'), '');
  return Uri(scheme: 'tel', path: trimmed.startsWith('+') ? '+$digits' : digits);
}

/// Default [PhoneDialer] backed by `url_launcher`.
Future<bool> dialPhoneNumber(String number) async {
  try {
    return await launchUrl(telUri(number));
  } catch (e) {
    debugPrint('Could not start a call: $e');
    return false;
  }
}
