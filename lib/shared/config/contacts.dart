/// Phone numbers shown in the app and printed on reports. Kept in one place
/// so the triage card and the PDF footer can never disagree again.
class HealthCenterContacts {
  HealthCenterContacts._();

  static const String healthCenterName = 'รพ.สต.แม่อาย';

  // TODO(pilot-meeting): confirm the รพ.สต. number. The triage card used
  // 053-459034 and the PDF footer 053-459-000; 053-459034 is kept until the
  // meeting (docs/pilot-meeting-questions.md).
  static const String healthCenterPhone = '053-459034';

  /// National emergency medical services (สพฉ.).
  static const String emergencyHotline = '1669';
}
