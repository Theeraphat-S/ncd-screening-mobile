/// Test citizen IDs that pass the Thai check digit (repositories reject the
/// rest since M1).
String withCheckDigit(String first12) {
  assert(RegExp(r'^\d{12}$').hasMatch(first12), first12);
  var sum = 0;
  for (var i = 0; i < 12; i++) {
    sum += int.parse(first12[i]) * (13 - i);
  }
  return '$first12${(11 - sum % 11) % 10}';
}
