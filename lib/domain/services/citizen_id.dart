/// Thai national ID (13 digits) format and check-digit validation.
class CitizenId {
  CitizenId._();

  /// True when [id] is exactly 13 digits and its last digit matches the
  /// check digit: `(11 - (sum of digit[i] * (13 - i), i = 0..11) % 11) % 10`.
  static bool isValid(String id) {
    if (!RegExp(r'^\d{13}$').hasMatch(id)) return false;
    var sum = 0;
    for (var i = 0; i < 12; i++) {
      sum += int.parse(id[i]) * (13 - i);
    }
    return (11 - sum % 11) % 10 == int.parse(id[12]);
  }
}
