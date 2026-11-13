import 'package:flutter/material.dart';
import 'package:ncd_screening_mobile/shared/tokens/p_colors.dart';
import 'package:ncd_screening_mobile/shared/tokens/p_typography.dart';
import 'package:ncd_screening_mobile/shared/tokens/p_radius.dart';
import 'package:ncd_screening_mobile/shared/tokens/p_spacing.dart';

/// White card with an icon + title header, used for each part of the form.
class ScreeningSectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const ScreeningSectionCard({
    super.key,
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(PSpacing.xl),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(PRadius.xl),
        border: Border.all(color: PColor.borderSubtle),
        boxShadow: PShadow.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(PSpacing.sm),
                decoration: BoxDecoration(
                  color: PColor.primaryLight,
                  borderRadius: BorderRadius.circular(PRadius.md),
                ),
                child: Icon(icon, color: PColor.primaryColor, size: 20),
              ),
              PSpacing.gapHorizontalMd,
              Expanded(child: Text(title, style: PTypography.sectionHeader)),
            ],
          ),
          const Divider(height: 24, color: PColor.borderSubtle),
          // Lets ListTile ink show through the card's decoration.
          Material(type: MaterialType.transparency, child: child),
        ],
      ),
    );
  }
}
