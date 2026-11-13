import 'package:flutter/material.dart';

/// Yes/no confirmation. The safe choice is the plain text button and the
/// action the user asked for is the filled one; returns false if dismissed.
Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  required String cancelLabel,
}) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: Text(cancelLabel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return ok ?? false;
}

/// Asked before leaving a form that holds unsaved input.
Future<bool> confirmDiscardChanges(BuildContext context) => showConfirmDialog(
      context,
      title: 'ออกโดยไม่บันทึก?',
      message: 'ข้อมูลที่กรอกไว้ยังไม่ได้บันทึก และจะหายไปหากออกจากหน้านี้',
      confirmLabel: 'ออกโดยไม่บันทึก',
      cancelLabel: 'กรอกต่อ',
    );

/// Asked before ending the session from a home page.
Future<bool> confirmSignOut(BuildContext context) => showConfirmDialog(
      context,
      title: 'ออกจากระบบ?',
      message: 'ต้องเข้าสู่ระบบใหม่อีกครั้งเพื่อใช้งานต่อ',
      confirmLabel: 'ออกจากระบบ',
      cancelLabel: 'ยกเลิก',
    );
