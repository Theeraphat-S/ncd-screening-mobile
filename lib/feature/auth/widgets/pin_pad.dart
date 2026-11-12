import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ncd_screening_mobile/domain/services/pin_service.dart';
import 'package:ncd_screening_mobile/shared/tokens/p_colors.dart';

/// 6-digit PIN entry with a large on-screen keypad.
///
/// Calls [onCompleted] once six digits are entered and then clears itself so
/// the pad can be reused after a wrong attempt.
class PinPad extends StatefulWidget {
  final ValueChanged<String> onCompleted;
  final bool enabled;
  final String? errorText;

  /// Optional extra key shown bottom-left (e.g. a biometric button).
  final Widget? leadingAction;

  const PinPad({
    super.key,
    required this.onCompleted,
    this.enabled = true,
    this.errorText,
    this.leadingAction,
  });

  @override
  State<PinPad> createState() => _PinPadState();
}

class _PinPadState extends State<PinPad> {
  String _entered = '';

  void _onDigit(String digit) {
    if (!widget.enabled || _entered.length >= PinService.pinLength) return;
    HapticFeedback.selectionClick();
    final next = _entered + digit;
    if (next.length == PinService.pinLength) {
      setState(() => _entered = '');
      widget.onCompleted(next);
    } else {
      setState(() => _entered = next);
    }
  }

  void _onBackspace() {
    if (!widget.enabled || _entered.isEmpty) return;
    setState(() => _entered = _entered.substring(0, _entered.length - 1));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(PinService.pinLength, (i) {
            final filled = i < _entered.length;
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: filled ? PColor.primaryColor : Colors.transparent,
                border: Border.all(color: PColor.primaryColor, width: 1.6),
              ),
              // Keyed child (not the dot itself): sibling keys must be unique.
              child: filled ? const SizedBox(key: Key('pin_dot_filled')) : null,
            );
          }),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 20,
          child: widget.errorText == null
              ? null
              : Text(
                  widget.errorText!,
                  style: const TextStyle(
                    color: PColor.errorColor,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
        const SizedBox(height: 12),
        for (final row in const [
          ['1', '2', '3'],
          ['4', '5', '6'],
          ['7', '8', '9'],
        ])
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [for (final d in row) _key(d)],
            ),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 76,
                height: 64,
                child: widget.leadingAction,
              ),
              _key('0'),
              _backspaceKey(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _key(String digit) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: SizedBox(
        key: Key('pin_key_$digit'),
        width: 76,
        height: 64,
        child: Semantics(
          button: true,
          label: digit,
          excludeSemantics: true,
          child: TextButton(
            onPressed: widget.enabled ? () => _onDigit(digit) : null,
            style: TextButton.styleFrom(
              backgroundColor: PColor.primaryLight,
              foregroundColor: PColor.contentColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(
              digit,
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ),
    );
  }

  Widget _backspaceKey() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: SizedBox(
        key: const Key('pin_key_backspace'),
        width: 76,
        height: 64,
        child: IconButton(
          tooltip: 'ลบ',
          onPressed: widget.enabled ? _onBackspace : null,
          icon: const Icon(Icons.backspace_outlined, size: 26),
        ),
      ),
    );
  }
}
