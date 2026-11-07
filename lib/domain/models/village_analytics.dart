import 'package:equatable/equatable.dart';
import 'package:ncd_screening_mobile/domain/models/ncd_models.dart';

/// Sorting options for village comparison rankings
enum AnalyticsSortOrder {
  highRiskDesc('เสี่ยงสูงมากที่สุด', 'High Risk First'),
  screeningCoverageDesc('ความครอบคลุมสูงสุด', 'Highest Coverage'),
  patientCountDesc('จำนวนประชากรมากที่สุด', 'Most Patients'),
  villageNumberAsc('ลำดับหมายเลขหมู่บ้าน', 'Village Number');

  final String labelTh;
  final String labelEn;

  const AnalyticsSortOrder(this.labelTh, this.labelEn);
}

/// Breakdown of risk levels (Low, Moderate, High) for a single NCD condition
class NcdDiseaseBreakdown extends Equatable {
  final String diseaseCode; // DIABETES, HYPERTENSION, CVD, METABOLIC_OBESITY
  final String diseaseName;
  final int lowCount;
  final int moderateCount;
  final int highCount;
  final int totalScreened;
  final double lowPercentage;
  final double moderatePercentage;
  final double highPercentage;

  const NcdDiseaseBreakdown({
    required this.diseaseCode,
    required this.diseaseName,
    required this.lowCount,
    required this.moderateCount,
    required this.highCount,
    required this.totalScreened,
    required this.lowPercentage,
    required this.moderatePercentage,
    required this.highPercentage,
  });

  factory NcdDiseaseBreakdown.fromCounts({
    required String diseaseCode,
    required String diseaseName,
    required int lowCount,
    required int moderateCount,
    required int highCount,
  }) {
    final total = lowCount + moderateCount + highCount;
    final lowPct = total == 0 ? 0.0 : (lowCount / total) * 100.0;
    final modPct = total == 0 ? 0.0 : (moderateCount / total) * 100.0;
    final highPct = total == 0 ? 0.0 : (highCount / total) * 100.0;

    return NcdDiseaseBreakdown(
      diseaseCode: diseaseCode,
      diseaseName: diseaseName,
      lowCount: lowCount,
      moderateCount: moderateCount,
      highCount: highCount,
      totalScreened: total,
      lowPercentage: double.parse(lowPct.toStringAsFixed(1)),
      moderatePercentage: double.parse(modPct.toStringAsFixed(1)),
      highPercentage: double.parse(highPct.toStringAsFixed(1)),
    );
  }

  @override
  List<Object?> get props => [
    diseaseCode,
    diseaseName,
    lowCount,
    moderateCount,
    highCount,
    totalScreened,
    lowPercentage,
    moderatePercentage,
    highPercentage,
  ];
}

/// Demographic distribution across gender and age brackets
class DemographicDistribution extends Equatable {
  final int maleCount;
  final int femaleCount;
  final int totalPatients;
  final double maleRatio;
  final double femaleRatio;

  final int ageUnder35Count;
  final int age35To59Count;
  final int age60AndAboveCount;

  final double ageUnder35Ratio;
  final double age35To59Ratio;
  final double age60AndAboveRatio;

  const DemographicDistribution({
    required this.maleCount,
    required this.femaleCount,
    required this.totalPatients,
    required this.maleRatio,
    required this.femaleRatio,
    required this.ageUnder35Count,
    required this.age35To59Count,
    required this.age60AndAboveCount,
    required this.ageUnder35Ratio,
    required this.age35To59Ratio,
    required this.age60AndAboveRatio,
  });

  factory DemographicDistribution.calculate({required List<Patient> patients}) {
    final total = patients.length;
    int male = 0;
    int female = 0;
    int under35 = 0;
    int age3559 = 0;
    int age60Plus = 0;

    for (final p in patients) {
      if (p.patientGender.contains('ชาย')) {
        male++;
      } else {
        female++;
      }

      final age = p.age;
      if (age < 35) {
        under35++;
      } else if (age < 60) {
        age3559++;
      } else {
        age60Plus++;
      }
    }

    final mRatio = total == 0 ? 0.0 : (male / total) * 100.0;
    final fRatio = total == 0 ? 0.0 : (female / total) * 100.0;
    final u35Ratio = total == 0 ? 0.0 : (under35 / total) * 100.0;
    final a3559Ratio = total == 0 ? 0.0 : (age3559 / total) * 100.0;
    final a60Ratio = total == 0 ? 0.0 : (age60Plus / total) * 100.0;

    return DemographicDistribution(
      maleCount: male,
      femaleCount: female,
      totalPatients: total,
      maleRatio: double.parse(mRatio.toStringAsFixed(1)),
      femaleRatio: double.parse(fRatio.toStringAsFixed(1)),
      ageUnder35Count: under35,
      age35To59Count: age3559,
      age60AndAboveCount: age60Plus,
      ageUnder35Ratio: double.parse(u35Ratio.toStringAsFixed(1)),
      age35To59Ratio: double.parse(a3559Ratio.toStringAsFixed(1)),
      age60AndAboveRatio: double.parse(a60Ratio.toStringAsFixed(1)),
    );
  }

