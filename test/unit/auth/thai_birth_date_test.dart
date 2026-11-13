import 'package:flutter_test/flutter_test.dart';
import 'package:ncd_screening_mobile/shared/utils/thai_birth_date.dart';

void main() {
  final today = DateTime(2026, 11, 12);

  group('parseThaiBirthDate', () {
    test('converts a Buddhist-era year to the Gregorian date', () {
      expect(
        parseThaiBirthDate(day: '1', month: '2', yearBe: '2523', today: today),
        DateTime(1980, 2, 1),
      );
    });

    test('accepts zero-padded and surrounding whitespace', () {
      expect(
        parseThaiBirthDate(
            day: ' 01 ', month: '02', yearBe: ' 2523', today: today),
        DateTime(1980, 2, 1),
      );
    });

    test('rejects empty or non-numeric parts', () {
      expect(parseThaiBirthDate(day: '', month: '2', yearBe: '2523', today: today), isNull);
      expect(parseThaiBirthDate(day: 'a', month: '2', yearBe: '2523', today: today), isNull);
      expect(parseThaiBirthDate(day: '1', month: '2', yearBe: '', today: today), isNull);
    });

    test('rejects dates that do not exist on the calendar', () {
      expect(parseThaiBirthDate(day: '31', month: '4', yearBe: '2523', today: today), isNull);
      expect(parseThaiBirthDate(day: '30', month: '2', yearBe: '2523', today: today), isNull);
      expect(parseThaiBirthDate(day: '29', month: '2', yearBe: '2523', today: today),
          DateTime(1980, 2, 29));
      expect(parseThaiBirthDate(day: '29', month: '2', yearBe: '2525', today: today), isNull);
      expect(parseThaiBirthDate(day: '0', month: '1', yearBe: '2523', today: today), isNull);
      expect(parseThaiBirthDate(day: '1', month: '13', yearBe: '2523', today: today), isNull);
    });

    test('rejects a Gregorian year typed by mistake and future dates', () {
      expect(parseThaiBirthDate(day: '1', month: '2', yearBe: '1980', today: today), isNull);
      expect(parseThaiBirthDate(day: '13', month: '11', yearBe: '2569', today: today), isNull);
      expect(parseThaiBirthDate(day: '12', month: '11', yearBe: '2569', today: today),
          DateTime(2026, 11, 12));
    });

    test('rejects implausibly old birth years', () {
      expect(parseThaiBirthDate(day: '1', month: '1', yearBe: '2300', today: today), isNull);
    });
  });
}
