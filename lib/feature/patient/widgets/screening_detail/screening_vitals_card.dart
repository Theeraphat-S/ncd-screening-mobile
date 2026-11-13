import 'package:flutter/material.dart';
import 'package:ncd_screening_mobile/domain/models/ncd_models.dart';
import 'package:ncd_screening_mobile/shared/tokens/tokens.dart';

/// Card widget displaying clinical vitals and physical measurement metrics.
class ScreeningVitalsCard extends StatelessWidget {
  final Screening screening;

  const ScreeningVitalsCard({super.key, required this.screening});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: PRadius.borderMd,
        side: const BorderSide(color: PColor.borderSubtle),
      ),
      child: Padding(
        padding: PSpacing.edgeInsetsAllLg,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'ข้อมูลสัญญาณชีพและร่างกาย',
              style: PTypography.cardTitle,
            ),
            const Divider(height: 20),
            _buildMetricRow(
              'น้ำหนัก',
              '${screening.weight.toStringAsFixed(1)} กก.',
            ),
            _buildMetricRow(
              'ส่วนสูง',
              '${screening.height.toStringAsFixed(1)} ซม.',
            ),
            _buildMetricRow('BMI', '${screening.bmi.toStringAsFixed(1)} kg/m²'),
            _buildMetricRow(
              'รอบเอว',
              '${screening.waistCm.toStringAsFixed(1)} ซม.',
            ),
            _buildMetricRow(
              'ความดันโลหิต',
              '${screening.sbp.toInt()}/${screening.dbp.toInt()} mmHg',
            ),
            _buildMetricRow('ชีพจร', '${screening.pulse.toInt()} ครั้ง/นาที'),
            _buildMetricRow(
              'น้ำตาลในเลือด',
              screening.bloodSugar == null
                  ? 'ไม่ได้ตรวจ'
                  : '${screening.bloodSugar!.toStringAsFixed(1)} mg/dL',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: PSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: Text(label, style: PTypography.bodyMuted)),
          PSpacing.gapHorizontalMd,
          // Flexible + end alignment: at large system text the value wraps
          // instead of overflowing the card.
          Flexible(
            child: Text(
              value,
              style: PTypography.bodyBold,
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
