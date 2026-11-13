import 'package:flutter/material.dart';

enum LeaveChoice { stay, keepDraft, discard }

/// Asked when the VHV leaves a form that still holds input.
Future<LeaveChoice> askLeaveForm(BuildContext context) async {
  final choice = await showDialog<LeaveChoice>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('ออกจากแบบฟอร์มคัดกรอง?'),
      content: const Text(
        'ข้อมูลที่กรอกถูกเก็บเป็นฉบับร่างอัตโนมัติ สามารถกลับมากรอกต่อได้ภายใน 7 วัน',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, LeaveChoice.stay),
          child: const Text('อยู่ต่อ'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, LeaveChoice.discard),
          child: const Text('ทิ้งฉบับร่าง'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, LeaveChoice.keepDraft),
          child: const Text('ออก (เก็บไว้)'),
        ),
      ],
    ),
  );
  return choice ?? LeaveChoice.stay;
}

/// Lists out-of-the-ordinary values; true means "save anyway".
Future<bool> confirmAbnormalValues(
  BuildContext context,
  Iterable<String> warnings,
) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('ค่าที่กรอกผิดปกติ'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final w in warnings)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text('• $w'),
            ),
          const SizedBox(height: 4),
          const Text('ตรวจสอบค่าอีกครั้งก่อนบันทึก หรือยืนยันหากวัดซ้ำแล้ว'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('ตรวจสอบอีกครั้ง'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('ยืนยันและบันทึก'),
        ),
      ],
    ),
  );
  return ok ?? false;
}
