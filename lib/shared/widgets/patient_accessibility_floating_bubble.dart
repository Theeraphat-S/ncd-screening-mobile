import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ncd_screening_mobile/shared/bloc/accessibility/accessibility_cubit.dart';
import 'package:ncd_screening_mobile/shared/tokens/p_colors.dart';

class PatientAccessibilityFloatingBubble extends StatefulWidget {
  const PatientAccessibilityFloatingBubble({super.key});

  @override
  State<PatientAccessibilityFloatingBubble> createState() =>
      _PatientAccessibilityFloatingBubbleState();
}

class _PatientAccessibilityFloatingBubbleState
    extends State<PatientAccessibilityFloatingBubble> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AccessibilityCubit, AccessibilityState>(
      builder: (context, state) {
        final isHC = state.isHighContrast;
        final bubbleBg = isHC ? PColor.hcAccent : PColor.primaryColor;
        final iconColor = isHC ? Colors.black : PColor.neutralColor;

        return Positioned(
          right: 16,
          bottom: 16,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (_isExpanded) ...[
                Container(
                  width: 300,
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isHC ? PColor.hcSurface : PColor.neutralColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isHC ? PColor.hcAccent : PColor.borderSubtle,
                      width: isHC ? 2 : 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(
                          alpha: isHC ? 0.6 : 0.15,
                        ),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Icon(
                                  Icons.accessibility_new_rounded,
                                  size: 20,
                                  color: isHC
                                      ? PColor.hcAccent
                                      : PColor.primaryColor,
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    'ปรับการแสดงผล',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: isHC
                                          ? PColor.hcText
                                          : PColor.contentColor,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            tooltip: 'ปิด',
                            key: const Key('bubble_close_button'),
                            icon: Icon(
                              Icons.close_rounded,
                              size: 20,
                              color: isHC ? Colors.white70 : Colors.grey,
                            ),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () {
                              setState(() {
                                _isExpanded = false;
                              });
                            },
                          ),
                        ],
                      ),
                      const Divider(height: 20),
                      // Large Font / Elderly Mode Toggle
                      SwitchListTile.adaptive(
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        title: Text(
                          'โหมดตัวโต (ผู้สูงอายุ)',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isHC ? PColor.hcText : PColor.contentColor,
                          ),
                        ),
                        value: state.isElderlyMode,
                        activeTrackColor: isHC
                            ? PColor.hcAccent
                            : PColor.primaryColor,
                        onChanged: (val) {
                          context.read<AccessibilityCubit>().setElderlyMode(
                            val,
                          );
                        },
                      ),
                      // High Contrast Mode Toggle
                      SwitchListTile.adaptive(
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        title: Text(
                          'โหมดคอนทราสต์สูง (AAA)',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isHC ? PColor.hcText : PColor.contentColor,
                          ),
                        ),
                        value: state.isHighContrast,
                        activeTrackColor: isHC
                            ? PColor.hcAccent
                            : PColor.primaryColor,
                        onChanged: (_) {
                          context
                              .read<AccessibilityCubit>()
                              .toggleHighContrast();
                        },
                      ),
                      const SizedBox(height: 8),
                      // Font Scale Fine Tuning
                      Text(
                        'ขนาดตัวอักษร: ${(state.textScaleFactor * 100).round()}%',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: isHC ? Colors.white70 : PColor.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => context
                                  .read<AccessibilityCubit>()
                                  .decreaseTextScale(),
                              icon: const Icon(
                                Icons.text_decrease_rounded,
                                size: 16,
                              ),
                              label: Semantics(
                                excludeSemantics: true,
                                label: 'ลดขนาดตัวอักษร',
                                child: const Text('A-'),
                              ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: isHC
                                    ? PColor.hcAccent
                                    : PColor.primaryColor,
                                side: BorderSide(
                                  color: isHC
                                      ? PColor.hcAccent
                                      : PColor.borderStrong,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => context
                                  .read<AccessibilityCubit>()
                                  .increaseTextScale(),
                              icon: const Icon(
                                Icons.text_increase_rounded,
                                size: 16,
                              ),
                              label: Semantics(
                                excludeSemantics: true,
                                label: 'เพิ่มขนาดตัวอักษร',
                                child: const Text('A+'),
                              ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: isHC
                                    ? PColor.hcAccent
                                    : PColor.primaryColor,
                                side: BorderSide(
                                  color: isHC
                                      ? PColor.hcAccent
                                      : PColor.borderStrong,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      // Reset Button
                      Center(
                        child: TextButton.icon(
                          onPressed: () => context
                              .read<AccessibilityCubit>()
                              .resetAccessibility(),
                          icon: Icon(
                            Icons.refresh_rounded,
                            size: 14,
                            color: isHC ? Colors.white70 : Colors.grey,
                          ),
                          label: Text(
                            'รีเซ็ตค่ามาตรฐาน',
                            style: TextStyle(
                              fontSize: 12,
                              color: isHC ? Colors.white70 : Colors.grey[700],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              // Floating Trigger Button
              FloatingActionButton(
                heroTag: 'patient_accessibility_bubble_fab',
                mini: true,
                elevation: 4,
                backgroundColor: bubbleBg,
                foregroundColor: iconColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: isHC
                      ? const BorderSide(color: PColor.neutralColor, width: 2)
                      : BorderSide.none,
                ),
                tooltip: 'ปรับขนาดอักษรและความคมชัด (Accessibility)',
                onPressed: () {
                  setState(() {
                    _isExpanded = !_isExpanded;
                  });
                },
                child: Icon(
                  _isExpanded
                      ? Icons.close_rounded
                      : Icons.accessibility_new_rounded,
                  size: 22,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
