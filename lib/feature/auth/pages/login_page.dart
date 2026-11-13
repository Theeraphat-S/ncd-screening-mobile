import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ncd_screening_mobile/domain/services/citizen_id.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ncd_screening_mobile/domain/models/ncd_models.dart';
import 'package:ncd_screening_mobile/feature/auth/bloc/auth_bloc.dart';
import 'package:ncd_screening_mobile/feature/auth/session_flow.dart';
import 'package:ncd_screening_mobile/shared/tokens/p_colors.dart';
import 'package:ncd_screening_mobile/shared/tokens/p_typography.dart';
import 'package:ncd_screening_mobile/shared/utils/thai_birth_date.dart';

class LoginPage extends StatefulWidget {
  final UserRole role;

  const LoginPage({super.key, required this.role});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _idController = TextEditingController();
  final _passwordController = TextEditingController();
  final _dayController = TextEditingController();
  final _monthController = TextEditingController();
  final _yearController = TextEditingController();
  bool _obscurePassword = true;

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

  String get _idLabel {
    switch (widget.role) {
      case UserRole.patient:
        return 'เลขบัตรประชาชน 13 หลัก';
      case UserRole.vhv:
        return 'รหัสบัตรประชาชน (13 หลัก)';
      case UserRole.nurse:
        return 'Nurse ID / รหัสพยาบาล';
    }
  }

  String get _idHint {
    switch (widget.role) {
      case UserRole.patient:
        return 'กรอกเลขบัตรประชาชน';
      case UserRole.vhv:
        return 'กรอกเลขบัตรประชาชน 13 หลัก';
      case UserRole.nurse:
        return 'กรอกรหัสพยาบาล (เช่น NUR001)';
    }
  }

  void _handleLogin() {
    final id = _idController.text.trim();
    final password = _passwordController.text;

    // Front-end validations per SRS
    if (id.isEmpty) {
      _showWarning('กรุณากรอกข้อมูลให้ถูกต้อง');
      return;
    }

    DateTime? birthDate;
    if (widget.role == UserRole.patient) {
      if (id.length != 13 || int.tryParse(id) == null) {
        _showWarning('รหัสบัตรประชาชนต้องเป็นตัวเลขความยาว 13 หลัก');
        return;
      }
      if (!CitizenId.isValid(id)) {
        _showWarning('เลขบัตรประชาชนไม่ถูกต้อง กรุณาตรวจสอบตัวเลขอีกครั้ง');
        return;
      }
      birthDate = parseThaiBirthDate(
        day: _dayController.text,
        month: _monthController.text,
        yearBe: _yearController.text,
      );
      if (birthDate == null) {
        _showWarning('กรุณากรอกวัน เดือน ปีเกิด (พ.ศ.) ให้ถูกต้อง');
        return;
      }
    } else if (widget.role == UserRole.vhv) {
      if (id.length != 13 || int.tryParse(id) == null) {
        _showWarning('รหัสบัตรประชาชนต้องเป็นตัวเลขความยาว 13 หลัก');
        return;
      }
      if (password.isEmpty || password.length < 4 || password.length > 16) {
        _showWarning('รหัสผ่านต้องมีความยาว 4-16 ตัวอักษร');
        return;
      }
    } else if (widget.role == UserRole.nurse) {
      if (id.length < 4) {
        _showWarning('รหัสพยาบาลต้องมี 4 ตัวอักษรขึ้นไป');
        return;
      }
      if (password.isEmpty || password.length < 4 || password.length > 16) {
        _showWarning('รหัสผ่านต้องมีความยาว 4-16 ตัวอักษร');
        return;
      }
    }

    context.read<AuthBloc>().add(
          AuthLoginSubmitted(
            role: widget.role,
            identifier: id,
            password: password.isNotEmpty ? password : null,
            birthDate: birthDate,
          ),
        );
  }

