import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ncd_screening_mobile/domain/models/ncd_models.dart';
import 'package:ncd_screening_mobile/feature/auth/bloc/auth_bloc.dart';
import 'package:ncd_screening_mobile/feature/auth/session_flow.dart';
import 'package:ncd_screening_mobile/shared/tokens/tokens.dart';
import 'package:ncd_screening_mobile/shared/utils/form_validators.dart';
import 'package:ncd_screening_mobile/shared/utils/thai_birth_date.dart';
import 'package:ncd_screening_mobile/shared/widgets/app_feedback.dart';
import 'package:ncd_screening_mobile/shared/widgets/app_text_field.dart';

class LoginPage extends StatefulWidget {
  final UserRole role;

  const LoginPage({super.key, required this.role});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _idController = TextEditingController();
  final _passwordController = TextEditingController();
  final _dayController = TextEditingController();
  final _monthController = TextEditingController();
  final _yearController = TextEditingController();
  bool _obscurePassword = true;
  bool _showErrorsAsYouType = false;

  /// Birth date is one answer spread over three boxes, so it gets one message.
  String? _birthDateError;

  /// Rejection from the sign-in itself (unknown user, wrong password).
  String? _authError;

  @override
  void initState() {
    super.initState();
    // Demo credentials are pre-filled in debug builds only, never in release.
    if (kDebugMode) {
      if (widget.role == UserRole.patient) {
        _idController.text = '1234567890121';
        _dayController.text = '1';
        _monthController.text = '2';
        _yearController.text = '2523';
      } else if (widget.role == UserRole.vhv) {
        _idController.text = '1111111111111';
        _passwordController.text = 'password123';
      } else if (widget.role == UserRole.nurse) {
        _idController.text = 'NUR001';
        _passwordController.text = 'password123';
      }
    }
  }

