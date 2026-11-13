import 'package:flutter/material.dart';
import 'package:ncd_screening_mobile/domain/models/ncd_models.dart';
import 'package:ncd_screening_mobile/domain/models/village_analytics.dart';
import 'package:ncd_screening_mobile/feature/patient/pages/patient_detail_page.dart';
import 'package:ncd_screening_mobile/shared/tokens/p_colors.dart';
import 'package:ncd_screening_mobile/shared/tokens/p_radius.dart';
import 'package:ncd_screening_mobile/shared/tokens/p_typography.dart';
import 'package:ncd_screening_mobile/shared/tokens/p_spacing.dart';

class HighRiskQueueList extends StatelessWidget {
  final List<HighRiskPriorityPatient> queue;
  final Nurse nurse;

  const HighRiskQueueList({
    super.key,
    required this.queue,
    required this.nurse,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(PSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(PRadius.lg),
        boxShadow: [
          BoxShadow(
            color: PColor.contentColor.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(PSpacing.xs),
                    decoration: const BoxDecoration(
                      color: PColor.riskHighBg,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.priority_high_rounded,
                      color: PColor.errorColor,
                      size: 18,
                    ),
                  ),
                  PSpacing.gapHorizontalSm,
                  const Text(
                    'กลุ่มเสี่ยงสูงที่ต้องติดตามเร่งด่วน',
                    style: PTypography.sectionHeader,
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: PSpacing.sm, vertical: PSpacing.xs),
                decoration: BoxDecoration(
                  color: queue.isEmpty
                      ? PColor.riskLowBg
                      : PColor.riskHighBg,
                  borderRadius: BorderRadius.circular(PRadius.md),
                ),
                child: Text(
                  '${queue.length} คน',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: queue.isEmpty
                        ? PColor.riskLow
                        : PColor.errorColor,
                  ),
                ),
              ),
            ],
          ),
          PSpacing.gapVerticalXs,
          const Text(
            'ผู้ป่วยที่มีผลคัดกรองความเสี่ยงระดับสูง กดเพื่อดูรายละเอียดหรือวางแผนลงพื้นที่',
            style: PTypography.micro,
          ),
          const Divider(height: 20),
          if (queue.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: PSpacing.xl),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.check_circle_outline_rounded,
                        color: PColor.riskLow, size: 40),
                    PSpacing.gapVerticalSm,
                    Text(
                      'ไม่พบผู้ป่วยกลุ่มเสี่ยงสูงในพื้นที่ที่เลือก',
                      style: PTypography.bodyMuted,
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: queue.length,
              separatorBuilder: (_, __) => PSpacing.gapVerticalMd,
              itemBuilder: (context, index) {
                final item = queue[index];
                return _buildHighRiskPatientCard(context, item);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildHighRiskPatientCard(
    BuildContext context,
    HighRiskPriorityPatient item,
  ) {
    final patient = item.patient;
    final village = item.village;
    final date = item.latestScreeningDate;
    final dateStr =
        '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year + 543}';

    return Container(
      decoration: BoxDecoration(
        color: PColor.backgroundColor,
        borderRadius: BorderRadius.circular(PRadius.md),
        border: Border.all(
          color: PColor.errorColor.withValues(alpha: 0.25),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(PRadius.md),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PatientDetailPage(
                  patient: patient,
                  nurse: nurse,
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(PSpacing.md),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  radius: 20,
                  backgroundColor: PColor.riskHighBg,
                  child: Icon(Icons.person_rounded,
                      color: PColor.errorColor, size: 22),
                ),
                PSpacing.gapHorizontalMd,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              patient.fullName,
                              style: PTypography.cardTitle,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            'ตรวจ: $dateStr',
                            style: PTypography.micro,
                          ),
                        ],
                      ),
                      PSpacing.gapVerticalXs,
                      Text(
                        'อายุ ${patient.age} ปี • ${patient.patientGender} • ${village != null ? 'หมู่ ${village.villageNumber} ${village.villageName}' : ''}',
                        style: PTypography.micro,
                      ),
                      PSpacing.gapVerticalSm,

                      // Risk chips
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: item.highRiskDiseases.map((d) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: PSpacing.sm, vertical: PSpacing.xs),
                            decoration: BoxDecoration(
                              color: PColor.errorColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(PRadius.sm),
                              border: Border.all(
                                color: PColor.errorColor.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Text(
                              'เสี่ยงสูง: $d',
                              style: PTypography.microError,
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                PSpacing.gapHorizontalSm,
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: PColor.textNeutralColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