  void _showWarning(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: PColor.errorColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _dobField(TextEditingController controller, String hint, int maxLen) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      textAlign: TextAlign.center,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      maxLength: maxLen,
      decoration: InputDecoration(
        hintText: hint,
        counterText: '',
        filled: true,
        fillColor: PColor.backgroundColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: PColor.borderSubtle),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: PColor.borderSubtle),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: PColor.primaryColor, width: 1.5),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (prev, curr) => prev.status != curr.status,
      listener: (context, state) {
        if (state.status == AuthStatus.error) {
          _showWarning(state.errorMessage ?? 'เข้าสู่ระบบไม่สำเร็จ');
        } else if (state.status == AuthStatus.authenticated &&
            state.currentUser != null) {
          completeLogin(context, widget.role, state.currentUser);
        }
      },
      child: Scaffold(
        backgroundColor: PColor.backgroundColor,
        appBar: AppBar(
          backgroundColor: PColor.primaryColor,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            _title,
            style: PTypography.appBarTitle,
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Container(
                  padding: const EdgeInsets.all(28.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: PColor.borderSubtle),
                    boxShadow: PShadow.card,
                  ),
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
                            border: Border.all(color: PColor.primaryColor.withValues(alpha: 0.2)),
                          ),
                          child: Icon(
                            widget.role == UserRole.patient
                                ? Icons.person_rounded
                                : widget.role == UserRole.vhv
                                    ? Icons.volunteer_activism_rounded
                                    : Icons.medical_services_rounded,
                            size: 36,
                            color: PColor.primaryColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        _title,
                        textAlign: TextAlign.center,
                        style: PTypography.pageTitle,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        widget.role == UserRole.patient
                            ? 'กรุณากรอกเลขบัตรประชาชนและวันเกิดเพื่อยืนยันตัวตน'
                            : 'กรุณากรอกข้อมูลเพื่อเข้าสู่ระบบการทำงาน',
                        textAlign: TextAlign.center,
                        style: PTypography.bodyMuted,
                      ),
                      const SizedBox(height: 28),

                      // Identifier Field
                      Text(
                        _idLabel,
                        style: PTypography.labelSmall,
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _idController,
                        keyboardType: widget.role == UserRole.nurse
                            ? TextInputType.text
                            : TextInputType.number,
                        maxLength: widget.role == UserRole.nurse ? null : 13,
                        decoration: InputDecoration(
                          hintText: _idHint,
                          hintStyle: PTypography.bodyMuted,
                          filled: true,
                          fillColor: PColor.backgroundColor,
                          counterText: '',
                          prefixIcon: const Icon(Icons.badge_outlined, color: PColor.primaryColor, size: 22),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: PColor.borderSubtle),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: PColor.borderSubtle),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: PColor.primaryColor, width: 1.5),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Password Field (VHV & Nurse)
                      if (widget.role != UserRole.patient) ...[
                        const Text(
                          'รหัสผ่าน',
                          style: PTypography.labelSmall,
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            hintText: 'กรอกรหัสผ่าน',
                            hintStyle: PTypography.bodyMuted,
                            filled: true,
                            fillColor: PColor.backgroundColor,
                            prefixIcon: const Icon(Icons.lock_outline_rounded, color: PColor.primaryColor, size: 22),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                color: PColor.textNeutralColor,
                                size: 20,
                              ),
                              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: PColor.borderSubtle),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: PColor.borderSubtle),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: PColor.primaryColor, width: 1.5),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ] else ...[
                        const Text(
                          'วันเกิด (พ.ศ.)',
                          style: PTypography.labelSmall,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(child: _dobField(_dayController, 'วัน', 2)),
                            const SizedBox(width: 10),
                            Expanded(child: _dobField(_monthController, 'เดือน', 2)),
                            const SizedBox(width: 10),
                            Expanded(
                              flex: 2,
                              child: _dobField(_yearController, 'ปี พ.ศ.', 4),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Submit Button
                      BlocBuilder<AuthBloc, AuthState>(
                        builder: (context, state) {
                          final isLoading = state.status == AuthStatus.loading;
                          return SizedBox(
                            height: 48,
                            child: ElevatedButton(
                              onPressed: isLoading ? null : _handleLogin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: PColor.primaryColor,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: isLoading
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text(
                                      'เข้าสู่ระบบ',
                                      style: TextStyle(
                                        fontSize: 15.5,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: -0.2,
                                      ),
                                    ),
                            ),
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
    );
  }
}
