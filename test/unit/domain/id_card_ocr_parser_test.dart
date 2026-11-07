import 'package:flutter_test/flutter_test.dart';
import 'package:ncd_screening_mobile/domain/services/id_card_ocr_parser.dart';

void main() {
  group('IdCardOcrParser', () {
    test('extracts formatted 13-digit Thai citizen ID and Thai name', () {
      const sampleOcr = '''
บัตรประจำตัวประชาชน Thai National ID Card
เลขประจำตัวประชาชน 1 5002 00123 45 6
ชื่อ นาย สมชาย ใจดี
Name Mr. Somchai Jaidee
เกิดวันที่ 15 ม.ค. 2515
ศาสนา พุทธ
      ''';

      final result = IdCardOcrParser.parse(sampleOcr);

      expect(result.citizenId, '1500200123456');
      expect(result.hasValidCitizenId, isTrue);
      expect(result.prefix, 'นาย');
      expect(result.firstName, 'สมชาย');
      expect(result.lastName, 'ใจดี');
      expect(result.fullName, 'นาย สมชาย ใจดี');
      expect(result.dateOfBirth, '15 ม.ค. 2515');
    });

    test('extracts hyphenated citizen ID with female prefix', () {
      const sampleOcr = '''
เลขประจำตัวประชาชน 3-5002-99887-65-4
นาง มาลี รักชาติ
      ''';

      final result = IdCardOcrParser.parse(sampleOcr);

      expect(result.citizenId, '3500299887654');
      expect(result.prefix, 'นาง');
      expect(result.firstName, 'มาลี');
      expect(result.lastName, 'รักชาติ');
    });

    test('extracts 13-digit sequence even without explicit label', () {
      const sampleOcr = '''
THAILAND
5500200011223
นาย บุญมี ทองคำ
      ''';

      final result = IdCardOcrParser.parse(sampleOcr);
      expect(result.citizenId, '5500200011223');
      expect(result.firstName, 'บุญมี');
      expect(result.lastName, 'ทองคำ');
    });

    test('handles empty and noisy input gracefully', () {
      final emptyResult = IdCardOcrParser.parse('');
      expect(emptyResult.hasValidCitizenId, isFalse);
      expect(emptyResult.citizenId, isNull);

      final noisyResult = IdCardOcrParser.parse(
        'Random text without any ID or numbers',
      );
      expect(noisyResult.hasValidCitizenId, isFalse);
      expect(noisyResult.citizenId, isNull);
    });
  });
}
