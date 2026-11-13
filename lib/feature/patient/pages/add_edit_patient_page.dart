import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ncd_screening_mobile/domain/models/ncd_models.dart';
import 'package:ncd_screening_mobile/feature/patient/bloc/patient_bloc.dart';
import 'package:ncd_screening_mobile/shared/tokens/tokens.dart';
import 'package:ncd_screening_mobile/shared/utils/form_validators.dart';
import 'package:ncd_screening_mobile/shared/widgets/app_dialogs.dart';
import 'package:ncd_screening_mobile/shared/widgets/app_feedback.dart';
import 'package:ncd_screening_mobile/shared/widgets/app_text_field.dart';

class AddEditPatientPage extends StatefulWidget {
  final VHV? vhv;
  final Patient? patient;
  final String villageId;
  final String? initialCitizenId;
  final String? initialTitle;
  final String? initialFname;
  final String? initialLname;

  const AddEditPatientPage({
    super.key,
    this.vhv,
    this.patient,
    required this.villageId,
    this.initialCitizenId,
    this.initialTitle,
    this.initialFname,
    this.initialLname,
  });

  @override
  State<AddEditPatientPage> createState() => _AddEditPatientPageState();
}

class _AddEditPatientPageState extends State<AddEditPatientPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _citizenIdController;
  late final TextEditingController _titleController;
  late final TextEditingController _fnameController;
  late final TextEditingController _lnameController;
  late final TextEditingController _addressController;
  late final TextEditingController _mobileController;

  String _gender = 'ชาย';
  DateTime _birthDate = DateTime(1980, 1, 1);
  bool get _isEdit => widget.patient != null;

  /// True once the user changed anything; guards against losing input.
  bool _dirty = false;
  bool _submitting = false;
  bool _showErrorsAsYouType = false;
  String? _formError;

  @override
  void initState() {
    super.initState();
    final p = widget.patient;
    _citizenIdController = TextEditingController(
      text: p?.patientCitizenId ?? widget.initialCitizenId ?? '',
    );
    _titleController = TextEditingController(
      text: p?.patientTitle ?? widget.initialTitle ?? 'นาย',
    );
    _fnameController = TextEditingController(
      text: p?.patientFname ?? widget.initialFname ?? '',
    );
    _lnameController = TextEditingController(
      text: p?.patientLname ?? widget.initialLname ?? '',
    );
    _addressController = TextEditingController(text: p?.patientAddress ?? '');
    _mobileController = TextEditingController(text: p?.patientMobile ?? '');
    if (p != null) {
      _gender = p.patientGender;
      _birthDate = p.patientBirthDate;
    }
  }

  @override
  void dispose() {
    _citizenIdController.dispose();
    _titleController.dispose();
    _fnameController.dispose();
    _lnameController.dispose();
    _addressController.dispose();
    _mobileController.dispose();
    super.dispose();
  }

  int get _calculatedAge {
    final now = DateTime.now();
    int age = now.year - _birthDate.year;
    if (now.month < _birthDate.month ||
        (now.month == _birthDate.month && now.day < _birthDate.day)) {
      age--;
    }
    return age;
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
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _birthDate = picked;
        _dirty = true;
      });
    }
  }

  /// Existing records keep their stored ID unless the user changes it, so
  /// the checksum is only enforced on a new or edited number.
  String? _validateCitizenId(String? value) => FormValidators.citizenId(
        value,
        checkDigit: widget.patient?.patientCitizenId != value?.trim(),
      );

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
    final patient = Patient(
      patientId: widget.patient?.patientId ?? '',
      patientCitizenId: _citizenIdController.text.trim(),
      patientTitle: title.isNotEmpty ? title : (_gender == 'ชาย' ? 'นาย' : 'นาง'),
      patientFname: _fnameController.text.trim(),
      patientLname: _lnameController.text.trim(),
      patientGender: _gender,
      patientBirthDate: _birthDate,
      patientAddress: _addressController.text.trim(),
      patientMobile: _mobileController.text.trim(),
      villageId: widget.villageId,
    );

    setState(() {
      _submitting = true;
      _formError = null;
    });
    context.read<PatientBloc>().add(
          _isEdit
              ? PatientUpdateRequested(patient)
              : PatientAddRequested(patient),
        );
  }

  /// The page stays open until the save is confirmed, so a failed save
  /// never throws the typed data away.
  void _onSaveResult(BuildContext context, PatientState state) {
    if (state.status == PatientStatus.success) {
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
    return BlocListener<PatientBloc, PatientState>(
      listenWhen: (prev, curr) =>
          _submitting &&
          prev.status == PatientStatus.loading &&
          ((curr.status == PatientStatus.success && curr.message != null) ||
              curr.status == PatientStatus.failure),
      listener: _onSaveResult,
      child: PopScope(
        canPop: !_dirty,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) _confirmLeave();
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(_isEdit ? 'แก้ไขผู้ป่วย' : 'เพิ่มผู้ป่วย'),
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
            AppTextField(
              label: 'เลขบัตรประชาชน',
              hint: 'ตัวเลข 13 หลัก',
              controller: _citizenIdController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              maxLength: 13,
              validator: _validateCitizenId,
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
                DropdownMenuItem(value: 'ชาย', child: Text('ชาย')),
                DropdownMenuItem(value: 'หญิง', child: Text('หญิง')),
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
              helper: 'อายุ $_calculatedAge ปี (คำนวณอัตโนมัติ)',
              onTap: _selectBirthDate,
            ),
            PSpacing.gapVerticalLg,
            AppTextField(
              label: 'ที่อยู่',
              hint: 'เช่น 60 หมู่ 1 บ้านท่าตอน อ.แม่อาย',
              helper: 'เลขที่บ้าน ซอย ถนน',
              controller: _addressController,
              maxLines: 2,
              keyboardType: TextInputType.streetAddress,
              validator: (v) =>
                  FormValidators.required(v, 'กรุณากรอกที่อยู่ให้ครบถ้วน'),
            ),
            PSpacing.gapVerticalLg,
            AppTextField(
              label: 'เบอร์มือถือ',
              optional: true,
              hint: 'เช่น 0812345678',
              controller: _mobileController,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.done,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              autofillHints: const [AutofillHints.telephoneNumber],
              maxLength: 10,
              // A number already on record is kept as it is.
              validator: (v) => v?.trim() == widget.patient?.patientMobile
                  ? null
                  : FormValidators.thaiMobile(v, optional: true),
            ),
          ],
        ),
      ),
    );
  }
}
