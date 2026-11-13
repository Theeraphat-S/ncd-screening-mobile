import 'package:flutter/material.dart';
import 'package:ncd_screening_mobile/domain/models/ncd_models.dart';
import 'package:ncd_screening_mobile/domain/services/ncd_lifestyle_advisor.dart';
import 'package:ncd_screening_mobile/shared/tokens/tokens.dart';
import 'package:ncd_screening_mobile/shared/widgets/elderly_bento_advice_card.dart';

/// Section widget displaying plain-Thai lifestyle guidance tailored for elderly & patients.
class ScreeningLifestyleGuidanceSection extends StatelessWidget {
  final Screening screening;
  final List<ScreeningResult>? results;

  const ScreeningLifestyleGuidanceSection({
    super.key,
    required this.screening,
    this.results,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveResults = results ?? screening.results;
    final adviceList = NcdLifestyleAdvisor.generateAdviceList(
      screening: screening,
      results: effectiveResults,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Plain Thai Lifestyle Guidance Header (Elderly Friendly)
        Container(
          padding: const EdgeInsets.all(PSpacing.lg),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [PColor.primaryDark, PColor.primaryColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: PRadius.borderCard,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(PSpacing.sm),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.health_and_safety_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              PSpacing.gapHorizontalMd,
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'คู่มือการปฏิบัติตัวและอาหารสุขภาพ',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'คำแนะนำเข้าใจง่ายสำหรับประชาชนและผู้สูงอายุ',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        PSpacing.gapVerticalMd,

        // Personalized Bento Guidance Cards
        ...adviceList.map((adv) => ElderlyBentoAdviceCard(advice: adv)),
      ],
    );
  }
}
