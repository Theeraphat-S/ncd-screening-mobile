import 'package:ncd_screening_mobile/domain/models/ncd_models.dart';
import 'package:ncd_screening_mobile/domain/models/village_analytics.dart';

/// Pure Dart deterministic calculation engine for Village Health Analytics
class VillageAnalyticsCalculator {
  /// Compute comprehensive village health analytics and risk metrics
  static VillageAnalytics compute({
    required List<Village> villages,
    required List<Patient> patients,
    required List<Screening> screenings,
    String? selectedVillageId,
    AnalyticsSortOrder sortOrder = AnalyticsSortOrder.highRiskDesc,
  }) {
    // 1. Identify active scope
    final isSpecificVillage =
        selectedVillageId != null && selectedVillageId.isNotEmpty;

    final List<Patient> activePatients = isSpecificVillage
        ? patients.where((p) => p.villageId == selectedVillageId).toList()
        : patients.toList();

    final activePatientIds = activePatients.map((p) => p.patientId).toSet();

    final List<Screening> activeScreenings = screenings
        .where((s) => activePatientIds.contains(s.patientId))
        .toList();

    // Map village lookup
    final villageMap = {for (final v in villages) v.villageId: v};

    // Determine selected village display name
    String selectedVillageName;
    if (isSpecificVillage) {
      final selectedVillage = villageMap[selectedVillageId];
      if (selectedVillage != null) {
        selectedVillageName =
            'หมู่ ${selectedVillage.villageNumber} ${selectedVillage.villageName}';
      } else {
        selectedVillageName = selectedVillageId;
      }
    } else {
      selectedVillageName = 'ทุกหมู่บ้าน (${villages.length} หมู่บ้าน)';
    }

    // 2. Group screenings by patient and find latest screening for each patient
    final patientScreeningsMap = <String, List<Screening>>{};
    for (final s in activeScreenings) {
      patientScreeningsMap.putIfAbsent(s.patientId, () => []).add(s);
    }

    final latestScreeningMap = <String, Screening>{};
    for (final entry in patientScreeningsMap.entries) {
      final list = entry.value;
      list.sort((a, b) => b.screeningDate.compareTo(a.screeningDate));
      latestScreeningMap[entry.key] = list.first;
    }

    // 3. KPI Metrics
    final totalPatients = activePatients.length;
    final screenedPatientsCount = latestScreeningMap.length;
    final totalScreeningsCount = activeScreenings.length;

    final double coveragePct = totalPatients == 0
        ? 0.0
        : double.parse(
            ((screenedPatientsCount / totalPatients) * 100.0).toStringAsFixed(
              1,
            ),
          );

    int pendingReviews = 0;
    int approvedReviews = 0;
    for (final s in activeScreenings) {
      if (s.reviewStatus == ReviewStatus.pending) {
        pendingReviews++;
      } else if (s.reviewStatus == ReviewStatus.approved) {
        approvedReviews++;
      }
    }

    // 4. Demographic Distribution
    final demographics = DemographicDistribution.calculate(
      patients: activePatients,
    );

    // 5. 4 NCD Disease Breakdowns
    int dmLow = 0, dmMod = 0, dmHigh = 0;
    int htLow = 0, htMod = 0, htHigh = 0;
    int cvdLow = 0, cvdMod = 0, cvdHigh = 0;
    int obLow = 0, obMod = 0, obHigh = 0;

    final highRiskPatients = <HighRiskPriorityPatient>[];

    for (final patient in activePatients) {
      final latest = latestScreeningMap[patient.patientId];
      if (latest == null) continue;

      final highRiskDiseases = <String>[];

      for (final result in latest.results) {
        final code = result.diseaseCode.toUpperCase();
        final risk = result.riskLevel;

        if (risk == RiskLevel.high) {
          highRiskDiseases.add(result.diseaseName);
        }

        if (code.contains('DIABETES') || code == 'DM') {
          if (risk == RiskLevel.high) {
            dmHigh++;
          } else if (risk == RiskLevel.moderate) {
            dmMod++;
          } else {
            dmLow++;
          }
        } else if (code.contains('HYPERTENSION') || code == 'HT') {
          if (risk == RiskLevel.high) {
            htHigh++;
          } else if (risk == RiskLevel.moderate) {
            htMod++;
          } else {
            htLow++;
          }
        } else if (code.contains('CVD') || code.contains('CARDIO')) {
          if (risk == RiskLevel.high) {
            cvdHigh++;
          } else if (risk == RiskLevel.moderate) {
            cvdMod++;
          } else {
            cvdLow++;
          }
        } else if (code.contains('OBESITY') || code.contains('METABOLIC')) {
          if (risk == RiskLevel.high) {
            obHigh++;
          } else if (risk == RiskLevel.moderate) {
            obMod++;
          } else {
            obLow++;
          }
        }
      }

      if (highRiskDiseases.isNotEmpty) {
        highRiskPatients.add(
          HighRiskPriorityPatient(
            patient: patient,
            village: villageMap[patient.villageId],
            latestScreening: latest,
            highRiskDiseases: highRiskDiseases,
            highRiskCount: highRiskDiseases.length,
            latestScreeningDate: latest.screeningDate,
          ),
        );
      }
    }

    // Sort high-risk priority patients by risk count desc, then date desc
    highRiskPatients.sort((a, b) {
      final cmp = b.highRiskCount.compareTo(a.highRiskCount);
      if (cmp != 0) return cmp;
      return b.latestScreeningDate.compareTo(a.latestScreeningDate);
    });

    final diseaseBreakdowns = {
      'DIABETES': NcdDiseaseBreakdown.fromCounts(
        diseaseCode: 'DIABETES',
        diseaseName: 'โรคเบาหวาน',
        lowCount: dmLow,
        moderateCount: dmMod,
        highCount: dmHigh,
      ),
      'HYPERTENSION': NcdDiseaseBreakdown.fromCounts(
        diseaseCode: 'HYPERTENSION',
        diseaseName: 'โรคความดันโลหิตสูง',
        lowCount: htLow,
        moderateCount: htMod,
        highCount: htHigh,
      ),
      'CVD': NcdDiseaseBreakdown.fromCounts(
        diseaseCode: 'CVD',
        diseaseName: 'โรคหลอดเลือดหัวใจ',
        lowCount: cvdLow,
        moderateCount: cvdMod,
        highCount: cvdHigh,
      ),
      'METABOLIC_OBESITY': NcdDiseaseBreakdown.fromCounts(
        diseaseCode: 'METABOLIC_OBESITY',
        diseaseName: 'โรคอ้วนลงพุง',
        lowCount: obLow,
        moderateCount: obMod,
        highCount: obHigh,
      ),
    };

    // 6. Village Comparison Summaries
    // Map all screenings by patient across the entire dataset
    final allPatientScreeningsMap = <String, List<Screening>>{};
    for (final s in screenings) {
      allPatientScreeningsMap.putIfAbsent(s.patientId, () => []).add(s);
    }
    final allLatestScreeningMap = <String, Screening>{};
    for (final entry in allPatientScreeningsMap.entries) {
      final list = entry.value;
      list.sort((a, b) => b.screeningDate.compareTo(a.screeningDate));
      allLatestScreeningMap[entry.key] = list.first;
    }

    final comparisons = <VillageComparisonSummary>[];

    for (final village in villages) {
      final vPatients = patients
          .where((p) => p.villageId == village.villageId)
          .toList();
      final vPatientIds = vPatients.map((p) => p.patientId).toSet();
      final vScreenings = screenings
          .where((s) => vPatientIds.contains(s.patientId))
          .toList();

      int vScreenedCount = 0;
      int vHighRiskCount = 0;
      for (final p in vPatients) {
        final latest = allLatestScreeningMap[p.patientId];
        if (latest != null) {
          vScreenedCount++;
          final hasHighRisk = latest.results.any(
            (r) => r.riskLevel == RiskLevel.high,
          );
          if (hasHighRisk) {
            vHighRiskCount++;
          }
        }
      }

      final vTotal = vPatients.length;
      final double vCoveragePct = vTotal == 0
          ? 0.0
          : double.parse(
              ((vScreenedCount / vTotal) * 100.0).toStringAsFixed(1),
            );

      int vPending = 0;
      int vApproved = 0;
      for (final s in vScreenings) {
        if (s.reviewStatus == ReviewStatus.pending) {
          vPending++;
        } else if (s.reviewStatus == ReviewStatus.approved) {
          vApproved++;
        }
      }

      comparisons.add(
        VillageComparisonSummary(
          village: village,
          totalPatients: vTotal,
          screenedPatientsCount: vScreenedCount,
          screeningCoveragePercentage: vCoveragePct,
          highRiskPatientsCount: vHighRiskCount,
          pendingReviewCount: vPending,
          approvedReviewCount: vApproved,
        ),
      );
    }

    // Sort comparisons according to sortOrder
    _sortVillageComparisons(comparisons, sortOrder);

    return VillageAnalytics(
      selectedVillageId: isSpecificVillage ? selectedVillageId : null,
      selectedVillageName: selectedVillageName,
      totalVillagesCount: villages.length,
      totalPatients: totalPatients,
      screenedPatientsCount: screenedPatientsCount,
      totalScreeningsCount: totalScreeningsCount,
      screeningCoveragePercentage: coveragePct,
      highRiskPatientsCount: highRiskPatients.length,
      pendingReviewsCount: pendingReviews,
      approvedReviewsCount: approvedReviews,
      diseaseBreakdowns: diseaseBreakdowns,
      demographics: demographics,
      villageComparisons: comparisons,
      highRiskPriorityQueue: highRiskPatients,
      sortOrder: sortOrder,
    );
  }

