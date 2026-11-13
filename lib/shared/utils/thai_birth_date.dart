/// Parses a birth date typed as day / month / Buddhist-era year.
///
/// Returns null when any part is missing or non-numeric, when the date does
/// not exist on the calendar (e.g. 30 Feb), when the year looks like a
/// Gregorian year typed by mistake, or when the date is in the future.
DateTime? parseThaiBirthDate({
  required String day,
  required String month,
  required String yearBe,
  DateTime? today,
}) {
  final d = int.tryParse(day.trim());
  final m = int.tryParse(month.trim());
  final yBe = int.tryParse(yearBe.trim());
  if (d == null || m == null || yBe == null) return null;

  final now = today ?? DateTime.now();
  final nowDate = DateTime(now.year, now.month, now.day);
  final yCe = yBe - 543;

  // Reject Gregorian-looking years (e.g. 1980) and implausibly old dates.
  if (yBe < 2400 || yCe > nowDate.year) return null;
  if (m < 1 || m > 12 || d < 1) return null;

  final date = DateTime(yCe, m, d);
  if (date.year != yCe || date.month != m || date.day != d) return null;
  if (date.isAfter(nowDate)) return null;
  return date;
}