  @override
  List<Object?> get props => [
    maleCount,
    femaleCount,
    totalPatients,
    maleRatio,
    femaleRatio,
    ageUnder35Count,
    age35To59Count,
    age60AndAboveCount,
    ageUnder35Ratio,
    age35To59Ratio,
    age60AndAboveRatio,
  ];
}

/// High-risk patient priority item for community health follow-up
class HighRiskPriorityPatient extends Equatable {
  final Patient patient;
  final Village? village;
  final Screening latestScreening;
  final List<String> highRiskDiseases;
  final int highRiskCount;
  final DateTime latestScreeningDate;

  const HighRiskPriorityPatient({
    required this.patient,
    this.village,
    required this.latestScreening,
    required this.highRiskDiseases,
    required this.highRiskCount,
    required this.latestScreeningDate,
  });

  @override
  List<Object?> get props => [
    patient,
    village,
    latestScreening,
    highRiskDiseases,
    highRiskCount,
    latestScreeningDate,
  ];
}

/// Comparative health metrics summary for an individual village
class VillageComparisonSummary extends Equatable {
  final Village village;
  final int totalPatients;
  final int screenedPatientsCount;
  final double screeningCoveragePercentage;
  final int highRiskPatientsCount;
  final int pendingReviewCount;
  final int approvedReviewCount;

  const VillageComparisonSummary({
    required this.village,
    required this.totalPatients,
    required this.screenedPatientsCount,
    required this.screeningCoveragePercentage,
    required this.highRiskPatientsCount,
    required this.pendingReviewCount,
    required this.approvedReviewCount,
  });

  @override
  List<Object?> get props => [
    village,
    totalPatients,
    screenedPatientsCount,
    screeningCoveragePercentage,
    highRiskPatientsCount,
    pendingReviewCount,
    approvedReviewCount,
  ];
}

/// Root aggregate village analytics model
class VillageAnalytics extends Equatable {
  final String? selectedVillageId;
  final String selectedVillageName;
  final int totalVillagesCount;
  final int totalPatients;
  final int screenedPatientsCount;
  final int totalScreeningsCount;
  final double screeningCoveragePercentage;
  final int highRiskPatientsCount;
  final int pendingReviewsCount;
  final int approvedReviewsCount;

  final Map<String, NcdDiseaseBreakdown> diseaseBreakdowns;
  final DemographicDistribution demographics;
  final List<VillageComparisonSummary> villageComparisons;
  final List<HighRiskPriorityPatient> highRiskPriorityQueue;
  final AnalyticsSortOrder sortOrder;

  const VillageAnalytics({
    this.selectedVillageId,
    required this.selectedVillageName,
    required this.totalVillagesCount,
    required this.totalPatients,
    required this.screenedPatientsCount,
    required this.totalScreeningsCount,
    required this.screeningCoveragePercentage,
    required this.highRiskPatientsCount,
    required this.pendingReviewsCount,
    required this.approvedReviewsCount,
    required this.diseaseBreakdowns,
    required this.demographics,
    required this.villageComparisons,
    required this.highRiskPriorityQueue,
    this.sortOrder = AnalyticsSortOrder.highRiskDesc,
  });

  bool get isAllVillages =>
      selectedVillageId == null || selectedVillageId!.isEmpty;

  NcdDiseaseBreakdown? get diabetesBreakdown => diseaseBreakdowns['DIABETES'];
  NcdDiseaseBreakdown? get hypertensionBreakdown =>
      diseaseBreakdowns['HYPERTENSION'];
  NcdDiseaseBreakdown? get cvdBreakdown => diseaseBreakdowns['CVD'];
  NcdDiseaseBreakdown? get obesityBreakdown =>
      diseaseBreakdowns['METABOLIC_OBESITY'];

  @override
  List<Object?> get props => [
    selectedVillageId,
    selectedVillageName,
    totalVillagesCount,
    totalPatients,
    screenedPatientsCount,
    totalScreeningsCount,
    screeningCoveragePercentage,
    highRiskPatientsCount,
    pendingReviewsCount,
    approvedReviewsCount,
    diseaseBreakdowns,
    demographics,
    villageComparisons,
    highRiskPriorityQueue,
    sortOrder,
  ];
}