  static void _sortVillageComparisons(
    List<VillageComparisonSummary> comparisons,
    AnalyticsSortOrder sortOrder,
  ) {
    int parseVillageNum(Village v) => int.tryParse(v.villageNumber) ?? 0;

    switch (sortOrder) {
      case AnalyticsSortOrder.highRiskDesc:
        comparisons.sort((a, b) {
          final cmp = b.highRiskPatientsCount.compareTo(
            a.highRiskPatientsCount,
          );
          if (cmp != 0) return cmp;
          return parseVillageNum(
            a.village,
          ).compareTo(parseVillageNum(b.village));
        });
        break;

      case AnalyticsSortOrder.screeningCoverageDesc:
        comparisons.sort((a, b) {
          final cmp = b.screeningCoveragePercentage.compareTo(
            a.screeningCoveragePercentage,
          );
          if (cmp != 0) return cmp;
          return parseVillageNum(
            a.village,
          ).compareTo(parseVillageNum(b.village));
        });
        break;

      case AnalyticsSortOrder.patientCountDesc:
        comparisons.sort((a, b) {
          final cmp = b.totalPatients.compareTo(a.totalPatients);
          if (cmp != 0) return cmp;
          return parseVillageNum(
            a.village,
          ).compareTo(parseVillageNum(b.village));
        });
        break;

      case AnalyticsSortOrder.villageNumberAsc:
        comparisons.sort(
          (a, b) =>
              parseVillageNum(a.village).compareTo(parseVillageNum(b.village)),
        );
        break;
    }
  }
}
