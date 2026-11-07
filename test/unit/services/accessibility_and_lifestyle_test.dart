import 'package:flutter_test/flutter_test.dart';
import 'package:ncd_screening_mobile/domain/models/ncd_models.dart';
import 'package:ncd_screening_mobile/domain/services/ncd_lifestyle_advisor.dart';
import 'package:ncd_screening_mobile/shared/bloc/accessibility/accessibility_cubit.dart';

void main() {
  group('AccessibilityCubit', () {
    late AccessibilityCubit cubit;

    setUp(() {
      cubit = AccessibilityCubit();
    });

    tearDown(() {
      cubit.close();
    });

    test('initial state has elderly mode false and scale 1.0', () {
      expect(cubit.state.isElderlyMode, isFalse);
      expect(cubit.state.textScaleFactor, 1.0);
      expect(cubit.state.isHighContrast, isFalse);
    });

    test('toggleElderlyMode toggles state and scales font to 1.35x', () {
      cubit.toggleElderlyMode();
      expect(cubit.state.isElderlyMode, isTrue);
      expect(cubit.state.textScaleFactor, 1.35);

      cubit.toggleElderlyMode();
      expect(cubit.state.isElderlyMode, isFalse);
      expect(cubit.state.textScaleFactor, 1.0);
    });

    test('setElderlyMode explicitly configures mode', () {
      cubit.setElderlyMode(true);
      expect(cubit.state.isElderlyMode, isTrue);
      expect(cubit.state.textScaleFactor, 1.35);
    });

    test('toggleHighContrast toggles contrast mode', () {
      expect(cubit.state.isHighContrast, isFalse);
      cubit.toggleHighContrast();
      expect(cubit.state.isHighContrast, isTrue);
      cubit.toggleHighContrast();
      expect(cubit.state.isHighContrast, isFalse);
    });

    test(
      'increaseTextScale and decreaseTextScale adjust scale within clamp range',
      () {
        cubit.increaseTextScale();
        expect(cubit.state.textScaleFactor, 1.1);

        cubit.increaseTextScale();
        cubit.increaseTextScale(); // 1.3
        expect(cubit.state.textScaleFactor, 1.3);

        cubit.decreaseTextScale();
        expect(cubit.state.textScaleFactor, 1.2);
      },
    );

    test('resetAccessibility resets state to default', () {
      cubit.increaseTextScale();
      cubit.toggleHighContrast();
      expect(cubit.state.textScaleFactor, 1.1);
      expect(cubit.state.isHighContrast, isTrue);

      cubit.resetAccessibility();
      expect(cubit.state.textScaleFactor, 1.0);
      expect(cubit.state.isElderlyMode, isFalse);
      expect(cubit.state.isHighContrast, isFalse);
    });
  });

  group('NcdLifestyleAdvisor', () {
    final testScreening = Screening(
      screenId: 'SCR001',
      patientId: 'P001',
      vhvId: 'VHV001',
      screeningDate: DateTime.now(),
      ageAtScreening: 65,
      weight: 80.0,
      height: 160.0,
      bmi: 31.25,
      waistCm: 95.0,
      sbp: 160.0,
      dbp: 100.0,
      pulse: 78.0,
      bloodSugar: 145.0,
      reviewStatus: ReviewStatus.pending,
      createdAt: DateTime.now(),
      histories: const [],
      results: const [
        ScreeningResult(
          resultId: 'R1',
          screeningId: 'SCR001',
          diseaseName: 'โรคเบาหวาน',
          diseaseCode: 'DM',
          score: 8,
          riskLevel: RiskLevel.high,
          adviceText: 'ควรพบแพทย์',
        ),
        ScreeningResult(
          resultId: 'R2',
          screeningId: 'SCR001',
          diseaseName: 'โรคความดันโลหิตสูง',
          diseaseCode: 'HT',
          score: 9,
          riskLevel: RiskLevel.high,
          adviceText: 'ควรพบแพทย์',
        ),
      ],
    );

    test(
      'generates personalized plain Thai advice for high-risk conditions',
      () {
        final adviceList = NcdLifestyleAdvisor.generateAdviceList(
          screening: testScreening,
          results: testScreening.results,
        );

        expect(adviceList.length, 2);

        final dmAdvice = adviceList.firstWhere(
          (a) => a.diseaseName.contains('เบาหวาน'),
        );
        expect(dmAdvice.riskLevel, RiskLevel.high);
        expect(dmAdvice.goodFoods, contains('ข้าวกล้อง / ข้าวไรซ์เบอร์รี่'));
        expect(dmAdvice.avoidFoods, contains('น้ำอัดลม ชาเขียวหวาน ชานม'));
        expect(dmAdvice.followUpSchedule, contains('รพ.สต.'));

        final htAdvice = adviceList.firstWhere(
          (a) => a.diseaseName.contains('ความดัน'),
        );
        expect(htAdvice.riskLevel, RiskLevel.high);
        expect(
          htAdvice.avoidFoods,
          contains('น้ำปลา ซีอิ๊ว กะปิ ปลาร้าเข้มข้น'),
        );
      },
    );
  });
}