  @override
  void dispose() {
    _idController.dispose();
    _passwordController.dispose();
    _dayController.dispose();
    _monthController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  bool get _isPatient => widget.role == UserRole.patient;
  bool get _isNurse => widget.role == UserRole.nurse;

  String get _title {
    switch (widget.role) {
      case UserRole.patient:
        return 'เข้าสู่ระบบ (บุคคลทั่วไป)';
      case UserRole.vhv:
        return 'เข้าสู่ระบบ อสม.';
      case UserRole.nurse:
        return 'เข้าสู่ระบบพยาบาล';
    }
  }

  String get _idLabel => _isNurse ? 'รหัสพยาบาล' : 'เลขบัตรประชาชน';

  String get _idHint => _isNurse ? 'เช่น NUR001' : 'ตัวเลข 13 หลัก';

  String? _validateId(String? value) {
    switch (widget.role) {
      case UserRole.patient:
        return FormValidators.citizenId(value);
      case UserRole.vhv:
        return FormValidators.citizenId(value, checkDigit: false);
      case UserRole.nurse:
        final v = value?.trim() ?? '';
        if (v.isEmpty) return 'กรุณากรอกรหัสพยาบาล';
        if (v.length < 4) return 'รหัสพยาบาลต้องมี 4 ตัวอักษรขึ้นไป';
        return null;
    }
  }

  DateTime? _parseBirthDate() => parseThaiBirthDate(
        day: _dayController.text,
        month: _monthController.text,
        yearBe: _yearController.text,
      );

  void _handleLogin() {
    FocusScope.of(context).unfocus();
    final fieldsValid = _formKey.currentState!.validate();
    final birthDate = _isPatient ? _parseBirthDate() : null;
    final birthDateError = _isPatient && birthDate == null
        ? 'กรุณากรอกวัน เดือน ปีเกิด (พ.ศ.) ให้ถูกต้อง เช่น 1 / 2 / 2523'
        : null;

    setState(() {
      _showErrorsAsYouType = true;
      _birthDateError = birthDateError;
      _authError = null;
    });
    if (!fieldsValid || birthDateError != null) return;

    final password = _passwordController.text;
    context.read<AuthBloc>().add(
          AuthLoginSubmitted(
            role: widget.role,
            identifier: _idController.text.trim(),
            password: password.isNotEmpty ? password : null,
            birthDate: birthDate,
          ),
        );
  }

  /// Once a message is showing, re-check as the user corrects the boxes.
  void _onBirthDateChanged(String _) {
    if (_birthDateError == null) return;
    if (_parseBirthDate() != null) setState(() => _birthDateError = null);
  }

  Widget _dobField(
    TextEditingController controller,
    String label,
    String hint,
    int maxLen, {
    TextInputAction action = TextInputAction.next,
  }) {
    return AppTextField(
      label: label,
      hint: hint,
      controller: controller,
      keyboardType: TextInputType.number,
      textInputAction: action,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      maxLength: maxLen,
      onChanged: _onBirthDateChanged,
      onFieldSubmitted:
          action == TextInputAction.done ? (_) => _handleLogin() : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (prev, curr) => prev.status != curr.status,
      listener: (context, state) {
        if (state.status == AuthStatus.error) {
          setState(
            () => _authError = state.errorMessage ?? 'เข้าสู่ระบบไม่สำเร็จ',
          );
        } else if (state.status == AuthStatus.authenticated &&
            state.currentUser != null) {
          completeLogin(context, widget.role, state.currentUser);
        }
      },
      child: Scaffold(
        appBar: AppBar(title: Text(_title)),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: PSpacing.xxl,
                vertical: PSpacing.xxxl,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Container(
                  padding: const EdgeInsets.all(PSpacing.xxl),
                  decoration: BoxDecoration(
                    color: scheme.surface,
                    borderRadius: BorderRadius.circular(PRadius.xl),
                    border: Border.all(
                      color: isDark ? PColor.hcAccent : PColor.borderSubtle,
                      width: isDark ? 2 : 1,
                    ),
                    boxShadow: isDark ? null : PShadow.card,
                  ),
                  child: Form(
                    key: _formKey,
                    autovalidateMode: _showErrorsAsYouType
                        ? AutovalidateMode.onUserInteraction
                        : AutovalidateMode.disabled,
                    child: AutofillGroup(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Center(
                            child: Container(
                              width: 72,
                              height: 72,
                              decoration: BoxDecoration(
                                color: PColor.primaryLight,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: PColor.primaryColor
                                      .withValues(alpha: 0.2),
                                ),
                              ),
                              child: Icon(
                                _isPatient
                                    ? Icons.person_rounded
                                    : _isNurse
                                        ? Icons.medical_services_rounded
                                        : Icons.volunteer_activism_rounded,
                                size: 36,
                                color: PColor.primaryColor,
                              ),
                            ),
                          ),
                          PSpacing.gapVerticalXl,
                          Text(
                            _title,
                            textAlign: TextAlign.center,
                            style: PTypography.pageTitle
                                .copyWith(color: scheme.onSurface),
                          ),
                          PSpacing.gapVerticalSm,
                          Text(
                            _isPatient
                                ? 'กรุณากรอกเลขบัตรประชาชนและวันเกิดเพื่อยืนยันตัวตน'
                                : 'กรุณากรอกข้อมูลเพื่อเข้าสู่ระบบการทำงาน',
                            textAlign: TextAlign.center,
                            style: PTypography.bodyMuted
                                .copyWith(color: scheme.onSurfaceVariant),
                          ),
                          PSpacing.gapVerticalXxl,
                          AppTextField(
                            label: _idLabel,
                            hint: _idHint,
                            controller: _idController,
                            keyboardType: _isNurse
                                ? TextInputType.text
                                : TextInputType.number,
                            inputFormatters: _isNurse
                                ? null
                                : [FilteringTextInputFormatter.digitsOnly],
                            maxLength: _isNurse ? null : 13,
                            autofillHints: const [AutofillHints.username],
                            prefixIcon: Icon(
                              Icons.badge_outlined,
                              color: scheme.primary,
                            ),
                            validator: _validateId,
                          ),
                          PSpacing.gapVerticalLg,
                          if (_isPatient)
                            ..._buildBirthDateFields()
                          else
                            AppTextField(
                              label: 'รหัสผ่าน',
                              hint: '4-16 ตัวอักษร',
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              textInputAction: TextInputAction.done,
                              autofillHints: const [AutofillHints.password],
                              prefixIcon: Icon(
                                Icons.lock_outline_rounded,
                                color: scheme.primary,
                              ),
                              suffixIcon: IconButton(
                                tooltip: _obscurePassword
                                    ? 'แสดงรหัสผ่าน'
                                    : 'ซ่อนรหัสผ่าน',
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                ),
                                onPressed: () => setState(
                                  () => _obscurePassword = !_obscurePassword,
                                ),
                              ),
                              validator: FormValidators.password,
                              onFieldSubmitted: (_) => _handleLogin(),
                            ),
                          PSpacing.gapVerticalXxl,
                          if (_authError != null) ...[
                            InlineAlert(_authError!),
                            PSpacing.gapVerticalMd,
                          ],
                          BlocBuilder<AuthBloc, AuthState>(
                            builder: (context, state) {
                              final isLoading =
                                  state.status == AuthStatus.loading;
                              return ElevatedButton(
                                onPressed: isLoading ? null : _handleLogin,
                                child: isLoading
                                    ? const SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                        ),
                                      )
                                    : const Text('เข้าสู่ระบบ'),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildBirthDateFields() {
    return [
      const AppFieldLabel('วันเกิด (พ.ศ.)'),
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: _dobField(_dayController, 'วัน', '1', 2)),
          PSpacing.gapHorizontalSm,
          Expanded(child: _dobField(_monthController, 'เดือน', '2', 2)),
          PSpacing.gapHorizontalSm,
          Expanded(
            flex: 2,
            child: _dobField(
              _yearController,
              'ปี พ.ศ.',
              '2523',
              4,
              action: TextInputAction.done,
            ),
          ),
        ],
      ),
      if (_birthDateError != null)
        Semantics(
          liveRegion: true,
          child: Padding(
            padding: const EdgeInsets.only(top: PSpacing.sm),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  size: 18,
                  color: PColor.errorColor,
                ),
                PSpacing.gapHorizontalXs,
                Expanded(
                  child: Text(_birthDateError!, style: PTypography.fieldError),
                ),
              ],
            ),
          ),
        ),
    ];
  }
}
