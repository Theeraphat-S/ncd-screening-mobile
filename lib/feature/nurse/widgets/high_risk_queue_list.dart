import 'package:flutter/material.dart';
import 'package:ncd_screening_mobile/domain/models/ncd_models.dart';
import 'package:ncd_screening_mobile/domain/models/village_analytics.dart';
import 'package:ncd_screening_mobile/feature/patient/pages/patient_detail_page.dart';
import 'package:ncd_screening_mobile/shared/tokens/p_colors.dart';

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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
                    padding: const EdgeInsets.all(4),
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
                  const SizedBox(width: 8),
                  const Text(
                    'กลุ่มเสี่ยงสูงที่ต้องติดตามเร่งด่วน',
                    style: TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.bold,
                      color: PColor.contentColor,
                    ),
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: queue.isEmpty
                      ? PColor.riskLowBg
                      : PColor.riskHighBg,
                  borderRadius: BorderRadius.circular(10),
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
          const SizedBox(height: 4),
          const Text(
            'ผู้ป่วยที่มีผลคัดกรองความเสี่ยงระดับสูง กดเพื่อดูรายละเอียดหรือวางแผนลงพื้นที่',
            style: TextStyle(fontSize: 11.5, color: PColor.textNeutralColor),
          ),
          const Divider(height: 20),
          if (queue.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.check_circle_outline_rounded,
                        color: PColor.riskLow, size: 40),
                    SizedBox(height: 8),
                    Text(
                      'ไม่พบผู้ป่วยกลุ่มเสี่ยงสูงในพื้นที่ที่เลือก',
                      style: TextStyle(
                        fontSize: 13.5,
                        color: PColor.textNeutralColor,
                      ),
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
              separatorBuilder: (_, __) => const SizedBox(height: 10),
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
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: PColor.errorColor.withValues(alpha: 0.25),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
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
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  radius: 20,
                  backgroundColor: PColor.riskHighBg,
                  child: Icon(Icons.person_rounded,
                      color: PColor.errorColor, size: 22),
                ),
                const SizedBox(width: 12),
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
                              style: const TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.bold,
                                color: PColor.contentColor,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            'ตรวจ: $dateStr',
                            style: const TextStyle(
                              fontSize: 11,
                              color: PColor.textNeutralColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'อายุ ${patient.age} ปี • ${patient.patientGender} • ${village != null ? 'หมู่ ${village.villageNumber} ${village.villageName}' : ''}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: PColor.textNeutralColor,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Risk chips
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: item.highRiskDiseases.map((d) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: PColor.errorColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: PColor.errorColor.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Text(
                              'เสี่ยงสูง: $d',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: PColor.errorColor,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
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
