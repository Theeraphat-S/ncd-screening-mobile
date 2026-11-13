import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ncd_screening_mobile/domain/models/ncd_models.dart';
import 'package:ncd_screening_mobile/feature/nurse/bloc/village_bloc.dart';
import 'package:ncd_screening_mobile/feature/vhv/bloc/vhv_bloc.dart';
import 'package:ncd_screening_mobile/shared/tokens/tokens.dart';
import 'package:ncd_screening_mobile/shared/utils/form_validators.dart';
import 'package:ncd_screening_mobile/shared/widgets/app_dialogs.dart';
import 'package:ncd_screening_mobile/shared/widgets/app_feedback.dart';
import 'package:ncd_screening_mobile/shared/widgets/app_text_field.dart';

class NurseAddEditVhvPage extends StatefulWidget {
  final Nurse nurse;
  final VHV? vhv;
  final String? villageId;

  const NurseAddEditVhvPage({
    super.key,
    required this.nurse,
    this.vhv,
    this.villageId,
  });

  @override
  State<NurseAddEditVhvPage> createState() => _NurseAddEditVhvPageState();
}

class _NurseAddEditVhvPageState extends State<NurseAddEditVhvPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _citizenIdController;
  late final TextEditingController _titleController;
  late final TextEditingController _fnameController;
  late final TextEditingController _lnameController;
  late final TextEditingController _mobileController;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;

  late String _selectedVillageId;
  String _gender = 'หญิง';
  DateTime _birthDate = DateTime(1985, 1, 1);
  bool get _isEdit => widget.vhv != null;

  /// True once the user changed anything; guards against losing input.
  bool _dirty = false;
  bool _submitting = false;
  bool _obscurePassword = true;
  bool _showErrorsAsYouType = false;
  String? _formError;

  @override
  void initState() {
    super.initState();
    final v = widget.vhv;
    _selectedVillageId = v?.villageId ?? widget.villageId ?? 'V001';
    _citizenIdController = TextEditingController(text: v?.vhvCitizenId ?? '');
    _titleController = TextEditingController(text: v?.vhvTitle ?? 'นาง');
    _fnameController = TextEditingController(text: v?.vhvFname ?? '');
    _lnameController = TextEditingController(text: v?.vhvLname ?? '');
    _mobileController = TextEditingController(text: v?.vhvMobile ?? '');
    _emailController = TextEditingController(text: v?.vhvEmail ?? '');
    _passwordController = TextEditingController();
    if (v != null) {
      _gender = v.vhvGender;
      _birthDate = v.vhvBirthDate;
    }
  }

  @override
  void dispose() {
    _citizenIdController.dispose();
    _titleController.dispose();
    _fnameController.dispose();
    _lnameController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String get _birthDateText =>
      '${_birthDate.day.toString().padLeft(2, '0')}/'
      '${_birthDate.month.toString().padLeft(2, '0')}/'
      '${_birthDate.year + 543}';

  void _markDirty() {
    if (!_dirty) setState(() => _dirty = true);
  }

  Future<void> _selectBirthDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate,
      firstDate: DateTime(1940),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _birthDate = picked;
        _dirty = true;
      });
    }
  }

  void _onSave() {
    FocusScope.of(context).unfocus();
    final invalid = _formKey.currentState!.validateGranularly();
    if (invalid.isNotEmpty) {
      setState(() {
        _showErrorsAsYouType = true;
        _formError =
            'ยังบันทึกไม่ได้ กรุณาแก้ไข ${invalid.length} ช่องที่มีข้อความสีแดง';
      });
      Scrollable.ensureVisible(
        invalid.first.context,
        alignment: 0.2,
        duration: PDuration.normal,
      );
      return;
    }

    final title = _titleController.text.trim();
    final password = _passwordController.text;
    final newVhv = VHV(
      vhvId: widget.vhv?.vhvId ?? '',
      vhvCitizenId: _citizenIdController.text.trim(),
      vhvTitle: title.isNotEmpty ? title : (_gender == 'ชาย' ? 'นาย' : 'นาง'),
      vhvFname: _fnameController.text.trim(),
      vhvLname: _lnameController.text.trim(),
      vhvMobile: _mobileController.text.trim(),
      vhvEmail: _emailController.text.trim(),
      vhvPassword: password.isNotEmpty
          ? password
          : (widget.vhv?.vhvPassword ?? 'password123'),
      vhvBirthDate: _birthDate,
      vhvGender: _gender,
      vhvAddress:
          widget.vhv?.vhvAddress ?? 'หมู่บ้าน $_selectedVillageId อ.แม่อาย',
      villageId: _selectedVillageId,
    );

    setState(() {
      _submitting = true;
      _formError = null;
    });
    context.read<VhvBloc>().add(
          _isEdit ? VhvUpdateRequested(newVhv) : VhvAddRequested(newVhv),
        );
  }

  /// The page stays open until the save is confirmed, so a failed save
  /// never throws the typed data away.
  void _onSaveResult(BuildContext context, VhvState state) {
    if (state.status == VhvStatus.success) {
      Navigator.pop(context);
      return;
    }
    setState(() {
      _submitting = false;
      _formError =
          '${state.errorMessage ?? 'บันทึกข้อมูลไม่สำเร็จ'} กรุณาตรวจสอบข้อมูลแล้วลองอีกครั้ง';
    });
  }

  Future<void> _confirmLeave() async {
    final leave = await confirmDiscardChanges(context);
    if (leave && mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<VhvBloc, VhvState>(
      listenWhen: (prev, curr) =>
          _submitting &&
          prev.status == VhvStatus.loading &&
          ((curr.status == VhvStatus.success && curr.message != null) ||
              curr.status == VhvStatus.failure),
      listener: _onSaveResult,
      child: PopScope(
        canPop: !_dirty,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) _confirmLeave();
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(_isEdit ? 'แก้ไขข้อมูล อสม.' : 'เพิ่ม อสม.'),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: PSpacing.edgeInsetsAllXl,
              child: Form(
                key: _formKey,
                autovalidateMode: _showErrorsAsYouType
                    ? AutovalidateMode.onUserInteraction
                    : AutovalidateMode.disabled,
                onChanged: _markDirty,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildFieldsCard(),
                    PSpacing.gapVerticalXxl,
                    if (_formError != null) ...[
                      InlineAlert(_formError!),
                      PSpacing.gapVerticalMd,
                    ],
                    ElevatedButton.icon(
                      onPressed: _submitting ? null : _onSave,
                      icon: _submitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2.5),
                            )
                          : const Icon(Icons.save_outlined),
                      label: Text(_submitting ? 'กำลังบันทึก…' : 'บันทึก'),
                    ),
                    PSpacing.gapVerticalXl,
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFieldsCard() {
    return Card(
      child: Padding(
        padding: PSpacing.edgeInsetsAllXl,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const AppFieldLabel('หมู่บ้าน'),
            BlocBuilder<VillageBloc, VillageState>(
              builder: (context, vState) {
                final villages = vState.villages.isNotEmpty
                    ? vState.villages
                    : [
                        const Village(villageId: 'V001', villageName: 'บ้านท่าตอน', villageNumber: '1'),
                        const Village(villageId: 'V002', villageName: 'บ้านใหม่หมอกจ๋าม', villageNumber: '2'),
                        const Village(villageId: 'V003', villageName: 'บ้านห้วยปู', villageNumber: '3'),
                        const Village(villageId: 'V004', villageName: 'บ้านแม่ฮ่าง', villageNumber: '4'),
                        const Village(villageId: 'V005', villageName: 'บ้านร่มไทย', villageNumber: '5'),
                      ];
                return DropdownButtonFormField<String>(
                  initialValue: _selectedVillageId,
                  isExpanded: true,
                  items: villages
                      .map((v) => DropdownMenuItem(
                            value: v.villageId,
                            child: Text(
                              'หมู่ ${v.villageNumber} ${v.villageName}',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedVillageId = val);
                  },
                );
              },
            ),
            PSpacing.gapVerticalLg,
            AppTextField(
              label: 'เลขบัตรประชาชน',
              hint: 'ตัวเลข 13 หลัก',
              controller: _citizenIdController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              maxLength: 13,
              validator: (v) => FormValidators.citizenId(v, checkDigit: false),
            ),
            PSpacing.gapVerticalLg,
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: AppTextField(
                    label: 'คำนำหน้า',
                    hint: 'นาย / นาง',
                    controller: _titleController,
                  ),
                ),
                PSpacing.gapHorizontalMd,
                Expanded(
                  flex: 5,
                  child: AppTextField(
                    label: 'ชื่อ',
                    hint: 'ชื่อจริง',
                    controller: _fnameController,
                    autofillHints: const [AutofillHints.givenName],
                    validator: (v) => FormValidators.personName(v, 'ชื่อ'),
                  ),
                ),
              ],
            ),
            PSpacing.gapVerticalLg,
            AppTextField(
              label: 'นามสกุล',
              hint: 'นามสกุล',
              controller: _lnameController,
              autofillHints: const [AutofillHints.familyName],
              validator: (v) => FormValidators.personName(v, 'นามสกุล'),
            ),
            PSpacing.gapVerticalLg,
            const AppFieldLabel('เพศ'),
            DropdownButtonFormField<String>(
              initialValue: _gender,
              isExpanded: true,
              items: const [
                DropdownMenuItem(value: 'หญิง', child: Text('หญิง')),
                DropdownMenuItem(value: 'ชาย', child: Text('ชาย')),
              ],
              onChanged: (v) {
                if (v != null) setState(() => _gender = v);
              },
            ),
            PSpacing.gapVerticalLg,
            AppPickerField(
              label: 'วันเกิด (พ.ศ.)',
              value: _birthDateText,
              icon: Icons.calendar_today_outlined,
              onTap: _selectBirthDate,
            ),
            PSpacing.gapVerticalLg,
            AppTextField(
              label: 'เบอร์มือถือ',
              hint: 'เช่น 0812345678',
              controller: _mobileController,
              keyboardType: TextInputType.phone,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              autofillHints: const [AutofillHints.telephoneNumber],
              maxLength: 10,
              validator: FormValidators.thaiMobile,
            ),
            PSpacing.gapVerticalLg,
            AppTextField(
              label: 'อีเมล',
              hint: 'เช่น vhv01@example.com',
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [AutofillHints.email],
              validator: FormValidators.email,
            ),
            PSpacing.gapVerticalLg,
            AppTextField(
              label: _isEdit ? 'รหัสผ่านใหม่' : 'รหัสผ่าน',
              hint: '4-16 ตัวอักษร',
              helper:
                  _isEdit ? 'ปล่อยว่างไว้หากไม่ต้องการเปลี่ยนรหัสผ่าน' : null,
              controller: _passwordController,
              obscureText: _obscurePassword,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.newPassword],
              validator: (v) => FormValidators.password(v, optional: _isEdit),
              suffixIcon: IconButton(
                tooltip: _obscurePassword ? 'แสดงรหัสผ่าน' : 'ซ่อนรหัสผ่าน',
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                ),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
